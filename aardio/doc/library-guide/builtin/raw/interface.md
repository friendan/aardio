# 原生接口类 raw.interface

raw.interface 有一定难度，一般用不到可以跳过不学。

raw.interface 用于导入或实现原生接口类。
可兼容 C++ 类定义中用 virtual 关键字声明的成员函数。
可兼容 COM 原生接口，导入或实现 COM 原生接口类 com.interface 内部也是调用 raw.interface 。

raw.interface 有两个主要作用：
- 将 C++ 等原生语言创建的原生接口对象（通常用内存指针访问）导入为 aardio 中的具有方法并易于使用的对象。
- 将 aardio 表对象实现为原生接口类兼容的对象，这种对象通常用于调用原生 API 函数的接口指针参数。

## 导入原生接口对象

```aardio
var rawObj = raw.interface(implPtr,declInterface,callingConvention)
```

- 参数 @implPtr 指定原生接口指针或地址数值。
- 参数 @declInterface 指定接口声明，这是一个类（class）或字符串。
- 可选用参数 callingConvention 指定调用约定，可省略。可选值为 "stdcall", "cdecl", "fastcall" 。默认值为 "stdcall" 。

## 实现原生接口

```aardio
var rawObj = raw.interface(implTable,declInterface,callingConvention)
```

- 参数 implTable 必须是纯表（不能有元表），并定义与 declInterface 接口声明类匹配的成员函数。aardio 并不要求实现原生接口声明类中声明的所有成员函数，未实现的函数在被调用时不执行操作。但具体接口是否要求实现所有成员，这样看接口文档的要求。
- 参数 @declInterface 指定接口声明，这是一个类（class）或字符串。
- 可选用参数 callingConvention 指定调用约定。默认值为 "stdcall" 。

实现原生接口也可以省略 implTable 参数，并且不用保持占位，如下：

```aardio
var rawObj = raw.interface(declInterface,callingConvention)
```

这种写法需要在创建对象后增加 rawObj 的成员函数，以实现 declInterface 声明的接口。

## 接口声明类

原生对象指的是 C++ 这种原生语言实现的对象。  
原生接口声明定义了原生对象提供哪些成员函数，以及这些成员函数的原型。  

原生接口声明一般指的是一个类。  
com.interface 名字空间下面的所有类都是 COM 原生接口声明类。   
com.interface 内部调用 raw.interface ，这种接口声明类的格式是兼容的。  

以下是 IUnknown 接口声明类：

```aardio
class IUnknown{
    ptr QueryInterface = "int(struct iid,ptr &ptr)" ;
    ptr AddRef = "int()" ;
    ptr Release ="int()" ;
}
```

原生接口声明类必须创建一个结构体， 
所有成员的原生类型必须是 ptr，而值必须用一个字符串声明原生函数原型。  
原型里使用的原生类型与声明原生 API 使用的类型相同。

请参考：[所有可用的原生类型文档](../../../library-guide/builtin/raw/datatype.md)

> 要特别注意：无论是在一个原生接口的声明类还是在接口实现表中，成员函数内部应当始终用 owner 访问当前对象。这是因为一个原生接口对象可能拥有来自声明类或实现表等不同来源的成员函数，owner 可以指向引用当前函数的实例对象。

原生接口声明可以用一个字符串表示，每行声明一个成员函数原型。

示例：

```aardio
this = raw.interface( pTest,"
    void getName(string &buffer,int len);
    void getInfo(struct &pInfo); 
    ","thiscall"  
)
```

参考：[范例 - 使用 thiscall 调用 C++ 对象](doc://example/Languages/CPP/thiscall.html?q=raw.interface%28)

用字符串声明接口时 aardio 会将其自动转换为前述的接口声明类。  
这种写法的唯一区别是将函数名直接写在原型里了，并且每行字符串表示一个成员函数。  

com.interface 里则不支持用字符串编写接口类声明，  
这是因为所有 COM 接口类声明都必须定义 IID 静态成员，并且必须继承自 com.interface.IUnknown 。
这就要求 COM 接口声明必须是类（ 但 com.interface 的参数支持用类名称表示 com.interface 下已导入的声明类 ）。

但是 com.interface 允许用一个字符串指定 com.interface 名字空间的接口声明类名称。
也就是说 `com.interface("IDropTarget")` 等价于 `com.interface(com.interface.IDropTarget)`

参考：[COM 动态接口与原生扫口](../com/base.md#interface)