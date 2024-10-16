# 读写结构体

file 对象支持读写结构体( struct )，请参考:[io 函数](file.md) [原生数据类型](../raw/datatype.md)

## 读写结构体

[file.write](file.md#write) 或 [file.read](file.md#read) 都可以指定任意多个参数，按顺序在文件流中写入或读取数据。而这两个函数都支持结构体( struct )。

使用结构体可以非常方便地从文件中读写二进制数据。

**示例代码：**  

  
```aardio
import console;
 
//自定义一个结构体
var testStruct ={
    int a = 134;
    BYTE b[] ="我是配置文件";
}

//创建一个文件对象
var file = io.file("/bin.bin","w+");
 
//写入结构体
file.write('下面是一个结构体\r\n',testStruct); //可以写入任意多个参数
//从缓冲区写到文件
file.flush();

//移动读写指针到文件开始
file.seek("set");
//再读取结构体
var desc,testStruct = file.read("%s"/*%s表示读取一行*/,testStruct);
 
//关闭文件
file.close();

console.print( desc ); 
console.dumpTable( testStruct );
console.pause();
```