# 延时、定时器函数用法 
  
## 一、延时函数 winform.setTimeout()    

此函数类似Javascript中的window.setTimeout() 函数  
  
1. 函数原型  
  
	winform.setTimeout( 函数或代码,延时值,其他参数 )  
	
	第一个函数可以是一个函数对象,也可以是一个字符串对象（包含需要延时执行的aardio代码)  
	第二个是可选参数,指定延时值,以毫秒为单位, 默认为100毫秒.  
	第三个参数开始可选添加任意多个附加参数,附加参数将会传递给将要延时执行的函数.  
	函数返回一个计时器ID, 可以使用 winform.changeInterval() 修改时间间隔, 或使用 winform.clearInterval() 删除计时器  
  
2. 函数说明  
  
	延时能指定异步延时执行的函数或代码,  
	因为无需等待异步执行的任务返回，是以可避免当前代码阻塞、使之可以继续执行.  
  
3. 函数示例  
  
	```aardio
	import win.ui;  
	var winform = win.form(text="aardio Form";right=349;bottom=249 )  
	winform.setTimeout(    
		function(){  
		     winform.msgbox("延时执行的对话框")  
		} ,1000  
	)  
		    
	winform.show()  
	win.loopMessage();
	```

	winform.setTimeout 的用法与 Javascript 的 setTimeout 用法基本一样.  
	区别是，winform.setTimeout() 还可以传递参数给延时函数, 示例： 


	```aardio
	import win.ui;  
	
	var winform = win.form(text="aardio Form";right=349;bottom=249 )    
	
	winform.setTimeout(  
		print ,1000 , "测试","传参数给 print"  
	)  
		    
	winform.show()  
	win.loopMessage();
	```

## 二、创建定时器函数 winform.setInterval()

1. 函数原型    

	`winform.setInterval(回调函数,延时值,其他参数)  `

	第二个参数指这定时间间隔,以毫秒为单位.  
	可选指定一个或多个其他参数，其他参数会作为调用参数@1指定函数的参数，如果没有指定其他参数，默认回调参数为 (hwnd,msg,timerId,tick)  

	函数返回一个计时器ID, 可以使用 winform.changeInterval() 修改时间间隔, 或使用 winform.clearInterval() 删除计时器.  
  
2. 函数说明  
  
	指定一个函数,并定时执行  
	定时函数可选返回一个值, 返回false或0取消定时器, 返回非零数值可修改计时器间隔.  
  
3. 函数示例  


	```aardio
	import win.ui;
	/*DSG{{*/
	var winform = win.form({text="定时器演示程序";right=476;bottom=356})
	winform.add(
	edit={cls="edit";left=17;top=13;right=457;bottom=320;edge=1;multiline=1;z=1}
	)
	/*}}*/

	//创建定时器  
	var tmId = winform.setInterval(  
		function(hwnd,msg,id,tick){  
			winform.edit.print( hwnd,msg,id,tick )  
			
			return 3000; //将定时器的时间间隔修改为 3000 毫秒  
		},1000  
	)  

	//显示界面     
	winform.show()

	//启动界面线程消息循环
	win.loopMessage();
	```

4. 自动生成定时器代码  
  
在窗体设计器中, 点击"工具箱 / 定时器" 可自动生成定时器代码.  


## 三、修改计时器函数 winform.changeInterval()    

1. 函数原型  
  
	`winform.changeInterval( 计时器ID, 新的时间间隔, 新的回调函数 )  `
  
2. 函数说明  
  
	修改计时器的时间间隔,  
	参数为 winform.setTimeout() 或 winform.setInterval() 返回的计时器ID,  
	第三个参数可选.
  
## 四、删除计时器函数 winform.clearInterval()

1. 函数原型  
  
	`winform.clearInterval( 计时器ID ) ` 
  
2. 函数说明  
  
	删除指定的计时器,  
	参数为 winform.setTimeout() 或 winform.setInterval() 返回的计时器ID,  
	
	此函数并非必须调用,  
	winform.setInterval() 创建的计时器在窗体关闭时就会自动删除.  
	winform.setTimeout()  创建的计时器在函数触发时自动删除.  

## 常见问题

### 定时器与 thread.delay（win.delay） 的区别是什么？

在界面线程中 threa.delay 实际上是调用 win.delay。
 
请先看调用 thread.delay 的示例 aardio 代码：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="thread.delay 与 定时器的区别";right=349;bottom=249;parent=...)
winform.add(
edit={cls="edit";left=22;top=13;right=326;bottom=226;edge=1;multiline=1;z=1}
)
/*}}*/

//显示窗口
winform.show()

//在文本框输出系统启动时间，以毫秒为单位
winform.edit.print( time.tick() )

//延时
thread.delay(1000)

//在文本框输出系统启动时间，以毫秒为单位
winform.edit.print( time.tick() )

win.loopMessage()
``
 
可以看出 thread.delay（win.delay） 是同步阻塞的，上面的代码运行时两次输出中间等待了 1000 毫秒。

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="thread.delay 与 定时器的区别";right=349;bottom=249;parent=...)
winform.add(
edit={cls="edit";left=22;top=13;right=326;bottom=226;edge=1;multiline=1;z=1}
)
/*}}*/

//显示窗口
winform.show()

//在文本框输出系统启动时间，以毫秒为单位
winform.edit.print( time.tick() )

//延时
winform.setTimeout(
	function(){
		//在文本框输出系统启动时间，以毫秒为单位
		winform.edit.print("定时器执行",time.tick() )
	},1000
) 

//在文本框输出系统启动时间，以毫秒为单位
winform.edit.print( "定时器已启动",time.tick() )

win.loopMessage()
```

运行程序可以看出:
winform.setTimeout() 是异步非阻塞的，所以后面的 "定时器已启动" 会先于 "定时器执行" 输出。  
窗体显示的速度也会很快，这就是支持异步的好处。  

### 异步的定时器是重开一个线程（纤程）来实现的吗？
  
定时器属于单线程（GUI线程里）异步.　并没有创建新的线程。  
定时器只不过预订了一个执行任务的机会而已。  
  
普通调用函数是自已去完成任务，  
使用定时器异目执行函数是把任务委派给别人（消息循环 ）去完成。  
消息循环也就是 win.loopMessage() 语句创建的 while 循环会不停地检测消息队列，并自动触发预设的定时器函数。  
  
线程与纤程也不是一回事，纤程也是单线程才有的概念。  
纤程是单线程里的多任务，但他不是异步的。  
  
线程就好像你把多个工作，让多个人（线程）同时去做，  
每人（线程）做一件事。  
  
而纤程就好像你一个人去做多件事，  
这个做一会，那个做一会，就好像你一边吃饭一边上网一边发贴子，  
吃两口饭，打几个字，再回去吃几口饭，然后再打几个字，最后你一个人（一个线程）把饭也吃完了，贴子也发完了。  
  
### setTimeout 和 setInterval 的区别是什么？是执行一次和循环执行不同吗？ 

1. winform.setTimeout() 内部是调用 winfomr.setInterval() 实现  
  
2. winform.setTimeout() 仅执行一次。winfomr.setInterval() 即可定时执行，也可以执行一次(回调函数返回false)  
  
3. winform.setTimeout() 的回调函数可以是一段代码(也就是字符串) ，例如：  

winform.setTimeout("print(1,2,3);");

### 如果想让定时器暂停，再继续执行应该怎么做？

```aardio
winform.changeInterval(timerId,-1)//暂停  
```