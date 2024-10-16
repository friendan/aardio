# 读写文件

一次性读写文件内容应优先选用 string.load string.save 而不是使用 io.file 创建文件对象。  
  
参考：[io.file 文件对象](../io/file.md) [检测文件路径](../io/path.md#exist)

## 读文件

`string.load(path,resType="RES",dllHandle = null )`

string.load 有三个参数，第一个参数 @path 为文件路径。  
文件路径可以是普通磁盘文件的路径，支持内嵌资源路径。

如果在磁盘上找不到文件，string.load会从资源加载文件。  
读取资源文件时，默认的资源类型为 RES ，也可以通过函数的第二个参数 @resType 指定资源类型。

资源名字、以及资源类型也可以是一个数值的资源 ID.  

函数的第三个参数 @dllHandle 指定查找资源文件的执行文件内存模块的句柄(pointer 指针类型)，不指定时默认为当前 EXE 模块。  使用 [raw.loadDll](../raw/api.md#loadDll) 可以加载dll 对象，dll对象提供 gethandle() 函数返回 dll 模块句柄。  

## 写文件

`string.save(path,str,append=false)`

string.save 函数将字符串参数 @str 保存到参数 @path 指定的磁盘文件，如果增加 @append 参数并且值为 true 则追加到文件尾。