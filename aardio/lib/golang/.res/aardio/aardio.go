package aardio 

import "syscall"
import "unsafe"
import "encoding/json" 

var dllUser32 = syscall.NewLazyDLL("user32.dll")
var sendMessage = dllUser32.NewProc("SendMessageA")
var _WM_THREAD_CALLBACK = 0xACCE 

func Call(hwnd interface{},method string,params ...interface{}) (uintptr,uintptr,error){
	var p = method + "( {JSON} )"
	var b = append([]byte(p), 0)
 	var jsonParam, err = json.Marshal(params)
 	if err != nil { return 0,0,err }
	return sendMessage.Call(ConvertToUintptr(hwnd),uintptr(_WM_THREAD_CALLBACK),uintptr(unsafe.Pointer(&b[0])),uintptr(unsafe.Pointer(&jsonParam[0])));	
}

func CallPtr(fn interface{},args ...uintptr)(r1, r2 uintptr, err syscall.Errno){
	size := len(args) 
	if( size == 0 ) {
		return syscall.Syscall(ConvertToUintptr(fn),0,0,0,0)
	}
	
	var args2 [15]uintptr
	if(size>15) {
		return 0,0,160
	}
	
	for i := 0; i < size; i++ {
		args2[i] =  args[i]
	}
	
	return syscall.Syscall15(ConvertToUintptr(fn),uintptr(size),args2[0],args2[1],args2[2],args2[3],args2[4],args2[5],args2[6],args2[7],args2[8],args2[9],args2[10],args2[11],args2[12],args2[13],args2[14])
}

func CallJson(fn interface{},params ...interface{}) (int,error){ 
 	var jsonParam, err = json.Marshal(params)
 	if err != nil { return 0,err }

	var r1,_,_ = syscall.Syscall(ConvertToUintptr(fn),2,uintptr(unsafe.Pointer(&jsonParam[0])),uintptr(len(jsonParam)),0)
	return int(r1),nil
}

func JsonParam(jsonStr *string, v interface{}) (func()){  
	var bytes = []byte( *jsonStr ) 
	err := json.Unmarshal( bytes, v) 
	if( err!= nil ){  panic(err) } 

	return func(){ 
		bytes,err = json.Marshal( v ) 
		if( err!= nil ) {  panic(err) } 

		*jsonStr = string(bytes) 
	};
}

func ConvertToUintptr(val interface{}) (uintptr) {
	switch v := val.(type) {
	case float64:
		return uintptr(v)
	case int32:
		return uintptr(v)
	case uint32:
		return uintptr(v)
	case uintptr:
		return v
	default:
		panic("unsupported type") 
	}
}
