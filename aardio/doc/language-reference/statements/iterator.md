# 泛型 for 与迭代器

相关参考： 

- [计数 for 循环语句](looping.md#numeric-for) 
- [循环中断语句(break、continue)](looping.md#break-and-continue)
- [理解迭代器](../../guide/language/iterator.md)

## 迭代器 <a id="iterator" href="#iterator">&#x23;</a>


1. 什么是迭代器

    "迭代"是指循环取值并不断逼近最终目标的过程，每次取值的结果总是作为下一次迭代的初始值。

    aardio 中的 "迭代器"就是一个在 for in 语句中被循环调用的函数，每一次调用迭代器得到的第一个返回值总会作为下一次调用迭代器的参数 - 这个关键的迭代结果值我们称之为控制变量（Control Variable）。

2. 迭代器示例

    下面是一个创建与使用迭代器的 aardio 代码示例：
    
    ```aardio
    import console; 

    /*
    创建一个迭代器函数,
    迭代器接受上次循环返回的第一个值作为参数，返回一个或多个值 
    */
    var iterator = function(controlVariable){
        
        //第一个返回值
        if(!controlVariable) return 1;
        
        //返回新的值，首个返回值作为下一次调用迭代器的参数
        if(controlVariable<10) return controlVariable+1;
    }

    //在for语句中循环调用迭代器函数,直到迭代器返回空值（ null ）
    for( controlVariable in iterator ){
        console.log(controlVariable) 
    }

    console.pause(true);
    ```  

3. 迭代器的作用与意义

    迭代器就象一个生产者，而 for in 语句就象一个消费者，在迭代器与 for in 语句中交替地交换运行代码的控制权，这实现了类似协程的一种分工合作的机制，很好的分离了代码逻辑。

    例如我们在某个库模块或对象内部实现了迭代器（ 这个函数可能封装了大量循环取值的代码 ），在使用的时候只要简单地使用 for in 循环语句调用已经写好的迭代器就可以，这样就大幅简化了调用代码，提高了开发效率。

## 泛型 for（ Generic for ）<a id="for-in" href="#for-in">&#x23;</a>


泛型 for（ Generic for ）也就是 for in 语句，是基于迭代器的循环语句（ Iterator-based for ）。

泛型 for（ Generic for ）的基本语法结构如下：

```aardio
for controlVariable in iterator,ownerObject,initialValue {

}
```  

要点：

- 迭代器 `iterator` 必须是一个函数对象。
- 控制变量 `controlVariable` 是在循环时每次调用 `iterator` 函数返回的第一个值，上一次循环返回的 `controlVariable` 会作为下次调用  `iterator` 函数的参数。
- 当 `iterator` 返回的  `controlVariable` 为 null 时循环结束。
- 首次调用 `iterator` 时参数为 `initialValue` 指定的初始值，如果不指定  `initialValue` 则首次的调用  `iterator` 的参数为 null 值。
- 如果 `iterator` 函数有多个返回值，可写在 `controlVariable` 后面，并用逗号 `,` 分隔。
- 可选用 `ownerObject` 指定调用  `iterator` 的 owner 参数，请参考 [owner](../function/owner.md) 。
- 如果不指定 `ownerObject` 与 `initialValue` ，且  `iterator` 是一个表对象（ table ），aardio 会生成一个默认的迭代器用于遍历指定的表对象。

一般我们不会直接使用迭代器，而是先写一个创建并初始化迭代器的迭代器工厂函数，使用迭代器工厂的基本结构如下。
  
```aardio

//迭代器工厂，可选指定初始化参数
var iteratorFactory = function(args){

    //返回迭代器，接受上次返回的循环控制变量作为参数
    return function(controlVariable){

        //迭代器实现代码

        //返回新的值
        return controlVariable;
    } 
}

//循环调用迭代器工厂创建的迭代器
for controlVariable in iteratorFactory(expList) {

}
```  

在 aardio 中 iteratorFactory 函数通常以 each　作为函数名前缀，aardio 中有大量这种创建迭代器的迭代器工厂函数，例如：

- string.each 用于遍历匹配字符串
- winex.each 用于遍历窗口
- table.eachIndex 用于遍历数组
- com.each 用于遍历 COM 对象
- dotNet.each 用于/遍历 .NET 对象

调用 winex.each 函数创建迭代器遍历窗口的示例：  

```aardio
import console; 
import winex;

//winex.each 就是一个迭代器工厂
for hwnd,title,theadId,processId in winex.each( ".+", ".+" ) { 	
	console.log(hwnd,title,theadId,processId )
}

console.pause(); 
```  

使用一个迭代器工厂函数创建迭代器的好处是：

- 可以方便地指定一些初始化迭代器的参数
- 在外部的迭代器工厂函数中返回一个内部的迭代器函数时，可以利用迭代器工厂函数内部作用域的局部变量为返回的迭代器函数创建闭包，以方便地为创建的迭代器保存状态。参考 [函数闭包](../function/closure.md) 。

## 无状态迭代器、与有状态迭代器 <a id="state" href="#state">&#x23;</a>


如前所述，for in 语句可以在调用迭代器时利用循环不变量 `ownerObject` 与循环控制变量 `controlVariable` 保存迭代器的状态与进度 ：

```aardio
for controlVariable in iterator,ownerObject,initialValue {

}
```  

如果迭代器自身不保存任何状态进度， 我们就称之为无状态的迭代器，举个例子如下：

```aardio
import console; 

//迭代器工厂函数
var each = function(array){
	
	//返回无状态的迭代器
	return function(index){
		if(!index) index = 1;
		else index = index + 1;
		
		if(index<=#owner) return index,owner[index]; 
	},array
}

for( i,v in each({123;456;789}) ){
	console.log(i,v); 
}

console.pause(true);
```  

反之，如果迭代器不使用 for in 语句保存或传递迭代的进度和状态，而是自己在创建的函数闭包中存储进度和状态，那就称为有状态的迭代器，例如：

  
```aardio
import console; 

//迭代器工厂函数
var each = function(array){
	
	//创建一个闭包变量保存迭代的当前索引。
	var index = 0;
	
	//返回有状态的迭代器
	return function(){

		index++;
		
		var value = array[index];
		
		if(value) return index,value;
	}	
}

for( i,v in each({123;456;789}) ){
	console.log(i,v); 
}

console.pause(true);
```  

有状态的迭代器忽略了 for in 语句传递过来的参数，并改用闭包变量保存迭代的进度与状态。

有状态的迭代器可控性好一些，无状态的迭代器可以减少使用闭包变量。在大多数情况下这种区别可以忽略。

无论是有状态的迭代器还是无状态的迭代器，都需要牢记首个返回值为 null 时结束循环。

## 迭代遍历表（ table ）

如果在 for in 语句中用一个 table 对象迭代器，则 aardio 会直接遍历该 table 对象。

for in 语句遍历 table 对象的基本结构如下：

```aardio
for( k,v in tableObject){
	//循环体代码
}
```

- `tableObject` 必须是一个表对象， `tableObject` 后面不能有其他表达式。
- 如果 `tableObject` 不是一个表，也不是一个函数对象（迭代器）则会直接忽略该语句不执行任何操作（不会报错）。
- `k` 为每次循环遍历到的元素的键。
- `v` 为每次循环遍历到的元素的值。
- 迭代过程中可以修改表中元素的值，可用 null 值删除元素，但不可增加新的键值（可能会导致迭代的顺序被打乱）。

示例如下：  

```aardio
import console;

var tab = { a=333;b=444;1;2;3 } 

for k,v in tab {
    console.log(k,v);
}

console.pause();
```  

### 迭代遍历表的顺序

使用  for in 语句直接迭代表对象时并不保证迭代的顺序。

表是一个纯数组（所有成员的“键”都是从 1 开始、有序、连续的数值）时 for in 才会按索引顺序循环，否则改用普通的 [计数 for 循环](looping.md#numeric-for) 才能保证按索引顺序循环 —— 并且不会遍历到表的非数组成员，示例：  

```aardio
import console;

var arr = {12,56,89,abc=123}
for(i=1;#arr;1){
    console.log(arr[ i ])
}

console.pause()
```  

如果表包含非数组成员，可以使用特定的迭代器以控制迭代的顺序与细节：

- 如果要按键名的名称排序表中的名值对，可用 table.eachName 创建迭代器。
- 如果要按表中的值排序遍历结果，可用 table.eachValue 创建迭代器；  
- 如果要按顺序遍历表中包含的数组，可用 table.eachIndex 创建迭代器。  
  
table.eachIndex 不仅仅是可以简单地用于遍历表的数组成员，而是提供了一些增强的功能。table.eachIndex 支持一些来自于外部接口的可兼容数组，保以识别表的 `length` 属性或` _length `元方法指定数组长度，也可以使用 `_startIndex` 元方法自定义起始下标。参考 [元方法](../datatype/table/meta.md) 。

示例：

```aardio
import console;

var arr = {12,56,89}
for i,v in table.eachIndex(arr){
    console.log(i,v)
}

console.pause()
```  

aardio 中的表是哈希表（hashtable），哈希表的用途是快速查找值，无序正是他的最大优点（索引快如闪电）。而数组适合用于排序，数组的排序功能与表的快速查找值的优势是可以相互结合的。  
  
示例：

```aardio
import console; 

//无序的哈希表
var tab = {
    c = "3";
    b = "2";
    a = "1";
}

//有序的数组
var keys = {
    "c","b","a"
}

//用数组排序，泛型 for 用于纯数组可保持索引顺序。
for(i,k in keys){
    //用表查找值
    console.log(k,tab[k])
}
console.more(1);

//用数组排序
table.sort(keys);

//用数组排序
for(i,k in keys){
    //用表查找值
    console.log(k,tab[k])
}

console.pause(true);
```  

table.eachName 等迭代器也都是根据上面的原理实现了排序功能。

## 迭代器的析构器
   
有状态的迭代器编程更为简单，迭代的实现代码可以更方便地管控与维护迭代的进度与状态，代码的可读性也更好一些。有状态的迭代码还可以返回一个析构器用于释放资源.

在 for in 语句中使用迭析构器的基本结构如下：

```aardio
iteratorFactory = function(n){

	var iterator = function(){
	
	}
	
	var destructor = function(){
	
	}

	return iterator,destructor;
}

for(controlVariable in iteratorFactory() ){

}
```  

要点：

- 迭代器工厂函数的前两个值 `iterator`,`destructor` 都必须是函数对象。
- 无论是正常的结束循环，还是用 break 意外中断当前循环，aardio 保证都会调用指定的析构器函数。  
- 当使用 break n 语句中断外层循环、或使用 return 语句直接退出当前循环时，当前循环的析构器不会被触发。

迭代器的析构器只是提供一个尽可能马上释放资源的机会，但并不保证一定会释放资源，例如在迭代器中创建了一个句柄需要在迭代结束后保证被释放，这时候可以使用析构器以尽可能提前释放句柄，但同时应该使用 gcdata 为句柄对象自身添加析构函数以保证句柄一定会被关闭。

普通的 aardio 对象都会自动释放，并不需要写析构函数，只有系统句柄这样的非 aardio 本身创建的资源才可能需要写析构函数，实际上在 aardio 中我们遇到这样的情况并不多见。

## 纤程生成器

迭代器的主要思路是在迭代器与 for in 语句中不停地交换执行代码的控制权，这与纤程的交换执行代码的控制权类似。

实际上我们还可以使用纤程来生成 for in 语句的迭代器，示例：  

```aardio
import console;

var function fib(max){
	var a, b = 1, 1;
	while a < max {
		fiber.yield( a );
		a, b = b, a+b;
	}
} 

var n = console.getNumber( "请输入斐波那契数列范围:" );
for v in fiber.generator(fib,n) {
	console.log( v );    
}

console.pause();
```