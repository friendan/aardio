# winex 库

winex 库主要扩展 win 库的功能，并提供管理外部进程窗口的函数与窗口自动化有关的功能。

## winex.match <a id="match" href="#match">&#x23;</a>


1. 函数原型：   

	`是否匹配 = winex.match(窗口句柄,文本,类名,ID,超时) `

2. 函数说明：
  
	所有参数可选.  
	
	检测给定窗口句柄的窗口属性，与给定的参数进行比较，如果相符返回真(true)，否则返回假(false) 。

	使用模糊匹配比较类名、标题，支持 [模式语法](../../builtin/string/patterns.md) 。  

	可选指定一个以毫秒为单位的超时值。
	
	winex 库中查找窗口的函数多是调用此函数对窗口进行匹配。  

## winex.find <a id="find" href="#find">&#x23;</a>


1. 函数原型：   

	`hwnd,线程ID,进程ID = winex.find( 类名,标题,进程ID,线程ID )` 

	注意：本文档中 hwnd 用于表示窗口句柄的变量名。

2. 函数说明：
  
	按给定的参数查找指定的窗口，所有参数都是可选参数。  
	winex.find使用模糊匹配来查找类名、标题，支持 [模式语法](../../builtin/string/patterns.md) 。  
	
	如果需要简单匹配，请使用 [win.find](../win/_.md#find)  
  
3. 调用示例：   
  
  
	```aardio
	import winex; 
	import process;
	import console; 

	//运行目标程序
	var prcs = process( "请指定文件名.exe"  )

	//查找窗口
	var hwnd = winex.find("请指定类名" , ,prcs.id /*根据进程ID也可以找到窗口*/ );  
	console.logPause("找到句柄：", hwnd )
	```  

## winex.findEx <a id="findEx" href="#findEx">&#x23;</a>


1. 函数原型：   

	`hwnd = winex.findEx( 父窗口句柄,返回第几个匹配句柄,类名模式串 ,标题模式串, 控件ID )`

  
2. 函数说明：   
  
	按给定的参数查找指定的窗口，除父窗口句柄以外所有参数都是可选参数。  
	
	winex.findEx使用模糊匹配来查找类名、标题，支持 [模式查找语法](../../builtin/string/patterns.md) 。  
	
	如果需要简单匹配，请使用 [win.findEx](../win/_.md#findEx)  
  
3. 调用示例：   
  
  
	```aardio
	import process;
	import winex; 

	//运行程序
	process.execute("请指定文件.exe")

	//查找
	var hwnd = win.find("请指定类名");//查找父窗口
	var hedit = winex.findEx(hwnd,1,"Edit" ); //查找第一个类名为Edit的子窗口

	//输出结果
	console.logPause("找到目标程序中的文本框句柄：", hedit )
	
	```

## winex.findExists <a id="findExists" href="#findExists">&#x23;</a>


1. 函数原型：   

	```aardio
	窗口句柄,控件句柄,线程ID,进程ID = winex.findExists( 父窗口标题,控件文本 )

	窗口句柄,控件句柄,线程ID,进程ID = winex.findExists( 
					父窗口标题,
					控件文本,
					父窗口类名,
					控件类名,
					控件ID
				)
	```
  
2. 函数说明：   
  
	所有参数都是可选参数,但一般应指定父窗口标题与控件文本.  
	这个函数基本是结合了winex.find与winex.findEx的功能,首先查找符合条件的父窗口,再查找它是否包含符合条件的控件窗口.您可以打开winex库查看此函数的源代码.  
	
	winex.findExists同样支持使用模糊匹配来查找类名、标题，支持 [模式查找语法](../../builtin/string/patterns.md) 。  
	
	这个函数是非常有用的一个函数.  
  
3. 调用示例：   
  
  
	```aardio
	import winex;
	import process
	import console; 

	//运行目标程序
	process.execute( "notepad.exe") 

	//查找包含指定标题,并包含类名为"Edit"控件的窗口.
	窗口句柄,控件句柄,线程ID,进程ID = winex.findExists("<标题1>|<标题2>","", ,"Edit")

	//显示结果
	console.log( 窗口句柄,控件句柄,线程ID,进程ID  )

	//关闭窗口
	win.close(窗口句柄)

	console.pause(true);
	```  

## winex.findActivate <a id="findActivate" href="#findActivate">&#x23;</a>


```aardio
1. 函数原型：   

窗口句柄,控件句柄,线程ID,进程ID = winex.findActivate( 父窗口标题,控件文本 )

窗口句柄,控件句柄,线程ID,进程ID = winex.findActivate( 
				父窗口标题,
				控件文本,
				父窗口类名,
				控件类名,
				控件ID
			)
```
  
2. 函数说明：   
  
	此函数用法与winex.findExists完全相同,内部直接调用winex.findExists.  

	不同的是:winex.findActivate会在找到窗口后激活窗口使之成为前台窗口.  

## winex.wait <a id="wait" href="#wait">&#x23;</a>


1. 函数原型：   

	```aardio
	窗口句柄,控件句柄,线程ID,进程ID = winex.wait( 父窗口标题,控件文本 )

	窗口句柄,控件句柄,线程ID,进程ID = winex.wait( 
					父窗口标题,
					控件文本,
					父窗口类名,
					控件类名,
					控件ID
				)
	```
  
2. 函数说明：   
  
	所有参数都是可选参数,但一般应指定父窗口标题与控件文本.  
	这个函数内部调用winex.findExists,所以参数用法与winex.findExists完全一致,请参考此函数说明.  
	winex.wait同样支持使用模糊匹配来查找类名、标题，支持 [模式查找语法](../../builtin/string/patterns.md) 。  
	
	该函数指定一些可选的参数,等待指定的窗口创建,然后返回.  
	可使用 winex.waitTimeout 指定超时值(以毫秒为单位),如果此属性为null空值,表示永不超时.  
	可使用 winex.waitDelay 指定检测间隔(以毫秒为单位),默认为100毫秒.  
	
	该函数如果超时并失败则返回空值.  


## winex.waitClose <a id="waitClose" href="#waitClose">&#x23;</a>


1. 函数原型：   

	```aardio
	是否成功 = winex.waitClose( 窗口句柄 )

	是否成功 = winex.waitClose( 
					父窗口标题,
					控件文本,
					父窗口类名,
					控件类名,
					控件ID
				)
	```
  
2. 函数说明：   
  
	此函数用法与winex.wait类似,请参考winex.wait说明.  
	不同的是,winex.waitClose可以指定一个窗口句柄作为参数.  
	并且 winex.waitClose只有一个返回值,表示是否成功.  
	
	该函数指定一些可选的参数,等待指定的窗口关闭,然后返回.  
	可使用 winex.waitTimeout 指定超时值(以毫秒为单位),如果此属性为null空值,表示永不超时.  
	可使用 winex.waitDelay 指定检测间隔(以毫秒为单位),默认为100毫秒.  
	
	如果超时返回false,成功则返回true;  

## winex.waitActive <a id="waitActive" href="#waitActive">&#x23;</a>


1. 函数原型：   

	```aardio
	窗口句柄 = winex.waitActive( 窗口句柄 )

	窗口句柄,控件句柄,线程ID,进程ID = winex.waitActive( 
					父窗口标题,
					控件文本,
					父窗口类名,
					控件类名,
					控件ID
				)
	```
  
2. 函数说明：   
  
	此函数用法与winex.waitClose类似,请参考winex.waitClose说明.  
	
	winex.waitActive返回激活窗口的句柄.如果使用了winex.wait相同的参数,则返回与winex.wait相同的返回值(窗口句柄,控件句柄,线程ID,进程ID)  
	
	
	该函数指定一些可选的参数,等待指定的窗口激话,然后返回. 可使用 winex.waitTimeout 指定超时值(以毫秒为单位),如果此属性为null空值,表示永不超时. 可使用 winex.waitDelay 指定检测间隔(以毫秒为单位),默认为100毫秒.  
	
	如果超时返回空值,否则返回激活窗口的句柄.  
	
	注意:此函数内部调用 win.getForeground() 检测激活窗口，而非 win.getActive() 。win.getActive() 仅能获取当前线程的激活窗口,而非系统激活窗口,通常会因为名称而导致误会.  

## 枚举窗口 <a id="enum" href="#enum">&#x23;</a>


请参考： [枚举与遍历](../../../language-reference/function/enum-and-each.md)

1. 函数原型：   

	`winex.enum( 回调函数,父窗口句柄 = 桌面窗口,要查找的类名,要查找的标题,要查找的控件ID )`

  
2. 函数说明：   
  
	在指定的父窗口枚举所有子窗口、除回调函数以外，所有参数为可选参数。类名与标题支持 [模式语法](../../builtin/string/patterns.md) 。  

	每查找到一个窗口就调用第一个参数指定的回调函数。回调函数按下面的格式定义：

  
	```aardio
	function( 找到的窗口句柄,窗口嵌套深度 ){
	//返回false停止枚举
	}
	```  

3. 调用示例： 

	```aardio
	import winex;
	import console; 

	winex.enum( 
		function(hwnd,depth){

		console.log( depth/*深度*/,hwnd/*窗口*/,win.getText(hwnd)/*标题*/ )
		/*return false*/
	} )
	```  

## 枚举顶层窗口 <a id="enumTop" href="#enumTop">&#x23;</a>


请参考： [枚举与遍历](../../../language-reference/function/enum-and-each.md)

1. 函数原型：   

	`winex.enumTop( 回调函数 )`

  
2. 函数说明：   
  
	枚举所有桌面顶层窗口。  
	每查找到一个窗口就调用第一个参数指定的回调函数。回调函数按下面的格式定义：

	
	```aardio
	function( 找到的窗口句柄 ){
	//返回false停止枚举
	}
	```  

	winex.enumTop的实现较简单，执行速度也很快，如果仅仅是需要例出顶层窗口的句柄，不需要其他的功能，应优先选用此函数。

3. 调用示例： 
  
	```aardio
	import winex;
	import console; 

	winex.enumTop(
		function(hwnd){
			console.log(hwnd)
		}
	)

	console.pause(true);
	```  

## 遍历窗口 <a id="each" href="#each">&#x23;</a>


请参考： [枚举与遍历](../../../language-reference/function/enum-and-each.md)

1. 函数原型：   

	`winex.each( 要查找的类名,要查找的标题,父窗口句柄 = 桌面窗口 )`

  
2. 函数说明：   
  
	父窗口句柄为可选参数，默认为桌面窗口。类名和标题都支持 [模式查找语法](../../builtin/string/patterns.md) 。  

	winex.each 创建一个可用于 [for in](../../../language-reference/statements/looping.md#for-in) 语句的迭代器函数，用于广度遍历同一子级的子窗口。  


## winex.fromPoint <a id="fromPoint" href="#fromPoint">&#x23;</a>


1. 函数原型：   

	`hwnd = winex.fromPoint( 屏幕坐标x,屏幕坐标y )`
  
2. 函数说明：   
  
	从指定的屏幕坐标获取窗口，如果窗口拥有子窗口则递归获取子窗口直到叶级窗口

## winex.fromPointReal

1. 函数原型：   

	`hwnd = winex.fromPointReal( 屏幕坐标x,屏幕坐标y )`

  
2. 函数说明：   
  
	此函数首先调用winex.fromPoint，然后调用winex.fromClientPointReal,可穿透groupbox控件获取内部控件窗口

## winex.fromClientPoint <a id="fromClientPoint" href="#fromClientPoint">&#x23;</a>


1. 函数原型：   

	`hwnd = winex.fromClientPoint(父窗口句柄, 客户坐标x,客户坐标y,un=_CWP_SKIPINVISIBLE )`

  
2. 函数说明：   
  
	在指定的父窗口获取、从指定的屏幕坐标获取该位置子窗口句柄(不能获取子窗口的子窗口)。

	un为可选参数，默认为_CWP_SKIPINVISIBLE，其他可选参数：

	| 参数 | 说明 |
	| --- | --- |
	| 0x0000/\*_CWP_ALL\*/ | 测试所有窗口 |
	| 0x0001/\*_CWP_SKIPINVISIBLE\*/ | 忽略不可见窗口 |
	| 0x0002/\*_CWP_SKIPDISABLED\*/ | 忽略已屏蔽的窗口 |
	| 0x0004/\*_CWP_SKIPTRANSPARENT\* / | 忽略透明窗口 |

## winex.fromClientPointReal <a id="fromClientPointReal" href="#fromClientPointReal">&#x23;</a>


1. 函数原型：   

	`hwnd = winex.fromClientPointReal(父窗口句柄, 屏幕坐标x,屏幕坐标y,un=_CWP_SKIPINVISIBLE )`

  
2. 函数说明：   
  
	在指定的父窗口获取、从指定的屏幕坐标获取该位置子窗口句柄(不能获取子窗口的子窗口)  
	可穿透groupbox控件获取内部控件窗口.

## winex.getFocus <a id="getFocus" href="#getFocus">&#x23;</a>


1. 函数原型：   

	`hfocus = winex.getFocus( hwnd )`

  
2. 函数说明：   
  
	返回指定窗口输入焦点所在的控件句柄，如果参数hwnd是一个控件，则直接返回该控件的句柄。  
	此函数支持获取外部线程的输入焦点，而 [win.getFocus](../win/_.md#getFocus) 只能支持当前线程的窗。


## winex.click <a id="click" href="#click">&#x23;</a>


1. 函数原型：   

	`hwnd = winex.click( 窗口句柄,命令ID )`

  
2. 函数说明：   
  
	窗口上的菜单、按钮等都会有一个控件ID，可以使用winex.click函数直接向包含该控件的主窗口发送该ID的命令消息，达到后台模拟点击控件的效果。

	可以使用附带的工具：winspy查看控件ID，使用查看资源文件的软件查看菜单项的ID。

## winex.findMenu

1. 函数原型：   

	`hwnd = winex.findMenu( 窗口句柄,菜单标题 | 菜单ID,...... )`
  
2. 函数说明：   
  
	第一个参数为目标窗口句柄。  
	自第二个参数开始可选添加任意多个参数，可用字符串表示菜单项标题，或用数值表示菜单序号。  
	菜单标题支持 [模式查找语法](../../builtin/string/patterns.md) ，菜单序号自1开始(第一个子菜单序号为1。

3. 调用示例： 
  
	```aardio
	//导入winex库
	import winex; 

	//查找
	var hwnd = win.find("指定窗口类名");//查找父窗口

	//查找指定的菜单("文件"菜单下的子菜单"另存为")
	hmenu,menuid = winex.findMenu(hwnd ,"文件","另存为"  );

	//前置窗口
	win.setForeground(hwnd)

	//点击菜单项
	winex.click( hwnd,menuid)
	```  

## winex.attach <a id="attach" href="#attach">&#x23;</a>


1. 函数原型：   

	`是否成功 = winex.attach( 窗口句柄,是否附加=true )`

  
2. 函数说明：   

	绑定当前线程到外部窗口所属线程并共享输入处理机制。
  
	参数应指定一个非当前线程的窗口,如果第二个参数为真(可省略参数,默认为真)。  
	
	通常，系统内的每个线程都有自己的输入队列。winex.attach 允许当前线程与目标窗口共享输入队列。连接了线程后，输入焦点、窗口激活、鼠标捕获、键盘状态以及输入队列状态都会进入共享状态 返回值 Long，非零表示成功，零表示失败。
	
	调用 winex.attach 以后,可以在附加的目标窗口使用 win.getFocus() win.setFocus() 等函数,也可以方便地使用winex.key winex.mouse等函数库提供的后台模拟函数.

	
	附加与解除应配对使用,例如调用 winex.attach(hwnd)附加成功以后,在不再需要附加时应调用winex.attach(hwnd,false)解除.

## winex.attachThread  <a id="attachThread" href="#attachThread">&#x23;</a>


1. 函数原型：   

	`是否成功 = winex.attachThread( 目标线程ID,是否附加=true )`

  
2. 函数说明：   

	绑定当前线程到外部线程并共享输入处理机制。
  
	此函数与 winex.attach 的功能一样。
	
	区别是第一个参数需指定线程ID，而不是窗口句柄。

	其他参考 [winex.attach](#attach) 函数。