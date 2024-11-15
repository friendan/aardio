# 定义函数

## 函数

函数是预定义子程序，封装一段可复用的代码，接受零个或多个参数，计算并返回零个或多个值。  

函数体包含一组语句、以执行预定义的程序指令，实现程序员定义的算法，并返回计算结果。 

函数的作用类似操作符，接受操作数作为参数，应用算法，执行指令，并返回结果，与操作符不同的是参数的数目不限，且返回值的数目不限。并且函数可以有自定义的名字。

## 定义函数

定义函数的基本语法：


```aardio
function name(parameter1, parameter2, parameter3,...) { 
  //函数内部代码 

  //返回一个或多个值
  return result1,result2;
}
```

- 函数可以指定零个或多个参数，例如上面的 `parameter1` 到 `parameterN` 称为`函数形参`,`函数形参`实际上是函数内部作用域的一种局部变量。
- 函数形参的最后可以使用 `...` 接受不定个数的参数，在定义了不定参数的函数内部 `...` 可以作为返回多个值的表达式使用，可以用 `{...}` 将不定个数的参数转换为普通数组。
- 函数可以选用 return 语句返回一个或多个值，例如上面的  `result1` 到 `resultN`，如果不返回任何值或者不调用 return 语句函数会默认返回 null 值。return 语句之后直到函数结束的代码将视为注释注略不执行，

函数定义可以不指定名字 - 即匿名函数　。匿名函数可以赋值给其他的变量或常量，例如：

```aardio
func = function() { 

}
```

后面一种写法在 aardio　中更为常见，在类或表构造器中只能写"匿名函数"，例如：

```aardio
class cls {
  func = function() { 

  }
}
```

下面的代码则存在语法错误：

```aardio
class cls {

  //在类或表构造器中如下写"具名函数"是错误的
  function func() { 

  }
}
```

注意：匿名函数是一个表达式，而具名函数是一个语句，在 aardio 中语句不能作为表达式使用，表达式也不可作为语句使用。

参考： [语句与表达式的区别](../basic-syntax.md#stat-vs-exp)

## 定义局部函数

函数也可以定义为局部变量。局部函数像局部变量一样作用域限于当前语句块。

用具名函数定义局部函数的基本语法：

```aardio
var function func() { 

}
```

用匿名函数赋值到局部变量以定义局部函数的语法：

```aardio
var func = function() { 

}
```

在 aardio 中第二种写法更为常见，第一种写法较少使用。 

## 局部函数的递归问题

如果使用 var 语句中将"匿名函数"定义为局部变量，那么
当局部函数递归调用自身时，"匿名函数"本身并不认识在它的定义之后才创建的局部变量，会导致出现找不到函数的错误。

例如：

```aardio
var func = function ( i ){ 
	if (  i <= 0   ) return  i 
	else return func(  i-1 )  //报错找不到 fun 函数  
}

//调用递归函数
var n = func( 5 )
```  
  
解决办法是先声明局部变量再赋值，如下：  
  
```aardio
var func;
func = function ( i ){ 
	if (  i <= 0   ) return  i 
	else return func(  i-1 )  //报错找不到 fun 函数  
}

//调用递归函数
var n = func( 5 )
```  

等价的写法是直接用 var 语句定义"具名函数"，如下：

```aardio
var function func( i ){ 
	if (  i <= 0   ) return  i 
	else return func(  i-1 )  //报错找不到 fun 函数  
}

//调用递归函数
var n = func( 5 )
``` 

## 调用函数  <a id="call" href="#call">&#x23;</a>

```aardio
result1,result2 = func(arg1,arg2,arg3)
```

- 在函数对象后添加调用操作符 `()` 写为 `func()` 格式表示调用函数。

  说明：
  * 调用[类构造函数](../class/class.md#new)、调用 [lambda 函数](lambda.md) 的语法与调用普通函数完全一样。
  * 调用操作符 `()`  不允许直接写在函数定义或字面量后面，也不能直接写在类或 lambda 定义后面。如果要立即调用匿名函数或 lambda 表达式则必须将其置于一对括号内，例如 `( function(){} )()`。
- 在调用函数时可以指定零个或多个调用实参，例如上面的  `arg1` 到 `argN`。调用实参的数目如果多于形参的数目，多余部分被丢弃。  调用实参的数目如果少于形参的个数，不足的部分添加 null 值。 
- 函数可以返回零个或多个值，例如上面的，例如上面的  `result1` 到 `resultN`。
- 调用函数的代码是一个语句，但函数的返回值是右值表达式。

可以丢弃返回值，使用单独的函数调用构成独立语句，如下：

```aardio
functionName(arg1,arg2,arg3)
```

可以省略部分返回值，如下：

```aardio
result1, , ,result4,result5 = functionName(arg1,arg2,arg3)
```

可以省略部分参数，如下：

```aardio
result1 = functionName(arg1, ,arg3,,arg5)
```

调用函数时，不管有没有参数，都要在函数名后面放一对圆括号，如下是错误的写法;

`io.open;` ![](../../icon/error.gif)

在 aardio 中函数必须先定义后使用。

aardio 在运行时创建函数对象，代码执行顺序决定了函数定义的顺序。在 aardio 中不能调用尚未定义的函数对象。

## 函数参数
 
形参 ( parameter ) 指函数定义参数列表中预定义的形式参数，形参可以在函数体内部作为局部变量使用。  

示例：

```aardio
//这里的a,b,c称为形参，可以将形参看成函数内部的局部变量名字  
function test(a,b,c){ 
    return a+b+c; //形参可以在函数体内部作为局部变量使用 
} 
```

实参（ argument）指调用时括号中指定的实际调用参数。

示例：

```aardio
print(1,2,3); //这里的 1,2,3,4 称为调用实参 
```

更多关于函数参数的使用技巧请参考：[函数参数用法](parameter.md)  
  
## 函数局部变量  <a id="var" href="#var">&#x23;</a>

在函数体中可以用 var 语句定义局部变量，函数的形参也可以作为局部变量使用。  

函数中的局部变量与外部变量命名相同时，在各自的作用域内生效，并不冲突。  
  
例如：  
  
  
```aardio
import console; 

str = "我是外部变量"

//定义函数
function func() {
	var str = "我是局部变量" 
	console.log( str , ..str ) //显示变量值
}

//调用函数
func();

//显示全局变量值
console.log(str);

console.pause();
```  

可以用 `..str` 访问全局变量 str，使用  `self.str` 访问当前名字空间的变量 str 。不加任何前缀时则优先获取最近的同名局部变量。

注意 aardio 中的局部变量拥有块级作用域，aardio 根据标志符查找命名对象的顺序依次为：  

*   当前语句块局部变量。
*   向上搜索上层语句块或外部函数的局部变量( upvar )。
*   当前名字空间( self )成员变量。

根据最少知道原则，在函数中应尽量避免使用全局对象，尤其要避免修改全局对象。而且局部变量存取速度更快。无论是为了效率，还是降低程序复杂度，都应当优先使用局部变量。  
  
更多关于局部变量的内容请参考：

- [局部变量](../variables-and-constants.md#var) 
- [定义局部变量](../statements/assignment.md#var)  

## 成员函数

1.  定义成员函数  

    定义成员函数原型：

    ```aardio
    var tab = {};

    tab.method = function( param1,param2,param3 ) {
      //函数内部内码
    }
    ```  

    也可以使用下面的格式定义成员函数：

    ```aardio
    var tab = {};

    function tab.method( param1,param2,param3  ) {
      //函数内部内码
    }
    ```  

2.  调用成员函数格式

    ```aardio
    tab.method( arg1,arg2,arg3 );
    ``` 

    调用成员函数时可选指定任意个参数，例如上面的 `arg1` 到 `argN` 。

3. 成员函数的 owner 对象  

    aardio 中所有函数都有一个隐藏的 owner 参数，可以认为是第 1 个调用参数前面隐藏的第 0 个参数。

    owner 参数不用写在调用参数列表里，由 aardio 自动传递并接收 owner 参数。

    owner 指的是在调用成员函数时拥有该成员函数的所有者。
    
    例如执行 `object1.method()` 时，object1.method 函数接收到的 owner 参数就指向 object1 。  

    如果我们先写 `object2.method = object1.method()` ，然后再调用  `object2.method()` 时，object2.method 函数接收到的 owner 参数就指向 object2 。

    onwer 参数可能指向不同的对象。

    在调用一个类构造实例对象时，如果实例对象的成员函数不改变所有者，则调用实例对象的成员函数时，owner 默认指向类的实例对象 - 也就是类主体内的 this 对象。区别在于 this 无法在外部改变，而 owner 可以在外部改变的。

    请参考：
    - [owner 对象](owner.md)
    - [this 对象](../class/class.md#this)