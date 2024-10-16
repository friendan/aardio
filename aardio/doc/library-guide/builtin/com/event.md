# COM 对象 事件接口

参考: [在windows窗体上嵌入可视化控件](embed.md)

## com.Connect

1. 函数原型：   

    ```aardio
    var sink,cookie = com.Connect( comObject, eventTable )
    ```  
  
2. 函数说明：   

    参数 @comObject 指定 COM 对象。 

    要特别注意 @comObject 不能指定临时变量，例如： `com.Connect( execl.ActiveWorkbook , ... )` 这样写是错误的。execl.ActiveWorkbook 没有被引用时会被回收，事件自然也就不起作用了。正确的做法是先写 `var book = execl.ActiveWorkbook` 保存 COM 对象并保持 book 变量在有效作用域内。然后再写  `com.Connect( book, ... ) `
    
    参数 @eventTable 指定事件表。  

    事件表是一个普通的 table 对象，com.Connect 查找 COM 对象的默认事件接口并进行挂接。挂接成功以后创建事件接收器(event sink)并返回,事件接收器是一个 COM 对象,用于响应事件,并触发事件表中的事件函数。
      
    返回的 sink 为事件接收器。
    返回的 cookie 是一个数字值，用来记录连接点。
    
    sink,cookie 主要用于调用 com.ReleaseConnection 以释放事件接收器，并取消事件挂接。
  
3. 调用示例： 

    ```aardio
    import win.ui;
    /*DSG{{*/
    var winform = win.form(text="响应 COM 事件";right=759;bottom=469)
    winform.add(
    edit={cls="edit";left=9;top=13;right=749;bottom=457;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
    )
    /*}}*/

    //创建 COM 对象,注意服务器系统没这个控件
    var wmPlayer = com.CreateObject("WMPlayer.OCX"); //注意 win.ui 自动导入了 com 库。
    
    //定义事件对象
    var ocxEvents1 = { 
      StatusChange = function() { 
        winform.edit.print("StatusChange",wmPlayer.Status)
      };
      MediaChange = function(item){
        winform.edit.print("ocxEvents1.MediaChange",item.sourceURL)
      }; 
    }
    
    com.Connect(wmPlayer, ocxEvents1);

    //使用 COM 对象打开指定的音频
    wmPlayer.url = "http://download.aardio.com/v10.files/demo/mp3/lrc.mp3"

    winform.show();
    win.loopMessage();
    ```  

## com.AddConnection

1. 函数原型：   
 
    ```aardio
    var cookie = com.AddConnection( comObject, eventSink )
    ```  
  
2. 函数说明：   

    参数 @comObject 指定 COM 对象。 
    要特别注意 @comObject 不能指定临时变量。
    
    参数 @eventSink 指定事件接口对象。  
    请使用 [com.ImplInterface](ImplInterface.md#ImplInterface) 创建事件接口。 
  
    返回的 cookie 是一个数字值，用来记录连接点。可以使用 cookie 作为参数调用 com.ReleaseConnection 以释放事件接收器，并取消挂接。
  
3. 调用示例：   

    ```aardio
    import win.ui;
    /*DSG{{*/
    var winform = win.form(text="响应COM事件";right=759;bottom=469)
    winform.add(
    edit={cls="edit";left=9;top=13;right=749;bottom=457;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
    )
    /*}}*/

    //创建 COM 对象,注意服务器系统没这个控件
    var wmPlayer = com.CreateObject("WMPlayer.OCX"); //注意 win.ui 自动导入了 com 库。
      
    var ocxEvents2 = {
      StatusChange = function() { 
        winform.edit.print("ocxEvents2.StatusChange",wmPlayer.Status)
      };
      MediaChange = function(item){
        winform.edit.print("ocxEvents2.MediaChange",item.sourceURL)
      }; 
    }
    var eventSink =  com.ImplInterface(ocxEvents2,"WMPlayer.OCX.7","_WMPOCXEvents")
    var cookie = com.AddConnection( wmPlayer,eventSink );//挂接事件监听器
    
    //释放前面挂接的事件监听器
    //com.ReleaseConnection(wmPlayer,eventSink,cookie);

    //使用 COM 对象打开指定的音频
    wmPlayer.url = "http://download.aardio.com/v10.files/demo/mp3/lrc.mp3"

    winform.show();
    win.loopMessage();
    ```  

## com.ReleaseConnection

1. 函数原型：   

  
    ```aardio
    com.ReleaseConnection( com对象 ) //释放挂接到默事件接口的接收器
    com.ReleaseConnection( com对象, 事件对象,cookie ) //释放挂接到指定接口的接收器
    ```  
      
2. 函数说明：   
  
    此函数与注销使用 com.Connect、com.AddConnection 创建的事件连接点。  
    调用这个函数并不是必须的，不再使用的 COM 对象会被 aardio 的内存回收器自动销毁，COM 对象销毁以前会自动释放所有的事件连接。
  
3. 调用示例：   

    ```aardio
    //......此处代码略,参考上面 com.AddConnection 的示例代码

    //释放前面挂接的事件监听器
    //com.ReleaseConnection(wmPlayer,eventSink,cookie);
    ```

## 必读：避免 COM 事件表的循环引用 <a id="gc" href="#gc">&#x23;</a>

无论是 COM 事件回调还是原生 API 回调函数，它们都有一个共同特征是要避免循环引用。而纯 aardio 对象或函数不存在这种问题。参考：[原生回调函数对象的内存管理与释放](../raw/callback.md#gc)

实际上我们使用 COM 控件上基本遇不到下面的要讲的问题，
甚至基本不需要自己绑定事件监听器，aardio 已经自动处理好了所有这些事。

但这背后的基本规则必须要有所了解。

注意绑定事件的 com.Connect() 或 com.AddConnection() 会将参数 @1 指定的 COM 对象,以及参数 @2 指定的事件表对象强绑定，这里如果不小心建立了循环引用，会导致 2 个对象都无法自动释放。

所以一般应当避免绑定自身作为事件监听器，例如：
`com.Connect(comObject, comObject)` 这样自己绑定自己是错的。

或者绑定引用了事件监听器的成员作为事件监听器，例如：
`com.Connect(eventTable.comObject, eventTable)`
这样自己绑定自己的成员对象也是错的。

但我们可能希望通过同一个对象访问 COM 对象并指定事件回调函数，
aardio 提供了 com.ConnectWeak() 以及 com.CreateEmbedEx() 可以实现这样的功能。

aardio 可以利用元表轻松地将一个表代理到另一个表、或建立弱引用表解决这种问题。有兴趣可以看看这几个函数的源码（ 位于标准库：builtin.com ）。

实际上我们很少需要自己绑定事件并使用 com.Connect() 这些函数，
aardio 中嵌入窗口控件的 winform.createEmbed(),winform.createEmbedEx() 已经自动绑定返回的 COM 容器对象作为事件监听器，
这几个函数虽有前述的循环引用，但是已经在宿主窗口销毁前
自动解除事件监听并释放对象，所以能正常释放。