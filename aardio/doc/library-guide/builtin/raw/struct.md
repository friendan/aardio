# 使用结构体

请参考: [原生数据类型](datatype.md)

## 创建结构体 <a id="struct" href="#struct">&#x23;</a>

在 aardio 中可以用类定义结构体，只要在类构造器的成员键名前添加原生类型声明就可以了。

参考：[类](../../../language-reference/class/class.md)
  
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

结构体创建的实例对象在 aardio 中仍然是一个 table 对象。 

我们可以在 table 构造器中成员的键名前面添加原生类型声明，直接构造结构体实例。

例如：

```aardio
var point = {
   int x = 0;
   int y = 0;
}
```

这非常方便，我们甚至可以在原生 API 函数的参数中直接用字面量构造结构体。

示例：

```aardio
var r,point = ::User32.GetCursorPos({
   int x;
   int y;
})
```

在 aardio 中设定结构体成员初始值不是必须的, 如果不指定初始值则在 aardio 代码中这些字段的值为 null，传到原生 API 函数中也会自动初始化为空值（简单讲就是存储该字段的每个内存字节的值都是 0 ）。

要点： 

- 在原生 API 函数中，声明为 struct 类型的参数不允许直接传 null 值，必须用 `{}` 表示 null 值。
- aardio 结构体在 API 函数参数中总是传结构体指针（传址）。`struct`与`struct &` 的类型唯一的区别是`struct &` 会获取被修改后的结构体值，对于目标 API 来说收到的都是相同的指针值。如果需要在 API 参数中[按值传递结构体](#by-val) （这种情况很罕见），则需要将结构体成员[展开](#by-val) 为多个普通的传值参数。
- [在调用 API 函数时，结构体会分配临时内存，并将临时内存的指针传给 API 函数，在调用结束后立即释放。如果要传稳定不变的结构体指针，请转换为 buffer 指针，或者使用 raw.struct 创建结构体。非必要不应该这样做，也很少会需要这样做。一般建议由 aardio 自动转换即可。](mem.md#struct)

> aardio 创建的结构体都会创建一个 _struct 字段，_struct 存储了结构体的原生类型声明。通过 `object[["_struct"]]` 可以快速判断一个对象是不是结构体。

参考： 

- [构造表](../../../language-reference/datatype/table/_.md#initializer)


## 在 API 函数中使用 struct 结构体 <a id="api" href="#api">&#x23;</a>


aardio 中的「结构体」存储为一个表对象，[当我们把结构体复制到 raw.buffer 或 raw.realloc 分配的内存、 或者其他可写入结构体的内存时，都会转换为原生结构体。在调用原生 API 函数时，结构体参数也会临时转换为「原生结构体」指针， 并在调用 API 结束时立即释放临时创建的「原生结构体」，这种转换是自动的](mem.md#struct)。  

无论原生 API 的函数参数是否输出参数，所有结构体参数总是转换为结构体指针（传址）,  

下面是一个在 API 函数参数中使用结构体的完整范例程序:

```aardio
//加载 DLL
var dll = raw.loadDll("User32.dll");

//声明 API 函数
getCursorPos = dll.api( "GetCursorPos", "word(struct& point)")

//通常，我们使用 class 来定义 API 函数中需要用到的结构体：
class Point {
   int x=0; 
   int y=0;
};

//创建一个新的结构体
var p = Point();

//使用API函数
GetCursorPos(p); 
```  

## 展开结构体 <a id="by-val" href="#by-val">&#x23;</a>


aardio 结构在 API 参数中总是传址（ 传结构体指针）。

如果需要在API参数中按值传递结构体（这种情况很罕见），则需要将结构体成员展开为多个普通的传值参数。
  
例如 PtInRect 的 C 语言函数原型为:

`BOOL PtInRect( RECT *lprc,POINT pt);`

第二个参数的 POINT 结构体是按值传递，而 POINT 结构体的成员为`{int x;int y}  `。

那么转换为 aardio 声明的格式如下:  

```aardio
::PtInRect := ::User32.api( "PtInRect", "int(struct lprc, int x, int y)" );
```

## 转换结构体类型

1. 函数原型：   

   ```aardio
   raw.convert(inPointerOrStringOrBufferOrStruct,outStruct,offset=0 ) 
   ```
  
2. 函数说明：   
  
   将源数据转换为目标结构体数据，偏移量 @offset 是可选参数,默认为 0。
   第一个参数 @pointerOrStringOrBufferOrStruct 可以是结构体(struct)、pointer、string、buffer 类型的对象。  
   第二个参数 @outStruct 必须是结构体(struct)。

3. 调用示例：   
  
   下面是使用 raw.convert 编写的一个数值类型转换小程序。

  
   ```aardio
   import console;  

   var struct2 = { 
      union u= { //union 联合体表示几个变量共用一个内存位置，利用此特性，可以将同一数据转换为不同的数据类型。
         byte byte = -1;
         BYTE ubyte = -1; 
      } 
   } 

   var struct1 = 
   { byte x= -1 }


   console.log( raw.convert(  struct1, struct2 ).u.ubyte ) //将 -1 转换为无符号单字节数值 255
   console.pause();
   ```  

## 获取结构体内存长度

1. 函数原型：   

   ```aardio
   raw.sizeof( structOrTypename )
   ```
  
2. 函数说明：   
  
   返回结构体的内存长度，参数可以是一个结构体(struct)，也可以是一个字符串形式的API数据类型名字。  
   
   ```aardio
   import console;  

   var struct = { 
      union u= {
         byte byte = -1;
         BYTE ubyte = -1; 
      };
      int n = 123;
   }; 

   console.log( raw.sizeof( struct ) );
   console.pause();
   ```  

## 自定义结构体对齐大小

  
在结构体中可以使用成员 _struct_aligned 自定义对齐大小。  
例如C/C++中定义结构体时使用 `#pragma pack(n)`，aardio则 需要在结构体中添加` _struct_aligned = n` 。
  
示例：  
  
```aardio
import console;

console.log( 
	raw.sizeof( {
		int x;
		LONG y;
		_struct_aligned = 1;
	} )
);

console.pause();
```  

## 原生数组 <a id="raw-array" href="#raw-array">&#x23;</a>

aardio 语言中我们可以在一个结构体里定义原生静态数组。
原生数组与其他原生类型的区别是在字段名称后用中括号内的数值指定了原生数组的长度。  
  
例如：  
  
```aardio
var arr  =  {
int value[2] = {1;2}
}
```

上面的字段声明 `int value[2]` 中的  `[2]` 指定了数组元素个数为 2。
在上面的 `[2]` 内只能指定数值字面量，不能用变量指定数组长度。

请参考：[原生类型 - 数组](datatype.md#raw-array)

如果我们不指定数组长度，可以用 `int value[]` 表示这是一个原生变长数组。
原生变长数组在运行时可选采用两种方法确定长度：

- 优先最高的方法是在数组中添加一个 length 字段指定数组的实际长度。
- 如果数组没有 length 字段，刚数组的值必须是一个非空数组，数组的实际元素个素将确定原生静态数组的长度。

例如:  
  
```aardio
var arr  =  {
int value[] = { length = 99/*可以使用变量*/ }
}
```

如果没有使用 length 指定数组长度，那么 aardio 将获取数组的实际长度，对于 BYTE,byte,WORD,word 等值可以为字符串的类型 - 支持使用字符串确定数组长度。 

例如：

```aardio
var arr  =  {
int value[] = { 1,2 }
}
```

如果原生数组的元素类型是结构体时（数组本身是 struct 类型的数组），  
则至少需要指定第一个元素的值（aardio 用这个元素确定数组元素实际使用的结构体类型）  
  
示例如下：  
  
```aardio
var arrLength = 99;
var arr  =  {
	struct value[] = { 
		length = arrLength; //指定数组长度
		{  //至少指定第一个结构体元素的值
			int x;
			int y;
		}; 
	}
}

```  

我们必须用将原生数组放到一个结构体中。
例如上面的 arr 是结构体对象，arr.value 才是包含在结构体中的数组。

在声明原生 API 函数时，原生数组参数的类型也应声明为　struct 类型（或 `struct&` 类型），struct 类型参数在 API 参数中传址（结构体指针）而非传值。

## raw.toarray 运行时创建指定长度的原生数组

1. 函数原型：   

   ```aardio
   rawArray = raw.toarray( arrayOrLenght, rawTypename = "struct", fieldName = "array" )
   ```
  
2. 函数说明：   

   函数的主要功能是在运行时创建指定长度的原生数组。
  
   函数根据从第一个参数 @arrayOrLenght 获取的长度在结构体中创建一个值为原生类型数组的字段（由第三个参数 @rawTypename 指定字段名称 ）。参数 @arrayOrLenght 可以直接用一个数值指定数组长度，也可以用于初始化数组内容与大小的普通数组（ table 对象 ）。

   第二个参数 @rawTypename 指定[原生数据类型名](datatype.md)，默认为"struct" 类型。

   第三个参数 @rawTypename 指定创建的结构体中保存原生数组的字段名称，省略则使用默认字段名 "array"。

3. 调用示例：   

  
   ```aardio
   import win;

   //创建一个结构体
   数组 = {}
   数组[1] = ::POINT()
   数组[1].x = 24123
   数组[1].y = 888

   数组[2] = ::POINT()
   数组[2].x = 45645
   数组[2].y = 999


   //转换为API数组
   array_c = raw.toarray( 数组 )
   ```  

   上面的代码等价于:

   
   ```aardio
   array_c =  {
      struct array[] = {}
   }

   array_c.array[1] = ::POINT(24123,888)
   array_c.array[2] = ::POINT(45645,999)
   ```   

4. 调用示例2：    

   ```aardio
   //构造定长原生数组
   var rawArray1 ={

      struct items[24] = { 
         { int int=0; float float=0.0; }
      } 
   }

   //动态创建定长数组
   var rawArray2  = raw.toarray( 24,"struct","items" )

   //结构体数组至少要指定一个结构体实例以确定数组类型。
   rawArray2.items[1] = { 
      int int=0;
      float float=0.0;
   }

   import console;
   console.logPause( 
      raw.sizeof(rawArray1)==raw.sizeof(rawArray2) 
   ); 
   ```  

## 将结构体转换为字符串

请参考: [raw.tostring](mem.md#tostring)

## 将结构体转换为字节数组

请参考:[raw.buffer](mem.md#buffer)

## 原生数组与 buffer 相互转换

示例：

```aardio
//创建一个结构体
array = {}
array[1] = ::POINT()
array[1].x = 24123
array[1].y = 888

array[2] = ::POINT()
array[2].x = 45645
array[2].y = 999

//转换为原生类型数组
var rawArray = raw.toarray( array )

//转换为二进制字节数组（buffer）
var buffer = raw.buffer(rawArray)

//再创建一个空的原生类型数组
var rawArray2 = raw.toarray( {::POINT(),::POINT()} )
  
//从内存里复制原生结构体的数据到 rawArray2
raw.convert( buffer,rawArray2 );

//输出
import console;
console.dumpJson(rawArray2);
console.pause();
```

## 内置结构体定义

aardio 已在内置模块 [builtin.struct](doc://library-reference/builtin/struct.html) 内预定义以下结构体为 [保留常量](../../../language-reference/variables-and-constants.md#reserved-constant)，全局有效可直接使用。


```aardio
class ::POINT {
   ctor(x=0,y=0){
      this.x = x;
      this.y = y;
   } 
   int x ; 
   int y ;
}

class ::SIZE {
    ctor(cx=0,cy=0){
      this.cx = cx;
      this.cy = cy;
    }
    int cx;
    int cy;
} 

class ::RECT {
    ctor(left=0,top=0,right=0,bottom=0){
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom; 
    } 
    int left;
    int top;
    int right;
    int bottom;
}

```

`::RECT` 结构体定义了很多方法，请查看库参考文档。