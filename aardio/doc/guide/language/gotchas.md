# aardio 常见陷阱

每一个编程语言都无法避免地存在各种各样的陷阱，
如果我们事先了解它们就可以善用这些语法特性并且避免问题。

## ▶ 多返回值与不定参数 <a id="multiple-values" href="#multiple-values">&#x23;</a>


在函数实参尾部调用有多个返回值的函数时，会增加多个调用参数。

示例：

```aardio
import console;

var tab = {}

table.push( tab,tonumber("1") );
table.push( tab,tonumber("123") );

console.log("你觉得tab应当有两个成员吗,下面我们看看 tab 里面是什么:")

// tab 里面实际有四个元素,超出了我们的预期,这是怎么回事?
console.varDump( tab )
```

aardio 支持多个返回值，也支持不定参数,
当这些好用的功能在你没有准备的时候碰到一起，就制造了一个可能的陷阱。

`tonumber()` 转换字符串为数值，成功则返回两个值，一个是转换后的数值, 一个是该数值在字符串中的字节长度。例如 `tonumber("123")` 返回 `123,3` 。

而 table.push() 函数接受不定个数的参数，它会将所有参数添加到数组的尾部。

看: `table.push( tab,tonumber("123") );`  
在执行时就变成了这样： `table.push( tab,123,3 );`

那么如何解决这个问题呢?  
很简单, 向下面这样加一对圆括号就可以：

`table.push( tab,( tonumber("123") ) ); ` 

圆括号建立的单值表达式只会返回一个值。

参考：[table.push](../../library-guide/builtin/table/_.md#push)

## ▶ `return` 语句后面被忽略的代码 <a id="return" href="#return">&#x23;</a>


在 aardio 中，
return 语句后面的代码会被解释为注释语句。

例如：

```aardio
import console; 

console.log(
    function(){
        return (123) )))))
    }
)
console.pause();
```

上面的代码看起来似乎存在语句错误，但实际上是正确的。虽然这不会出什么问题，但应当避免这样写代码。

参考：[return 语句](../../language-reference/function/result.md)

## ▶ 数组 <a id="array" href="#array">&#x23;</a>

aardio 数组的起始索引为 1 而不是 0，这一点要特别注意。

aardio 数组非常灵活，可以包含任意类型的数据，也可以嵌套，甚至可以包含非数组成员。

在 aardio 中哈希表与数组都是表（ table ）, 表可以包含这两种类型的成员。

基本规则：

- 在 aardio 中数组默认指的是有序数组，有序数组的索引自 1 开始并且连续不断。
- 数组不应包含 null 值 。

aardio 中的数组操作函数，取数组长度的 `#` 操作符都只能用于有序数组。如果有序数组中包含 null 值，仍然作为有序数组操作则 aardio 并不保证数组的有效范围包含或不包含 null 值。

正确的方法是避免将类似 `{1,null,null,null,null,5,6}` 这样的稀疏数组作为有序数组进行操作，例如应当使用 table.range 函数获取稀疏数组的索引范围而不是使用  `#` 操作符去获取有序数组长度。

参考：

- [稀疏数组](../../language-reference/datatype/table/_.md#sparse-array)
- [范例 - 含 null 数组](../../example/aardio/Array/sparse-array.html)

## ▶ 字符串连接与数值加运算 <a id="concat" href="#concat">&#x23;</a>


数值加运算符为  `+`  
字符串连接操作符为 `++`  

算术加与字符串连接是完全不同的操作，应当明确区分。

当 `+` 运算符的两个操作数都是字符串，且任一操作数无法转换为数值时则转换为字符串连接。不应依赖此规则做字符串连接，以避免误操作与不必要的转换。

引号（双引号、单引号、反引号）前后的 `+` 运算符将自动转换为字符串连接运算符 `++`。例如 ` str + "" ` 等价于  ` str ++ "" ` 。这种写法不会有歧义，在 aardio 中也很常见。

但不能因为经常看到  ` str + "" ` 这样的代码，就认为使用 `str1 + str2 ` 适合用于连接字符串。

实际上，如果  `str1 + str2 ` 的两个操作符都是字符串，且任一字符串不能转换为数值，就会转换为字符串连接。这会让我们更容易误以为  `str1 + str2 ` 的写法是正确的，直到有一天其中一个操作数可以转换为数值，bug 就来了。

举例：

```aardio
var str = ""

var str2 = 2;


/*
两个字符串相加，如果其中一个字符串可以转换为数值，
则执行算术加运算而非连接操作。

因为 str 之前存储的空字符串能自动转换为数值 0，
所以下面的 str 在与 str2 自动做算术加运算以后变成了数值 2。
*/
str += str2;

var str3 = "abc"

//报错，字符串 "abc" 不能与数值相加。
str += str3;
```

参考：[自动类型转换](../../language-reference/datatype/datatype.md#type-coercion) [+ 运算符](../../language-reference/operator/arithmetic.md#add)

正确写法是明确地用 `++` 连接字符串：

```aardio 
var str = "";
var str2 = 2;
var str3 = "abc";

str ++= str2;
str ++= str3
```

参考： [++ 操作符](../../language-reference/operator/concat.md)

## ▶ 等式判断与逻辑值转换 <a id="eq" href="#eq">&#x23;</a>


aardio 的等式判断与逻辑值转换规则是比较容易掌握的。

最主要的规则：

- 任意值与 true,false 比较则先转换为布尔值，非 0. 非 null、非 false 为 true，反之为 false。 
- 非布尔值与数值比较，则先转换为数值，然后比较数值是否相等。  

### 1. 逻辑值比较

根据前述原则： 

` false == 0 ` 的结果为 true　。  
` true == "" `的结果也为 true　。  

因为以上等式中有一个操作数是布尔值，所以全部操作数都会转换为逻辑值以后再比较。

### 2. 数值比较

当我们将 ` 0 == "" ` 比较时结果也是 true。

这是因为当操作数中没有布尔值且存在数值时，会转换为数值进行比较。`""` 转换为数值则为 `0`，所以与 0 是相等的。

**当等式或不等式的操作数中只有数值而没有出现布尔值，就不应当错误地根据布尔值转换规则去推导结果。**


## ▶ `try catch` 只能用 `return` 语句退出自身 <a id="try" href="#try">&#x23;</a>


参考：[try catch](../../language-reference/statements/try.md)

在 aardio 中 `try catch` 的行为更像一个立即执行的匿名函数。

在  `try catch` 内部的  `return` 语句只会中断并退出 `try catch` 自身，而不会退出包含  `try catch` 的函数。

而且也只能用 `return` 中断并退出 `try catch` 语句，不能对包含  `try catch` 的外部循环使用 `break` 或 `continue` 语句。

如果需要在退出 try catch 语句以后退出函数，
那么需要在 try catch 语句中使用一个额外的错误标记，然后在 try catch 语句结束后检查该标记并退出函数。

示例：

```aardio
var func = function(){

	var err;
	try {
		error("出错了")
		return 123;
	}
	catch( e ){
		err = e;
	}
	
	if( err ){
		return null,err;
	}
	
	return 456;
}
```

这的确带来一点小麻烦，但是如果擅于运用这个特性也会带来好处。

例如：

```aardio
try {

	if( 条件1 ){
		return;
	}
	
	if( 条件2 ){
		return;
	}
	
	if( 条件3 ){
		return;
	}  
	
}  
```

任何特性用不好就是陷阱，用好了也就不是陷阱了。


## ▶ 隐蔽的 _WM_QUIT <a id="wm_quit" href="#wm_quit">&#x23;</a>


在窗口程序中，`win.loopMessage()`　负责启动消息循环。

消息循环实际上是一个 `while` 循环，它就象公司的前台，不断的接待各种用户操作请求，然后分发给窗体回调函数。

参考：[win.loopMessage](../../library-guide/std/win/_.md#loopMessage)

在 aardio 中开发窗口程序非常简单，我们不需要显式地指定应用程序主窗体。当所有窗口退出，会自动退出 win.quitMessage() ， 所有事会自动地帮你处理得妥妥当当。
  
但是这又导致了一个新的问题。

我们看下面的代码。

```aardio
import win.ui;
/*DSG{{*/
var winform = ..win.form( scroll=1;bottom=399;parent=...;text="aardio Form";right=599 )
winform.add(  )
/*}}*/

winform.show(); //显示窗体
winform.close() //关闭窗体

/*
所有窗体退出了, 看起来消息循环也不需要了?
win.loopMessage() 看来也可以省略掉了!?
*/
  
//下面我们制造一个程序异常,理论上我们应当看到IDE弹出错误信息
error("出错")
```

怎么回事？
我们并没有看到错误信息 !
也就是说这后面的代码要是出错了，我们将看不到任何提示。

呃，窗口程序的机制可不是想象的那么简单。
`win.loopMessage()` 还做了很多其他的事，例如在所有窗口退出以后，负责打扫卫生 - 清除所有的 _WM_QUIT 退出消息。

解决办法是加上 `win.loopMessage()`。如果你忘记了这件事，那这些到处乱跑的 _WM_QUIT 会“帮助”你关掉你的错误对话框。

正确代码如下：

```aardio
import win.ui;
/*DSG{{*/
var winform = ..win.form( scroll=1;bottom=399;parent=...;text="aardio Form";right=599 )
winform.add(  )
/*}}*/

winform.show();
winform.close();

//窗口程序不能缺少下面这句
win.loopMessage();

error("出错");
```