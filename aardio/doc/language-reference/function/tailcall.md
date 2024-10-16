# 尾调用优化

请看下面的例子：

```aardio
function tailCaller (x){ 
     return tailCallee(x) //调用另外一个函数以后不再做任何事称为尾调用
}
```  

如果一个函数（tailCaller）在调用另外一个函数(tailCallee)以后不再做任何事称为尾调用。被调用函数(tailCallee)结束后不再需要返回原来的函数（tailCaller），所以不需要额外的栈保留调用函数（tailCaller）的数据。

正确的尾调用：

*   尾调用必须是在最后一个 return 语句中
*   return 语句后面只能有一个独立的函数调用语句，不能调函数调用作为其他表达式的一部分，例如 `return g(x) + 1` 不是尾调用。
*   调用参数中可以包含其他表达式。

递归调用函数是很浪费资源的，但是如果使用尾调用就不再需要大量的压栈，无论递归多少次都不会导致栈溢出。

下面是一个递归尾调用的示例：
  
```aardio
import console;
	
//递归函数
var function recursion( count ){
	
	if( count <= 0 ) return count; 
	else {
		// 这是一个的尾调用
		return recursion(  count-1 ); 
	}
}

//调用递归函数 
console.log( recursion( 99999  )  )
console.pause()
```  

如果我们把 `return recursion(a-1)` 改成 `return recursion(a-1)+1` 就不再是尾调用了，这会导致内存不断地增加直到栈溢出，然后报错无法继续运行。