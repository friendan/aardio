  使用函数参数 

# 使用函数参数

请参考：[定义函数](definitions.md)

## 形参、实参

形参 ( parameter ) 指函数定义时被包含在括号中具名参数，形参名也是局部有效的变量名字。  

实参（ argument）指调用时括号中包含的实际参数，实际参数是一个右值表达式。

示例：

```aardio
//这里的 param1,param2,param3 称为形参，可以将形参看成函数内部的局部变量名字  
var func = function(param1,param2,param3){ 
	//形参可以在函数体内部作为局部变量使用 
	return param1+param2+param3; 
} 
  
//这里的2,3,4 称为实参 
var result = func(2,3,4); 
```

实参的数目如果多于形参的数目，多余部分被丢弃。  
实参的数目如果少于形参的个数，不足的部分添加 null 值。

请参考：[调用函数](definitions.md#call)  

## 可变参数  

1. 在形参列表尾部定义可变参数

    在定数定义的**形参**列表尾部，可以用三个连续的圆点（`...`）表示可变参数（不定参数）。  

    可变参数必须是最后一个参数，如下：  
      
    ```aardio
    import console.int;

    //使用三个连续的圆点表示任意个数、任意类型的参数
    func = function( a,b, ... ){ 

      //不定参数转换为数组
      var args = { ... }
      
      /*
      args 是典型的可能包含 null 值的稀疏数组（数组索引不连续）。
      所以应使用 table.range() 取最小最大索引，而不是用 # 取数组长度。 
      */ 
      var _,len = table.range(args)
      console.log(len + "个参数")
      
      //遍历这种稀疏数组应当使用 table.eachArgs() 创建迭代器。
      for i,v in table.eachArgs(args){
        console.log(i,v)
      } 
    }

    func(1,2,99,888,null,777);
    ```  

2.  在调用实参列表尾部指定可变参数

    在实参列表尾部可以使用可变参数  

    ```aardio
    import console; 

    var str ="abcd"

    //在实参尾部可以使用不定参数
    console.log( "string.unpack有多个返回值",string.unpack(str) );

    //可变参数不放在最后面就只能取第一个值
    console.log( string.unpack(str) ,"string.unpack的第一个返回值");
    ```  

    注意上面的 `string.unpack(str) )` 会返回多个值。

## 在形参中指定默认值参数

实参可以省略，省略的实参传递 null 空值。如下：  
  
```aardio
import console; 

console.log( , ,2,3,) //下面都是等价的写法
console.log( null , null , 2 , 3 , null ) //与上面一行的作用相同
console.log( null , null , 2 , 3  ) //与上面一行的作用相同

console.pause();
```  

在调用实参的尾部指定 null 值是无意义的，在 aardio 中 null 等价于未指定任何值。
  
在函数定义的形参表中，可以为任意位置的参数指定默认值。
如果省略相应实参，或调用实参为 null 值时，则将对应形参指定的默认值作为实参。  
  
在其他一些编程语言中，只能为尾部的参数的指定默认参数，而在 aardio 中没有这个限制。

示例如下： 

```aardio
import console;

//在函数定义的形参中，使用等号指定形参的默认值;
function func(a,b=123,c="字符串",d=2,e=true) {
  console.log(a,b,c,d,e)
}

//调用函数
func(1,,,4,5 )
```  
  
形参默认值仅允许使用以上示例中演示的字面值常量(数值、字符串、布尔值)，不可使用其他变量或表达式。  

## 在函数实参中构造表

当函数的调用实参有且只有一个表构造器（并且表不是结构体），并且第一个名值对使用等号`=`分隔时，则可以省略外层的 `{}` 符号。
  
例如 `func( k=1,k2=2 )` 等价于   `func({ k=1,k2=2 })` 。

只要参数中的第一个表构造器的第一个名值对使用`=`分隔，后面再指定其他表成员时只要符合构造表的语法就可以了。

例如在表参数中添加数组成员可以这样写：

`func( k="值",123,456,789 )`
  
> 注意这种写法不是其他编程语言里的"命名参数", aardio 语言并不存在"命名参数"这个特性。但利用这种语法确实可以模拟命名参数的效果，例如 aardio 在调用 Python 时如果在 Python 函数名前加一个 `$` 字符就可以利用 aardio 省略  `{}` 的表参数特性模拟出 Python 命名参数的效果，示例：
> 
> ```aardio
> import py3;
> 
> var requests = py3.import("requests");
> var ses = requests.Session(); 
> var res = ses.$get(verify=false,"https://www.aardio.com");
> ```

如果一个函数需要较复杂的经常变动的参数，使用表作为参数可以增强函数的可扩展性与可读性。

示例：

```aardio
函数调用( 
	名字 = "某某"; 
	住址 = "北京"; 
	家庭成员 =  统计函数( 
		男 = 6, 
		女 = 3, 
		老 = 1, 
		幼 = 1, 
	) 
);
```

## table 参数的副作用

1. 纯函数

    在 aardio 中函数是纯函数（Pure Function）- 输入输出数据流都是显式（Explicit）的。函数从函数外部接受的所有输入信息都通过参数传递到该函数内部；函数输出到函数外部的所有信息都通过返回值传递到该函数外部，即函数的数据只有一个入口( 参数 )，一个出口( 返回值 )。函数可以返回多个值。

    aardio 的函数只有输入参数，没有输出参数，不能在函数体中改变实参的数据。 原生 API 函数中的输出参数同样被转换为返回值 - 然后附加到返回值列表中。  
  
2. 具有副作用的 table 参数

    在虚函数中传址参数仍然具有副作用。

    table 对象在赋值或传参中都是传址的，传递过程中并不改变指向的对象，而table 的成员又是可修改的，这就使 table 对象在函数的传参过程中具有副作用，对 table 参数的成员进行修改会作用到外部对象，并不局限于函数体内部。

    如果需要在函数内部改变外部变量的值，那么应当把数据封装到一个 table 对象中。

    ```aardio
    import console;

    // tab 参数指定 table 对象时具有副作用 
    var set = function (tab) { 
      //改变 tab 对象的成员值会作用到函数外部
      tab.x = 256; 

      //输出参数针对的是参数本身，副作用影响的是参数指向的数据
      //tab 不是输出参数，下面的代码仍然不能改变外部 table 对象
      t = 123;
    }

    var tab ={x=10,y=20}

    //table 对象作为参数是按引用传递的
    set(tab); 

    //tab.x 被 set 函数改变了
    console.dumpTable(tab); 

    console.pause();
    ```  

    这个有一点利用潜规则走后门的意思，不声不响的修改了外部的对象，又没有显式的交待，应当尽量避免这么做。

    当然，我们也没有必要总是墨守成规，可以使用更友好的函数命名，清晰地注明副作用。

    例如：

    ```aardio
    import win;

    var rc = ::RECT(1,2,3,4);

    //函数命名注明了它会改变 rc 中的坐标 
    win.toScreenRect(0,rc);
    ```  

    有经验的程序员总是不断提醒我们，多打几个字，减少大堆的麻烦！

## 输出参数

虽然从语法上说,aardio 函数没有定义输出参数的这个概念，但是 aardio 函数支持在函数中返回多个返回值，通过返回值也可以实现修改输出参数的值，举个例子：  

```aardio
var test = function(x,y){
	x = x + 1;
	y = y + 1;
	return x,y;
}

var x,y = 1,2;

//通过返回值接收了 x,y 的新值
x,y = test(x,y);

```  
  
aardio 在调用外部 COM 函数，或者外部 API 函数时，同样是使用上面的方法来支持输出参数。  

例如调用 COM 函数时，所有输出参数都会增加一个返回值（ 按参数的前后位置排序返回 ）。调用外部 API 函数时同样的可以自返回值获取输出参数的值，在 API 函数声明中定义为输出参数的参数(参数的原生类型后面加 `&`，例如`int &`) - 都会增加一个对应的返回值。  
  
如果在 aardio 中定义外部 COM 函数或外部API函数需要用到的回调函数时，同样使用多个返回值来修改输出参数的值。  
  
例如，在调用API函数时定义 stdcall 回调函数，下面的 x 就是输出参数：  
  
```aardio
var stdCallback = raw.tostdcall( 
	function(x){
		x = x + 1; 
		return 123,x;
	},"int(int &x)" )
```  
  
或者在调用 COM 控件时定义各种回调函数（例如定义 COM 事件）同样是在返回值中指定输出参数的新值。

例如在使用 web.form 时如下定义 NewWindow3 事件：  
  
```aardio
wb.NewWindow3 = function(ppDisp,cancel,flags,urlContext,url ) { 

  //这里 ppDisp,cancel 都是输出参数，下面修改了cancel 的值为true
  return ppDisp,true;
};
```  

## owner 参数 <a id="owner" href="#owner">&#x23;</a>


aardio 中所有函数都有一个隐藏的 [owner 参数](../../language-reference/function/owner.md)，可以认为是第 1 个调用参数前面隐藏的第 0 个参数。

owner 参数不用写在调用参数列表里，由 aardio 自动传递并接收 owner 参数。

owner 指的是在调用成员函数时拥有该成员函数的所有者。

例如执行 `object1.method()` 时，object1.method 函数接收到的 owner 参数就指向 object1 。  

如果我们先写 `object2.method = object1.method()` ，然后再调用  `object2.method()` 时，object2.method 函数接收到的 owner 参数就指向 object2 。

onwer 参数可能指向不同的对象。

请参考：[owner](owner.md)

在调用一个类构造实例对象时，如果实例对象的成员函数不改变所有者，则调用实例对象的成员函数时，owner 默认指向类的实例对象 - 也就是类主体内的 [this](../class/class.md#this) 对象。区别在于 this 无法在外部改变，而 owner 可以在外部改变的。

在 [元方法](../datatype/table/meta.md) 中 owner  表示左操作数。

在 [数组排序](../../library-guide/builtin/table/_.md#sort) 序时，owner 参数表示将要与下一个参数比较的元素。

