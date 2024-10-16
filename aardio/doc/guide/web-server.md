# aardio 语言 Web 服务端开发指南

## 简介

aardio 用户接触 Web 开发的相对比较多，在 aardio 中开发桌面软件，应用 Web 技术,HTML 等等非常普遍，
所以大家切换到网站开发应当是轻车熟路，不会有太大的难度，现在很多软件应用都是基于服务端接口，几乎每一个软件都要与服务端接口互动，不仅仅是桌面软件，例如一些手机应用，客户端是HTML5,服务端是REST接口，这种模式是未来的方向，所以应用领域还是比较广的。

实际上在 aardio 中开发网站应用非常简单，大家可以把网站理解为控制台程序，
只不过取代 console.log 的是 `response.write` 函数。一句 aardio 代码

`response.write("hello")`

就输出一个最简单的网页了。

aardio 直接支持与 PHP 类似的语言级模板语法，可以 html,aardio 代码混合生成页面，非常方便。


## 网站开发

### 创建网站工程

首先请在主菜单中点击新建工程。

在工程向导中点选【网站程序】，创建网站工程。默认的 main.aardio 中包含一个在本地启动 Web服务器的代码（ 不需要安装IIS这些，直接用aardio实现的Web服务器）

创建一个Web服务器非常简单，几句代码就可以了，如下：

```aardio
import wsock.tcp.simpleHttpServer; 
var app = wsock.tcp.simpleHttpServer("127.0.0.1",8081);
 
app.run(
     
    function(response,request){
     
    }
);
```

上面的代码在本地IP 127.0.0.1启动一个Web服务器，监听连接的端口为 8081，
用户每一次连接都自动回调 函数  `function(response,request,session){ }`

每一个 aardio 创建的 Web 服务器应用都应该遵守相同的调用约定，使用相同的回调函数格式，并创建相同的 `response`,`request` 对象，无论是创建本地服务器，还是在IIS等Web服务器上创建FastCGI模块，网站应用程序的入口是一致的。

### aardio 模板语法

在 aardio 代码中可直接支持 HTML 模板语法。

#### 一、aardio 代码如果以 HTML 代码开始，或以 `<?` 标记开始则自动启用模板语法。  
aardio 代码可以是纯 aardio 代码，也可以是纯 HTML，或者是 HTML、aardio 相互混合的模板代码。  

可直接将 HTML 模板代码复制到 aardio 编辑器中运行并预览网页。
  
可在 aardio 开发环境新建一个 aardio 源码文件，复制下面的源代码并粘贴到 aardio 编辑器中：

```aardio
<!doctype html>
<html><head><meta charset="utf-8"><title>帮助页面</title></head>
<body>当前时间<? = time() ?>
</body></html>
```

然后点【运行】按钮，可以看到立即生成了一个网页。  

#### 二、启用模板语法以后，aardio 代码必须置于 `<? ..... ?>` 内部。  
aardio 将不在 `<? ..... ?>` 之内的部分作为参数调用全局函数 print 函数输出。  
aardio 模板语法并不限于输出 HTML 代码 - 而是可用于输出任何文本。

#### 三、使用 print 函数的规则：

*   aardio 中全局 print 函数只能用于捕获或修改模板输出，不可用于其他用途。
*   print 允许接收多个参数，并且必须对每个参数调用 tostring() 以转换为字符串。
*   在一个独立 aardio 模板文件解析结束时，print 函数将收到一个 null 参数调用。

  
aardio 提供 string.loadcode() 函数可直接解析 aardio 模板并获取模板输出。  
请在标准库 builtin/string 中查看此函数的源代码，了解如何通过自定义 print 函数捕获或修改模板输出。

#### 四、模板开始标记 `<?` 必须独立，不能紧跟英文字母。例如 `<?xml...` 不被解析为 aardio 代码段开始标记。  
另外，aardio 总是忽略文件开始的空白字符（包含空格、制表符，换行）。

#### 五、可以使用 `<?=表达式?>` 输出文本 - 作用类似于 print( 表达式 )，可用逗号分隔多个表达式。  
aardio 会忽略表达式前面等号首尾的空白字符 , 下面的写法也是允许的：  

```aardio
<?
= 表达式1,表达式2
?>
```

#### 六、aardio 文件只能以 UTF-8 编码保存，不建议添加 UTF8 BOM(如果添加了 BOM,aardio 仍然会自动移除)


### 网站开发 request,response,session 对象函数文档

请参考  fastcgi.client 库模块帮助文档中 request,response,session 对象的函数文档。

request,response,session 的文档由 fastcgi.client 库模块提供。

在 aardio 中所有 HTTP 服务端实现都支持兼容的 request,response,session 对象，这些对象的接口与用法是一样的。


## 创建 FastCGI 服务端

首先请在主菜单中点击新建工程。

在工程向导中点选【CGI 服务端】，创建 CGI 服务端工程。

CGI 服务端应先生成 EXE 文件、并在 Web 服务器上注册为 FastCGI 模块才能使用，
IIS 服务器可通过在代码中 import fastcgi.iisInstall 自动注册 FastCGI 模块。

### 注册  FastCGI 模块操作步骤

以 Win2008 ,IIS7 为例:

1. 桌面右键点【计算机】，弹出菜单中点【管理】，【添加角色/添加IIS】

2. 右键点【Web服务器(IIS)】，弹出菜单中点【添加角色服务】，确认已添加【CGI】

3. 然后打开IIS，到指定的网站点击【处理程序映射】，添加【处理程序映射】
   后缀名设为：*.aardio ( 如果设为 *,取消勾选请求限制到文件或目录则处理所有URL )
   模块选：FastCgiModule 可执行文件：选中使用本工程生成的 aardio-cgi.exe 
   
4. 在资源管理器右键点击 aardio-cgi.exe 所在目录，在目录属性中点【安全】，
添加IUSR,IIS_USER用户组,允许读取和执行、列出目录、写入权限。

5. 右键点击网站所在目录，在目录属性中点【安全】，添加IUSR,IIS_USER用户组,
允许读取和执行、列出目录、写入权限。

6. 如果是64位系统，请在应用程序池属性中设置"启用32位的应用程序"为 True

### 常见问题解答

1. 如果用新版aardio编写的代码，在旧版编译的CGI.EXE中运行报错，那么把旧版CGI.EXE重新编译一次就可以。

2. import导入的库，在一个进程中只会加载一次, 如果网站引用了修改的库，应当杀除CGI.EXE进程重启动，如果在服务器上编译CGI.EXE，此工程会在发布后自动执行此操作。工程内的发布前触发器,\.build\default.init.aardio 会在每次发布前停止已运行的CGI进程，这个操作需要管理权限如果在本机上安装IIS测试，本机测试建议以管理权限启动aardio开发环境

3. 如果是64位系统，请在应用程序池属性中设置"启用32位的应用程序"为True

4. CGI.EXE 内部错误可请查看"CGI.EXE目录/config"下面生成的日志文件。网页代码发生500内部错误，可查看"网站目录/config"下面生成的日志文件。使用localhost绑定并访问要测试的网站也可以查看500错误的详细信息。

5. 注意在编写网站时，有必要请输出日志文件来排查错误
 



