package jsonrpc

import (
    "net/rpc"
    "net/rpc/jsonrpc"
	"os" 
)

type JsonRpcConn struct{}

func (s *JsonRpcConn) Read(p []byte) (int, error) {
	return os.Stdin.Read(p)
}

func (s *JsonRpcConn) Write(p []byte) (int, error) {
	return os.Stdout.Write(p)
}

func (s *JsonRpcConn) Close() error {
	os.Stdin.Close()
	os.Stdout.Close()
	return nil
}

func Run(server *rpc.Server) {
	server.ServeCodec( jsonrpc.NewServerCodec(new(JsonRpcConn)) )
}