#include <JSON>

EnvGet externalInfo,AARDIO_AHK_EXTERNAL_INFO
externalInfo := JSON.load(externalInfo)

global  AARDIO_AHK_EXTERNAL_RESULT

class aardio_form{
	__New(hwnd)
	{
		this.hwnd := hwnd
	}
	
	__Call(method, params*)
	{
		if( -1 == DllCall("user32\SendMessage","int",this.hwnd,"UINT",0xACCE,"Str",method . "( {JSON} )","Str" ,JSON.dump(params),"int") ){
			if( AARDIO_AHK_EXTERNAL_RESULT ) {
				return JSON.load(AARDIO_AHK_EXTERNAL_RESULT)
			}
		}
	}
}

global aardio := new aardio_form(externalInfo.hwnd)