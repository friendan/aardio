#include "CSmtp.h" 
 
extern "C" __declspec(dllexport) CSmtp* __cdecl CreateSmtp() { 
	return new CSmtp();
}

extern "C" __declspec(dllexport) void __cdecl DeleteSmtp( CSmtp* pSmtp) {
	delete pSmtp;
}

 