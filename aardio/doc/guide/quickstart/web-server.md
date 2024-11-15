# aardio 语言 Web 服务端开发指南

## 一、简介

aardio 用户接触 Web 开发的相对比较多，在 aardio 中开发桌面软件，应用 Web 技术,HTML 等等非常普遍，
所以大家切换到网站开发应当是轻车熟路，不会有太大的难度，现在很多软件应用都是基于服务端接口，几乎每一个软件都要与服务端接口互动，不仅仅是桌面软件，例如一些手机应用，客户端是HTML5,服务端是REST接口，这种模式是未来的方向，所以应用领域还是比较广的。

实际上在 aardio 中开发网站应用非常简单，大家可以把网站理解为控制台程序，
只不过取代 console.log 的是 `response.write` 函数。一句 aardio 代码

`response.write("hello")`

就输出一个最简单的网页了。

aardio 直接支持与 PHP 类似的语言级模板语法，可以 html,aardio 代码混合生成页面，非常方便。


## 二、网站开发

### 1. 创建网站工程

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

### 2. aardio 模板语法

在 aardio 代码中可直接支持 HTML 模板语法。

ardio 代码如果以 HTML 代码开始，或以 `<?` 标记开始则自动启用模板语法。启用模板语法以后，aardio 代码必须置于 `<? ..... ?>` 内部。aardio 代码可以是纯 aardio 代码，也可以是纯 HTML，或者是 HTML、aardio 相互混合的模板代码。 

请参考： [aardio 模板语法](../../language-reference/templating/syntax.md)

### 3. request,response,session 对象 

使用 aardio 编写的网站应用中最重要的几个对象：

- request: HTTP 请求对象
- response:  HTTP 响应对象
- session:  HTTP 会话对象

在 aardio 中所有 HTTP 服务端实现都支持兼容的 request,response,session 对象，这些对象的接口与用法是一样的。

关于这几个对象的详细说明请参考 [fastcgi.client 库](../../library-reference/fastcgi/client/_.md) 文档。

## 三、创建 HTTP 服务端

可以使用 aardio 标准库中的 wsock.tcp.simpleHttpServer 或 wsock.tcp.asynHttpServer 启动微型 HTTP 服务端。这几个服务端非常小并且不依赖外部文件，可以方便地嵌入到程序中，可以作为网页界面的嵌入后端使用。

wsock.tcp.simpleHttpServer 是多线程 HTTP 服务端，不依赖消息循环。在界面线程中可以调用 `wsock.tcp.simpleHttpServer.startUrl("/")` 创建一个单实例（多次调用不会重复创建线程）的 HTTP 服务器线程（自动分配空闲端口，在界面线程退出时自动退出），并且返回参数指定路径的 HTTP 访问地址。 

而 wsock.tcp.asynHttpServer 则是单线程异步的 HTTP 服务端，只能用于界面线程。

在使用 [web.view 创建的网页程序](../../library-guide/std/web/view/_.md) 中，只要简单地调用 `import wsock.tcp.simpleHttpServer` 或者 `import wsock.tcp.asynHttpServer` 就可以自动创建 HTTP 服务端并且 wb.go 函数可自动参数中基于应用程序根目录访问的路径转换为 HTTP 地址，例如：

```aardio
import web.view;
var theView  = web.view(mainForm);  

import wsock.tcp.simpleHttpServer; 
theView.go("\web\index.html");
```

在 aardio 工程向导中选择 『 网页界面 / web.view 』 中的任何工程模板都可以创建包含以上代码的完整示例工程。

## 四、创建 FastCGI 服务端

在 IIS 这样的服务端中可通过 FastCGI 加载 aardio 编写的 FastCGI 服务端，就可以支持 aardio 编写的网站程序，下面我们介绍具体步骤。 

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
 



