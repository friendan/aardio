# 随机数、随机字符串

## 随机字符串

`str = string.random( len [, seed] )  `
  
返回长度为 len 的随机字符串，seed 为可选参数指定供随机选择字符的字符串(默认值为英文字母、数字)。  
seed 参数可以使用中英文字符。

```aardio
import console; 
console.log( string.random(10  ) )
console.log( string.random(10 ,"seed参数可以使用中英文字符。") )
```  

`str = string.random( str [, str2[, ...] ] )  `
  
参数为多个字符串，随机选择其中一个字符串并作为返回值。


```aardio
import console;  
console.log( string.random( "待选字符串","待选字符串2","待选字符串3") );
```  

## 随机数

`n = math.random(min,max)`

指定最小随机数 min，最大随机数 max，返回 \[5,99\] 之间的随机数，如果不指定参数返回(0,1)之间的小数。  

## 随机数发生器

`math.randomize(随机数发生器种子)  `

用于改变随机数队列的函数。

math.randomize 的参数可以是一个任意的数值，省略参数时，则自动生成一个安全的随机数作为随机数种子。

aardio 程序在启动时，主线程会以 time.tick 获得的系统启动毫秒数作为参数调用一次 math.randomize。  

在创建新的线程时也会自动调用 math.randomize，但不会使用系统启动毫秒数作为参数，而是自动生成一个安全的随机数作为随机数种子。