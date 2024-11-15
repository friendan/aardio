# aardio 创建多窗口程序

## 一. 加载并管理多个独立显示的下属窗口( owned window )
 
### 1. 创建窗口工程

点选『 aardio 主菜单 / 新建工程 / 窗口程序 / 窗白程序』，点击『创建工程』按钮。  
  
### 2. 添加多个窗口

鼠标右键点击『工程资源目录』，在弹出右键菜单点击『 新建文件 / 新建窗体设计器』，新建一个或多个子窗口，例如增加子窗体文件 frmChild.aardio 。  

### 3. 在主窗口上添加按钮与响应事件的回调函数

切换到主窗口 main.aardio ，在上面拖放一个按钮 。
  
双击新增的按钮，自动切换到代码视图 。 
  
aardio 自动添加了响应按钮事件的回调函数：  

```aardio
mainForm.button.oncommand = function(id,event){  
    //用户点击按钮将会执行这里的代码
}
```
  
### 4. 加载其他独立窗口

从工程管理器中拖动 frmChild.aardio 到 main.aardio 的按钮事件内部，  
   
aardio 生成代码如下：  

```aardio
mainForm.button.oncommand = function(id,event){  
    var frmChild = mainForm.loadForm("\res\frmChild.aardio");  
    frmChild.show();  
}
```

frmChild.show() 显示一个非模态的下属窗口( owned window )，改为 frmChild.doModal() 则显示模态对话框，模态对话框在关闭前不能操作所有者窗口（owner window）。 

## 二. 在子窗口中嵌入外部子窗口

使用自定义控件就可以在窗口上任何指定的部位嵌入其他外部子窗口，子窗口显示在父窗口的客户区，如同普通的控件窗口。

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

上面的示例加载了 aardio 自带范例中的窗口文件，[文件路径开始的 `~` 在开发环境中表示  aardio.exe 所在目录](../../../builtin/io/path.md#app-path)。

参考：[custom 控件](ctrl/custom.md#cls-path)

## 三. 使用选项卡管理多个子窗口

aardio 有两种不同的选项卡：

1. 简单选项卡控件（ win.ui.ctrl.tab ）。用法请参考: [简单选项卡使用指南](ctrl/tab.md)
2. 高级选项卡（ win.ui.tabs  ）。高级选项卡并不是一个控件，而是用于管理 plus 控件实现选项卡效果的管理组件。用法请参考: [高级选项卡使用指南](tabs/_.md)

下面介绍一下 win.ui.ctrl.tab 的用法。

1. 我们首先打开窗体设计器，在界面控件工具箱拖一个 tab 选项卡控件到界面上。
2. 切换到代码视图，从工程管理器内拖动子窗口到当前主窗口的代码中生成类似 `mainForm.loadForm("\res\frmChild.aardio")` 的默认代码，我们仅仅需要将 `mainForm.loadForm()` 改为 `mainForm.tab.loadForm() `就可以了。

  
通过 tab 选项卡加载多个子窗口的 aardio 示例代码：  

```aardio
import win.ui;  

//创建主窗口
mainForm = win.form(text="多窗口示例工程";right=757;bottom=467)  

//添加简单选项卡控件（ classic tab control  ）
mainForm.add(  
tab={cls="tab";left=22;top=11;right=725;bottom=436;edge=1;z=1}  
)  

//加载子窗口到选项卡
var frmChild = mainForm.tab.loadForm("\res\frmChild.aardio");    

//加载更多子窗口到选项卡
var frmChild2 = mainForm.tab.loadForm("\res\frmChild2.aardio");    

mainForm.show();  
win.loopMessage();
```

如果希望界面更漂亮一些，可以使用高级选项卡，参考[高级选项卡范例](../../../../example/tabs/QuickStart.html)。  