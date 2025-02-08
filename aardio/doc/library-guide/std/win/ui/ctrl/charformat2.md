# 富文本框控件 - 颜色样式

富文本编辑框控件（ win.ui.ctrl.richedit ）继承自编辑框控件（ win.ui.ctrl.edit ），richedit 基本继承了 edit 控件的所有功能，但增加了一些功能特性，例如支持超链接与颜色样式，支持透明背景等。

## 使用 setSelCharformat 函数 <a id="setSelCharformat" href="#setSelCharformat">&#x23;</a>

我们可以使用 richedit 控件提供的 setSelCharformat 函数修改标插入点或当前选区的默认样式。

要点：

- setSelCharformat 的参数是 [win.ui.ctrl.CHARFORMAT2](../../../../../library-reference/win/ui/ctrl/richedit.html#charformat2Object) 结构体。
    但我们一般不必要创建这个结构体，直接传入一个普通的表，表中可以指定 CHARFORMAT2 结构体的任意字段。setSelCharformat 会自动将接收到的表参数转换为 CHARFORMAT2 结构体。
- setSelCharformat 函数修改的是选区或光标插入点的默认样式，所以必须先设置好光标插入点或者文本选区。

下面是 setSelCharformat 函数的基本用法示例:

```aardio
import win.ui;

//创建窗口
var winform = win.form(text="在富文本框输入带颜色字体";right=759;bottom=469)

//添加富文本框与按钮控件
winform.add(
    richedit={cls="richedit";left=25;top=15;right=716;bottom=398;edge=1;multiline=1;z=1};
    button={cls="button";text="输入指定颜色字体";left=502;top=412;right=667;bottom=458;z=2}
)

//响应按钮事件
winform.button.oncommand = function(id,event){
	  
	// winform.richedit.setSelCharformat 函数会自动将参数 cf2 转换为 win.ui.ctrl.CHARFORMAT2 结构体。
    var charformat2 = {};
 
    // 设置红色文本
    charformat2.textColor = 0x0000FF;  //RGB 颜色值，格式 0xBBGGRR
    
    //指定光标插入点或当前选区的默认样式
    winform.richedit.setSelCharformat(charformat2);
    
    //在光标插入点输入文本或修改当前选区文本。
    winform.richedit.selText = "这是红色文本";
    
    //将输入光标（光标插入点）移动到尾部
    winform.richedit.setsel(-1);
    
    // 设置蓝色文本
    charformat2.textColor = 0xFF0000 //RGB 颜色值，格式 0xBBGGRR
    
    //指定光标插入点或当前选区的默认样式
    winform.richedit.setSelCharformat(charformat2);
    
    //在光标插入点输入文本或修改当前选区文本。
    winform.richedit.selText = "这是蓝色文本";
    
    //将输入光标（光标插入点）移动到尾部
    winform.richedit.setsel(-1);
}

//显示窗口
winform.show();

//启动界面消息循环
win.loopMessage();
```

注意 winform.richedit.log, winform.richedit.print 这些函数实际上是修改  winform.richedit.text ，也就是修改整个控件的文本，这会让局部样式失效。

## 使用 appendText  函数 <a id="appendText" href="#appendText">&#x23;</a>


如果要插入特定样式的文本，只能使用 winform.richedit.appendText 函数。而且 winform.richedit.appendText 总是会自动将光标插入点移动到文本末尾，有利于连续的设置文本样式。

winform.richedit.appendText 还能直接在参数中指定样式表参数，这些样式表可以仅指定 win.ui.ctrl.CHARFORMAT2 结构体的部分字段，并由 winform.richedit.appendText 自动转换为 CHARFORMAT2 结构体。

下面是使用 winform.richedit.appendText 插入带颜色文本的示例：

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="在富文本框输入带颜色字体";right=759;bottom=469)
winform.add(
button={cls="button";text="输入指定颜色字体";left=502;top=412;right=667;bottom=458;z=2};
richedit={cls="richedit";left=25;top=15;right=716;bottom=398;edge=1;multiline=1;z=1}
)
/*}}*/

//响应按钮事件
winform.button.oncommand = function(id,event){
	
	/*
	追加文本，支持任意个文本参数或样式表参数。
    每个样式都会修改后面文本的样式，如果指定了样式表，函数返回前会恢复默认样式。 
	样式表可指定 CHARFORMAT2 结构体或者部分需要修改的字段即可。
	*/
	winform.richedit.appendText( 
		{ textColor = 0xFF0000 },
		" ","蓝色文本",
		{  protected = true, point = 16 },
		" ","绿色文本",
		{ textColor = 0x0000FF,point = 8 },
		" ","红色文本1", " ","红色文本2", " ","红色文本3",
	);
	
	winform.richedit.appendText("默认样式");
}

winform.show();
win.loopMessage();
```

样式表参数一般只需要指定 CHARFORMAT2 结构体中你需要设置的字段即可，aardio 会自动转换为结构体。

CHARFORMAT2 常用字段：

- backColor: 背景颜色，GDI 颜色格式（ 0xBBGGRR ）。
- textColor: 字体颜色，GDI 颜色格式（ 0xBBGGRR ）。
- faceName: 字体名 
- point: 字体大小，以 pt 为单位
- italic = 是否斜体，仅用于写入样式。 
- strikeout = 是否显示删除线，仅用于写入样式。   
- underlineType: 下划线类型 
- underline = 是否粗体，仅用于写入样式。

根据 aardio 的语法规则第一个参数是样式表时可以省略包围表的 `{}`，例如：

```aardio
winform.richedit.appendText( textColor = 0xFF0000, "蓝色文本" ) 
```

上面的代码等价于：

```aardio
winform.richedit.appendText( { textColor = 0xFF0000, "蓝色文本"} ) 
```

winform.richedit.appendText 如果只有一个表参数，可以通过数组成员指定文本，也可以通过 text 字段指定文本，例如：

```aardio
winform.richedit.appendText({ 
    textColor = 0x00FF00;  // 使用 RGB 颜色值（0xBBGGRR 格式）,这里是绿色
    text = "这是绿色文本";
})
```

# 使用 TO 文本对象（COM 对象）设置样式

```aardio
import win.ui;
/*DSG{{*/
var winform = win.form(text="在富文本框输入带颜色字体";right=759;bottom=469)
winform.add(
richedit={cls="richedit";left=25;top=15;right=716;bottom=398;edge=1;multiline=1;z=1}
)
/*}}*/

//使用 TO 文本对象（COM 对象）设置样式
var textDoc = winform.richedit.createTextDocument()

textDoc.Selection.Text = "红色加粗"
textDoc.Selection.Font.ForeColor = gdi.RGB(255,0,0)  // 红色
textDoc.Selection.Font.Bold = textDoc.tomTrue  // 加粗

winform.show();
win.loopMessage();
```


