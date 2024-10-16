# 数值与进制

aardio 中可使用自定义进制表示整数，可表示的有效整数范围在正负 `2**53 - 1 `之间。

aardio 也可以使用 [math.size64](../../library-guide/builtin/math.md) 对象表示 64 位无符号整数。

## 常用数值与进制表示法

```aardio
var hex = 0xA5; //0x 前缀表示一个十六进制数 
var dec = 10; //普通十进制数值,即使在前面加上 0 前缀仍然表示 10 进制数  
var num1 = 10.1; //小数
var num2= 6e+20； //科学计数法
var num3 = -10; //负数
var num4 = -0; //字面值常量-0自动转换为0,但运算得到的 -0 可以保持其值。
var num5 = 123_456; //数值中可以添加单个下划线作为分隔符（不能使用连续多个下划线，解析字符串为数值是不支持分隔符）。
```

## 自定义进制表示法

自定义进制语法:  

`var num = radix#number`
  
如果一个数值包含 `#` 号，则 `#` 号前面是自定义进制(大于等于 2 且小于 36 )，`#` 号后面是数值，10 以上的数用 `a-z` 范围的大小写字母表示。  

示例：

```aardio
var a = 2#010 //表示一个2进制数010  
var c = 36#Z7 //表示一个36进制数Z7
 
import console;  
console.log( 2#10000000000000000 /*aardio可以直接表示2进制数,1后面16个0*/ );
console.log( 2#10000000000000000  >>>  16 ,"65536右移16位变成了1")  
console.log( 2#1010_1100 ) //自定义进制的数值也可以使用下划线作为数值分隔符

console.pause();
```  

## 在字符串中使用数值与进制

在单引号包含的字符串中使用 `\` 转义符+数值表示字符。

```aardio
var str = '六进制字符 \x2A'; // \x 前缀表示一个十六进制字符  
var str3 = '十进制字符 \65'; // \ 前缀表示一个十进制字符
```  
  
参考：

- [数据类型-字符串](datatype.md#string)
- [字符串与编码](string.md)

## 格式化字符串函数中使用进制与数值  

string.format 函数支持以下与进制有关的格式选项

- `%b` 格式化为二进制数  
- `%x` `%X` 格式化为小写或大写十六进制数  
- `%o` 格式化为八进制数  
- `%d` 格式化为十进制数  
 
示例：

```aardio
import console;  
console.logPause( string.format("%X",123) )
```
参考： [格式化字符串](../../library-guide/builtin/string/format.md)

## 转换进制  

```aardio
import console; 

var str =  tostring(123,16) //转换为十六进制字符串
var num = tonumber(str,16) //将十六进制字符串转换为数值

console.logPause(
  "二进制",tostring( 123,2) ,
  "八进制",tostring( 123,8) ,
  "十六进制",tostring( 123,16) ,
  "十进制",tostring( 123 ) 
);
```  

将数值转换为字符串的 tostring() 函数,以及将字符串转换为数值的 tonumber() 函数,都可选使用第二个参数指定应用于转换的进制(2到36之间).