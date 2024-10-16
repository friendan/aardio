# aardio 中最重要的控件：自定义控件使用指南

aardio 中最强大的控件是 plus 控件，但最重要的控件是 custom 控件。不会用 plus 控件可能只是界面没那么好看，而不会用 custom 控件，你在 aardio 中将寸步难行。

aardio 开发环境「界面控件」工具箱里最后一个控件就是自定义控件（ custom 控件）。

## 用自定义控件嵌入外部子窗口 <a id="cls-path" href="#cls-path">&#x23;</a>

步骤如下：

1. 在 aardio 工程里找到其他新建的窗体代码文件。
右键点击该文件，复制文件路径，例如 `/.res/frmChild1.aardio`

2. 拖一个 custom 控件到风窗口上，
点击该控件，在控件属性窗口修改控件类名为 `/.res/frmChild1.aardio`

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="加载子窗口文件";)
winform.add(
custom={cls="~\example\Windows\Custom\.res\frmChild1.aardio";left=19;top=15;right=740;bottom=455;db=1;dl=1;dr=1;dt=1;z=1}
)
/*}}*/

winform.show();
win.loopMessage();
```

## 用自定义控件动态加载一个或多个子窗体 <a id="loadForm" href="#loadForm">&#x23;</a>


我们可以使用 winform.custom.loadForm( path ) 加载窗口。aardio 会自动将窗口加载为 winform.custom 的子窗口。

每次调用 winform.custom.loadForm( path )都会加载窗体代码并返回新的子窗体对象。
winform.custom 会成为容器管理所有加载的子窗口数组。

规则如下：
1. 当显示一个子窗口，其他子窗口就会自动隐藏。
2. 调用 winform.custom.loadForm( path ) 并不会释放之前加载的其他子窗体，而仅仅是隐藏他们。
3. 当关闭一个子窗口，他就会自动从 custom 控件容器的子窗口数组中移除。

示例代码：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="用 custom 控件加载一个或多个子窗体")
winform.add(
button1={cls="button";text="切换窗口 frmChild1";left=366;top=418;right=525;bottom=459;db=1;dr=1;z=2};
button2={cls="button";text="切换窗口 frmChild2";left=534;top=418;right=693;bottom=459;db=1;dr=1;z=3};
custom={cls="custom";text="自定义控件";left=21;top=14;right=741;bottom=380;db=1;dl=1;dr=1;dt=1;z=1}
)
/*}}*/

var frmChild1 = winform.custom.loadForm("~/example/Windows/Custom/.res/frmChild1.aardio")
winform.button1.oncommand = function(id,event){
	frmChild1.show();
}

var frmChild2 = winform.custom.loadForm("~/example/Windows/Custom/.res/frmChild2.aardio")
winform.button2.oncommand = function(id,event){
	frmChild2.show();
}

winform.show();
win.loopMessage(); 
```

## 自定义控件类 <a id="cls" href="#cls">&#x23;</a>


custom 控件与其他控件的主要区别是：控件的类名可以修改为任意 win.ui.ctrl 名字空间下的类名。

所有控件类都位于 win.ui.ctrl 名字空间，例如 plus 控件的类名为 "plus"，那么 win.ui 就会将 "plus" 自动转换为完整类名 "win.ui.ctrl.plus" ， 然后调用 "win.ui.ctrl.plus" 创建控件。

如果是基础控件只要在 开发环境「界面控件」工具箱直接拖到界面上就可以了，这些基础控件不需要写 import 语句，aardio 在开发时会导放所有基础控件，在发布时会按需发布程序实际使用的基础控件。

但是自定义控件首先要用 import 语句导入，不然 win.ui 在  win.ui.ctrl 名字空间找不到对应的控件类就无法创建控件。

实现自定义控件类有三种方式。

1. 由系统创建窗口，如果系统存在相同类名的控件就可以直接创建。否则可以在控件的构造函数中修改类名，下面我们看一下 win.ui.ctrl.hotkey 的部分有关代码：

    ```aardio
    namespace win.ui.ctrl;  
        
    class hotkey{
        ctor(parent,tParam){ 
                if(tParam){
                    //修改创建控件的实际类名
                    tParam.cls = "msctls_hotkey32";  
                };
        }
        @_metaProperty;
    }
    ```

    上面的代码指示使用系统类名 "msctls_hotkey32" 创建控件。控件创建成功以后，控件的 cls 属性会被还原为设计时类名 "hotkey"，而运行时类名 "msctls_hotkey32" 将会被保存到控件的 className 属性中。

    最后 aardio 会将控件的 hwnd 属性设置为窗口句柄。这是最重要的一步，所有对窗口的操作在控件内部都要通过句柄操作。

2. 由控件类自己创建窗口，这时候 aardio 就不管控件到底是怎么创建窗口了，唯一的要求就是在控件构造函数运行以后，控件的  hwnd 属性必须指向创建成功的子窗口的句柄。

    所以 win.ui 对控件的要求就是：要么你给一个有效的运行时类名我来负责创建控件窗口，要么你自己创建窗口把句柄值告诉我。

    由控件自己创建窗口的控件，最典型的代表控件就是 custom 控件。

    如果我们修改了 custom 控件的类名，那么实际创建的控件实际跟 custom 控件无关。但如果我们没有修改 custom 控件的类名，那么就会创建执行 win.ui.ctrl.custom 构造函数创建一个真正的 custom 控件。

    我们看一下 custom 控件的主要代码（只看与本文有关的部分）：

    ```aardio
    namespace win.ui.ctrl; 
    class custom { 
        ctor(parent,tParam){ 
            this = ..win._form(border="none";exmode="none";mode="child";parent=parent;
                left=tParam.left;top=tParam.top;right=tParam.right;bottom=tParam.bottom;tParam=tParam);
        } 
    }
    ```

    原来 custom 控件自己啥都没干，默认只是调用 win.form 创建了一个子窗口，并且把自己直接赋值为这个创建的子窗口。当然这个子窗口符合条件，winform 的 hwnd 属性那肯定是有效的窗口句柄。

    其实产这个最简单原始的空白 custom 控件也不是真的那么简单。custom 控件扩展了一些功能。例如在高级选项卡里，我们可以使用这样的 custom 控件作为多标签页的子窗体容器，用来管理并切换选项卡的内容区域。

    请参考：[aardio 范例：自定义控件类](https://www.aardio.com/zh-cn/doc/example/Windows/Custom/cls.html)


3. 无句柄的贴图控件

    如果在自定义控件类里指定控件的 onlyDirectDrawBackground 属性为 true，那么控件就不需要创建窗口，hwnd 属性也不会有一个窗口句柄值。

    典型的无句柄贴图控件就是 bk, bkplus 控件。

    请参考： [窗口背景贴图](../background.md)

下面是一个空白的自定义控件类：

```aardio
namespace win.ui.ctrl;

class myCtrl{
	ctor( parent,tParam ){
		
	};
}
```

说明：

- 窗口控件类必须 win.ui.ctrl 名字空间。
- 控件类构造参数 @parent 指向父窗体对象。
- 控件类构造参数 @tParam 指向创建控件的参数表。当我们在 "窗体设计器" 上绘制好控件，然后切换到 "代码模式" 可以看到每个控件都生成了一个创建参数表，这个参数表就是上面的 @tParam 参数。

有了上面的知识，下面我们一起创建一个自定义控件。

1. 拖一个 custom 控件到窗口上。
2. 把 custom 控件的类名改为你创建的控件类名，例如 "myCtrl"
3. 将窗口编辑器切换到代码模式，并在创建窗口前添加 import win.ui.ctrl.myCtrl 导入该控件。
4. 在标准库或者用户库中创建库文件 `/lib/win/ui/ctrl/myCtrl.aardio`。

然后我们在 myCtrl.aardio 中添加以下代码实现控件类：

```aardio
namespace win.ui.ctrl;

class myCtrl{
	ctor( parent,tParam ){ 
		this = ..win._form(border="none";exmode="none";mode="child";parent=parent;right=750;bottom=387;tParam=tParam)
		this.add(
			plus={cls="plus";left=-5;top=2;right=751;bottom=393;db=1;dl=1;dr=1;dt=1;repeat="scale";z=1}
		)	 
	};
}
```

上面的子窗体创建参数里：

- `parent=parent;`指定了父窗口。
- `mode="child";`指定了创建的是一个子窗口。

然后我们如下调用自定义控件：

```aardio
//用于支持在图像属性中直接指定网络图像
import inet.http;

//导入界面库
import win.ui;
/*DSG{{*/
var winform = win.form(text="自定义控件类";right=757;bottom=467)
winform.add(
myCtrl2={cls="myCtrl";text="自定义控件";left=3;top=-1;right=467;bottom=316;db=1;dl=1;dr=1;dt=1;z=1};
plus={cls="plus";left=168;top=280;right=465;bottom=353;notify=1;z=2}
)
/*}}*/

//显示窗口 
winform.show();

//这时候 winform.myCtrl2 就是 win.ui.ctrl.myCtrl 的实例对象.
winform.myCtrl2.plus.background = "http://download.aardio.com/v10.files/demo/images/custom.gif";

win.loopMessage();
```

## 使用自定义控件加载加载扩展控件 <a id="extension" href="#extension">&#x23;</a>


在 aardio 中我们还可以对任何一个窗口、或窗口上的子窗件进行扩展，这种用法在 aardio 中被大量使用，例如让窗口嵌入浏览器控件，以增加显示网页的功能。

这样的库非常多，例如 web.form,web.view,web.sysView,web.layout,web.sciter,chrome.app ……

示例：

```aardio
//扩展控件
import win.ui;
/*DSG{{*/
var winform = win.form(text="加载扩展控件";right=759;bottom=469)
winform.add(
button={cls="button";text="全屏";left=523;top=415;right=630;bottom=460;db=1;dr=1;z=2};
custom={cls="custom";text="自定义控件";left=17;top=26;right=732;bottom=380;db=1;dl=1;dr=1;dt=1;z=1}
)
/*}}*/

import web.form;
var wb  = web.form( winform.custom )

//导出允许网页调用的 aardio 函数
wb.external={
	close = function(){ winform.close()}
}

wb.html = /**
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <style type="text/css">
    html,body{ margin:50; } 
    </style>
</head>
<body>这是一个网页 <button id="fullscreen" onclick="external.close()">关闭</button>
**/

//全屏
winform.button.oncommand = function(id,event){
	winform.custom.fullscreen()
}

winform.show();
win.loopMessage();
```


