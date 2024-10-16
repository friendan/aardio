 
# aardio + bat 批处理混合编程指南
 

本文我们主要介绍 aardio + bat 批处理混合编程。

## 一、aardio + bat 入门

请在 aardio 中点击「主菜单 / 新建工程 」打开工程向导，然后点击 「 更多 / 批处理」选择批处理工程模板，然后点击「 创建工程 」按钮。

生成的批处理工程例初始代码很简单，我们在工程中双击打开程序入口代码 main.aardio ，然后点击运行以查看运行后的效果。

范例工程的 main.aardio 源代码如下：

```aardio
import fonts.fontAwesome;
import win.ui;
/*DSG{{*/
var mainForm = win.form(text="aardio工程4";right=875;bottom=625)
mainForm.add(
btnExecute={cls="plus";text="执行批处理 1";left=433;top=549;right=605;bottom=594;align="left";bgcolor=-5197169;db=1;dr=1;font=LOGFONT(h=-16);iconStyle={align="left";font=LOGFONT(h=-16;name='FontAwesome');padding={left=20}};iconText='\uF17A';notify=1;textPadding={left=42};z=2};
btnExecute2={cls="plus";text="执行批处理 2";left=637;top=549;right=809;bottom=594;align="left";bgcolor=-5197169;db=1;dr=1;font=LOGFONT(h=-16);iconStyle={align="left";font=LOGFONT(h=-16;name='FontAwesome');padding={left=20}};iconText='\uF17A';notify=1;textPadding={left=42};z=3};
editResult={cls="edit";left=15;top=13;right=863;bottom=536;db=1;dl=1;dr=1;dt=1;edge=1;hscroll=1;multiline=1;vscroll=1;z=1}
)
/*}}*/

import process.batch;
mainForm.btnExecute.oncommand = function(id,event){
	
	////优先调用 64 位命令请改为 process.batch.wow64 
	var prcs = process.batch("\bat\bat.aardio",{
		exepath = io._exepath; //传命名参数给批处理内的 aardio 代码，使用 owner.exepath 接收
		"批处理启动参数1"; //批处理使用 %1 接收第一个参数
		"批处理启动参数2"; //批处理使用 %2 接收第一个参数
	})
	
	mainForm.btnExecute.disabledText = {'\uF254';'\uF251';'\uF252';'\uF253';'\uF250';text=''}
	
	//out 用于接收批处理的全部输出(包含错误输出), err 为错误信息（无错误为 null ）
	var out,err = prcs.readAll(); //可在参数 @1 中指定匹配模式查找指定字符串
	mainForm.editResult.print(out);

	mainForm.btnExecute.disabledText = null;
}
	
mainForm.btnExecute2.oncommand = function(id,event){
	var prcs = process.batch("\bat\bat2.aardio",{
		text = "abc,传参数给批处理"; //传命名参数给批处理内的 aardio 代码，使用 owner.text 接收
		"批处理启动参数1"; //批处理使用 %1 接收第一个参数
		"批处理启动参数2"; //批处理使用 %2 接收第一个参数
	})
	
	mainForm.btnExecute2.disabledText = {'\uF254';'\uF251';'\uF252';'\uF253';'\uF250';text=''}
	
	//out 用于接收批处理的全部输出(包含错误输出), err 为错误信息（无错误为 null ）
	var out,err = prcs.readAll(); //可在参数 @1 中指定匹配模式查找指定字符串
	mainForm.editResult.print(out);

	mainForm.btnExecute2.disabledText = null;	
}

import style;
mainForm.btnExecute.skin(style.primaryButton);
mainForm.btnExecute2.skin(style.primaryButton);

mainForm.show();
win.loopMessage();
```

代码很简单，我们重点说一下上面代码中启动批处理的代码：

```aardio
var prcs = process.batch("\bat\bat.aardio",{
  exepath = io._exepath; //传递命名参数
  "批处理启动参数1"; //批处理使用 %1 接收第一个参数
  "批处理启动参数2"; //批处理使用 %2 接收第一个参数
})
```

process.batch() 函数用于启动批处理，返回一个进程管道对象。如果需要优先执行 64 位命令 —— 请改为 process.batch.wow64()，其他用法一样。  

先看参数 @1 指定的 bat 文件路径参数， aardio 中文件路径「首字符」可以用一个单斜杆（或反斜杆）表示应用程序根目录，应用程序根目录在开发时指工程目录或工程外独立启动的文件所在目录，发布后指 EXE 所在目录。

而 aardio 工程中的目录可以指定为「内嵌资源」，也就是将该目录下面的文件编译到 EXE 资源内。aardio 中很多文件有关的函数都自动兼容资源文件，代码不需要修改，上面的 `"\bat\bat.aardio"` 就是一个资源文件。

`"\bat\bat.aardio"`的文件后缀改成 \*.bat 后缀也是可以的，不过使用 \*.aardio 后缀可以直接在 aardio 中编辑。我们可以右键点击 `"\bat\bat.aardio"`，然后在弹出菜单中点击「跳转到文件」，打开的批处理代码如下：


```aardio
?>
@echo off 
for %%i in (<?

//这里可以嵌入 aardio 代码，使用 print 函数动态生成批处理代码
import fsys;
fsys.enum( "/", "*.*",
	function(dir,filename,fullpath,findData){ 
		if(filename){ 
			print(filename," ")
		}
		else {
			
		}
	},false
);

?>) do echo %%i 

echo 批处理工作目录："%cd%"


echo <?= time() ?>
echo <?= owner.exepath ?>

echo 此批处理接收到的第一个参数："%1"
echo 此批处理接收到的第二个参数："%2"

rem 批处理延时
ping 127.0.0.1 -n 2 >nul

rem 下面自定义批处理进程退出代码
exit /B 123
```

我们可以在批处理中编写 aardio 代码，遵守类PHP的 aardio 模板语法即可 —— 也就是将 aardio 代码置入`<? ?>` 模板标记就可以了。

aardio将 `<? ..... ?>` 之外的部分解析为：`print("批处理代码")` 以调用全局函数 print 输出批处理代码。print 函数可以接收多个参数，每个参数都会自动调用 `tostring()` 转换为字符串。

可以使用 `<?=表达式?>` 输出文本，该代码的作用类似于 `print( 表达式 )` , 下面的写法也是允许的

```aardio
<?
= 表达式
?>
```

我们再回到开始，看一下启动该批处理的 aardio 代码：

```aardio
var prcs = process.batch("\bat\bat.aardio",{
  exepath = io._exepath; //传递命名参数
  "批处理启动参数1"; //批处理使用 %1 接收第一个参数
  "批处理启动参数2"; //批处理使用 %2 接收第一个参数
})
```

`process.batch()` 用于启动批处理，第一个参数指定批处理文件（ 或者直接指定批处理代码也可以 ），后面可以用一个表参数指定批处理调用参数：

```aardio
{
  exepath = io._exepath; //传递命名参数
  "批处理启动参数1"; //批处理使用 %1 接收第一个参数
  "批处理启动参数2"; //批处理使用 %2 接收第一个参数
}
```

这个批处理表参数的数组成员传递为批处理的普通参数 —— 可以在批处理中用 `%1, %2` 等接收对应参数：

```bat
echo 此批处理接收到的第一个参数："%1"
echo 此批处理接收到的第二个参数："%2"
```

而表参数中的名值对成员则传为 aardio 模板参数，在 `"\bat\bat.aardio"` 内可以用 owner 参数接收该模板参数，例如该文件内可以用 aardio 代码 owner.exepath 获取调用参数 exepth 。

```aardio
?>
echo <?= owner.exepath ?>
```

process.batch() 返回一个进程管道对象 —— 也就是 process.popen 对象。使用该管道对象可以方便地读写批处理进程，获取返回值，退出代码等等。更多用法请参考标准库 process.popen 库函数文档。

其实用法很简单，例如等待批处理执行完成，并返回进程输出：

```aardio
var out,err = prcs.readAll(); //可在参数 @1 中指定匹配模式查找指定字符串
```

返回值 out 用于接收批处理的输出( 包含错误输出 )，返回值 err 用于接收批处理的错误输出。批处理调用" EXIT /B 数值"即可指定退出代码。

## 二、aardio 与批处理简单对比

本节提到的所有源码来自 aardio 自带范例。

下面是一个 aardio 调用批处理 for 语句的示例：

```aardio
import console
import process.batch;

//批处理 for 遍历并拆分字符串
var bat = process.batch(`
@echo off
for %%i in (abc,def,xyz) do echo %%i
`)
console.log( bat.readAll() )
console.pause();
```

下面我们用纯 aardio 代码实现上面的功能：循环遍历用空格键、跳格键(tab)、逗号、分号或等号拆分出来的字符串，aardio 代码如下：

```aardio
import console;
for( line in string.lines("abc,def,xyz","[\s,;=]") ){
  console.log(line)
}
console.pause(true);
```

上面是一个典型的 for 循环语句。string.lines() 用于创建迭代器，string.lines() 的第 @2 个参数指定分隔符 —— 支持类正则表达式的 aardio 模式匹配语法（请参考语法文档）。注意 aardio 里循环变量名 line 不需要在前面加%%，也没有只能使用26个字母的限制。

下面我们再看一个 aardio 调用批处理 for 语句的例子：

```aardio
import console
import process.batch;

//创建一个测试文件，双引号内换行符会解释为 '\n'
string.save("/test.txt","abc,def
123,456" )

//批处理 for 遍历并按行拆分字符串
var bat = process.batch(`
@echo off
for /f "usebackq delims=, tokens=1,2" %%i in ("test.txt") do echo %%i,%%j
`)
/*
注意文件路径如果有空格必须包含在引号内
如果要用引号包含路径，就必须加上 usebackq，usebackq的意思是用反引号包含命令，
单引号包含字符串，然后双引号就可以包含文件路径而不是字符串了
*/
 
console.dump(bat.readAll())
console.pause()
```

用纯 aardio 代码这样写：

```aardio

import console

//aardio 需要先读文件到字符串
var str = string.load("/test.txt")

//参数@3指定delims，可以用强大的模式匹配语法指定分隔符
for tokens in string.lines(str,,",") {
   /*
   tokens 是一个数组，可以用 string.join
   任意拼接数组中指定范围的元素实现批处理 tokens=n-m 的效果
   */
  console.log(tokens[1],tokens[2])
}

console.pause()
```

其实在 aardio 中还可以 string.each() 实现类似功能，如下：

```aardio
for a,b in string.each(str,"([^,]+),(.+)"){
  console.log(a,b)
}
```

再看一个例子，aardio 中调用 for 语句遍历文件这样写：

```aardio
import console;
import process.batch;

//批处理 for 遍历一个目录下的所有文件
var bat = process.batch(`
@for /r "./" %%I in (*) do @echo %%I
`)

for( all,out,err in bat.each() ){
   console.log(all)
}
console.pause()
```

改成纯 aardio 代码遍历文件这样写：

```aardio
import console;

//aardio 遍历一个目录下的所有文件
import fsys;
fsys.enum( "/", "*.*",
  function(dir,filename,fullpath,findData){
    if(filename){
          console.log("发现文件："+filename,"完整路径："+fullpath)
    }
    else{
      console.log( "发现目录：" + dir )
    }
  }
);
console.pause();
```

## 三、执行 CMD 命令与进程管道操作

如果我们不需要执行 bat 批处理。也可以用 process.popen 直接调用 cmd.exe 创建进程管道。注意 process.batch 同样是基于 process.popen 调用 cmd.exe ，对进程管道的操作是一样的。

批理执行 CMD 命令：

```aardio
import process.popen

//打开命令行,隐藏命令行窗口
var prcs = process.popen.cmd(`
CD "C:\Program Files"
C:
dir
mkdir test
rmdir test
`)

//显示结果
import win;
win.msgbox(prcs.readAll())
```

process.popen 创建的进程对象不会打开黑窗口，而且可以通过返回的进程管道读写进程标准输出输入。当然这个方法不仅仅是可以用于 cmd.exe ，也适用于所有控制台程序。

再看一个读写进程管道的例子：

```aardio
//管道读写

import process.popen

/*
打开命令行,隐藏命令行窗口
如果包含弹出控制台窗口的外部命令，
请将下面的 process.popen.detached 换为 process.popen
*/
var prcs = process.popen.detached("cmd.exe")

//如果调用UTF8编码的程序，请添加下面的编码声明
//prcs.codepage = 65001

var cmd = /*
CD C:\
C:
dir 
mkdir test
rmdir test
*/

prcs.write(cmd)
var result = prcs.peekTo(">");
prcs.print('exit')

//显示结果
import console;
console.log( result );
console.pause("pause");
```

## 四、环境变量

直接看范例：

```aardio

import win;
import process.popen

//在父进程中指定环境变量
string.setenv("TESTENV","测试变量值");

//也可以用下面的方法
//import environment
//environment.user().set("TESTENV","测试变量值")

//打开命令行,隐藏命令行窗口
var prcs = process.popen.cmd(`echo %TESTENV%`) 

//也可以在 process 或 process.popen 参数@3中通过 environment为目标进程指定环境变量
var prcs = process.popen("cmd.exe","/c echo %TESTENV2%",{
  environment = {
    TESTENV2 = "测试变量值2"
  }
})

import fsys.environment;
import process.batch;
var prcs = process.batch( `
@echo off
set TESTENV3=测试变量值3<?
  print( fsys.environment.expand("%appdata%") )

?>&
echo %TESTENV3%
`)

//显示结果
import win;
win.msgbox(prcs.read(-1))
```

## 五、发送 Ctrl + C

直接看范例：

```aardio
//发送Ctrl+C
import console
import process.popen

var prcs = process.popen("ping 127.0.0.1 -n 10 ")
for( all,out,err in prcs.each() ){
    console.log( out,err ); 
    prcs.ctrlEvent(0);
}

console.pause();
```