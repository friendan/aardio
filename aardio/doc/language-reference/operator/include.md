# 包含操作符



| 运算符 | 说明 |
| --- | --- |
| `$` | 包含操作符 |

包含操作符 `$` 可以将外部文件在编译期嵌入到代码中以创建一个字符串对象。

示例：

```aardio
import console; 
console.log ( $"/my.txt" ) //my.txt 文件内容
```  
  
在程序发布后，程序即可脱离源文件运行, 因为该文件已经被编译为一个普通字符串对象并内嵌到程序中了。  
  
如果 `$` 包含的文件路径以`~/`或`~\`开始，并且查找文件失败， aardio 会移除路径前面的`~`，转换为单个`\`或`/`开头的应用程序根目录路径继续查找。  

> 应用程序根目录在开发时指工程根目录（工程之外独立运行的 aardio 文件则指启动 aardio 文件所在目录），在发布后则指启动 EXE 所在目录。  
  
反之，如果包含的文件以单个`\`或`/`开始，并且查找包含文件失败，aardio 不会在路径前面添加`~`到EXE目录下查找（EXE目录在开发时指 aardio 开发环境所在目录）。  
  
默认如果找不到包含文件会报错，但是如果被包含的文件路径前面添加一个问号, 找不到文件时则不会报错而是返回 null，示例：  
  
```aardio
import console; 
console.log ( $"?不存在的路径" ) //不报错而是返回 null
```  
  
需要注意的是:

1.  包含操作符是在编译后、运行以前生效。 
2.  被包含的文件程序发布后已内嵌到生成的 EXE 文件中,因此没有必要再将被包含的文件放入内嵌资源目录（ 这样会导致同一个文件被包含两次 ）。
3.  包含操作符嵌入的是原始二进制文件，不会对被包含的文件数据进行任何改变。即使你包含的是 aardio 源码文件，aardio 不会编译该文件。所以一般不应该将 `$` 操作符用于包含 aardio 源码文件。相反，如果通过内嵌资源目录包含 aardio 源码文件，发布 EXE 时则会自动编译该文件。