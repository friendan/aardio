# try catch 容错语句

相关链接：

- [语句块](blocks.md) 
- [容错调用函数：call](../builtin-function/call.md)  

实际上在 aardio 中 try 语句使用不多。

aardio 并不提倡大量的抛出或处理异常，也较少需要使用 try 语句。

aardio 函数通常会利用多返回值检测并处理错误，大多数执行成功会返回非 null 值的函数在执行失败时会返回 `null, 错误信息或错误代码`, 也就是说检测到第一个返回值为 null 就可以从第二个返回值获取到错误原因。这种方式编码与处理错误相对来说比较简单并易于维护。

try 语句尝试执行一个语句块，遇到错误则退出 try 语句块而不是中断 aardio 程序。  如果使用了 catch 语句块就可以在执行代码抛出异常时时捕获错误( catch 语句是可选的 )。
  
示例如下：  

```aardio
import console;

try{
	b="aaaaaaaaaaaa" *2
	console.log("错误会中断try语句块")
}
catch(e){ //catch部分可以省略
	console.log( "错误信息：",e )
	//在这里可以调用debug库
	//在栈释放以前调用错误处理 
	//所以可以调用debug库中的函数收集错误相关的信息
}

console.log("错误不会中断程序")
console.pause();
```  

错误信息不一定要是一个字符串,传递给 error 的任何信息都会被catch 捕获。

示例：

```aardio
try{
    error( {a=2;b=3} ) //error显式抛出一个异常
    console.log("错误会中断try语句块")
}
catch(e){ //catch部分可以省略
    console.log( "错误信息：",e.a,e.b) 
}
```  

容错语句是允许多重嵌套的，一个容错语句允许包含另一个容错语句。为了清晰地表示嵌套的层次，建议根据嵌套的层次使用 tab 制表符缩进代码。  

try catch 语句需要遵守以下规则：

1. 在 aardio 中 `try catch` 的行为更像一个立即执行的匿名函数。

	- 在 `try ... catch` 语句内部使用 `return` 语句将会中断并退出 `try ... catch` 语句自身（并非退出包含 `try ... catch` 语句的函数）。
	- 不能在 `try ... catch` 语句内部对包含 `try ... catch` 语句的外部循环使用 `break` 或 `continue` 语句 。  
	- try catch 语句块内可以使用语句外部的 owner 参数，但是不能使用语句外部的  `...` 参数。可以提前使用 `var args = {...}` 将不定参数转换为数组，在 try catch 语句块内用 `table.unpackArgs( args )` 函数展开。  

3. 禁止在 catch 语句中再次调用 error 语句，  
如果需要在抛出异常前插入一些代码，在执行这些插入的代码以后继续抛出异常，那么更好的选择在 global.onError 事件中添加代码。  
层。

