# COM 基础知识

COM 具有与语言，平台无关的特性，aardio 提供 com 库对 COM 组件提供支持。

## 一、COM 组件

COM(Component Object Model 组件对象模型 )是开发软件组件的一种方法。COM 组件实际上是一些小的二进制可执行程序，它们可以给应用程序，操作系统以及其他组件提供服务。在 COM 构架下，人们可以开发出各种各样的功能专一的组件，然后将它们按照需要组合起来，构成复杂的应用系统。可以在多个应用系统中重复利用同一个组件；可以方便的将应用系统扩展到网络环境下；COM具有与语言，平台无关的特性，aardio 提供 com 库对 COM 组件提供支持。

## 二、CLSID 与 ProgID <a id="id" href="#id">&#x23;</a>


每个COM接口和组件类都有一个全球唯一的标识符GUID，接口的标识符叫做IID，组件类的标识符叫CLSID(其实都是GUID)，组件类还可以用一个别名ProgID来标识，ProgID由类名+工程名组成,例如flash控件的ProgID: "ShockwaveFlash.ShockwaveFlash"

aardio标准库中有一个win.guid库,可以创建转换guid,下面是一个将ProgID转换为GUID的示例:

  
```aardio
import win;
import win.guid

guid = win.guid.fromString("ShockwaveFlash.ShockwaveFlash")
win.msgbox(guid)
```  

下面是将CLSID转换为ProgID的示例:

  
```aardio
import win;
import win.guid 

str = win.guid.toProgId("{d27cdb6e-ae6d-11cf-96b8-444553540000}") 
win.msgbox( str )
```  

## 三、动态接口、原生接口 <a id="interface" href="#interface">&#x23;</a>


COM 对象有两种类型的接口,一种是动态语言用到的 IDispatch 接口,一种是静态语言用到的原生接口。在 aardio 中可同时支持双接口,在 aardio 中我们将 IDispatch 接口称为动态接口,而非 IDispatch 类接口称为原生接口。

### 1. 动态接口对象 <a id="IDispatch" href="#IDispatch">&#x23;</a>

IDispatch 接口对象使用一个封装接口指针的 table 对象表示。

这种对象的元类型为 com.IDispatch，所以我们也称为 com.IDispatch 对象。

aardio 中提到的 "COM 对象"都是特指这种 IDispatch 对象。使用 com.IsObject 函数可以判断一个对象是否 IDispatch 对象.  

使用以下函数可以创建 IDispatch 对象：

- [com.GetObject](com.md#CreateObject) 
- [com.CreateObject](com.md#GetObject) 
- [com.QueryObject](com.md#QueryObject) 

com 库还提供了一些基于以上函数封装的对象可以创建 COM 对象：

- com.TryCreateObject 函数，创建 COM 对象失败返回 null 还不是报错。
- com.GetOrCreateObject() 获取已打开的 COM 对象，获取失败就尝试创建对象，失败返回 null 还不是报错。

创建 COM 对象示例：

```aardio 
import com;
import console;

//创建 COM 对象，注意 COM 有关的函数通常首字母大写
var fs = com.CreateObject("Scripting.FileSystemObject");

//使用 COM 对象
var dir = fs.GetFolder( io.fullpath("~/") ); 

//遍历COM对象成员
for index,file in com.each(dir.Files) {
    console.log(file.path);
}

console.pause();
```

可以嵌入窗口的 COM 控件对象也是  IDispatch 对象。

我们可以使用窗口或控件对象提供的 createEmbed 或 createEmbedEx 函数创建这种嵌入窗口的 COM 控件对象。

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="嵌入COM控件";right=759;bottom=469)
/*}}*/

//嵌入 COM 控件，宿主窗口这里指定为 winform
var embedObject= winform.createEmbedEx("Shell.Explorer.2"); 

//通过控件容器调用 COM 对象打开指定的网页
embedObject.Navigate("about:这是一个网页");


winform.show();
win.loopMessage();
```
  
### 2. 原生接口对象 <a id="IUnknown" href="#IUnknown">&#x23;</a>


- COM 对象指针

  注意 COM 对象可以实现多个接口，也就是说可以同时实现 IDispatch 接口或其他原生接口。

  如果要通过非 IDispatch 接口去访问 COM 对象则需要使用 COM 对象指针。

  在 aardio 里有两种 COM 对象指针：
  * pointer 类型的原生裸指针，COM 指针的引用计数与管理相对较复杂，直接操作这种指针较为麻烦，如果没有小心遵守复杂的 COM 规则可能会直接导致程序崩溃。
  * 由 aardio 内核对象封装的 IUnknown 指针，aardio 数据类型为 cdata，元类型为 "com.IUnknown" 。IUnknown 指针会按 COM 规则自动管理引用计数，不再使用时可自动回收释放，也可以调用  com.Release() 显式释放。 

  有关的库函数：
  * 使用[com.GetPointer](com.md#topointer) 可以获取一个 com.IDispatch 对象的 IUnknown 接口原生指针.  
  * 也可以使用[com.GetIUnknown](com.md#GetIUnknown) 函数获取 com.IDispatch 对象的 com.IUnknown 内核对象.  
  * com.IUnknown 内核对象可自动释放,或调用.而 pointer 类型 IUnknown 原生指针则必须手工调用 com.Release() 显式释放  
  * 使用[com.GetIUnknown](com.md#GetIUnknown)函数也可以将一个 poineter 指针转换为com.IUnknown 内核对象.  
  * 使用 com.IsIUnknown 数可以判断一个对象是否 com.IUnknown 内核对象.

- COM 原生接口对象

  aardio 支持 COM 原生接口。

  COM 原生接口是基于指定的原生接口定义对 COM 指针进行操作的对象。

  在标准库的 com.interface 名字空间下可找到很多这类原生接口，可查看源码了解如何定义 COM 原生接口。
  
  COM 原生接口使用的参数的数据类型与调用原生原生 API 相类似，参考 raw 库 [相关文档](../raw/datatype.md) 即可。

  在 aardio 中使用 COM 原生接口的情况其实很罕见，一般不必要学习。
  

