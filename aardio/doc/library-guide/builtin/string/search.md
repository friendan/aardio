# 查找字符串

下面介绍不使用模式匹配语法的字符串查找函数。

参考：[模式匹配函数](matching.md)

### 一、禁用模式匹配搜索文本

`string.indexOf(str,substr [ , startPos [ , endPos ] ])  `
  
查找第二个字符串参数 @substr 位于第一个字符串参数 @str 的位置，返回值按字节计数。 

此函数执行纯文本搜索，字符串如果包含 `'\0'` 则仅取`'\0'` 之前的文本。如果要搜索二进制数据，可以使用功能类似的 raw.indexOf 函数，

可选用第三个参数 @startPos 指定开始查找的位置，默认为 1。

可选用第四个参数 @endPos 指定结束查找的位置，默认为字符串长度。
  
```aardio
import console;

console.log( string.indexAny("abcdefg","cde") ) //显示3
console.log( string.indexAny("abcdefg",'c'# ) ) //显示3

console.pause(); 
```  

### 二、禁用模式匹配反向查找字符串

`string.lastIndexOf(str,substr [ , bytes]) ` 
  
自后向前查找第二个字符串参数 @substr 位于第一个字符串参数 @str 的位置，返回值按字节计数。此函数执行二进制搜索，字符串可包含  `'\0'` 。

可选用第三个参数 @bytes 指定要搜索的字节数，如果为正数则从左侧向右侧（尾部）按字节计数，如果为负数则自尾部反向按字节计数。

此函数反向逐个字节查找字符串，效率较低。

示例：
  
```aardio
import console;
console.log( string.lastIndexAny("abcdefg","cde") ) //显示5
console.pause(); 
```  

### 三、查找任意单字节字符

`string.indexAny(str,bytes | bytecode [ , pos])  `
  
查找第二个字符串参数 @bytes 中的任意一个单字节字符位于第一个字符串参数 @str 的位置。也可以在第二个参数指定一个字节码。第二个参数可包含  `'\0'` 或指定要搜索的字节码为 0。

可选用第三个参数 @pos 指定开始查找的位置，默认为 1。

返回值按字节计数。
  
```aardio
import console;

console.log( string.indexAny("abcdefg","cde") ) //显示3
console.log( string.indexAny("abcdefg",'c'# ) ) //显示3

console.pause(); 
```  

### 四、反向查找任意单字节字符

`string.lastIndexAny(str,bytes | bytecode [ , pos]) ` 
  
自后向前查找第二个字符串参数 @bytes 中的任意一个单字节字符位于第一个字符串参数 @str 的位置。也可以在第二个参数指定一个字节码。第二个参数可包含  `'\0'` 或指定要搜索的字节码为 0。

可选用第三个参数 @pos 指定开始查找的位置，默认为 1。

返回值按字节计数。 

示例：
  
```aardio
import console;
console.log( string.lastIndexAny("abcdefg","cde") ) //显示5
console.pause(); 
```  

### 五、检测是否以指定字符串开始

`string.startWith(str,substr,是否忽略大小写=false)  `
  
判断第二个字符串参数 @substr是否位于第一个字符串参数 @str 开始处。参数三为可选参数(默认为false)

示例：

```aardio
import console;
console.log( string.startWith("abcdefg","abc") ) //显示true
console.log( string.startWith("abcdefg","efg") ) //显示false
console.pause(); 
```  

### 六、检测是否以指定字符串结束

`string.endWith(str,substr,是否忽略大小写=false)  `
  
判断第二个字符串参数 @substr 是否位于第一个字符串参数 @str 结束处。可选参数三指定是否忽略大小写( 默认值为false )。

示例：
  
```aardio
import console;
console.log( string.endWith("abcdefg","abc") ) //显示false
console.log( string.endWith("abcdefg","efg") ) //显示true
console.pause(); 
```