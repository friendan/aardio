# 类

## 定义类

类可以动态创建数据结构相同的 table 对象。

定义类的语法如下：

```aardio

//定义类
class className{

	//构造函数，可以省略
	ctor( parameter1,parameter2,... ){
		//构造函数代码
	}
	
	//定义属性
	propertyName = "value";
	
	//定义方法(成员函数)，必须写为名值对格式。
	methodName = function(parameter1,parameter2,... ){
		
	} 
}
``` 


也可以使用下面的格式定义类：

```aardio

//定义类
className = class {

	//构造函数，可以省略
	ctor( parameter1,parameter2,... ){
		//构造函数代码
	}
	
	//定义属性
	propertyName = "value";
	
	//定义方法
	methodName = function(parameter1,parameter2,... ){
		
	} 
}
```  
 

## 类主体

类主体指的是 class 关键字后面用 `{}` 包括的部分。

类主体内除了用 ctor 关键字定义的构造函数以外，其他部分的语法与构造表成员的语法完全相同，请参考：[构造表](../datatype/table/_.md#initializer) 。

示例如下：
  
```aardio
class cls{
	a = 123;
	func = function(){
		//类有自已的名字空间，访问全局对象要加上..前缀
		..console.log("我是对象内部的成员函数") 
	} 
}
```

**类主体内部的成员函数必须写为名值对格式，函数体必须是匿名函数，不能省略 function 关键字与等号**。

## 构造函数

使用 ctor 关键字定义构造函数，构造函数在调用类创建对象时被调用。构造函数可以接收参数，并返回对象。

要点：

- 定义构造函数除了用 ctor 关键字代替 function 关键字以外，其他与定义函数的语法一致。请参考：[定义函数](../function/definitions.md) 。
- 构造函数必须写在类主体的最前面，不能写在其他成员后面。
- 构造函数是可选的。

示例：

```aardio
class cls { 
	
	ctor( name ){
		this.name = name;
	};
	
	//其他成员
	method = function(){
		
	}; 
}
```

## 使用类创建对象 <a id="new" href="#new">&#x23;</a>

调用类创建对象实际上等价于调用类的构造函数，其语法与调用函数完全一样，在类名后加 `()` 表示调用类创建对象，可以在 `()` 内指定构造参数。

请参考： [调用函数](../function/definitions.md#call)

示例：

```aardio
//创建对象
var obj = cls("名字1");
var obj2 = cls("名字2"); 

//访问对象属性
var name = obj.name;

//调用对象的方法 
obj.method();
```  

类创建的对象都是 table 对象，使用方法与其他 table 对象一样。


## 类的名字空间

请参考：[名字空间](../namespace.md)

每一个类拥有独立的名字空间，类的名字空间就是类自身。
类名字空间中的成员也就是类的公用静态成员。  

在类内部访问外部名字空间需要使用完整路径。在类外部可以通过类的名字访问类名字空间内的成员（也就是类的静态成员）。

示例：

```aardio
//定义一个类
class cls{
	a = 123;

	func = function(){
		//类有自已的名字空间，访问全局对象要加上..前缀
		..console.log( "类的方法被调用了" ) 
	}
}  

//类自身也是名字空间
namespace cls{
		
}

//访问类名字空间的公用静态成员。
cls.A = "类的静态成员A";
```  

因为类有独立的名字空间，在类内部要使用 `..` 前缀的全局名字空间路径才能访问外部名字空间的对象，例如上面的 `..console.log( 类的方法被调用了 ) `。

要特别注意：

- 类是一个名字空间，但名字空间不一定是类。
- 可以先定义类再用 namespace 语句打开类的名字空间，但不能反过来。如果先用 namespace 语句定义与类名同名的名字空间，在后面再定义同名的类就会覆盖掉原来的名字空间，因为名字空间不是类。
- 同理如果在外部库名字空间中使用类名字，类名应当是库路径尾部的最后一个名字空间，类不应当作为父名字空间。 

请看下面的代码:

```aardio
import my.cls.c
import my.cls //如果my.cls是一个类,因为类会创建新的名字空间,那么上面导入的 my.cls.c 会被覆盖。
```  

但如果使用一些技巧，类也可以作为父名字空间使用。典型的例如标准库里的 process 就是一个类，而 process 作为父名字空间包含了大量的下级库。

如果我们像下面这样写是不会出问题的：

```aardio
import process.popen;
import process;
```  

可以这样写的原因有两个：

- process 名字空间的库几乎都会先调用 `import process`，这就保证了 process　名字空间总是指向 procss 类。
- process 库里面如果检查到在 process 类定义以前已经定义了 process 名字空间，就会将原来的旧名字空间自动合并到 process 类定义的名字空间以修正问题。

当然我们仍然应当避免用类名作为父名字空间，避免不必要地将简单的事搞复杂。
  
关于导入库请参考: [import](../../library-guide/import.md)

## this 对象 <a id="this" href="#this">&#x23;</a>


在类内部，可以使用 this 对象引用动态创建的对象。

示例如下：
  
```aardio
import console; 

class cls{
	a = 123;
	func = function(){
		//类有自已的名字空间，访问全局对象要加上..前缀 
		..console.log( this.a ) 
	}
}

//创建对象
var obj = cls(); 

//调用对象的方法
obj.func();
```  

当一个 table 对象使用 `object.method()` 的格式调用成员函数时，默认会将 object 传递为成员函数的 owner 参数。  
而在类创建的对象成员函数里，owner 对象与 this 对象默认指向同一个对象。
  
this 对象与 owner 对象的区别在于：

this 是类内部指向当前创建对象的指针，this指针不会因为拥有函数的 table 前缀改变而改变。而 owner 对象是会根据函数调用时拥有函数的 table 对象而相应改变。

请参考：[owner](../function/owner.md)

示例如下：

```aardio
import console; 
	
class cls{ 

	func = function(){
		//类有自已的名字空间，访问全局对象要加上 .. 前缀 
		..console.log("owner", owner  )
		..console.log("this", this )
		..console.log("owner == this", owner == this  ) 
	} 
}

//创建对象
var obj = cls(); 

//调用对象方法
obj.func(); //默认 table 与 owner 是同一个对象 

console.more();

var func = obj.func;

func();//这里 owner 为null空值，而 this 对象没有改变

console.more();
```  
 
## 类的直接继承

直接继承是指在子类的构造函数中调用基类的构造函数创建实例对象 - 并直接基于该实例对象继续构造出子类实例对象。这种方法可以向上调用基类的构造函数 - 保证按继承关系正确的初始化基类，并且可以使用构造函数创建的闭包变量方便地存储实例对象的私有数据。

示例：

```aardio
//创建一个基类 
class baseClass{
	a = 123;
	b = 456;
	c = 789
}
namespace baseClass{
	static = 123; //类的静态成员
}

class derivedClass{
	
	//构造函数
	ctor(...){ 
		this = ..baseClass(...); //调用基类构造对象原型。
	};
	
	c = "覆盖基类成员";
	d = "子类的新成员";
}

import console;

//从子类创建对象
var obj = derivedClass();

//输出对象的所有成员(包括直接继承的基类成员)
for(k,v in obj){
	console.log(k,v);
}

console.pause();
```  

## 类的间接继承 - 原型继承(差异化继承)

通过对象元表的 `_get` 元方法指定一个原型表，也可以实现继承的功能。  

间接继承的好处继承指向静态的公用模板，并不会实际生成新的对象(浅拷贝)，可以占用较少的空间，缺点是访问速度不如直接继承快，并且占用了 `_get` 元方法，当我们需要使用 `_get` 元方法来做一些其他的事（例如实现属性方法）时就比较麻烦。

在间接继承时可以通过 owner 来访问当前对象（类似直接继承中的 this 对象）。  
  
示例：

```aardio
class baseClass{
	a = 123;
	b = 456;
	c = 789
}

class derivedClass{ 
	c = "覆盖基类成员";
	d = "子类的新成员";
	@_prototype; 
}

//在类的名字空间内指定静态共享成员 _prototype
derivedClass._prototype =  { _get = ..baseClass() };
	
import console;
var obj = derivedClass();//从子类创建对象

//与类的直接继承不同
//遍历只能输出子类的所有对象,（不会遍历元表中原型对象的成员）
for(k,v in obj){
	console.log(k,v);
}

//通过元方法继承仅在使用成员操作符时生效
console.log("访问 baseClass 类的成员", obj.a );

console.pause();
```  

如果不需要构造函数，我们也可以使用 table.create 函数基于原型继承的原理直接创建表对象。  
  
直接继承、原型继承可以相互结合使用，  
一个对象可以直接继承一个基类，并且通过原型继承另外一个类或对象。  
而在原型继承中使用的原型对象自身，也可以直接继承、或原型继承基它的类或对象。  

在 aardio 中最常见的是直接继承，原型继承很少被使用。

另外使用过于复杂的继承关系是非常不好的习惯，重度使用继承的开发模式在现代编程中已经不流行了。

优先使用组合而不是继承是良好的设计习惯，尤其在动态语言中更应该这样做。

## 属性元表 <a id="metaProperty" href="#metaProperty">&#x23;</a>


在我们设计 winform 窗体时，会在上面放一些控件，当我们访问这些控件对象的 text 属性时，无论读或写 text 属性都会调用系统 API 函数，这种属性必须指向一个函数，因为除了简单的读写数据以外还需要执行一些其他的代码去操作界面上的控件窗口。

例如一个 winform 窗体上有一个 button2 控件，我们这样读它的 text 属性。  

```aardio
var text = winform.button2.text
```

为了拦截对象的属性读写操作，一般我们想到通过 `_get`、`_set` [元方法](../datatype/table/meta.md) 将属性转换为函数。

但是我们会遇到一些麻烦：

所有的控件有一些共同的属性，例如大小、字体等等，如果都写在  `_get` 或  `_set` 元方法里会非常乱。属性字段越来越多，我们假设有二十个属性，我们的 `_get` 或  `_set`  元方法里的代码将会非常的多，然而我们每次需要访问的仅是其中一小部分代码。

aardio 的早期版本并没有属性表的概念，win.ui.ctrl 库的设计臃肿而复杂。为了解决所有的问题，让可变的代码与不变的代码合理分离，aardio 设计了 util.metaProperty 库，这个库的源码很简短，但是解决了所有的问题。win.ui.ctrl.metaProperty 则是util.metaProperty的一个扩展，提供了类似的功能。应用属性表以后，win.ui.ctrl 减少了很多代码并更为清晰。  
  
我们看下面 win.ui.ctrl.picturebox 控件的部分代码:
  
```aardio
namespace win.ui.ctrl; 

class picturebox{
    ctor(parent,tParam){
        if(tParam){
            tParam.style |= 0xE/*_SS_BITMAP*/;
        }
    }
    @_metaProperty;
}

picturebox._metaProperty = metaProperty( 
    image = {
        _get = function(){   
            return owner.getBitmap();
        }
        _set = function( v ){
            if(type(v)==type.pointer)
                return owner.setBitmap(h);
        } 
    } 
)
```  

当我们在窗体 winform 上创建一个 picturebox 控件，我们可以直接通过 winform.picturebox.image 读写属性。当然图片在屏幕的控件上，而不是 picturebox 这个对象里面，无论是读或写都要从控件中实时读写，这就需要把它们映射为函数。

上面的属性字段 image 就被映射为了独立的 `_get` ,`_set`  函数。  
`_get` 负责读属性，`_set` 负责写属性，当省略`_get`时可以创建一个只写属性，而省略`_set`时可以创建一个只读属性。

我们可以仅仅在需要属性表时加载 util.metaProperty，这样不会影响普通表存取的速度。无论是 util.metaProperty 的实现、还是 util.metaProperty 的使用都非常的简洁、直观并易于扩展。  
  
属性表的意义在于扩展了`_get` ,`_set`元方法、使每一个属性字段都可以定义自已的`_get` ,`_set`方法， 方便地定义只读、只写属性。属性元表不但可以自定义对象的元方法，而且可以通过属性表定义对象的原型，该原型（属性表）是支持多级继承的。并且在多级继承中始终可以通过 owner 参数访问当前对象。

实际上经过数十年的发展，util.metaProperty 已经成为了 aardio 标准库中可能是被使用次数最多的一个库。

请参考： [util.metaProperty](../../library-reference/util/metaProperty.html)

## 信息隐藏、成员保护  
  
1. 在构造函数中可以使用 var 语句创建对象的私有数据。 

    构造函数的局部变量作用域为类主体。因此构造函数中定义的局部变量在整个类主体内部都可以访问。而在类外部无法访问它们。利用此特性可以创建对象的私有数据，实现对象的信息隐藏。

    请参考：[var语句](../statements/assignment.md#var)  
  
2. 成员保护 

    使用下划线作为首字符的类成员是只读成员，只读成员的数据只能读取不能修改。 可以使用只读成员保护对象内部不希望被修改的数据。

    另外，使用元表也可以创建只读的成员，例如使用 util.metaProperty 创建的属性表可以指定 `_get` 方法而省略 `_set` 方法实现只读成员。


## 结构体 <a id="struct" href="#struct">&#x23;</a>

在 aardio 中可以用类定义结构体，只要在类构造器的成员键名前添加原生类型声明就可以了。
  
```aardio
//定义结构体
class Point{
	int x = 0;  
	int y = 0;  
}

//创建一个结构体实例对象
var pt = Point();
```

> aardio 默认已经定义了所有字母大写的保留常量 `::POINT` 用于表示坐标。

参考：[原生数据类型 - 结构体](../../library-guide/builtin/raw/datatype.md#struct)
