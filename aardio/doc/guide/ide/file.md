# aardio 代码文件与工程文件

## aardio 源文件

aardio 代码文件的后缀名为 `.aardio`，可包含 UTF-8 编码的源代码，也可以包含编译后的二进制代码。

## aardio 工程文件

aardio 工程文件的后缀名为 `.aproj`，其内容是 XML 格式的工程配置，也使用  UTF-8 编码 。  

aardio 允许在一个工程目录包含多个 aproj 工程文件，但大多时候一个工程目录基本上都只有一个 default.aproj 。

aardio 工程文件通常默认命名为 default.aproj 。
 
以下是一个 web.view 工程文件的内容：

```xml
<?xml version="1.0" encoding="utf-8"?>
<project ver="37" name="web.view 示例工程" libEmbed="true" icon="..." ui="win" output="发布名称.exe" CompanyName="aardio" FileDescription="aardio 工程名称" LegalCopyright="Copyright (C) 作者 2025" ProductName="产品名称" InternalName="内部文件名" FileVersion="0.0.0.1" ProductVersion="0.0.0.1" publishDir="/dist/" dstrip="false">
	<file name="main" path="main.aardio"/>
	<folder name="窗体" path="forms" comment="" embed="true" local="false" ignored="false"/>
	<folder name="网页" path="web" embed="true" comment="目录" local="true">
		<file name="index.html" path="web\index.html" comment="web\index.html"/>
		<file name="index.js" path="web\index.js" comment="web\index.js"/>
	</folder>
	<folder name="网页源码" path="web.src" embed="false" comment="目录" local="false" ignored="true"/>
</project>
```

- project 元素指定工程配置，并作为工程根目录包含其他 folder 或 file 元素。

    project 元素的属性 ui 指定图形界面。 

        * 如果 ui 为 "win" 则为图形界面发布后运行默认不显示控制台。
        * 如果 ui 为"console" 则为控制台程序发布后运行时默认显示控制台窗口。

    project 元素的属性 dstrip 指定是否移除调试符号。 

        * `dstrip="true"` 则发布后移除调试信息，生成的文件更小但错误信息会缺少调试信息（例如文件名行号）。

- folder 元素为工程中的虚拟目录

    如果 folder  的属性 embed 为 "true" 则该目录发布后嵌入 EXE 资源文件，aardio 中很多函数和库都自动支持这种嵌入资源而不需要额外修改代码。例如对于 `string.load("/res/test.txt")`，无论参数指定的文件是不是 EXE 资源文件函数的返回值都是一样的，这是 aardio 的一个主要特性。

    如果 folder 元素的属性 local 为 "true" 则表示这是一个本地目录（通常也是 Web  前端工程的发布目录），发布为 EXE 时将添加该目录下的所有文件。这种目录在工程中不显示子级文件或目录，右键菜单的『同步本地目录』也是无效的。 

    如果 folder 元素的属性 ignored 为 "true" 是指这个目录在发布时被忽略（ignored）。这种目录通常用来指向包含 Web 前端工程源码的目录，工程本身其实并不需要这些多余的目录，生成 EXE 时也会忽略这种目录。

- file 元素则表示添加到工程中的文件

    在工程根目录下只能有一个应用程序启动文件, 文件路径必须是 `main.aardio` 或以  `.main.aardio` 结束。除了启动文件，工程根目录只能包含 folder 元素。

aardio 工程根目录也是 [应用程序根目录](../../library-guide/builtin/io/path.md#app-path)，在 aardio 中文件路径第一个字符如果是单个斜杠或反斜杠则表示应用程序根目录，例如 `/res/test.txt` 。
