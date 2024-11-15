# 中文分词与分句

## 使用 mmseg 实现中文分词 <a id="mmseg" href="#mmseg">&#x23;</a>


mmseg 是一个轻量简洁的中文分词组件（对英文使用空格与标点自然分词），调用示例：

```aardio
import console;
import mmseg;

console.open();

var str = /*
MMSEG（Maximum Matching Segmentation）是一种高效的中文分词算法，它采用了最长匹配原则，能够有效地处理歧义问题，适用于多种应用场景，如搜索引擎、信息检索等。
*/

for word,attr in mmseg.each(str){
    console.writeText( word," " );
    sleep(100)
}
 
console.pause();
```

mmseg.each 接受一个输入文本参数并创建一个分词迭代器，用于循环分词。

循环变量 word 为分词结果，attr 为词的属性。

attr 是一个用字节码表示的数值，中文多字词的默认值为 `'@'#`，单字的值为 0，英文字词 attr 的值为 `'e'#`。我们可以在词库中的多字词后面加一个字格再加一个标点符号可以预定义一个词的 attr 。

可以使用 mmseg.loadChars 函数加载字库，使用 mmseg.loadWords 函数加载词库。mmseg 已经加载了默认的字词库，但 mmseg.loadChars 与 mmseg.loadWord 会自动忽略不存在的文件，所以可以根据需要删除或替换字词库。要特别注意字词库要自行除重，尽量不要加入重复的词，这样会导致分配多余内存。

改用 mmseg.list() 函数可以对输入文本进行分词，并直接得到分词后的文本数组，示例：

```aardio
import mmseg;

var text = "研究生命起源";
var words = mmseg.list(text);
```

## 使用 string.sentences 实现文本分句 <a id="sentences" href="#sentences">&#x23;</a>


分句指的是文本拆分为一个个语意相对独立的语句。

aardio 提供了 string.sentences 可用于中英文的文本分句，示例：

```aardio
import console; 

var text = /*
例如这句要独立成句：“分句算法需要能够识别并处理各种标点符号，包括逗号、句号、感叹号等。” 
“这是引号包含的内容” 类似这样的句子也要独立成句。

英文缩写，前后引用，多重引号。

"It's amazing!" he said. "I can't believe it."
What is the use of ''say,'' ''said'', and ''says''? 
 
考虑各种松散写法。。。。。
考虑各种写法！！！

考虑这种嵌套包含的引号：“这里面又有一层相同的“引号”，要正确处理这种对称匹配的引号”。
*/

import string.sentences;
for( i,v in string.sentences(text)){
	console.log(v)
	sleep(200);
}

console.pause()
```

string.sentences 的参数指定一个输入文本，返回值为拆分后的句子组成的字符串数组。

string.sentences 的返回数组定义了 _call 元方法，因此也可以直拉作为 for in 语句的迭代器使用。