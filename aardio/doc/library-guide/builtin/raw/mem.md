# raw 库 - 原生内存操作

请参考: 

- [aardio 数据类型 - buffer](../../../language-reference/datatype/datatype.md#buffer)
- [原生数据类型](datatype.md)

## raw.tostring <a id="tostring" href="#tostring">&#x23;</a>


1. 函数原型：
  
    ```aardio
    // 参数可以指定结构体
    var 字符串 = raw.tostring( 结构体 )

    // 支持用负数表示相对位置
    var cdata = raw.tostring( 指针,开始位置=1,结束位置 )
    ```  
  
2. 函数说明：   

    将一个结构体、指针或 raw.buffer 创建的 buffer 对象转换为普通 string 对象。  

    参数 @1 是必须的，参数 @2，参数 @3 是可选参数。
    
    如果不指定结束位置，则会自动获取结束位置，如果是参数 @1 是 buffer 则会自动获取 buffer 的长度作为结束位置。如果是参数 @1 是指针则查找文本终结符`'\0'`并确定文本长度，然后返回全部字符串。

## raw.buffer 函数 <a id="raw-buffer" href="#raw-buffer">&#x23;</a>

1. 函数原型：   

    ```aardio
    var buffer = raw.buffer( 分配内存的字节长度 )
    var buffer = raw.buffer( 分配内存的字节长度,初始值 )
    var buffer = raw.buffer( 初始值 )
    ```
  
2. 函数说明：   

    raw.buffer 函数分配可读写的、固定长度的内存,内存不再使用时会自动释放, 返回可读写该内存的原生字节数组（ buffer ），可用于存取各种二进制数据。  
    
    raw.buffer 函数仅指定一个初始值参数时，初始值参数可以是一个结构体、字符串、或 buffer,  由指定的初始值确定分配的内存长度，并复制初始值指定的数据到分配的内存, 返回 buffer 对象。  

    初始值参数如果是一个普通的表结构体(struct)，则创建与结构体相同大小的内存并复制结构体的内存数据.  
    初始值参数传入 { } 则返回null。  
    
    raw.buffer 函数第一个参数为内存长度时，可选用第二个参数指定初始值。第二个参数指定的内存初始值可以用结构体、指针、buffer、或字符串指定一段内存数据,  也可用一个数值指定所有字节的初始值,不指定默认初始化所有字节为0, 如果初始值指定为字符串或buffer类型，填充初始数据以后剩余的字节会全部初始化为0。  

    初始值参数如果是一个普通的表结构体(struct)，则复制结构体的内存数据到 buffer 中，buffer 的大小必须大于或等于结构体的大小。  
    
    buffer 可用 `#` 操作符取数组长度,可用`[]`下标操作符读写 8 位无符号字节数值。这一点与字符串很像，但字符串是只读的字节数组，而buffer 对象的内存是可读写的。在下标中指定索引返回指定位置的字节码,如果索引溢出(过大或过小)会返回0。  
    
    buffer 在几乎所有字符串函数中都可以作为字符串使用。  
    在 `type.isString()` 函数参数中传入 buffer 或 字符串都会返回 true， buffer 不支持字符串连接操作符， 但支持 raw.concat,string.concat,string.join 等拼接函数。  
    
    buffer 在结构体中也可作为指针、`BYTE[]`数组的值。  
    在原生 API 参数中可作为内存指针、字符串、输出字符串使用。  
    在 COM 函数中可作为安全数组使用。  
    
    通过 web.json 库，buffer 在 JSON 中会转换为`{type="Buffer";data={} }`格式的表对象, 这种表对象可作为raw.buffer的唯一初始值参数还原为buffer对象。  
    
    与字符串、动态指针一样， buffer 尾部总会保护性地放置 2 个隐藏的字节`'\0\0'`（不计入字符串长度，不包含在字符串中）。与动态指针不同的是，即使你不指定初始值，aardio 仍然会初始化 buffer 中所有字节的值为 0，并且 buffer 的长度是不可变的。  

    注意：如果在一个结构体中，将 buffer 赋值为一个结构体的指针字段，并将这个结构体作为输出参数调用 API， 在 API 函数返回以后，只要指针地址没有改变 —— 则这个字段的值仍然是指向原来的 buffer 对象（ 如果指针地址被修改，则会变为新的指针值 ）。

3. 调用示例：   

    ```aardio
    import console; 

    var buffer = raw.buffer( 20 )

    //复制数据到 buffer
    raw.copy(buffer,"123abcdef")

    //修改字节数组
    buffer[1] = 65;
    buffer[2] = 66;

    //获取字节值
    console.log( buffer[1] )

    //显示所有字节值
    console.hex( buffer );

    //可用于字符串函数操作
    var s = string.left(buffer,3);

    //可用于其他函数的字符串参数
    console.log(buffer)

    console.pause(true);
    ```  

## 动态内存结构体、静态内存结构体  <a id="struct" href="#struct">&#x23;</a>

aardio 中的普通结构体在 aardio 中存为 table 对象，这种属于「动态内存结构体」，  
「动态内存结构体」其内存结构与其他原生静态语言的原生结构体是不同的，这种对象只有 aardio 可以直接使用。  
  
在调用原生 API 函数时，当我们使用动态内存结构体作为参数，aardio 会自动分配临时的内存，  
并将动态内存结构体转换为原生结构体复制到该内存， 然后将这个临时原生结构体指针作为参数传给 API 函数，调用结束后立即释放临时的原生结构体（不等待垃圾回收器）。 这个过程是全自动进行的。  
  
如果我们将存于表对象中的动态内存结构体复制到 buffer 中，这时候会自动转换为静态的结构体。buffer 的内存指针不会在 buffer 对象失效以前失效，静态内存结构体的指针也是静态不变的。 

- 动态内存结构体：结构体的内存指针是动态可变的，可以直接读写动态语言对象。
- 静态内存结构体：结构体的内存指针是静态不变的，不可以直接读写动态语言对象（需要转换）。
  
如果外部 API 函数需要一个静态不变的结构体指针，则必须创建静态内存结构体。

静态内存结构体仍然需要使用 raw.convert 函数将转换为普通结构体才能方便地操作。

为了避免这样的来回转换，标准库提供了 raw.struct 可以创建一种能自动同步的静态内存结构体。raw.struct 会在普通结构体与 buffer 分配的原生内存间自动同步，让我们可以得到一个静态内存的结构体指针，又可以像操作普通结构一样方便。

当然，raw.struct 多了同步数据的过程，没有普通 struct 快 - 所以不要滥用这个库。  
  
下面看一个完整的代码演示：  

```aardio
import console; 

//创建动态内存结构体（表结构体）
var point = {
    int x;
    int y;
}

//将动态内存结构体作为参数调用原生 API
::User32.GetCursorPos(point)
/*
要注意 ::User32.GetCursorPos() 根本就没有访问 point 这个对象，
原生 API 函数无法直接操作 point 这样的动态语言对象。

在调用过程中 aardio 生成了一个临时的原生结构体，
将 point 的值复制过去，然后调用 ::User32.GetCursorPos()
在调用结束后再从临时的原生结构体复制结构体的数据到 point，
最后释放临时结构体。
*/

//下面我们将结构体复制到 buffer 中
var pointBuffer = raw.buffer({int x;int y})

/*
这时候 buffer 里存储的就是原生的静态内存结构体，
::User32.GetCursorPos(pointBuffer) 直接访问了 pointBuffer 的内存指针，
*/
::User32.GetCursorPos(pointBuffer);

//在字节数组里我们只能直接获取二进制字节数据
console.hex(pointBuffer);

//转换 buffer 里的静态内存结构体为动态内存结构体（表对象）
var point2 = raw.convert(pointBuffer,{
    int x;
    int y;
})

//这时候就可以愉快的读写动态内存结构体数据了
console.log(point2.x,point2.y);
console.pause(true);
```  

## 字符串与 buffer  <a id="string-vs-buffer" href="#string-vs-buffer">&#x23;</a>


字符串与 buffer 相互转换：  

```aardio
import console; 

//字符串转为 buffer
var buffer = raw.buffer("abc");

//buffer 的字节值是可修改的，而字符串是只读的
buffer[1] = 92;

//buffer 转换为字符串
var str = raw.tostring(buffer);

console.log(str);
 
console.pause(true);
```  

字符串与 buffer 对比：  

```aardio
import console; 

//字符串是只读的
var str = "abc";

var str2 = "abc";

console.log("不同的变量放相同的字符串指向同一内存",str === str2)

//对字符串进行修改，实际上生成了新的字符串
var str = str + "def"

//不再相等，因为指向了不同的内存地址
console.log("str 与 str2 不再相等",str === str2)

var buffer = raw.buffer("abc")

var buffer2 = raw.buffer("abc")

//buffer 与字符串不一样，内容相同的 buffer 并不相等，存储的地址也不相同。
console.log("不同 buffer 放相同字符串，指向的是不同的内存",buffer === buffer2)

//buffer 的字节值是可修改的，而字符串是只读的
buffer[1] = 92;

//buffer 可以作为字符串使用
console.log(buffer)
 
console.pause(true);
```  

## 使用 raw.buffer 创建可析构对象 

raw.buffer 函数返回的 buffer 类型只要添加元表，其数据类型就会变为 cdata 类型，也不能再作为 buffer 使用。

通过这种方法我们就可以创建自定义的 cdata，在 aardio 代码中 cdata 可能不如 table 方便。
但是 cdata 有一个 table 对象所没有的功能，cdata 可以自定义 _gc 析构元方法。

我们可以用这种方法将析构函数指定到 cdata，然后再将 cdata 设为 table 对象的成员，那么 table 对象销毁时会释放 cdata 成员，也就间接触发了析构函数。table.gc 就是利用这个原理可以为所有 table 对象添加析构函数。

我们简化一下 table.gc 的代码，其关键代码思路是这样的:  
  
```aardio
table.gc = function(object,gc){
	var gd = raw.buffer(1);
	gd@ = { _gc = gc }
	object[["_gc"]] = gd; 
}; 
```  

标准库中还有一个 gcdata 函数可以直接利用 buffer 创建一个 cdata 对象，并可以直接指定元表，其基本用法如下：

```aardio
..gcdata(  
    _topointer = lambda() null;  
    _gc = function(){
        
    } 
)
```  

