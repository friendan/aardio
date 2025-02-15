
#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files:
#include <windows.h>
#include <SDKDDKVer.h>

#include "..\\include\\zbar.h"
#pragma comment(lib,"..\\lib\\libzbar-0.lib") 
using namespace zbar;

extern "C"  __declspec(dllexport) void * __cdecl CreateImageScanner()
{
	ImageScanner *scanner = new ImageScanner();
	scanner->set_config(ZBAR_NONE, ZBAR_CFG_ENABLE, 1);
	return scanner;
}

extern "C"  __declspec(dllexport) void __cdecl DeleteImageScanner(ImageScanner *scanner)
{
	delete scanner;
}

extern "C"  __declspec(dllexport) int __cdecl ScannerConfig(ImageScanner *scanner,const char * cfgstr)
{
	return scanner->set_config(cfgstr);
}

extern "C"  __declspec(dllexport) int __cdecl Scan( ImageScanner *scanner,const void *raw,int width,int height,const char * format,unsigned int length, void  (__cdecl *callback)(const char* type_name,const char * data)  )
{
    Image imageSrc(width, height, format, raw, length); 
	Image image = imageSrc.convert( *((long *)"Y800"));
    int n = scanner->scan(image);

    for(Image::SymbolIterator symbol = image.symbol_begin();
        symbol != image.symbol_end();
        ++symbol) {
			callback( symbol->get_type_name().c_str(),symbol->get_data().c_str() );
    }

    image.set_data(NULL, 0);
    return(n);
}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

