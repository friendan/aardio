# 操作符重载

在 aardio 里对于一个可以指定元表的对象（主要指 table 对象），可以重载操作符使操作数执行自定义的运算函数。

## 使用元方法重载操作符

对象都可以指定一个[元表(metatable)](../datatype/table/meta.md)，在元表中可以重载运算符。  

重载的操作符实际上是一个函数对象，我们称之为元方法。

以 `@` 操作符表示对象的元表。例如 `tab@` 表示tab的元表。  
也可以在表构造器中直接用 `@` 操作符指定元表，例如：`var tab = { n=123;n2=456;@{ _type = "自定义元表"} }`

table 的元表可以是 table 自已。例: `tab@ = tab;` 

下面是使用元表重载运算符的示例：  
  
```aardio
import console;
var tab = { x=10 ; y=20 };
var tab2 = { x=12 ; y=22 }

//错误，table 默认是不能相加的
//var c = tab + tab2; 

//添加 _add 元方法重载加运算符。
tab@ = {
	_add = function(b) { 
		return owner.x + b.x
	};
}

//调用重载的加运算符
var c = tab + tab2;

//显示22
console.log( c );

console.pause(); 
```  

请参考：[元属性/元方法 列表](../../language-reference/datatype/table/meta.md#meta-methods)

一个常见的技巧:

table 默认是按引用比较的，即使它们的值相同，但只要不是指向同一个对象都被认为是不相等。 
我们通过重载 `==` 运算符可以让两个 table 对象按它们的存储值比较是否相等。

示例：

```aardio
import console;

var tab = { x=10 ; y=20 };
var tab2 = { x=10 ; y=20 }

//默认是按引用比较，结果为 false
console.log( tab == tab2 ); 

//创建一个元表。
tab@ = {
	//重载 "==" 运算符
	_eq = function( b){ 
		return ( (owner.x == b.x) and (owner.y == b.y) )
	};
}

// "==" 运算符要求操作数使用相同的 _eq 元方法（元表可以不同）。 
tab2@ = tab@;

//调用重载的 "==" 运算符，结果为 true 
console.log( tab==tab2 ); 

console.pause();
```  

## 避免元方法递归调用导致溢出

我们先看一个错误的示例：

```aardio
import console;

var dic = {

	//创建元表
	@{ 
		_tostring = function() {
			//递归调用 _tostring 元方法导致堆栈溢出。
			console.log( owner ); 
			return "aaa";
		}
	} 

}

//自动调用 tostring(参数)
console.log( dic );  
```  

分析一下上面的代码：

- console.log 会自动调用 tostring 函数将参数转换为字符串。
所以 `console.log( dic )` 自动变成了 `console.log( tostring(dic) )  ` 。
- tostring 会触发 `_tostring` 元方法。
- 在 `_tostring` 元方法里我们又调用了 `console.log( owner )` 。然后又会递归调用 `tostring(owner)` 将自己转换为字符串。问题就来了，owner 就是它自已，`tostring(owner)` 又会调用它自己的  `_tostring` 元方法，而元方法又会再次调用　`tostring(owner)` ， 就这样没完没了的递归，所以导致调用堆栈溢出然后报错了。  

类似的错误还有：
  
如果我们在 `_get` 元方法  的内部写 `owner["key"] ` 。
那么就会重复调用 `_get`  元方法，而 `_get` 元方法又会再次递归调用 `owner["key"] ` 也是这样没完没了，然后致调用堆栈溢出报错。  

避免这个问题的方法是在 `_get` 元方法或 `_set` 元方法中使用不会触发元方法的直接下标操作符 `[[]]`，将单层中括号的"下标操作符"改为使用双层中括号的"直接下标操作符"。也就是说，在 `_get` 元方法里写 `owner[["key"]] ` ， 就可以避免出现上述的递归调用错误。

参考： [直接下标](member-access.md#raw-subscript)