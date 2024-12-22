# 原生数据类型（ raw datatype ）

原生类型指的是直接访问和操作原生内存数据的类型系统。

aardio 本身是动态语言，aardio 语言本身的数据类型( datatype ) 与原生数据类型( raw datatype ) 是两套类型系统。aardio 会自动做必要的类型转换，但不要混淆这两种数据类型。举个例子，在原生数据类型中数值有 int,long,double,float …… 一大堆，但是对于 aardio 语言本身的类型系统来说，数值都是双精度浮点数（相当于 double 类型）。

原生接口有关的文档提到的"API 函数"是特指的外部 DLL 文件提供的原生接口函数，例如操作系统 DLL 提供的 "WinAPI" 函数。DLL 文件通常由 C/C++ 等原生编程语言编写。

在 aardio 中使用原生类型主要有两种方式：

- raw 库函数
- 原生 API 函数。这个主要是指原生 DLL 接口。
- aardio 定义的结构体。 

参考：

- [raw库](api.md)
- [aardio 数据类型](../../../language-reference/datatype/datatype.md) 
- [使用结构体](struct.md)

## 原生数据类型( raw datatype )  

注意原生数据类型声明严格区分大小写，数据类型大写表示对类型有更严格的限制条件。  

- 数值类型小写表示允许负数，大写表示无符号数据类型(没有负数，仅有正整数)。   
- 对于支持指针的类型(string,pointer)，小写表示允许 null 值并允许自动转换（例如字符串转换为指针），大写表示不接受 null 实参。  

> 使用 aardio『工具 / 转换工具 / API 转换』工具可自动转换 C/C++ 的 API 类型、结构体、函数声明为　aardio 格式。  
  
注意 C/C++/WinAPI 的数据类型名有一些复杂，同一个类型有无数的不同名字，而同一个类型名字可以处理为不同的类型。

aardio 对原生类型做了简化，只要掌握几个基础类型就可以了。  
  
例如句柄类型，有时候作为无符号数，有时候作为有符号数，有时候又作为指针类型处理，实际上你无论是使用指针类型、有符号数值类型、还是无符号数值类型，对于句柄来说内存中的值是相同的，例如 topointer(-1) == topointer(0xFFFFFFFF) 的结果是相等的。 在 aardio 标准库里，一般句柄类型都被处理为指针，只有窗口句柄( HWND )在 aardio 中统一被声明为 addr 类型。

| 类型 | 原生类型 | 位长 | aardio 类型 | C 语言类型 | WinAPI 类型 | 备注 |
| :--- | :---- | :---- | :---- | :---- | :---- | :---- |
| 无符号字节 | BYTE | 8位 | 数值，例：<br>` { BYTE chr = 'A'# }` | unsigned char | BYTE | 注意 C++ 中的 bool(小写)类型为一个字节(8位),字节长度等价于 aardio 中的 byte 类型。 |
| 字节 | byte  | 8位 | 数值，例：<br> `{ byte chr = 'A'# }` | char |  |
| 无符号短整型 | WORD | 16位 | 数值，例：<br> `{ WORD n = 123 }` | unsigned short | WORD |  |
| 短整型 | word | 16位 | 数值，例：<br>` { word n = -2 } `| short |  |
| 无符号整型 | INT | 32位 | 数值，例：<br> `{ INT n = 123 }` | unsigned int,unsigned long | DWORD | WinAPI中H前缀通常表示32位数。 |
| 整型 | int | 32位 | 数值，例：<br> `{ int n = -2 }` | int,long | LRESULT,<br>LPARAM,<br>WPARAM |
| 无符号长整型 | LONG64 | 64位 | math.size64 长整数，或普通数值，例：<br> `{ LONG a = 123; LONG b = math.size64(456) } `| `unsigned long long ,unsigned __int64` |  | 可缩写为LONG,<br>1. API函数返回值中LONG类型返回为math.size64对象<br>2. 在API回调函数中，LONG类型回调参数为math.size64对象<br>3. 在结构体中LONG类型字段值为math.size64对象时,aardio始终<br>保持该对象的类型以及地址不变，反之则处理为64位浮点数值<br> |
| 长整型 | long64 | 64位 | 数值，例：<br> `{ long a = -2;  } `| `long long,__int64` |  | 可缩写为 long |
| 内存地址 | ADDR | 32位/64位 | 无符号数值，例：<br> `{ ADDR n = 123 }` | void\* | UINT_PTR,<br>ULONG_PTR<br>,DWORD_PTR,<br>HWND | 注意使用数值表示地址时,为保持更好的兼容性,请使用此类型,而不要使用固定位长的int,INT,long,LONG等类型替代,<br> |
| 内存地址 | addr | 32位/64位 | 有符号数值，例：<br> `{ ADDR n = 123 }` | void\* | INT_PTR,<br>LONG_PTR,<br>HWND |
| 浮点数 | float | 32位 | 数值，例：<br> `{ float n = 123 } `| float | FLOAT |  |
| 双精度浮点数 | double | 64位 | 数值，例：<br>` { double n = 123 } `| double |  |  |
| 布尔值 | bool | 32位 | true,false | int | BOOL<br>int | 原生类型中的布尔值可以指定任何 aardio 对象，并自动转换为 true 或 false。<br><br><br> 注意 C++ 中的 bool(小写)类型一般实现为1个字节(8位),在 aardio 中相同长度的是 byte 类型。 而 aardio 中的 bool 类型,在 C++ 中相同长度的为 BOOL(大写，32位 int) 类型。<br><br> 因为 aardio 的 bool 类型实际上会转换为 C++ 的 bool,BOOL 都兼容的 0(false) 或 1（true），在 API 的参数类型与返回值类型中 C++ 的 bool,BOOL 在 aardio 中都可以声明为 bool 类型。但是在结构体类型中应当用等长的 byte 替代 C++ 的 bool 类型 |
| 指针 | pointer<br>ptr | 32位/64位 | pointer null | `void*` | PVOID,<br>LPVOID,<br>LPCVOID<br>HANDLE,<br>HINSTANCE | 此类型可缩写为ptr,或PTR,也可以使用所有p开头的自定义类型名字表示指针。<br> <p>指针值必须是一个 pointer 类型或null值，在aardio中空指针为null而不是0，table 或 cdata 对象可以通过元表中的\_topointer成员返回一个有效指针(不能为null)或指针数值， \_topointer可以是一个值（元数据）或者一个函数（元方法）。 <br><br> 注意在未声明直接调用 API 函数时，对于结构体 aardio 将默认忽略元表中的 \_topointer 优先将其作为结构体处理，除非存在类型声明 —— 则优先按类型声明处理（如果声明为指针则执行 \_topointer 元方法获取指针） <br><br> 在 API 或结构体中声明为指针类型的参数或字段，都可以兼容指针、字符串、字节数组(buffer)、动态指针、声明了 \_topointer 元方法的表或 cdata 对象。 如果一个被作为 API 函数输出参数的结构体的指针字段被赋值为 buffer 或 声明了 \_topointer 元方法的表，在这个结构体返回时如果指针指向的地址没有变化则字段值不变（仍然指向原来的 buffer 或表对象） </p> |
| 指针 |POINTER<br>PTR | 32位/64位 | pointer | `void*` | PVOID,<br>LPVOID,<br>LPCVOID<br>HANDLE,<br>HINSTANCE |大写的 POINTER 表示参数不接受null指针(空指针为null，而不是0)，不能转换字符串为常量指针。|
| 字符串 | string | 32位 | string pointer null | const char\* | LPCSTR,<br>LPSTR  | <p>二进制字符串（但是在结构体中自内存读取此类型字段时，会返回遇 `'\0'` 结束的纯文本字符串），也可以接受 pointer 指针值 。在API回调函数或结构体中 API 返回 0~0xFFFF 或 -1 的指针地址 aardio 将转换为指针而不是字符串 <br></p> |
| 字符串 | STRING | 32位 | string pointer | `const char*` | LPCSTR,<br>LPSTR   | 大写 STRING 则表示参数不接受 null 指针  |
| 文本字符串 | str | 32位 | string pointer null | `const char *` |  | <p>在普通API中表示`'\0'`结束的文本(不含 `'\0'`)，在 Uniocde API中等价于 ustring (遇 `'\u0000'` 结束)。在API回调函数或结构体中API返回0~0xFFFF或-1的指针地址aardio将转换为指针而不是字符串</p> <p></p> |
| 字节数组 | pointer | 32位/64位 | buffer null | `char *`,`unsigned char *` |  | <p>这种可以让 API 读或写数据的字节数组也就是 aardio 中的 buffer 类型，使用 raw.buffer() 函数创建 buffer。 <br><br>如果一个被作为 API 函数输出参数的结构体的指针字段被赋值为 buffer ，在这个结构体返回时如果指针指向的地址没有变化则字段值不变（仍然指向原来的 buffer） </p> <p></p> |
| UTF-16 字符串 | ustring | 32位 | ustring pointer null | `const wchar_t *` | LPCWSTR,<br>LPWSTR,    | <p>Unicode(UTF16) 纯文本字符串 (遇 `'\u0000'` 结束)，aardio 会自动做双向编码转换，传给 API 时是 UTF16 ，从 API 返回时转换为 UTF8。在 API 回调函数或结构体中API返回0~0xFFFF或-1的指针地址aardio将转换为指针而不是字符串 <br></p> |
| UTF-16 字符串 | USTRING | 32位 | string pointer | `const wchar_t* `| LPCWSTR,<br>LPWSTR,    |  类型名 USTRING 大写时禁用 null 值。|
| 结构体 | struct | 32位 | table | struct |  | <p>注意在原生 API 函数中，struct 对象总是传址（传结构体指针），如果是按值传递的结构体，可尝试[展开其成员为多个普通参数](struct#by-val)。<br><br>原生 API 函数的 struct 参数不允许传 null 值，必须使用空表 `{}` 表示结构体指针传 null 值。</p> <p></p> |
| 联合 | union | 32位 | table | union |  | `u = { union value = { BYTE c=8; WORD s=123; } }` |
| 空类型 | void |  |  | void |  | 标识函数返回值为空 |
|  |   |  |  |   |  | <div style="width:590px"></div>  |


声明的数据类型必须保持绝对正确，使用错误的类型会导致内存读写错误并导致程序崩溃。调用原生 API 函数大部分导致崩溃的错误原因基本都是因为定义了错误的原生数据类型。

## 原生数组(raw array)  <a id="raw-array" href="#raw-array">&#x23;</a>


原生数据类型数组必须写在一个结构体里面。

示例：

```aardio
var bytes = { 
	byte buffer[256]={1,2,3} 
}
```  

必须在中括号内指定一个有效的数值表示数组长度。
中括号内表示数组长度的只能是一个数值字面量，不能写变量。

如果原生数组不指定数组长度,则表示创建一个变长原生数组，
aardio 将会在运行时检测并获取实际的原生数组长度，变长原生数组在运行时的长度不能为 0。

变长原生数组确定长度的方式有两个方法：

- 用数组的 length 属性确定原生数组长度，length 的优先级更高。
- 如果找不到 数组的 length 属性，则用数组实际包含的元素个数确定原生数组长度。

```aardio
//创建变长数组
var bytes = { 
	byte buffer[] 
}

//根据运行时的数组长度确定原生类型数组长度
bytes.buffer={1,2,3} 

//用 length 属性指定数组长度
bytes.buffer={ length=20 } 
```  

原生数组类型列表：

| 数组类型 | aardio 类型声明 | aardio 示例 | 备注
| :--- | :--- | :--- | :--- |
| 无符号字节 | `BYTE []` | `array = { BYTE str[2] = {'A'#,'B'#} }`<br><br>或者<br>`array = { BYTE str[2] = "AB" }`<br><br>或者<br>`array = { BYTE str[2] = {0x41;0x42} }`<br><br>也可以不指定数组长度,<br>aardio根据运行时值自动获取数组长度,<br>例如:<br><br>`array = { BYTE str[] = "AB" }`</p> | 定长 string,<br>或者 table 数组(元素是数值或null值)<br><br>如果将字段指定为 null 或字符串,则 aardio 始终将该字段处理为字符串对象。要特别注意这是定长字符串，结构体写入内存时总是会填充至指定长度（不足长度补`'\0'`）。自内存读取为字符串时返回二进制字符串，可以包含`'\0'`，不以'\\0'为结束符，不会丢失尾部 `'\0'`。如果需要转换不含`'\0'`的文本字符串，请调用 string.str() 函数。<br><br>如果指定为 table 字节数组,则 aardio 始终将该字段处理为数组，可以调用 string.pack 函数将数组转换为字符串.<br><br>也可以使用 buffer 对象作为参数<br> |
| 字节 | `byte []` | `array = { byte arr[2] = {} }` | 数组元素支持数值或 null 值、以及 buffer ，如果将字段指定为 null 或字符串，处理规则就与 `BYTE[]` 相同|
| 无符号短整型 | `WORD []` | `array = {  WORD arr[2] = {'A'#,'B'#} }` | 如果值是一个 table 数组则 aardio 总是将该字段处理为数组，数组元素支持数值、 null 值，不支持 buffer 对象。<br><br>如果值为空，或者值是一个字符串，aardio 则总是将该字段作为一个 UTF16 编码的 Unicode 文本字符串处理，在调用 API、以及作为输出结构体参数时 aardio 会自动做 UTF16 到 UTF8 的双向自动转换（ 读取或获取 aardio 字符串是 UTF-8, 写入内存或传入原生 API 则自动转为 UTF-16 编码字符串)，此字符串总是会处理为文本字符串，（字符串内容不含`'\u0000'`，遇 `'\u0000'` 结束） |
| 短整型 | `word []` | | 数组元素支持数值或 null 值，不支持 buffer 对象。如果将字段指定为 null 或字符串，处理规则就与 `WORD[]` 相同 |
| 无符号整型 | `INT []` | `array = { INT arr[2] = {} }` | 数组元素支持数值或 null 值 |
| 整型 | `int []` | | 数组元素支持数值或 null 值 |
| 无符号长整型 | `LONG64 []` | `array = { LONG arr[2] = {}  }` | 数组元素支持数值、math.size64 对象或 null 值 |
| 长整型 | `long64 []` | `array = { long arr[2] = {} }` | 数组元素支持数值、 null 值 |
| 无符号指针地址 | `ADDR []`| `array = { ADDR arr[2] = {} }` | 数组元素支持数值、 null 值 |  
| 指针地址 | `addr []` | `array = { addr arr[2] = {} }` | 数组元素支持数值、 null 值 | 
| 浮点数 | `float []` | `array = { float arr[2] = {} }` | 数组元素支持数值、 null 值 |
| 双精度浮点数 | `double []` | `array = { double arr[2] = {} }` | 数组元素支持数值、 null 值 |
| 布尔值 | `bool []` | `array = { bool arr[2] = {} }` | 布尔数组元素支持任意值 |
| 指针 | `pointer []`,`POINTER []` | `array = { pointer arr[2] = {} }` | 数组元素支持 pointer、string，或可转换为指针的对象，小写类型名支持 null 值 |
| 字符串 | `string []`,`STRING []` | `array = { string arr[2] = {} }` | 数组元素支持 字符串，小写类型名支持 null值 |
| 结构体 | `struct []` | `array = { struct arr[2] = { ::POINT() } }` | 至少要在第一个数组元素指定结构体实例 |
| <div style="width:60px"></div>  |   |<div style="width:190px"></div>  |<div style="width:290px"></div>  |

定义原生数组的要点：

- `struct[]` 类型数组至少需要显示声明数组中的第一个元素为有效结构体实例。  
- 大写的 `STRING[]`,`POINTER[]` 类型数组不允许数组成员为 null 值。  
- 其他已声明长度的原生数组，数组成员可以包含 null 值或为空数组，但数组本身不能为 null 值。  
- 未声明长度的变长原生数组必须用 lenght 指定长度或者赋值为非空数组以确定长度，原生数组长度不能为 0。
- `BYTE []`，`byte []` 类型数组可以指向数组，也可以指向字符串。
- `WORD []`，`word []` 类型数组可以指向数组，也可以指向字符串（ [自动转换 UTF-16 编码](utf16.md#word-array) ）。

请参考：[结构体 - 原生数组](struct.md#raw-array)

## 原生输出参数( raw output parameters )

在 aardio 中，如果在原生 API 函数声明的参数类型名以后添加 `&` 符号，表示这个参数的值允许被外部函数修改并且会返回修改后的值。  

如果一个原生 API 函数含输出参数，那么每个输出参数都会按原来的先后顺序附加在返回值后面返回。aardio 遵循纯函数原则，函数的数据只有唯一的入口(参数)，也只有唯一的出口(参数)，所以被修改的输出参数必须显示地从返回值输出。

  
```aardio
//加载 DLL 模块
var dll = raw.loadDll("/test.dll");

//声明 API 函数
var apiFunc = dll.api("apifunc", "int(addr hwnd,string text,string &caption,INT uType)" )

//增加返回值以接收 API 输出参数
var ret,caption = apiFunc(hwnd,text,caption,uType);
```  

| 输出类型 | aardio 类型声明 | C 语言类型 | 备注 |
| ---: | :--- | :--- | :--- |
| 无符号字节 | `BYTE &` | `unsigned char *` |
| 字节 | `byte &` | `char *` |
| 无符号短整型 | `WORD &` | `unsigned short *` |  |
| 短整型 | `word &` | `short *` |
| 无符号整型 | `INT &` | `unsigned int *` |  |
| 整型 | `int &` | `int * `|
| 无符号长整型 | `LONG64 &` | `unsigned long long *` | 该参数支持普通数值，以及math.size64()创建的长整数 |
| 长整型 | `long64 &` | `long long *` |
| 无符号指针地址 | `ADDR &` | `void** `|  |
| 指针地址 | `addr &` | `void **` |  |
| 浮点数 | `float &` | `float *` |  |
| 双精度浮点数 | `double &` | `double *` |  |
| 布尔值 | `bool &` | `bool *` `BOOL *` |   |
| 指针 | `pointer &`<br>`POINTER &` | `void **` | 二级指针。 |
| 字符串 | `string &`<br>`STRING &` | `char **` | <p>string &类型的参数可以使用 buffer 对象（这时候对应的输出参数返回值为buffer类型，而非字符串）。<br><br> 如果参数是一个字符串，这时候 aardio 会创建一个等长的临时的 buffer 并拷贝字符串到该内存，并将内存指针发送给API函数，在调用结束后增加相应的返回值返回新的字符串。<br><br> 如果参数是一个指定 buffer 长度的数值（以字节为单位），aardio初始化 buffer 所有字节值为0，并且在 buffer 尾部增加2个字节并写入'\\u0000'。使用参数0表示传递给此类型参数一个null指针(而不是使用null空参数）<br><br>这种API类型，也可以在 aardio 中声明为pointer指针类型，然后用 raw.buffer() 函数创建一个可以让API写入数据的 buffer 传过去。</p> |
| 文本字符串 | `str &` | `const char **` | 同上,但以'\\0'为终结符返回文本字符串。如果参数使用 buffer 对象，这时候对应的输出参数返回值为字符串，而非buffer类型 |
| 宽字符串 | `ustring &`<br>`USTRING &` | `wchar_t * `| <p>可以使用 buffer 对象（这时候对应的输出参数返回值为字符串，而非buffer类型）。<br><br> 如果参数是一个字符串(aardio会自动转换为UTF16编码再取长度)，这时候aardio会创建一个等长的临时的 buffer 并拷贝字符串到该内存，并将内存指针发送给API函数，在调用结束后增加相应的返回值返回新的字符串。<br><br> 如果参数是一个指定 buffer 长度的数值（以字符为单位，一个字符占2个字节），aardio初始化 buffer 所有字节值为0，并且在 buffer 尾部增加2个字节并写入'\\u0000'。使用参数0表示传递给 buffer 一个null指针(而不是使用null空参数）<br><br>也可以 buffer 对象作为参数，如果使用 buffer，输入值不转换编码，但返回值转换为UTF8编码，并转换为字符串类型作为返回值（不改变输入参数的类型）</p> |
| 结构体 | `struct &` | `void *` | 结构体按引用传递，具有副作用的，即使不接收对应的返回值，结构体仍然可被API函数修改值。<br><br>可以在API参数中使用空结构体 {} 表示C/C++中的null结构体指针 <br><br>请参考：[table参数的副作用](../../../language-reference/function/parameter.md#table) |
| <div style="width:60px"></div>  |   |  |<div style="width:390px"></div>  |

请特别注意：`struct ` 与 `struct &` 类型在 API 参数里传递的都是相同的结构体指针，目标 API 参数收到的值是一样的。`struct &` 并不是二级指针。
区别是指定为 `struct `类型时 aardio 会丢弃外部 API 对结构体的修改（速度更快），而指定为 `struct &`类型时外部 API 对结构体的修改会被同步到 table 对象。无论是不是接收了新的返回值，`struct &`类型的参数都具有副作用，这一点与其他类型是完全不同的。

但其他数值类型以及 bool、pointer、POINTER 类型如果加上 `&` 则是传址（指针），否则是传值，目标 API 函数收到的值是完全不一样的。例如 API 形参定义为 `int`，那么你传递实参数值 123 时，API 函数接收到的是 123 这个数值。  
如果 API 形参定义为 `int &`，那么你同样传递参数值 123 时，API收到的是指向 123 的地址，是另外一个数值。   

我们要特别注意，纯 aardio 对象与原生数据类型对象在内存里的结构是完全不同的。所以我们并不能将 aardio 里的对象的指针传给外部 API 函数。当我们在调用 API 时对于 `int &` 这样的原生数据类型的输出参数，aardio 是在调用时临时分配了一块内存，在调用 API 函数结束后会立即释放该内存。所以在外部 API 中不得保存这样的内存指针，如果要传给外部 API 函数稳定不变的指针，则需要使用 raw.buffer , raw.realloc 分配原生内存。

aardio 结构体传给外部 API 函数时，同样会分配临时的内存指针，在 API 调用结束后立即释放。如果要传稳定不变的指针，则需要将结构体转换为 buffer 类型，或者使用 raw.struct 创建结构体。 

## 在 API 函数中使用字符串

aardio 中的 string 数据类型是传址的，多个相同内容的字符串变量内部指向相同的内存数据。  而字符串内存数据是只读的，修改字符串总是会导致 aardio 创建新的字符串，而不是改变原字符串的内存数据。

1. 获取原生 API 输出的字符串

	对于外部API函数：  

	如果一个字符串有可能被外部函数所改变，并且需要返回修改后的新字符串，那么在API函数参数中应将其声明为 `string &` 以通知 aardio 字符串的内存可能被修改，而在结构体中应声明为 `BYTE[]` 数组。在结构体中的 `BYTE[]` 是一个字节数组，仍然可以使用字符串进行赋值。例如：  

	
	```aardio
	//字段 b , b2 的内存数据是相同的
	class struct{
		BYTE b[3] = {'a'#;'b'#;'c'#};
		BYTE b2[3] = "abc";//BYTE 数组仍然可以使用字符串进行赋值
	}
	```  

2. 获取原生 API 输出的 UTF-16 字符串

	对于可能被外部函数所改变 Unicocde( UTF-16 )  字符串，可将类型声明 `ustring` 变更为 `ustring &` 以通知 aardio 字符串的内存可能被修改。而在结构体中应声明为 `WORD[]` 数组。在结构体中的 `WORD[]` 是一个宽字节数组，仍然可以使用字符串进行赋值。例如：  

	```aardio
	class struct{
		WORD b[3] = {'a'#;'b'#;'c'#};
		WORD b2[3] = "abc"; 
	}
	```  

	对于 `WORD[]` 类型如果值是一个 table 数组则 aardio 总是将该字段处理为数值数组。如果值为空，或者值是一个字符串，aardio 则总是将该字段作为一个 UTF16 编码的 Unicode 文本字符串处理，在调用 API、以及作为输出结构体参数时 aardio 会自动做 UTF16 到 UTF8 的双向自动转换（ 读取或获取 aardio 字符串是 UTF-8, 写入内存或传入原生 API 则自动转为 UTF-16 编码字符串)，此字符串总是会处理为文本字符串，（字符串内容不含`'\u0000'`，遇 `'\u0000'` 结束）

3. 使用 buffer 分配的内存获取 API 输出的字符串

	在 API 中字符串实际上是一个内存指针，因此 API 函数中的字符串参数同样可以声明为指针类型。  

	使用 raw.buffer 创建的 buffer 对象 - 在API函数中该类型等价于一个C语言中的 `char *` 指针，该指针指向可修改的内存，在 API 函数返回以后，可以再用 raw.tostring() 将 buffer 指针转换为普通字符串。

	实际上不传换也可以用，在 aardio 中大多数字符串函数可以直接支持将 buffer 类型的字节数组作为字符串参数直接使用。

	> 注意：buffer 对象用于普通 API 函数的`pointer`类型的输入参数，或普通结构体`pointer`类型成员指针。buffer 接收的是指针指向的数据而不是接收指针本身。对于声明为 声明为 `pointer &` 类型的参数，应当用 null 值或者 pointer 类型的指针值去接收新的指针。

4. 结构体中的字符串类型 

	在结构体中声明为 string 类型，作为输出参数使用时，这时候接收的就是一个字符串的地址，例如将 `{string pStr}`作为 API 参数，结构体指针就是字符串的指针。这里有一个比较奇怪的问题，在 WinAPI 中有一些结构体的字符串指针字段在某些情况下会将字符串指针赋值为一个小于 0xFFFF 的原子值、ID 等数值，aardio 对这种情况做了分别处理，对于结构体中的 string 类型 - 如果 API 返回的是一个字符串指针则获取指针并转换为字符串，对于小于 0xFFFF 或者为 -1 的值， aardio 会将其转换为指针类型的值。

5. 接收字符串指针

	要注意将 API 参数类型声明为 `string &`,`ustring &` 接收字符串，或者在结构体中声明为`BYTE[]`或者 `WORD[]` 接收字符串，或者创建 buffer 对象接收字符串，这几种不同形式的本质都相同的，也就是分配一块内存让原生 API 可以写入数据。

	如果我们要接收的不是字符串的数据，而是字符串的指针本身。那么用  `string &`,`ustring &` 是不行的。

	实际上在调用原生 API 时，遇到这个需求的可能性很小。对于静态语言，把字符串指针单独传给调用者，谁负责释放是很麻烦的一件事。一般写 API 函数的人不会没事自己给自己找麻烦。

	通过原生 API 函数接收字符串指针分为两种情况：
	- 在函数返回值中返回，这又分为两种情况：
		* 如果不需要调用者释放，我们可以声明 API 类型为 `string()` 就可以了，aardio 拿到指针然后自动转换为字符串，转换为 aardio 字符串以后就不会再使用外部指针，所以外部 API 怎么释放都没不会影响到 aardio 代码。
		* 如果需要调用者释放内存，我们可以声明 API 类型为 `pointer()` 就可以了，拿到指针以后，调用 raw.tostring 或者 raw.str 转换为 aardio 字符串，Unicode（UTF16）字符串则调用 string.fromUtf16 转换为 UTF-8 字符串，纯二进制也可以考虑转换为 buffer。然后就是调用外部 API 释放该指针就行了。
	- 在函数的输出参数中返回，这有两种方法可以获取：
		* 声明为 `pointer &` 类型，参数不用传值（因为指针支持 null 值），然后在增加到返回值列表的输出参数中得到指针。跟上面一样，调用 raw.tostring 或者 raw.str 转换为 aardio 字符串。然后看对方的要求是不是要调用什么函数释放获取到的指针。
		* 将参数声明为 `struct  &` 类型，然后传 `{string pStr}` 得到字符串。示例：

			```aardio
			var getString = dll.api( "GetString","void(struct &ppStr)" );  
			var str = getString( {string value} ); 
			```
		
	要注意区别 `string &`，`ustring &` 接收的是数据而不是指针，我们大多时候需要接收的是数据，需要接收字符串指针的情况较为少见。


## 在原生 API 函数中使用指针

在 aardio 中 API 函数会严格的检测数据类型，不允许直接用数值作为 API 函数 pointer 类型指针实参。  
  
`pointer &` 类型的输出参数必须使用 pointer 类型的实参、或 null 值接收新的指针值。

`pointer ` 类型输入参数中可以使用 string、pointer 类型的实参、也可以使用 buffer 对象。如果 aardio 对象声明了 `_topointer` 元方法，并通过 `_topointer` 元方法返回一个 pointer 指针或数值，则可以作为指针实参使用。 `_topointer` 元方法可以指向返回指针或内存地址的函数，也可以直接设置一个指针或内存地址值（数值）。

aardio 字符串的指针是常量指针，外部 API 函数不应当修改 aardio 字符串指针指向的内存。 而 raw.buffer 分配的内存是可修改的，当使用 raw.buffer 分配的指针作为参数时，该参数在 API 函数参数中应当声明为`pointer`类型而不应当声明为`pointer&`类型，因为 buffer 用收接收指针指向的数据而不是接收指针本身。

对于原生 API 的输入参数，API 函数的 poinetr 类型与 string 类型的实参都可以使用 aardio 中的 pointer,string,buffer,null 类型的值。如果使用大写的 STRING 或 POINTER 类型，则不能在实参中使用 null 值。  

## 转换数据类型

可使用 raw.convert 函数转换结构体。

函数原型：

```aardio
raw.convert(inPointerOrStringOrBufferOrStruct,outStruct,offset=0 ) 
```
  
将源数据转换为目标结构体数据，偏移量 @offset 是可选参数,默认为 0。

函数的作用是将参数 @inPointerOrStringOrBufferOrStruct 转换为 @outStruct 类型。  

参数 @inPointerOrStringOrBufferOrStruct 可以是结构体(struct)、pointer、string、buffer 类型的对象。

第二个参数 @outStruct 必须是结构体(struct)。


下面看一个简单的示例：

```aardio
import console; 

var struct = raw.convert({
	int value = -1;
},{
	INT value;
})

console.log( struct.value );
console.pause(true);
```

实际上我们用 `-1 >>> 0` 也可以代替上面的代码。

一般这种原生类型转换多在我们声明 API 或结构体类型的时候就自动完成了。在 aardio 中需要做这些转换的情况较为少见。如果是简单的有符号转无符号，用 `>>> 0` 就可以实现。参考：[无符号右移](../../../language-reference/operator/bitwise.md#unsigned-right-shift")