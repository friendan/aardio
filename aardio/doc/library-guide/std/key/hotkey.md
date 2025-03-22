# 超级热键使用指南

标准库 key.hotkey 用于创建超级热键，超级热键是基于低级键盘钩子 [key.hook](../../../library-reference/key/hook.md) 实现的系统全局有效的增强热键。

相关文档： [key.hotkey 库参考](../../../library-reference/key/hotkey/_.html)  | [超级热键范例](../../../example/Windows/Hotkey/key.hotkey.aardio) | [输入法与键盘状态检测](imeState.md)

## ▶ 创建超级热键 

超级热键基于低级键盘钩子，运行超级热键的线程必须是界面线程或者调用了  `win.loopMessage()` 创建窗口消息循环的线程。

以下是一个最简单的超级热键程序示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import key.hotkey;
import win.dlg.chineseNumber;

superHotkey = key.hotkey();
superHotkey.loadTable({
	// 按 Ctrl+ $ 键打开大写金额与中文数字输入框
	["Ctrl+$"] = function(hFocus){  
		win.dlg.chineseNumber().show();
	};
})

winform.show();
win.loopMessage();
```

按 `Ctrl+$` 键运行效果：

![Ctrl+$ 超级热键效果图](https://imtip.aardio.com/screenshots/cn.gif)

`superHotkey.loadTable` 的参数是一个指定热键配置的[表（ table ）](../../../language-reference/datatype/table/) 对象。这个`热键配置表`中每一组键值对都创建一个`热键`，表成员的键指定热键（例如上面的 `"Ctrl+$"` ），表成员的值指定`热键回调函数`。

- 热键用一个或多个对应键盘按键的`虚拟键名`组成的字符串表示。`虚拟键名`指的是 aardio 中 [key.VK 库](../../../library-reference/key/VK.md) 定义的表示指定按键的英文字符串（ 通常与键盘上显示的名称相同 ）。可运行 『 aardio 工具 ／ 鼠标按键　／　按键指令生成器 』自动显示当前按键的`虚拟键名`。 请参考： [虚拟键名称与代码](virtual-key-names.md)
- `热键回调函数`返回 `true` 表示允许系统继续发送按键，否则取消该按键，不再继续发送。
如果热键回调函数返回一个函数对象，则取消该按键不再发送，并在返回函数以后异步延时执行返回的函数对象。

热键书写格式：

- 热键不区分大小写，字符间不能有空白。
- 分隔符 `+` 用于分隔需要同时按下的虚拟键名，例如  `CTRL+I`。分隔符 `,` 用于分隔需要前后连续按下的虚拟键名，例如   `CTRL+I,I` 。只要使用了一个分隔符，则所有虚拟键名都必须用分隔符分开。
- 虚拟键名分隔符前后不能有空白。例如 `CTRL + I` 是错误写法。
- 所有虚拟键名都是单字符时可省略分隔符。 
- 任何虚拟键名都只表示该虚拟键名所在的单个按键，例如 `~` 表示 `~` 字符所在的单个按键而非`Shift+~` 这两个按键。
- 连续的普通字符串触发的热键可用字节码为 0 的 `'\0'` 字符结束以启用终止键，例如 `'~hi\0'` 表示必须按下预设的终止键才会触发热键。可调用 `superHotkey.setEndKeys()` 函数设置预设终止键，此函数参数为不定个数的虚拟键名参数。

超级热键的检测与触发规则：

1. 如果首个按下的键不是控制键，则不需要同时按住多个键。
如果按下的键是已注册的热键前半部分，则阻止当前按键继续发送。
如果继续按键已不符合任何热键，则释放已捕获的按键并按原顺序重新发送。
2. 如果首次按住的是控制键（ CTRL,ALT,SHIFT,WIN 之一），则必须同时按住多个键才算已完成热键。
如果这样同时按住的多个键是一个已完成的热键，但同时又是其他热键的前半部分，则必须放开所有键才会生效。
3. 如果注册单个控制键热键，并且加上 @ 前缀，则放开该键（且中间没有按其他键）才算完成热键。
4. 按键保持按下不放时不会触发多次超级热键。

示例代码：

```aardio
superHotkey = key.hotkey(); 

superHotkey.loadTable({ 
	//按连续按 3 个键，每个键都要放开。
	["~AA"] = function(){  
		//要执行的操作
	};
	
	//按下 Shift 键不放，再按2下Q。
	["SHIFT+Q,Q"] = function(){  
  		//要执行的操作
	};
	
	//按下 Ctrl 键不放，再按K, 然后都放开。
	["Ctrl+K"] = function(){  
  		//要执行的操作
	};
	
	//按下 Ctrl 键不放，再按2次K。因为不是其他热键的前半部分，不需要等待放开。
	["Ctrl+K,K"] = function(){  
  		//要执行的操作
	};
	
	//表示按下 Shift 键再放开，中间不按其他键，通常不会阻止 Shift 切换输入法状态的默认热键。
	["@Shift"] = function(){  
  		//要执行的操作
	};
})
```

## ▶ 避免阻塞键盘消息的耗时操作 <a id="thread" href="#thread">&#x23;</a>


超级热键基于低级键盘钩子，所在线程必须调用 `win.loopMessage()` 启动消息循环。

超级热键所在线程应避免阻塞消息循环的耗时操作，任何阻塞消息循环或热键回调函数的操作执行时间不应超过 200 毫秒。如果阻塞时间超过一秒或超过注册表限制的更小时间，系统可能会直接删除键盘钩子（导致超级热键不可用）。

**如果超级热键出现异常（例如热键失效，对按键的拦截失效，本应被取消的按键发送到了目标窗口等问题），应当首先检查超级热键所在线程是否执行了阻塞钩子消息的耗时操作。**

建议用单独的线程运行超级热键（ [ImTip](#imtip) 就是这样做的 ），超级热键回调函数中使用 thread.invoke 等方法创建新的线程执行耗时操作。请参考：。

如果超级热键中的耗时操作会阻塞消息循环，可使用 thread.invoke 等方法创建新的线程执行这些耗时操作。请参考：

- [示例: 在超级热键中多线程调用 AI 助手处理选区文本](#ai)
- [创建多线程](../../../guide/language/thread.md)

如果超级热键中的耗时操作仅仅是阻塞代码向下执行，但不会阻塞消息循环，则不需要创建多线程，只需要在热键回调中返回一个函数对象即可。示例：

```aardio
superHotkey = key.hotkey(); 

superHotkey.loadTable({
 
	["Ctrl+#"] = function(hFocus){ 
		
		//返回的函数对象时将延时到当前函数退出后执行，避免阻塞键盘钩子
		return function(){
	    	//打开屏幕取色与调色器对话框
    		var dlg = win.ui.ctrl.pick();
    		win.setTopmost(dlg.hwnd,true); 
    		 
    		//显示模态对话框，对话框关闭才会退出此函数。
    		dlg.doModal();		
		} 
	};
})
```

上面的 `dlg.doModal()` 会显示一个模态对话框，此函数运行直到对话框关闭才会退出，代码才能继续向后执行。但 `dlg.doModal()` 函数本身就会创建窗口消息循环直到对话框关闭，所以并不会影响当前线程处理窗口消息或键盘钩子消息（超级热键基于键盘钩子消息）。

## ▶ 在超级热键中调用 AI 助手 <a id="ai" href="#ai">&#x23;</a>

记事本里的运行效果：

![记事本里超级热键调用 AI 续写与补全文本](https://www.aardio.com/zh-cn/doc/images/fim-notepad.gif)

PowerShell 里的运行效果：

![PowerShell 里超级热键调用 AI 自动写代码](https://www.aardio.com/zh-cn/doc/images/fim-ps.gif)

相关文档与范例:

- [使用 web.rest.aiChat 调用 AI 大模型](../../std/web/rest/aiChat.md)
- [更多 AI 调用范例](../../../../example/AI/aiChat.html)

调用 AI 自动续写与补全的范例源码：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import key.hotkey;
superHotkey = key.hotkey();

superHotkey.loadTable({
	
	// 按 Ctrl+ I 触发热键
	["Ctrl+Shift+F1"] = function(hFocus){  
			
			
		//创建多线程以执行耗时操作，以避免阻塞键盘钩子消息导致热键失效。
		thread.invoke( 
			function(winform){
				import key;
				import web.rest.aiChat;
				import winex.editor;
				
				//获取当前选区文本
				var leftText,rightText = winex.editor.getText2();
				if(!#leftText) return;
					
				var ai = web.rest.aiChat(
					key = "sk-请修改密钥";
					url = "https://api.deepseek.com/v1";//大模型接口地址
					model = "deepseek-chat";//模型名称首字符为 @ 则使用 Anthropic 接口
					temperature = 0.5;//温度
					maxTokens = 1024,//最大回复长度
				)
				
				//创建 AI 会话消息队列 
				var msg = web.rest.aiChat.message();
				
				//添加系统提示词
				msg.system(`你是一个续写与补全助手。`) 
				msg.system(`用户当前输入光标插入点前面的"""前置文本"""为: `+leftText);
				msg.system(`用户当前输入光标插入点后面的"""后置文本"""为: `+rightText);
					
				//添加用户提示词
				msg.prompt(`请在"""前置文本"""与"""后置文本"""中间继续写，仅回复可以直接插入其中的文本，不要返回"""前置文本"""与"""后置文本"""`);
					
				var ok,err = ai.messages(msg,function(delta){
					//以打字方式逐步输出 AI 回复的增量文本到目标输入框。
					winex.editor.sendString(delta)

					//如果不需要输入可以改用 winex.tooltip.popupDelta() 函数显示为屏幕汽泡提示，支持增量文本。
				} );
				
				if(err) winform.msgboxErr(err);
			},winform
		)
	};
})

winform.show();
win.loopMessage();
```

web.rest.aiChat 需要发送 HTTP 请求以执行调用远程接口的耗时操作，因此我们[创建多线程以避免阻塞键盘钩子消息](#thread)。

如果需要更好的效果，则建议在 AI 提示词中添加更多的信息，例如让 AI 知道目标进程的文件名，并要求 AI 根据不同的程序给出更合适的解答，完整示例请参考： [范例 - 超级热键调用 AI 大模型自动续写补全](../../../example/AI/aiHotkey.html) 

![复制 aardio 超级热键范例到 ImTip](https://www.aardio.com/zh-cn/doc/images/copy-to-imtip.jpg)


aardio 基于上面的范例已经内置了 F1 键 AI 助手，运行效果：

![F1 键助手](https://imtip.aardio.com/screenshots/fim.gif)

利用 F1 键还可以在 aardio 中调用 AI 写其他编程语言的代码，例如写 Python 代码：

![F1 键助手写 Python 代码](https://www.aardio.com/zh-cn/doc/images/fim-py.gif)

在调用 AI 续写补全时，清晰的提示很重要。例如上面我们简明扼要地通过变量命名与注释让 AI 明确  pyCode 里放的是 Python 代码。在编码补全时，在清晰的注释提示后面补全有更好的效果。 注意用法，那么在 aardio 环境中调用 AI 写前端代码、Python 代码、 Go 语言的代码的效果会很好，利用 AI 可以更好地利用 aardio 在混合语言编程上的优势。

## ▶ 在超级热键中获取输入上下文、输入位置与状态

获取输入光标前后的文本：

```aardio
//允许安装扩展库 
import ide;

//导入此扩展库则在当前线程范围启用 JAB 以支持 Java 开发的程序。
import java.accessBridge;

//导入外部编辑器接口
import winex.editor; 

/*
获取当前输入窗口光标插入点前后的文本，
支持各种自动化接口，任何接口都不可用时退化为模拟按钮复制操作。
*/
var leftText,righText = winex.editor.getText2(true);

//获取当前行光标插入点之前的文本，如果存在选区优先返回选区文本。
var caretText = winex.editor.caretText() 
```

将 leftText,righText 作为上下文发给 AI 助手就可以方便地实现续写与补全效果。

相关范例: [获取外部编辑器文本](../../../example/Automation/Text/editor.html) [AI 续写与补全](../../../example/AI/aiHotkey.html)

获取前输入窗口的文本选区：

```aardio
import ide; 
import java.accessBridge;  
import winex.selection;
 
/*
获取选区，
参数 @1 为 true 允许在获取失败时复制文本，
参数 @2 为　true 则通过 UIA 接口获取到空文本时尝试复制。
*/
var selText = winex.selection.get(true,true);
```

一个常见的应用是获取选区查单词或者翻译：[示例源码](#web.view) 


获取输入法状态：

```aardio
import key.ime;
import winex.candidate;

//是否正在显示输入法候选窗
var caretRect = winex.candidate.visible()

//输入法状态
var opened,symbol,lang,conv  = key.ime.state()
 
```

如果提前导入 java.accessBridge 扩展库则上述获取编辑框文本信息的功能自动支持启用了 JAB 接口的 Java 程序窗口，不需要任何其他步骤或操作。

```aardio
import ide; //允许 IDE 按需自动安装扩展库
import java.accessBridge; //在当前线程范围启用 JAB 扩展。
```

获取当前输入光标的位置：

```aardio
import winex.caret;

/*
获取光标位置，
返回值为 ::RECT 结构体（含 left,top,right,bottom 字段）, 
返回结构体额外有一个 hwnd 字段记录输入焦点窗口句柄。
*/
var caretRect = winex.caret.get()
```

如果需要获取 WPF 窗口与 Java 窗口的输入光标位置请参考 winex.caret.getEx 函数说明与源码实现。

## ▶ 在超级热键中常用的自动化操作 <a id="auto" href="#auto">&#x23;</a>

请参考： [自动化程序开发](../../../guide/quickstart/automation.md)

### 1. 获取与设置输入焦点：<a id="focus" href="#focus">&#x23;</a>

在 aardio 中可使用 `winex.getFocus()` 获取当前输入焦点所在的窗口句柄。在 aardio 中很多与自动化有关的参数在省略  hwnd 参数时都会自动调用 `winex.getFocus()` ，例如前面的获取输入框文本与状态有关的函数。

如果要修改外部线程的输入焦点，则必须先用 winex.attach 附加到目标线程以共享输入状态，示例：

```aardio
winex.attach(hwnd,function(){
	win.setFocus(hwnd)
});
```

### 2. 向外部窗口发送字符串：<a id="sendString" href="#sendString">&#x23;</a>


```aardio
import winex;
import winex.editor;
import key;

//自动选择合适的发送文式
winex.editor.sendString("这里是要发送的字符串")

//使用剪贴板与模拟粘贴发送字符串
winex.editor.sendStringByClip("这里是要发送的字符串")

//直接发送所有字符，不需要发送按键，适用于支持 EM_REPLACESEL 消息的传统编辑框
winex.sendString("这里是要发送的字符串")

//发送字符串，换行发送回车键，制表符发送 tab 键，其他非控制字符直接发送
key.sendString("这里是要发送的字符串")
```

请参考：[自动发送文本](sendString.md)

key.sendString 类似输入法的效果，通常是更好的选择。但是 key.sendString 对于控制键发送的是按键而不是字符，对于 tab 或 enter 键可能自动触发代码补全的编辑器（例如 aardio 编辑器）使用 winex.sendString 是更好的选择。而 winex.editor.sendString 则自动进行判断并选择更合适的发送方式，编写 aardio 插件时，使用 ide.getActiveCodeEditor 函数可以获取到直接可以操作的编辑框对象，这时候可以使用返回编辑框的  selText 属性直接输入文本覆盖到当前选区或插入点。

### 3. 获取按键状态 <a id="keyState" href="#keyState">&#x23;</a>

参考：[虚拟键名称与代码](virtual-key-names.md)

- 在 aardio 中可以使用 `虚拟键名` 或 `虚拟键码` 表示键盘上的按键。虚拟键名称通常与键盘上显示的名称相同。
- 可调用 key.getName(virtualKeyCode) 函数将`虚拟键码` 转换为字符串类型的`虚拟键名`，也可调用 key.getCode(virtualKeyName) 函数将`虚拟键名`或者`虚拟键码`都统一转换为数值类型的`虚拟键码`。
- key 库函数表示按键的参数基本都兼容 `虚拟键名` 或者 `虚拟键码`。

获取获取按键状态可使用 `key.getState()` 或 `key.getStateX()` 函数，这两个函数都支持以键名或键码作为参数。

主要区别：

- key.getState() 主要用于自界面线程的消息队列中检测按键状态（模拟按键操作也会影响这个函数的返回值），界面线程在后台时仍然可用。
- key.getStateX() 则用于检测真实物理按键的状态，在工作线程中也可以使用。

在超级热键中还可以使用 superHotkey 对象的 [onKeyDown,onKeyUp 事件](#event) 检测按键状态。

获取鼠标按键状态：

- 使用 mouse.state() 函数获取鼠标左键是否按下。
- 使用 mouse.rb.state() 函数获取鼠标右键是否按下。
- 使用 mouse.mb.state() 函数获取鼠标中键是否按下。

如果不想引入 mouse 库也可以直接调用 API，例如使用 `::User32.GetAsyncKeyState(1/*_VK_LBUTTON*/) & 0x8000` 就可以判断鼠标左键是否按下。

### 4. 模拟按键：<a id="key-press" href="#key-press">&#x23;</a>

```aardio
//可转换为虚拟按键的字符发送对应按键，其他字符用 key.sendString 相同的规则直接发送
key.send("/hello中文")

//发送按键，可用任意个参数指定要发送的虚拟键名或键码
key.press("ENTER")

//发送组合键，可用任意个参数指定要发送的虚拟键名或键码
key.combine("CTRL","A")

//仅按下按键，可用任意个参数指定要发送的虚拟键名或键码
key.down("CTRL")

//释放按键，可用任意个参数指定要发送的虚拟键名或键码
key.up("CTRL")
```

在超级热键中如果需要模拟键键，可用类似 `key.up("CTRL")` 的方法释放按键以改变目标程序获取的组合键状态。

[key 库函数参考](../../../library-reference/key/_.md)

### 5. 后台发送按键与鼠标消息

winex.key 可以向指定窗口后台发送按键消息（ 发送组合键则必须先调用 winex.attach 共享输入状态 ），winex.mouse 可以向指定窗口后台发送鼠标消息。不是所有程序都支持这种后台按键与鼠标消息，这种方法不是很通用。用法请参考相关库文档。

## ▶ 在超级热键中创建窗口界面、网页浏览器 <a id="web.view" href="#web.view">&#x23;</a>

在下面的超级热键示例中，我们调用 web.view 创建 WebView2 浏览器控件以展示查单词与英中翻译结果。

```aardio
import ide;//允许自动安装扩展库
import web.view.translate; //翻译窗口
import web.view.dict;//查单词窗口

superHotkey.loadTable({
    
    ["ctrl+Shift+#"] = function(){
        
        //获取当前选区文本
        var txt = winex.selection.get(true);
        if(!#txt) return true;//选区文本为空，继续发送按键
        
        var words = string.splitEx(txt,"\s");
         
		//返回函数对象以异步启动查词翻译避免阻塞热键消息。
        return function(){ 
			
            if(#words>3){ 
				//创建 WebView2 浏览器控件以展示翻译结果。
                ..web.view.translate(txt);   
            }
            else{
				//创建 WebView2 浏览器控件以展示查单词结果。
                ..web.view.dict(txt,true)
            }
        }  
    }
);
```

要点：

- 如果不创建新线程，则热键回调函数应当返回一个函数对象启动新的界面。
这样热键回调可以先返回，再异步延时启动窗口，避免启动窗口耗时并阻塞热键消息。
- 如果使用 web.view 创建  WebView2 浏览器控件，则建议使用单例模式重用之前创建的浏览器。
跳转一下网址比每次都创建新的浏览器控件肯定要快很多倍，上面的 web.view.dict，web.view.translate( 就是这样做的，可以参考这几个库的源码。 
- 创建这种用于外部窗口的提示工具，可以在 win.form 构造参数表中添加 `parent=win.getForeground();` 参数将父窗口指定为前景窗口的子窗口以避免窗口出现在后台，可选添加 `topmost=true` 参数让窗口保持显示在最顶层。
- 使用 `winform.show(4/*_SW_SHOWNOACTIVATE*/)` 显示窗口可避免抢占当前输入焦点。 
- 如有必要，可选使用 winex.attach 结合 win.setFocus 设置或改变外部窗口输入焦点。

相关范例： [获取选区调用本地词库查单词](../../../example/Automation/Text/selection.html)

## ▶ ImTip 的超级热键 <a id="imtip" href="#imtip">&#x23;</a>


开源软件 [ImTip](http://imtip.aardio.com) 的超级热键基于 key.hotkey 库。

在 ImTip 中点击『编辑超级热键』按钮就可以调用 aardio 编辑器打开 ImTip 热键配置代码（ 文件路径为 `%LocalAppData%\aardio\std\ImTip\.hotkey\hotkey.aardio` ）。 

![ImTip 超级超键](https://imtip.aardio.com//screenshots/hotkey.jpg)

只要是从 ImTip 中点击『编辑超级热键』按钮打开 hotkey.aardio ，那么在 aardio 中保存对 hotkey.aardio 的修改时新的热键配置就会在 ImTip 中立即生效。

ImTip 运行超级热键时会自动查找 aardio 开发环境，并以 aardio 目录作为运行超级热键的 [应用程序根目录](../../builtin/io/path.md#app-path)，因此超级热键可以调用 aardio 开发环境的所有库。

示例：

```aardio
import win.ui;

/*开发环境（请勿修改）{{*/
//如果是在开发环境中启动，而不是由 ImTip 启动 
if(_STUDIO_INVOKED && ...!="ImTip"){

	//显示测试窗口
	var winform = win.form(text="超级热键";right=759;bottom=469)
	winform.add(
	edit={cls="edit";left=29;top=24;right=727;bottom=420;db=1;dl=1;dr=1;dt=1;edge=1;multiline=1;z=1}
	)
	
	//在 ImTip 中启动热键就不必要显示这个测试窗口
	winform.show();	
}
/*}}*/

import key.hotkey;
import win.dlg.chineseNumber;

superHotkey = key.hotkey();
superHotkey.loadTable({
	// 按 Ctrl+ $ 键打开大写金额与中文数字输入框
	["Ctrl+$"] = function(hFocus){  
		win.dlg.chineseNumber().show();
	};
})

win.loopMessage();
```

注意不要删除上面的 hotkey.aardio 代码中检测 aardio 开发环境与 ImTip 运行环境的代码。

ImTip 创建独立的工作线程运行超级热键（ hotkey.aardio ），每次更新超级热键配置都会退出原来的超级热键线程并且创建新的线程。在超级热键中可调用 [process.imTip](../../../language-reference/process/imTip/_.md) 库向 ImTip 主程序或主窗口发送指令。

在 ImTip 超级热键中可以导入并使用 ide 库，ide 库提供了丰富的 aardio 开发环境接口。

在超级热键中导入 ide 库还会启用启用自动安装缺少的扩展库到开发环境（ IDE ）的功能（ 在 IDE 中直接运行代码则总是启用此功能 ）。

示例：

```aardio
import ide;
import java.accessBridge;
```

## ▶ 调用 ImTip 聊天助手 <a id="imtip-ai-chat" href="#imtip-ai-chat">&#x23;</a>

直接调用 AI 大模型不需要会话界面请参考：[在超级热键中调用 AI 大模型接口](#ai) 

使用 [process.imTip](../../../library-reference/process/imTip/_.md) 库可自动打开 ImTip 的 AI 聊天助手会话界面，通过 chat 参数自动选择指定 AI 助手配置名称，并且自动发送 q 参数指定的问题。

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import process.imTip;
import winex.selection;
import key.hotkey;
superHotkey = key.hotkey();

superHotkey.loadTable({
	// 按 Ctrl+ I 触发热键
	["Ctrl+I"] = function(hFocus){  
		
	    //获取当前选区文本
        var txt = winex.selection.get(true);
        if(!#txt) return true;//选区文本为空，继续发送按键
        
        process.imTip(
        	chat = "",//可指定 ImTip 的 AI 助手配置名，也可指定空字符串
        	q = txt //指定要发送的问题
        )  
	};
})

winform.show();
win.loopMessage();
```

ImTip 增加 AI 助手配置图解：

![ImTip 增加或修改 AI 配置](https://imtip.aardio.com//screenshots/ai.gif)

我们还可以调用 process.imTip 向 ImTip 发送其他指令，例如自动禁用或启用输入法状态提示：

```aardio
import process.imTip;
process.imTip.imeSwitch();
```

## ▶ 更多超级热键示例 <a id="more" href="#more">&#x23;</a>


```aardio
/*导入库{{*/
import fsys;
import fsys.lnk;
import process;
import process.cache;
import process.popen;
import process.curl;
import winex;
import winex.mouse;
import winex.key;
import winex.accObject;
import win.dlg.chineseNumber;
import win.clip;
import winex.tooltip;
import winex.selection;
import winex.caret;
import win.reg;
import mouse;
import key;
import key.ime;
import key.hotkey;
/*}}*/

superHotkey = key.hotkey();
superHotkey.loadTable({

//复制输入焦点所在窗口类名
["Ctrl+F12"] = function(hFocus){  
	var cls = win.getClass(hFocus);
	winex.tooltip.trackPopup(cls + " 已复制到剪贴板!");
	win.clip.write(cls);
};

//运行QQ
["Ctrl+Q,Q"] = function(hFocus){ 
	var qqPath = process.cache.find("qq.exe");  
	process.execute( qqPath )
};

["@Shift"] = function(hFocus){
	/*
	如果 Ctrl,Shift,Alt,Win 等单控制键作为热键，显在前面加上@ 字符。
	则仅在按下并放开该键后（中间没有按其他键）才会触发热键。
	这通常不干扰该键原有热键（因为一般都是按下触发）。
	*/
} 

//按大写自动切换到英文输入
["CAPSLK"]  = function(hFocus){  
	key.ime.setOpenStatus(false);
	key.ime.setConversionMode(0); 
	
	return true;//允许按键继续发送，不改变大小写键的默认行为
};

//按 Ctrl + .  切换到中文输入 + 中文标点 + 小写
["Ctrl+."]  = function(hFocus){    
	var openState,mode = key.ime.state();
	if( openState && !key.ime.capital() ) return true; //当前已经是中文输入模式，不改变默认行为
	
	key.up("Ctrl");//先放开 Ctrl 键

	//如果是大写状态，切换为小写
	if(key.ime.capital())    key.press("CAPSLK") 

	//英文直接切中文 + 中文标点
	key.ime.setOpenStatus(true); //打开输入法
	key.ime.setConversionMode(1|0x400); //切换到中文状态，这一步不能省略
	
	//再次尝试用键盘切换中文标点，这一步不能省略
	key.combine("CTRL",".");
	
	//现在再次检测中文标点状态
	var openState,mode = key.ime.state();
	if(mode!=3/*_IME_SYMBOLMODE_SYMBOL*/){
		//说明切换到了英文标点，再切换回去
			key.combine("CTRL",".")
	}  
};

//改键演示
["Ctrl+."] = function(hFocus){  
	key.up("Ctrl"); //先把已经按下的键弹起来
	key.combine("CTRL","A"); //换成别的键，具体看 aardio 库函数文档
	return false; //阻止按键事件
};

//叠字键演示
["`"]  = function(hFocus){  
	var openState,mode = key.ime.state();//用法请查看 aardio 文档
	if(!openState 
			||  mode !=3 || key.getState("Shift")  
			|| key.getState("Ctrl")  
			|| key.getState("CAPSLK")  ) {
			return true; //允许此按键继续发送
	}
	
	key.combine("SHIFT","LEFT"); //向后选一个字
	key.combine("CTRL","C"); //复制
	key.press("RIGHT"); //取消选中
	key.combine("CTRL","V"); //粘贴
};

//取消次选键
[";"] = function(hFocus){
	if( winex.msCandidate.isVisible() ){
		key.send(" ;") 
	} 
	else return true;
};

//按 shift + back 变 ctrl + z
["SHIFT+BACK"] = function(hFocus){
	key.up("SHIFT"); //先把已经按下的键弹起来
	key.combine("CTRL","Z")
};

//中文模式输入斜杠“/”改为顿号
["/"] = function(hFocus){
	var openState,mode = key.ime.state();
	if( !openState /*&&(mode==3) */ ) return true; 
	key.sendString("、")
};

//切换鼠标左右键，经常换左右手耍鼠标是好习惯
["Ctrl+SHIFT+RIGHT"] = function(hFocus){  
	::User32.SwapMouseButton(!::User32.GetSystemMetrics(23));
}

//按 Shift + Back 变 Ctrl + Z，因为这时候 Shift 是按下状态，所以可以先发一个 key.up("SHIFT") 弹起shift键
["SHIFT+BACK"] = function(hFocus){
	key.up("SHIFT")
	key.combine("CTRL","Z")
};

//粘贴时替换指定的字符
["Ctrl+V"] = function(){
  var str = win.clip.read();
   
  if(str && string.find(str,"abcd")){
    str = string.replace(str,"abcd","");
    win.clip.write(str);  
  }
  
  return true; //执行默认操作 
}

//引号配对
[`SHIFT+"`] = function(hFocus){  
	var o,s = key.ime.state();
	key.sendString(s==3 ? `“”` : `""`); 

	//与目标窗口共享输入状态
	winex.attach(hFocus,true);
	
	//设置LSHIFT,RSHIFT 为弹起状态
	key.up("RSHIFT","LSHIFT","SHIFT");
	key.setState(false,"RSHIFT","LSHIFT","SHIFT"); 

	//移动光标
	key.press("LEFT");
	
	//取消共享输入状态
	winex.attach(hFocus,false);
} 

//括号配对
[`SHIFT+(`] = function(hFocus){  
	key.sendString(`()`);
	key.up("SHIFT"); 
	key.press("LEFT");
}

//右 SHIFT 键切换为英文
["RSHIFT"]  = function(hFocus){  
	key.ime.setOpenStatus(false);
	key.ime.setConversionMode(0); 
};

//左 SHIFT 键切换为中文
["LSHIFT"]  = function(hFocus){    
	var openState,mode = key.ime.state();
	if( openState && !key.ime.capital() ) return true; //当前已经是中文输入模式，不改变默认行为
	
	key.up("SHIFT");//先放开 SHIFT 键

	//如果是大写状态，切换为小写
	if(key.ime.capital())    key.press("CAPSLK") 

	//英文直接切中文 + 中文标点
	key.ime.setOpenStatus(true); //打开输入法
	key.ime.setConversionMode(1|0x400); //切换到中文状态，这一步不能省略
	
	//再次尝试用键盘切换中文标点，这一步不能省略
	key.combine("CTRL",".");
	
	//现在再次检测中文标点状态
	var openState,mode = key.ime.state();
	if(mode!=3/*_IME_SYMBOLMODE_SYMBOL*/){
		//说明切换到了英文标点，再切换回去
		key.combine("CTRL",".")
	}  
};

//按 `date 输入大写的当前日期
["~date"] = function(hFocus){ 
	var zh = string.chineseNumber('〇一二三四五六七八九');
	key.sendString(zh.date()); //改为 zh.time() 输出大写的当前时间
}; 

//增加音量
["Ctrl+F6"] = function(hFocus){
	key.press("VOLUME_UP");
}

//降低音量
["Ctrl+F7"] = function(hFocus){
	key.press("VOLUME_DOWN");
}

//切换静音
["Ctrl+F8"] = function(){
	key.press("VOLUME_MUTE");
}

//运行计算器
["~calc"] = function(hFocus){
	process.execute("calc.exe")
};

//创建 COM 对象，调用 Word
["~word"] = function(hFocus){
	var word = com.CreateObject("Word.Application")
	if(word)word.Visible = true; 
};

//微软五笔打开或关闭拼音混输
["Ctrl+,"] = function(hFocus){
	var reg = win.reg("HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS");
	var mode = !reg.queryValue("PinyinMixEnable") ? 1 : 0
	reg.setDwValue("PinyinMixEnable",mode)	
	
	key.ime.changeRequest(0x4090409)
	key.ime.changeRequest(0x8040804)
};

//不可直接在上述键盘回调函数中执行耗时操作，这会导致操作系统禁用热键。
//如果有耗时操作必须如下返回一个异步函数，将异步执行该函数，并取消已按键不再执行默认操作
[`SHIFT+"`] = function(hFocus){  
	return function(){
		key.waitUp("SHIFT")
		key.sendString(`"`);
		key.press("LEFT");
	} ; 
} 

};
```

## ▶ onKeyDown,onKeyUp 事件 <a id="event" href="#event">&#x23;</a>

超级热键（ key.hotkey 对象）允许自定义 onKeyDown,onKeyUp 事件。

```aardio
import key.hotkey; 
superHotkey = key.hotkey();

//按键时触发，此事件在检测超级热键规则前触发
superHotkey.onKeyDown = function(vk){
	
	//vk 参数为虚拟键码
	
	//返回 true 阻止按键继续发送，也会取消相关的超级热键。
	return true; 
	
}

//释放按键时触发，此事件在检测超级热键规则之后触发
superHotkey.onKeyUp = function(vk){ 
	
	//vk 参数为虚拟键码
	
	//返回 true 阻止按键继续发送。
	return true; 
	
} 

win.loopMessage();
```

下面的热键热键示例通过 superHotkey.onKeyDown 事件实现在中文输入模式下，输入数字后自动支持  `.,_:`  等常用数值分隔符，避免将小数点等数值分隔符输入为中文句号。

```aardio
import winex.candidate;
import key.number;
import key.hotkey; 
superHotkey = key.hotkey();

//按键时回调此函数，vk 为虚拟键码
superHotkey.onKeyDown = function(vk){
 
	//按下 CTRL,ALT 时忽略
	if(key.getStateX("CTRL") || key.getStateX("ALT") ) return; 
	 
	//输入法候选列表窗口正在显示时忽略
	if( winex.candidate.visible() ) {
		superHotkey.prevKeyCode = null;
		return;
	} 
	
	//当前输入是否数值分隔符
	var sep = key.number.getSeparator(vk);

	if(sep){ 

		//在此之前是否输入了数字
		if( key.number.is(superHotkey.prevKeyCode)){
			 
			//发送数值分隔符到目标窗口
			key.sendString( sep ); 

			//取消原按键事件
			return true;
		} 	
	} 
	 
	//记录上次的按键，但不记录 Shift 键
	if(vk!=0xA0/*_VK_LSHIFT*/ && vk!=0xA1/*_VK_RSHIFT*/){
		superHotkey.prevKeyCode = vk;	
	} 
}

win.loopMessage();
```

