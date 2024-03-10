win.ui.ctrl.bk帮助文档
===========================================
<a id="win.ui.ctrl"></a>
win.ui.ctrl 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="win.ui.ctrl.bk">win.ui.ctrl.bk() </h6>
 无窗口控件,仅用于背景贴图,不建议用于频繁刷新绘图  
  
[返回对象:winuictrlbkObject](#winuictrlbkObject)

<a id="winuictrlbkObject"></a>
winuictrlbkObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="winuictrlbkObject.background">winuictrlbkObject.background </h6>
 参数指定图像路径，重设背景图像,  
仅支持gif,jpg等，不支持png,  
png贴图请改用bkplus控件

<h6 id="winuictrlbkObject.bgcolor">winuictrlbkObject.bgcolor </h6>
 背景色,RGB格式数值

<h6 id="winuictrlbkObject.forecolor">winuictrlbkObject.forecolor </h6>
 前景色,RGB格式数值

<h6 id="winuictrlbkObject.getPos（）">winuictrlbkObject.getPos（） </h6>
 返回x,y,cx,cy,  
x,y为控件坐标,cx,cy为控件宽、高

<h6 id="winuictrlbkObject.linearGradient">winuictrlbkObject.linearGradient </h6>
 线程渐变方向,0为水平方向，其他数值为垂直方向渐变

<h6 id="winuictrlbkObject.onDrawBackground">winuictrlbkObject.onDrawBackground </h6>
 
    winuictrlbkObject.onDrawBackground(hdc,rc){
    	/*背景绘图以后触发此回调,  
    hdc为当前绘图设备句柄,rc为控件位置*/
    }

<h6 id="winuictrlbkObject.redraw">winuictrlbkObject.redraw() </h6>
 刷新,会导致背景窗口重建背景图缓存  
不建议频繁调用

<h6 id="winuictrlbkObject.setBitmap">winuictrlbkObject.setBitmap(__) </h6>
 参数指定位图句柄,重设背景位图  
控件负责销毁位图句柄
