# 自动化程序开发指南

## 运行外部程序 <a id="process" href="#process">&#x23;</a>


运行外部程序并创建进程主要使用  process 库。

仅仅是运行程序，可以使用 process.execute 以及 process.execute 前缀的系列函数。

运行程序示例：

```aardio
import process;
process.execute("notepad.exe")
```

process 所有创建进程的函数都可以指定命令行启动参数，这些命令行启动参数都有统一的规则。命令参数如果是单个字符串则直接传给启动进程，如下：

```aardio
import process;
process.execute("cmd.exe","/k dir")
```

如果命令行启动参数是一个表对象，
则数组成员则会自动调用 string.args.join() 函数合并并自动处理转义。不用再考虑空格、引号这些带来的问题。

如果命令行启动参数是一个表对象，
则表中以键名以 - 或 / 开头的键值对自动合并为命令行参数（自动处理转义并在必要时添加双引号）键值对参数总是置于数组参数之前。

示例：

```aardio
import process;
process.execute("cmd.exe",{"/k"="dir"})
```

如果要创建进程对象并操作进程对象，则需要使用 process 类构造对象。
process 处理命令行启动参数的规则与 process.execute 一样，但是 process 可以使用多个参数替代单个数组参数。

示例：

```aardio
import process;
var prcs = process("cmd.exe","/k","dir"); //等价于 process("cmd.exe",{"/k","dir"});

//关闭进程，对象释放时会自动调用，但不用早关闭是好习惯
prcs.free();

```
process 的第三个参数可以用一个表指定 [ startInfo 结构体 ](../../library-reference/process/_.html#startinfoObject) 。


## WOW64 重定向 <a id="wow64" href="#wow64">&#x23;</a>


个别 64 位程序需要禁用 WOW64 重定向才能启动，示例：

```aardio
import process.wow64;
process.wow64.execute("osk");
```

## 外部窗口操作 <a id="winex" href="#winex">&#x23;</a>


aardio 所有操作窗口的库或函数都在 win 名字空间，而所有操作外部控件的库或函数都在 `winex` 名字空间。

要注意的是现代窗口通常是无传统控件句柄的窗口，只有顶层窗口存在句柄，内部的控件窗口是无句柄的，典型的例如新的计算器。

控制传统的有句柄控件窗口，可以使用  `winex.key`, `winex.mouse` 后台向窗口发送消息操控，也可以使用一些由发送消息实现的函数，例如向窗口发送文本的 `winex.sendString()` 函数，操作窗口主菜单的 winex.findMenu 函数等等。

但是现代程序的窗口，通常不支持发送传统的窗口消息去控制，因此这种技术使用场景越来越少。

比较重要而实用的是使用 `winex` 操作顶层窗口，因为无论什么程序他都得有一个顶层窗口，即使使用 UIA 等针对无句柄窗口的自动化技术，先找到顶层窗口句柄通常比让 UIA 自己去全局查找更快。

示例：

```aardio
import winex; 
import process; 

//启动计算器
process.execute("calc.exe")

//等待计算器窗口激活
var hwnd = winex.waitActive("计算器",,"ApplicationFrameWindow")
```

`winex.waitActive` 的作用是等待窗口创建并激活，函数原型如下：

```aardio
winex.waitActive(父窗口标题,控件文本,父窗口类名,控件类名,控件ID,进程ID,第几个匹配)
```

所有参数都是可选的（至少指定一个参数）。父窗口标题，控件文本,父窗口类名,控件类名都支持 [模式匹配](../language/pattern-matching.md) 语法。

winex.findActivate 的参数用法与 ```winex.waitActive``` 相同，区别是 ```winex.findActivate``` 是找到窗口并激活窗体，但 如果找不到窗口时并不会等待。

## 使用窗口探测器 <a id="winspy" href="#winspy">&#x23;</a>


aardio 工具的『探测器』目录提供了多种不同的窗口与控件探测工具。

最基本的『窗口探测』（WinSpy）是最常用的，可以查看到目标窗口以及启动进程的许多有用数据。

![winspy](https://www.aardio.com/zh-cn/doc/images/winspy.gif)

而对于非句柄窗口，可以使用 UIA 与 MSAA 探测器，但这些探测器虽功能很多，但比较难用，操作不便，而且会出现卡顿干扰等问题。

aardio 代码开发的 FlaUI 探测器用于无句柄窗口则比较流畅，一般建议使用这个，生成的示例代码一般稍改改就可以用。

## UIA <a id="uia" href="#uia">&#x23;</a>


基于 .NET 的 UIA 组件有一个好处是系统自带，但原始的 UIA 接口操作不易，aardio 已经进行了简化，但相比 FlaUI, 原始 UIA 接口相对麻烦。

UIA 有两个完全兼容的库，接口完全相同。
- 系统自带的 System.Windows.Automation
- 扩展库 System.Windows.Automation.3 ，基于开源项目 UIAComWrapper，只有导入时需要写 `import System.Windows.Automation.3`, 使用的时候则仍然使用 `System.Windows.Automation` , 这是 aardio 的一个全局通用的规则 - 只能在导入语句中指定扩展库版本号。

System.Windows.Automation.3 的好处是 扩展了一些原来需要通过 COM 接口调用的功能，例如支持 TextPattern2 。aardio 中取光标位置的 winex.caret 以及很多用到 winex.caret 的库都引入了 System.Windows.Automation.3 。

通常建议使用 System.Windows.Automation.3 ，引入了 System.Windows.Automation.3 就不应该引入 System.Windows.Automation。

基本用法示例

```aardio
import System.Windows.Automation;

//访问 .NET 类的静态成员
Automation = System.Windows.Automation;
AutomationElement = Automation.AutomationElement;

//直接获取当前输入焦点所在窗口的 UIA 节点对象
var ele = AutomationElement.RootElement.FocusedElement;
assert(ele,"输入焦点窗口没有找到 UIA 节点")

//取窗口句柄，自 Current 属性取节点的其他属性比较方便
var hwnd = editBox.Current.NativeWindowHandle;//获

//自窗口句柄得到 AutomationElement 对象
ele = Automation.AutomationElement.FromHandle(hwnd);

//鼠标操作，移动鼠标到控件位置
import mouse;

//鼠标移到 UIA 节点上，mouse 库所有函数都支持将 UIA 控件替代坐标 x,y 这两个参数。
mouse.moveTo(ele);
```

UIA 获取控件文本：

```aardio
import System.Windows.Automation; 
Automation = System.Windows.Automation;
AutomationElement = Automation.AutomationElement;

//直接获取当前输入焦点窗口的 UIA 节点对象
var ele = AutomationElement.RootElement.FocusedElement;

if(ele ? ele.Current.ControlType == Automation.ControlType.Edit){ 
try {
	//获取 Pattern 失败会抛出异常
	var textPattern = editBox.GetCurrentPattern(Automation.TextPattern.Pattern);
	
	//获取全部文本
	var text = textPattern.DocumentRange.GetText(-1);

	print(text);
}	
catch(e){
	print(e);
}
}
```

使用 GetCurrentPattern 可以获取很多不同的 Pattern 实现不同的功能。

要注意的是很多 UIA 控件用上面的方式取不到文本，用最简单的 ele.Current.Name 反而可以取到文本，这是一个很流行的做法。

UIA 查找节点是最复杂的一部分，aardio 对这部分进行了封装与简化，提供了更简单的 Automation.Find 函数，Automation.Find 函数的参数可以是一个或多个表，一个表中的所有名值对组成 `And` 操作符的与条件（如果单个名值对的值为数组，则多个不同的值构 `Or` 操作符的或条件），而多个不同表参数组成 `Or` 操作符的或条件。但大多时候没那么复杂，一个表参数通常够用。

Automation.Find 函数的第一个参数可选指定一个 UIA 根节点（ 如果不指定则不要保留参数占位），凡是 Find 函数返回的 UIA 节点都有 Find 方法（其他函数返回的 UIA 节点没有）。

下面我们是一个 UIA 操作 Win10/Win11 新版计算机的示例：

```aardio
import winex;
import mouse;
import process; 
import System.Windows.Automation;

if(!_WIN10_LATER) error("此范例支持 Win10 以上版本的计算器")

//启动计算器
process.execute("calc.exe")

//等待计算器窗口激活
var hwnd = winex.waitActive("计算器",,"ApplicationFrameWindow")

//访问 .NET 类的静态成员
Automation = System.Windows.Automation;
AutomationElement = Automation.AutomationElement;

//查找计算器窗口
var calcWindow = AutomationElement.FromHandle(hwnd);

//等待创建按钮控件
var numButton1 = win.wait( function(){

//查找数字 1 按钮
return Automation.Find(calcWindow,{
	AutomationId = "num1Button" 
})
})

//查找其他按钮（不需要再调用 win.wait 等待）
var numButton2 = Automation.Find(calcWindow,{
AutomationId = "num2Button" 
})

//数字 3
var numButton3 = Automation.Find(calcWindow,{
AutomationId = "num3Button" 
})

//加运算按钮
var addButton = Automation.Find(calcWindow,{
AutomationId = "plusButton" 
})

//等于按钮
var equalButton = Automation.Find(calcWindow,{
AutomationId = "equalButton" 
})

//点击数字按钮 1
var invokePattern = numButton1.GetCurrentPattern(Automation.InvokePattern.Pattern);
invokePattern.Invoke();

//点击 + 按钮 
var invokePattern = addButton.GetCurrentPattern(Automation.InvokePattern.Pattern);
invokePattern.Invoke();

//点击数字按钮 2
var invokePattern = numButton2.GetCurrentPattern(Automation.InvokePattern.Pattern);
invokePattern.Invoke();

//用鼠标点击等号按钮，mouse 库函数直接支持以 .NET 控件作为参数
mouse.click(equalButton);

//也可以用参数 1,2 指定控件内部的相对 x,y 坐标 
mouse.click(2,3,equalButton);

//显示结果的节点
var resultText = Automation.Find(calcWindow,{
AutomationId = "CalculatorResults" 
}) 

//获取结果
var text = resultText.Current.Name;
var num = string.match(text,"[\d\,]+");
num = string.replace(num,",","");

//输出结果
print(resultText.Current.Name)
```

## FlaUI <a id="flaui" href="#flaui">&#x23;</a>

FlaUI 是底层基于 UIA 的开源项目，但接口大幅简化，操作更容易，可以使用 XPath 语法方便地查询节点。

以下是 FlaUI 操作计算器的例子，代码主要由 aardio 实现的 FlaUISpy 控测器生成：

![FlaUISpy](https://www.aardio.com/zh-cn/doc/images/FlaUISpy.gif)

示例代码：

```aardio
import FlaUI.UIA3;

//自窗口句柄直接获取窗口对象
//var window = FlaUI.FromHwnd(0x100E52); 

/*
查找窗口
参数@1: 可指定EXE文件名、EXE路径、进程ID。
参数@2: 窗口类名，支持模式匹配语法（首字符为 `@` 禁用模式语法）。
参数@3: 窗口标题，支持模式匹配语法（首字符为 `@` 禁用模式语法）。
*/
//var window = FlaUI.FindWindow("ApplicationFrameHost.exe","ApplicationFrameWindow","计算器");

//查找窗口，禁用模式匹配语法搜索窗口
var window = FlaUI.FindWindow("ApplicationFrameHost.exe","@ApplicationFrameWindow","@计算器");

if(window){

//前置窗口
window.Focus();

//使用 XPath 语法查找节点。 
var ctrl  = window.FindFirstByXPath(`//Button[8][@Name="七"][@AutomationId="num7Button"][@ClassName="Button"]`);

//将节点转换为按钮，并单击按钮
FlaUI.AsButton(ctrl).Invoke();

//移动鼠标到 UIA 节点内的相对坐标
//mouse.move(88,61,ctrl);

//单击鼠标
//mouse.click(88,61,ctrl);

//输入字符串
//key.sendString("发送内容")
}	
```

最简单的几个 XPath 语法规则：

- XPath 用斜杠分开节点
- 单斜杠 / 表示选择当前节点的子节点。
- 两个斜杠 // 表示选择当前节点下面任意深度的后代节点（不要求位置是直接子节点）。
- 如果路径开始于单个斜杠 / ，则表示从根节点开始查找。
例如 XPath `/Window/Edit` 表示找根节点的子节点 Window 的子节点 Edit。这里的 Window, Edit 指的是节点类型（ControlType）。
- 属性置于方括号内并以 @ 字符作为名称前缀。可查询的属性有：AutomationId， Name，ClassName，HelpText 。可以用探测工具 FlaUInspect 查看这些属性。例如 `[@Name="文件传输助手"]` 。
- 数值置于方括号内表地序号，例如上面的 `//Button[8]`，如果去掉序号也能找到，并且控件的序号可能会变动，民么建议去掉序号。属性声明通常比序号靠谱。

## MSAA <a id="msaa" href="#msaa">&#x23;</a>


所有 Windows 系统都自带 MSAA，夺于 COM 的接口简单，易于使用，生成的 EXE 程序体积也会很小。aardio 标准库 [winex.accObject ](../../library-reference/winex/accObject/_.html)  则对 MSAA 做了进一步封装，用法就更简单了。

虽然 MSAA 是 UIA 的上一代技术，但某些场景 UIA 不正常的 MSAA 反而能解决问题。

以 Chrome 浏览器，我们用窗口探测器检测一下窗口类名等信息：
![winspy](https://www.aardio.com/zh-cn/doc/images/winspy.gif)

拖动『窗口探测器』左下角的十字图标到目标窗口上，就会显示窗口信息。

使用窗口探测器我们可以发现 Chrome, Edge 等浏览器的网页窗口类名都是 "Chrome_WidgetWin_1", 所以我们可以用下面的 aardio 代码获取所有打开的浏览器窗口：

```aardio
import winex;
import winex.accObject;

//遍历浏览器窗口（兼容 Chrome，Edge 等）
for hwnd,title in winex.each("Chrome_WidgetWin_1") { 

//获取 MSAA 接口对象
var accObject = winex.accObject.fromWindow(hwnd);  
print(hwnd,title,accObject);
}
```

请在 aardio 中打开 winex.accObject 的文档或源码，搜索“ACC对象浏览工具” 并下载该工具（ inspect.exe ）。

运行 inspect.exe ，点选下图的『 Watch Cursor 』图标：

![winspy](https://www.aardio.com/zh-cn/doc/images/inspect.jpg)

也就是允许探测鼠标指向的窗口。

然后将鼠标移向浏览器的地址栏，Inspect 找到了地址栏所在的 ACC 对象，并显示了一堆信息，我们重点关注这几行：

```
Name:  "Address and search bar"
Role:  editable text (0x2A)
```

Name 是 ACC 对象的名称。
Role 是 ACC 对象的角色，其实就是控件类型。

根据上面的信息，我们修改代码获取浏览器地址栏：

```aardio
import winex;
import winex.accObject;

//遍历浏览器窗口（兼容 Chrome，Edge 等）
for hwnd,title in winex.each("Chrome_WidgetWin_1") { 

//获取 MSAA 接口对象
var accObject = winex.accObject.fromWindow(hwnd);  

//查找地址栏
var edit = accObject.find(
	role = 0x2A;
	name = "<Address and search bar>|<地址和搜索栏>";
)

//显示地址栏的内容
if(edit) print( edit.value() );
}
```

在 aardio 中运行上面的代码，我们方便地地拿到了浏览器地址栏的网址。

拿到一个 accObject 对象以后，可以调用 `accObject.find()` 函数继续查找符合条件的子节点。而查找参数就是我们用 Inspect.exe 探测到的参数。

查找参数中，role, state 可以是文本，也可以是数值，一般建议用数值（ 速度更快 ）。

上面的 name 参数用到了模式匹配：

```aardio
name = "<Address and search bar>|<地址和搜索栏>";
```

## 获取与设置输入焦点：<a id="focus" href="#focus">&#x23;</a>

在 aardio 中可使用 `winex.getFocus()` 获取当前输入焦点所在的窗口句柄。在 aardio 中很多与自动化有关的参数在省略  hwnd 参数时都会自动调用 `winex.getFocus()` ，例如前面的获取输入框文本与状态有关的函数。

如果要修改外部线程的输入焦点，则必须先用 winex.attach 附加到目标线程以共享输入状态，示例：

```aardio
winex.attach(hwnd,function(){
win.setFocus(hwnd)
});
```

## 向外部窗口发送字符串：<a id="sendString" href="#sendString">&#x23;</a>


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

请参考：[自动发送文本](../../library-guide/std/key/sendString.md)

key.sendString 类似输入法的效果，通常是更好的选择。但是 key.sendString 对于控制键发送的是按键而不是字符，对于 tab 或 enter 键可能自动触发代码补全的编辑器（例如 aardio 编辑器）使用 winex.sendString 是更好的选择。而 winex.editor.sendString 则自动进行判断并选择更合适的发送方式，编写 aardio 插件时，使用 ide.getActiveCodeEditor 函数可以获取到直接可以操作的编辑框对象，这时候可以使用返回编辑框的  selText 属性直接输入文本覆盖到当前选区或插入点。


## 获取按键状态 <a id="keyState" href="#keyState">&#x23;</a>

参考：[虚拟键名称与代码](../../library-guide/std/key/virtual-key-names.md)

- 在 aardio 中可以使用 `虚拟键名` 或 `虚拟键码` 表示键盘上的按键。虚拟键名称通常与键盘上显示的名称相同。
- 可调用 key.getName(virtualKeyCode) 函数将`虚拟键码` 转换为字符串类型的`虚拟键名`，也可调用 key.getCode(virtualKeyName) 函数将`虚拟键名`或者`虚拟键码`都统一转换为数值类型的`虚拟键码`。
- key 库函数表示按键的参数基本都兼容 `虚拟键名` 或者 `虚拟键码`。

获取获取按键状态可使用 `key.getState()` 或 `key.getStateX()` 函数，这两个函数都支持以键名或键码作为参数。

主要区别：

- key.getState() 主要用于自界面线程的消息队列中检测按键状态（模拟按键操作也会影响这个函数的返回值），界面线程在后台时仍然可用。
- key.getStateX() 则用于检测真实物理按键的状态，在工作线程中也可以使用。

获取鼠标按键状态：

- 使用 mouse.state() 函数获取鼠标左键是否按下。
- 使用 mouse.rb.state() 函数获取鼠标右键是否按下。
- 使用 mouse.mb.state() 函数获取鼠标中键是否按下。

如果不想引入 mouse 库也可以直接调用 API，例如使用 `::User32.GetAsyncKeyState(1/*_VK_LBUTTON*/) & 0x8000` 就可以判断鼠标左键是否按下。

## 模拟鼠标按键 <a id="key-mouse" href="#key-mouse">&#x23;</a>

[key 库](../../library-reference/key/_.md) 提供模拟前台按键的函数，[mouse 库](../../library-reference/mouse/_.md) 提供后台按键的的函数。

```aardio
//模拟单个按键
key.press("ENTER")

//模拟组合键
key.combine("CTRL","SHIFT","U")

//键按下
key.down("TAB")

//键弹起
key.up("TAB")

//以字符为单位连续发送按键
key.send("abcd123")

//间隔 100 毫秒发送一个按键
key.send("abcd123",100)

/*
鼠标左键单击,参数 @3 为 true 表示绝对坐标
也可以用一个参数指定一个 ::RECT,::RECTF,::Point 结构体，
或者指定 .NET 返回的 Rect,Point 等提供相同字段的结构体，
也支持用 UIA 控件对象作为参数。
如果第一个参数是 UIA 控件则在控件内点击。
如果第三个参数指定 UIA 控件，则在 UIA 控件内的相对坐标 x,y 处点击。
*/
mouse.click(x,y,true)

//鼠标左键双击
mouse.clickDb();

//鼠标左键按下
mouse.down();

//鼠标右键单击
mouse.rb.click();

//鼠标中键单击
mouse.mb.click()

//鼠标中键滚动，负数向下滚动
mouse.mb.roll(-10)
```

## 使用 WebDriver 自动化控制浏览器 <a id="chrome-driver" href="#chrome-driver">&#x23;</a>


aardio 的 [chrome.driver 库](../../library-reference/chrome/driver.html)  封装了 WebDriver 协议，这个库使用非常简单。虽然不同的浏览器，以及浏览器的不同版本都要下载不同的 driver.exe ，但是 chrome.driver 可以自动匹配并自动下载合适的 driver.exe ，我们不需要任何其他的操作或步骤，直接使用就可以。

下面是示例源码：

```aardio
import chrome.driver;

/*
创建 chromeDriver 对象，支 Chrome，Edge（Chromium），Supermium 等相同内核浏览器。 
自动检测 chromeDriver 版本，并在必要时自动下载匹配版本的chromeDriver。
*/
var driver = chrome.driver();  

//添加 Chrome 启动参数
//driver.addArguments("--start-maximized") 
//driver.addArguments("--incognito") //无痕模式
//driver.addArguments("--headless") //无痕模式，看不到界面

//创建会话，打开chrome浏览器，调用参数仅用于演示( 可以省略 )。
var browser = driver.startBrowser( {
loggingPrefs  = { browser = 'ALL', performance = 'ALL', };
perfLoggingPrefs = {
	enableNetwork = true,
	enablePage= false,
	enableTimeline = false
} 
});

//打开网页
browser.go("https://www.aardio.com/zh-cn/doc/")

//查找文本输入框,返回的 DOM 对象也可以使用ququerySelector继续查找子节点
var ele = browser.querySelector("body").querySelector("#search-input"); 

//在网页输入文本，并发送按键。
ele.sendKeys( "多线程" ,"ENTER"  ) 

/*
可用键名定义于 chrome.driver.keys ，键名与 key,key.VK 库基本兼容。
如果要将键名设为普通文本，可改用 ele.setValue( "ChromeDriver","ENTER" )
*/

//调用 JS，并且可以返回值（也可以返回 DOM 节点对象）
var searchButton = browser.doScript(` 
	//可以使用arguments访问aardio传来的参数
	return arguments[0].querySelector("#search-button");
`
,browser.querySelector("body")//可以传任意个调用参数给JS,还可以直接传DOM节点对象
)


//JS 返回的 DOM 节点对象也可以操作控制
searchButton.click();

//等待网址
browser.waitUrl("多线程");

//打开新窗口(标签页)
browser.doScript("window.open('https://httpbin.org/cookies')");

//关闭原来的窗口(标签页)
browser.close();

//等待网址
browser.waitUrl("httpbin");

//修改 cookie
var ret,err = browser.cookie( { 
cookie = { name = "GUID",value = "09031171412667840400",domain="httpbin.org"} 
} )

//调用 CDP 命令
var ret,err = browser.cdp("Network.getCookies",{urls={"https://httpbin.org"}},);
var cookies = ret[["value"]];

//driver.startBrowser() 指定 loggingPrefs, perfLoggingPrefs
//var log = browser.se.log(type="performance"); //获取日志

browser.refresh();
```

## 使用 web.view 自动化网页 <a id="web-view" href="#web-view">&#x23;</a>


web.view 操作网页应当是最优选，如无必要应优先使用 web.view 而不是 chrome.driver 。

请参考: [web.view 使用指南](../../library-guide/std/web/view/_.md)

使用 wb.waitEle 函数：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="web.view( WebView2 ) - 调用 waitEle 等待节点";right=798;bottom=541;bgcolor=16777215)
winform.add()
/*}}*/

import web.view;
var wb = web.view(winform);

//打开网址
wb.go("https://www.aardio.com/zh-cn/doc/");

//用法一：异步等待参数@1指定 CSS 选择器的节点，回调 aardio 函数
/*
wb.waitEle("#search-input",function(ok,err){
wb.doScript("
	var searchInput = document.querySelector('#search-input');
	searchInput.value='多线程'; 
	searchInput.dispatchEvent(new Event('input', { bubbles: true, }));
")
})
*/

//用法二：不指定回调函数或回调 JS 脚本则同步等待参数 @1 指定CSS选择器的节点
wb.waitEle("#search-input");
/*
wb.waitEle 在单个网页内有效，打开其他网页则会取消等待。
如果要跨网页等待应改用 wb.waitEle2 函数。
*/

wb.doScript("
var searchInput = document.querySelector('#search-input');
searchInput.value='多线程'; 
searchInput.dispatchEvent(new Event('input', { bubbles: true, }));
")

winform.show();
win.loopMessage();
```

要注意 web.view 提供了与 wb.waitEle 参数用法相同的 wb.waitEle2 。区别在于：：

- wb.waitEle2  可跨网页等待，网址变更不会退出。
- wb.waitEle 仅在当前网页有效，当前网页关闭或跳转（ JavaScript 中的 document 文档对象变更）就会自动释放。

如果等待时网页可能发生跳转，务必使用 wb.waitEle2 函数。

wb.preloadScript 函数可在网页初始化时注入 JS 代码，这是做网页自动化非常有用的函数，在这个函数里可以修改很多 JS 默认函数实现有趣的功能，下面是一个 禁止刷新缩放的例子：

```aardio
import win.ui;
var winform = win.form(text="禁止按 F5，Ctrl + R 刷新")

import web.view;
var wb = web.view(winform);

//定义字符串 initScript，赋值为需要执行的 JavaScript
var initScript = /****

//禁止页面刷新
document.onkeydown = function (e) {
if (e.key == "F5" || (e.ctrlKey && e.key == "r") ) {
	e.preventDefault(); 
}
} 

//禁止滚轮缩放
document.addEventListener('wheel', function(e) {
if(e.ctrlKey) {
	e.preventDefault();
}
}, { passive: false });

****/

//添加网页默认加载执行的 JavaScript
wb.preloadScript(initScript)

wb.html = /**
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<script >alert("网页每加载一次，显示一次弹框")</script>
</head>
<body>已禁止刷新，禁止 Ctrl + 鼠标滚轮缩放。</body>
</html>
**/

winform.show();
win.loopMessage();
```

拦截弹窗：

```aardio
import win.ui;
var winform = win.form(text="web.view - 拦截网页弹窗")

import web.view; 
var wb = web.view(winform);

//弹出新窗口触发
wb.onNewWindow = function(url){

//耗时操作应返回异步自动执行的函数（提前结束 onNewWindow ）
return function(){ 
	//如果打开的是 file: 前缀网址，例如拖放文件到网页上。
	var filePath = inet.url.getFilePath(url)
	if(filePath){
		winform.msgbox(filePath,"本地文件"); 	
	}
	else {
		//用 wb.location 代替 wb.go 跳转网页则当前页面设为 HTTP referrer 请求头。 
		wb.location = url;
	} 
}
}

wb.html = /**
<!doctype html>
<html><head>
<base target="_blank" />
</head>

<body style="margin:50px">
<a href="http://www.aardio.com">aardio.com</a>
<button onclick="window.open('http://www.aardio.com')" >aardio.com</button>
**/

winform.show();
win.loopMessage();
```

使用 CDP 命令自动关闭弹框示例：

```aardio
import win.ui;
var winform = win.form(text="CDP 事件 - 自动关闭网页上弹出信息框")

import web.view; 
var wb = web.view(winform);
winform.show();

//允许监听页面事件
wb.cdp("Page.enable");

//订阅 CDP 事件
//https://chromedevtools.github.io/devtools-protocol/tot/Page/#event-javascriptDialogOpening
wb.cdpSubscribe("Page.javascriptDialogOpening",function(dlg){
/*
dlg.message 是对话框文本。
dlg.type 是对话框类型
dlg.url 对话框所在页面网址
*/

//为避免阻塞导致某些网页出现异常，应返回异步执行的函数关闭弹框。
return function(){
	//自动关闭弹框
	wb.cdp("Page.handleJavaScriptDialog",{accept=true})
} 
})

wb.html = /**
<script type="text/javascript">alert("测试弹框")</script>
**/
win.loopMessage();
```