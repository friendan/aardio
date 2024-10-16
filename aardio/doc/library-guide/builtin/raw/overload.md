# 重载 API 函数

请参考 [原生数据类型](datatype.md)

## 重载 API  

在 aardio 中如果通过 [免声明调用API函数](directCall.md) ,  
则可以改变参数个数、参数类型调用同一个 API 函数。  
  
任何时候应当优先采用[免声明调用API函数](directCall.md) 的方式。  
这种调用方式灵活并自由，但是参数检查并不严格，如果对 API 函数与原生类型不熟悉，  
可能因为传入错误的参数导致调用 API 函数异常或程序直接崩溃。  
  
声明 API 函数可以有更严格的参数类型检查，  
对于同名的 API 函数声明必须指定不同的变量名称，例如：

```aardio
::SendMessage = ::User32.api("SendMessageW","addr(addr hwnd,INT msg,ptr wParam,ptr lParam)")
::SendMessageInt = ::User32.api("SendMessageW","addr(addr hwnd,INT msg,ADDR wParam,addr lParam)")
::SendMessageByInt = ::User32.api("SendMessageW","addr(addr hwnd,INT msg,int &wParam,int &lParam)")
::SendMessageByString = ::User32.api("SendMessageW","addr(int,INT,int,string &lParam)")
::SendMessageByStr = ::User32.api("SendMessageW","addr(int,INT,int,ustring &lParam)")
::SendMessageByStruct = ::User32.api("SendMessageW","addr(int,INT,int,struct &lParam)")
```

注意重载 API 时一般约定以重载的类型作为函数名字后缀。如果重载的类型是输出参数则以 "By+类型名"作为后缀，例如 `::SendMessageByInt`。

## 参数传值与传址

1. 默认传值的原生类型

    原生数值类型包括:`int,INT,long,Long,byte,BYTE,float,double` 。double,float 表示小数，其他为整数。大写的整型为无符号整数，小写整型为有符号整数。

    在调用原生 API 函数时，上述数值类型，以及表示布尔值的 bool 类型，表示指针的 pointer、POINTER 类型 在 API 函数中默认都是传值。如果在类型名后面加上 `&` 则切换为传址。

    对于这些默认传值的类型，类型名后面加上 `&` 则切换为传址以后，目标 API 函数收到的值是完全不一样的。传值收到的是数据值，而传址收到的是存储数据值的地址。
  
2. 默认传址的原生类型 
   结构体(struct) 类型无论是不是在类型名后加上 `&` 都是传相同的指针，目标 API 函数收到的值是完全一样的。`string &` ，`struct &` 的意义仅仅是指示 aardio 要不要把 API 函数修改后的内存值取回来。

   字符串类型默认值址，加 `&` 后的处理请参考 [原生数据类型 - 字符串](https://)

## 隐式转换 <a id="implicit-raw-type-conversion" href="#implicit-raw-type-conversion">&#x23;</a>


如果你需要在API函数参数中使用不同的数据类型，aardio要求你显式的定义参数的类型，声明重载的API函数。
  
但是 aardio 也支持部分的隐式自动转换：

- null 可以表示空指针，
- null,pointer,string 类型可以相互转换。
- 所有类型都可以自动转换为 bool 类型，非 0. 非 null、非 false 值为 true，反之为 false。

在 aardio 中省略参数就会传递 null 空值作为实参,  
因此 pointer,string 类型的 API 参数都可以省略参数传递默认的null值。

例如:

```aardio
::SendMessage( 0xFFFF, 0x1A )
```

上面的第三个参数、第四个参数省略了，aardio 会默认传递 null 值，自动转换为如下的代码:

```aardio
::SendMessage( 0xFFFF, 0x1A, null, null )
```

但是如果我们将 SendMessage 的第三个参数、第四个参数的形参指定为 int 数值类型， 那么空值就要显式指定为 0，如下:

```aardio
::SendMessageInt(0xFFFF/*_HWND_BROADCAST*/, 0x1A/*_WM_WININICHANGE*/,0,0 )
```

原生类型编程中有很多需要注意的细节，如果你不是很清楚这个参数在做什么，不应当随意的更改 API 参数的类型。  

## 句柄   

一个特例是 Windows 中使用的句柄。句柄是一个特殊的数值，用来指向内核对象的地址，这一点类似指针。但是句柄比指针更安全一些，Windows 会管理句柄的分配与访问，访问一个错误的句柄一般不会导致程序崩溃。

在 aardio 中应当将句柄声明为指针类型，这至少可以提醒你不要随意的对句柄进行算术运算。唯一的一个特例是 aardio 将窗口句柄声明为 addr 类型，这实际上是一个数值类型，其他任何句柄都应当声明为 pointer 或 POINTER 类型。

从本质上来说所有的类型都可以相互替代, 它们都是具有不同意义的数值。
而在 aardio 中也可以显式的调用 topointer 函数将一个数值转换为指针。或者调用 tonumber 将一个指针转换为数值。 

## 结构体的空值

在C/C++中结构体也是一个指针,可以为 null 值,  
  
而 aardio 对结构体有严格的限制，禁止用其他类型来取代结构体,也不允许传递 null 值。这种设计对增强程序的健壮性有非常重要的意义，它避免你因为失误少写一个参数导致的崩溃错误。结构体指向的内存通常较为重要，应小心的使用。  
  
aardio 允许你使用 `{}` 构建一个空的 table 对象表示结构体参数的空值。你必须显式地告诉 aardio 你确实想使用一个空值。

## 我们正在使用的是动态语言

你可能已经被上面的指针、数值搞的晕头转向了,但是别忘了,aardio 是动态语言，虽然支持原生接口编程，但大多时候你并不需要去使用这些底层的、麻烦的功能。在 aardio 中，你可以把通过原生接口实现的功能用动态语言灵活地封装和应用，在保持原生接口开发能力的同时，享受动态语言的轻便灵活。