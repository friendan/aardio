# 判断语句

参考：

- [等式运算符](../operator/equality.md) 
- [逻辑运算符](../operator/logical.md) 
- [关系运算符](../operator/comparison.md)
- [布尔值](../datatype/datatype.md#boolean)
- [隐式数据类型转换](../datatype/datatype.md#type-coercion)

## if 语句

if 语句包含条件判断部分、执行代码部分。 

执行代码部分可以是一句代码（不能是单个分号表示的空语句），或者一个[语句块](blocks.md)。

而 if 语句将条件表达式返回的结果与布尔值 true 进行比较，比较使用[等式运算符](../operator/equality.md)( 支持自动类型转换、` _eq` 元方法 )。

if 语句可选包含任意多个 elseif 分支判断语句，可选在最后包含一个 else 语句。

if 语句可以嵌套使用。

一个标准的 if 语句示例:  

```aardio
import console;

var a=1;

if(b==1){
	if(a==1)  {
		console.log("if");
	}
}
elseif(a==11){
	console.log("elseif");
}
else{
	console.log("else");
}

console.pause();
```  

> 注意：上面的 `elseif` 如果改为 `else if` 相当于在 `else` 语句嵌套了一个新的 if 语句，这通常是不必要的。

## select case 语句

select 指定一个选择器变量或表达式，case语句列举不同的值或条件值，第一个符合条件的 case 语句将会执行（执行第一个符合条件的 case 语句以后退出 select 语句，不会连续执行多个 case 语句）。

![](../../icon/info.gif) case 语句默认调用[恒等式运算符](../operator/equality.md)进行比较。也可以自行指定操作符。  

例如：  

  
```aardio
import console;

var a = 0;

select( a ) {

    case 1 { //判断 1===a 是否为真 
        console.log("a==1")
        //其他代码
    }
    case 1,9,10 {  //判断 a　是否其中的一个
        console.log("a是1,9,10其中之一")
    }
    case 10;20 { //判断 ( 10<=a and a <=20 ) 是否为真
        console.log("a在10到20的范围")
    }
    case !=0{ //判断 a是否不等于0，这是自已指定关系运算符的示例
        console.log("a不等于0")
    }
    else{ //所有条件不符时执行else语句块
        console.log("a是其他值(0)")
    }
}
```  

select case 语句也可以嵌套使用，但 select case 语句嵌套写的可读性不是很好，一般应当避免。