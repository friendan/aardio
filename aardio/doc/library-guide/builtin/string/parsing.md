# 文本解析

## 一、分行遍历匹配结果

函数原型：

```aardio
string.each(str,pattern,lineDelimiter)
```

与 [string.match](matching.md#match) 等模式匹配函数不同，string.each 会将文本按行拆分，然后返回一个迭代器，用于在 [for in](../../../language-reference/statements/iterator.md) 语句中循环且逐行匹配字符串并且循环返回结果。

- 参数 str 指定要处理的字符串。
- 参数 pattern 指定模式匹配串，查找模式串中可用圆括号创建捕获分组自定义迭代器返回值个数，如果不指定捕获组则迭代器直接返回找到的字符串。

示例：

```aardio
import console; 

var str = /*
属性名1: 属性值1
属性名2: 属性值2
属性名3: 属性值3
*/

for k,v in string.each(str,"(.+?)\s*\:\s*(.*)") { 
	console.log(k,v)
} 
console.pause();
```

## 二、分行拆分文本 <a id="lines" href="#lines">&#x23;</a>


我们遇到的很多需要解析的文本都以是行为单位的。

最常见的例如 CSV 格式，CSV 格式可以用 aardio 标准库中的 [string.database](../../../library-reference/string/database.md) 解析。

但是我们还会遇到很多其他格式的分行文本，这时候我们可以使用 string.lines 函数进行解析。

函数原型：

```aardio
string.lines(str,lineDelimiter,columnSeparator,maxColumns)
```

说明：

string.lines 用于创建一个迭代器，用于 [for in](../../../language-reference/statements/iterator.md) 语句中循环按行拆分字符串并返回拆分结果。

- 参数 str 指定要解析的字符串。  
- 参数 lineDelimiter 用于指定换行标记，支持模式匹配语法。  
- 参数 columnSeparator 用于指定列分隔符，支持模式匹配。如果指定了列分隔符则每次迭代返回的都是数组，否则返回的是字符串。
- 参数 maxColumns 用于限定拆分的最大列数，注意这个参数仅在指定 columnSeparator 参数时有效。

string.lines 实际上相当于调用并增强了 [splitEx](part.md#splitEx) 的功能，参数用法与 splitEx 是一致的，例如在分隔符中同样支持捕获组并作如下处理：

- 模式串尾部有 $ 符号，则捕获组放到上个拆分结果尾部。
- 模式串头部有 ^ 符号，则捕获组放到下个拆分结果头部。
- 模式串头部有 ^ 符号并且尾部有 $ 符号，则捕获组作为单独的拆分结果添加到返回数组中。这个特性被用于文本分句的 string.sentences 库。

下面看一个简单的调用示例：

```aardio
import console; 

var str = /*
abc,def,xyz
abc2,def2,xyz2
abc3,def3,xyz3
*/

for( line in string.lines(str,,"[\s,;=]") ){ 
	console.log(line[1],line[2],line[3])
} 
console.pause();
```

以上代码用于循环遍历每一行用空格键、制表符(tab)、逗号、分号或等号拆分出来的字符串数组。

我们可以将迭代器直接传入 table.array 以快速转换为数组，例如：

```aardio
var str  = /*
abc,def,efg
123,456,789
*/

//转换为数组
var array = table.array( , string.lines(str,,",") )
```

如果迭代器传入 table.array 的第 2 个参数，则取迭代器的首个循环返回值作为数组元素。 

## 三、解析字符串属性表 <a id="talbe" href="#talbe">&#x23;</a>


字符串属性表是一种很常见的文本格式。

示例：

```txt
属性名1: 属性值1
属性名2: 属性值2
属性名3: 属性值3
```

格式说明：

- 每行为一个单位，属性值不能跨行，引号等仅作为字面值解析。
- 名值对之间用 `:` 或 `=` 分隔，忽略分隔等前后的空白字符。
- 某些程序里允许在行首用 `#` 标明一个需要被忽略的注释。 

aardio 提供了 string.table 用于快速解析这样的文本并返回一个表对象。

示例：

```aardio
import console; 

var str = "
属性名1: 属性值1
属性名2: 属性值2
属性名3: 属性值3
"

//解析为表对象
var propTable = string.table(str);

//输出结果
console.dump(propTable);

console.pause();
```

string.table 的函数原型为：

```aardio
string.table(str,nameValueSeparator,lineDelimiter,commentChar) 
```

除了第一个参数，其他参数都是可选的。  
参数 nameValueSeparator 用于指定键值分隔符，已默认指定为 `\s*[\:=]\s*` 。  
参数 lineDelimiter 用于指定识别行分隔符的模式串，已默认指定为 `<\r*\n>|\r` 。  
参数 commentChar 指定行首注释符，这个参数仅支持字节码。默认未指定。如果指定为 `'#'#` 表示以 `#` 置于行首时则忽略该行。

string.table 仅支持以行为单位的字符串属性表。而标准库 string.list 则允许在属性值中用引号包含跨行的引用段，以及更多其他特性。

参考：

- [string.list 库参考](../../../library-reference/string/list.md)

- [string.list 范例](../../../example/Text/list.aardio)

## 四、解析更多文本格式

aardio 解析文本非常方便，标准库提供了很多解析各种格式的库，代码量都很少。

- [web.json 库参考](../../../library-reference/web/json.md) JSON 格式。

- [string.database 库参考](../../../library-reference/string/database.md) CSV 格式。

- [string.xml 库参考](../../../library-reference/string/xml.md)  XML 格式。

- [string.html 库参考](../../../library-reference/string/html.md) HTML 格式。

- L[string.list 库参考](../../../library-reference/string/list.md) LIST 格式。

更多其他格式请查看相关库参考与范例。

