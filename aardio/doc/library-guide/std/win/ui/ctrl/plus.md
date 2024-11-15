# aardio 图形界面 - plus 控件使用指南

强烈推荐先仔细阅读：[《Z 序：原理与优化》](../z-order.md)  
里面也讲解了 plus 控件的优化技术。Z 序与很多问题都有关系，一定要仔细看。

## plus 控件简介
  
plus 控件可支持各种字体图标， jpg 图像，透明 gif 图像，透明动画，半透明 png 图像，并可设定多种不同的绘图模式、九宫格贴图等等，使用 plus 控件可以简单地通过在窗体设计器中拖拉创建各种漂亮的控件效果、可创建静态图片框、动画播放控件、按钮、透明按钮、不规则按钮、复选框、超链接、组合框、进度条、扇形进度条、滑块跟踪条、选项卡、弹出菜单、下拉框...... plus 控件还提供了非常多的灵活的可调整参数，如果您擅于发挥可以做出更多的控件效果。  

aardio 的窗体背景图也支持九宫格，缓存绘图等功能。另外 aardio 还提供 bk,bkplus 等纯背景贴图控件（ 无句柄控件 ）。使用这些背景贴图功能，再加上 plus 控件，可以轻松拖放出好看的界面。  
  
## plus 控件的基本用法
  
使用 plus 控件的基本步骤：
  
1. 首先拖一个 plus 控件到界面上，选中 plus 控件。  
  
2. 鼠标双击并打开"aardio 工具 / 界面 / plus 控件配色工具"。  
  
3. 配置好颜色样式，或者点击预设的范例样式，然后点击 **「导出到窗体设计器选中控件」** 就可以了。  

## 使用图标字体

注意 plus 控件可以指定两个文本属性，一个是普通「文本」属性，一个是「图标文本」属性。

如果「图标文本」为空，则「图标字体」属性被忽略。普通文本的「字体」属性也可以指定为图标字体，但如果普通文本的「字体」属性用适合文本的 Tahoma 字体，而「图标文本」使用 FontAwesome 等图标字体效果会更好一些。

为 plus 控件指定图标字体是非常简单的：

1. 选中 plus 控件。
2. 点击『 aardio 工具 / 界面 / 字体图标 』，选中需要的字体图标，然后点击字体图标就可以了。

示例代码：

```aardio
import win.ui;
import fonts.fontAwesome;
/*DSG{{*/
var winform = win.form(text="FontAwesome 图标字体演示";right=455;bottom=286)
winform.add(
plus={cls="plus";text='\uF1f7'/*_FA_BELL_SLASH_O*/;left=64;top=75;right=109;bottom=117;color=32768;font=LOGFONT(name='FontAwesome';h=-35);transparent=1;z=1};
plus2={cls="plus";text='\uF25a'/*_FA_HAND_POINTER_O*/;left=154;top=77;right=199;bottom=119;color=32768;font=LOGFONT(name='FontAwesome';h=-35);transparent=1;z=2};
plus3={cls="plus";text= '\uF1d6 点这里联系我们'/*_FA_QQ*/;left=248;top=76;right=420;bottom=118;color=32768;font=LOGFONT(name='FontAwesome';h=-16);transparent=1;z=3}
)
/*}}*/

var hyperlink = {
     color = {
        hover = 0xFFFF0000; //鼠标移上去的颜色
        active = 0xFF00FF00; //鼠标按下去的颜色
    }
}
winform.plus.skin(hyperlink);
winform.plus2.skin(hyperlink);
winform.plus3.skin(hyperlink);

winform.show();
win.loopMessage();
```

工具会自动添加代码 `import fonts.fontAwesome` 以导入 FontAwesome 字体。

## 设置背景图像、前景图像 <a id="image" href="#image">&#x23;</a>

1. 首先，请新建一个窗体。  
2. 然后在开发环境左下侧『界面控件』面板点选 plus 控件（高级图像控件），并在窗体上拖拽画出控件。
3. 在窗体上点选添加上去的 plus 控件，然后在右侧属性面板中修改"前景图像"、"背景图像"等属性。等价于在代码中设置控件的 background 属性以显示背景图像，设置控件的 foreground 属性以显示前景图像。plus 控件支持 jpg ,gif 动画，透明动画，png 半透明图像。可以同时设置背景图、前景图在运行时合成新的图像。如果图像是一个 GIF 动画则会自动播放。 
  
注意 plus 控件使用的图像一定要包含在工程目录下（并且目录的"内嵌资源"属性应设为 true ), 
picturebox 添加图像时默认为会在路径前添加包含操作符`$`通过内存载入图像，图像不需要添加到工程管理器中。  
而 plus 控件默认不会这么做，应当将图像添加到工程中（可以放在资源目录下，在工程管理器右键菜单中简单的点击【同步本地目录】），如果你指定一个文件名（可以指定资源文件名）而不是内存数据（），plus 控件将可以更好的缓存优化图像。  
  
控件属性中的背景模式、前景模式可以设置图像的显示模式，可选项如下：  

1. expand: 九宫格拉伸模式，按你设定的上、右、下、左四个坐标把图像划四条线把图像切分为九个格子，四个角的图像保持原来的大小显示在屏幕上，而其他中间的块则拉伸显示。  

    | 固定 | 自动拉伸 | 固定 |  
    |------|---------|-----|  
    | 拉伸 | 自动拉伸 | 拉伸 |  
    | 固定 | 自动拉伸 | 固定 |  

    如果指定 expand 模式，则可以通过控件属性"背景切图"、"前景切图"指定九宫格切图位置。我们可以用鼠标点选"背景切图"、"前景切图"坐标数值，然后**滚动鼠标滚轮**快速调整切图位置。在"窗体设计器"中，会实时使用不同颜色的线条标明背景、前景的九宫格切图位置。 
  
2. stretch:普通拉伸模式，控件多大图像就缩放到适应的大小显示。  
3. center: 绝对居中模式，图像保持原始大小，图像的中心对准控件的中心，如果图像比控件大则只会显示能显示的部分，超出控件的被剪切掉不显示。  
4. scale：保持图像原来的比例不变、并缩放到适应控件的大小  
5. tile：图像保持原来的大小并横向、纵向重复平铺显示  
6. repeat-x：仅横向重复平铺显示  
7. repeat-y：仅纵向重复平铺显示  

我们还可以设置控件的"前景边距"以指定前景图像与文本的显示外边距，"前景边距"不会改变背景图像的边距。

如果不希望前景图被内边距限制显示范围，可以将前景模式设为"point"模式。point 模式按 x,y 指定的坐标显示前景图（忽略 "前景边距"），x,y 如果为小数则按百分比划分图像与控件间的剩余空间（忽略 "前景边距"）。如果为负数则表示相对右下角的坐标。
 
expand 模式是最常用的一种图像显示模式，自适应系统 DPI 缩放的效果较好。

## 设置 plus 控件交互样式：动态切换图像
 
在窗体设计器中添加一 个plus 控件，然后设置好背景图或前景图等参数。  

然后双击该控件添加代码如下：  

```aardio

//设定 plus 控件切换到不同状态时的样式
winform.plus.skin(

    background = { //指定背景图像在不同状态下的样式
        hover = "/res/btn-hover.png";//鼠标移到控件上的图像
        focus = "/res/btn-focus.png";//控件得到焦点的图像
        active = "/res/btn-active.png";//鼠标按下时的图像
        disabled = "/res/btn-disabled.png"; //控件禁用的图像
    }
)

// 点击按钮时触发下面的事件
winform.plus.oncommand = function(id,event){
        
}
```

winform.plus.skin() 的参数是一个表对象，可以指定 plus 控件不同属性在不同状态下的外观样式。

例如上面指定了 plus 控件的 background 属性在不同状态下显示的不同的背景图像。同样也可以使用 foreground 属性指定不同状态下的前景图像，以及使用 color 属性指定不同状态下的字体颜色。  
  
plus 控件支持的样式非常多。

我们可以在窗体设计器上点选 plus 控件，然后打开 "aardio 工具 / 界面 / plus 控件配色工具" 设置样式并自动生成 `winform.plus.skin` 函数调用代码。

实际上现代软件界面使用图像已经不多见，更流行的是使用字体图标与配色实现更轻快简洁的效果，使用"plus 控件配色工具"以及 aardio 提供的 "字体图标工具" 做这样的界面将会非常方便。

## 用 plus 控件实现超链接

创建超链接很简单，在设计器中双击 plus 控件，修改 skin 函数调用代码如下：

```aardio
 winform.plus.skin(  
     color = {
         hover = 0xFFFF0000; //鼠标移上去的颜色  
         active = 0xFF00FF00; //鼠标按下去的颜色  
     }  
 )
```

plus 控件使用 GDI+ 绘图，所以使用的颜色格式也是 GDI+ 颜色格式 0xAARRGGBB。其中A为透明度,R为红色分量,G为绿色分量,B为蓝色分量。

下面是一个完整的示例：


```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="用 plus 控件创建超链接";right=492;bottom=254;bgcolor=4448391;max=false)
winform.add(
plus={cls="plus";text="http://www.aardio.com";left=46;top=85;right=429;bottom=130;color=15793151;font=LOGFONT(h=-24);notify=1;z=2};
progress={cls="plus";left=119;top=107;right=377;bottom=131;align="left";background="~\res\progress-bg.jpg";color=16777215;foreRepeat="expand";foreground="~\res\progress.jpg";z=1}
)
/*}}*/

winform.plus.skin(
	//颜色样式
	color = { 
		hover = 0xFFFF0000; //鼠标移上去的颜色
		active = 0xFF00FF00; //鼠标按下去的颜色
	}
)
	
//鼠标点击超链接触发下面的函数
winform.plus.onMouseClick = function(){
	//打开网页
	raw.execute("http://www.aardio.com");
}

winform.show();
win.loopMessage(); 
```

plus 控件默认使用透明背景，也可以如下指定不同状态下的背景色：  

```aardio
winform.plus.skin(  
    background = {  
        active = 0xFF004444;  
        hover = 0xFFCCCC00;  
    }  
)  
```

注意 background 的样式可以指定图像路径，也可以直接指定 0xAARRGGBB 格式的颜色代码。

 
## 用 plus 控件实现进度条

使用 plus 控件创建进度条比较简单。

1. 如果我们不需要图像，只要简单地在控件属性中设置好背景色、前景色就可以了。

    如果需要指定背景图、前景图，那么显示模式都应当指定为"expand"模式（九宫格贴图 ）。

2. 然后我们切换窗体到 "代码模式"，添加一句代码 `winform.plus.setProgressRange(1,100) ` 指定进度条的最小值、最大值就可以自动切换到进度条模式了。

进度条也可以显示文件，文本被限制在前景图范围内（文本的显示边距为前景边框 + 文本边距）。  
  
进度条可以是横向的（宽度大于高度），也可以是竖向的（高度大于宽度），plus 控件会根据设计时的宽高比自动判断进度条的方向，不需要设置其他参数。  
  
示例：  

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="plus控件 - 进度条")
winform.add(
plus={cls="plus";left=161;top=282;right=707;bottom=316;bgcolor=6447459;forecolor=9959653;notify=1;z=1}
)
/*}}*/

//设置进度区间，可自动切换到进度条显示模式
winform.plus.setProgressRange(1,50);

//设置进度
winform.plus.progressPos = 20;

winform.show() 
win.loopMessage();
```

## 用 plus 控件实现圆形进度条

如果使用 `winform.plus.setPieRange(1,100); ` 设定进度条的进度范围就可以创建圆形的进度条。  

圆形进度条如果需要使用图像，则扇形进度条的前景图、背景图都应当设置为"center" 模式（ 即绝对居中 ）。

示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="圆形进度条";right=759;bottom=469)
winform.add(
plus={cls="plus";left=390;top=108;right=643;bottom=361;notify=1;z=1}
)
/*}}*/

//切换为圆形进度条
winform.plus.setPieRange(1,360) 

//前景色
winform.plus.foreground = 0x80ffff00;

//背景色
winform.plus.background = 0x60ff00ff;
	
//进度动画
winform.setInterval( 
	function(){
		//改变进度条的进度
		winform.plus.progressPos = winform.plus.progressPos+1
	},10 
)

winform.show() 
win.loopMessage();
```

## 用 plus 控件实现滑块控件

创建滑尺控件与创建进度条类似，  
区别是使用 `winform.plus.setTrackbarRange(1,100)` 设置进度范围.  
  
请参考教程[《trackbar 控件高级玩法》](https://mp.weixin.qq.com/s?__biz=MzA3Njc1MDU0OQ==&mid=2650931907&idx=1&sn=2543aee4c3e32393c8361f0dd43d8667&chksm=84aa2979b3dda06fcb8c590caba5b11eeb3eebcec5608fdb7944dc792566ea417a5ab3b64996&scene=178&cur_album_id=2209804829378543621#rd)  
  
如果我们想让 trackbar 变得更漂亮一些，用系统 trackbar 就比较为难了。我们可以用 aardio 中最强大的控件 —— plus 控件来绘制 trackbar 控件。方法很简单，先拖一个 plus 控件到界面上，然后打开「工具 / 界面 / 滑尺配色工具」 。 
  
在 "滑尺配色工具" 里配置好外观与样式，然后「导出到窗体设计器选中控件」就行了：  
  
如果需要用图像制作滑块，背景图、前景图都必须使用"expand"模式（ 九宫格模式 ）。前景图的九宫格切图需要指定右侧切图的宽度为滑块按钮的宽度。
  
滑块控件可以是横向的（宽度大于高度），也可以是竖向的（高度大于宽度），plus 控件会根据设计时的宽高比自动判断滑块的方向，不需要设置其他参数。  
  
与此类似，当 plus 控件作为普通进度条使用时也自动支持横向、竖向进度条（同样根据设计时的宽高比自动判断）。  

## plus 控件创建静态控件

plus 控件用于静态显示图像或背景色时，也可以作为文本框的背景用于美化文本框。需要注意 plus 控件作为背景控件使用时要设置【事件回调】为false（ 这个是默认值，表示不响应鼠标按键事件 ）以避免与文本框争抢绘图。  
  
文本框用于显示单行文本时可以将高度调整的较小，加上背景图显示效果就比较好了。 注意要在属性面板中设置【多行】属性为false，多行文本框调整太小了光标就看不到了。  
 