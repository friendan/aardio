# 理解 aardio 迭代器

## 最简单的例子  
  
首先我们把迭代器的一大堆复杂的语法描述先扔到一边，看来一个简单至极的使用迭代器的示例：  
  

```aardio
import console;

//each函数创建一个迭代器
each = function(){
   
    //在局部变量闭包中保存一些需要用到的数据
    var i = 0;
   
    //下面返回一个迭代器 - 实际上就是一个函数。
    return function(){
        i++;
        if( i < 10 ) return i; //迭代器函数会被循环调用,直到他返回的是空值
    }
}

for( i in each() ){
    console.log("i",i)
}

console.pause(true);
```


从上面我的代码我们了解到：

> 1、迭代器实际上就是一个函数对象,这个函数会在for语句中被多次的循环调用
> 
> 2、each函数是用来创建迭代器的，这个创建迭代器的函数我们称之为“迭代器生成器”，for语句在开始循环以前会调用each函数并获取迭代器函数。

  
参考：[泛型 for 与迭代器](../../language-reference/statements/iterator.md) 

  
上面一节给出的例子返回的迭代器返回了0到10中间的整数，  
现在我们希望生成器一些参数让他生产不同的迭代器，例如我们可以指定数值从哪里开始、到哪里结束。  
  
  
示例：  

```aardio
import console;

//each函数创建一个迭代器
each = function(min,max){
   
    //下面返回一个迭代器  
    return function(){
        min++;
        if( min <= max ) return min-1;
    }
}

for( i in each(10,20) ){
    console.log("i",i)
}

console.pause(true);
```


  
现在我们又有了新的需求，我们不是要求迭代器循环列出min到max之间的数值。  
而是希望给迭代器一个集合对象，要求迭代器根据一定的规则列出我们需要的成员。  
  
那么我们进一目改进迭代器如下：  

```aardio
import console;

//each函数创建一个迭代器
each = function( array ){
     
    var i = 0;
    return function(){
        i++;
        if( array[ i ] ) return array[ i ];  
    }
}

var arr = {1;23;45};
for( n in each( arr ) ){
    console.log("n",n)
}

console.pause(true);
```


通过学习 aardio 基础语法，我们知道在调用一个对象的成员函数时 - 函数默认会提供 owner 参数指向他所在的集合。  
所以如果我们把上面的 each( array ) = function(){}  函数修改为 arr.each = function(){}  以后，就可以在迭代器内部使用 owner 对象来访问集合对象了。  
  
我们想当然地把上一节的代码修改如下：  

```aardio
import console;

var arr = {1;23;45};
arr.each = function(){
     
    var i = 0;
    return function(){
        i++;
      if( owner[ i ] ) return owner[ i ];  
    }
}

for n in arr.each() {
    console.log("n",n)
}

console.pause(true);
```


可是运行后，代码报错了，说是 onwer 参数为 null，出错行为上面红字标出的那行。


我们知道每个函数都有自己的 owner 参数，arr.each 函数内部的 owner 参数无疑就是指向 arr 对象。

但在 arr.each 内部创建的新函数（ 也就是那个迭代器 ）并不是任何集合对象的成员，他的 owner 对象是空的。

> 关于 owner 参数的详细说明，请参考这里： [owner 参数](../../language-reference/function/owner.md)

这该如何是好呢？！

幸运的是 - aardio 中提供了一种机制，for 语句可以在接受迭代器生成器的多个返回值，你可以用第一个返回值返回迭代器，你可以用第二个返回值返回迭代器的 owner 对象，正确的代码如下：

```aardio
import console;

var arr = {1;23;45};
arr.each = function(){
     
    var i = 0;
    return function(){
        i++;
        if( owner[ i ] ) return owner[ i ];  
    },owner //使用第二个返回值显式指定迭代器的 owner 参数
}

for n in arr.each() {
    console.log("n",n)
}

console.pause(true);
```

下面的范例把集合对象保存在了迭代器生成器函数创建的局部变量的闭包中，这种使用上层生成器函数的局部变量保存迭代器所需的集合对象以及状态的迭代器，我们称之为“有状态的迭代器”。

```aardio
var arr = {1;23;45};
arr.each = function(){
     
    var i = 0;
    var 集合对象 = owner;
    return function(){
        i++;
        if( 集合对象[ i ] ) return 集合对象[ i ];  
    }
}
```
  
而依赖 for 语句来传递迭代器集合对象、以及状态值的叫“无状态的迭代器”，也就是说这种迭代器依赖 for 语句来保持状态。  
我们前面说过了，for 语句在循环开始首先调用迭代器生成器，迭代器生成器可以返回以下三个返回值。  

> 迭代器,集合对象,控制变量 = 迭代器生成器( 可选的生成器参数 )

当然集合对象,控制变量这两个返回值都是可选的，  
如果迭代器生成器返回了集合对象，那么 for 语句会在每次调用迭代器时把他指定为迭代器的 owner 参数。  
如果返回了控制变量，for 语句会在调用迭代器时把控制变量作为调用参数传过去，而每次调用迭代器的第一个返回值会成为新的控制变量的值。  
  
听起来是不是很复杂？！我们还是来看一个简单的例子：  

```aardio
import console;

var each = function(集合对象){
      
    return function(控制变量){
   
        控制变量++;
        if( owner[控制变量] ) return 控制变量/*新的值*/,owner[控制变量];
         
    },集合对象,0/*控制变量的初始值*/
}

var arr = {1;23;45};
for i,v in each(arr) {
    console.log(i,v)
}

console.pause(true);
```


上面就是一个无状态的迭代器，利用 for 语句来传递迭代器的状态。


在 aardio 中有一个规则，所有对象提供的迭代器生成器的函数名都以"each"开始，例如：  

```aardio
import console;

import process;
for processEntry in process.each( ".*.exe" ) {  
    console.log( processEntry.szExeFile )
}

import winex;
for hwnd,title,theadId,processId in winex.each() {  
    console.log( hwnd,title,theadId,processId  )
}
console.pause(true);
```


所以，请善用 aardio 编辑器提供的智能提示找到您需要的迭代器生成器。 

 
我们还可以用 fiber.generator 创建基于纤程的迭代器：

```aardio
import console;

function fib(max){
    var a, b = 1, 1;
    while a < max {
        fiber.yield( a );
        a, b = b, a+b;
    }
}

for v in fiber.generator(fib,console.getNumber( "请输入斐波那契数列范围:" )) {
    console.log( v )   
}

console.pause()
```


   