<?php  
function handleJsonRpc($requestJson) {
    $request = json_decode($requestJson);
    if ($request === null) {
        return json_encode(array('jsonrpc' => '2.0', 'error' => array('code' => -32700, 'message' => 'Parse error'), 'id' => null)) . "\n";
    }

    if (!isset($request->method)) {
        return json_encode(array('jsonrpc' => '2.0', 'error' => array('code' => -32601, 'message' => 'Method not specified'), 'id' => $request->id)) . "\n";
    }

    $methodParts = explode('.', $request->method);
    $params = isset($request->params) ? $request->params : array();

    try {
        if (count($methodParts) == 2) {
            $objectName = $methodParts[0];
            $methodName = $methodParts[1];

            if (isset($GLOBALS[$objectName]) && method_exists($GLOBALS[$objectName], $methodName)) {
                $result = call_user_func_array(array($GLOBALS[$objectName], $methodName), $params);
                return json_encode(array('jsonrpc' => '2.0', 'result' => $result, 'id' => $request->id)) . "\n";
            } else {
                return json_encode(array('jsonrpc' => '2.0', 'error' => array('code' => -32601, 'message' => 'Method not found'), 'id' => $request->id)) . "\n";
            }
        } elseif (count($methodParts) == 1) {
            $functionName = $methodParts[0];
            if (function_exists($functionName)) {
                $result = call_user_func_array($functionName, $params);
                return json_encode(array('jsonrpc' => '2.0', 'result' => $result, 'id' => $request->id)) . "\n";
            } else {
                throw new Exception("Function not found");
            }
        } else {
            throw new Exception("Invalid method format");
        }
    } catch (Exception $e) {
        return json_encode(array('jsonrpc' => '2.0', 'error' => array('code' => -32603, 'message' => $e->getMessage()), 'id' => $request->id)) . "\n";
    } catch (Error $e) {
        return json_encode(array('jsonrpc' => '2.0', 'error' => array('code' => -32603, 'message' => 'Internal error: ' . $e->getMessage()), 'id' => $request->id)) . "\n";
    }
}

$stdin = fopen('php://stdin', 'r');
while ($line = fgets($stdin)) { 
    $response = handleJsonRpc($line);
    echo $response;
    ob_flush(); flush();
}
fclose($stdin);
?>