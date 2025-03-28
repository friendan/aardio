

# aardio 语法速览

## 第一个对话框

```aardio
import win;
win.msgbox("Hello, World!");
```

win.msgbox 可将任意类型参数显示为字符串，可显示表对象与数组的内容。

aardio 中除 raw,string,table,math,io,time,thread 等无需导入的内置库以外，其他所有库（标准库或扩展库）都必须先用 `import` 语句导入后才能使用。例如在上面我们用 `import win` 导入了窗口函数库。


##  第一个控制台程序

```aardio
print("Hello, World!");
```

在 aardio 中 [print](../../language-reference/builtin-function/print.md) 是一个模板输出函数，可以被重写并指向不同的实际输出函数，在默认情况下 print 函数向控制台窗口输出内容，并可自动打开控制台，在退出非界面线程前自动暂停控制台。

更为正式与完整的控制台程序需要用到 console 库，示例：

```aardio
//导入库
import console; 

//加载动画
console.showLoading("加载动画测试");
thread.delay(1000); //暂停 1 秒

//输出字符串
console.log('测试字符串');

//输出变量
console.dump({a=123;b=456});

//以 JSON 格式输出变量
console.dumpJson({a=123;b=456});

//暂停并等待按键
console.pause(true);
```

请参考：[控制台入门教程](../../library-guide/std/console/_.md)

##  第一个窗口程序  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="第一个 aardio 窗口程序")
winform.add(
button={cls="button";text="点这里";note="这是一个很酷的按钮";left=435;top=395;right=680;bottom=450;color=14120960;z=2};
edit={cls="edit";left=18;top=16;right=741;bottom=361;edge=1;multiline=1;z=1}
)
/*}}*/

//按钮回调事件
winform.button.oncommand = function(){

    //修改控件属性
    winform.edit.text = "Hello, World!";

    //输出字符串或对象，自动添加换行
    winform.edit.print(" 你好！")
}

//显示窗口
winform.show();

//启动界面线程的消息循环（消息泵）
win.loopMessage();
```

**【重要】窗口程序必须使用 `import win.ui` 导入 `win.form` 窗口类**。

请参考文档：[创建窗口与控件](../../library-guide/std/win/ui/create-winform.md)

## 第一个网页应用程序

```aardio
import win.ui; 
var winform = win.form(text="窗口标题")

import web.view;
var wb = web.view(winform);//创建 WebView2 浏览器控件

// 导出 aardio 函数到 JavaScript 中
wb.external = {
	add = function(a, b) {
		return a + b;
	}	
} 

// 写入网页 HTML 代码
wb.html = /******
<div id="result"></div>

<script> 
(async ()=>{
	
	//调用 aardio 导出的 wb.external.add 函数。
	var num = await aardio.add(1, 2)

	//显示结果
	document.getElementById('result').innerText = num;
})()
</script>
******/;

//显示窗口
winform.show();

//启动界面消息循环
win.loopMessage();
```

也可以用 wb.go 函数打开网址或本地文件，例如：

```aardio
wb.go("https://www.example.com/");
```

请参考文档：[web.view 入门指南](../../library-guide/std/web/view/_.md)

## 调用标准库 web.json 解析 JSON

```aardio
import web.json;

var json = `
name = {
    a: 123,
    b: 456,
    c: [1,2,3]
}`

//JSON 字串解码成 table 对象
var tabObject  = web.json.parse(json);
```

请参考文档：[web.json 库参考](../../library-reference/web/json.md)

##  调用原生 API

```aardio
//加载 DLL
var dll = raw.loadDll("user32.dll");

//调用 API 函数
dll.MessageBox(0,"测试","标题",0);
```

aardio 已经默认加载了一些常用的系统 DLL 对象，例如 `::User32`, `::Kernel32`, `::Shell32`，`::Ntdll` 等。  


所以上面的代码可以简化为：

```aardio
::User32.MessageBox(0,"测试","标题",0);
```

参考：[免声明调用原生 API](../../library-guide/builtin/raw/directCall.md)

##  结构体

```aardio
var info = {
    INT size = 8;
    INT tick;
}
::User32.GetLastInputInfo( info )
```

因为 aardio 函数支持多返回值，且结构体默认为传址输出参数 —— 会添加到返回值中，所以上面的代码也可以这样写：

```aardio
var ok,info = ::User32.GetLastInputInfo( {
    INT size = 8;
    INT tick;
} );
```

参考：[使用结构体](../../library-guide/builtin/raw/struct.md)

##  注释语句

```aardio
// 单行注释


/*  
多行注释，首尾星号数目必须相同。
*/
```

## 变量与赋值

```aardio
// 使用 var 语句声明局部变量
var n = null;
var str = "字符串";

// 不使用 var 语句声明的变量为当前名字空间的变量
gstr = "字符串";
```

在 aardio 中，默认情况下变量属于当前名字空间。使用 `var` 语句可以定义局部变量，使其作用域仅限于当前语句块。

##  语句与语句块

```aardio
{
    var n = null;
    var str = "字符串";
}
```

语句末尾可以加分号，也可以不加。

aardio 使用 `{` 和 `}` 来标记语句块。

使用 `var` 语句定义的局部变量具有块级作用域，即在语句块内定义的局部变量，其作用域仅限于该语句块内。


##  数值

```aardio
var num = 123.01; //10 进制数值
var hex = 0xEFEF; //16 进制数值
var num2 = 123_456; //可用下划线作为分隔符
var num3 = 2#010; //可在 # 号前自定义进制
```

##  算术运算

```aardio
var num = 3 + 2; //加，值为 5
var num = 3 - 2; //减，值为 1
var num = 3 * 2; //乘，值为 6
var num = 3 / 2; //除，值为 1.5
var num = 3 % 2; //取模，值为 1
var num = 3 ** 2; //乘方，值为 9
```

##  位运算

```aardio
import console;


//按位取反
var n = ~2#101;
//显示2#11111111111111111111111111111010
console.printf("2#%b", n)


//按位与
var n = 2#101 & 2#100;
//显示2#100
console.printf("2#%b", n)


//按位或
var n = 2#101 | 2#110;
//显示2#111
console.printf("2#%b", n)


//按位异或
var n = 2#101 ^ 2#110;
//显示2#011
console.printf("2#%b", n);


//按位左移
var n = 2#101 << 1;
//显示2#1010
console.printf("2#%b", n);


//按位右移
var n = 2#101 >> 1;
//显示2#10
console.printf("2#%b", n);


//按位无符号右移
var n = -2 >>> 18;
//显示 16383
console.log(n);


console.pause();
```

##  字符串

```aardio
var rawString = "双引号包含的是原始字符串，不处理转义。
可直接包含换行符，不能包含回车符。
可以用 "" 表示一个双引号。";


var rawString2 = `反引号的包含的是原始字符串，不处理转义。
可直接包含换行符，不能包含回车符。
可以用 `` 表示一个反引号。`;


var escapedString = '单引号包含的是转义字符串，处理转义
忽略回车换行，反斜杠作为转义符使用
例如 \r\n 表示回车换行';


var commentString = /*
块注释可以赋值为字符串。
首尾星号数目必须配对。
忽略首尾紧邻星号的第一个空行（如果有的话）,
其他换行总是会规范化为回车换行符，
也就是 '\r\n'。
*/

var commentString2 = //行注释也可赋值为字符串，不含回车换行

//在文件路径前加 $ 符号，可将该文件编译为字符串
var fileContent = $"~/aardio.exe"
```

##  二进制字符串、文本编码

```aardio
var bin = '字符串可以包含任意二进制数据，例如 \0'


var utf8 = "字符串可以包含文本，默认为 UTF-8 编码"


var utf16 = '转义字符串后加 u 字符表示 UTF-16 编码字符串'u
```

aardio 在很多地方都支持自动编码转换，例如调用 Unicode(UTF-16) 版本的 API 函数时，UTF-8 字符串可自动转换为UTF-16 编码字符串（ 支持双向自动转换），例如以下两句代码的作用是相同的：

```aardio
::User32.MessageBox(0,"内容","标题",0);


::User32.MessageBox(0,'内容'u,'标题'u,0);
```

在调用 `::User32.MessageBox` 时，aardio 会自动检测并优先使用 Unicode 版本的 `::User32.MessageBoxW` 函数。当然，也可以主动在 API 函数名后加上大写的 `W` 尾标声明这是 Unicode 版本函数（即使该函数名尾部并没有 `W`，也可以添加 `W` 尾标）。


##  字符串连接

```aardio
//使用 ++ 操作符连接字符串
var str = "字符串1" ++ "字符串2";


//如果 ++ 前后有引号，可省略一个 + 号。
var str = "字符串1" + "字符串2";


//用 string.concat() 函数连接支持多参数，支持 null 值
var str = string.concat("字符串1","字符串2")
```

##  数组转字符串

```aardio
//合并字符符，参数 2 指定换行符作为分隔符，单引号包含转义字符串
var str = string.join({"字符串1","字符串2"},'\n')
```

##  读写文件

直接读写文件全部数据：

```aardio
//写文件
string.save("/test.txt","要保存在文件的字符串");


//读文件
var str = string.load("/test.txt");
```

使用 io.file 读写文件：

```aardio
//创建文件对象
var file = io.file("/example.txt","w+b");

//写入结构体
file.write({int x=1,int y=2});

//写入文本
file.write("写入内容",'\r\n');

//移到文件指针
file.seek("set",0);

//读取结构体
var struct = file.read({int x=1,int y=2});
print(struct.x,struct.y);

//读取文本行
var line = file.read("%s");
print(line);

//关闭文件
file.close();
```

fsys.file 的基本用法与 io.file 类似，但 fsys.file 基于 ::Kernel32.CreateFile 并且支持指定文件、管道等系统句柄参数。

fsys.stream 的基本用法与 io.file 类似， 但 fsys.stream 实现了  COM 接口 IStream ，并可以创建内存文件流。

当调用函数 `type.isFile( file )` 时如果参数 file 为 io.file,fsys.file,fsys.stream 之一都会返回 true 。

##  文件路径

```aardio
/*
文件路径开始可用单个斜杠（或反斜杠）表示应用程序根目录。
应用程序根目录在开发时指工程目录，发布后指 exe 目录。
*/
var str = string.load("\res\test.txt");


//文件路径中正斜杠可自动转换为反斜杠
var str = string.load("/res/test.txt");


/*
文件路径开始用波浪线表示 exe 所在目录。
aardio 不需要生成 exe 就可以运行调试，此时波浪线表示 aardio.exe 所在目录。
*/
var str = string.load("~/res/test.txt");


/*
aardio 很多读文件的函数都兼容工程内嵌资源目录。
不需要修改代码，所以 "\res\test.txt" 可以是资源目录。
如果读取文件失败，string.load() 会返回 null 值（不报错）。
*/
var str = string.load("\res\test.txt");


/*
将文件转换为完整路径。
将路径传给第三方组件时，建议这样转换一下。
*/
var path = io.fullpath("\res\test.txt");
```

注意在 aardio 中双引号内不需要转义反斜杠，所以写为 `"\\res\\test.txt"` 是错的。单引号内才需要使用转义符，例如 `'\\res\\test.txt'` 等价于  `"\res\test.txt"`。


在 aardio 中一般不必要使用 `"./dir/test.txt"` 这样的相对当前目录路径。因为当前目录可以任意更改，你不知道什么时候某个第三方组件是不是悄悄帮你改了当前目录。


##  嵌入文件到字符串

在文件路径前加上 `$` 操作符可将该文件编译为字符串对象。

在编译该代码时文件必须存在，程序发布后就不再需要这个文件了。


示例：

```aardio
var str = $"\dir\test.txt";
```

不要用这个方法包含资源目录下的资源文件，  

因为这等于将同一个文件重复包含了多次，会不必要地增加发布体积。


##  名字空间

```aardio
//导入其他库文件，同时也导入该库创建的名字空间
import console;


//打开名字空间
namespace test.a.b{
   
    //定义当前名字空间变量
    console = 123;
   
    //..console 等价于 global.console
    ..console.log(console);
}


console.pause(true);
```

默认名字空间为全局名字空间，也就是 global 名字空间。在其他名字空间访问 global 名字空间必须在变量前加上两点（ .. ） 。例如 global.console 等价于 ..console 。

在 aardio 中使用 import 导入其他库文件，同时也导入该库创建的名字空间。导入名字空间只是引入模块，访问该名字空间仍然要写完整的名字空间路径。


##  表 (table)


table（表）是 aardio 中唯一的复合数据类型，除了非复合的基础数据类型以外，aardio 中几乎所有的复合对象都是表，即使是变量的命名空间也是表。表的本质是一个集合，可以用于容纳其他的数据成员，并且表也可以嵌套的包含其他的表（table），在 aardio 里表几乎可以容纳一切其他对象。

  
1.  表可以包含键值对

    ```aardio
    tab = {
        a = 123;
        str = "字符串";
        [123] = "不符合变量命名规则的键应放在下标内。";
        ["键 名"] = "不符合变量命名规则的键应放在下标内。";
        键名 = {
            test = "表也可以包含表";
        }
    }
    ```

2.  表可以包含有序数组

    如果表中不定个数的成员的“键”是从1开始、有序、连续的数值，那么这些成员构成一个有序数组。aardio 中如果不加特别说明，数组一般特指有序数组，所有数组函数默认都是用于有序数组。

    ```aardio
    //在表中创建数组
    var array = {
        [1] = 123;
        [2] = "数组的值可以是任何其他对象";
        [3] = { "也可以嵌套包含其他表或数组"}
    }
    
    //有序数组的键可以省略，下面这样写也可以（并且建议省略）
    var array = {
        123;
        "数组的值可以是任何其他对象";
        { "也可以嵌套包含其他表或数组"}
    }
    ```

    要特别注意 aardio 的数组起始索引为 1 。

3. 表可以包含稀疏数组

    如果表中包含的成员使用了数值作为键，但是多个成员的键并不是从1开始的连续数值 - 则构成稀疏数组。在 aardio 一般我们提到的数组 - 如果未加特别说明则是特指有序连续数组（不包含稀疏数组）。
    
    如果表中包含了稀疏数组 - 也就是说成员的数值键（索引）包含不连续的、中断的数值，那么不应当作为有序数组使用。 aardio 中几乎所有针对数组操作的函数或操作符 - 如果未加特别说明都要求参数是有序数组。

    下面的数组就包含了 null 值，属于数值键（索引）不连续的稀疏数组：  
    `var array = { "值：1", null, "值：2", "值：4", null, null,"其他值" }`

4. 表的常量字段

    如果键名以下划线开始，则为常量字段（值为`非 null`时不可修改） —— 可通过元属性 `_readonly` 禁用此规则，详细说明请参考[语法手册](../../language-reference/datatype/table/meta.md#_readonly)。例如 `var tab = {}; tab@ = {_readonly = false} //添加元表设置元属性 _readonly 为 false  `。

5. 表的类 JavaScript 写法

    如果表不是一个声明原生类型的结构体，那么在表构造器中允许使用类 JavaScript 语法，可用冒号代替等号分隔键值，用逗号代替分号分隔表元素，并允许用引号包含键名。

    示例：

    ```aardio
    var tag ={"name1":123,"name2":456}
    ```

    上面包含键名的双引号可以省略，这种写法的表作为函数参数使用时不可省略外面的大括号 `{}` 。

    但请注意 aardio 不允许用  `[]` 构造数组，必须用 `{}`构造数组。

6. 表作为函数参数的简写法

    如果函数的参数是一个普通的表构造器（ 构造表对象的字面值 ），并且第一个元素以等号分隔键值对，则可省略最外层的 `{}` 。例如 `console.dump({a = 123,b=456})` 可以简写为 `console.dump(a = 123,b=456)`。

    这种写法很像命名参数，但 aardio 并没有命名参数，本质只是创建了一个表对象作为唯一的调用实参。
    
    注意：

    参数表如果是结构体则不能省略外层的 `{}`。

    如果参数表使用类 JavaScript 语法用冒号代替等号分隔键值，则不能省略外层的外层的 `{}` 。

    例如：`console.dump({a : 123,b : 456})` 或者 `console.dump({"a" : 123,"b" : 456})` 都不能省略外层的  `{}` 。


##  成员操作符

```aardio
var tab = {a = 123; b = 456};


/*
用点号访问表成员，点号后面必须跟合法的标识符
*/
var item = tab.a;


/*
用下标操作符 [] 访问表成员，[] 里可以放任何表达式。
*/
var item = tab["a"];


/*
用直接下标操作符 [[]] 访问表成员，[[]] 里可以放任何表达式。
直接下标不会触发元方法，忽略重载的运算符。
*/
var item = tab[["a"]];

tab = null;

//无论操作对象存储的是什么值，直接下标 [[]]  失败返回 null 而不是报错。
item = tab[["a"]];
```

##  null 值  

未定义的变量值默认为 null 。  
  
如果对象本身是 null 值，对其使用点号、普通下标会报错，对基使用直接下标 `[[]]` 则不会报错而是会返回 null 值。

用 # 操作符获取 null 值长度返回 0 而不是报错。

将表对象的成员赋值为 null 就可以删除该成员。

在条件判断中，null 值为 false。


##  取数组或字符串长度

```aardio
var array = {123;456};
print("数组长度",#array);

var str  = "abcd";
print("字符串长度",#str);

var n  = null;
print("null 值长度为 0",#n);
```

使用 `#` 操作取数组或字符串的值，也可以取 null 值的长度（ 返回 0 ）。

## 数组操作

```aardio
//创建长度为 3 的数组（多维数组可指定多个长度参数），初始值为 0
var arr = table.array(3,0); //等价于 {0,0,0}

//创建数组，添加从 1 循环到 10 步进为 2 的数值。
var arr = table.range(1,10,2); //等价于 {1,3,5,7,9}

//创建数组
var arr = {1, 2, 3, "hello"};

//在末尾添加元素
table.push(arr, "world");

//删除末尾元素
var last = table.pop(arr);

// 在开头添加元素
table.unshift(arr, 0);

// 删除开头元素
var first = table.shift(arr);

// 在索引 2 处插入元素
table.insert(arr,"aardio", 2);

// 删除索引 3 处的元素 
table.remove(arr, 3);  

// 查找元素
var index = table.find(arr, "hello"); 

// 遍历数组
for(i=1;#arr;1){
	print( arr[i] );
}
```

## 查找替换字符串

aardio 与查找替换字符串有关的函数基本都支持模式匹配。
模式匹配比正则表达式更简洁、速度更快。

与正则表达式的重要区别是：
- 不允许对`()` 包含的捕获组使用任何模式运算符。
- 模式匹配使用尖括号`<>`包含非捕获组，非捕获组可以嵌套，但不能包含捕获组。

请参考：[模式匹配快速入门](pattern-matching.md)

查找字符串示例

```aardio
var str = "abc 123";
var letters, numbers = string.match(str, "^(\a+)\s+(\d+)$");
print(letters, numbers)
```

替换字符串示例：

```aardio 
var str = "1hello 2world";
//将每个单词前面的数字移动到单词后面
str = string.replace(str, "(\d)(\a+)","\2\1");
print(str)
```

注意在替换字符串中 `\1` 到 `\9` 表示向前引用捕获组。


## 日期时间

```aardio
//获取系统运行毫秒数
var tk = time.tick();

//获取当前时间
var now = time()

/*
创建时间对象。
- 参数 @1 可以是数值时间戳，字符串
- 参数 @2 指定时间格式化串，省略则默认为'%Y/%m/%d %H:%M:%S'，字符串解析为时间的规则宽松，空白、标点、字母、中文等都可以匹配任意个数同类字符。忽略首尾不匹配的字符以及完整日期后不匹与的字符。
- 可选用参数 @3 指定格式化语言，例如 "enu"
*/
var tm = time("2017-05-27T16:56:01Z",'%Y/%m/%d %H:%M:%S') 

//自时间戳（秒）创建时间对象
var tm2 = time(123456)

//转换为 UTC 时间
var tm3 = tm.utc(true)

//解析 RFC 1123 格式，RFC 850 格式时间
var tm3 = time.gmt("Sun,07Feb2016 081122 +7")

//解析 ISO8601 时间
var tm4 = time.iso8601("20170822 123623 +0700")

//解析 ISO8601 时间（14 位数字或 12 位数字）
var tm5 = time("20170822123623")

print(tm5);
```

  
##  if 语句

```aardio
var enabled = true;

if (enabled) {
	print('enabled 的值为 true');
}
```

注意在条件判断中，非 `0`、非 `null`、非 `false` 为 `true`，反之为 `false`。

如果要准确判断一个变量的值是否为 `true` 或 `false` ，则应使用恒等操作符，如下：

```aardio
import console;
var enabled = false;

if (enabled === false ) {
  console.log('enabled 的值为 false，不是 0，也不是 null');
}
elseif( enabled ){
  console.log('enabled 的值为真');
}
else{
  console.log('enabled 值为：',enabled);
}

console.pause(true);
```

上面的 `elseif` 也可以改为 `else if`。

##  逻辑操作符

逻辑非操作符可以使用 `not` 或 `!` 。

逻辑与操作符可以使用 `and`  、`&&` 或者 `?` 。

逻辑或操作符可以使用 `or` 、 `||` 或者 `:`  。

为了兼容其他语言的习惯,aardio 提供了多种逻辑操作符的写法。

##  三元运算符

```aardio
var n = 1;

// ret 值为 true
var ret = n ? true : 0;
```

要特别注意 `?` 实际上是逻辑与操作符，`:` 实际上是逻辑或操作符。如果 `a ? b : c` 这个表达式里 `b` 为 `false`，则该表达式总是返回 `c`。这与其他类 C 语言的三元操作符不同，请注意区分。

  
##  定义函数

```aardio
//定义函数:
var add = function(a, b) {
  return a + b,"支持多个返回值";
}


//调用函数
var num,str = add(1, 2);


/*
要特别注意，函数可以返回多个值。
可以用 () 将多个返回值转换为单个调用参数。
*/
var str = tostring( ( add(1, 2) )  );
```

> 需要注意的是: aardio 函数的默认参数只能是布尔值、字符串或数值,其他类型的默认值需要在函数体内部进行处理。

## for 循环语句（ Numeric for ）

aardio 使用基于数值范围的 for 循环语法（Range-based for）。

`for` 循环语句基本结构：  
  
```aardio
for(i = initialValue;finalValue;incrementValue){
    //循环体
}
```  

- 可选用 `()` 包含循环条件，可选用分号或逗号分隔循环参数。
- 循环体可以是用 `{}` 包含的语句块，也可以是一个单独的语句。
- 循环变量 `i` 的值从 `initialValue` 开始，到 `finalValue` 结束（包含 `finalValue` ），每次递增 `incrementValue`。
- 循环增量 `incrementValue` 用可负数表示递减循环，省略则默认为 1 。 
- `finalValue` 必须是确定的数值 。

【重要】 **aardio 使用基于数值范围的 `for` 循环，所有循环参数都必须是数值表达式，不支持`条件（condition-expression）`和`迭代（iteration-expression）`。** 

示例：  

```aardio
import console;

// 循环变量 i 从起始值 1 循环到终止值 10 ，每次递增步长为 2。
for(i=1;10;2){ 
    
    // 在控制台输出 1,3,5,7,9
    console.log(i); 
}

// 循环变量 i 从起始值 1 循环到终止值 10 ，每次递增步长为 1。
for(i=1;10;1){
        
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

参考：[for 循环语法](../../language-reference/statements/looping.md#numeric-for)

##  for in 泛型循环语句（Generic for）

```aardio
var tab = {
	a = 123;
	b = 456;
}

//遍历表对象的所有键值
for(k,v in tab){
	print(k,v)
}
```

参考：[for in 语句与迭代器](../../language-reference/statements/iterator.md)

##  while 循环语句

```aardio
var i = 0;

//i 的值小于 100 时循环执行代码
while (i < 100) {  
    i++;
    print(i);
   
    if(i==10){
        break; //i 的值等于 10 时中步循环
    }
}
```

##  while var 语句

```aardio
import console;

//用法 1: 
while(
    var i; //初始化循环变量
    i =  console.getNumber( "请输入数值,输入100退出:" ); //每次循环前要执行的单个语句
    i != 100  //循环条件表达式
    ) {
    console.log( i )
}


//用法 2: 仅保留一个 var 语句，其他参数省略。
while(
    var i =  console.getNumber( "请输入数值,输入0退出:" )
    ) {
    console.log( i )
}



//用法 3:  省略 var 语句（分号不能省略）
var i = 0;
while( ;i++; i<10 ) {
    console.log(i)
}

//用法 4: 仅保留循环条件表达式
while(i>0){
    i--;
    console.log(i);
}


console.pause(true);
```

参考：[while var 语法](../../language-reference/statements/looping.md#while-var)


##  类

```aardio
import console;

//定义类
class className{
	
	//构造函数
	ctor(name,...){ 
		//通过  this 对象访问类的实例属性
		this.property = "property value"; 
		
		this.args = {...}; 
	};
	
	//属性
	property = "value";
	
	//定义方法(成员函数)，必须写为名值对格式，不能省略等号或 function 关键字。
	method = function(v){
		if(v===null){
			//在类内部可以直接访问类名字空间的静态成员
			v = staticProperty; //等价于 self.staticProperty
		}
		
		//访问外部全局名字空间必须加上 .. 前缀
		..console.log("method",v);
		
		this.property = v; 
	}
}

//打开类的名字空间
namespace className{
	
	staticProperty = "类的静态变量值";
	
	staticMethod = function(){
		..console.log("staticMethod",staticProperty);
	} 
}
	
//调用类创建对象
var object = className();

//调用对象的方法（成员函数）
var v = object.method("新的属性值");

//通过类名访问类的名字空间，通过类名字空间访问类的静态成员
className.staticMethod();

console.pause();
```

- 类内部可以用 `this` 访问当前实例对象。
- 类总是先调用构造函数 `ctor` 然后再初始化其他成员。
- 类有自己的名字空间，类创建的所有实例共享同一名字空间，类名字空间的成员也就是类的静态成员。

## self,this,owner 对象

`self` 表示当前名字空间。

`this` 在类内部表示当前创建的实例对象。

每个函数都有一个隐式传递的 `owner` 参数。如果用点号 `.` 作为成员操作符获取并调用对象的成员函数（ ownerCall 方式 ），则点号前面的对象是被调用成员函数的 `owner` 参数，否则被调用函数的 `owner` 参数为 `null`。 

示例：

```aardio
obj = {
	method = function(a,b){
		print("owner,a,b",owner,a,b);
	}
}

//这样调用（ ownerCall 方式 ）时 owner 参数指向 obj
obj.method(123,456)

//这样调用时 owner 参数为 null
obj["method"](123,456)
```

一个独立的 aardio 代码文件编译后也相当于一个匿名的函，其 `owner` 参数默认为 `null` 。使用 `import` 语句加载库文件时， `owner` 参数为库路径或资源文件数据（ 如果是编译后的内嵌库则 owner 指向资源文件 ）。

`owner` 在元方法中表示左操作数。

在迭代器函数中， `owner` 表示迭代目标对象。

aardio 允许用 `call`, `callex`, `invoke` 等函数调用其他函数并改变 `owner` 参数的值。

请参考： [owner 参数](../../language-reference/function/owner.md)