# 循环语句

## for 循环语句（ Numeric for ） <a id="numeric-for" href="#numeric-for">&#x23;</a>

aardio 使用基于数值范围的 for 循环语法（Range-based for）。

for 循环语句基本结构：  
  
```aardio
for(i = initialValue;finalValue;incrementValue){
    //循环体
}
```  

基本格式：

- 可选使用或不使用括号 `()` 包含循环条件（循环变量与循环参数）。
- 循环体可以是用 `{}` 包含的语句块，也可以是一个单独的语句。
- 循环体不允许是单独的分号（空语句）。

循环变量：  

- 循环变量 `i` 的值从 `initialValue` 开始，到 `finalValue` 结束（包含 `finalValue` ），每次递增 `incrementValue`。
- 循环变量 `i` 是一个作用域限于循环体内部的局部变量，前面不需要写 var 关键字，写了也会被忽略。
- 允许在循环体内部修改循环变量 `i` 为一个合法数值。如果循环变量被修改为非数值，则下次循环前自动恢复为修改前的值。 

循环参数：

- **aardio 使用基于数值范围的 `for` 循环，全部循环参数都必须是数值表达式，没有`条件（condition-expression）`与`迭代（iteration-expression）`部分。** 
- `initialValue` 指定循环范围的起始数值，`finalValue` 指定结束数值。
- 循环增量 `incrementValue` 可使用负数表示递减循环，省略循环增量则默认为 1。
-  可以用 `;` 或者 `,` 号分隔所有循环参数，但是同一语句分隔循环参数的分隔符必须相同。允许改用任何非大写的标识符分隔循环参数，但不能使用语法关键字、保留函数名、全局常量作为分隔符。
- 所有循环参数都仅在循环开始前计算一次，循环过程中不会重新计算。

要点：

aardio 使用基于数值范围的 for 循环语法（Range-based for）。 for 循环范围的终止值 `finalValue`  是一个确定的数值而不是需要循环计算的条件表达式（condition-expression），循环增量 `incrementValue` 也是一个纯数值而不是一个需要重复执行的迭代表达式（iteration-expression）。这一点与其他类 C 风格编程语言完全不同，aardio 使用更简单的 `for` 循环语法。

示例：  

```aardio
import console;

// 循环变量 i 从起始值 1 循环到终止值 10 ，每次递增步长为 2。
for(i=1;10;2){ 
    
    // 在控制台输出 1,3,5,7,9
    console.log(i); 
}

// 循环变量 i 从 1 循环到 10 ，省略递增步长则默认为 1 。
for(i=1;10){
        
    i++; // 修改循环变量的值，使步长变为 2
    
    // 循环变量设为无效数值，下次循环以前自动修复为计数器值
    i = "无效数值" 
}

// 循环变量 i 从起始值 10 循环到终止值 1 ，每次递减步长为 1。
for(i=10;1;-1){  
    
    // 在控制台输出 10,9,8,7,6,5,4,3,2,1
    console.log(i); 
}

console.pause()
```  

aardio 允许以多种不同的方式分隔循环参数，示例：

```aardio
//使用逗号分隔循环参数，前后两个分隔符必须一致
for i=1,10,1 {  
    
}

//使用普通标识符分隔循环参数。 
for i=1 to 10 step 1 {  
    
}
```

  
用 for 循环计算阶乘的示例：  
  
  
```aardio

//计算阶乘(指从 1 乘以 2 乘以 3 一直乘到所要求的数) 
math.factorial = function(n){ 
    
   var result = 1; 
   
   //for 计数循环，递增步长为 1 时可省略，循环体可以为单个语句。
   for(i=2;n) result *= i;  
   
   return result;  
}

import console;
console.log( math.factorial(15) )
console.pause();
```

## for in 泛型循环语句（ Generic for ）<a id="for-in" href="#for-in">&#x23;</a>


泛型 for 循环是基于迭代器的循环（ Iterator-based for ）。

"迭代"是指循环取值并不断逼近最终目标的过程，每次取值的结果总是作为下一次迭代的初始值。

aardio 中的 "迭代器"就是一个在 for in 语句中被循环调用的函数，每一次调用迭代器得到的第一个返回值总会作为下一次调用迭代器的参数 - 这个关键的迭代结果值我们称之为控制变量（Control Variable）。

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

更多关于 for in 语句的细节与示例请查看：[泛型 for 与迭代器](iterator.md)

## while 循环语句 <a id="while" href="#while">&#x23;</a>


while 语句包含`条件判断`部分、执行代码的`循环体`部分。  

```aardio
while( condition ) { 
    //循环体（Code block）
}
```

要点：

- `condition` 是一个返回循环条件的表达式。
- `condition` 为 true 则继续循环，为 false 则停止循环。
- 循环体可以是一个单独的语句，可以是用 `{}` 包含的[语句块](blocks.md) 。 

相关参考：

- [等式运算符](../operator/equality.md) 
- [逻辑运算符](../operator/logical.md) 
- [关系运算符](../operator/comparison.md)

示例代码：
  
```aardio
import console;

// 定义循环变量
var countLoop = 0;

// 循环条件判断
while( countLoop<10 ){ 
    
    // 递增循环变量
    countLoop++;
    
    // 在控制台显示循环变量
    console.log("循环次数", countLoop); 
}; 

console.pause();
```  

## while var 循环语句 <a id="while-var" href="#while-var">&#x23;</a>


while var 语句类似 while 语句，但可以条件判断前添加循环变量初始化、判断条件前执行语句。  

while var 循环语句的基本结构如下：

```aardio
while( var variable = expression; step; condition ) { 
    //循环体（Code block））
}
```  
要点：

*   `var variable = expression` 在循环初始化时执行，其语法与声明局部变量的 var 语句相同，可以声明一个或多个仅在循环体内部有效的局部变量，多个变量用逗号分开，可用赋值语句指定这些变量的初始值。 
*   `step` 可指定需要在每次循环前执行的单个语句。
*   `condition` 是循环条件表达式，返回值为 true 则继续循环，为 false 则停止循环。
*   可单独省略 `var variable = expression` 部分，但要保留分号。
*   可单独省略 `step` 部分，但要保留分号。
*   可只保留 `condition`部分，其他部分省略（ 分号也省略 ），这等价于普通的 while 语句。
*   可将 `while(var variable;variable=value;variable){}` 缩写为 `while(var variable=value){}`。

标准 while var 语句示例代码：

```aardio
import console;

while( 
    var countLoop = 0;//在循环开始前初始化局部变量
    countLoop++;//每次循环前执行的单个语句，可省略不写,但不能省略分号
    countLoop<=10 //循环条件表达式 
    ){ 
    
    // 在控制台显示循环变量，将输出 1 到 10 的数值。
    console.log("循环次数", countLoop); 
}; 

console.pause();
```  
  
while var 语句各种用法示例：  

```aardio
import console;

//用法 1: 标准 while var 语句
while(
    var i; //初始化循环变量列表
    i =  console.getNumber( "请输入数值,输入100退出:" );//每次循环前要执行的单个语句
    i != 100  //循环条件表达式
    ) {
    console.log( i ) 
}

//用法 2: 循环参数中省略初始化循环变量部分，用于分隔循环参数的分号不可省略，
var i = 0;
while( ;i++; i<10 ) {
    console.log(i)
}

//用法 3: 循环参数中省略循环前执行语句，用于分隔循环参数的分号不可省略
while(  var i; ;  i != 100  ) {
        
    i =  console.getNumber( "请输入数值,输入100退出:" ); 
     
    console.log( i ) //循环条件表达式
}

//用法 4: 合并缩写法,下面的循环变量赋值语句会循环执行，循环变量 i 的值同时也是循环条件表达式。
while(
    var i =  console.getNumber( "请输入数值,输入0退出:" )
    ) {
    console.log( i ) 
}
 
//用法 5: 省略其他部分，等价于标准 while 语句
while(i>0){
    i--;
    console.log(i);
}

console.pause(true);
```  

## do while 循环语句

do while 循环语句的基本结构如下：  
  
```aardio
do{
    //循环体（Code block）
} while( condition )
```  

要点：

- `condition` 是一个返回循环条件的表达式。
- `condition` 为 true 则继续循环，为 false 则停止循环。
- 循环体可以是一个单独的语句，可以是用 `{}` 包含的[语句块](blocks.md) 。 
- do ... while 语句首先执行循环体，然后再判断循环条件。 循环体至少会执行一次。

下面是 do..while 语句示例:  

```aardio
import console;

//循环
do{  
    //显示循环变量
    console.log(countLoop) 
    
    //递增循环变量
    countLoop++

}while( countLoop<123 ); //判断循环条件
console.pause();
```  

## 循环中断语句 <a id="break-and-continue" href="#break-and-continue">&#x23;</a>


1. break 语句 

    break语句中断并退出循环并跳转到指定循环的结束点以后开始执行。  
  
2. continue 语句 

    continue 语句跳过循环体剩下的部分，跳转到循环体的开始处并继续执行下一次循环。  
    类似一种不执行循环体剩余部分代码的条件语句。  
    
    可以在循环体的开始处使用 continue 语句是一种好的习惯，可以避免将循环体代码包含在一个大的if语句中。  
    使程序拥有清晰的结构。  
  
3. 带标号的 break、continue 语句(labeled break、labeled continue) 

    aardio 支持带标号的 break、continue 语句。  
    
    标号可以是一个数值，例如 break N; continue N;  
    N指定循环语句的嵌套序号。当前循环用1表示，上层循环为2，再上层为3，依此累加......  
    
    也可以在循环语句的开始，为循环语句指定一个具名标号，  
    然后使用 break lable、continue lable 中断指定的循环。  
  

示例代码：
  
```aardio
import console;

while( true ){ 
    
    循环体2: //可以在循环体的开始指定一个标号 
    console.log("循环体2开始" );
    
    
    while( true ){ 
        console.log("循环体1开始" );
        
        //中断上层循环
        break 2;
        
        //这句的作用与上面的 break 2 作用是一样的
        break 循环体2; 
        
        console.log("循环体1结束" );
    
    }; 
    
    console.log("循环体2结束" );
}

console.pause();
```

一个好的习惯是：使循环的条件控制集中在循环体的开始或结束，使循环体内部保持良好的内聚性。从而使代码的结构清晰并容易理解。

## 巧用中断语句减少嵌套

请看下面的判断语句。
  
```aardio
import console;

//定义局部变量
var cond = 2;

//条件语句
if( cond == 1 ){
    console.log(1);
}
else{ 
    //可以在 if 语句块前面添加代码 
    if( cond == 2 ){ 
        console.log(2); 
    } 
    else{ 
        //可以在 if 语句块前面添加代码 
        if( cond == 3 ){ 
            console.log(3); 
        } 
    } 
} 

console.pause()
```  

按上面的思路，你可以继续写下去，嵌套层次越多，代码也就会越来越混乱。但是它的确符合了结构化编程的原则：一个入口、一个出口。  
  
这时候我们不能再默守成规，将上面的判断语句放在一个 `do...while(false)` 语句块内部，这个“循环”语句块只会执行一次，并且可以随时可以用中断语句退出循环.改进后的代码如下：

```aardio
import console;

// 定义局部变量
var cond = 2; 

// 循环
do {  
    if(cond == 1) { 
         console.log(1);
         break;// 可以随时跳出语句块
    };

    //可以在这里添加其他代码
    
    if(cond == 2 ){ 
         console.log(2); 
         break;//可以随时跳出语句块  
    };
    
    //可以在这里添加其他代码
 
    if(cond == 3 ){ 
        console.log(3); 
        break;//可以随时跳出语句块 
    }; 
}while( false ); //while 条件为 false 则不再循环
console.pause();
```  

这里我们虽然使用了 break 中断语句，但是所有 break 语句位于相同深度的嵌套层次，中断过程清晰一致。  
  
现在我们不再需要 else 语句块来“多管闲事”，if 语句完成自已的任务就可以离开。每个代码块(指语句块、子程序、或类、名字空间、甚至是按就近原则放在一起的逻辑语句块)都应当尽可能减少自已的责任。

我们同样可以在函数中使用上面的技巧来避免条件语句过深的嵌套。  
这时候我们需要创建一个函数、并用 return 语句代替退出子程序。  

  
```aardio
import console;

// 定义函数。
var func = function(cond) { 
    if(cond == 1) { 
         console.log(1);
         return;// 可以随时跳出语句块
    };

    //可以在这里添加其他代码
    
    if(cond == 2 ){ 
         console.log(2); 
         return;//可以随时跳出语句块  
    };
    
    //可以在这里添加其他代码
 
    if(cond == 3 ){ 
        console.log(3); 
        return;//可以随时跳出语句块 
    }; 
} 

// 调用函数。
func(2);

console.pause();
```  

## 嵌套循环

循环语句是允许多重嵌套的，一个循环语句允许包含另一个循环语句。  
为了清晰的表示嵌套的层次，需要根据嵌套的层次使用tab制表符缩进。  

![](../../icon/warning.gif)不要使用超过三层的嵌套，这样会使代码变得混乱难以理解并且要添加太多的缩进

### 用简洁清晰的条件语句

无论循环的条件语句是在循环体的开始，还是在循环体的结束。  
它们应当尽可能的清晰、简短。一个很长的而复杂的条件表达式意谓着你需要重新设计你的程序。  
  
将难以理解的条件表达式从循环体的条件判断语句中分离出来，将它们赋值一个命名清晰的变量。或者用命名清晰的子程序来执行。  
  
条件语句的责任只有一个，即判断循环条件。  
不要试图在条件语句中改变什么、这是不好的习惯、除了 while var 语句 aardio 不允许你在条件表达式中赋值，这有利于形成良好的代码风格。

请看下面的设计糟糕的代码。  

  
```aardio
import console; 
import mouse;

var x,y,l,t = 0,0,0,0 
var r = 20; 
var b = 20;

function 下一个坐标(){ 
    x++;
    y++ 
    return x,y;
}

while(x>=l && x<=r && y>=t && y<=b && 下一个坐标()  ){

    mouse.move(x,y,true);
    sleep(1)
}
```  

while 语句的条件判断式写的很长不会很“酷”，这是糟糕的错觉。  
而且在循环体内部的函数做了它不应该做的事：改变坐标值。  
  
需要修改的是将复杂的条件判断交给一个布尔变量或者一个函数。  
而修改数据的代码应当放到循环体内部，如下：  

  
```aardio
import mouse;

//变量名调整了位置，而不是将x,y与l,t莫名其妙的放在一起
var l,t,r,b = 0,0,20,20; 
var rcWindow = ::RECT(l,t,r,b);

function 在窗口范围内(x,y){
    return rcWindow.contains(x,y);  
}   
 
//变量在靠近第一次使用处声明，减小跨度，增强可读性
var x,y = 0,0      

//循环体的条件判断语句只有一个责任：清晰明确的条件判断
while( 在窗口范围内(x,y) ){ 

    x++;
    y++;    

    mouse.move(x,y,true);

    sleep(1); 
}
```