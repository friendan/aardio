# 多线程中的交通信号灯：thread.event

标准库中的 thread.event 用于创建线程事件对象，  
该对象类似于多线程中的交通信号灯、实现红绿灯机制实现多线程之间的同步协作。thread.event 对象可以让等待的线程停下来，这显然比不断地循环查询一个线程共享变更高效。

## 一、创建线程事件对象
  
创建 thread.event 对象的代码如下：  

```aardio
import thread.event;
var event = thread.event("交通信号灯");
```

thread.event 有三个构造参数，如下：

```aardio
var event =  thread.event("事件唯一名称",是否手动复原信号,初始状态)
```

1. 第一个参数指定唯一的事件名称、一般建议用 aardio 工具里的 GUID 工具生成一个 GUID 以保证其唯一性。  
在不同线程、或不同进程中使用相同的事件名称就可以打开同一个事件对象（ thread.event 对象不但可以跨线程、也可以跨进程使用 ），使用返回事件对象的 event.conflict 属性可以判断其他线程或进程是否也打开了该事件对象。  
2. 参数 2 指定是否手动复原信号，为可选参数，默认值为 false 。如果手动复原信号为 false 表示自动复原信号，也就是每次放行线程以后自动重置为无信号状成。仅在第一次创建事件时有效，打开其他线程已创建的事件此参数无效。
3. 参数 3 指定事件初始状态，为可选参数，默认值为 false 。初始状态为 false 表示初始化为无信号状态。仅在第一次创建事件时有效，打开其他线程已创建的事件此参数无效。

## 二、使用线程事件对象
  
可以将 event 比作交通信号灯，红灯停、绿灯行为基本规则。

- 无信号状态类似红灯，表示禁止通行。
- 有信号状态类似绿灯，表示放行等待的线程。
 
event 对象提供以下方法：

```aardio
import thread.event;
var event = thread.event("交通信号灯")

//重置为无线号状态、类似于切换为红灯
event.reset(); //红灯停

//切换为有线号状态、类似于切换为绿灯
event.set(); //绿灯行

//阻塞线程并等待有信号状态（类似等绿灯）。如果未设为手动复原、则函数返回后会自动复原为无信号状态(红灯)
event.wait(); 

//等待有信号状态，等待的同时可以响应窗口消息与用户操作
event.waitOne(); 
```

注意 event.wait() 与 event.waitOne() 作用类似，区别是 event.waitOne() 在等待的过程中可以同时处理当前界面线程的窗口消息，响应用户的交互操作（ 不会是无响应状态 ）。

- event.wait() 内部是调用 thread.wait 函数。
- event.waitOne() 内部是调用 thread.waitOne 函数。

event.wait() 与 event.waitOne() 都可以指定一个超时参数，超时后返回 null 。范例  [thread.event 定时器](../../../example/aardio/Thread/09.timer.html) 的原理就是利用了 event.wait() 的超时参数。


## 三、命名线程事件对象用法示例

在不同线程中调用 thread.event 构造对象时可以指定一个相同的事件名称，以访问相同的事件对象。

示例：

```aardio
import thread.event;

//首次创建事件参数 2 设为手动复原，则有信号就放行所有等待线程，否则仅放行一个。
var event = thread.event("交通信号灯",true) 

thread.invoke( 
    function(){
        import thread.event;
        
        var event = thread.event("交通信号灯")
        event.wait();
        
        io.print("汽车1 过了")
    }
)

thread.invoke( 
    function(){
        import thread.event;
        
        var event = thread.event("交通信号灯")
        event.wait();
        
        io.print("汽车2 过了")
    }
)

thread.invoke( 
    function(){
        import thread.event;
        
        var event = thread.event("交通信号灯")
        event.wait();
        
        io.print("汽车3 过了")
    }
)

//给一点时间让所有线程进入等待状态
sleep(100)

//打开控制台
io.open();

//切换为绿灯
event.set(); 

execute("pause")
```

如果首次创建事件调用 `thread.event("交通信号灯",true) ` - 参数 2 指定了手动复原事件。则调用一次 `event.set()` 就放行所有正在等待的线程。反之，调用 `thread.event("交通信号灯",false) ` 创建的事件对象在放行等待线程时会自动复原事件为无信号状态（默认设置），一次只能放行一个等待线程。

thread.event 构造函数的参数 2，3 只在首次创建事件时有效，其他线程调用 `thread.event("交通信号灯")` 只是打开已存在的事件，参数 2,3 是无效的。

## 四、匿名线程事件对象用法示例

创建  thread.event 对象时也可以不指定名称，然后将事件对象作为线程参数传入其他线程。

示例：

```aardio
import thread.event;
var event = thread.event(); 

thread.invoke( 
	function(event){ 
		event.wait();
		
		io.print("张三: 李四、收到请回复")
		event.set();//我讲完了，到你了
			
		event.wait();
		io.print("张三: 年夜饭吃过了吗")
		event.set();//我讲完了，到你了
			
		event.wait();
		io.print("张三: %￥#@！~") 
		event.set();//over,让对方有机会说话
	},event
)        

thread.invoke( 
	function(event){ 
		event.wait();
		io.print("李四: Hi、兄弟你好！")  
		event.set()//我讲完了，到你了
			
		event.wait();
		io.print("李四: 还没吃呢，正在写个自动吃年夜饭的小程序")
		event.set();//我讲完了，到你了
		
	},event
)

//打开控制台
io.open();

//切换为有信号状态
event.set();
		
//暂停控制台
execute("pause");
```

> 要注意在 aardio 中每个线程都有独立的变量环境。当我们将同一 thread.event 对象传入不同的线程，实际上是在不同的线程环境创建了自动绑定相同的事件句柄的不同的对象。

在实际的应用中可以更简单一些：上一个线程调用 event.wait() 等待，而另外一个线程执行 event.set() 放行等待线程。更复杂的用法可以考虑创建多个 thread.event 对象进行分工，这样更好控制。  
  


  
