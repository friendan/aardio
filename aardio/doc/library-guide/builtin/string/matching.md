# 模式匹配函数

请参考：[模式匹配语法](patterns.md)

## 一、查找字符串位置 <a id="find" href="#find">&#x23;</a>

1. string.find 函数原型：

    `i,j = string.find(str, pattern [, pos [, chars ] ])`

2. 说明：

    使用第二个参数 @pattern 指定的模式串查找第一个参数 @str 指定的字符串并返回起始位置(i),结束位置(j)。

    此函数支持 [模式匹配语法](patterns.md) 。如果需要禁用模式语法，请在模式串开始添加 `@` 字符，或者使用[不使用模式匹配语法的查找字符串函数](search.md)。  

    可选用第三个参数 @pos 指定搜索开始的位置（以字节计数），省略则使用默认值 1 。 @pos 如果为负数，则从右侧倒数计数(-1表示字符串最后一个字符)。 

    可选使用第四个参数 @chars 指定返回值是否以字符计数，设为 true 则返回值以字符计数，否则返回值以字节计数。注意，@pos 始终以字节计数。

    函数返回匹配字符串的起始位置 i ，结束位置 j 。如果查找失败, i,j 都返回 null 值。

3. 示例

    下面是一个简单的例子:

    ```aardio
    import console;

    var i,j = string.find("abc456d" ,"c\d+");

    if( i ) //如果找到i为大于0的数值
    console.log("在 'abc456d' 中找到 c\d+" ,"从" + i + "到" + j);

    if(not string.find("abcd" ,"不可能") ) 
        console.log("没有从 'abcd' 中找到 '不可能' ");

    console.pause();
    ```  

    string.find 会将所有的捕获组增加到返回值队列中。  

    示例：
    
    ```aardio
    var i,j,ab,cd = string.find ( "abcd" , "(ab)(cd)" ); 
    ```  

    每个捕获组都会增加一个返回字符串，返回值的前后顺序也就是模式串中捕获组的左圆括号出现的前后顺序。参考：[模式语法 - 捕获组](patterns.md#capturing-groups)


## 二、查找并返回字符串 <a id="match" href="#match">&#x23;</a>

1. string.match 函数原型：

    `string.match(str, pattern [, pos])`

2. 说明：

    第一个参数 @str 指定目标字符串，每二个参数指定 @pattern 查找模式串。第三个参数 @pos 可选指定开始位置（以字节计数）。 

    这个函数与 string.find 很象。但是返回匹配的开始位置与结束位置。而是返回找到的字符串。

    如果在模式串中用圆括号指定捕获组，则每个捕获组都会增加一个返回字符串。捕获组组可以相互嵌套，捕获组返回的顺序对应模式串中捕获组的左圆括号出现的前后顺序。如果你希望第一个返回值是匹配结果的完整字符串,那么请将整个模式串包含在一对圆括号内。

3. 示例：
  
    ```aardio
    var v,v2   = string.match("abcd", "(ab)(cd)"); 
    ```  

    如果模式串中未指定任何捕获组，则直接返回匹配到的字符串。

    示例：

    ```aardio
    //\d表示数字 \d+表示最长匹配多个数字
    var v = string.match("abcd1234", "\d+");
    ```  

## 三、遍历所有匹配的字符串 <a id="gmatch" href="#gmatch">&#x23;</a>

1. string.gmatch 函数原型：

    `iterator = string.gmatch(str, pattern)  `

2. 说明：
  
    string.gmatch() 创建并返回一个迭代器，可用于 for in 语句中迭代地进行全局模式匹配。

    迭代器每执行一次就返回该次匹配到的结果，返回匹配结果的规则与 string.match 相同。

    如果模式串中不指定捕获组，则每次匹配都返回匹配到的字符串。

    如果在模式串中用圆括号指定捕获组, 则迭代器的返回值有多个字符串并且分别对应所有捕获组。捕获组可以相互嵌套，捕获组返回的顺序对应模式串中捕获组的左圆括号出现的前后顺序。如果你希望第一个返回值是匹配结果的完整字符串,那么请将整个模式串包含在一对圆括号内。

    参考：[模式语法 - 捕获组](patterns.md#capturing-groups)

3. 示例：
  
    ```aardio
    import console;

    //for后面的变量对应查找模式串中的括号分组(有几对括号就有几个返回值)
    for str,int in string.gmatch( "abcd=1234 xyz=999","(\a+)=(\d+)")   { 
        console.log(str,int);
    }

    console.pause()
    ```  

    string.gmatch 的返回值是一个迭代器函数,每调用这个函数一次就会向后查找一个匹配直到查找失败。  

    参考：[泛型 for 与迭代器](../../../language-reference/statements/iterator.md)

## 四、替换字符串 <a id="replace" href="#replace">&#x23;</a>

### string.replace 函数

1. 语法：

    `str,count = string.replace (str, pattern, repl [, n])`  

2. 说明：

    第一个参数 @str 指定目标字符串。

    第二个参数 @pattern 指定搜索模式串，支持模式匹配语法。

    第三个参数 @repl 指定替换对象，可以是字符串、替换表、替换函数。
    
    第四个可选参数用于限定替换的次数，默认替换所有的找到的字符串。

    如果需要禁用模式语法，请在模式串开始添加 `@` 字符。

    函数返回值 str 为替换结果，返回值 count 为替换次数。

3. 示例：
  
    ```aardio
    import console; 

    //  在模式匹配中 .圆点标记匹配任意字符
    str = string.replace("abcd",".","k");
    console.log(str); //输出kkkk

    str = string.replace("abcd",".","k",1);
    console.log(str); //输出kbcd

    console.pause();
    ```  

### 替换表

string.replace 的第三个参数 @repl 可以指定一个替换表（ table 对象 ），每次匹配到字符串以后，就以匹配结果作为键名到替换表中查询对应的值，如果找到对应的值则执行替换。

示例：

```aardio
import console;
 
var str = string.replace("abcd","(.)",{
	"a" = "A",
	"c" = "C",
});

//结果是 AbCd
console.logPause(str); 
```

### 在替换串中引用捕获组
  
替换字符串中可以用 `\1,\2,\3.....\9` 等表示模式匹配后的捕获组引用。

请参考：[模式语法 - 捕获组引用](patterns.md#backreferences)

在替换串中引用捕获组的示例：
  
```aardio
import console; 

//在模式匹配中 .圆点标记匹配任意字符。
str = string.replace("abcd","(.)","\1k");

console.log (str); //结果是akbkckdk

console.pause();
```  

注意在查找串中可以引用的捕获组为 `\1` 到 `\9` ，
而在替换串中除了可以引用 `\1` 到 `\9` 的捕获组，还可以用 `\0` 完整的匹配字符串。

下面的 aardio 代码互换相邻的字符:

```aardio
str = string.replace("hello", "(.)(.)", "\2\1")
```  

### 使用替换回调函数

第三个参数 @repl 也可以指定一个替换函数。替换函数的回调参数为所有捕获组对应的字符串，如果没有捕获组则回调参数为每次匹配到的字符串。替换函数如果返回字符串则执行替换，如果返回 null 或者不返回值则不执行替换。

使用替换函数的示例：
  
```aardio
import console;

//如果两个捕获都是数字则相加，否则将位置前后掉换
function captureProc(a,b) { 
    console.log(owner,a,b); //owner 显示原始字符串
    if(tonumber(a) and tonumber(b) ) 
        return a + b;//如果两个捕获都是数字则相加
    else
        return b ++ a;//否则将位置前后掉换
}

str = string.replace("abcdef23","(.)(.)",captureProc);
console.log(str); //显示 badcfe5

console.pause();
```  

注意在替换函数中 onwer 参数指向原始字符串。

## 五、在不匹配模式的部分进行替换 <a id="replaceUnmatched" href="#replaceUnmatched">&#x23;</a>

如果我们希望在匹配指定模式的部分进行替换这很容易。

即使我们需要将复杂的模式匹配拆分为多次更简单的模式匹配这也很简单，我们只要在替换回调函数中再次调用 string.replace 即可，例如：

```aardio
var str,count = string.replace("abc123","\w+",function(text){
	
	return string.replace(text,"\d+","***");
})
```

但如果我们要在不匹配一个或多个模式的部分替换要，那就需要用到 string.replaceUnmatched 函数了。

函数原型：

 `str = string.replaceUnmatched(str, pattern, repl , keep1 [ , keep2, ... keepN ] )`  

 string.replaceUnmatched 的 str 参数指定要进行替换的源字符串，而 pattern 指定替换模式串，repl 参数指定替换对象，这些参数的用法与 string.replace 函数完全一样。 repl 参数同样可以指定替换字符串、替换表或替换回调函数。

 函数返回值 str 为替换结果，返回值 count 为替换次数，这与 string.replace 函数也完全一样。

 区别在于 string.replaceUnmatched 可用 keep1 到 keepN 参数使用模式匹配语法指定一个或多个需要排除部分的模式串。

 举个例子：

 ```aardio
var code = `
var tab = {};

// tab  
`

code = string.replaceUnmatched(code,"tab","tab2","//\N+");
```

上面的代码替换 tab 为 tab2，但是 "//\N+" 匹配的注释行将被排除在外不进行任何替换。


