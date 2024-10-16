# 分行迭代读取文件

io.lines(pathOrFile = io.stdin )  
  
io.lines 自动打开通过 @pathOrFile 参数指定路径的文件。  
@pathOrFile 参数也可以是使用 io.file 打开的文件对象，省略 @pathOrFile 参数则使用默认值 io.stdin 。

如果指定文件路径，io.lines 使用文本模式打开文件，文本模式 `'\0'`,`'\x1A'` 为终止符。如果需要读取 `'\x1A'`  或者 `'\0'`，请调用 `io.files(path,"rb")` 以二进制模式打开文件对象，然后就文件对象指定为 io.lines 的第一个参数 @pathOrFile。

io.lines 创建一个[迭代器](../../../language-reference/statements/looping.md#for-in)， 支持在[泛型for](../../../language-reference/statements/looping.md#for-in) 循环中逐行读取文件，在读取完毕以后自动关闭文件对象。使用 io.lines 可以避免一次性读取太大的文件。  

```aardio
import console;

for line in io.lines("d:\test.txt") { //io.lines()返回的迭代器函数每次读取文件中的一行 
    console.log(line);
}
```  

使用 file.read 函数可以实现类似的功能：

  
```aardio
import console;

var file = io.file("d:\test.txt")
 
while( var line = file.read() ) {
	console.log(line);
}

file.close();
```  

