# raw 库 - 声明原生 API 函数

使用 raw 库函数可操作[原生数据类型](datatype.md)、可导入外部 DLL 文件提供的原生 API 函数。

## 一、加载 dll 模块 <a id="loadDll" href="#loadDll">&#x23;</a>


语法：

`dll = raw.loadDll( path | strMemoryDll,shareName,callingConvention="stdcall");  `
  
说明：

raw.loadDll 从路径 path 或内存数据 strMemoryDll 中加载 DLL 模块，然后我们可以使用 dll.api 函数声明我们需要用到的api函数。 
  
如果自内存加载 DLL，可选使用 shareName 参数指定多线程共享名， 指定 shareName 后，多个线程可共享同一内存DLL模块，指定 shareName 参数后可省略参数@1 —— 此时仅查找已加载的DLL。  
  
callingConvention 参数指定默认调用约定，可省略，不指定时默认值为 "stdcall" 。操作系统 API 使用默认的 "stdcall" 调用约定。C 语言编写的 DLL 一般会使用 C 语言调用约定 "cdecl" 。callingConvention 最常见的参数就是  "stdcall" 或者 "cdecl"。更多细节请查看 [DLL 调用约定](#calling-convention)。

加载内存 DLL 示例：

```aardio
dllmodule := raw.loadDll($"d:\\hardware.dll");
```  
参考：[包含文件操作符 $](../../../language-reference/operator/include.md)

aardio 已默认加载以下 DLL 模块  

```aardio
::User32, ::Kernel32, ::Ntdll, ::Shell32
```

使用 aardio『工具 / 转换工具 / API 转换』工具可自动转换 C/C++ 的 API 函数声明为　aardio 格式，并自动识别 `::User32, ::Kernel32, ::Ntdll, ::Shell32` 这些 DLL 模块提供的函数。

注意: <a id="arch" href="#arch">&#x23;</a>

> 如果 DLL 厂商仅提供一个版本的 DLL，一般是 32 位的 DLL，在 aardio 可以直接加载， aardio 程序也是 32 位的，而 32 位程序兼容所有平台，而 64 位程序只能运行在 64 位平台。 如果 DLL 厂商提供了 64 位、32 位两个版本的 DLL，这时候你需要选择 32 位版本的 DLL 才能加载，如果 对方只提供 64 位的 DLL (比较罕见)，只要包装为进程调用，aardio 仍然可以支持。 aardio 做多进程、多线程开发都非常方便。 通过多进程交互，aardio 就可以非常方便地调用 64 位的组件。 
> 
> 一个常见的误解是认为 32 位不能调用 64 位程序，其实这种限制仅仅是进程内的限制，对跨进程调用并没有限制。而且目前跨进程调用更为普及，稳定性与兼容性都更好。典型的最常见的浏览器应用就是多进程架构。在 aardio 中利用标准库中的　web.view 就可以非常方便地调用 64 位的 WebView2 组件。
>
> aardio 中多进程组件以及可以用于多进程架构的库非常多，包括但不限于 web.view, process, process.popen, process.ruffle, process.python, process.command，process.rpc, web.rpc, web.socket, process.util,com,com.excel,com.activeX …… 

## 二、声明 API 函数 <a id="api" href="#api">&#x23;</a>


1. 语法：

	```aardio
	var dll = raw.loadDll( path | strMemoryDll,shareName,callingConvention="stdcall" );

	dll.api( 函数名|函数序号,函数原型,调用约定="stdcall",this指针=null) 
	```
2. 说明

	这里的 dll 指 raw.loadDll 加载的 dll 模块对象。

	dll.api 函数的第一个参数是加载的 DLL 模块中导出的 API 函数名字，或导出函数序号。

	调用约定为可选参数，默认为加载 DLL 模块时指定的调用约定。如果加载 DLL 时未指定调用约定，则默认值为 "stdcall"。更多细节请查看 [API 调用约定](#calling-convention)。
	
	可选的 this 指针参数用于 thiscall 调用约定绑定 C++ 中 this 对象的指针，也可用于其他调用约定中指定默认的第一个参数。 
	
	函数原型是以一个字符串表示的 API 函数声明，定义该函数的参数类型、返回值类型等, 这里的类型指原生数据类型. 例如:

	`"int(int a,int b)"`

	定义了一个函数原型,有一个 int 类型的参数a,一个 int 类型的参数 b,返回值为 int 类型。
	
	请参考: [原生数据类型](datatype.md)

3. UTF-16 API 与尾标 <a id="api-name-suffix" href="#api-name-suffix">&#x23;</a>

	aardio 支持对 Unicode 版本 API 的字符串参数进行 UTF-16 与 UTF-8 编码的双向自动转换。

	请参考：[Unicode（UTF-16） API 函数](utf16.md)

	API 尾标指的是 API 函数名尾部独立大写的特定字符。使用尾标可以修改默认的 API 调用规则。
	- 尾标必须是函数名的最后一个大写字母，前面不能有其他大写字母。
	- 无论真实的 API 函数名是不是包含实际的尾标字母，我们都可以在函数名后使用尾标并且尾标起的作用是相同的。
	- aardio 会首先查找函数名称包含指定尾标的 API 函数。如果没有找到指定的 API 函数，aardio 会移除函数名称后面的尾标字母再次查找 API 函数。
	- aardio 在找不到目标函数时，总是会自动加上 'W' 尾标寻找是否存在 Unicode 版本的函数。 

	在声明 API 时，可支持 'W'，'A' 两种尾标。

	[免声明 API 再可以支持更多尾标。](directCall.md#api-name-suffix)

	如果 API 函数名以 '_w' 结尾也会切换到 Unicode 版本，但 '_w' 不是尾标字母。'_w' 不能省略，aardio 也不会自动移除 '_w' 或 自动添加 '_w' 然后查找 API 函数。 

	如果不写函数原型参数，使用 `dll.api("导出符号名")` 格式搜索 DLL 导出符号则 aardio 不会自动添加或移除尾标。

4. 声明原生 API 示例

	```aardio
	//导入DLL
	var dll = raw.loadDll("User32.dll"); 

	//声明 API
	messageBox = dll.api( "MessageBox", "void(int hWnd,ustring lpText,ustring lpCaption ,INT uType )","stdcall") //最后一个参数可以省略

	//调用 API 函数
	messageBox( 0, "这是一个测试对话框", "对话框标题", 0 )
	```  

	要注意  MessageBox 并不存在，aardio 会自动切换到 MessageBoxW ，并识别 ['W' 尾标](#api-name-suffix)，切换到 [Unicode( UTF-16 ) API](utf16.md) ，然后参字符串参数与返回值进行 UTF-8 与 UTF-16 编码双向自动转换。

	aardio 已经默认导入了 `::User32, ::Kernel32, ::Ntdll, ::Shell32` 这几个 DLL 模块，所以上面的代码可简化为：

	```aardio
	messageBox = ::User32.api( "MessageBox", "void(int hWnd,ustring lpText,ustring lpCaption ,INT uType )","stdcall") //最后一个参数可以省略

	//调用 API 函数
	messageBox( 0, "这是一个测试对话框", "对话框标题", 0 )
	```

	aardio 其实 [不用声明也可以直接使用 DLL 导出的 API 函数](directCall.md)，一般除非是有什么不能自动转换的类型，不必要先声明，aardio 提倡无声明直接调用 API 函数，例如：

	```aardio
	::User32.MessageBox(0,"这是一个测试对话框","对话框标题",0)
	```

### 三、声明内部函数 <a id="function-pointer" href="#function-pointer">&#x23;</a>


语法：

```aardio
var dll = raw.loadDll();
var func = dll.api( 内部指针地址,函数原型 ) 
```

如果调用 raw.loadDll() 时未使用任何参数，则 dll.api 的第一个参数应当是一个内部函数指针。

实际上 aardio 已经用以下的代码默认加载了 raw.main 模块：

```aardio
raw.main = raw.loadDll();
```

所以我们可以直接写：

```aardio
var func = raw.main.api( 内部指针地址,函数原型 ) 
```

一个有趣的示例(危险操作,请勿模仿):

```aardio
import win; 

var func = function(str){ win.msgbox( "非法操作:" + str) }

//转换为原生函数指针 
var func_c = raw.tostdcall(func,"void(str)" )

//获取原生指针，对内核对象使用 topointer,tonumber 等函数是无效的 
funcAddr = raw.toPointer(func_c)

//声明一个特殊的API,调用内部函数指针 
func_api = raw.main.api( funcAddr ,"void(str)" )

//看来是一件很无聊的事,转来转去,我们只是调用 aardio 函数而已. 
func_api("hello")
```

## 四、API 调用约定  <a id="calling-convention" href="#calling-convention">&#x23;</a>

加载 DLL 与声明 API 时都可选指定调用约定参数。

调用约定参数也可以不指定，默认值为"stdcall"，可选值为"cdecl","thiscall"，"fastcall"，"regparm(n)"等.

可以在调用约定后面紧跟一个逗号以及目标 DLL 的开发平台，可选值为",borland"， ",microsoft" 。microsoft 是默认选项可以省略。实际上需要用到 ",borland" 这个选项的情况现在基本遇不到了，即使是调用 Delphi 编写的 DLL，"stdcall","cdecl" 等调用约定都不需要指定开发平台。 

"thiscall" 是 C++ 对象调用约定，可在声明 API 时增加一个参数指定 this指针，如果不在声明时指定，也可以在调用时用首参数传递 this 指针。

fastcall,regparm(n) 调用约定( 也就是寄存器传参方式 ) 详解:

> "fastcall"
> "fastcall,microsoft"
> 以上两种写法作用相同，前2个小于等于32位的数值参数使用edx,ecx寄存器， > 如果还有参数则自右向左依次压栈; 由被调者负责维护堆栈平衡(清除压入的参> 数);如果函数有返回值则把返回值存放在eax寄存器中.
> 
> "fastcall,borland"
> 同上，前3个小于等于32位的数值参数使用eax,edx,ecx寄存器，
> 
> "fastcall,regparm(n)"
> "stdcall,regparm(n)"
> 以上两种写法作用相同，n可以为3,2,1,前n个参数使用eax,edx,ecx寄存器,如果为1则仅使用eax，为2仅使用eax,edx
> 
> "regparm(n)"
> "cdecl,regparm(n)"
> 以上两种写法作用相同，n可以为3,2,1,前n个参数使用eax,edx,ecx寄存器,如果为1则仅使用eax，为2仅使用 eax,edx 。如果还有参数则自右向左依次压栈; 由调者负责维护堆栈平衡(清除压入的参数);如果函数有返回值则把返回值存放在eax寄存器中.

在调用 raw.loadDll 函数时，可以在调用约定中添加 ",unicode" 声明该 DLL 的所有 API 为 [UTF-16 API](utf16.md) 。例如：` raw.loadDll("test.dll",,"stdcall,unicode")` 声明该 "test.dll" 中所有 API 为 UTF-16 API 。但要注意每个 API 函数仍然可以声明自己是不同的编码，API 参数也可以使用参数类型明确的声明是文本还是二进制字符串。  

### 五、DLL 导出符号 <a id="dllimport" href="#dllimport">&#x23;</a>

1. 语法：

	```aardio
	var dll = raw.loadDll();
	var ptr = dll.api( "导出符号名" ) 
	```

2. 说明：

	dll.api 仅指定一个参数时直接返回导出符号指针而非返回原生函数对象。

	查找导出符号时会精确匹配"导出符号名"，不会对"导出符号名"自动添加或移除 A,W 尾标，

	此操作不会增加 DLL 的引用计数，在使用导出符号指针时 DLL 模块对象应在生存周期内。

	使用此方法可以获取 DLL 导出的数据指针，或者用精确匹配函数名的方式获取 DLL 的导出函数指针。

3. 示例

	```aardio
	//取到 DLL 导出函数指针
	var pMsgbox = ::User32.api("MessageBoxW"); 

	//将函数指针转换为函数 
	var msgbox = raw.main.api(pMsgbox,"void(int,ustring,ustring,int)" );

	//调用函数
	msgbox(0,"消息","标题",0);
	
	```
	实际调用 DLL 导出函数不需要这么复杂，直接调用就可以了，例如：

	```aardio
	//调用 DLL 导出函数
	::User32.MessageBox(0,"消息","标题",0);
	```