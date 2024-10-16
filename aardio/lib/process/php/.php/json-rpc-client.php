<?php
class JsonRpcClient {
    
    function __construct($url = null) {
        if(is_null($url)) {
            $this->url = 'http://'.$_SERVER['HTTP_HOST'].'/jsonrpc';
        } else {
            $this->url = $url;
        }
    }
    
    public function xcall($method) {
        $params = func_get_args();
        array_shift($params);
    
        $request = array('jsonrpc' => '2.0', 'method' => $method, 'params' => $params, 'id' => 1);
        $request_json = json_encode($request);
        $context = stream_context_create(array(
            'http' => array(
                'method' => 'POST',
                'header' => "Content-Type: application/json\r\n",
                'content' => $request_json
            )
        ));
    
        //PHP 5 不稳定，PHP 7 没问题
        $result = file_get_contents($this->url, false, $context); 
        return json_decode($result);
    }
    
    public function __call($name, $arguments) {
        array_unshift($arguments, $name);
        return call_user_func_array(array($this, 'xcall'), $arguments);
    }
}
?>