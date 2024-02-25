# coding: utf-8

__author__ = "Marcel Rieger"
__email__ = "python-jsonrpyc@googlegroups.com"
__copyright__ = "Copyright 2016-2023, Marcel Rieger"
__credits__ = ["Marcel Rieger"]
__contact__ = "https://github.com/riga/jsonrpyc"
__license__ = "BSD-3-Clause"
__status__ = "Development"
__version__ = "1.1.1"
__all__ = ["RPC"]

import sys
import json
import io
import time
import threading

class Spec(object):

    @classmethod
    def check_id(cls, id, allow_empty=False):

        if (id is not None or not allow_empty) and not isinstance(id, (int, str)):
            raise TypeError("id must be an integer or string, got {} ({})".format(id, type(id)))

    @classmethod
    def check_method(cls, method):

        if not isinstance(method, str):
            raise TypeError("method must be a string, got {} ({})".format(method, type(method)))

    @classmethod
    def check_code(cls, code):

        if not isinstance(code, int):
            raise TypeError("code must be an integer, got {} ({})".format(id, type(id)))

        if not get_error(code):
            raise ValueError("unknown code, got {} ({})".format(code, type(code)))

    @classmethod
    def request(cls, method, id=None, params=None):

        try:
            cls.check_method(method)
            cls.check_id(id, allow_empty=True)
        except Exception as e:
            raise RPCInvalidRequest(str(e))

        req = "{{\"jsonrpc\":\"2.0\",\"method\":\"{}\"".format(method)

        if id is not None:
            if isinstance(id, str):
                id = json.dumps(id)
            req += ",\"id\":{}".format(id)

        if params is not None:
            try:
                req += ",\"params\":{}".format(json.dumps(params))
            except Exception as e:
                raise RPCParseError(str(e))

        req += "}"

        return req

    @classmethod
    def response(cls, id, result):

        try:
            cls.check_id(id)
        except Exception as e:
            raise RPCInvalidRequest(str(e))

        if isinstance(id, str):
            id = json.dumps(id)

        try:
            res = "{{\"jsonrpc\":\"2.0\",\"id\":{},\"result\":{}}}".format(id, json.dumps(result))
        except Exception as e:
            raise RPCParseError(str(e))

        return res

    @classmethod
    def error(cls, id, code, data=None):

        try:
            cls.check_id(id)
            cls.check_code(code)
        except Exception as e:
            raise RPCInvalidRequest(str(e))

        message = get_error(code).title
        err_data = "{{\"code\":{},\"message\":\"{}\"".format(code, message)

        if data is not None:
            try:
                err_data += ",\"data\":{}}}".format(json.dumps(data))
            except Exception as e:
                raise RPCParseError(str(e))
        else:
            err_data += "}"

        if isinstance(id, str):
            id = json.dumps(id)

        err = "{{\"jsonrpc\":\"2.0\",\"id\":{},\"error\":{}}}".format(id, err_data)

        return err


class RPC(object):

    EMPTY_RESULT = object()

    def __init__(self, target=None, stdin=None, stdout=None, watch=True, **kwargs):
        super(RPC, self).__init__()

        self.target = target

        stdin = sys.stdin if stdin is None else stdin
        stdout = sys.stdout if stdout is None else stdout
        self.stdin = io.open(stdin.fileno(), "rb")
        self.stdout = io.open(stdout.fileno(), "wb")

        self._i = -1
        self._callbacks = {}
        self._results = {}

        kwargs["start"] = watch
        kwargs.setdefault("daemon", target is None)
        self.watchdog = Watchdog(self, **kwargs)

    def __del__(self):
        watchdog = getattr(self, "watchdog", None)
        if watchdog:
            watchdog.stop()

    def __call__(self, *args, **kwargs):

        return self.call(*args, **kwargs)

    def call(self, method, args=(), kwargs=None, callback=None, block=0):

        if kwargs is None:
            kwargs = {}

        is_notification = callback is None and block <= 0

        id = None
        if not is_notification:
            self._i += 1
            id = self._i

        if callback is not None:
            self._callbacks[id] = callback

        if block > 0:
            self._results[id] = self.EMPTY_RESULT

        params = {"args": args, "kwargs": kwargs}
        req = Spec.request(method, id=id, params=params)
        self._write(req)

        if block > 0:
            while True:
                if self._results[id] != self.EMPTY_RESULT:
                    result = self._results[id]
                    del self._results[id]
                    if isinstance(result, Exception):
                        raise result
                    else:
                        return result
                time.sleep(block)

    def _handle(self, line):

        obj = json.loads(line)

        if "method" in obj:
            self._handle_request(obj)
        elif "error" not in obj:
            self._handle_response(obj)
        else:
            self._handle_error(obj)

    def _handle_request(self, req):

        try:
            method = self._route(req["method"])
            result = method(*req["params"]["args"], **req["params"]["kwargs"])
            if "id" in req:
                res = Spec.response(req["id"], result)
                self._write(res)
        except Exception as e:
            if "id" in req:
                if isinstance(e, RPCError):
                    err = Spec.error(req["id"], e.code, e.data)
                else:
                    err = Spec.error(req["id"], -32603, str(e))
                self._write(err)

    def _handle_response(self, res):

        if res["id"] in self._results:
            self._results[res["id"]] = res["result"]

        if res["id"] in self._callbacks:
            callback = self._callbacks[res["id"]]
            del self._callbacks[res["id"]]
            callback(None, res["result"])

    def _handle_error(self, res):

        err = res["error"]
        error = get_error(err["code"])(err.get("data", err["message"]))

        if res["id"] in self._results:
            self._results[res["id"]] = error

        if res["id"] in self._callbacks:
            callback = self._callbacks[res["id"]]
            del self._callbacks[res["id"]]
            callback(error, None)

    def _route(self, method):

        obj = self.target
        for part in method.split("."):
            if not hasattr(obj, part):
                break
            obj = getattr(obj, part)
        else:
            return obj

        raise RPCMethodNotFound(data=method)

    def _write(self, s):
        self.stdout.write(bytearray(s + "\n", "utf-8"))
        self.stdout.flush()


class Watchdog(threading.Thread):

    def __init__(self, rpc, name="watchdog", interval=0.1, daemon=False, start=True):
        super(Watchdog, self).__init__()

        self.rpc = rpc
        self.name = name
        self.interval = interval
        self.daemon = daemon

        self._stop = threading.Event()

        if start:
            self.start()

    def start(self):

        super(Watchdog, self).start()

    def stop(self):

        self._stop.set()

    def run(self):
        self._stop.clear()

        if not self.rpc.stdin or self.rpc.stdin.closed:
            return

        last_pos = 0
        while not self._stop.is_set():
            lines = None

            if self.rpc.stdin.closed:
                break

            if self.rpc.stdin.isatty():
                cur_pos = self.rpc.stdin.tell()
                if cur_pos != last_pos:
                    self.rpc.stdin.seek(last_pos)
                    lines = self.rpc.stdin.readlines()
                    last_pos = self.rpc.stdin.tell()
                    self.rpc.stdin.seek(cur_pos)
            else:
                try:
                    lines = [self.rpc.stdin.readline()]
                except IOError:
                    pass

            if lines:
                for line in lines:
                    line = line.decode("utf-8").strip()
                    if line:
                        self.rpc._handle(line)
            else:
                self._stop.wait(self.interval)


class RPCError(Exception):

    def __init__(self, data=None):
        message = "{} ({})".format(self.title, self.code)
        if data is not None:
            message += ", data: {}".format(data)
        self.message = message

        super(RPCError, self).__init__(message)

        self.data = data

    def __str__(self):
        return self.message


error_map_distinct = {}
error_map_range = {}


def is_range(code):
    return (
        isinstance(code, tuple) and
        len(code) == 2 and
        all(isinstance(i, int) for i in code) and
        code[0] < code[1]
    )


def register_error(cls):

    if not issubclass(cls, RPCError):
        raise TypeError("'{}' is not a subclass of RPCError".format(cls))

    code = cls.code

    if isinstance(code, int):
        error_map = error_map_distinct
    elif is_range(code):
        error_map = error_map_range
    else:
        raise TypeError("invalid RPC error code {}".format(code))

    if code in error_map:
        raise AttributeError("duplicate RPC error code {}".format(code))

    error_map[code] = cls

    return cls


def get_error(code):

    if code in error_map_distinct:
        return error_map_distinct[code]

    for (lower, upper), cls in error_map_range.items():
        if lower <= code <= upper:
            return cls

    return None


@register_error
class RPCParseError(RPCError):

    code = -32700
    title = "Parse error"


@register_error
class RPCInvalidRequest(RPCError):

    code = -32600
    title = "Invalid Request"


@register_error
class RPCMethodNotFound(RPCError):

    code = -32601
    title = "Method not found"


@register_error
class RPCInvalidParams(RPCError):

    code = -32602
    title = "Invalid params"


@register_error
class RPCInternalError(RPCError):

    code = -32603
    title = "Internal error"


@register_error
class RPCServerError(RPCError):

    code = (-32099, -32000)
    title = "Server error"