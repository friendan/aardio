# API原生回调函数

本节介绍如何将 aardio 动态函数转换为原生回调函数指针。

请参考：[raw库](api.md) 、[原生类型](datatype.md)

## 一、stdcall,cdecl 调用约定 

stdcall 调用约定由被调用函数恢复堆栈。cdecl 调用约定由主调函数恢复堆栈。  

一般系统 API 使用 stdcall 调用约定，纯 C 语言实现的 DLL 通常使用 cdecl 调用约定。

在一个 DLL 中通常会统一使用一种调用约定，如果 API 为 stdcall 调用约定，则回调函数一般也是 stdcall 调用约定。

参考：[API 调用约定](api.md#calling-convention)
  
## 二、创建 stdcall 约定的原生回调函数

WinAPI 回调函数使用 stdcall 约定,stdcall 是调用外部函数时使用最普遍的调用约定。使用 raw.tostdcall函 数将普通 aardio 函数转换为支持 stdcall 调用约定的可回调函数。 

示例：
  
```aardio
var func = function(a,b,c) {  
    print(owner,a,b,c) 
}


var func_c = raw.tostdcall( func,"(int,int,int)" );

//回调函数也可以在 aardio 中被调用执行，例如： 
func_c(1,2,3)
```  

raw.tostdcall 的第一个参数为函数对象。
第二个参数为函数原型，在原型中指明参数与返回值的 [原生数据类型](datatype.md)，其语法与 [声明 API](api.md) 相同。

原生回调函数由 aardio 内存管理器自动进行垃圾回收。 
如果回调函数仍然被外部函数调用，您必须保持原生回调函数在有效作用域内。

回调函数是一个 cdata 对象，回调函数声明了 _topointer 元方法，因此可以自动转换为pointer 指针。

可以从一个 aardio 函数创建多个回调函数。

为区别不同的回调函数，可以附加一个参数以显式指定 owner 指针的值。

示例：
  
```aardio
var func2_c =raw.tostdcall( func,"(int,int,int)" ,"可以附加一个参数，以指定被回调函数的 owner 值" );  
```  

## 三、创建 cdecl 约定的原生回调函数

使用 raw.tocdecl 函数将普通 aardio 函数转换为支持 cdecl 调用约定的可回调函数。

除了将 raw.tostdcall 函数改为  raw.tocdecl ，其他用法与上面的 raw.tostdcall 一样。 
  
## 四、创建 fastcall 约定的原生回调函数

使用 raw.tofastcall 函数将普通 aardio 函数转换为支持 fastcall 调用约定的可回调函数。 

除了将 raw.tostdcall 函数改为  raw.tofastcall ，其他用法与上面的 raw.tostdcall 一样。  

## 五、多线程原生回调函数

普通回调函数创建于当前线程环境，  
不能将普通回调函数指针传递给其他线程使用。  
  
如果一个原生回调函数不是在当前线程被触发，应作如下替换：  

- 用多程版本的 thread.tocdecl() 替换 raw.tocdecl()  
- 用多程版本的 thread.tostdcall() 替换 raw.tostdcall()  
- 用多程版本的 thread.tofastcall() 替换 raw.tofastcall()  
  
上述 thread 名字空间下的函数与 raw 名字空间下的同名函数参数与用法相同，  
区别是 thread 名字空间提供的函数创建的原生回调函数是可以多线程使用的。

要注意在多线程回调函数里要遵守 aardio 的 [多线程开发规则](../../../guide/language/thread.md)。
例如要注意 import 等语句要写到函数内部， 这与创建线程的规则相同，因为不同线程的变量环境各自独立。  

当使用 thread.tostdcall, thread.tocdecl() thread.tofastcall() 等函数创建多线程回调函数时，aardio 将会自动初始化线程环境 - 并且可以共享、重用已创建的线程环境。  
  
即使线程不是由 aardio 代码所创建，aardio 仍然会自动管理所有被动创建的线程环境，在回调函数对象  离开作用域，或者发起调用的线程结束时 aardio 根据需要自动回收资源。  

## 六、原生回调函数对象的内存管理与释放 <a id="gc" href="#gc">&#x23;</a>

如果所有引用原生回调函数对象的变量被赋值为 null 或者超出作用域不再有效，  
将会由 aardio 内存管理器自动回收并删除。  
  
因此：如果原生回调函数对象仍然被外部API函数调用，你必须确定原生回调函数在有效作用域内，并且没有被赋值为null。 这一点非常重要，你释放了原生回调函数，可是外部组件的C、C++却并不知道，如果原生回调函数对象已被回收，再次调用原生回调函数将会导致不可预知的错误。  
  
如果原生回调函数被指定为某对象的成员，在函数内部又循环引用了该对象，  
这会导致无法释放资源。使用参数 @3 将该对象指定为 owner 可避免该问题  
  
下面是一个错误用法的示例：  
  

```aardio
this.createCallback = function(callback){
  this.callback = ..raw.tostdcall( 
    function(...){
      this.beforeCallback(...) //这里导致了循环引用自身的问题
      return callback(...); 
    },proto); 	
}
```  
  
正确用法是使用 owner 参数引用对象自身，如下：  

```aardio
this.createCallback = function(callback){
  this.callback = ..raw.tostdcall( 
    function(...){
      owner.beforeCallback(...) 
      return callback(...); 
    },proto,this); 	
}
```  

注意只有线程内原生回调函数要注意这个问题，多线程原生回调函数无法跨线程直接引用对象，而普通函数不会有这些问题。 

无论是 COM 事件回调还是原生 API 回调函数，它们都有一个共同特征是要避免上述的循环引用。而纯 aardio 对象或函数不存在这种问题。参考：[避免 COM 事件表的循环引用](../com/event.md#gc)

## 七、在原生回调函数中使用返回值、输出参数

原生回调函数的返回值类型检测较宽松，支持按 C 语言规则兼容转换。  
null 值返回 0，true 返回 1, false 返回 0,所有数值、浮点数值，布尔值、null值，math.size64 值等声明类型与实际返回值类型可自动转换。返回其他类型则尝试转换为指针值返回。  
  
但原生回调函数返回值声明为 struct 类型时则必须返回一个不大于 64 位的结构体，且传值而非传址（与 struct 用在参数中总是传址不同）。
  
原生回调函数声明中不指定返回值或指定为 void 无返回值 （但仍然可以通过输出参数添加不定个数的返回值）。
  
在原生回调函数声明中，可以在参数类型后添加`&`声明输出参数，例如C,C++中的`int *`指针可以声明为`int &`， 在 aardio 函数中使用返回值输出参数（有几个输出参数，增加几个返回值），例如：  
  
```aardio
cdeclCallback = raw.tocdecl( function(a,b){

	//使用返回值输出参数（有几个输出参数，增加几个返回值）
	return 0,a,456;
},"int(long &a,int &b )")
```  

也可以把参数声明为指针，再自己修改指针的值，示例： 

```aardio
cdeclCallback = raw.tocdecl( function(a,b){ 
  raw.convert({long v = 123},a);
  return 0;
},"int(ptr a,int b )")
```  

## 八、在原生回调函数中声明结构体

原生回调函数中，对于 struct 型参数，可以用一个实际的结构体声明替换 struct 类型，例如 `raw.tocdecl(func,"int(struct pt)") `我们可以更改为 `raw.tocdecl(func,"int({int x;int y} pt)")` ，也可以在结构体后面加一个`&`表示输出类型的参数，并可通过返回值修改调用者传入的原结构体的值（回调函数无对应返回值时忽略此操作），  
  
在回调函数中直接声明结构体时，要注意结构体不能再包含其他结构体（简单说只能出现一对`{}` ），并且除了结构体的字段名以外 - 不能在该结构体声明中使用其他变量名。

## 九、示例程序：在 WinAPI 函数中使用回调函数枚举桌面窗口

枚举与遍历桌面软件可以直接使用标准库函数 [winex.enum](../../std/winex/winex.md#enum), [winex.each](../../std/winex/winex.md#each) 更方便一些。

WinAPI 回调函数使用 stdcall 约定,stdcall 是调用外部函数时使用最普遍的调用约定。

调用 ::User32.EnumWindows 枚举桌面窗口示例：
  
```aardio
import console;
	
//回调函数
var enumwndProc = function(hwnd,lparam ){ 
	//在控制台显示所有参数
	console.log("回调owner:" + owner.tag , "窗口句柄:" + hwnd , "回调附加参数:" + lparam ); 
	return 1 ; //如果有输出的传址参数，在这里按传入顺序添加所有参数到返回值后面
}

//转换为原生回调函数
enumwndProc_c = raw.tostdcall(enumwndProc,"int(int hwnd,int lparam )" ,{tag='crane'} ); 

//回调函数在 API 参数中可自动转换为 pointer 类型指针。 
::User32.EnumWindows(enumwndProc_c ,12330); 

//可以确定回调函数不再使用，赋值为null，并等待由内存垃圾回收 
enumwndProc_c = null; 
```

