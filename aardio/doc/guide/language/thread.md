# aardio 多线程开发入门

## 一、做好心理准备
  
虽然 aardio 的多线程开发非常简单，但是：  
1、请先了解:「**多线程」开发比「单线程」开发更复杂**这个残酷的现实。  
2、请先了解: aardio 这样的动态语言可以实现**真多线程**非常罕见。  
  
建议先找任意的编程语言试试能不能更轻松地实现 aardio 多线程范例相同的效果。 如果**实践后你发现 aardio 做多线程开发要轻松得多，那么请继续往下看**， 如果遇到一点困难和限制就不行，那只能早点放弃。  
  
## 二、简单了解什么是线程
  
当你点击EXE文件系统一个应用程序的时候 - 系统会创建一个进程（process）  
而在一个进程内可以包含多个线程(thread)。用来显示界面的线程，我们通常称为“界面线程”，  
其他不是用来显示界面的线程，我们一般称为“工作线程”或者是“后台线程”。  
进程的启动线程称为「主线程」，「界面线程」通常是主线程。  
  
每个线程可以按单一顺序执行一系列的任务 —— 但不能并发执行多个任务。  
**多个线程就可以并发执行多个任务**。  
  
## 三、为什么需要多线程
  
界面线程会使用 win.loopMessage() 启动一个消息循环，  
win.loopMessage() 就象一个快递公司不知疲倦地分发、处理窗口消息，直到最后一个非模态、非 MessageOnly 的独立窗口（ 或 mainForm ）关闭后才会退出消息循环。当然你也可以使用 win.quitMessage() 退出消息循环。  
  
界面线程如果遇到耗时操作，就会停下来无法继续分发处理消息 —— 这时候界面就表现为「卡死」状态。  
这时候如果创建工作线程去执行耗时操作，就可以让界面线程继续分发处理消息（不会卡住）。  
  
## 四、线程同步的风险
  
多线程就象多个在并列的轨道上疾驰的火车，如果 A 火车与 B 火车上的人想操作同一部手机（ **线程共享变量** ），你不能直接从 A 火车上把手伸出去跟B 火车上的人拉拉扯扯。这时候只能先让所有的火车都停下来，互动完了再继续往前开。需要互动的时候先停下来 —— 这在多线程开发里就是线程同步锁机制。 在 aardio 中用 thread.lock() 创建同步锁，但实际上在 aardio 中很少需要用到同步锁。  
  
上面这种看起来省事的方式会制造大量的麻烦。更好的方法是 A 火车、B 火车上的人都玩自己的手机，而不是共享一部手机。大家拿着自己的手机（ **线程独享变量** ）相互联系，一样可以愉快地互动。这就是 aardio 多线程的基本规则：每个线程有独立的运行上下文、独立的全局变量环境，一个线程中的对象传到另一个线程 —— 只会传值而不会传址（传引用）。  
  
注意：  

1. aardio 也提供操作共享变量的 thread.get,thread.set,thread.var,thread.table 等。  
2. 一个对象传入另一个线程虽然是传值，但仍然可能引用同一个可以在线程间安全共享的资源，例如 thread.command,thread.event 等。  
3. 窗口或控件对象从一个线程传到另一个线程实际上是传同一个窗口句柄的引用对象 —— 在多线程中操作同一个窗口或控件总是会转发到创建窗口的界面线程内执行。  
  
  
## 五、aardio 多线程开发基本规则
  
多线程开发时要谨记以下基本规则。  
  
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
>time,time.ole,thread.var,thread.table,  
thread.command,thread.event,thread.semaphore,process.mutex,  
fsys.file,fsys.stream,fsys.mmap,raw.struct …… 请参考相关文档说明。  
  
如果不想看文档，直接判断一个对象是不是可以跨线程传递的方法也很简单：  
不支持传入线程使用的对象，那么传入线程后调用必然会失败报错。  
  
## 六、多线程入门
  
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
 doSomething( "也可以有参数什么的" )
```

如果希望写复杂一点调用这个函数，我们也可以这样写：

```aardio
 invoke(doSomething ,,"也可以有参数什么的" )
```


如果我们希望创建一个新的线程来调用这个函数，那么就需要下面这样写：

```aardio
 thread.invoke(doSomething ,"也可以有参数什么的" )
```


切记不要犯一个低级错误：

> 如果把创建线程的代码改为 thread.invoke( doSomething("也可以有参数什么的") )
> 
> 这是在创建线程前就调用函数了，实际执行的代码是 thread.invoke( 123 ) 这肯定会出错的。

aardio 中多线程交换变量的几种方法:
  
1. 如果你有一些函数需要被多个线程用到，请他们写到库文件里，然后在任何线程中使用 import 语句导入即可使用。  
  
2. 可以在创建线程时，通过线程的启动参数把变量从一个线程传入另一个线程，例如：  

    ```aardio
    thread.invoke( 线程启动函数,"给你的","这也是给你的","如果还想要上车后打我电话" )
    ```

3. 多线程共享的变量，必须通过 thread.get() 函数获取，并使用 thread.set() 函数修改其值，thread.var, thread.table 对这两个函数做了进一步的封装。

4. aardio提供了很多线程间相互调用函数的方法，通过这些调用方式的传参也可以交互变量，具体请查看aardio范例中的多线程范例。

  
界面线程会使用 win.loopMessage(); 启动一个消息循环，  
win.loopMessage();  就象一个快递公司不知疲倦的收发消息，直到最后一个非模态、非 MessageOnly 的独立窗口（ 或 mainForm ）关闭后才会退出消息循环。当然你也可以使用 win.quitMessage() 退出消息循环。  
  
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

复制上面的代码到 aardio 中并运行，你可以看到一个窗体显示在屏幕上。

如果你去掉代码中的最后一句 win.loopMessage() 那么窗体只会显示一下就消失了，你的程序也迅速退出了。  
但如果你加上 win.loopMessage() 窗体就会一直显示在屏幕上（直到你点击关闭按钮）。并且你可以做其他的操作，例如点击按钮。  
  
我们尝试点击按钮，点击按钮后触发了 winform.button.oncommand() 函数，一件让我们困惑的事发生了，窗体卡死了任何操作都没有反应，这是因为类似 sleep(5000) 这样的耗时操作阻塞了win.loopMessage()启动的消息循环过程。  
  
一种解决方法是把 sleep(5000)改成 thread.delay(5000)，虽然他们同样都是延时函数，但是 thread.delay() 在界面线程会继续处理窗口消息。但很多时候我们其他的耗时操作 —— 不能同时处理窗口消息，这时候就需要创建工作线程执行耗时操作。  
  
下面的代码演示在界面线程中创建工作线程，然后在工作线程中与界面线程交互：  

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

在工作线程中直接操作界面控件固然令人愉快，  
但如果代码量一大，界面与逻辑混杂在一起，会让代码不必要的变的千头万绪复杂臃肿。  
  
如果把多线程比作多条轨道上并列飞奔的火车，那么火车交互的方法不仅仅只有停下来同步，或者把手伸出车窗来个最直接的亲密交互。一种更好的方式是拿起手机给隔壁火车上的人打个电话 - 发个消息，或者等待对方操作完了再把消息发回来。  
  
这种响应式的编程方式在 aardio 里就是 thead.command，下面我们看一个简单的例子：  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="线程命令";right=599;bottom=399)
winform.add(
edit={cls="edit";left=12;top=11;right=588;bottom=389;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
)
/*}}*/

import thread.command;
var listener = thread.command();
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

thread.command可以把多线程间复杂的消息交互伪装成普通的函数调用，非常的方便。


这里新手仍然可能会困惑一点：我在工作线程中不是可以直接操作界面控件么？！ 你这个thread.command虽然好用，但是多写了不少代码呀。


这样去理解是不对的，你开个轮船去对象菜市场买菜固然是有点麻烦，但如果你开轮船去环游世界那你就能感受到它的方便在哪里了。thread.command 一个巨大的优势是让界面与逻辑完全解耦，实现界面与逻辑的完全分离，当你的程序写到后面，代码越来越多，就能感受到这种模式的好处了，我举一个例子，例如 aardio自带的自动更新模块的使用示例代码：

```aardio
import fsys.update.dlMgr;
var dlMgr = fsys.update.dlMgr("http://update.aardio.com/api/v1/version.txt","/download/update-files")

dlMgr.onError = function(err,filename){
    //错误信息 err,错误文件名 filename 这里可以不用做任何处理,因为出错了就是没有升级包了
}

dlMgr.onConfirmDownload = function(isUpdated,appVersion,latestVersion,description){

    if( ! isUpdated ){
        //已经是最新版本了
    }
    else {
        //检测到最新版本，版本号 latestVersion
    };
   
    return false; //暂不下载
}

dlMgr.create();
```


这个 fsys.update.dlMgr 里面就用到了多线程，但是他完全不需要直接操作界面控件。  
而你在界面上使用这个对象的时候，你甚至都完全不用理会他是不是多线程，不会阻塞和卡死界面，有了结果你会收到通知，你接个电话就行了压根不用管他做了什么或者正在做什么。

  
这个fsys.update.dlMgr里面就是使用thread.command实现了实现界面与逻辑分离，你可以把检测、下载、更新替换并调整为不同的界面效果，但是fsys.update.dlMgr的代码可以始终复用。


我们有时候在界面中创建一个线程，仅仅是为了让界面不卡顿，我们希望用 thead.waitOne() 阻塞等待线程执行完闭（界面线程同时可以响应消息），然后我们又希望在后面关闭线程句柄，并获取到线程最后返回的值。  
  
可能我们希望一切尽可能的简单，尽可能的少写代码，并且也不想用到thread.manage（因为并不需要管理多个线程）。  
  
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


一般我们可以使用 thread.invoke() 函数简单快捷的创建线程，  
而 thread.create() 的作用和用法与  thread.invoke() 一样，唯一的区别是 thread.create()会返回线程句柄。  
  
线程句柄可以用来控制线程（暂停或继续运行等等），  
如果不再使用线程句柄，应当使用 raw.closehandle() 函数关闭线程句柄（这个操作不会关停线程）  
  
有了线程句柄，我们可以使用 thread.waitOne() 等待线程执行完毕，  
而且 thread.waitOne() 还可以一边等待一边处理界面消息（让界面不会卡死）。  
  
下面看一下aardio范例里的多线程入门示例：  

```aardio
//入门
import win.ui;
/*DSG{{*/
var winform = win.form(text="多线程 —— 入门";right=536;bottom=325;)
winform.add(
button={cls="button";text="启动线程";left=27;top=243;right=279;bottom=305;db=1;dl=1;dr=1;font=LOGFONT(h=-16);z=1;};
edit={cls="edit";left=27;top=20;right=503;bottom=223;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=2;};

)
/*}}*/

winform.button.oncommand = function(id,event){
	
	//禁用按钮并显示动画
	winform.button.disabledText = {"✶";"✸";"✹";"✺";"✹";"✷"}	
	
	//创建工作线程
	thread.invoke( 
	
		//线程启动函数
		function(winform){
			
			for(i=1;3;1){
				sleep(1000); //在界面线程执行 sleep 会卡住
				
				//调用界面控件的成员函数 - 会转发到界面线程执行
				winform.edit.print("工作线程正在执行，时间：" + tostring( time() ) ); 
			} 
			
			winform.button.disabledText = null;
			
		},winform //窗口对象可作为参数传入工作线程
	)
} 

winform.show();
win.loopMessage();
```

 
aardio中提供了 thread.manage，thread.works 等用于管理多个线程的对象，  
例如标准库中用于实现多线程多任务下载文件的 thread.dlManager 就使用了thread.works管理线程。
  
thread.works 用于创建多线程任务分派，多个线程执行相同的任务，但可以不停的分派新的任务，一个例子：

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

而 thread.manage 可以用来创建多个线程执行多个不同的任务，可以添加任意个线程启动函数，在线程执行完闭以后可以触发onEnd事件，并且把线程函数的返回值取回来，示例如下：

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
  
  
   