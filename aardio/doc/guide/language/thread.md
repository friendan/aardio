# aardio 多线程开发入门

## ▶ 请做好心理准备
  
虽然 aardio 大幅降低了多线程开发的复杂度，但是 **「多线程」开发一定会比「单线程」开发更复杂** 。

解决 “为什么单线程可以 xxx，多线程不可以 xxx ，为什么多线程与单线程不一样？” 这种问题的有效方法就是去学习多线程的知识，去了解「多线程」与「单线程」的不同之处。  
  
## ▶ 什么是线程
  
当你点击 EXE 文件启动并执行一个应用程序 - 操作系统会创建一个进程（process）。

在一个进程内可以包含多个线程(thread)。用来显示界面的线程，我们通常称为“界面线程”， 其他不是用来显示界面的线程，我们一般称为“工作线程”或者是“后台线程”。  

进程的启动线程称为「主线程」，「界面线程」通常是主线程。  
  
每个线程可以按单一顺序执行一系列的任务 —— 但单个线程不能并发执行多个任务。  **多个线程就可以并发执行多个任务**。  
  
## ▶ aardio 多线程开发基本规则
  
多线程就象多个在并列的轨道上疾驰的火车，如果 A 火车与 B 火车上的人想操作同一部手机（ **线程共享变量** ），你不能直接从 A 火车上把手伸出去跟B 火车上的人拉拉扯扯。这时候只能先让所有的火车都停下来，互动完了再继续往前开。需要互动的时候先停下来 —— 这在多线程开发里就是线程同步锁机制。 在 aardio 中用 thread.lock() 创建同步锁，但实际上在 aardio 中很少需要用到同步锁。  
  
上面这种看起来省事的方式会制造大量的麻烦。更好的方法是 A 火车、B 火车上的人都玩自己的手机，而不是共享一部手机。大家拿着自己的手机（ **线程独享变量** ）相互联系，一样可以愉快地互动。这就是 aardio 多线程的基本规则：每个线程有独立的运行上下文、独立的全局变量环境，一个线程中的对象传到另一个线程 —— 只会传值而不会传址（传引用）。  
  
要点：  

1. aardio 也提供操作共享变量的 thread.get,thread.set,thread.var,thread.table 等。  
2. 一个对象传入另一个线程虽然是传值，但仍然可能引用同一个可以在线程间安全共享的资源，例如 thread.command,thread.event 等。  
3. 窗口或控件对象从一个线程传到另一个线程实际上是传同一个窗口句柄的引用对象 —— 在多线程中操作同一个窗口或控件总是会转发到创建窗口的界面线程内执行。  
  
多线程开发时要谨记以下基本规则： 
  
1. 非主线程的错误信息默认只会输出到控制台。 
只有用 console.open() 或 io.open() 打开控制台才能看到非主线程的错误信息。  
  
2. 每个线程有独立的运行上下文、独立的全局变量环境，有独立的堆栈。
一个线程不会使用另一个线程的全局部变量。  
一个线程也不会使用另一个线程引入的库。  
  
3. 不是所有对象都可以从一个线程传到另一个线程使用。  
没有任何外部依赖的数值、字符串、buffer、table、function 可以传入其他线程使用。  
这些对象在传入另一个线程时通常会复制值 - 也就是传值而非传址（传引用）。  
  
    「类」不可以从一个线程传入另一个线程使用。  
    「类」创建的实例对象，除非文档有特别说明一般不可以传入另一个线程使用。  
    
    win.form 创建的窗体对象以及该窗体上创建的控件对象都可以作为参数传入其他线程。  
    在其他线程调用窗体与控件对象的成员函数时 —— 都会回发到创建窗体的界面线程执行。  
    利用这种奇妙的特性 —— 实际上可以在工作线程调用界面线程的任意代码。  
    
    COM 对象不可以从一个线程传递到另一个线程。  
    
    以下对象可从一个线程传递到另一个线程：  
    > time,time.ole,thread.var,thread.table,  
    thread.command,thread.event,thread.semaphore,process.mutex,  
    fsys.file,fsys.stream,fsys.mmap,raw.struct,win.form,web.form,web.view …… 更多支持传入多线程的对象请参考相关文档说明。  
    
    如果不想看文档，直接判断一个对象是不是可以跨线程传递的方法也很简单：  
    不支持传入线程使用的对象，那么传入线程后调用必然会失败报错。  
  
## ▶ 多线程入门示例 <a id="quickstart" href="#quickstart">&#x23;</a>

一个线程会排队执行一系列的编程指令，但一个线程同时只能做一件事。  
例如在界面上有耗时的操作在执行时 - 就不能同时处理其他的界面消息或者响应用户的操作。  
这时候我们就要使用多线程来完成我们的任务。  
  
我们假设有一个耗时操作是这样的：

```aardio
//下面这个函数执行耗时操作
doSomething = function( str ){

    for(i=1;100){
        str = str + " " + i;
        sleep(100)
    }
   
    return 123;
   
}
```

一般我们直接调用这个函数会是这样写：

```aardio
 doSomething( "可以添加任意个数调用参数" )
```

如果希望写复杂一点调用这个函数，我们也可以这样写：

```aardio
 invoke(doSomething , ,"可以添加任意个数调用参数" )
```


如果我们希望创建一个新的线程来调用这个函数，那么就需要下面这样写：

```aardio
 thread.invoke(doSomething ,"可以添加任意个数调用参数" )
```


切记不要犯一个低级错误：

> 如果把创建线程的代码改为 `thread.invoke( doSomething("也可以有参数什么的") )`，则等价于执行 `thread.invoke( 123 )` 这肯定是错的。thread.invoke 的第一个参数必须是一个函数对象，而 `doSomething("也可以有参数什么的")` 的返回值并非函数对象。

## ▶ 多线程交换数据的方法 <a id="var" href="#var">&#x23;</a>


在 aardio 中每个线程都有独立的运行环境。

多线程共享与交换数据的几种方法:
  
1. 使用库文件在多线程间共享代码：如果你有一些函数需要被多个线程用到，请他们写到库文件里，然后在任何线程中使用 import 语句导入即可使用。  
  
2. 通过线程函数的参数传递数据：可以在创建线程时，通过线程的启动参数将对象从一个线程传入另一个线程，例如：  

    ```aardio
    thread.invoke( 线程启动函数,"给你的","这也是给你的","如果还想要上车后打我电话" )
    ```

3. 通过窗口对象的属性与方法传递数据：窗口或控件对象可以跨线程调用，通过跨线程读写窗口对象的属性、跨线程调用窗口方法的调用参数与返回值与可以在线程间交换数据。

4. 使用多线程共享变量交换数据：可通过 thread.get() 函数获取线程共享变量，使用 thread.set() 函数修改线程共享变量。thread.var, thread.table 对则进一步封装了 thread.get 与 thread.set 函数。

5. 其他方式交换数据：aardio 还提供了更多线程间相互调用函数的方法，通过这些调用方式的传参也可以交互变量。具体请查看 aardio 范例中的多线程范例。

## ▶ 界面线程与工作线程 <a id="ui-worker" href="#ui-worker">&#x23;</a>


需要创建窗口界面的线程必须导入 win.ui 库，并且调用 win.form 类构建窗口界面，调用 win.ui.ctrl 名字空间的控件类创建控件窗口。请参考: [创建窗口与控件](../../library-guide/std/win/ui/create-winform.md)

界面线程必须调用 `win.loopMessage()` 启动窗口消息循环，`win.loopMessage()` 就像一个快递公司不知疲倦地分发处理窗口消息，直到最后一个非模态、非 MessageOnly 的独立窗口（ 或 mainForm ）关闭后才会退出消息循环。当然你也可以使用 `win.quitMessage()` 退出消息循环。 请参考：[窗口消息循环](../../library-guide/std/win/ui/msg.md#loopMessage)
  
下面是一个启动界面线程的例子：  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="aardio form";right=759;bottom=469)
winform.add(
button={cls="button";text="耗时操作";left=392;top=232;right=616;bottom=296;z=1}
)
/*}}*/

//用户点击窗口上的按钮时会触发下面的回调函数
winform.button.oncommand = function(id,event){

    //下面用sleep函数休眠5秒(5000毫秒)模拟耗时操作
    sleep(5000)
}

winform.show();
win.loopMessage();
```

复制上面的代码到 aardio 中并运行，我们可以看到一个窗体显示在屏幕上。

如果去掉代码中的最后一句 `win.loopMessage()` 那么窗体只会显示一下就消失了，你的程序也迅速退出了。  
但如果你加上 win.loopMessage() 窗体就会一直显示在屏幕上（直到你点击关闭按钮）。并且你可以做其他的操作，例如点击按钮。  
  
我们尝试点击按钮，点击按钮后触发了 `winform.button.oncommand()` 函数，一件让我们困惑的事发生了，窗体卡死了任何操作都没有反应，这是因为类似 `sleep(5000)` 这样的耗时操作阻塞了 `win.loopMessage()` 启动的消息循环过程。  
  
一种解决方法是将延时函函数 `sleep(5000)` 改成 `thread.delay(5000)`。虽然它们都是延时函数，但是 `thread.delay` 函数在界面线程会继续处理窗口消息。但很多时候我们其他的耗时操作 —— 不能同时处理窗口消息，这时候就需要创建工作线程执行耗时操作。  

并非所有耗时操作都能像  `thread.delay` 函数那样只是延时并继续分发与处理窗口消息。一个线程不能同时做两件事，对于会阻塞窗口消息处理并导致界面卡顿的其他耗时操作，我们将其置于新的工作线程以避免阻塞界面线程。

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="多线程 —— 入门";right=536;bottom=325)
winform.add(
button={cls="button";text="启动线程";left=27;top=243;right=279;bottom=305;db=1;dl=1;dr=1;font=LOGFONT(h=-16);z=1};
edit={cls="edit";left=27;top=20;right=503;bottom=223;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=2}
)
/*}}*/

winform.button.oncommand = function(id,event){
   
    //禁用按钮并显示动画
    winform.button.disabledText = {"✶";"✸";"✹";"✺";"✹";"✷"}
   
    //线程工作线程
    thread.invoke(
        function(winform){
            
            for(i=1;3;1){
                sleep(1000); //在界面线程执行 sleep 会卡住
               
                //调用界面控件的成员函数 - 会转发到界面线程执行
                winform.edit.print("工作线程正在执行，时间：" + tostring( time() ) );
            }
            
            winform.button.disabledText = null;
            
        },winform //窗口对象可作为参数传入其他线程
    )
}

winform.show();
win.loopMessage();
```

我们将多线程应用中的非界面线程称为工作线程。

可以将界面线程的窗口或控件对象传入工作线程，并且在工作线程方便地调用这些界面对象。

要点：

- 在工作线程中调用界面线程的窗口或控件对象，调用总是在被调用的界面线程中执行，发起调用的工作线程会等待调用结束。
- 界面线程的窗口或控件对象并非真的传入了工作线程。工作线程得到的是一个记录了界面线程窗口句柄的代理对象。

## ▶ message-only 线程与 message-only 窗口 <a id="message-only" href="#message-only">&#x23;</a>

一个不显示任何窗口界面的工作线程，仍然可以调用了  `win.loopMessage()` 使线程可以自动分发与处理窗口消息。我们将这种线程称为 message-only 线程。

message-only 窗口则是不在屏幕上显示，仅用于接收与处理窗口消息的窗口。

我们可以在 message-only 线程中创建 message-only 窗口，就可以跨线程调用工作线程内 message-only 窗口对象的属性和方法。

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="示例 - 在工作线程中启动消息循环")
winform.add(
button={cls="button";text="调用工作线程函数";left=441;top=358;right=644;bottom=430;z=1}
)
/*}}*/

thread.invoke( 
	function(winform){
		import win.ui;
		
		//创建 message-only 窗口
		var msgOnly = win.form().messageOnly();
		
		//添加成员函数
		msgOnly.hello = function(str){
			
			//调用界面线程的窗口对象方法
			winform.msgbox(str,"在工作线程 msgOnly.hello 中调用 winform.msgbox")
		}
		
		//关闭窗口时触发
		msgOnly.onClose = function(){
			//message-only 窗口在任何情况下都不会自动调用 win.quitMessage 
			win.quitMessage();
		} 
		
		//传入界面线程
		winform.thread1 = msgOnly;
		
		//启动消息循环
		win.loopMessage();
		
	},winform //窗口对象作为参数传入工作线程
)

winform.button.oncommand = function(id,event){
	
	//调用线程函数
	winform.thread1.hello("你好！");
	
	//退出工作线程
	//winform.thread1.close();
}

winform.show();
win.loopMessage();
```

## ▶ 线程命令 thead.command <a id="thead.command " href="#thead.command ">&#x23;</a>

  
thread.command 用于跨线程监听或发送线程命令。

构造 thread.command 监听器来接收线程命令的线程必须调用 `win.loopMessage()` 启动消息循环。
  
示例：  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="线程命令";right=599;bottom=399)
winform.add(
edit={cls="edit";left=12;top=11;right=588;bottom=389;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
)
/*}}*/

import thread.command;

//创建线程命令监听器
var listener = thread.command();

//添加线程命令回调函数
listener.print = function( ... ){
    winform.edit.print( ... ) //我们在界面线程中这样响应工作线程的消息
}

//创建工作线程
thread.invoke(

    function(){
   
        //必须在线程函数内部导入需要的库
        import thread.command;
        
        //调用界面线程的命令
        thread.command.print("hello world",1,2,3);
        
    }
)

winform.show();
win.loopMessage();
```

thread.command 可以把多线程间复杂的消息交互伪装成普通的函数调用，非常的方便。

我们也可以将 thread.command 构造的监听对象作为参数传入工作线程，示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="线程命令";right=599;bottom=399)
winform.add(
edit={cls="edit";left=12;top=11;right=588;bottom=389;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
)
/*}}*/

import thread.command;

//创建线程命令监听器
var listener = thread.command();

//创建线程命令回调函数
listener.print = function( ... ){
	
	//将工作线程传过来的参数追加输出到文本框
    winform.edit.print( ... ) 
} 

//创建工作线程
thread.invoke(
    function( listener ){  
        
        //同步调用指定监听器的方法
        listener.print("正在努力执行线程.....",99,88) 
        
        //在函数名前加 $ 符号可以异步调用线程命令（不等待返回）
        listener.$print("异步 正在努力执行线程",99,88) 
    },listener //传入工作线程
)

winform.show();
win.loopMessage(); 

```

> 在单个界面线程范围内发布与订阅命令消息可以使用更简单的 subscribe 与 publish 函数。

## ▶ 使用 thread.invokeAndWait 获取线程返回值 <a id="invokeAndWait" href="#invokeAndWait">&#x23;</a>


我们有时候在界面中创建一个线程，仅仅是为了让界面不卡顿，我们希望用 thead.waitOne() 阻塞等待线程执行完闭（界面线程同时可以响应消息），然后我们又希望在后面关闭线程句柄，并获取到线程最后返回的值。  
  
可能我们希望一切尽可能的简单，尽可能的少写代码，并且也不想用到 thread.manage（因为并不需要管理多个线程）。  
  
这时候我们可以使用 thread.invokeAndWait，thread.invokeAndWait 的参数和用法与 thread.invoke 完全一样，区别是 thread.invokeAndWait 会阻塞并等待线程执行完毕，并关闭线程句柄，同时获取到线程函数的返回值。  
  
示例：  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="aardio form";right=759;bottom=469)
winform.add(
button={cls="button";text="读取网页";left=272;top=368;right=624;bottom=440;z=1};
edit={cls="edit";text="edit";left=48;top=40;right=720;bottom=336;edge=1;multiline=1;z=2}
)
/*}}*/

winform.button.oncommand = function(id,event){
    winform.button.disabledText = {"✶";"✸";"✹";"✺";"✹";"✷"}
   
    winform.edit.text = thread.invokeAndWait(
        function(winform){
            sleep(3000);//暂停模拟一个耗时的操作
            
            import inet.http;
            return inet.http().get("http://www.aardio.com");
        },winform
    )
   
    winform.button.disabledText = null;
}

winform.show()
win.loopMessage();
```

请复制上面的代码运行测试一下，在线程执行完以前，你仍然可以流畅地拖动窗口，操作界面。

## ▶ 线程句柄 <a id="handle" href="#handle">&#x23;</a>


一般我们可以使用 thread.invoke() 函数简单快捷的创建线程，  
而 thread.create() 的作用和用法与  thread.invoke() 一样，唯一的区别是 thread.create() 会返回线程句柄。  

线程句柄可以用来控制线程，很多 thread 库函数都是以线程句柄作为参数。

例如用于暂停继续线程的 thread.suspend(线程句柄),thread.resume(线程句柄) 函数，用于等待线程执行完成的 thread.waitOne(线程句柄) 函数等等。

> 注意： thread.waitOne 函数可以一边等待一边处理窗口消息（让界面不会卡死），而 thread.wait, thread.waitAll 在等待时都会阻寒线程（不会同时处理窗口消息）
 
如果不再使用线程句柄，应当使用 raw.closehandle() 函数关闭线程句柄（这个操作不会关停线程）。 
  
[thread 库函数参考](../../library-reference/thread/_.md)
 

## ▶ 多线程任务分派 thread.works <a id="thread.works" href="#thread.works">&#x23;</a>

  
thread.works 用于创建多线程任务分派：多个线程执行相同的任务，但可以不停的分派新的任务。

一个例子：

```aardio
import console;
import thread.works;

var works = thread.works( 20,
    function(...) {
        import console;
        
        thread.lock("写控制台")
        console.log("线程ID" + thread.getId(),",开始工作,接收到任务指令参数",...)
        thread.unlock("写控制台")
        
        return "返回值,线程ID" + thread.getId();
    }
);

//分派任务
works.push("一个任务")
works.push("两个任务")

//等待任务完成
works.wait(
    function(r){
        console.log( "检查成果", r  )
    }
)

works.push("三个任务")
works.push("四个任务")
works.push("五个任务")

//退出程序前,等待任务完成并关闭所有线程
works.waitClose(
    function(r){
        console.log( "检查成果", r  )
    }
)

console.pause()
```

例如标准库中用于实现多线程多任务下载文件的 thread.dlManager 就使用了thread.works 管理线程

## ▶ 多线程管理器 thread.manage <a id="thread.manage" href="#thread.manage">&#x23;</a>


thread.manage 可以用来创建多个线程执行多个不同的任务，可以添加任意个线程启动函数，在线程执行完闭以后可以触发onEnd事件，并且把线程函数的返回值取回来，示例如下：

```aardio
import console;
import thread.manage

//创建线程管理器
manage = thread.manage(3)

var thrdFunc = function(name){
    import win;
    import console;
   
    for(i=1;10;1){
        console.log( thread.getId(),name )
        if( !win.delay(1000) ){ //主线程可以用 manage.quitMessage()中断这个循环
            console.log("收到退出指令")
            return;
        }
    }
    return 67;
}

manage.create(thrdFunc,"线程1").onEnd = function(...){
    console.log("线程1的回调",...)
}

manage.createLite(thrdFunc,"线程2").onEnd = function(){
    console.log("线程2的回调")
}

manage.create(thrdFunc,"线程3")

manage.waitClose()
console.pause();
```

thread.manage通常是用于界面线程里管理工作线程，上面为了简化代码仅仅用到了控制台。  
  
  
   