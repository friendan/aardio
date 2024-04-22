win.ui.ctrl.listview帮助文档
===========================================
<a id="win.ui.ctrl"></a>
win.ui.ctrl 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="win.ui.ctrl.listview">win.ui.ctrl.listview() </h6>
 列表视图  
  
[返回对象:listviewObject](#listviewObject)

<a id="listviewObject"></a>
listviewObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="listviewObject._defWindowProc">listviewObject._defWindowProc(hwnd,message,wParam,lParam) </h6>
 用于在 wndproc 回调中提前调用默认消息回调函数,  
所有窗口和控件定义了 wndproc 回调以后会自动创建这个函数,  
调用此函数以后,wndproc 必须指定非 null 返回值,  
以避免再次重复调用默认回调函数

<h6 id="listviewObject._parentForm">listviewObject._parentForm </h6>
 创建该控件的父窗口（win.form对象）,  
设计时窗体容器是所有拖放在窗体上的控件的 _parentForm,  
  
即使窗口移除子窗口样式、更改父子关系，或以 orphanWindow显示,  
控件的 _parentForm 始终都不会改变  
  
[返回对象:winform](#winform)

<h6 id="listviewObject.addCtrl">listviewObject.addCtrl </h6>
 
    listviewObject.addCtrl(  
    	edit ={ cls="edit";left=0;top=0;right=50;bottom=50;autoResize=false ;hide=1;edge=1;  }  
    )

<h6 id="listviewObject.addItem">listviewObject.addItem(LVITEM对象,位置) </h6>
 参数一可以是指定一个或多个LVITEM对象成员的table对象  
text成员指定项目文件,也可以是一个指定多列文本的数组  
位置参数可省略,默认为count值  
返回新增项行号

<h6 id="listviewObject.addItem">listviewObject.addItem(文本,位置,图像索引) </h6>
 位置参数可省略,默认为count值  
图像索引可省略,默认为-1  
文本可以是一个指定多列文本的table数组,  
如果列文本不是指针、空值则自动转换为字符串,  
返回新增项行号

<h6 id="listviewObject.adjust">listviewObject.adjust </h6>
 
    listviewObject.adjust = function( cx,cy,wParam ) {	   
    	 /*窗口缩放时会自动触发此函数。  
    cx 参数为窗口宽度,cy 参数为窗口高度,  
    wParam 参数请参考 _WM_SIZE 消息参数说明,一般不用管。  
      
    所有 win.form 创建的窗体和控件都支持此事件,  
    重复赋值只会追加而不会覆盖此事件。  
    一般不建议添加一个 wndproc 仅仅是为了处理  _WM_SIZE 消息，  
    定义 adjust 事件是更好的选择。  
      
    可主动调用此事件,省略参数时 cx,cy 参数默认设为窗口大小*/    
    };

<h6 id="listviewObject.bottom">listviewObject.bottom </h6>
 底部坐标

<h6 id="listviewObject.capture">listviewObject.capture </h6>
 是否捕获全局鼠标消息

<h6 id="listviewObject.checkbox">listviewObject.checkbox </h6>
 是否在每个项目前显示复选框  
注意虚表不存在实际的项也不支持设置项目复选框

<h6 id="listviewObject.checked">listviewObject.checked </h6>
 返回已勾选复选框的行索引数组,  
此数组内的行索引按实际显示的前后排序,  
需要先启用复选框支持

<h6 id="listviewObject.className">listviewObject.className </h6>
 运行时类名

<h6 id="listviewObject.clear">listviewObject.clear() </h6>
 清空所有项

<h6 id="listviewObject.clear">listviewObject.clear(true) </h6>
 清空所有项,并且删除所有列

<h6 id="listviewObject.clearColumnImage">listviewObject.clearColumnImage() </h6>
 清除所有列的图像索引

<h6 id="listviewObject.clientRect">listviewObject.clientRect </h6>
 获取控件客户区块位置(::RECT结构体)

<h6 id="listviewObject.close">listviewObject.close() </h6>
 关闭控件窗口

<h6 id="listviewObject.cls">listviewObject.cls </h6>
 设计时类名

<h6 id="listviewObject.columnCount">listviewObject.columnCount </h6>
 列总数

<h6 id="listviewObject.count">listviewObject.count </h6>
 项目总数  
用于实现虚表时可修改此属性

<h6 id="listviewObject.delColumn">listviewObject.delColumn(__) </h6>
 删除指定列

<h6 id="listviewObject.delItem">listviewObject.delItem(__) </h6>
 参数为数值,移除指定索引的项目

<h6 id="listviewObject.disabled">listviewObject.disabled </h6>
 是否禁用

<h6 id="listviewObject.each">listviewObject.each(起始索引,选项) </h6>
 
    for itemIndex in listviewObject.each(){
    	/*遍历所有项*/
    }

<h6 id="listviewObject.eachChecked">listviewObject.eachChecked(col) </h6>
 
    for item,value in listviewObject.eachChecked(){
    	/*从后向前倒序遍历所有勾选项,  
    迭代变量 item 为勾选项行号,  
    迭代变量 value 为  @col 参数所指定列的文本值  
    @col 参数省略则默认为1*/
    }

<h6 id="listviewObject.eachSelected">listviewObject.eachSelected(col) </h6>
 
    for item,value in listviewObject.eachSelected(){
    	/*从后向前倒序遍历所有选中项,  
    迭代变量 item 为选中项行号,  
    迭代变量 value 为  @col 参数所指定列的文本值  
    @col 参数省略则默认为1*/
    }

<h6 id="listviewObject.editLabel">listviewObject.editLabel(行序号) </h6>
 编辑指定项,无参数则编辑选定项  
此函数成功返回编辑文本框句柄  
返则返回0

<h6 id="listviewObject.enableDoubleBuffering">listviewObject.enableDoubleBuffering() </h6>
 启用双缓冲,  
可用于实现虚表时避免拖动时闪烁

<h6 id="listviewObject.ensureVisible">listviewObject.ensureVisible(__) </h6>
 滚动视图以确定可以显示参数指定行序号的项,  
不指定参数则设置当前选中焦点项

<h6 id="listviewObject.fillParent">listviewObject.fillParent(列序号) </h6>
 使指定列自适应父窗口宽度,  
如果不指定列默认调整最后一列,  
用户调整窗口大小时会自动调用此函数调整自适应列

<h6 id="listviewObject.findItem">listviewObject.findItem(查找文本,起始位置,部分匹配,全局搜索) </h6>
 使用文本查找匹配项,  
除第一个参数外,所有参数可选,  
部分匹配仅限于匹配文本开始部分,默认值为true  
全局搜索指搜索到最后一项以后转到第一项继续搜索

<h6 id="listviewObject.fullRow">listviewObject.fullRow </h6>
 是否选中整行

<h6 id="listviewObject.getChecked">listviewObject.getChecked(__) </h6>
 返回指定索引项是否已勾选复选框，需要启用复选框支持

<h6 id="listviewObject.getClientRect">listviewObject.getClientRect() </h6>
 控件客户区块位置(::RECT结构体)  
  
[返回对象:rectObject](#rectObject)

<h6 id="listviewObject.getColumn">listviewObject.getColumn() </h6>
 [返回对象:lvcolumnObject](#lvcolumnObject)

<h6 id="listviewObject.getColumn">listviewObject.getColumn(列参数表,列序号) </h6>
 参数一可以为空,或是指定LVCOLUMN结构体成员键值的参数表,  
返回LVCOLUMN结构体

<h6 id="listviewObject.getColumnImage">listviewObject.getColumnImage(col) </h6>
 获取指定列的图像索引,参数和返回值都是数值,  
无图像返回null

<h6 id="listviewObject.getColumnText">listviewObject.getColumnText(__) </h6>
 取指定列文本

<h6 id="listviewObject.getEditControl">listviewObject.getEditControl() </h6>
 开始编辑时返回编辑控件,  
此控件在完成编辑后会自动销毁,不必手动销毁  
取消发送_WM_CANCELMODE消息即可  
  
[返回对象:editObject](#editObject)

<h6 id="listviewObject.getExtended">listviewObject.getExtended() </h6>
 获取树视图扩展样式

<h6 id="listviewObject.getExtended">listviewObject.getExtended(_LVS_EX__) </h6>
 获取树视图指定扩展样式

<h6 id="listviewObject.getFocused">listviewObject.getFocused(返回字段列号) </h6>
 获取当前焦点项位置,返回数值,不存在焦点项则返回0,  
  
返回字段列号为可选参数，  
返回值2为参数为返回行指定列的文本值

<h6 id="listviewObject.getFont">listviewObject.getFont() </h6>
 控件字体(::LOGFONT结构体)  
  
[返回对象:logfontObject](#logfontObject)

<h6 id="listviewObject.getHeader">listviewObject.getHeader() </h6>
 返回列标题窗口句柄

<h6 id="listviewObject.getImageList">listviewObject.getImageList( _LVSIL__ ) </h6>
 获取图像列表,  
可选使用 _LVSIL_ 前缀常量指定类型

<h6 id="listviewObject.getItem">listviewObject.getItem() </h6>
 [返回对象:lvitemObject](#lvitemObject)

<h6 id="listviewObject.getItem">listviewObject.getItem(__) </h6>
 返回LVITEM对象,参数为TVITEM结构体或指定部分成员的table对象.  
可选使用参数一指定行号,参考二指定列序号,  
不指定项目序号,则取当前焦点节点作为序号

<h6 id="listviewObject.getItemRect">listviewObject.getItemRect() </h6>
 [返回对象:rectObject](#rectObject)

<h6 id="listviewObject.getItemRect">listviewObject.getItemRect(行,列,RECT,选项) </h6>
 返回表示项目表示项目区块的RECT结构体,  
除第一个参数以外,其他参数为可选参数,  
如果不指定列则返回所在行区块,  
使用_LVIR_前缀常量指定选项

<h6 id="listviewObject.getItemState">listviewObject.getItemState(项索引,状掩码 ) </h6>
 读取状态值

<h6 id="listviewObject.getItemText">listviewObject.getItemText(行,列,缓冲区长度) </h6>
 返回指定项指定列文本，列默认值为1,  
如果列指定为-1，则返回一个包含所有列文本的数组,  
缓冲区最大字符数默认为520,  
不指定行序号则默认取当前选中焦点行,  
不指定列则默认设为1

<h6 id="listviewObject.getNextItem">listviewObject.getNextItem(起始索引,选项) </h6>
 参数二为一个或多个 _LVNI_ 前缀的常量合并  
默认为 _LVNI_ALL   
起始索引默认为0

<h6 id="listviewObject.getNotifyCustomDraw">listviewObject.getNotifyCustomDraw() </h6>
 [返回对象:NMLVCUSTOMDRAWObject](#NMLVCUSTOMDRAWObject)

<h6 id="listviewObject.getNotifyCustomDraw">listviewObject.getNotifyCustomDraw(code,ptr) </h6>
 NM_CUSTOMDRAW通知消息返回NMLVCUSTOMDRAW结构体

<h6 id="listviewObject.getNotifyDispInfo">listviewObject.getNotifyDispInfo() </h6>
 [返回对象:LVDISPINFOObject](#LVDISPINFOObject)

<h6 id="listviewObject.getNotifyDispInfo">listviewObject.getNotifyDispInfo(code,ptr) </h6>
 该函数限用于onnotify通知回调函数中  
code参数为通知码,ptr参数为NMHDR指针  
如果NMHDR指针指向LV_DISPINFO对象则返回该对象,否则返回空值

<h6 id="listviewObject.getNotifyMessage">listviewObject.getNotifyMessage() </h6>
 [返回对象:NMLISTVIEWObject](#NMLISTVIEWObject)

<h6 id="listviewObject.getNotifyMessage">listviewObject.getNotifyMessage(code,ptr) </h6>
 该函数限用于onnotify通知回调函数中  
code参数为通知码,如果ptr指向NMLISTVIEW对象则返回该对象.

<h6 id="listviewObject.getParent">listviewObject.getParent() </h6>
 返回父窗口  
  
[返回对象:staticObject](#staticObject)

<h6 id="listviewObject.getPos">listviewObject.getPos() </h6>
 返回相对坐标,宽,高  
x,y,cx,cy=win.getPos(hwnd)

<h6 id="listviewObject.getRect">listviewObject.getRect() </h6>
 控件区块位置(::RECT结构体)

<h6 id="listviewObject.getRect">listviewObject.getRect(true) </h6>
 控件屏幕区块位置(::RECT结构体)

<h6 id="listviewObject.getSelected">listviewObject.getSelected(__/*项索引*/) </h6>
 指定项是否选中状态

<h6 id="listviewObject.getSelection">listviewObject.getSelection(起始索引,返回字段列号) </h6>
 获取选中项,返回数值,不存在选中项则返回0  
可选指定起始索引,默认为0,  
  
返回字段列号为可选参数，  
返回值2为参数为返回行指定列的文本值

<h6 id="listviewObject.getTileViewInfo">listviewObject.getTileViewInfo() </h6>
 返回排列显示相关属性  
  
[返回对象:tileviewinfoObject](#tileviewinfoObject)

<h6 id="listviewObject.gridLines">listviewObject.gridLines </h6>
 是否显示网格线

<h6 id="listviewObject.height">listviewObject.height </h6>
 高度

<h6 id="listviewObject.hitTest">listviewObject.hitTest(x坐标,y坐标,是否屏幕坐标) </h6>
 该函数返回指定坐标的行号,参数三可省略,默认为false.  
如果不指定任何参数,则自动调用 win.getMessagePos() 获取消息坐标  
返回行号,列号,_LVHT_前缀的状态常量

<h6 id="listviewObject.hwnd">listviewObject.hwnd </h6>
 控件句柄

<h6 id="listviewObject.id">listviewObject.id </h6>
 控件ID

<h6 id="listviewObject.insertColumn">listviewObject.insertColumn(列名,列宽,位置,样式) </h6>
 第一个参数可以是标题字符串,图像索引,  
或者指定LVCOLUMN结构体成员的table对象,  
  
其他参数都是可选参数,  
样式使用_LVCFMT_前缀的常量指定,  
例如_LVCFMT_LEFT为文本左对齐,注意第一列只能左对齐,  
不指定样式则默认左对齐,  
如果列宽为-1,则自动调用fillParent(ind)函数填充剩余空间

<h6 id="listviewObject.items">listviewObject.items </h6>
 返回或设置包含所有列表项的数组  
数组的每个项表示一行，每行也必须是包含列文本的数组  
返回数组有一个可选字段 checked 包含了所有勾选的行

<h6 id="listviewObject.left">listviewObject.left </h6>
 左侧坐标

<h6 id="listviewObject.modifyStyle">listviewObject.modifyStyle(remove,add,swpFlags) </h6>
 修改窗口样式,所有参数都是可选参数,  
@remove 用数值指定要移除的样式,可使用 _WS_ 前缀的常量  
@add 用数值指定要添加的样式,可使用 _WS_ 前缀的常量  
@swpFlags 可选用数值指定调整窗口选项,可使用 _SWP_ 前缀的常量  
如果指定了 @swpFlag ,则使用该参数调用::SetWindowPos  
细节请参考 win.modifyStyle 函数源码

<h6 id="listviewObject.modifyStyleEx">listviewObject.modifyStyleEx(remove,add,swpFlags) </h6>
 修改窗口扩展样式,所有参数都是可选参数,  
@remove 用数值指定要移除的样式,可使用 _WS_EX_ 前缀的常量  
@add 用数值指定要添加的样式,可使用 _WS_EX_ 前缀的常量  
@swpFlags 可选用数值指定调整窗口选项,可使用 _SWP_ 前缀的常量  
如果指定了 @swpFlag ,则使用该参数调用::SetWindowPos  
细节请参考 win.modifyStyle 函数源码

<h6 id="listviewObject.onCheckedChanged">listviewObject.onCheckedChanged </h6>
 
    listviewObject.onCheckedChanged = function(checked,item){
    	/*勾选状态变更触发此事件。  
    checked 为是否勾选，item 为变更项序号*/
    }

<h6 id="listviewObject.onClick">listviewObject.onClick </h6>
 
    listviewObject.onClick = function(item,subItem,nmListView){
    	/*左键单击项目触发此事件。  
    item 为变更为焦点的项序号，subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.onDestroy">listviewObject.onDestroy </h6>
 
    listviewObject.onDestroy = function(){  
    	/*窗口销毁前触发*/  
    }

<h6 id="listviewObject.onDoubleClick">listviewObject.onDoubleClick </h6>
 
    listviewObject.onDoubleClick = function(item,subItem,nmListView){
    	/*左键双击项目触发此事件。  
    item 为变更为焦点的项序号，subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.onFocusedChanged">listviewObject.onFocusedChanged </h6>
 
    listviewObject.onFocusedChanged = function(item,subItem,nmListView){
    	/*焦点项变更触发此事件。  
    item 为变更为焦点的项序号，subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.onGetDispItem">listviewObject.onGetDispItem </h6>
 
    listviewObject.onGetDispItem = function(item,row,col){
    	/*处理 _LVN_GETDISPINFOW 通知消息  
    参数 @item 为 LVITEM 结构体,@row 为当前行号,@col 为当前列号,  
    返回 item 或包含 item 部分字段则更新 LVITEM 结构体*/
    	return {text="要显示的文本"}; 
    }

<h6 id="listviewObject.onItemChanged">listviewObject.onItemChanged </h6>
 
    listviewObject.onItemChanged = function(item,subItem,nmListView){
    	/*项目变更触发此事件。  
    item 为变更为焦点的项序号，subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.onRightClick">listviewObject.onRightClick </h6>
 
    listviewObject.onRightClick = function(item,subItem,nmListView){
    	/*右键点击项目触发此事件。  
    item 为变更为焦点的项序号，subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.onSelChanged">listviewObject.onSelChanged </h6>
 
    listviewObject.onSelChanged = function(selected,item,subItem,nmListView){
    	/*选中项更触发此事件。  
    selected 为是否选中，item 为变更项序号，  
    subItem 为列序号，nmListView 为 NMLISTVIEW 结构体*/
    }

<h6 id="listviewObject.oncommand">listviewObject.oncommand </h6>
 
    listviewObject.oncommand = function(id,event){  
    	/*命令事件触发*/  
    }

<h6 id="listviewObject.onnotify">listviewObject.onnotify </h6>
 
    listviewObject.onnotify = function(id,code,ptr){  
    	/*通知事件触发*/  
    }

<h6 id="listviewObject.orphanWindow">listviewObject.orphanWindow(transparent,hwndBuddy) </h6>
 创建悬浮窗口,  
悬浮窗口仍然显示在原来的位置,  
悬浮窗口如影随形的跟随父窗口移动或改变大小,控件原来的固定边距等参数仍然有效  
此控件不建议指定参数

<h6 id="listviewObject.postMessage">listviewObject.postMessage(msg,wParam,lParam) </h6>
 投递窗口消息到消息队列中  
此函数用法请参考 ::User32.PostMessage

<h6 id="listviewObject.redraw">listviewObject.redraw() </h6>
 刷新

<h6 id="listviewObject.replaceItems">listviewObject.replaceItems(__) </h6>
 替换所有列表项。  
参数@1 指定包含所有列表项的数组，格式与 items 属性相同。  
数组的每个项表示一行，每行也必须是包含列文本的数组，  
数组可以有一个可选字段 checked 包含了所有勾选的行。  
  
此函数不会事先清空列表，而 items 则会事先清空列表。  
当每次替换需要删除的项数较少时，此函数可避免清空导致的闪烁。  
建议先用 enableDoubleBuffering 函数启用双缓冲

<h6 id="listviewObject.right">listviewObject.right </h6>
 右侧坐标

<h6 id="listviewObject.selIndex">listviewObject.selIndex </h6>
 当前获得输入焦点的选中项,  
这指的是最后一次用鼠标点击且选中的项

<h6 id="listviewObject.selected">listviewObject.selected </h6>
 所有选中项目索引的数组,  
注意是选中列表项而不是指勾选复选框  
设为 null 或空表清除所有选中项

<h6 id="listviewObject.sendMessage">listviewObject.sendMessage(msg,wParam,lParam) </h6>
 发送窗口消息  
此函数用法请参考 ::User32.SendMessage

<h6 id="listviewObject.setChecked">listviewObject.setChecked(索引,是否勾选) </h6>
 勾选指定索引项前面的复选框，需要启用复选框支持  
参数@1为0则设置全部项目,  
参数@2省略则默认为true

<h6 id="listviewObject.setColumn">listviewObject.setColumn({cx=100},列序号) </h6>
 改变列宽

<h6 id="listviewObject.setColumn">listviewObject.setColumn(列参数表,列序号) </h6>
 参数一指定LVCOLUMN结构体成员键值的参数表,  
也可以是LVCOLUMN结构体对象,自动设置掩码参数.

<h6 id="listviewObject.setColumnImage">listviewObject.setColumnImage(col,iImage,fmt) </h6>
 使用col指定列索引设置该列的图像索引为iImage,  
第一列col的索引值为1,但图像列表的第一个图像索引为0,  
可选用fmt指定图像显示位置,此参数用法参考此函数源码

<h6 id="listviewObject.setColumnImageList">listviewObject.setColumnImageList(imgList) </h6>
 设置图像列表,  
参数可以是图像列表句柄,也可以传入win.imageList对象

<h6 id="listviewObject.setColumnText">listviewObject.setColumnText(位置,文本) </h6>
 设置指定列文本

<h6 id="listviewObject.setColumns">listviewObject.setColumns(column1,column2,...) </h6>
 参数用不定个数的字符串指定要显示的列  
如果参数@1为空则清空所有列

<h6 id="listviewObject.setColumns">listviewObject.setColumns(columns,widths,alignments) </h6>
 参数@1用一个字符串数组指定要显示的列  
如果参数@1为空则清空所有列,  
可选在 @widths 参数用一个数组指定各列宽度,  
可选在 @alignments 参数用一个数组指定各列对齐选项,  
各列可用参数与 insertColumn 函数相同

<h6 id="listviewObject.setExtended">listviewObject.setExtended(_LVS_EX__) </h6>
 启用树视图指定扩展样式

<h6 id="listviewObject.setExtended">listviewObject.setExtended(_LVS_EX__,false) </h6>
 取消树视图指定扩展样式

<h6 id="listviewObject.setFocus">listviewObject.setFocus() </h6>
 设置焦点

<h6 id="listviewObject.setFont">listviewObject.setFont(__/*指定字体*/) </h6>
 指定LOGFONT字体对象,或逻辑字体句柄

<h6 id="listviewObject.setFont">listviewObject.setFont(混入字体属性) </h6>
 
    listviewObject.setFont(point=10;name="宋体");

<h6 id="listviewObject.setImageList">listviewObject.setImageList( imageList,_LVSIL__ ) </h6>
 指定图像列表,  
可选使用 _LVSIL_ 前缀常量指定类型  
listview控件在销毁时将自动销毁最后一次指定的图像列表，  
通过替换并且不再使用的图像列表由用户负责销毁

<h6 id="listviewObject.setItem">listviewObject.setItem(LVITEM对象,行序号,列序号) </h6>
 更新项节点,参数为LVITEM结构体或指定部分成员的table对象  
如果参数未指定节点序号,则取当前焦点节点序号  
成功返回true;  
此函数可自动检测非空成员并自动设定相应mask位

<h6 id="listviewObject.setItemPos">listviewObject.setItemPos(__/*项索引*/,x,y) </h6>
 设置图标项坐标

<h6 id="listviewObject.setItemState">listviewObject.setItemState(项索引,状态位,掩码) </h6>
 设置状态,参数三如果省略则使用参数二的值.  
参数@1为0则设置全部项目,

<h6 id="listviewObject.setItemText">listviewObject.setItemText(文本,行,列) </h6>
 设置项目指定列文本,  
参数一也可是指定多列文本的数组  
设置的文本如果不是指针或空值则自动转换为字符串,  
不指定行序号则默认取当前选中焦点行,  
不指定列则默认设为1

<h6 id="listviewObject.setNotifyDispInfo">listviewObject.setNotifyDispInfo(ptr,dispinfo) </h6>
 参数@1为更新目标指针,  
参数@2必须是getNotifyDispInfo函数的返回值

<h6 id="listviewObject.setParent">listviewObject.setParent(__/*控件对象*/) </h6>
 改变父窗口

<h6 id="listviewObject.setPos">listviewObject.setPos(x坐标,y坐标,宽,高,插入位置,参数) </h6>
 调整窗口位置或排序,所有参数可选  
同时指定x,y坐标则移动位置  
同时指定宽高则改变大小  
指定插入位置(句柄或_HWND前缀常量)则调整Z序

<h6 id="listviewObject.setRect">listviewObject.setRect(rc) </h6>
 设置控件区块位置(::RECT结构体)

<h6 id="listviewObject.setRect">listviewObject.setRect(rc,true) </h6>
 设置控件屏幕区块位置(::RECT结构体)

<h6 id="listviewObject.setRedraw">listviewObject.setRedraw(false) </h6>
 禁止重绘

<h6 id="listviewObject.setRedraw">listviewObject.setRedraw(true) </h6>
 恢复重绘

<h6 id="listviewObject.setSelected">listviewObject.setSelected(__/*项索引*/) </h6>
 选中项,注意是选中列表项而不是勾选复选框

<h6 id="listviewObject.setSelected">listviewObject.setSelected(__/*项索引*/,false) </h6>
 取消选中项,注意是选中而不是勾选复选框

<h6 id="listviewObject.setTable">listviewObject.setTable(__) </h6>
 用listview控件显示数据表  
此函数会自动清空控件之前的所有项,  
如果没有创建任何列,则自动创建列  
如果要重新创建列,请先调用clear(true)清空原来的列,  
  
数据表应当包含行组成的数组,  
每行的数据列必须是由列名和列值组成的键值对  
数据表应使用fields包含需要显示的列名称数组  
可以通过fields控制要显的列、以及要显示的顺序  
  
使用sqlite,access,sqlServer等数据库对象提供的getTable函数可获取符合此规格的数据表

<h6 id="listviewObject.setTileViewInfo">listviewObject.setTileViewInfo() </h6>
 设置排列显示相关属性

<h6 id="listviewObject.show">listviewObject.show(true__) </h6>
 显示控件

<h6 id="listviewObject.theme">listviewObject.theme </h6>
 外观主题,例如  
winform.button.theme = "Explorer"  
winform.button.theme = false

<h6 id="listviewObject.threadCallable">listviewObject.threadCallable() </h6>
 开启此控件的跨线程调用功能

<h6 id="listviewObject.top">listviewObject.top </h6>
 顶部坐标

<h6 id="listviewObject.translateCommand">listviewObject.translateCommand() </h6>
 允许转发转发子窗口的命令（_WM_COMMAND）与通知（_WM_NOTIFY）消息，  
避免子窗口 oncommand，onnotify 等回调失效。  
同时会处理子窗口的 _WM_CTLCOLORSTATIC 等消息，  
以避免部分外观属性失效

<h6 id="listviewObject.valid">listviewObject.valid </h6>
 窗口是否有效，  
窗口未关闭返回 true ，  
窗口已关闭或正在关闭返回 false

<h6 id="listviewObject.width">listviewObject.width </h6>
 宽度

<h6 id="listviewObject.wndproc">listviewObject.wndproc </h6>
 
    listviewObject.wndproc = function(hwnd,message,wParam,lParam){  
    	/*窗口消息回调，返回任意非null值阻止默认回调  
    wndproc重复赋值时追加函数而不是覆盖之前的回调  
    设为null添除所有消息回调函数  
    wndproc也可以是一个表,键要为处理的消息,值为对应的消息回调函数*/	  
    }

<a id="LVDISPINFOObject"></a>
LVDISPINFOObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="LVDISPINFOObject.hdr">LVDISPINFOObject.hdr </h6>
 [返回对象:nmhdrObject](#nmhdrObject)

<h6 id="LVDISPINFOObject.item">LVDISPINFOObject.item </h6>
 [返回对象:lvitemObject](#lvitemObject)

<a id="NMLISTVIEWObject"></a>
NMLISTVIEWObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="NMLISTVIEWObject.hdr">NMLISTVIEWObject.hdr </h6>
 [返回对象:nmhdrObject](#nmhdrObject)

<h6 id="NMLISTVIEWObject.iItem">NMLISTVIEWObject.iItem </h6>
 鼠标指向项的行号  
没有使用则为0

<h6 id="NMLISTVIEWObject.iSubItem">NMLISTVIEWObject.iSubItem </h6>
 鼠标指向项的列序号  
没有使用则为0

<h6 id="NMLISTVIEWObject.lParam">NMLISTVIEWObject.lParam </h6>
 附加参数

<h6 id="NMLISTVIEWObject.ptAction">NMLISTVIEWObject.ptAction </h6>
 [返回对象:pointObject](#pointObject)

<h6 id="NMLISTVIEWObject.uChanged">NMLISTVIEWObject.uChanged </h6>
 类似LVITEM结构体中的mask成员  
以LVIF_前缀的常量标明改变的属性

<h6 id="NMLISTVIEWObject.uNewState">NMLISTVIEWObject.uNewState </h6>
 改变后状态  
由_LVIS_作为前缀的常量指定

<h6 id="NMLISTVIEWObject.uOldState">NMLISTVIEWObject.uOldState </h6>
 改变前状态  
由_LVIS_作为前缀的常量指定

<a id="NMLVCUSTOMDRAWObject"></a>
NMLVCUSTOMDRAWObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="NMLVCUSTOMDRAWObject.clrFace">NMLVCUSTOMDRAWObject.clrFace </h6>
 
    clrFace

<h6 id="NMLVCUSTOMDRAWObject.clrText">NMLVCUSTOMDRAWObject.clrText </h6>
 文字颜色

<h6 id="NMLVCUSTOMDRAWObject.clrTextBk">NMLVCUSTOMDRAWObject.clrTextBk </h6>
 文字背景色

<h6 id="NMLVCUSTOMDRAWObject.dwItemType">NMLVCUSTOMDRAWObject.dwItemType </h6>
 
    dwItemType

<h6 id="NMLVCUSTOMDRAWObject.iIconEffect">NMLVCUSTOMDRAWObject.iIconEffect </h6>
 
    iIconEffect

<h6 id="NMLVCUSTOMDRAWObject.iIconPhase">NMLVCUSTOMDRAWObject.iIconPhase </h6>
 
    iIconPhase

<h6 id="NMLVCUSTOMDRAWObject.iPartId">NMLVCUSTOMDRAWObject.iPartId </h6>
 
    iPartId

<h6 id="NMLVCUSTOMDRAWObject.iStateId">NMLVCUSTOMDRAWObject.iStateId </h6>
 
    iStateId

<h6 id="NMLVCUSTOMDRAWObject.iSubItem">NMLVCUSTOMDRAWObject.iSubItem </h6>
 列序号

<h6 id="NMLVCUSTOMDRAWObject.nmcd.dwDrawStage">NMLVCUSTOMDRAWObject.nmcd.dwDrawStage </h6>
 绘图状态

<h6 id="NMLVCUSTOMDRAWObject.nmcd.dwItemSpec">NMLVCUSTOMDRAWObject.nmcd.dwItemSpec </h6>
 行序号

<h6 id="NMLVCUSTOMDRAWObject.nmcd.hdc">NMLVCUSTOMDRAWObject.nmcd.hdc </h6>
 设置句柄

<h6 id="NMLVCUSTOMDRAWObject.nmcd.hdr">NMLVCUSTOMDRAWObject.nmcd.hdr </h6>
 [返回对象:nmhdrObject](#nmhdrObject)

<h6 id="NMLVCUSTOMDRAWObject.nmcd.lItemlParam">NMLVCUSTOMDRAWObject.nmcd.lItemlParam </h6>
 自定义数据，LPARAM 参数

<h6 id="NMLVCUSTOMDRAWObject.nmcd.rc">NMLVCUSTOMDRAWObject.nmcd.rc </h6>
 [返回对象:rectObject](#rectObject)

<h6 id="NMLVCUSTOMDRAWObject.nmcd.uItemState">NMLVCUSTOMDRAWObject.nmcd.uItemState </h6>
 状态值，例如 _CDIS_FOCUS

<h6 id="NMLVCUSTOMDRAWObject.rcText">NMLVCUSTOMDRAWObject.rcText </h6>
 [返回对象:rectObject](#rectObject)

<h6 id="NMLVCUSTOMDRAWObject.uAlign">NMLVCUSTOMDRAWObject.uAlign </h6>
 对齐

<h6 id="NMLVCUSTOMDRAWObject.update">NMLVCUSTOMDRAWObject.update() </h6>
 更新数据

<a id="lvcolumnObject"></a>
lvcolumnObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="lvcolumnObject.cchTextMax">lvcolumnObject.cchTextMax </h6>
 文本缓冲区长度

<h6 id="lvcolumnObject.cx">lvcolumnObject.cx </h6>
 宽度

<h6 id="lvcolumnObject.fmt">lvcolumnObject.fmt </h6>
 样式

<h6 id="lvcolumnObject.iImage">lvcolumnObject.iImage </h6>
 图像索引

<h6 id="lvcolumnObject.iOrder">lvcolumnObject.iOrder </h6>
 序号

<h6 id="lvcolumnObject.iSubItem">lvcolumnObject.iSubItem </h6>
 列号

<h6 id="lvcolumnObject.mask">lvcolumnObject.mask </h6>
 掩码;

<h6 id="lvcolumnObject.text">lvcolumnObject.text </h6>
 文本指针  
注意该值是指针类型而不是字符串类型  
转换为字符串必须首先判断mask包含4/*_LVCF_TEXT*/

<a id="lvitemObject"></a>
lvitemObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="lvitemObject.cColumns">lvitemObject.cColumns </h6>
 列数目

<h6 id="lvitemObject.cchTextMax">lvitemObject.cchTextMax </h6>
 文本长度

<h6 id="lvitemObject.iGroupId">lvitemObject.iGroupId </h6>
 组ID

<h6 id="lvitemObject.iImage">lvitemObject.iImage </h6>
 图像索引

<h6 id="lvitemObject.iIndent">lvitemObject.iIndent </h6>
 缩进

<h6 id="lvitemObject.iItem">lvitemObject.iItem </h6>
 行

<h6 id="lvitemObject.iSubItem">lvitemObject.iSubItem </h6>
 列

<h6 id="lvitemObject.lParam">lvitemObject.lParam </h6>
 附加值

<h6 id="lvitemObject.mask">lvitemObject.mask </h6>
 掩码

<h6 id="lvitemObject.puColumns">lvitemObject.puColumns </h6>
 [返回对象:pointObject](#pointObject)

<h6 id="lvitemObject.state">lvitemObject.state </h6>
 状态码

<h6 id="lvitemObject.stateMask">lvitemObject.stateMask </h6>
 状态掩码

<h6 id="lvitemObject.text">lvitemObject.text </h6>
 文本指针  
注意该值是指针类型而不是字符串类型  
转换为字符串必须首先判断mask是否包含1/*_LVIF_TEXT*/

<a id="tileviewinfoObject"></a>
tileviewinfoObject 成员列表
-------------------------------------------------------------------------------------------------

<h6 id="tileviewinfoObject.cLines">tileviewinfoObject.cLines </h6>
 行数

<h6 id="tileviewinfoObject.dwFlags">tileviewinfoObject.dwFlags </h6>
 
    tileviewinfoObject.dwFlags = _LVTVIF ;

<h6 id="tileviewinfoObject.dwMask">tileviewinfoObject.dwMask </h6>
 
    tileviewinfoObject.dwMask = _LVTVIM ;

<h6 id="tileviewinfoObject.rcLabelMargin">tileviewinfoObject.rcLabelMargin </h6>
 [返回对象:rectObject](#rectObject)

<h6 id="tileviewinfoObject.sizeTile">tileviewinfoObject.sizeTile </h6>
 [返回对象:sizeObject](#sizeObject)


自动完成常量
-------------------------------------------------------------------------------------------------
_CDIS_CHECKED=8  
_CDIS_DEFAULT=0x20  
_CDIS_DISABLED=4  
_CDIS_FOCUS=0x10  
_CDIS_GRAYED=2  
_CDIS_HOT=0x40  
_CDIS_INDETERMINATE=0x100  
_CDIS_MARKED=0x80  
_CDIS_SELECTED=1  
_CDIS_SHOWKEYBOARDCUES=0x200  
_LVCFMT_BITMAP_ON_RIGHT=0x1000  
_LVCFMT_CENTER=2  
_LVCFMT_COL_HAS_IMAGES=0x8000  
_LVCFMT_FILL=0x200000  
_LVCFMT_FIXED_RATIO=0x80000  
_LVCFMT_FIXED_WIDTH=0x100  
_LVCFMT_IMAGE=0x800  
_LVCFMT_JUSTIFYMASK=3  
_LVCFMT_LEFT=0x0  
_LVCFMT_LINE_BREAK=0x100000  
_LVCFMT_NO_DPI_SCALE=0x40000  
_LVCFMT_NO_TITLE=0x800000  
_LVCFMT_RIGHT=1  
_LVCFMT_SPLITBUTTON=0x1000000  
_LVCFMT_TILE_PLACEMENTMASK=0x300000  
_LVCFMT_WRAP=0x400000  
_LVCF_DEFAULTWIDTH=0x80  
_LVCF_FMT=1  
_LVCF_IDEALWIDTH=0x100  
_LVCF_IMAGE=0x10  
_LVCF_MINWIDTH=0x40  
_LVCF_ORDER=0x20  
_LVCF_SUBITEM=8  
_LVCF_TEXT=4  
_LVCF_WIDTH=2  
_LVFI_NEARESTXY=0x40  
_LVFI_PARAM=1  
_LVFI_STRING=2  
_LVFI_SUBSTRING=4  
_LVFI_WRAP=0x20  
_LVHT_ABOVE=8  
_LVHT_BELOW=0x10  
_LVHT_NOWHERE=1  
_LVHT_ONITEM=0xE  
_LVHT_ONITEMICON=2  
_LVHT_ONITEMLABEL=4  
_LVHT_ONITEMSTATEICON=8  
_LVHT_TOLEFT=0x40  
_LVHT_TORIGHT=0x20  
_LVIF_COLFMT=0x10000  
_LVIF_COLUMNS=0x200  
_LVIF_GROUPID=0x100  
_LVIF_IMAGE=2  
_LVIF_INDENT=0x10  
_LVIF_NORECOMPUTE=0x800  
_LVIF_PARAM=4  
_LVIF_STATE=8  
_LVIF_TEXT=1  
_LVIR_BOUNDS=0  
_LVIR_ICON=1  
_LVIR_LABEL=2  
_LVIR_SELECTBOUNDS=3  
_LVIS_ACTIVATING=0x20  
_LVIS_CUT=4  
_LVIS_DROPHILITED=8  
_LVIS_FOCUSED=1  
_LVIS_GLOW=0x10  
_LVIS_OVERLAYMASK=0xF00  
_LVIS_SELECTED=2  
_LVIS_STATEIMAGEMASK=0xF000  
_LVM_APPROXIMATEVIEWRECT=0x1040  
_LVM_ARRANGE=0x1016  
_LVM_CANCELEDITLABEL=0x10B3  
_LVM_CREATEDRAGIMAGE=0x1021  
_LVM_DELETEALLITEMS=0x1009  
_LVM_DELETECOLUMN=0x101C  
_LVM_DELETEITEM=0x1008  
_LVM_EDITLABEL=0x1017  
_LVM_ENABLEGROUPVIEW=0x109D  
_LVM_ENSUREVISIBLE=0x1013  
_LVM_FINDITEM=0x100D  
_LVM_FIRST=0x1000  
_LVM_GETBKCOLOR=0x1000  
_LVM_GETBKIMAGE=0x1045  
_LVM_GETCALLBACKMASK=0x100A  
_LVM_GETCOLUMN=0x1019  
_LVM_GETCOLUMNORDERARRAY=0x103B  
_LVM_GETCOLUMNW=0x105F  
_LVM_GETCOLUMNWIDTH=0x101D  
_LVM_GETCOUNTPERPAGE=0x1028  
_LVM_GETEDITCONTROL=0x1018  
_LVM_GETEMPTYTEXT=0x10CC  
_LVM_GETEXTENDEDLISTVIEWSTYLE=0x1037  
_LVM_GETFOCUSEDGROUP=0x105D  
_LVM_GETFOOTERINFO=0x10CE  
_LVM_GETFOOTERITEM=0x10D0  
_LVM_GETFOOTERITEMRECT=0x10CF  
_LVM_GETFOOTERRECT=0x10CD  
_LVM_GETGROUPCOUNT=0x1098  
_LVM_GETGROUPINFO=0x1095  
_LVM_GETGROUPINFOBYINDEX=0x1099  
_LVM_GETGROUPMETRICS=0x109C  
_LVM_GETGROUPRECT=0x1062  
_LVM_GETGROUPSTATE=0x105C  
_LVM_GETHEADER=0x101F  
_LVM_GETHOTCURSOR=0x103F  
_LVM_GETHOTITEM=0x103D  
_LVM_GETHOVERTIME=0x1048  
_LVM_GETIMAGELIST=0x1002  
_LVM_GETINSERTMARK=0x10A7  
_LVM_GETINSERTMARKCOLOR=0x10AB  
_LVM_GETINSERTMARKRECT=0x10A9  
_LVM_GETISEARCHSTRING=0x1034  
_LVM_GETITEMCOUNT=0x1004  
_LVM_GETITEMINDEXRECT=0x10D1  
_LVM_GETITEMPOSITION=0x1010  
_LVM_GETITEMRECT=0x100E  
_LVM_GETITEMSPACING=0x1033  
_LVM_GETITEMSTATE=0x102C  
_LVM_GETITEMTEXT=0x1073  
_LVM_GETITEMW=0x104B  
_LVM_GETNEXTITEM=0x100C  
_LVM_GETNEXTITEMINDEX=0x10D3  
_LVM_GETNUMBEROFWORKAREAS=0x1049  
_LVM_GETORIGIN=0x1029  
_LVM_GETOUTLINECOLOR=0x10B0  
_LVM_GETSELECTEDCOLUMN=0x10AE  
_LVM_GETSELECTEDCOUNT=0x1032  
_LVM_GETSELECTIONMARK=0x1042  
_LVM_GETSTRINGWIDTH=0x1011  
_LVM_GETSUBITEMRECT=0x1038  
_LVM_GETTEXTBKCOLOR=0x1025  
_LVM_GETTEXTCOLOR=0x1023  
_LVM_GETTILEINFO=0x10A5  
_LVM_GETTILEVIEWINFO=0x10A3  
_LVM_GETTOOLTIPS=0x104E  
_LVM_GETTOPINDEX=0x1027  
_LVM_GETUNICODEFORMAT=0x2006  
_LVM_GETVIEW=0x108F  
_LVM_GETVIEWRECT=0x1022  
_LVM_GETWORKAREAS=0x1046  
_LVM_HASGROUP=0x10A1  
_LVM_HITTEST=0x1012  
_LVM_INSERTCOLUMN=0x1061  
_LVM_INSERTGROUP=0x1091  
_LVM_INSERTGROUPSORTED=0x109F  
_LVM_INSERTITEM=0x104D  
_LVM_INSERTMARKHITTEST=0x10A8  
_LVM_ISGROUPVIEWENABLED=0x10AF  
_LVM_ISITEMVISIBLE=0x10B6  
_LVM_MAPIDTOINDEX=0x10B5  
_LVM_MAPINDEXTOID=0x10B4  
_LVM_MOVEGROUP=0x1097  
_LVM_MOVEITEMTOGROUP=0x109A  
_LVM_REDRAWITEMS=0x1015  
_LVM_REMOVEALLGROUPS=0x10A0  
_LVM_REMOVEGROUP=0x1096  
_LVM_SCROLL=0x1014  
_LVM_SETBKCOLOR=0x1001  
_LVM_SETBKIMAGE=0x1044  
_LVM_SETCALLBACKMASK=0x100B  
_LVM_SETCOLUMN=0x101A  
_LVM_SETCOLUMNORDERARRAY=0x103A  
_LVM_SETCOLUMNWIDTH=0x101E  
_LVM_SETGROUPINFO=0x1093  
_LVM_SETGROUPMETRICS=0x109B  
_LVM_SETHOTCURSOR=0x103E  
_LVM_SETHOTITEM=0x103C  
_LVM_SETHOVERTIME=0x1047  
_LVM_SETICONSPACING=0x1035  
_LVM_SETIMAGELIST=0x1003  
_LVM_SETINFOTIP=0x10AD  
_LVM_SETINSERTMARK=0x10A6  
_LVM_SETINSERTMARKCOLOR=0x10AA  
_LVM_SETITEMCOUNT=0x102F  
_LVM_SETITEMINDEXSTATE=0x10D2  
_LVM_SETITEMPOSITION=0x100F  
_LVM_SETITEMPOSITION32=0x1031  
_LVM_SETITEMSTATE=0x102B  
_LVM_SETITEMTEXT=0x1074  
_LVM_SETITEMW=0x104C  
_LVM_SETOUTLINECOLOR=0x10B1  
_LVM_SETSELECTEDCOLUMN=0x108C  
_LVM_SETSELECTIONMARK=0x1043  
_LVM_SETTEXTBKCOLOR=0x1026  
_LVM_SETTEXTCOLOR=0x1024  
_LVM_SETTILEINFO=0x10A4  
_LVM_SETTILEVIEWINFO=0x10A2  
_LVM_SETTOOLTIPS=0x104A  
_LVM_SETUNICODEFORMAT=0x2005  
_LVM_SETVIEW=0x108E  
_LVM_SETWORKAREAS=0x1041  
_LVM_SORTGROUPS=0x109E  
_LVM_SORTITEMS=0x1030  
_LVM_SORTITEMSEX=0x1051  
_LVM_SUBITEMHITTEST=0x1039  
_LVM_UPDATE=0x102A  
_LVNI_ABOVE=0x100  
_LVNI_ALL=0x0  
_LVNI_BELOW=0x200  
_LVNI_CUT=4  
_LVNI_DIRECTIONMASK=0xF00  
_LVNI_DROPHILITED=8  
_LVNI_FOCUSED=1  
_LVNI_PREVIOUS=0x20  
_LVNI_SAMEGROUPONLY=0x80  
_LVNI_SELECTED=2  
_LVNI_STATEMASK=0xF  
_LVNI_TOLEFT=0x400  
_LVNI_TORIGHT=0x800  
_LVNI_VISIBLEONLY=0x40  
_LVNI_VISIBLEORDER=0x10  
_LVN_BEGINDRAG=0xFFFFFF93  
_LVN_BEGINLABELEDIT=0xFFFFFF97  
_LVN_BEGINLABELEDITW=0xFFFFFF51  
_LVN_BEGINRDRAG=0xFFFFFF91  
_LVN_COLUMNCLICK=0xFFFFFF94  
_LVN_COLUMNDROPDOWN=0xFFFFFF5C  
_LVN_COLUMNOVERFLOWCLICK=0xFFFFFF5A  
_LVN_DELETEALLITEMS=0xFFFFFF98  
_LVN_DELETEITEM=0xFFFFFF99  
_LVN_ENDLABELEDIT=0xFFFFFF96  
_LVN_ENDLABELEDITW=0xFFFFFF50  
_LVN_FIRST=0xFFFFFF9C  
_LVN_GETDISPINFOW=0xFFFFFF4F  
_LVN_HOTTRACK=0xFFFFFF87  
_LVN_INSERTITEM=0xFFFFFF9A  
_LVN_ITEMACTIVATE=0xFFFFFF8E  
_LVN_ITEMCHANGED=0xFFFFFF9B  
_LVN_ITEMCHANGING=0xFFFFFF9C  
_LVN_KEYDOWN=0xFFFFFF65  
_LVN_LAST=FFFFFF39  
_LVN_MARQUEEBEGIN=0xFFFFFF64  
_LVN_ODCACHEHINT=0xFFFFFF8F  
_LVN_ODFINDITEM=0xFFFFFF68  
_LVN_ODSTATECHANGED=0xFFFFFF8D  
_LVN_SETDISPINFO=0xFFFFFF69  
_LVN_SETDISPINFOW=0xFFFFFF4E  
_LVSIL_GROUPHEADER=3  
_LVSIL_NORMAL=0  
_LVSIL_SMALL=1  
_LVSIL_STATE=2  
_LVS_ALIGNLEFT=0x800  
_LVS_ALIGNMASK=0xC00  
_LVS_ALIGNTOP=0x0  
_LVS_AUTOARRANGE=0x100  
_LVS_EDITLABELS=0x200  
_LVS_EX_AUTOAUTOARRANGE=0x1000000  
_LVS_EX_AUTOCHECKSELECT=0x8000000  
_LVS_EX_AUTOSIZECOLUMNS=0x10000000  
_LVS_EX_BORDERSELECT=0x8000  
_LVS_EX_CHECKBOXES=4  
_LVS_EX_COLUMNOVERFLOW=0x80000000  
_LVS_EX_COLUMNSNAPPOINTS=0x40000000  
_LVS_EX_DOUBLEBUFFER=0x10000  
_LVS_EX_FLATSB=0x100  
_LVS_EX_FULLROWSELECT=0x20  
_LVS_EX_GRIDLINES=1  
_LVS_EX_HEADERDRAGDROP=0x10  
_LVS_EX_HEADERINALLVIEWS=0x2000000  
_LVS_EX_HIDELABELS=0x20000  
_LVS_EX_INFOTIP=0x400  
_LVS_EX_JUSTIFYCOLUMNS=0x200000  
_LVS_EX_LABELTIP=0x4000  
_LVS_EX_MULTIWORKAREAS=0x2000  
_LVS_EX_ONECLICKACTIVATE=0x40  
_LVS_EX_REGIONAL=0x200  
_LVS_EX_SIMPLESELECT=0x100000  
_LVS_EX_SINGLEROW=0x40000  
_LVS_EX_SNAPTOGRID=0x80000  
_LVS_EX_SUBITEMIMAGES=2  
_LVS_EX_TRACKSELECT=8  
_LVS_EX_TRANSPARENTBKGND=0x400000  
_LVS_EX_TRANSPARENTSHADOWTEXT=0x800000  
_LVS_EX_TWOCLICKACTIVATE=0x80  
_LVS_EX_UNDERLINECOLD=0x1000  
_LVS_EX_UNDERLINEHOT=0x800  
_LVS_ICON=0x0  
_LVS_LIST=3  
_LVS_NOCOLUMNHEADER=0x4000  
_LVS_NOLABELWRAP=0x80  
_LVS_NOSCROLL=0x2000  
_LVS_NOSORTHEADER=0x8000  
_LVS_OWNERDATA=0x1000  
_LVS_OWNERDRAWFIXED=0x400  
_LVS_REPORT=1  
_LVS_SHAREIMAGELISTS=0x40  
_LVS_SHOWSELALWAYS=8  
_LVS_SINGLESEL=4  
_LVS_SMALLICON=2  
_LVS_SORTASCENDING=0x10  
_LVS_SORTDESCENDING=0x20  
_LVS_TYPEMASK=3  
_LVS_TYPESTYLEMASK=0xFC00  
_LVTVIF_AUTOSIZE=0x0  
_LVTVIF_EXTENDED=4  
_LVTVIF_FIXEDHEIGHT=2  
_LVTVIF_FIXEDSIZE=3  
_LVTVIF_FIXEDWIDTH=1  
_LVTVIM_COLUMNS=2  
_LVTVIM_LABELMARGIN=4  
_LVTVIM_TILESIZE=1  
