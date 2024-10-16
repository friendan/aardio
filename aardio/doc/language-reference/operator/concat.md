# 连接运算符

参考： [字符串](../datatype/string.md)

对两个操作数进行字符串连接操作。

如果操作数不是字符串，aardio 将尝试自动转换为字符串，如果转换失败则会报错。 
  

| 运算符 | 说明 |
| --- | --- |
| `++` | 连接运算符 |


![](../../icon/info.gif)引号（双引号、单引号、反引号）前后的 `+` 运算符将自动转换为字符串连接运算符 `++` 。

  
例如：

```aardio
import console.int; 

// str 为 “hello world” 
var str = "hello " ++ "world"; 

// str 为 "12"，表达式自动转换为 1 ++ "2"
var str = 1 + "2";   

// str 为数值 3，+ 与 " 号被括号分开
var str = 1 + ("2");

console.log(str);
```