
# win.form 使用指南 - 如何创建窗口并添加控件

## 一. 窗体设计器 <a id="new" href="#new">&#x23;</a>


在 aardio 中创建窗口有以下方法：

- 在开发环境左上角点击"创建窗体设计器"的快捷图标，或者直接按 `Ctrl + Shift + N` 快捷键，可新建一个空白窗体。
- 打开工程向导，选择窗口程序，然后任务一个窗口工程模板，点击创建工程。
在创建工程以后，右键点选一个工程目录，点击"新建文件 / 新建窗体设计器"就可以创建窗口。

默认将在窗体设计器中以"设计视图"打开窗体，  
我们可以在开发环境左下方的"界面控件"选择和拖放控件到窗体上。  
点击窗体或控件，在右侧属性面板可以设置控件的属性。  

我们可以点击"代码视图"切换到代码编辑器模式，也可以直接按相同的 `Ctrl + U` 快捷键来回切换视图模式。在窗体设计器上直接双击控件也可以切换到代码模式并且为控件添加事件函数（默认会添加 oncommand 事件，不同的控件有所不同 ）。

## 二. 窗体设计器生成的代码结构 <a id="dsg" href="#dsg">&#x23;</a>


我们创建窗口，添加一个按钮与一个文本框，切换到代码模式，我们看到生成了以下代码：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form({ text="窗口标题";right=759;bottom=469 })
winform.add({
button1={cls="button";text="Button";left=550;top=414;right=701;bottom=458;z=1};
edit1={cls="edit";text="Edit";left=22;top=16;right=735;bottom=398;edge=1;multiline=1;z=2}
})
/*}}*/

winform.show();
win.loopMessage();
```

`/*DSG{{*/` 到 `/*}}*/` 之间的代码由窗体设计器自动生成，这部分代码默认会折叠并显示为『窗体设计器生成代码(请勿修改)』，通常直接修改这部分代码是不必要的，应当通过窗体设计器修改相关属性。

同一个代码文件不应当包含多个 `/*DSG{{*/ ... /*}}*/` 代码块。建议使用不同的代码文件创建不同的窗口，请参考: [创建多窗口程序](multi-window.md) 。

> 注意：win.form 类并不在 win.ui 名字空间下面，但必须使用 win.ui 库导入 win.form 类。这在 aardio 标准库中是一个特例，其他标准库导入的类或者名字空间与库路径会保持一致，例如 web.view 库会导入 web.view 类。

## 三. 调用 win.form 类创建窗体对象 <a id="ctor" href="#ctor">&#x23;</a>


原型：

```aardio
var winform = win.form(formPropertiesTable)  
```

说明：

参数 formPropertiesTable 是一个表对象。  
formPropertiesTable 包含的键值对定义窗口的属性。  
实际上 formPropertiesTable 就是我们在窗体设计器上设置的窗体属性认集合。  

win.form 返回 winform 对象，在 aardio 中一般窗体通常默认命名为 winform,只有程序的第一个主窗口会命名为全局变量 mainForm。

在 aardio 的文档一般会用 winform 泛指所有 win.form 创建的窗体对象。

示例：

```aardio
var winform = win.form({ text="窗口标题";right=759;bottom=469 })
```

在 aardio 中如果函数参数是一个表对象的构造器，  
并且第一个出现的元素是用等号分隔的名值对，则可以省略外层的括号，  
例如上面的代码可以简写为：

```aardio
var winform = win.form( text="窗口标题";right=759;bottom=469 )
```

注意上面 win.form 的参数写法不是命名参数而是省略了外层 `{}` 符号的表参数，aardio 里没有命名参数。

win.form 的构造参数不指定 left,top 坐标时则使用默认值 -1，这会让窗口显示在屏幕居中的默认位置。这时候窗口的宽度与高度分别为 right ＋ １,bottom ＋ １。如果 left,top 为小于等于 -2 的值则表示以窗口显示在屏幕右下角以后取得的左上角坐标作为原点计数。如果 left,top 为大于等于 0 的值则表示自屏幕左上角正常计数。

## 四. 调用 winform.add 函数添加控件 <a id="add" href="#add">&#x23;</a>


### 1. 原型：
 
```aardio
winform.add = function(controlsPropertiesTable) {
    /*
	controlsPropertiesTable 是一个键值对，定义控件集合 。
    键名为访问控件的名称，键名对应的值刚是描述每个控件属性的表对象。 
	格式：{控件访问名称 = {控件属性表}, ...}  
	*/
}
```

### 2. 说明：

controlsPropertiesTable 参数是一个表对象。
controlsPropertiesTable 包含的键值对定义了一个或多个控件，
键名为之后通过 winform 对象访问该控件的名称，键名对应的值刚是描述每个控件属性的表对象。 
每个控件的创建参数同样是一个包含描述控件属性键值对的表对象（ propertiesTable ），这些属性也就是我们在窗体设计器上为控件设置的设计时属性。


### 3. 示例：

```aardio
import win.ui; 
var winform = win.form({ text="窗口标题";right=759;bottom=469 });

winform.add({
	button1={//指定访问名称为  winform.button1
		cls="button";//指定用 win.ui.ctrl.button 类构造控件
		text="添加第一个按钮 button1 到  winform.button1";//控件显示的标题
		left=264;top=410;right=469;bottom=454;//控件位置
		z=1 //Z序
	};
	button2={//指定访问名称为  winform.button2
		cls="button";//指定用 win.ui.ctrl.button 类构造控件
		text="添加第二个按钮 button2 到 winform.button2";//控件显示的标题
		left=499;top=410;right=688;bottom=454;//控件位置
		z=2 //Z序
	};
	edit1={//指定访问名称为  winform.edit1
		cls="edit";//指定用 win.ui.ctrl.edit 类构造控件
		text="添加第一个编辑框 edit1 到  winform.edit1";//控件文本
		left=386;top=16;right=739;bottom=398;
		edge=true;multiline=true;z=3 //边框，多行，Z序
	};
	edit2={//指定访问名称为  winform.edit2
		cls="edit";//指定用 win.ui.ctrl.edit 类构造控件
		text="添加第一个编辑框 edit2  到  winform.button2";//控件文本
		left=22;top=16;right=375;bottom=398;//控件位置
		edge=true;multiline=true;z=4 //边框，多行，Z序
	}
});
```

上面的代码创建了 4 个控件：

- winform.button1
- winform.button2
- winform.edit1
- winform.edit2

controlsPropertiesTable 里的控件名称也就是添加到 winform 对象的成员名，例如 controlsPropertiesTable 里添加的控件名为 "button1" ，则之后的代码就要通过 `winform.button1` 访问该控件。winform.add 函数的作用就是把 "button1" 添加到 winform 对象让我们可以通过 `winform.button1` 访问新增的控件对象。

controlsPropertiesTable 里每个控件的参数属性为设计时属性，可以在窗本设计器视图中设计好这些控件的初始化属性，然后切换到代码视图就可以查看细节。创建控件的很多设计时属性与控件的运行时属性同名，因此也可以在控件的参考文档中查看这些属性的细节。

这里介绍几个最重要的控件设计时属性：

- left 相对于父窗口客户区的左坐标，设计时坐标。 所以控件的创建参数中指定的是设计时坐标，运行时坐标会根据设计时坐标计算出来。aardio 窗口支持自动缩放与自动调整坐标，默认会根据系统 DPI 缩放设置自动调整窗口与控件的位置和大小，
- top 相对于父窗口客户区的上坐标，设计时坐标
- right 相对于父窗口客户区的右坐标，设计时坐标
- bottom 相对于父窗口客户区的下坐标 ，设计时坐标
- dl 左侧是否固定与父窗口的左边距,如果是一个小数,计算父窗口宽度的百分比得出当前边距
- dt 上侧是否固定与父窗口的上边距,如果是一个小数,计算父窗口高度的百分比得出当前边距
- dr 右侧是否固定与父窗口的右边距,如果是一个小数,计算父窗口宽度的百分比得出当前边距
- db 底侧是否固定与父窗口的底边距,如果是一个小数,计算父窗口高度的百分比得出当前边距
- cls 所有控件都必须指定 cls，cls 对应的是 win.ui.ctrl 名字空间的类名。例如 `cls="button"` 就指定调用 win.ui.ctrl.button 创建一个按钮控件。cls 被称为设计时类名，控件在创建以后会生成一个 className 属性用于记录运行时类名，运行时类名通常不一样，例如 win.ui.ctrl.tab 创建以后运行时类名为 "SysTabControl32"，"SysTabControl32" 实际上是操作系统提供的系统控件类名。

	aardio 标准在 win.ui.ctrl 名字空间提供的常用控件类名如下：

	* custom 自定义控件，可用于加载其他窗体或者作为其他窗窗体的容器，也是在窗体设计器中是唯一可更改 cls 属性为其他控件类的控件。[使用指南](ctrl/custom.md)
	* static 静态文本控件 
	* button 控钮按件
	* radiobutton 单选控件 ， checked 属性表示是否选中。
	* checkbox 复选控件 ，checked 属性表示是否选中。 
	* combobox 组合框控件，items 属性可获取或设置一个字符串数组（列表数据）。[范例：自动完成输入效果](../../../../example/Windows/Dropdown/autoComplete.html)
	* listbox 列表框，items 属性可获取或设置一个字符串数组（列表数据）。[范例](example/Windows/Listbox/ListboxDemo.html)
	* listview 列表视图，items 属性返回或设置包含所有列表项的数组，数组的每个项表示一行，每行也必须是包含列文本的数组，返回数组有一个可选字段 checked 包含了所有勾选的行。[范例](../../../../example/Windows/ListView/listview.html)
	* checklist 这是基于 listview 控件实现的带复选框的列表框。 [范例](../../../../example/Windows/ListView/checklist.html)
	* treeview 树视图控件 [范例](../../../../example/Windows/TreeView/treeview.html)
	* splitter 拆分条控件。使用控件的 split 函数拆分多个控件，参数也可以是控件数组，每个控件数组必须包含位于拆分条同一侧的控件。 [范例](../../../../example/Windows/Controls/splitter.html)
	* tab 简单选项卡控件，样式比较简单。 [范例](../../../../example/Windows/Tab/TabControl.html) 。如有更多需求可改用高级选项卡（  [win.ui.tabs](tabs/_.md) ）。
	* syslink 这个控件的 text 文件属性支持 HTML 的超链接语法，可以包含普通文本或多个超链接。 [范例](../../../../example/Windows/Controls/syslink.html)
	* atlax 用于创建 COM 控件，创建时在参数表的 text 字段指定类名。 [范例](../../../../example/COM/Advanced/InkEdit.html)
	* bk 背景控件，无句柄不创建实际的窗口，仅用于背景排版，使用 GDI 绘图。
	* bkplus 高级背景控件，无句柄不创建实际的窗口，仅用于背景排版，使用 GDI+ 绘图。 [范例](../../../../example/Graphics/drawBackground.html)
	* calendar 日历控件，time 属性用于获取或设置 time 对象。
	* datetimepick 日期时间控件，time 属性用于获取或设置 time 对象。
	* ipaddress IP 地址控件，text 属性为 IP 地址文本格式，address 属性为 IP 地址数值格式。
	* hotkey 热键控件，value 属性用于获取或设置设置，值为表示热键配置的数组。
	* edit 文本框控件 
	* richedit 富文本框控件，支持透明背景，text 属性读写普通文本，rtf 属性读写 RTF 格式文本。 [范例](../../../../example/Windows/edit/CHARFORMAT2.html)
	* picturebox 图像控件，image 属性设置图像路径或图像数据，不支持 png 或动画 gif 。
	* plus 高级图像控件，支持 png 或动画 gif，可设置丰富的外观样式，通过不同配置模拟不同类型的控件。在 aardio 中最为常用。 [指南](ctrl/plus.md)
	* progress 进度条控件。 [范例](../../../../example/Windows/Controls/scroll.html)
	* spin 微调按钮，可滚动选择数值，buddy 属性设置、获取伙伴 edit 控件。。 [范例](../../../../example/Windows/Controls/scroll.html)
	* pick 取色控件。 [范例](../../../../example/System/Settings/sysColor.html)
	* vlistview 虚表控件。 [范例](../../../../example/Windows/ListView/vlistview.html)
	* trackbar 跟踪条控件。 [范例](../../../../example/Windows/Controls/scroll.html)


### 4. winform.add 函数的返回值：

虽然 winform.add 有返回值，但是我们通常不使用 winform.add 的返回值。

winform.add 的返回值与传入参数的结构相同，如果传入的是 controlsPropertiesTable 则返回的与是包含控件名值对的表，只不过对应控件名字的值变成了创建好的控件对象。

通常不必要去使用 winform.add 的返回值，应当通过 winform 去访问控件。例如在代码中使用  `winform.button1`，`winform.edit1` 访问被添加到 winform 窗口上的控件，这样写的好处是窗体设计器将会为这种访问方式提供更好的智能提示。

## 五. 创建窗口的高级用法与隐藏参数

win.form 构造参数与 winform.add 有一些不常见的用法与隐藏参数，用于解决一些不太常见的需求。关于这些参数在 aardio 自带的"范例 / Windowns 窗口 / 基础知识" 内有详细的演示与注释说明，也可以查看库参考手册，作为入门指南这里不多讲。

范例：

- [创建窗口隐藏参数](doc://example/Windows/Basics/win.form.aardio)
- [动态创建控件](doc://example/Windows/Basics/win.form.add.aardio)


## 六. 创建窗口示例 <a id="example" href="#example">&#x23;</a>


```aardio
//自 win.ui 库中导入 win.form 窗口类
import win.ui;

/*DSG{{*/
	
//创建窗口
var winform = win.form(text="窗口标题不要省略";right=763;bottom=425)

//创建多个控件应当仅调用 winform.add 一次
winform.add({//如果函数的参数只有一个表对象，可省略名值对外层的 {}  。
	
	//指定访问控件的名字为 winform.button1 ，不可省略
	button1={
		cls="button";// 指定用类 win.ui.ctrl.button 创建按钮控件，不可省略
		text="点击我";// 按钮上的文字
		left=556;top=367;// 按钮左上角坐标
		right=689;bottom=407; // 按钮右下角坐标
		z=1 // 文本框左上角坐标
	};
	
	//指定访问控件的名字为 winform.edit1 ，不可省略
	edit1={
		cls="edit";// 指定用类 win.ui.ctrl.edit 创建文本框控件，不可省略
		text="输入文本";// 文本框内的文字
		left=9;top=10;// 文本框左上角坐标
		right=752;bottom=351;// 文本框右下角坐标
		multiline=1;//多行文本框
		z=2 //Z序，可省略
	}
})

/*}}*/

// 设置按钮的点击事件处理程序，winform.button1 也就是 winform.add 的参数中创建的名为 "button1" 的控件。
winform.button1.oncommand = function(id, event) {
    // 从 1 循环到 10 的数字输出到 edit 控件
    for(i=1; 10; 1) {
        //注意 edit 以 '\r\n' 换行，而 richedit 以 '\n' 换行
        winform.edit1.appendText(i,'\r\n'); //winform..edit1 也就是 winform.add 的参数中创建的名为 ".edit1" 的控件。
    }
};
	
//显示窗口
winform.show();

//启动界面线程消息循环
win.loopMessage();
```

这个代码示例首先自 `win.ui` 库导入了 `win.form` 类，然后创建了一个带有指定标题的 winform 窗口。接着，它在该窗口上添加了一个按钮和一个文本框。当按钮被点击时，会从 1 循环到 10 的数字，每个数字后跟一个换行符，然后输出到文本框中。最后，显示窗口并进入消息循环，以便响应用户的操作。

用户在点击按钮时会回调 winform.button1.oncommand 事件函数，请参考 [aardio 范例：响应控件命令](/example/Windows/Basics/command.md)

## 七. 无边框窗口 <a id="frameless" href="#frameless">&#x23;</a>


win.form 的构造参数可使用 border 字段指定边框，示例：

```aardio
var winform = win.form(text="创建无边框（无标题栏）窗口";border="none")
```

border 可指定的值如下：

- "none"  创建无边框窗口，无边框窗口也不会有标题栏。
- "resizable" 创建可拖动改变窗口大小的边框，这是默认设置，不需要显式指定。
- "dialog frame" 创建对话框窗口边框，不能拖动改变窗口大小。此选项仅适用于包含标题栏的窗口。
- "thin" 窗口显示细边框，不能拖动改变窗口大小。此选项仅适用于无标题栏的窗口。

win.form 的构造参数可以用 title 字段指定是否显示标题栏，示例：

```aardio
var winform = win.form(text="细边框 + 无标题栏样式";border="thin";title=false)
```

title 字段仅对有边框的窗口有效（无边框的窗口一定没有标题栏），有边框的窗口 title 字段的默认值为 true 一般不需要显式指定。

> win.form 的构造参数如果不用 text 字段指定标题文本也会导致窗口不显示标题栏。没有标题栏就找不到原本显示在标题栏的关闭窗口按钮，用户就只能通过 `AL + F4` 关闭窗口，所以一般不建议省略创建窗口参数中的 text 字段。就算是无边框无标题栏的窗口一般也推荐给窗口指定一个合适的标题。

创建无边框窗口的目的通常是为了自己定制标题栏与边框，aardio 提供了一个简单的示例库 win.ui.simpleWindow 。

用法演示：

```aardio
import win.ui;

//创建无边框（无标题栏）窗口
var winform = win.form(text="aardio form";border="none")

//添加标题栏背景
winform.add(
bkTitleBar={cls="bk";left=0;top=0;marginRight=0;bottom=30;bgcolor=8421504;dl=1;dr=1;dt=1;z=1}
) 

//添加阴影边框、标题栏等
import win.ui.simpleWindow;
win.ui.simpleWindow(winform);

winform.show();
win.loopMessage();

```

可查看 win.ui.simpleWindow 库源码了解如何定制无边框窗口。

在无边框窗口上，调用以下函数模拟标题栏按钮消息：

```aardio
winform.hitMax() //模拟点击最大化按钮
winform.hitMin() //模拟点击最小化按钮
winform.hitClose() //模拟点击关闭按钮
winform.hitCaption() //拖动标题栏
```

请参考： 

- [无边框窗口范例](../../../../example/Windows/Basics/frameless.html)
- [web.view - 网页界面无边框窗口范例](../../../../example/WebUI/web.view/frameless.html)



