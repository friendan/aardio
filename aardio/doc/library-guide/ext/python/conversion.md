
# aardio 与 Python 类型转换


## 类型转换规则
 

- 兼容的纯值类型：

    Python 返回的浮点数值、不大于 53 位的整型数值、布尔值、字符串、字节数组会自动转换为对应的纯 aardio 值，同样反过来 aardio 这些类型的值也可以自动转换为对应的 Python 类型。

- pyObject 对象：

    除了纯值以外的其他 Python 对象在 aardio 中存为 py3.object 对象（ 简称 pyObject ）。如果是 py2 扩展库就是 py.object ，原理与用法都相同。

## 使用纯值

示例：

```aardio
import console;  
import py3;
 
//导入 Python 模块
var math = py3.import("math");

//调用 Python 函数，  
var num = math.floor(22.3);

//在控制台输出数值。 
console.log(num);

console.pause();
```

非常简单。

## 使用 pyObject

pyObject 也可以在 aardio 中也可以像普通对象一样使用。
可以调用 pyObject 的成员函数、读写其属性、通过下标读写索引项、并支持各种常用运算符。

可通过 pyObject.parseValue() 函数转换为纯 aardio 值（通过 JSON 自动转换）。 

Python 对象（ pyObject ）在 aardio  中与类型转换有关的函数：

- `pyObject.parseValue()` pyObject 转换为 aardio 表对象
- `table.parseValue(pyObject)`pyObject 转换为 aardio 表对象
- `tostring(pyObject)` pyObject 转换为 aardio 字符串
- `tonumber(pyObject)` pyObject 转换为 aardio 数值 
- `pyObject.toString()` pyObject 转换为 aardio 字符串
- `pyObject.toDict()` pyObject 转换为字典，返回 py3.dict 字典对象
- `pyObject.toList()` pyObject 转换为字典，返回 py3.list 列表对象
- `pyObject.toTuple()` pyObject 转换为字典，返回 py3.tuple 元组对象
- `pyObject.type()` pyObject 返回 Pythton 类型名

aardio 中的 py3.dict,py3.list,py3.tuple  都继承自 py3.object ，本质都是 pyObject 对象（指 py3.object ）。

最常用的函数 pyObject.parseValue，示例：

```aardio
import console;
import py3; 

var pyCode = /** 
def getList(a,b):   
    return a,b,123 # Python 多返回值实际是返回一个 tuple
**/

py3.exec( pyCode ) 

//从 py3.main 模块调用 Python 代码定义的函数 
var pyList = py3.main.getList(12,23);

//pyObject 转换为纯 aardio 值
var list = pyList.parseValue() 
console.dump(list);  

/*
list 或 tuple 可用下标访问，
注意 Python 对象起始索引为 0，aardio 数组起始索引为 1。
*/
var num = pyList[0];

//可以如下遍历 pyObject 对象。
for( pyItem in pyList.each() ){
	console.log(pyItem) //基础类型已转换为纯 aardio 值，其他为 py2.object
}

console.pause();
```