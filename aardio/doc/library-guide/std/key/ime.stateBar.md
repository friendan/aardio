# 输入法状态跟踪提示条

aardio 标准库 key.ime.stateBar 用于创建输入法状态跟踪提示条对象。key.ime.stateBar 通过在输入光标处显示 2 个简单的图标 —— 可以让我们在输入文本前就可以及时查看中英、中英标点、全半角、大小写、多语言键盘布局等所有输入法与键盘状态。

 key.ime.stateBar 对象基于以下函数、库、控件：

- 输入法与键盘状态检测，由 [key.ime.state](imeState.md) 函数实现。
- 获取当前文本输入窗口插入点位置，由 [winex.caret 库](../../../library-reference/winex/caret.md) 实现。
- 提示控件界面由 plus 控件实现，key.ime.stateBar 本质上就是一个扩展的 [plus 控件对象](../../std/win/ui/ctrl/plus.md) 

key.ime.stateBar 的主要应用就是流行的开源软件 [ImTip](https://imtip.aardio.com) 。

ImTip 运行效果：

![ImTip 输入法提示效果图](https://imtip.aardio.com/screenshots/imtip.gif)

## 1. 自定义显示规则 <a id="filter" href="#filter">&#x23;</a>


在 ImTip 的设置界面勾选『启用扩展规则』，然后再点击『编辑规则』按钮就可以在 aardio 开发环境中打开并使用 aardio 代码编写规则。

- 在 aardio 中保存规则代码就可以在 ImTip 实时生效。
- 规则代码在 ImTip 主界面线程运行，可以调用 aardio 开发环境的所有公共库。
- 如果在在规则代码中导入 ide 库并不能启用自动安装扩展库的功能，而在超级热键中导入 ide 库则支持自动安装扩展库。

在 ImTip 的规则文件中需要使用全局变量 imeBar 访问 key.ime.stateBar 对象。

使用窗口类名过滤窗口的示例：

```aardio
imeBar.onImeForegroundWindow = function(hwnd){

	//获取窗口类名
	var cls = win.getClass(hwnd);
	
	//检测类名，支持模式匹配 doc://guide/language/pattern-matching.html
	if(string.find(cls,"<禁止类名1>|<禁止类名2>")){
		
		//返回 false 禁止此窗口提示输入法状态
		return  false; 
	}
	 
}
```

用户每次切换到新的独立窗口都会调用 imeBar.onImeForegroundWindow  函数，参数 hwnd 为切换到的目标窗口句柄，imeBar.onImeForegroundWindow  函数返回 false 会阻止在该窗口检测或显示输入法状态 。

当然，我们还可以检测其他任何条件，例如创建目标窗口进程的执行文件名，示例：

```aardio
imeBar.onImeForegroundWindow = function(hwnd){ 
	
	//获取线程 ID，进程 ID。
	var tid,pid = win.getThreadProcessId(hwnd);
	
	//获取执行文件路径
	var path = process.getPath(pid);
	if(!#path) return;//普通权限无法获取管理权限进程文件名
	
	//转换为不含后缀的文件名
	var name = io.splitpath(path).name;

	//禁止提示的窗口
	if(IMTIP_DISABLED_APP[name]){
		return false; 
	}
}

//禁止提示的窗口
IMTIP_DISABLED_APP = {
	"禁止的执行文件名1" = true;
	"禁止的执行文件名2" = true;
}
```

在指定的窗口使用自定义的获取光标函数，以替代默认的 `winex.caret.get()` 函数:

```aardio
imeBar.onImeForegroundWindow = function(hwnd){ 
	
	if(string.find(cls,"<自定义窗口类名2>")){
		
		/*
		自定义获取输入光标位置的函数。
		返回值必须与 winex.caret.get 兼容。
		细节请参考 key.ime.stateBar 源码
		*/
		imeBar.getCaretEx = function(hwnd){
			
			//return caret,hFocus; 
		}
		
		return; 
	} 
}
```

imeBar.onImeStateChange 函数在检测输入状态后，显示输入状态前触发：

```aardio
imeBar.onImeStateChange = function(hFocus,imeX,imeY,openNative,symbolMode,text,iconText){
	return true;//允许提示
}
```

在为 ImTip 的规则代码在界面线程中执行，我们还可以做一些有趣的事，例如扩展托盘菜单：

```aardio
mainForm.onTrayMenu = function(menu){ 
	menu.add("打开 AI 助手",function(){
		import process.imTip;
		process.imTip(chat="");	
	});
	 
	menu.add();//分隔线
} 
```

## 2. 自定义外观样式 

key.ime.stateBar 基于 plus 控件，而 plus 控件自定义外观样式非常方便，key.ime.stateBar 也继承了这个优点。

ImTip 的外观配置界面：

![ImTip 外观配置](https://imtip.aardio.com/screenshots/color.gif)

点击每个颜色方块都可以打开增强的调色器，所有颜色都可以指定透明度，调到完全透明就可以隐藏对应的图标或者背景。

ImTip 可以导入导入外观配置方案，方案文件实现上就是一个 aardio 代码文件。

在 ImTip 上提供了很多 [外观方案](https://imtip.aardio.com/#schemes)，复制外观方案的 aardio 代码，然后在 ImTip 外观配置窗口点击粘贴按钮就可以了。

![粘贴外观方案](https://imtip.aardio.com/screenshots/copy.gif)

以下是一个单图标显示方案的示例:

```aardio
imeBar.imeSkin(/*ImTipConfig{{*/{
argbColor=16731983;
border={color=14395508;radius=6;width=0};
offsetX=13;
iconStyle={align="left";font={h=-17;name="imtip";weight=700};padding={top=4;right=6;left=1;bottom=0}};
background=16745333;
textRenderingHint=3;
openStyle={[1]={argbColor=16731983;background=16745333;border={color=14395508;radius=6;width=0};iconColor=-45233};[0]={argbColor=5291856;background=4700671;border={color=14395508;radius=6;width=0};iconColor=-11485360}};
align="left";
textPadding={top=0;right=0;left=-60;bottom=0};
tipChars={fullShape='\uF111';close='\uE801';hanja="漢";[1033]='\uF111';[2052]='\uF111';[1041]="あ";katakana="カ";halfShape='\uF042';[1042]="가";capital='\uF031';symbol='\uF111'};
width=55;
font={h=-18;name="imtip";weight=400};
iconColor=-45233;
foreground=16745333;
height=34;
offsetY=3;
iconTextRenderingHint=3;
valign="center"
}/*}}*/)
```

上面的外观方案背景透明，用红色表示中文模式，绿然表示英文模式，半圆表示半角标点，A 表示大写。

显示效果：  
![单图标方案显示效果](https://imtip.aardio.com/screenshots/imtip-dot.gif)

## 3. 兼容窗口类名 <a id="editorClasses" href="#editorClasses">&#x23;</a>


key.ime.stateBar 对象的 editorClasses 用于设置『兼容窗口类名』。

key.ime.stateBar 源码中 editorClasses 的默认配置如下：

```aardio
namespace key.ime;
class stateBar{
	ctor(form){ 
		this.editorClasses = {
			["AVL_AVView"]=1;["ConsoleWindowClass"]=1;["@WeChatMainWndForPC"]=1;["@ChatWnd"]=1;["#EXCEL6"]=1;
		};
	}
}
```

ImTip 输入法提示配置窗口的『兼容窗口类名』则是用分号分隔的字符串。

key.ime.stateBar  使用了多种不同的接口获取输入位置，但少数任何接口都不支持的应用窗口会退化为取鼠标输入指针位置。对于前述方式都不支持的窗口，可在『兼容窗口类名』中添加窗口类名（可使用 aardio 工具中的提供的窗口探测软件查看类名）。兼容类名写法规则如下：

- 如果兼容类名前面增加 `#` 字符则表示该窗口是一个较小的文本输入框，例如 `#EXCEL6`。
- 如果兼容类名前面增加 `@` 字符则表示优先通过 MSAA 接口获取输入框位置，典型的例如微信 3.x 可指定兼容类名为 `@WeChatMainWndForPC`。 
- 如果兼容类名前没有 `#` 或 `@` 字符，则退化为在鼠标指针位置显示输入状态提示。


## 4. 支持 Java 程序自动化接口 <a id="jab" href="#jab">&#x23;</a>


只要简单地提前导入 java.accessBridge 扩展库，
key.ime.stateBar  就可以自动支持使用 Java 程序自动化接口定位光标插入点，不需要任何其他的步骤或操作。

```aardio
import java.accessBridge
```


<br>