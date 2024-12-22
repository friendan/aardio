# 免声明直接调用原生 API 函数

  
aardio 免声明直接调用原生 API 函数示例：  

```aardio
::User32.MessageBox(0,"测试","标题",0) 
```

aardio 建议使用免声明的方式调用 API 函数，直接调用 API 更方便也更节省资源(除非有特殊的数据类型必须通过声明 API 来指定)。而且也可以更灵活地调整调用参数。

## 一、免声明调用 - 传参规则
  
1. 在加载 DLL 时可指定调用约定，支持 cdecl 调用约定的不定个数参数。

2. null、boolean(true,false),string、buffer、pointer,math.size64(64位长整数) 等数据类型一律直接传参，null 参数不可省略。
  
3. aardio 数值一律处理为 32 位 int 整型。

    如果 API 函数的要求的参数类型是等于或小于 32 位的整型（包括枚举、bool、BOOL类型），都可以直接传入 aardio 数值作为参数。 

    示例： 

    例如C语言API声明为：  
    `void setNumber( short n ) ` 
    
    在 aardio 里如下调用就可以：       
    `dll.setNumber( 123 ) ` 
  
4. 64 位整数可以 math.size64 对象表示。或者用两个数值参数表示一个64位整数值参数，其中第一个参数表示低32位数值，第二个参数表示高 32 位数值（一般可以直接写 0 ）。  
  
5. 任何 API 函数的数值类型的指针（输出参数）都可以使用结构体表示。

    例如 C 语言 API 声明为：
    `void getNumber( short *n ) `

    在 aardio 里如下调用就可以：

    ```aardio
    var n = {word value}  
    dll.getNumber( n )
    ```
  
    也可以使用 `raw.word(number,true)` 创建上面的结构体。  
  
6. API 函数中的原生数组指针类型，通过 aardio 结构体传原生数组。

    例如 C 语言中的 `int data[4]` 在 aardio 中写为 `{ int data[4] }` 。字节数组指针也可以使用 aardio 中的 buffer 对象。  
  
7. 如果调用参数是未定义任何原生类型的 aardio 表对象。
    * 如果表对象定义了 _topointer 元方法，则调用 _topointer 元方法返回的指针值作为调用 API 的指针参数。
    * 如果表对象未定义 _topointer 元方法,但定义了 _tonumber 元方法,则调用 _tonumber 元方法获取数值, 并支持在元表中用 _number_type 定义数值的原生数据类型。可以使用标准库提供的 `raw.byte() raw.ubyte() raw.word() raw.uword() raw.int() raw.uint() raw.long() raw.ulong() raw.double() raw.float()` 等函数创建这种在元表中声明了原生类型的数值对象, 这些函数的第一个参数指定要传递的数值,第二个可选参数如果为 true - 则返回用于传址的结构体对象。  
  
8. 所有 aardio 结构体一律处理为输出参数并在 aardio 返回值中返回，其他类型只能作为输入参数。注意在 aardio 中，任何结构体在 API 调用中传递的都是结构体指针（传址）。

    在未声明直接调用 API 时，所有结构体都会忽略 _topointer 元方法 - 这与调用已声明 API 函数的规则不同。
    
    在调用声明的 API 函数时。一个定义了_topointer 元方法的结构体参数如何传参将取决了对应的参数类型声明。如果参数要求结构体类型则会传递结构体指针，如果参数要求传递指针，则会传递 _topointer 元方法返回的指针。  
  
9. 因为没有参数类型声明，调用代码有责任事先检查并保证参数类型正确，传入错误的参数可能导致程序异常。  

## 二、免声明调用 - 返回值规则

1. 免声明直接调用 API的 返回值默认为 int 类型。如果原 API 返回的是 32 位无符号整数，那么只要简单的将返回值 [>>> 0](..\..\..\language-reference\operator\bitwise.md#unsigned-right-shift) 就可以得到原来的无符号数值了。  
  
2. 可以使用 **API 尾标** 改变返回值为其他类型。  

## 三、使用 API 尾标 <a id="api-name-suffix" href="#api-name-suffix">&#x23;</a>

API 尾标指的是 API 函数名尾部独立大写的特定字符。使用尾标可以修改默认的 API 调用规则。

- 尾标必须是函数名的最后一个大写字母，前面不能有其他大写字母。
- 无论真实的 API 函数名是不是包含实际的尾标字母，我们都可以在函数名后使用尾标并且尾标起的作用是相同的。
- aardio 会首先查找函数名称包含指定尾标的 API 函数。如果没有找到指定的 API 函数，aardio 会移除函数名称后面的尾标字母再次查找 API 函数。
- aardio 在找不到目标函数时，总是会自动加上 'W' 尾标寻找是否存在 Unicode 版本的函数。 

### 免声明调用 API 支持的尾标列表：   

- dll.ApiNameW() 切换到 Unicode 版本，字符串参数双向自动转换 UTF-16 编码与 UTF-8 编码。 

- dll.ApiNameA() 切换到 ANSI 版本，字符串参数不作任何转换。

- dll.ApiNameL() 返回值为 64 位 LONG 类型，在 aardio 中返回为 math.size64 对象，可用 tonumber 转换为普通数值。

- dll.ApiNameP() 返回值为指针类型（ pointer 类型），如果是字符串指针，可用 raw.str 或 raw.tostring 转换为字符串。

- dll.ApiNameD() 返回值为 double 浮点数。

- dll.ApiNameF() 返回值为 float 浮点数。

- dll.ApiNameB() 返回值为 8 位 bool 类型（兼容 32 位 BOOL 类型），在 aardio 中返回为布尔值（ true 或 false ）。

### 尾标 'W'，'A' 的特殊规则：

- 'W'，'A' 尾标在声明 API 或免声明 API 时都会起作用，其他尾标仅适用于免声明调用。
- 无论调用 API 函数是否先声明，aardio 在找不到目标函数时，总是会自动加上 'W' 尾标寻找是否存在 Unicode 版本的函数。
- 如果 API 函数名以 '_w' 结尾也会切换到 Unicode 版本，但 '_w' 不是尾标字母。'_w' 不能省略，aardio 也不会自动移除 '_w' 或 自动添加 '_w' 然后查找 API 函数。

### 示例：

```aardio
::User32.MessageBoxB(0,"消息","标题",0)
```  

对于上面的代码，aardio 会执行下面的步骤：

- aardio 找不到 `::User32.MessageBoxB`，于是移除尾标 `B` 查找 `::User32.MessageBox` 函数。
- aardio 仍然找不到 `::User32.MessageBox` 函数，于是自动加上尾标 `W` 查找 `::User32.MessageBoxW` 函数。
- `W` 尾标生效，aardio 将字符串参数转换为 UTF-16 编码并调用 API 函数。
- `B` 尾标生效，aardio 将返回值转换为布尔值。
  
## 四、免声明调用 API 如何使用字符串 <a id="strings" href="#strings">&#x23;</a>

1. 字符串一般直接转换为字符串指针，buffer 类型字节数组也可以作为字符串指针使用，如果 API 需要向字符串指向的内存中写入数据，那么必须使用 raw.buffer() 函数创建定长的字节数组。普通的 aardio 字符串指向的内存是禁止写入的（ aardio 中修改普通字符串会返回新的字符串对象，而不是在原内存修改数据）。
  
2. 对于非 UTF-16 API 字符串直接输入原始的数据（对于文本就是 UTF-8 编码），对于声明为 Unicode 版本的 API，字符串会被自动转换为 Unicode(UTF-16)，但 buffer 类型的参数仍然会以二进制方式使用原始数据与 API 交互（不会做文本编码转换）  
    * 可以在 raw.loadDll() 加载DLL时在调用约定中添加`",unicode"`声明一个DLL默认使用 UTF-16 API，  
    * 也可以在函数名后添加尾标 "W" 声明一个 UTF-16 API, 即使真实的 API 函数名后面并没有"W"尾标，你仍然可以添加"W" 尾标调用 API。aardio 在找不到该 API 函数时，会移除"W"尾标，并且仍然会认为该 API 函数是一个 UTF-16 API，注意尾部的 "W" 必须独立大写（前面不能有其他大写字母）。  
    * 直接调用 API 时，如果目标 API 函数并不存在，而是存在加 "W" 尾标的 UTF-16 API，aardio 将会自动切换到 UTF-16 API，并在调用函数时，自动将 aardio 的 UTF8 编码的字符串参数转换为 API 所需要的 UTF-16 编码字符串。  
    * 反之，在 API 函数名后也可以显式的添加'A'尾标强制声明此 API 是一个 ANSI 版本的函数（对字符串参数不使用任何 Unicode 转换，即使加载 DLL 时在调用约定中声明了默认以 unicode 方式调用），规则同上 - 也即真实的 API 函数名后面有没有'A'尾标并不重要，在 aardio 中都可以加上'A'尾标。  
  
3. 一些 API 在接收字符串、字节数组等参数时，通常下一个参数需要指定内存长度。请特别注意 aardio 中用 `#` 操作符取字符串、buffer 的长度时，返回的都是字节长度。一些 API 可能需要你传入字符个数（而不是字节数）。 注意 Unicod（ UTF-16 ） 版本的 API 里一个字符为两个字节，而 UTF-8 则为多字节编码。对于一个 UTF8 字符串应当事用 string.len() 函数得到真正的字符长度, 而 Unicode（ UTF-16 ） 字符串则用 # 取到字节长度后除以 2 即可得到字符数了（ 就现实情况来说基本都是如此处理 ）。

## 其他说明

- 未声明的原生 API 函数自身在 aardio 中是一个普通的aardio 函数对象，不能作为函数指针参数传给其他原生 API 参数。而声明的原生 API 函数则可以作为函数指针参数传递给其他原生 API 函数。  

- aardio 对未声明调用的 API 函数存在缓存机制，越是频繁使用的 API 就越是会优先缓存以避免重复获取，但 aardio 会根据需要回收较少被使用或不使用的免声明 API 函数对象。

    我们可以将免声明 API 函数保存到变量以自行掌握其生命周期：

    ```aardio
    var msgbox = ::User32.MessageBox; 
    msgbox(0,"消息","标题",0)
    ```

    这样带来的效率提升是非常有限的，一般没必要这么做。
