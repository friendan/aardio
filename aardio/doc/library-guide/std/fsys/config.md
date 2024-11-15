
# 使用 fsys.table,fsys.config 创建配置文件 

## 简介

fsys.config 实际上是对 fsys.table的封装，
fsys.table 的功能是将table对象映射为硬盘文件 - 以创建一个可持久化的 table 对象，在 aardio中 数组、哈希表、结构体等等都是 table（请参考语法文档）。

fsys.table 使用 table.tostring() 函数将一个table转换为aardio代码并写入一个字符串对象（忽略表的所有函数成员）。然后将此字符串写入硬盘，在加载文件时，使用 eval()函数解析aardio 代码重新生成table对象。

## 基本用法

fsys.table 的用法非常简单，最简单的 aardio 代码示例：

```aardio
import fsys.table;
var ftbl = fsys.table("/test/test.table"); //注意参数指定的目录或文件不存在时会自动创建目录。
ftbl.name = 123;
```

上面的ftbl对象就象一个普通的table对象那样使用，
区别是在线程结束时，他会自动更新对应的硬盘文件的值（ 控制台程序直接点关闭按钮 - 这种异常终止程序时不会更新硬盘文件）。

ftbl对象 还提供以下常用的一些成员函数:

- ftbl.load() 函数用于再次从硬盘文件重新载入值。
- ftbl.save() 函数用于手动保存表到硬盘文件。
- ftbl.assign() 函数用于将参数指定的表混入到当前对象,类似table.assign ()函数。
- ftbl.mix() 函数同样是混入表到当前对象，但是不会覆盖已经存在的值，类似 table.mix() 函数。
- ftbl.beforeSave 用于自定义一个回调函数，可在保存配置文件以前自动调用。

fsys.config 与 fsys.table 类似，区别是 fsys.config 的构造参数是一个文件目录，而不是像 fsys.table 那样在构造参数中指定一个具体的配置文件路径。在获取 fsys.config 配置对象的成员时将会自动使用同名配置文件作为构造参数的创建一个 fsys.table 对象 。

示例 aardio 代码：

```aardio
import fsys.config;
config = fsys.config("/config/")
config.uiSetting.height = 123;
```

config 的成员配置文件名不能以下划线开始，例如 config._uiSetting 这样写是错的。上面的 config.uiSetting 将会自动生成一个fsys.talbe对象 - 对应的硬盘文件存储于创建 fsys.config对象时指定的 "/config/"目录下（  config.uiSetting 对应的硬盘文件为 "/config/uiSetting.table"）。

config 对象只有一个成员函数，也就是 config.saveAll() 函数，用于保存所有的配置文件。即使你不调用这个函数，在退出程序时，也会自动保存所有配置文件（除非程序意外终止）。

如果你不希望将配置文件保存在当前目录，而是系统的 AppData 目录（这也是推荐的做法），那么可以象下面这样写：

```aardio
config = ..fsys.config(
    ..io.appData("/应用程序名/" )
);
```

## 在窗口中应用配置文件

win.form创建的窗口对象，可以使用 bindConfig() 函数将控件绑定到配置文件，示例：

```aardio
import fsys.config;
config = fsys.config("/config/");

//将窗口控件绑定到配置文件 config.mainForm
winform.bindConfig( config.winform,{
    edit = "text";
    radiobutton = "checked";
    checkbox = "checked";
    combobox = "selIndex";
} );
```

这个函数的第一个参数指定一个 fsys.table 对象（ fsys.config 的成员也就是 fsys.table 对象 ），
第二个参数可选指定一个选项表（可省略此参数），选项表的键为控件类名，选项表的值为指定类名的控件需要同步到配置文件的控件属性名称。

窗口如果绑定了 fsys.table 配置文件，那么在窗口销毁后，控件指定的值将会自动同步到配置文件。


下面是一个更完整的 aardio 代码示例，演示了如何重置控件的值、如何手动保存配置：


```aardio
import win.ui;
/*DSG{{*/
winform = ..win.form(text="aardio form";right=599;bottom=399)
winform.add(
btnReset={cls="button";text="重置";left=389;top=351;right=521;bottom=379;z=3};
btnSave={cls="button";text="保存";left=231;top=351;right=363;bottom=379;z=1};
edit3={cls="edit";text="edit3";left=44;top=42;right=407;bottom=68;edge=1;multiline=1;z=2}
)
/*}}*/

import fsys.config;

//创建配置文件
var config = fsys.config("/config/");

//将窗口控件绑定到配置文件 config.mainForm
winform.bindConfig( config.winform,{
    edit = "text";
} );

//取消或重置为初始值
winform.btnReset.oncommand = function(id,event){ 
    config.winform.load();
}

//也可以手动保存配置文件
winform.btnSave.oncommand = function(id,event){
    config.winform.save();
}

//显示窗口
winform.show();

//启动界面线程消息循环
win.loopMessage();
```

绑定 fsys.table 配置文件的窗口在销毁时将自动同步控件的指定值到配置文件。

