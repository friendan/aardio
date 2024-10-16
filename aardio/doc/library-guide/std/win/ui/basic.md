# 窗口程序入门指南

## 窗口程序基础知识

### 一、理解窗口应用程序执行流程

1. 界面线程(一般也是主线程)的主消息循环由 win.loopMessage 启动,
窗口应用程序有且只能有一个 win.loopMessage()，使用 win.loadForm() 或者 winform.loadForm() 加载。
窗体代码文件时会自动忽略重复启动消息循环的 win.loopMessage() 调用。

2. 所有非模态、非 MessageOnly 的独立窗口（ 或 mainForm 窗口 ）都关闭后，
将会自动调用 win.quitMessage() 终止 win.loopMessage 创建的消息循环（通常也就是退出界面线程）。

3. 使用 winform.doModal() 创建模态窗口, 模态窗口会禁用所有者窗口（也就是背景窗口）直到模态窗口关闭。
模态窗口不能是子窗口（禁用父窗口就是禁用自己）。模态窗口创建独立的消息循环阻塞调用代码继续向后执行
直到模态窗口退出,而调用 winform.show() 显示的非模态窗口不会阻塞调用代码向后执行。

请参考： [启动与退出窗口消息循环](../_.md#loopMessage)

### 二、aardio 工程内如何加载代码文件

1. 在工程中加载其他代码文件时可使用 loadcodex 函数,例如：loadcodex("/res/x.aardio") 在工程中
加载 aardio 代码文件时,路径应当总是使用斜杠字符开始的应用程序根目录相对路径。可以在工程管理器
中右键点击代码文件,在弹出菜单中点击【复制路径】。

2. 如果加载窗体代码文件可以使用 win.loadForm("/dlg/winform.aardio") 。
win.loadForm 会忽略 win.loopMessage() 。加载的窗体如果没有返回非空值,则默认返回创建的窗体对象。

3. 也可以使用窗体对象加载另一个窗体,例如 `winfrom.loadForm("/dlg/frmChild.aardio") `,  
winfrom.loadForm 的作用与 win.loadForm 相同，但是会自动把 winfrom 指定为被加载窗体的父窗口(或所有者窗口)。
在工程管理器中拖动窗体文件到父窗口代码内会自动生成此代码。

4. 可以在标准库、用户库中创建名字空间、类、窗口类，并使用 import 语句加载。

## 理解窗口间的关系

### 一、包含关系（整体局部关系）

也就是父/子窗口关系（ parent/child 关系）,

1. 父窗口包含子窗口，子窗口显示在父窗口客户区内部。
2. 这种嵌入式子窗口拥有CHILD样式，只能作为内部子窗口被包含在父窗口内部。
3. 移动父窗口，子窗口必然被移动，因为他们是整体局部的包含关系。
4. 父窗口销毁时，子窗口都会被销毁。

### 二、下属关系（责任归属关系）

也就是所有者窗口/下属窗口关系（ owner/owned 关系），消息对话框(msgbox)就是最常见的下属窗口。
传统说法如“所有窗口他所有的窗口”不好理解，在 aardio 中我们把 owned 窗口称为“下属窗口”以避免混淆。

1、下属窗口(owned window)总是显示在所有者窗口（owner window）前面。
2、下属窗口都是外部独立窗口，不使用CHILD样式，可独立显示在所有者窗口外部。
3、移动所有者窗口，下属窗口不会跟着移动，窗口仍然是各自独立显示的。
4、所有者窗口销毁时，下属窗口也会销毁。

这种独立窗口间的归属关系实际上是一种独立窗口间的父子关系，
因此所有者窗口也经常被称为父窗口，下属窗口也常常被称为外部子窗口，新手容易混淆。
aardio 标准库对这些接口重新整理并进行了规范命名,提供了win.getOwner() win.setOwner() 
win.getParent() win.setParent() 等标准库函数。

aardio 中还有一种 orphanWindow 比较特别，orphanWindow 实际上是独立的下属窗口，
但是他又会自动跟随所有者窗口（owner window）移动，从而模拟出嵌入式子窗口的效果。

## 如何加载子窗口

### 一、使用 winform.loadForm 函数加载子窗口

例如 mainForm是父窗口， "/dlg/frmChild.aardio" 是要加载的子窗口。
我们只要在工程中将 "/dlg/frmChild.aardio" 往 mainForm 的源代码一拖就可以生成下面的加载代码了：

```aardio
var frmChild = mainForm.loadForm("/dlg/frmChild.aardio")
```

这时候如果子窗口 frmChild 指定了 child 样式就会作为嵌入式子窗口显示在父窗口内部。
否则就会作为独立的下属窗口(外部子窗口)独立显示在所有者窗口前面。

下属窗口(外部子窗口)有两种显示模式
1. 调用 winform.show() 显示的非模态窗口，不阻塞调用代码向后执行。
2. 调用 winform.doModal() 显示的模态窗口，模态窗口会创建独立的消息循环
并禁用上级所有者窗口(即背景窗口),阻塞调用代码向后执行直到窗口关闭。

child 样式的嵌入式子窗口不能显示为模态窗口，这样既没意义也会因为禁用父窗口而禁用自身。

### 二、使用 tab 选项卡控件可以加载并管理多个子窗口：

例如我们窗口上有名为 winform.tab 的选项卡控件，则使用 
winform.tab.loadForm("/dlg/tab-page1.aardio") 加载子窗口。
使用这种方式加载的是嵌入式子窗口,会自动把窗口修改为 child 样式。
win.ui.tabs 实现的高级选项卡可实现类似功能。

### 三、使用 custom 控件加载子窗口，有3种方法

1. 使用 custom 控件直接加载嵌入式子窗口，在 custom 的类名中输入子窗口的代码文件路径即可。
2. 使用 custom 控件的 loadForm 函数载并管理多个嵌入式子窗口，可以结合高级选项卡(win.ui.tabs)使用。
3. 在 win.ui.ctrl 名字空间下创建控件类库（参考 win.ui.ctrl.custom 等控件的源码），
使用 import 语句导入自定义的控件类，拖动 custom 控件到界面上并且把类名改为对应的自定义控件类名就可以了。

### 四、使用窗口类库加载窗口

这种窗口类使用 import 导入，通过类构造函数创建窗口。
标准库中的 win.inputBox 就是这样的窗口类。