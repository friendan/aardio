string帮助文档
===========================================
<a id="string"></a>
string 成员列表
-------------------------------------------------------------------------------------------------
字符串函数库

字符串函数库  
这是自动导入的内核库,  
[使用手册相关文档](chm://libraries/kernel/string/pattern%20matching.html)

<h6 id="string.bytes">string.bytes </h6>
 将字符记数转换为字节计数

<h6 id="string.bytes">string.bytes(字符串,字符数,开始位置) </h6>
 将字符记数转换为字节计数  
可选用参数@3指定开始位置，此参数以字节为单位,首字节开始为1  
如果遇到不合法的UTF8编码函数返回0

<h6 id="string.charAt">string.charAt </h6>
 返回UTF8编码的文本指定位置的字符,  
一个字符可能包含多个字节  
  
注意UTF8属变长编码，因此每次调用此函数都需要从文本开始计算字符位置,  
如果需要遍历所有字符,可使用string.split一次性拆分字符到数组,  
或调用string.toUnicode转换为UTF16字符串后再处理

<h6 id="string.charAt">string.charAt(字符串,字符位置) </h6>
 省略字符位置时默认值为1,1表示第1个字符,  
按字符计数而不是按字节计数,支持编码大于0x10000的字符

<h6 id="string.charCodeAt">string.charCodeAt </h6>
 返回UTF8编码的文本指定位置字符的Unicode编码,  
一个字符可能包含多个字节  
  
注意UTF8属变长编码，因此每次调用此函数都需要从文本开始计算字符位置,  
如果需要遍历所有字符,可使用string.split一次性拆分字符到数组,  
或调用string.toUnicode转换为UTF16字符串后再处理

<h6 id="string.charCodeAt">string.charCodeAt(字符串,字符位置) </h6>
 省略字符位置时默认值为1,1表示第1个字符,  
按字符计数而不是按字节计数,支持编码大于0x10000的字符

<h6 id="string.cmp">string.cmp(字符串,字符串2,比较长度) </h6>
 　参数可以是字符串或 buffer  
文本模式比较字符串前n个字符串大小,忽略大小写,忽略区域设置,  
从第一个字符开始比较,不相等或不支持比较的数据类型返回非0值,  
字符串1较大返回正数,字符串2较大返回负数  
比较长度是可选参数,默认为字符串长度  
仅比较纯文本,忽略'\0'以后的内容

<h6 id="string.cmpMatch">string.cmpMatch( __,"" ) </h6>
 忽略大小写比较两个字符串  
如果失败则使用模式语法匹配是否相同.  
如果其中一个参数不是字符串则返回false

<h6 id="string.collate">string.collate(字符串,字符串2) </h6>
 比较字符串,大小写敏感,相等返回0,  
字符串1较大返回正数,字符串2较大返回负数,  
排序受区域影响，使用setlocale函数改变区域设置  
该函数需要转换为UTF16比较，性能不及使用大于、小于等操作符直接比较字符串

<h6 id="string.concat">string.concat('字符串','字符串',...) </h6>
 拼接并返回字符串,支持任意个参数,  
允许参数中有null值,所有参数为null或无参数时无返回值,  
二进制模式拼接,不会被'\0'截断

<h6 id="string.concat">string.concat(buffer,'文本字符串',...) </h6>
 文本模式追加字符串到 buffer,buffer 请使用 raw.buffer 函数创建，  
如果需要使用二进制模式拼接字符串到 buffer，请使用 raw.concat() 函数  
  
可以追加任意个数的字符串参数，字符串参数也可以是null值。  
仅拼接'\0'以前的纯文本，超出 buffer长度的内容将被丢弃。

<h6 id="string.concatUnicode">string.concatUnicode(str,...) </h6>
 将所有参数转换为Unicode字符串并连接后返回  
参数可以是数值,字符串,Unicode字符串,  
忽略null值参数

<h6 id="string.crc32">string.crc32(字符串,crc32,长度) </h6>
 计算字符串的CRC32校验值  
参数一也可以是 buffer,  
可选使用参数@2指定前面字符串的校验值,以返回总的校验值  
长度为可选参数

<h6 id="string.crlf">string.crlf(字符串,回车换行) </h6>
 自动调用 tostring 函数转换传入参数为字符串,  
此函数格式化文本中的回车换行组合、或单独的回车、换行,  
例如 string.crlf(str,'\r') 格式化所有格式的回车换行为回车符。  
省略参数 @2 默认为回车换行组合。  
  
注意字符串字面值解析换行的规则:  
双引号或反引号内字符串只有换行没有回车,  
单引号内字符串解析时忽略所有回车换号,  
使用/*多行注释*/包含字符串,则总是解析为回车换行组合

<h6 id="string.each">string.each </h6>
 创建适用于 for in 语句的迭代器,  
用于分行匹配字符串,  
可将返回迭代器传入 table.array 生成数组

<h6 id="string.each">string.each(字符串,模式串,行分隔符) </h6>
 必须使用参数@2指定模式串,  
查找模式串中可用圆括号创建捕获分组自定义迭代器返回值个数,  
行分隔符支持模式匹配语法,可省略

<h6 id="string.endWith">string.endWith("字符串","结束串") </h6>
 判断结束串是否位于字符串结束处  
基于二进制模式

<h6 id="string.endWith">string.endWith("字符串","结束串",true) </h6>
 判断结束串是否位于字符串结束处。  
基于文本模式,忽略大小写

<h6 id="string.escape">string.escape </h6>
 转义字符串中需要转义的字符  
使用string.unescape函数可以还原转义

<h6 id="string.escape">string.escape(字符串) </h6>
 返回转义字符串，如果字符串不需要转义返回null  
如果参数@1指定 buffer,即使不需要转义也会返回字符串而不是null

<h6 id="string.escape">string.escape(字符串,兼容JSON,Unicode编码) </h6>
 返回转义字符串，如果字符串不需要转义返回 null,  
如果参数@1指定 buffer,即使不需要转义也会返回字符串而不是null,  
如果参数@2为true，即使字符串不需要转义也会返回字符串而不是null  
兼容JSON时参数1应当是UTF8、或UTF16编码文本,单引号转为\u0027,  
Unicode编码为true时所有非ASCII字符使用\uXXXX编码  
  
注意即使选择了不启用UNICODE编码，单引号，  
以及一些可能无法直接显示的Unicode字符仍然会进行转义

<h6 id="string.expand">string.expand </h6>
 重复替换直到找不到匹配,  
可用于展开字符串中的环境变量

<h6 id="string.expand">string.expand(字符串,查找模式串,替换函数) </h6>
 在字符串中重复执行替换操作,  
直到参数@2指定的模式串找不到匹配,  
省略参数@2,@3则默认展开百分号包含的进程环境变量  
可用于展开文件路径中的环境变量  
注意即使替换函数返回null,此函数仍然会替换为空串,  
如果替换结果为空字符串,此函数返回 null

<h6 id="string.find">string.find </h6>
 使用模式表达式在字符串中查找子串的位置，  
如果有多个捕获分组,将附加为多个返回值。  
如果只是查找普通查找建议使用string.indexOf函数  
类似的函数raw.find可以支持在内存指针中查找字符串

<h6 id="string.find">string.find("字符串","@查找文本",开始位置,返回值以字符计数) </h6>
 返回匹配结果的起始,结束位置  
查找文首字符为'@'或'@@'禁用模式语法  
首字等为'@'可选指定返回位置以字符计数  
'@@'则是'<@@...@>'的缩写形式,忽略大小写查找

<h6 id="string.find">string.find("字符串","模式",开始位置) </h6>
 开始位置为可选参数,默认为1，必须以字节计数，  
函数返回匹配结果的起始,结束位置,以及所有捕获分组

<h6 id="string.format">string.format("%__", ) </h6>
 首参数内每个%符号后是一个格式化字符,  
每个格式化字符按对应顺序格式后续参数  
  
详细用法请参考  
[格式化字符串](chm://libraries/kernel/string/format.html)

<h6 id="string.fromCharCode">string.fromCharCode(__) </h6>
 使用1个或多个 Unicode 编码值转换为 UTF-8 字符串  
参数可以指定1个或多个Unicode编码数值,可指定大于0x10000的编码,  
不可直接传入数组作为参数

<h6 id="string.fromUnicode">string.fromUnicode </h6>
 将参数@1指定的字符串字符串自UTF16编码转换为多字节编码，默认转为UTF8，  
如果参数@1是一个字符串，并且已存在UTF编码标记，则根据该源编码进行优化并避免不必要的转换或错误转换。  
如果出现错误转换，请注意检查源数据是否被添加了错误的UTF标记

<h6 id="string.fromUnicode">string.fromUnicode(字符串) </h6>
 从unicode编码还原到aardio字符串默认为UTF8编码  
注意aardio中Unicode指的UTF16 LE,代码页为1200

<h6 id="string.fromUnicode">string.fromUnicode(字符串,目标编码) </h6>
 从Unicode编码还原到指定编码  
目标编码默认为UTF8代码页:65001  
注意aardio中Unicode指的UTF16 LE,代码页为1200  
aardio字符串默认为UTF8编码

<h6 id="string.fromUnicode">string.fromUnicode(字符串,目标编码,转换字符数) </h6>
 显示定转换转换字符数参数时，  
可允许第一个参数为指针、或 buffer对象，  
参数@3以字符计数，即2个字节为一个单位,  
字符数为-1表示查找'\u0000'终止符获取可打印文本长度  
字符数只能为数值

<h6 id="string.fromUnicodeIf">string.fromUnicodeIf(字符串) </h6>
 如果是UTF16字符串转换到UTF8代码页，否则直接返回,  
可使用string.setUtf函数标记一个字符串是否UTF16编码,  
aardio也会在相关转换编码的函数中自动标记

<h6 id="string.fromto">string.fromto </h6>
 转换传入文本字符串编码并返回转换后的字符串,  
此函数先调用 string.toUnicode,再调用 string.fromUnicode,  
fromto 函数名源于这两个函数的前缀

<h6 id="string.fromto">string.fromto(内存指针,源编码,目标编码,转换字节数) </h6>
 转换传入文本字符串编码并返回转换后的字符串,  
参数@4为可选用一个数值指定需要转换的文本所占内存字节数,  
字节数为-1时表示查找'\0'终止符自动获取长度  
指定转换字节数时,参数@1即可使用指针、buffer作为参数  
注意即使指定UTF16代码页,参数@4仍然是以字节计数

<h6 id="string.fromto">string.fromto(字符串,源编码,目标编码) </h6>
 转换传入文本字符串编码并返回转换后的字符串,  
目标编码默认为0,即系统默认代码页  
源编码为可选参数,默认为UTF8代码页 65001  
如果字符串已存在UTF标记，则忽略源编码参数  
UTF16 LE代码页为1200,UTF 16 BE代码页为1201

<h6 id="string.getUtf">string.getUtf(__) </h6>
 获取字符串的UTF格式标记，返回值如下:  
&16 表示双字节编码的UTF-16编码  
&8 表示UTF-8字符串,  
&(8 | 1) 表示UTF-8、ANSI兼容编码,即所有字符小于0x80  
  
对于空字符串,aardio忽略其UTF标记,  
对于非空字符串，aardio只允许一个字符串对象在创建时初始化UTF标记为UTF16,  
而其他字符串，允许在运行时修改UTF标记

<h6 id="string.getenv">string.getenv("变量名") </h6>
 读取当前进程环境变量  
成功返回字符串,失败返回 null

<h6 id="string.gfind">string.gfind(字符串,模式串,开始位置) </h6>
 
    for i,j,group1  in string.gfind( /*查找字符串*/,"(.)") { 
    	
    }

<h6 id="string.gmatch">string.gmatch(str,pattern) </h6>
 
    for m in string.gmatch( ,"./*指定模式表达式,  
    用于在参数@1指定的字符串中循环全局搜索符合条件的字符串,  
    有几个匹配分组迭代器返回几个值,  
    注意表达式不能以^开始*/") {   
          
    }

<h6 id="string.hex">string.hex </h6>
 以十六进制编码字符串

<h6 id="string.hex">string.hex(字符串,前缀,'\x80') </h6>
 以十六进制编码字符串中的所有非ASCII字符 - 字节码大于等于'\x80'的字节(汉字等),  
前缀可省略,默认为"\x",

<h6 id="string.hex">string.hex(字符串,前缀,忽略字符串) </h6>
 以十六进制编码字符串,前缀可省略,默认为"\x",  
忽略字符串指定忽略不转换的字符,不指定则编码所有字节  
指定了任意忽略字符，都会忽略ASCII大小写字母以及ASCII数字

<h6 id="string.indexAny">string.indexAny(字符串,查找字符串) </h6>
 查找参数@2指定的字符串中的任意一个字节,  
参数@2可以是数值字节码

<h6 id="string.indexAny">string.indexAny(字符串,查找字符串,开始位置) </h6>
 查找参数@2指定的字符串中的任意一个字节,  
参数@2可以是数值字节码

<h6 id="string.indexOf">string.indexOf </h6>
 纯文本搜索，  
类似的函数raw.indexOf支持以二进制直接使用指针搜索内存

<h6 id="string.indexOf">string.indexOf("字符串","查找文本") </h6>
 返回查找文本所在起始索引,结束索引  
字符串如果包含'\0'时仅取'\0'之前的纯文本  
禁用模式匹配

<h6 id="string.indexOf">string.indexOf("字符串","查找文本",开始位置,结束位置) </h6>
 返回查找文本所在起始索引,结束索引  
字符串如果包含'\0'时仅取'\0'之前的纯文本  
禁用模式匹配

<h6 id="string.isUnicode">string.isUnicode(__) </h6>
 判断参数是否标记过的UTF-16字符串  
'在aardio转义字符串中附加u后缀表示Uniocde字符串'u  
注意aardio中Unicode指的UTF16 LE,代码页为1200

<h6 id="string.isUtf8">string.isUtf8(__) </h6>
 快速检测字符串是否包含UTF8编码  
空字符串返回null

<h6 id="string.join">string.join(字符数组,"分隔符",开始索引,结束索引) </h6>
 将字符串数组使用指定的分隔符合并为一个字符串  
即使传入空数组至少也会返回空字符串而非null,  
开始索引,结束索引为可选参数

<h6 id="string.lastIndexAny">string.lastIndexAny(字符串,查找字符串) </h6>
 自尾部向前查找参数@2指定的字符串中的任意一个字节,  
参数@2可以是数值字节码

<h6 id="string.lastIndexAny">string.lastIndexAny(字符串,查找字符串,开始位置) </h6>
 自尾部向前查找参数@2指定的字符串中的任意一个字节,  
参数@2可以是数值字节码

<h6 id="string.lastIndexOf">string.lastIndexOf </h6>
 从右侧反向搜索字符串  
禁用模式匹配  
这个函数需要从尾部逐个字符反向查找,效率较低

<h6 id="string.lastIndexOf">string.lastIndexOf("字符串","查找子串",搜索范围) </h6>
 从右侧反向搜索字符串  
此函数为二进制搜索,搜索内容可包含'\0',禁用模式匹配  
搜索范围仍然是自右向右正方向字节计数,负数为反向计数  
返回值为正向字节计数

<h6 id="string.left">string.left(str__,n ) </h6>
 从字符串左侧截取n个字符,  
n为负数表示自左侧截取到右侧倒计数的指定字符,  
按字节计数,汉字为多个字节  
参数@1也可以是 buffer 对象

<h6 id="string.left">string.left(str__,n,true) </h6>
 从字符串左侧截取n个字符  
按字符计数,汉字为一个字符  
参数@1也可以是 buffer 对象

<h6 id="string.len">string.len </h6>
 如果字符串是合法的UTF8编码，返回字符计数，否则返回0

<h6 id="string.len">string.len(字符串,起始字节位置,结束字节位置) </h6>
 如果字符串是合法的UTF8编码，返回字符计数,  
参数@2,@3都是可选参数,以字节而非字符为单位  
起始位置默认为1  
结束位置默认为-1

<h6 id="string.lines">string.lines </h6>
 创建用于for in语句的迭代器按行拆分字符串  
也可将返回迭代器传入 table.array 生成数组,  
按行读取文件请使用 io.lines 函数,  
null值或空字符串忽略不执行

<h6 id="string.lines">string.lines(字符串,行分隔符,列分隔符,最大列数) </h6>
 按行拆分参数@1传入的字符串,  
可选使用参数@2指定行分隔符,支持模式匹配语法,  
如果不指定列分隔符,每次循环返回字符串,  
如果指定列分隔符,使用模式匹配二次拆分,每次循环返回数组,  
可选用参数@4指定最大列数,  
列分隔符支持模式匹配语法

<h6 id="string.load">string.load </h6>
 读取文件或内嵌资源文件,返回普通字符串  
如果文件以UTF16 LE BOM开始,并且长度为2的倍数时，读入为Unicode(UTF16)字符串  
  
注意，此函数以启用共享读写模式打开文件

<h6 id="string.load">string.load("文件路径") </h6>
 读取文件或内嵌资源文件,返回普通字符串  
  
路径首字符可用斜杠表示应用程序根目录，用~加斜杠表示EXE根目录  
如果~\或~/开头的EXE根目录路径不存在，自动转换为应用程序根目录下的路径重试

<h6 id="string.load">string.load(资源名,资源类型,dll句柄) </h6>
 读取文件或内嵌资源文件,返回普通字符串  
资源名，资源类型都可以是字符串、或小于0xFFFF的数值或指针  
参数三是dll句柄,默认为_HINSTANSE  
除参数一以外,其他参数可选

<h6 id="string.loadBuffer">string.loadBuffer </h6>
 读取文件或内嵌资源文件,返回 buffer  
  
注意，此函数以启用共享读写模式打开文件

<h6 id="string.loadBuffer">string.loadBuffer("文件路径") </h6>
 读取文件或内嵌资源文件,返回 buffer,  
  
路径首字符可用斜杠表示应用程序根目录，用~加斜杠表示EXE根目录  
如果~\或~/开头的EXE根目录路径不存在，自动转换为应用程序根目录下的路径重试

<h6 id="string.loadBuffer">string.loadBuffer(资源名,资源类型,dll句柄) </h6>
 读取文件或内嵌资源文件,返回 buffer,  
资源名，资源类型都可以是字符串、或小于0xFFFF的数值或指针  
参数三是dll句柄,默认为_HINSTANSE  
除参数一以外,其他参数可选

<h6 id="string.loadcode">string.loadcode </h6>
 加载并执行 aardio 代码或文件,返回 HTML 模板输出的 HTML 代码  
如果当前应用未定义 response 对象,请使用 print 函数替代。  
此函数也可以用于非 HTML 格式的任意字符串模板，  
但非 HTML 格式的字符串开始部分必须是 aardio 模板标记

<h6 id="string.loadcode">string.loadcode("代码文件",...) </h6>
 加载并执行 aardio 代码或文件,  
返回 HTML 模板输出的 HTML 代码,失败返回空值,错误信息。  
参数@1,与 loadcode 函数相同,其他参数作为模板参数传给被调用的文件,  
在被调用文件的函数外部可使用 owner 参数获取首个模板参数,  
也可以使用...获取多个模板参数

<h6 id="string.lower">string.lower(__) </h6>
 字符串转换为小写

<h6 id="string.map">string.map </h6>
 搜索并返回搜索结果数组,  
并调用映射函数转换数组中的每个匹配结果为新的值,  
  
注意如果模式串中使用括号指定了多个分组,  
映射函数会有多个对应的回调参数

<h6 id="string.map">string.map(字符串,模式,映射函数) </h6>
 参数@1指定要查找的字符串,  
参数@2可以指定模式表达式,或包含多个表达式的数组,  
省略则默认为"[-\d]+",并且参数@3的默认值会被更换为tonumber  
可选用参数@3指定映射函数,  
  
返回值为匹配的字符串数组,如果有多个捕获分组则返回二维数组  
如果参数@2不是数组而是表,则返回相同结构的表,  
每个键对应的值更新为参数表中同名键指定的模式表达式的匹配结果。

<h6 id="string.match">string.match </h6>
 使用模式表达式在字符串中查找子串，  
类似的函数raw.match可以支持在内存指针中查找字符串

<h6 id="string.match">string.match("字符串","模式串",开始位置) </h6>
 使用模式表达式在字符串中查找子串，  
参数@1指定目标字符串,参数@2指定查找模式串。  
参数@3可选,用于指定起始位置,负数表示尾部倒计数,  
返回匹配字符串,如果使用了匹配分组则返回多个对应的匹配串,  
返回值的顺序对应模式串中左圆括号的开始顺序

<h6 id="string.matches">string.matches("字符串","模式表达式") </h6>
 全局匹配并将匹配结果返回为数组  
每次匹配成功的多个返回值存为成员数组  
即使没有匹配到任何结果,也会返回一个空数组

<h6 id="string.pack">string.pack(chr__,chr2) </h6>
 参数为零个或多个字符的ascii码数值  
str = string.pack('A'#,'B'#,'C'#)  
也可以是一个包含字节码的数组,例如:  
string.pack( {'A'#,'B'#,'C'# } )

<h6 id="string.random">string.random(len__) </h6>
 生成随机字符串（字母、数字）

<h6 id="string.random">string.random(len__,"中文字符集") </h6>
 生成随机字符串,并指定随机字符集

<h6 id="string.random">string.random(str__,str2,str3) </h6>
 参数为多个字符串,函数随机返回其中一个字符串

<h6 id="string.reduce">string.reduce </h6>
 使用string.match依次匹配多个模式表达式,逐步缩减并返回最终匹配结果

<h6 id="string.reduce">string.reduce(字符串,模式,...) </h6>
 参数@1指定要查找的字符串,  
参数@2开始指定一个或多个模式表达式,  
使用前面一个的匹配结果作为后面一次匹配的条件,  
逐步缩减并返回最终匹配结果,  
也可以在参数@2中使用一个数组指定多个模式表达式

<h6 id="string.removeBom">string.removeBom(字符串) </h6>
 如果字符串开始为UTF8 BOM，则返回移除该 BOM 的字符串。  
如果字符串开始为 UTF-16 BOM,则移除 BOM 并返回转换为 UTF-8 编码的字符串,  
否则直接返回参数

<h6 id="string.repeat">string.repeat(n__) </h6>
 创建长度为n的字符串,默认填充\0

<h6 id="string.repeat">string.repeat(n__," ") </h6>
 将参数2重复n次并创建新的字符串返回

<h6 id="string.repeat">string.repeat(n__,' ') </h6>
 将参数2重复n次并创建新的字符串返回

<h6 id="string.replace">string.replace </h6>
 替换字符串,此函数不会改变原字符串,而是返回替换后的新字符串  
此函数有两个返回值,第二个返回值为替换次数

<h6 id="string.replace">string.replace("字符串","@查找字符串","替换字符串",替换次数) </h6>
 禁用模式匹配替换,  
在查找串中用模式匹配语法，替换字符串反斜杠也仅仅表示字面值不再表示匹配分组,  
以'@@'开始则是'<@@...@>'的缩写形式,忽略大小写查找  
替换次数省略则全局替换

<h6 id="string.replace">string.replace("字符串","模式表达式",替换函数,替换次数) </h6>
 使用模式匹配在字符串中查找替换  
替换回调函数返回需要替换的新字符串,不返回值则保留原字符串  
有几个匹配分组就有几个回调参数  
  
替换次数省略则全局替换  
返回值为替换后的新字符串

<h6 id="string.replace">string.replace("字符串","模式表达式",替换字符串,替换次数) </h6>
 使用模式匹配在字符串中查找替换  
替换字符串,可使用\1至\9引用匹配分组,\0表示匹配到的完整字符  
  
替换次数省略则全局替换  
返回值为替换后的新字符串

<h6 id="string.replace">string.replace("字符串","模式表达式",替换表,替换次数) </h6>
 使用模式匹配在字符串中查找替换  
替换表对象中键为匹配到的字符串,替换值可以是字符串、数值、函数、false  
其中数值转换为字符串返回，false表示取消替换,  
函数用于接收匹配结果并返回新字符串,有几个匹配分组就有几个回调参数

<h6 id="string.repline">string.repline </h6>
 按行替换字符串,返回替换后的字符串,  
此函数仅返回替换后的新字符串,只有一个返回值

<h6 id="string.repline">string.repline(源字符串,模式串,替换串,替换次数) </h6>
 模式串用于匹配所有的单行文本,  
替换串与 string.replace 用法相同  
替换次数指的也是每一行内部进行替换的最大次数,不指定则不限制

<h6 id="string.repline">string.repline(源字符串,模式串,替换函数,替换次数) </h6>
 模式串用于匹配所有的单行文本,  
替换函数与 string.replace 用法相同  
,  
替换次数指的也是每一行内部进行替换的最大次数,不指定则不限制

<h6 id="string.repline">string.repline(源字符串,模式串,替换表,替换次数) </h6>
 模式串用于匹配所有的单行文本,  
替换表与 string.replace 用法相同  
,  
替换次数指的也是每一行内部进行替换的最大次数,不指定则不限制

<h6 id="string.reverse">string.reverse('字符串') </h6>
 字节序反转排列

<h6 id="string.reverse">string.reverse('字符串',true) </h6>
 将字符串倒序排列  
以字符为单位,参数必须是以UTF8编码的文本字符串,  
返回值同样是UTF8编码,注意aardio中文本字符串默认的编码为UTF8

<h6 id="string.right">string.right(str__,n ) </h6>
 从字符串右侧截取n个字符,  
n为负数表示自左侧计数起始位置,并向右截取剩余字符,  
按字节计数,汉字为多个字节  
参数@1也可以是 buffer 对象

<h6 id="string.right">string.right(str__,n,true ) </h6>
 从字符串右侧截取n个字符  
按字符计数,汉字为一个字符  
参数@1也可以是 buffer 对象

<h6 id="string.save">string.save("__/*请输入文件路径*/", ) </h6>
 保存字符串到文件  
如果父目录尚未建立，将自动创建父目录  
写入文件成功返回true,否则返回false,错误信息  
如果文件存在隐藏属性,可能会写入失败,错误信息返回"No Error"  
  
注意，此函数以启用共享读写模式打开文件

<h6 id="string.save">string.save("__/*请输入文件路径*/", ,true) </h6>
 追加字符串到文件  
如果父目录尚未建立，将自动创建父目录  
  
注意，此函数以启用共享读写模式打开文件

<h6 id="string.search">string.search(回调函数,字符串,模式表达式,...) </h6>
 模式匹配搜索.  
  
可以指定1个或多个模式表达式,  
此函数使用前面表达式的结果作为后面表达式的查询字符串,  
每一个模式表达式都支持全局搜索并可以返回多个匹配结果,  
最后一个表达式的匹配结果作为参数回调参数@1指定的函数.  
  
每一个模式表达式参数都可以使用函数或 lambda表达式替代,  
用于作为筛选器筛选上次的匹配结果,筛选器可以返回新的字符串,  
返回非字符串类型则用于指定是否保留上次的匹配结果,  
  
如果参数@1是一个数组,则将匹配结果添加到该数组,如果有多个捕获分组则返回二维数组,  
如果参数@1是数组则返回该数组,否则函数无返回值

<h6 id="string.setUtf">string.setUtf </h6>
 设置字符串的UTF格式标记  
该标记主要由aardio自动设置,一般不建议用户调用该函数  
  
对于空字符串,aardio忽略其UTF标记,  
对于非空字符串，aardio只允许一个字符串对象在创建时初始化UTF标记为UTF16,  
而其他非UTF16字符串，允许在运行时修改UTF标记,  
此函数并不会改变字符串数据，也没有返回值

<h6 id="string.setUtf">string.setUtf("字符串"，编码格式) </h6>
 设置字符串的UTF格式标记，所有UTF格式标记如下:  
0 表示普通字符串,  
&8 表示UTF-8字符串,  
&16 表示双字节编码的Unicode字符串  
&(8 | 1) 表示UTF-8、ANSI兼容编码,即所有字符小于0x80  
  
此函数只能用于标记除UTF16以外的编码。  
不能使用此函数修改字符串的UTF标记为UTF16编码，  
也不允许使用此函数修改已经标记为UTF16编码的字符串。  
  
aardio会自动维护UTF16字符串的编码标记，  
使用string.sliceUnicode函数也可以获取UTF16标记的字符串

<h6 id="string.setenv">string.setenv("变量名","变量值") </h6>
 设置当前进程环境变量  
参数@2为 null 或省略则删除参数@1指定的环境变量

<h6 id="string.slice">string.slice(str__,i,j ) </h6>
 从字符串中截取位置i到j的字符串,  
注意i使用1表示第一个字符,返回字符串包含j指字的最后一个字符,  
按字节计数,汉字为多个字节,如果i,j为负数则从右侧倒数计数  
省略参数j则默认值为截取到字符串尾部  
  
参数@1也可以是 buffer 对象

<h6 id="string.slice">string.slice(str__,i,j,true ) </h6>
 从字符串中截取位置i开始的字符串,  
注意i使用1表示第一个字符,返回字符串包含j指字的最后一个字符,  
按字符计数,汉字为一个字符,如果i为负数则从右侧倒数计数  
省略参数j则默认值为截取到字符串尾部,  
  
参数@1也可以是 buffer 对象

<h6 id="string.sliceUnicode">string.sliceUnicode </h6>
 截取Unicode(UTF16）字符串,  
也可用于为字符串添加UTF16标记

<h6 id="string.sliceUnicode">string.sliceUnicode(字符串,开始位置,结束位置) </h6>
 截取Unicode(UTF16）字符串,也可用于为字符串添加UTF16标记.  
此函数不会修改传入字符串的UTF标记，但是返回非空字符串时会添加UTF16编码标记.  
  
注意此函数并不是一个编码转换函数,  
转换编码请使用 string.toUnicode函数.  
  
开始位置,结束位置以UTF16字符单位计数（2个字节为1个单位）  
可以使用负数表示自右侧倒计数单位，-1表示最后一个字符.

<h6 id="string.split">string.split </h6>
 拆分字符串,  
空字符串拆分后返回数组长度为0,  
连续的分隔符中间拆分为空字符串,  
改用string.splitEx函数才能使用模式语法指定连续的分隔符

<h6 id="string.split">string.split('字符串') </h6>
 不指定分隔符则按UTF8编码逐个拆分为字符数组,  
返回数组,中文等多字节字符会被拆分为一个数组元素,  
参数传入空字符串返回数组长度为0

<h6 id="string.split">string.split('字符串','<分隔符>',返回数组最大长度) </h6>
 置于<>内的字符串作为分隔符,  
返回数组,空字符串返回数组长度为0  
参数@3为可选参数,不指定则拆分全部字符串

<h6 id="string.split">string.split('字符串','A',返回数组最大长度) </h6>
 单字节快速拆分  
返回数组,空字符串返回数组长度为0  
参数@3为可选参数,不指定则拆分全部字符串

<h6 id="string.split">string.split('字符串','abc',返回数组最大长度) </h6>
 指定多个单字节分隔符,不可使用多字节分隔符,基于二进制搜索  
返回数组,空字符串返回数组长度为0  
参数@3为可选参数,不指定则拆分全部字符串

<h6 id="string.splitEx">string.splitEx </h6>
 使用模式匹配语法指定分隔符,用于拆分字符串,  
返回拆分后的字符串数组,  
传入null值或空字符串返回空数组

<h6 id="string.splitEx">string.splitEx(字符串,分隔符模式串,最大拆分次数,开始位置) </h6>
 使用模式匹配语法指定分隔符,拆分字符串并返回数组,  
参数@1传入null值或空字符串返回空数组,  
用零宽匹配指定分隔符可在拆分的字符串中包含分隔符,  
省略分隔符模式则按行拆分,支持回车、换行、回车换行等不同换行规则,空行不合并,  
拆分次数可省略,默认不限次数,  
开始位置可省略,默认从开始拆分

<h6 id="string.startWith">string.startWith("字符串","开始串") </h6>
 判断开始串是否位于字符串开始处  
基于二进制模式

<h6 id="string.startWith">string.startWith("字符串","开始串",true) </h6>
 判断开始串是否位于字符串开始处。  
基于文本模式,忽略大小写

<h6 id="string.str">string.str </h6>
 转换字符串为不包含'\0'的纯文本字符串,  
或转换 Unicode 字符串为不包含'\u0000'的纯文本字符串

<h6 id="string.str">string.str(字符串) </h6>
 如果传入字符串包含 '\0'，则返回  '\0' 前面的字符串，  
否则返回原字符串。  
  
参数@1也可以是 buffer 对象,   
如果输入参数是结构体或指针，应当改用 raw.str 函数

<h6 id="string.str">string.str(字符串,true) </h6>
 参数 @1 可传入 Unicode 字符串。Unicode 字符串如包含 '\u0000'，  
则返回 '\u0000' 前面的 Unicode 字符串,否则返回该 Unicode 字符串。  
返回的 Unicode 字符串自动添加 UTF16 标记。  
  
如果参数 @1 是 UTF16 标记过的 Unicode 字符串,参数 @2 可以省略,  
参数 @1 也可以是 buffer 对象,如果参数是结构体或指针，  
应改用 raw.str 函数

<h6 id="string.toUnicode">string.toUnicode </h6>
 转换字符串到Unicode/UTF16编码字符串  
如果字符串已经是UTF16编码将直接返回参数  
对于Unicode/UTF16编码字符串aardio会添加UTF编码标记,  
对UTF16字符串使用下标操作符[ ]可返回2字节的宽字节码,  
使用直接下标操作符[[ ]]会返回2字节的宽字符

<h6 id="string.toUnicode">string.toUnicode(字符串) </h6>
 将字符串转换从多字节编码转换为UTF16编码  
源编码默认为UTF8代码页:65001

<h6 id="string.toUnicode">string.toUnicode(字符串,源编码) </h6>
 将字符串转换从指定编码转换为unicode编码  
源编码默认为UTF8代码页:65001

<h6 id="string.toUnicode">string.toUnicode(字符串,源编码,转换字节数) </h6>
 字节数为-1时表示查找'\0'终止符自动获取长度  
指定转换字节数时,参数@1即可使用指针、buffer作为参数  
注意参数@3始终以字节计数,而非按字符计数

<h6 id="string.trim">string.trim(str__) </h6>
 从字符串首尾清除所有空白字符

<h6 id="string.trim">string.trim(str__,' ') </h6>
 从字符串首尾清除指定的一个或多个单字节字符

<h6 id="string.trimleft">string.trimleft(str__) </h6>
 从字符串左侧清除所有空白字符

<h6 id="string.trimleft">string.trimleft(str__,' ') </h6>
 从字符串左侧清除指定的一个或多个单字节字符  
清除多字节字符请不要用这个函数,应改用模式匹配替换,例如  
str = string.replace(str,`^[中文]+`,``)

<h6 id="string.trimright">string.trimright(str__) </h6>
 从字符串右侧清除所有空白字符

<h6 id="string.trimright">string.trimright(str__,' ') </h6>
 从字符串右侧清除指定的一个或多个单字节字符  
清除多字节字符请不要用这个函数,应改用模式匹配替换,例如  
str = string.replace(str,`[中文]+$`,``)

<h6 id="string.unescape">string.unescape(__) </h6>
 还原函数string.escape生成的转义字符串  
可兼容JSON字符符转义规则,允许直接包含单引号

<h6 id="string.unhex">string.unhex </h6>
 还原使用16进制编码的字符串

<h6 id="string.unhex">string.unhex("16进制编码数据","前缀") </h6>
 还原使用16进制编码的字符串,解码失败返回null值  
例如UrlEncode前缀可以指定为"%",前缀可以为空字符,不指定前缀时默认为"\x"  
空前缀必须明确指定一个空字符串,使用空前缀不能混杂非编码字符  
  
如果前缀是单个空白字符时,可以省略字符串开始的前缀(仅作为分隔符使用)

<h6 id="string.unpack">string.unpack(str__,i) </h6>
 取字符串的第i个字符的ascii码数值。

<h6 id="string.unpack">string.unpack(str__,i,j) </h6>
 取字符串的第i个到第j个字符的ascii码数值并返回。

<h6 id="string.upper">string.upper(__) </h6>
 字符串转换为大写
