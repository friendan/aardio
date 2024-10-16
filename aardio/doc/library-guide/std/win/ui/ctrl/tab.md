# 简单选项卡使用指南

aardio 有两种不同的选项卡：

1. 简单选项卡控件（ classic tab control  ）

    简单选项卡是由 win.ui.ctrl.tab 类库基于系统 SysTabControl32 控件实现的经典选项卡。可在窗体可视化设计器上直接拖放添加选项卡控件，控件创建参数中指定的 cls 类名为 "tab"。

2. 高级选项卡（ tab plus ）

    高级选项卡由 win.ui.tabs 类库实现。高级选项卡并不是一个控件，而是用于管理一组 plus 控件（ win.ui.ctrl.plus ）以实现选项卡效果的管理组件。

    关于高级选项卡的用法请参考: [高级选项卡使用指南](../tabs/_.md)

下面介绍简单选项卡的用法。

## 使用简单选项卡的步骤
 
1. 点击『 aardio 主菜单 / 新建工程 / 窗口程序 / 窗白程序』，然后在工程向导界面点击『创建工程』按钮。  

2. 切换到主窗口 main.aardio 的窗体设计视图，自『界面控件』面板拖放一个选项卡控件（ tab 控件 ） 到窗体上 。
  
3. 鼠标右键点击『工程资源目录』，在弹出右键菜单点击『 新建文件 / 新建窗体设计器』，新建一个或多个子窗口，例如我们在 res 目录增加一个子窗体文件 frmChild.aardio 。  

4. 切换到代码视图 ，从工程管理器中拖动 frmChild.aardio 到 main.aardio 的代码内。  
   
	aardio 自动生成代码如下：  

	```aardio 
		var frmChild = mainForm.loadForm("\res\frmChild.aardio");  
		frmChild.show();   
	```
  
	我们将上面的 mainForm.loadForm() 改为 mainForm.tab.loadForm() 以加载窗体到选项卡控件中。  
  
以下为完整示例： 

```aardio
import win.ui;  

mainForm = win.form(text="多窗口示例工程";right=757;bottom=467)  
mainForm.add(  
tab={cls="tab";left=22;top=11;right=725;bottom=436;edge=1;z=1}  
)  


var frmPage = mainForm.tab.loadForm("\res\frmChild.aardio");     
var frmPage2 = mainForm.tab.loadForm("\res\frmChild2.aardio");    

mainForm.show();  
win.loopMessage();
```

如果希望界面更漂亮一些，可以使用『高级选项卡』，具体请参考: [高级选项卡使用指南](../tabs/_.md)