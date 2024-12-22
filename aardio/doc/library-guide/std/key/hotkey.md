# 超级热键使用指南

标准库 key.hotkey 用于创建超级热键，超级热键是基于低级键盘钩子 [key.hook](../../../library-reference/key/hook.md) 实现的系统全局有效的增强热键。

- [key.hotkey 库参考](../../../library-reference/key/hotkey/_.html)
- [key.hotkey 范例](../../../example/Windows/Hotkey/key.hotkey.aardio)


## ▶ 检测超级热键的基本规则 

1. 如果首个按下的键不是控制键，则不需要同时按住多个键。
如果按下的键是已注册的热键前半部分，则阻止当前按键继续发送。
如果继续按键已不符合任何热键，则释放已捕获的按键并按原顺序重新发送。
2. 如果首次按住的是控制键（ CTRL,ALT,SHIFT,WIN 之一），则必须同时按住多个键才算已完成热键。
如果这样同时按住的多个键是一个已完成的热键，但同时又是其他热键的前半部分，则必须放开所有键才会生效。
3. 如果注册单个控制键热键，并且加上 @ 前缀，则放开该键（且中间没有按其他键）才算完成热键。
4. 按键保持按下不放时不会触发多次超级热键。

超键热键中任何键名都只表示该键名所在的单个按键，不包含上档键。例如热键 `~hi` 指连续按 3 个键，其中 `~` 不是指同时按 `Shift + ~` 这两个键。

## ▶ 超级热键格式说明

例如注册了以下 4 个热键，则对应热键格式的热键触发规则如下：

- 热键 `~hi` 用法：连续按 3 个键，每个键都要放开。
- 热键 `SHIFT+Q,Q` 用法：按下 `Shift` 不放，再按 2 下 `Q`。
- 热键 `Ctrl+K` 用法：按下 `Ctrl` 不放，再按 `K`, 然后都放开。
- 热键  `Ctrl+K,K`	用法：按下 `Ctrl` 不放，再按 2 次 `K`（因为不是其他热键的前半部分，不需要等待放开）。

## ▶ 注册超级热键

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

要注意必须在包含窗口的界面线程中才能使用 key.hotkey ， 创建 key.hotkey 对象时必须指定一个 winform 窗口对象作为参数。

superHotkey.loadTable 函数用于批量处册热键热键，参数 @1 指定热键配置表。热配置表中每个名值对都会调用 superHotkey.regStr 函数注册为热键，键名指定超级热键，对应的键值指定热键回调函数。热键回调函数用于响应热键并执行指定的代码。

热配置表中指定超级热键的键名可以是 [key.VK 库](../../../library-reference/key/VK.md) 定义的英文键名字符串，尾部可用 `'\0'` 表示终止键。热键不区分大小写，字符间不能有空白。如果超级热键的第一个按键是控制键并紧跟一个加号，后面所有键名都要使用逗号分开，例如 `Ctrl+Q,Q` 。

热键回调函数返回 true 表示允许系统继续发送按键，否则取消该按键，不再继续发送。
如果热键回调函数返回一个函数对象，则取消该按键不再发送，并在返回函数以后异步延时执行返回的函数对象。

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
import win.ui;

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

ImTip 创建独立的工作线程运行超级热键（ hotkey.aardio ），每次更新超级热键配置都会退出原来的超级热键线程并且创建新的线程。在超级热键中可调用 [processs.imTip](../../../language-reference/process/imTip/_.md) 库向 ImTip 主程序或主窗口发送指令。

## ▶ 避免阻塞键盘消息的耗时操作 <a id="thread" href="#thread">&#x23;</a>


超级热键基于低级键盘钩子，所在线程必须调用 `win.loopMessage()` 启动消息循环。

超级热键所在线程应避免阻塞消息循环的耗时操作，任何阻塞消息循环或热键回调函数的操作执行时间不应超过 200 毫秒。如果阻塞时间超过一秒或超过注册表限制的更小时间，系统可能会直接删除键盘钩子（导致超级热键不可用）。

**如果超级热键出现异常（例如热键失效，对按键的拦截失效，本应被取消的按键发送到了目标窗口等等问题），应当首先检查超级热键所在线程是否执行了阻塞钩子消息的耗时操作。**

建议用单独的线程运行超级热键，超级热键回调函数中创建新的线程执行耗时操作。请参考：[创建多线程](../../../guide/language/thread.md)。

## ▶ 示例: 按 `Ctrl+I` 调用 AI 助手处理选区文本 <a id="ai" href="#ai">&#x23;</a>


在下面的超级热键示例中我们调用 web.rest.aiChat 创建了一个 AI 助手以处理通过 winex.selection 获取的选区文本。AI 助手需要调用远程接口，发送 HTTP 请求属于耗时操作且会阻塞消息循环，因此我们创建多线程执行这些耗时操作以避免阻塞键盘钩子消息。

```aardio
 
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import winex.selection;
import key.hotkey;
superHotkey = key.hotkey();

superHotkey.loadTable({
	// 按 Ctrl+ I 触发热键
	["Ctrl+I"] = function(hFocus){  
		//获取当前选区文本
		var txt = winex.selection.get(true);
	
		if(!#txt) { 
			return true;
		}
			
		//创建多线程以执行耗时操作，以避免阻塞键盘钩子消息导致热键失效。
		thread.invoke( 
			function(txt){
				
				import web.rest.aiChat;
				import web.rest.aiChat.message;
				import key;
				
				var ai = web.rest.aiChat(
					key = "sk-请修改密钥";
					url = "https://api.deepseek.com/v1";//接口地址
					model = "deepseek-chat";//模型名称首字符为 @ 则使用 Anthropic 接口
					temperature = 0.5;//温度
					maxTokens = 1024,//最大回复长度
				)
				
				//创建 AI 会话消息队列 
				var msg = web.rest.aiChat.message();
				
				//添加系统提示词
				msg.system("你是一个翻译助手，如果用户输入主要为中文请翻译为英文，反之则将输入翻译为英文。")
					
				//添加用户提示词
				msg.prompt(txt);
					
				var ok,err = ai.messages(msg,function(delta){
					//以打字方式逐步输出 AI 回复的增量文本到目标输入框。
					key.sendString(delta)
				} );
			},txt
		)

	};
})

winform.show();
win.loopMessage();
	
```

## ▶ 示例: 按 `Ctrl+I` 创建浏览器控件展示 AI 搜索结果

在下面的超级热键示例中，我们调用 web.view 创建 WebView2 浏览器控件以展示 AI 搜索结果。

创建浏览器控件可能会有不易察觉的短暂阻塞过程。如果不使用多线程，阻塞键盘钩子消息就可能导致热键异常或失效。例如获取的选区文本非空时本应取消的 `Ctrl+I` 被发送到目标窗口，或导致后续的超级热键失效。

下面我们在热键回调函数中用 thread.invoke 创建多线程就可以避免上述的问题。

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import winex.selection;
import key.hotkey;
superHotkey = key.hotkey();

superHotkey.loadTable({
	// 按 Ctrl+ I 触发热键
	["Ctrl+I"] = function(hFocus){  
		
	    //获取当前选区文本
        var txt = winex.selection.get(true);
        if(!#txt) return true;//选区文本为空，继续发送按键
        
        //创建多线程
        thread.invoke( 
        	function(txt){
          		import win.ui;
        		var winform = win.form(
        			text="ImTip - AI 搜索";right=759;bottom=469;
        			parent=win.getForeground();//前置窗口
        			topmost=true;//窗口保持在最顶层
        		); 
        		
        		//创建浏览器
        		import web.view;
        		var wb = web.view(winform);
        		wb.go("https://metaso.cn",{q=txt});
        		winform.show();  
        		
        		win.loopMessage()		
        	},txt
        );  
	};
})

winform.show();
win.loopMessage();
```

这里有一个小技巧，在后台线程创建窗口时我们可以使用 `parent=win.getForeground();` 参数将父窗口指定为前景窗口以避免窗口出现在后台。而 `topmost=true` 参数让窗口保持显示在最顶层。

## ▶ 示例: 按 `Ctrl+Shift+I` 查单词，调用 AI 翻译

```aardio
import win.ui;
import win.ui;
/*DSG{{*/
var winform = win.form(text="超级热键示例")
winform.add(
edit={cls="edit";left=32;top=35;right=725;bottom=414;edge=1;multiline=1}
)
/*}}*/

import winex.tooltip;
import winex.selection; 
import winex.caret;
import key.hotkey;

superHotkey = key.hotkey();
superHotkey.loadTable({
	
	// 按 Ctrl + Shift + I 触发热键
	["Ctrl+Shift+I"] = function(hFocus){
		
		//获取当前选区文本
		var txt = winex.selection.get(true);
		if(!#txt) return true;//选区文本为空，继续发送按键
			
		//本地英中翻译查词
		import string.words;
		var cn,en = string.words(txt) 
		if(cn){
			var x,y = winex.caret.getPos();  
			winex.tooltip.popup(cn,x,y - 50); 
		}
		
		//朗读单词
		if(en){
			//用 := 操作符避免重复创建控件
			wmPlayer := com.CreateObject("WMPlayer.OCX"); 
			wmPlayer.url = "https://dict.youdao.com/dictvoice?audio="+txt+"&type=2";
			
			return;	
		} 
		
		//如果不包含空格分隔的英文单词则退出
		if(!string.find(txt,"\a+\s+\a+")){
			return true;
		} 
		
		//创建多线程以执行耗时操作，以避免阻塞键盘钩子消息导致热键失效。
		thread.invoke( 
			function(txt){ 
				import web.rest.aiChat;
				import web.rest.aiChat.message;
				import key;

				var ai = web.rest.aiChat(
					key = "sk-请修改密钥";
					url = "https://api.deepseek.com/v1";//接口地址
					model = "deepseek-chat";//模型名称首字符为 @ 则使用 Anthropic 接口
					temperature = 0.5;//温度
					maxTokens = 1024,//最大回复长度
				)

				//创建 AI 会话消息队列 
				var msg = web.rest.aiChat.message();

				//添加系统提示词
				msg.system("你是一个翻译助手，如果用户输入主要为中文请翻译为英文，反之则将输入翻译为英文。")

				//添加用户提示词
				msg.prompt("请翻译:"+txt);
				
				//获取文本选区坐标
				import winex.caret;
				var x,y = winex.caret.getPos(,-50);

				import winex.tooltip;
				var ok,err = ai.messages(msg,function(delta){ 
					
					//增量显示屏幕提示
					if( winex.tooltip.popupDelta(delta,x,y ) ){
						thread.delay(3000);//已完成输出，延时避免线程退出导致提示立即关闭。
					} 
				} ); 
				
				//显示错误信息
				if(err)winex.tooltip.popupDelta(err,x,y ) 
			},txt
		) 
	}
})

win.loopMessage();
```

## ▶ 调用 ImTip 聊天助手 <a id="imtip-ai-chat" href="#imtip-ai-chat">&#x23;</a>

如果不需要会话界面，可参考前面的范例：[自动输入回复文本到目标窗口](#ai) 。

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

![ImTip 增加或修改 AI 配置](https://imtip.aardio.com//screenshots/aiChat-setting.gif)

我们还可以调用 process.imTip 向 ImTip 发送其他指令，例如自动禁用或启用输入法状态提示：

```aardio
import process.imTip;
process.imTip.imeSwitch();
```

## ▶ 更多超级热键示例

先了解几个在自动化中较常用的发送按键与字符串的方法：

```aardio
//发送字符串
key.sendString("这里是要发送的字符串")

//发送按键
key.send("/")

//发送按键
key.press("ENTER")
```

下面是一些超级热键示例，ImTip 默认已经导入了下面范例中这些常用的库，也可以自行将新的 aardio 库按原路径放到 ImTip.exe 所在目录的 /lib/ 目录下，然后使用 import 语句导入。

```aardio
/*导入库{{*/
import fsys;
import fsys.lnk;
import process;
import process.cache;
import process.popen;
import process.curl;
import win.ui.ctrl.pick;
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
["Ctrl+#"] = function(hFocus){  
	//打开调色器 
	var dlg = win.ui.ctrl.pick();
	win.setTopmost(dlg.hwnd,true); 
	dlg.doModal();
};

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

//把斜杠“/”改为顿号
["/"] = function(hFocus){
	var openState,mode = key.ime.state();//
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

//运行word
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

winform.show();
win.loopMessage();
```

## ▶ 使用虚拟键码与键名获取按键状态

可调用 key.getName(vk) 函数将虚拟键码转换为字符串类型的键名，
也可调用 key.getCode(keyName) 函数将键名转换为数值类型的虚拟键码，此函数传入键码则直接返回。

全部键名与键码在 [key.VK](../../../library-reference/key/VK.md) 库中定义。

aardio 中与键盘操作有关的函数多允许以键名或键码作为参数指定按键，例如获取按键状态的 key.getState(),key.getStateX() 都支持以键名或键码作为参数。

鼠标按键较为特殊：

- 使用 mouse.state() 函数获取鼠标左键是否按下。
- 使用 mouse.rb.state() 函数获取鼠标右键是否按下。
- 使用 mouse.mb.state() 函数获取鼠标中键是否按下。

如果不想引入 mouse 库也可以直接调用 API，例如使用 `::User32.GetAsyncKeyState(1/*_VK_LBUTTON*/) & 0x8000` 可判断鼠标左键是否按下。