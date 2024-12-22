# owner 参数

请参考：[定义函数](definitions.md)

## 成员函数的 owner 参数

请参考：[定义成员函数](definitions.md#member)  

owner 参数是 aardio 中一个自动传递的隐藏参数，在形参与实参列表中都不用显式指定。可以认为它是函数的第 0 个参数，位于所有显式指定的参数之前。

如果用成员操作符`.` 获取并调用对象的成员函数，
则点号`.`前面的对象将被自动指定为被调用成员函数的 owner 参数，
否则被调用函数的 owner 参数为 null。

例如使用 `object.method()` 格式调用对象的成员函数时，`object` 自身将隐式传递为 `owner` 参数。

代码示例：

```aardio
var object = {
	property = 123;
	method = function(){
		//使用 owner 可以方便地访问对象自身属性 owner.property，输出 123 
		print( owner.property );
	}; 
}

//调用成员函数
object.method()
```

onwer 参数指向被调用的成员函数名前面的`.`操作符前面的所有对象。**使用下标或其他方式调用成员函数时 owner 参数为 null。**

例如：

- 执行 `object1.method()` 时，object1.method 函数接收到的 owner 参数就指向 `object1` 。
- 如果我们先写 `object2.method = object1.method()` ，然后再调用  `object2.method()` 时，owner 参数就指向 `object2` 。
- 如果我们先写 `var method = object1.method()` ，然后再调用  `method()` 时， owner 参数就是 null 值。
-  调用  `object1["method"]()` 或  `object1[["method"]]()` 时， owner 参数都是 null 值。

请看一个更具体的代码示例：

  
```aardio
import console.int; 

//定义函数
var func = function(){
	console.log( owner.name ,"我被调用了" )
}

//定义不同的集合
var tab = { name = "我是 tab" };
var tab2 = {name = "我是tab2"};
 
//设置函数的所有者
tab.method = func;
tab2.method = func;

//调用成员函数
tab.method(); //显示 "我是 tab 我被调用了" 

//调用成员函数
tab2.method();  //显示 "我是 tab2 我被调用了" 
```  

实际上在 aardio 中需要修改 owner 的情况极为少见。虽然在理论上 owner 是可变的，但通常我们没必要去改变 owner 。

owner 参数的最主要的作用是用于在成员函数中动态获取成员函数的所有者对象，以方便地访问成员函数当前所属对象的其他成员。

在类实例中，owner 参数默认指向 this 对象，请参考：[this 对象](../class/class.md#this)

## aardio 代码文件的 owner 参数

注意一个独立的 aardio 代码文件编译后也相当于一个匿名的函数，代码文件的默认 owner 参数遵守以下规则：

1. 在aardio开发环境中独立运行的 aardio 代码文件，文件级别的 owner 参数为null。
2. 使用 import 语句加载的 aardio库 文件, owner 参数为加载路径、或资源文件数据。

  
根据以上规则，可以在库文件中使用 `if( owner ) { }` 语句判断库是被加载还是在开发环境中直接执行， 以方便编写一些直接运行库文件的测试代码。

请参考：[import](../../library-guide/import.md)

## 元方法中的 owner 参数

请参考：

[重载操作符](../operator/overloading.md)   
[元方法](../datatype/table/meta.md)  

在元表元方法中，owner 表示左操作数。  

```aardio
import console; 

//定义表
var tab = { x=10 ; y=20 };
var tab2 = { x=10 ; y=20 }

//默认是按引用比较，不指向同一个对象就不相等，结果为 false
console.log( tab == tab2 ); 

//创建一个元素
tab@ = {
	//元表中的__eq函数重载比较运算符"=="。
	_eq = function( b){ 
		return ( (owner.x == b.x) and (owner.y == b.y) )
	};
}

//为tab2添加元表， 比较运算符需要为两个操作数添加同一个元表。
tab2@ = tab@;

//现在可以使用重载的==操作符按值比较了
console.log(tab==tab2 ); 

console.pause();
```  

## 迭代器中的 owner 参数

请参考：[泛型 for 与迭代器](../statements/iterator.md)

泛型 for（ Generic for ）的基本语法结构如下：

```aardio
for i in iterator,ownerObject,initialValue {

}
```  

上面的 `ownerObject` 就是 for in 语句循环调用 `iterator` 迭代器时使用的 owner 参数（用来表示迭代的目标对象）。

通常我们会写一个创建迭代器的工厂函数来初始化 for in 语句需要的 `iterator,ownerObject,initialValue` 这三个值。aardio 中的迭代器工厂函数都使用  `each` 前缀（ 这只是一个传统 ）。

示例：
  
```aardio
import console;

//创建迭代器的工厂函数
var eachArray = function (tab) {
		
	//上一次返回的 i 是下一次的参数    
	var iter = function  ( i ) {  
	
		//i 是控制变量，自动加一取下一个索引
		i++; 
		
		//自 owner 参数取得新的元素
		var v = owner[i];  
		
		//返回新值
		if( v  )return i, v;
	}
	
	//返回迭代器，owner 参数，初始迭代参数 
	return iter, tab, 0 
}

//创建一个测试用的数组
var tab = {12;345;6789};

//eachArray(tab) 返回迭代器，owner 参数，初始迭代参数 
for i,v in eachArray(tab) { 
	console.log(i,v);
}

console.pause();
```

## 数组排序回调函数的 owner 参数

在使用 table.sort 对数组排序时，排序回调函数将使用 owner 参数与第一个参数比较两个元素的大小，示例：

```aardio
var array = {1,2,3}

//排序
table.sort(array,function(next){
	//较大的值应排序在前
	return owner > next
})
```

请参考： [table.sort](../../library-guide/builtin/table/_.md#sort)