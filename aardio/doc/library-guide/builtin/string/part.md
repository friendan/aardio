# 拆分合并

请参考：[数据类型 - 字符串](../../../language-reference/datatype/datatype.md#varstring) [字符串连接操作符](../../../language-reference/operator/concat.md)

## 截取字符串

1.  string.slice

    原型：

    `substr = string.slice(str,i,j=-1,chars=false );`  

    说明：
      
    从字符串中截取从位置i到位置j的字符串，j为可选参数。  
    如果i,j为负数，则从右侧倒数计数(-1表示字符串最后一个字符)。 如果i,j没有指定一个有效的截取范围，则返回一个空字符串(而不是null);  
      
    最后一个参数 @chars 是可选参数,默认为 false,  
    该参数影响计数方式,如果为 false 则按字节计数，汉字有多个字节(注意UTF-8是变长编码) 。如果为 true , 则按字符计数,一个汉字计为一个字符.  

    示例：

    ```aardio
    import console;
    console.log(string.slice("abcdefg",-5,-4) )
    ```  

2.  string.left

    原型：

    `substr = string.left(str,n,chars=false);  `

    说明：
      
    在字符串左侧截取n个字符,如果n没有指定一个有效的截取范围，  
    则返回一个空字符串(而不是null);  
      
    参数chars如果为false则按字节计数,一个汉字有多个字节.  
    如果为true,则按字符计数,一个汉字计为一个字符.  

3.  string.right

    原型：

    substr = string.right(str,n,chars=false);  

    说明：
      
    在字符串右侧截取 n 个字符,如果 n 没有指定一个有效的截取范围，则返回一个空字符串(而不是null);  
      
    参数 chars 如果为false则按字节计数,一个汉字有多个字节.  
    如果为true,则按字符计数,一个汉字计为一个字符.

## 清除字符串首尾字符

1. string.trim

    原型：

    `substr = string.trim(str\[,space\]);  `
      
    说明：

    去掉字符串首尾指定字符，可以指定单个字符，或一组需要在首尾去掉的字符组成的字符串。  如果省略space参数，则清除所有空白字符，包含空格(' ')、制表符('\\t')、回车('\\r')、换行('\\n')、垂直制表符('\\v')或翻页('\\f') 等。

2. string.trimleft

    原型：

    `substr = string.trimleft(str\[,space\]); ` 
      
    说明：

    去掉字符串开始的指定字符，可以指定单个字符，或一组需要在首尾去掉的字符组成的字符串。  
    如果省略space参数，则清除所有空白字符，包含空格(' ')、制表符('\\t')、CR('\\r')、换行('\\n')、垂直制表符('\\v')或翻页('\\f') 等。

3. string.trimright

    原型：

    `substr = string.trimright(str\[,space\]);  `

    说明：
      
    去掉字符串尾部的指定字符，可以指定单个字符，或一组需要在首尾去掉的字符组成的字符串。  
    如果省略space参数，则清除所有空白字符，包含空格(' ')、制表符('\\t')、CR('\\r')、换行('\\n')、垂直制表符('\\v')或翻页('\\f') 等。

## 拼接字符串

原型：

`string.concat(str,str2[,...])  `

说明：
  
拼接字符串，与 ++ 连接操作符不同的是:  
string.concat会忽略null值,而使用++操作符连接null空值时会抛出异常。  
如果无参数,或所有参数为null,string.concat返回null.  
  
如果需要连接多个字符串，而允许其中有null参数,  
可以使用string.concat替代连接操作符

## 拆分字符串数组 <a id="split" href="#split">&#x23;</a>


原型：

`string.split(str,separator,maxLength)  `
  
拆分字符串并返回[数组](../../../language-reference/datatype/table/_.md#array)。

说明：

str 参数指定要拆分的字符串。  
separator 参数可使用字节码或字符串指定分隔符。  
maxLength 则用于限定反回数组的最大长度，默认不指定则不限制返回数组长度。  

1. 按单字符拆分  

    separator 参数为置于单引号中的单个字符，这是速度最快的拆分方法  

    示例：

    ```aardio
    import console;

    var str = "123ab456ab789ab";
    var t = string.split(str,'a'); //使用单个分隔字符拆分字符串

    console.log(table.unpack(t) );
    ```  

2. 按多个分隔字符(分隔串)拆分 
  
    separator 参数为包含多个分隔字符的普通字符串，分隔符与分隔符之间返回空元素  

      
    示例：

    ```aardio
    import console;

    str = "123ab456ab789ab";
    t = string.split(str,"ab"); //使用分隔串"ab"拆分字符串

    console.log( #t ); //数组长度为6
    console.log(table.unpack(t) );
    ```  

3. 按字符串拆分
  
   separator 参数为普通字符串，此字符串被包含在`<>`括号内，作为一个独立整体的分隔标记. 注意，虽然 `<>` 在这里的语义与模式匹配语法相同，但 string.split 并不支持其他模式语法。  

      
    示例：
    
    ```aardio
    import console;

    str = "123ab456ab789ab";
    t = string.split(str,"<ab>"); //使用完整字符串"ab"为分隔符拆分

    console.log( #t ); //数组长度为3
    console.log(table.unpack(t) );
    ```  

## 使用模式匹配拆分字符串数组 <a id="splitEx" href="#splitEx">&#x23;</a>


原型：

`string.splitEx(str,separator,maxLength,position)  `
  
使用[模式匹配](patterns.md)拆分字符串并返回[数组](../../../language-reference/datatype/table/_.md#array)。

说明：

- 参数 str 指定要拆分的字符串，传入 null 值或空字符串返回空数组。  
- separator 使用模式匹配指定文本分隔符。

    省略分隔符模式则默认按行拆分，兼容回车、换行、回车换行等不同换行风格，空行不合并。

    分隔符模式串可用括号创建捕获组，首个捕获组如下处理：
    - 模式串尾部有 $ 符号，则捕获组放到上个拆分结果尾部。
    - 模式串头部有 ^ 符号，则捕获组放到下个拆分结果头部。
    - 模式串头部有 ^ 符号并且尾部有 $ 符号，则捕获组作为单独的拆分结果添加到返回数组中。如果将分隔符加入拆分结果，则每次拆分至少会增加 2 个拆分元素，如果同时指定了限定返回数组长度的 maxLength 参数则会自动对齐为奇数。
- maxLength 则用于限定返回数组的最大长度，默认不指定则不限制返回数组长度。  
- position 指定允许字符最早出现的位置 ，以字节为单位 。不指定此参数则不作限制，默认从开始拆分。

string.lines 封装了 string.splitEx 函数并提供了一个用于 [for in](../../../language-reference/statements/iterator.md) 语句的迭代器，主要增加了以下功能：

- 除了可以指定行分隔符，还可以选择指定列分隔符以进行二次拆分。
- 当模式串模式串头部有 `^` 符号并且尾部有 `$` 符号时，捕获组会作为单独的拆分结果由迭代器返回为第一个循环变量，此时迭代器返回的第二个循环变量为 true 以表明这是一个分模式串头部有 `^` 符号并且尾部有 `$` 符号， 则捕获组将由迭代器返回为单独的拆分结果，紧随其后的第二个返回值为 true 以表明该拆分结果是一个分隔符。调用代码格式为  `for line,isSeparator in string.lines(str,"^(分隔符)$"){ }` 这个特性被用于实现文本分句的 [string.sentences 库](../../../library-reference/string/) 。

参考： [文本解析函数 string.lines](parsing.md#lines)


## 字符串数组合并

原型：

string.join(tab,sep)

说明：

将一个字符串数组([table对象](../../../language-reference/datatype/table/_.md)）以sep指字的分隔标记合并为一个字符串

示例：
  
```aardio
import console;

tab = {"ab";"cd";"efg"}
str = string.join(tab,"分隔符");

console.log( str );
```