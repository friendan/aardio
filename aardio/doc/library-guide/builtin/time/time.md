# time 库

日期时间函数库，这是自动导入的内置库。

## time 时间对象 

time 结构体用于表示日期时间对象，其声明如下：

  
```aardio
class time{
    WORD year; //年
    WORD month;//月
    WORD dayofweek; //星期
    WORD day; //日期
    WORD hour; //小时
    WORD minute; //分钟
    WORD second; //秒
    WORD milliseconds;//这个字段正常情况下为0，只有在WinAPI函数中会起作用
    format = "%Y/%m/%d %H:%M:%S"; //时间格式字符串 
}
```  

time 结构体兼容 WinAPI 的 SYSTEMTIME 结构体、兼容 COM 接口日期时间对象。 可在 WinAPI 函数，COM 函数中直接使用。

## 创建时间对象

函数原型：

`dateTime = time( strOrTimestampOrTableOrTime,format,locale);`

函数说明：

构造并返回时间对象。  
参数@1可以是表示时间的数值、字符串、参数表、或其他 time,time.ole 对象。

参数 @1 可以用一个普通的表指定部分时间字段，也可以传入另外一个需要复制的 time 或 time.ole 对象。time 将会构造一个新的日期时间对象并返回。

不指定参数@1默认初始化为当前时间。

可选用参数@2指定格式化串，格式化串的首字符为`!`表示 UTC 时间。省略格式串时默认值为'%Y/%m/%d %H:%M:%S'，可兼容解析 ISO8601 格式时间。

格式化串有两个作用：

- 将返回的时间对象转换为字符串时会使用格式化串指定的格式与规则。
- time 对象的第一个构造参数为文本时，则依据第二个参数 @format 指定的格式化串解析获取时间。

可在创建时间对象以后使用 format 属性修改格式化串。

请参考：[日期时间格式化语法](#format)

可选用第三个参数 @locale 指定对象文本格式化使用的区域语言。 locale 支持的参数与 setlocale 相同，例如英文为 "enu", 简体中文为"chs" 。也可以在时间对象的 locale 属性指定格式化使用的语法，如果不指定则使用默认的区域设置 - 默认区域设置可使用 setlocale()函数进行设置，例如 `setlocale("all","chs")` 或 `setlocale("time","chs")` 应用简体中文格式化,而使用 `setlocale("time","enu") `应用英文语言格式化时间。

![](icon/info.gif) 格式化串如果将 `!` 作为第一个字符表示使用 UTC 标准时间，否则使用本地区域时间。UTF 时间可以使用时间对象的 local() 函数转为本地时间，而本地时间可以使用对象的 utc() 函数转换为 UTC 时间。  

不同参数用法：

- time() 

    不指定任何参数创建时间对象则默认初始化为当前时间。 

    不指定参数@1 在 milliseconds 字段返回毫秒数，且 dayofyear 字段无效,
    参数@1指定其他参数时 milliseconds 字段总是为 0

- time( timestamp )

    自时间戳创建日期时间对象。

    参数 @1 用一个数值指定时间戳 - 也就是自 UTC 时间 1970年1月1日 00:00:00 到 3000年12月31日23:59:59 之间的秒数。

- time( str,format )

    使用字符串参数 @format 指定格式化串。参数 @format 指定的格式与规则解析参数 @str 指定的字符串解析时间对象，支持自 1900年1月1日 到 9999年12月31日 的时间。
    
    自文本解析时间以尽可能宽松的规则识别时间。
    格式串中不是`%`前导格式化字符、分隔符不要求精确匹配。
    格式化时间时宽松处理所有空格，无须考虑空白字符的严格匹配.

    如果输入文本中的时间数值超出日期范围，则返回 null 。
    但如果出现当月不存在的日期且小于 31 号时会顺推为下月时间。

    如果格式化解析时间时输入文本提前结束，返回 null。
    创建对象后可通过 format 属性单独修改输出时间格式。 

    请参考：[日期时间格式化语法](#format)


返回值说明：

返回的时间对象可传入其他线程使用。 

返以回的时间对象可作为调用 tonumber 的参数转换为自 UTC 时间 1970年1月1日 00:00:00 到 3000年12月31日23:59:59 之间的秒数。需要更宽的运算范围请使用 time.ole 对象。

返以回的时间对象可作为调用 tostring 函数的参数转换为字符串。

可选用参数@2指定格式化串,首字符为!表示 UTC 时间。
参数@1 为文本时，则依据参数@2指定的格式化串解析获取时间。
 

示例：
  
```aardio
//如果省略所有参数返回当前时间
var tm = time(); 

//自文本解析时间
var tm2 = time("2017-05-27T16:56:01Z",'%Y/%m/%d %H:%M:%S');

//格式化为字符串
var str = tostring(tm2); 
```  

## datetime类型转换: 转换为字符串或数值

  
```aardio
var tm = time();

//返回时间戳数值，以秒为单位
var n = tonumber(tm); 

//修改格式化串
tm.format = "%Y年%m月%d日 %H时%M分%S秒";

//返回格式化的时间字符串
var s = tostring(tm); 
```  

## 检测时间对象

可以使用 type.eq 函数检查两个时间对象是否相等。  
也可使用 time.istime 函数判断对象是否一个时间对象。  
  
type.eq 是严格判别类型，而 time.istime 是兼容性检测，只要拥有相同的结构体声明都会返回true。time.istime 检测返回为真的对象，同样意谓着可以通用于 COM 函数，API 函数，对于时间类型都会使用 time.istime 进行检测。

```aardio
import console; 
import time.ole;

var tm = time();

//输出 true
console.log( time.istime(tm) )

var oletm = time.ole(); 

//输出 true,兼容time对象
console.log( time.istime(oletm) )

//输出 false，不相等
console.log( !! type.eq(oletm,tm) )

console.pause(); 
```  

## 时间格式化语法 <a id="format" href="#format">&#x23;</a>


创建时间的time对象构造函数的第二个参数可以指定格式化字符串，不指定格式化串时默认值为'%Y/%m/%d %H:%M:%S'。 也可以在创建时间对象以后使用 format 属性修改格式化串。

![](../../../icon/info.gif) 格式化串如果将 `!` 作为第一个字符表示使用 UTC 标准时间，否则使用本地区域时间。UTF 时间可以使用时间对象的 local() 函数转为本地时间，而本地时间可以使用对象的 utc() 函数转换为 UTC 时间。 

 格式化时间时可以使用第三个参数指定格式化使用的语言， 例如 `tm = time(,"%a %B %Y %m %d  %H:%M:%S","enu")` 的最后一个参数"enu"找定了格式化时使用英文语言。中文则为"chs"，也可以在时间对象的 locale 属性指定格式化使用的语法，如果不指定则使用默认的区域设置 - 默认区域设置可使用 setlocale()函数进行设置，例如:setlocale("all","chs") 或 setlocale("time","chs") 应用简体中文格式化,而使用 setlocale("time","enu") 应用英文语言格式化时间。
 
 在格式化串中，每一个 `%` 号声明一个格式化标记，全部可用的格式化标记如下表：   `

- `%%` - 表示原始 `%` 字符。
- `%c` - 输出字符串时按当前区域首选的日期时间格式，因为这个格式具有不确定性，不应使用此格式解析输入字符串。 
- `%x` - 格式化输出字符串时使用当前区域首选的日期表示法，不包括时间，格式化输入字符串时等价于`"%m/%d/%y" `
- `%X` - 格式化输出字符串时当前区域首选的时间表示法，不包括日期，格式化输入字符串时使用`"%H:%M:%S" `
- `%a` - 当前区域星期几的简写（格式化输入字符串时忽略此字段遇到的错误） 
- `%A` - 当前区域星期几的全称（格式化输入字符串时忽略此字段遇到的错误） 
- `%b` - 当前区域月份的简写 %B - 当前区域月份的全称 
- `%d` - 月份中的第几天，十进制数字（范围从 01 到 31） 
- `%H` - 24 小时制的十进制小时数（范围从 00 到 23） 
- `%I` - 12 小时制的十进制小时数（范围从 00 到 12）
- `%m` - 十进制月份（范围从 01 到 12） 
- `%M` - 十进制分钟数 
- `%p` - 根据给定的时间值为 `am' 或 `pm'，或者当前区域设置中的相应字符串 
- `%S` - 十进制秒数 
- `%y` - 没有世纪数的十进制年份（范围从 00 到 99,解析文本时也兼容输入的4位年份） 
- `%Y` - 包括世纪数的十进制年份(解析文本时也兼容输入的2位年份) 
- `%Z` - 时区名或缩写 %w - 星期中的第几天，星期天为 0 
- `%W` -本年的第几周，从第一周的第一个星期一作为第一天开始，不应使用此格式解析输入字符串生成时间,此标记使用前需要调用 tm.addsecond(0) 函数刷新 tm.dayofyear 字段。 
%U - 本年的第几周，从第一周的第一个星期天作为第一天开始，不应使用此格式解析输入字符串生成时间,此标记使用前需要调用 tm.addsecond(0) 函数刷新 tm.dayofyear 字段。 
%j - 本年的第几天，十进制数（范围从 001 到 366），不应使用此格式解析输入字符串生成时间,此标记使用前需要调用 tm.addsecond(0) 函数刷新 tm.dayofyear 字段。   ``  

使用格式串解析文本并转换为时间时，除上述匹配时间的标记以外， 
其他分隔字符支持宽松的模糊匹配，规则如下：

- 格式串不是使用`%`前导的字符如果没有精确匹配到对应字符,  
则模糊匹配连续的标点、或连续的字母，或连续的宽字符（例如汉字）。  
  
- 忽略目标字符串空格，忽略目标字符串以数值表示的时间字段前的非数值字符。  

- 宽松处理所有空格，无须考虑空白字符的严格匹配.
  
- 支持 ISO8601 兼容的省略间隔符的写法（即使格式串中指定了间隔符）  
省略间隔符时年月日组合的数值必须为8位或6位，其中月、日必须是两个数字，  
时分秒连写时每个部分都必须是两个数字。  
  
如果输入文本中的时间数值超出日期范围，则返回 null 。但如果出现当月不存在的日期且小于 31 号时会顺推为下月时间。 如果格式化时间未完成，但输入文本提前结束则返回 null 。 

如果最后一个格式化标记解析成功以后如果还有剩余的字符串， 首先跳过前面的空白字符，从前面取其他连续的非空白字符存入时间对象的endstr属性内。endstr可用于后续解析 ISO8601 等格式的时区，可参考 builtin 库中 time.iso8601 函数的源码。

下面是一个使用格式化代码的示例：

  
```aardio
import console;

//从字符串创建时间值
var tm = time("2006/6/6 12:56:01","%Y/%m/%d %H:%M:%S");

//改变格式化模式串
tm.format = "%Y年%m月%d日 %H时%M分%S秒";

//从时间值创建字符串
var str = tostring(tm);

//打印结果到控制台窗口
console.log(str);

console.pause();
```  

## 时间的加减运算

时间对象可以使用 tonumber 函数转换为以秒为单位的数值( time.ole 对象则转换为以天为单位的数值) 进行运算。

我们也可以直接使用 time 对象提供的方法进行加减运算。

  
```aardio
import console;
var dateTime = time.now();

dateTime.year += 2;
console.log(dateTime,"增加2年")

dateTime.addsecond(30)
console.log(dateTime,"增加30秒")

dateTime.addminute(180)
console.log(dateTime,"增加180分")

dateTime.addhour(2)
console.log(dateTime,"增加两小时")

dateTime.addday(365)
console.log(dateTime,"增加365天")

dateTime.addmonth(-24)
console.log(dateTime,"倒退24个月")

var tm2 = time.now()

//计算相差时间
console.dumpJson(
	相差月份 = tm2.diffmonth(dateTime);
	相差天数 = tm2.diffday(dateTime);
	相差小时数 = tm2.diffhour(dateTime);
	相差分钟数 = tm2.diffminute(dateTime);
	相差秒数 = tm2.diffsecond(dateTime);
	相差秒数2 = tonumber(dateTime) - tonumber(tm2); 
) 

console.pause();
```  

使用 add... 系列函数修改时间将自动计算并更新时间对象的所有字段。

而直接指定时间对象的部分字段，aardio 不保证时间的合法性，也不会自动更新 dayOfWeek 字段，也可以主动调用 tm.update() 函数重新计算时间并更新该字段。

## datetime 的关系运算

```aardio
import console;

var dateTime = time.now();
dateTime.year += 2;

var tm2 = time.now(); 

//关系运算
console.dumpTable( 
	相等 = tm2 == dateTime;
	大于 = tm2 > dateTime;
	小于等于 = tm2 <= dateTime;
)

console.pause()
```  

## time 对象 在 WinAPI 函数中的运用

  
```aardio
//创建 UTC 时间
var dateTime = time.utc();

//调用 API 函数
::Kernel32.GetSystemTime(dateTime);
```