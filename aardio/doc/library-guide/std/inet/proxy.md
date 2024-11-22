
# aardio 代理服务器设置指南

## 一、常用格式

例如有以下代理服务器:

- SOCKS 代理服务器 127.0.0.1:1081
- HTTP 代理服务器 127.0.0.1:1082

那么 aardio 中所有 inet,web.rest 名字空间的库与函数的代理参数都可以如下设置。

- "127.0.0.1:1082" 设置为 HTTP 代理服务器
- "socks=127.0.0.1:1081" 设置为 SOCKS4 代理服务器

代理设置忽略大小写，先记住几个简单的规则就足够用了，后面再细说原理。

## 二、设置代理

设置代理的方法分为以下四类

### 1. 设置系统全局代理服务器  
	
例如 

```aardio
import inet.conn;
inet.conn.setProxy( ,"socks=127.0.0.1:1081")
```

一般只要指定代理服务器参数就可以，其他参数自动指定。
第一个参数是网络连接名，省略即可。
第二个参数指定代理服务器。
第三个参数是指定不走代理的 proxyBypass 参数，aardio 会自动设定，一般不需要去指定。
	
### 2. 设置当前进程内代理服务器，不影响其他进程

 
例如 

```aardio
import inet;
inet.setProxy("socks=127.0.0.1:1081")
```

第一个参数指定代理服务器。
第二个参数是指定不走代理的 proxyBypass 参数，aardio 会自动设定，一般不需要去指定。

### 3. 设置 HTTP 客户端对象的代理


aardio 以下所有类的构造参数全部是一样的：

- inet.http(userAgent, proxy,proxyBypass,flags)
- web.rest.client(userAgent, proxy,proxyBypass,flags)
- web.rest.jsonClient(userAgent, proxy,proxyBypass,flags)
- web.rest.jsonLiteClient(userAgent, proxy,proxyBypass,flags)
- 以及 web.rest 名字空间的其他 Client 类。用法都一样。

所有这些类的构造函数用法都一样，这些参数都是可选参数，一般情况下不必指定任何参数。

参数用法：

- userAgent 指定 User Agent 一般没必要写，参数位置要留空占位。
- proxy 参数指定代理服务器，有三种用法：
	* 指定为 null,"" 或 "IE" 则使用系统代理服务器设置，这是默认值，一般不需要显式指定。
	* 指定为 false 表示禁用代理服务器。
	* 用一个字符串指定代理服务器地址，例如 "socks=127.0.0.1:1081"。
- proxyBypass 绕过代理的配置，不用指定，自己创建的客户端通常都是连接明确指定的地址，所以这个参数基本用不上。
- flags 参数，打开连接的选项，数值，不用指定。

web.rest 下面所有基于 web.rest.client 的类构造对象实例时都会调用基类 web.rest.client 的构造函数 `web.rest.client(userAgent, proxy,proxyBypass,flags)`，并将构造参数转发给基类。

而 web.rest.client 构造函数被调用时，又会自动调用 inet.http 的构造函数 `inet.http(userAgent, proxy,proxyBypass,flags)`，并将构造参数转发给 inet.http。


下面是一个例子：

```aardio
import web.rest.jsonClient;

//第二个构造参数指定代理服务器
var http = web.rest.jsonClient(,"socks=127.0.0.1:1081");

//声明 HTTP 接口对象
//声明 API，参数 @3 指定的模式串用于匹配返回数据
var api = http.api("http://myip.ipip.net",,"(\d+\.\d+\.\d+\.\d+)");

//发送 GET 请求
var ret = api.get();
```

### 4. 设置浏览器或浏览器控件的代理服务器

- web.form 与 inet.http 是一样的，支持 inet.setProxy 以及 inet.conn.setProxy 设置的代理。

	在 web.form 中可以如下设置代理服务器登录信息。

	```aardio
	import win.ui;
	var winform = win.form(text="aardio form")

	import web.form;
	var wb = web.form(winform);

	import crypt.bin;
	wb.addHeaders ={
		["Proxy-Authorization"] = "Basic " +crypt.bin.encodeBase64("代理服务器用户名"+":"+"代理服务器密码");
		["Authorization"] = "Basic " +crypt.bin.encodeBase64("用户名"+":"+"密码");
	} 
	wb.go("http://www.aardio.com");

	winform.show();  
	win.loopMessage(); 
	```
- web.view（ WebView2 ）以及 Edge,Chrome 等 Chromium 内核的浏览器应用设置代理的方法都差不多。
	你只要知道怎么指定浏览器启动参数就可以了。

	Chromium 的代理服务器使用了 WinInet 类似的格式，所以用法基本一样。
	[Proxy support in Chrome](https://chromium.googlesource.com/chromium/src/+/HEAD/net/docs/proxy.md)

	下面是 web.view 设置代理的示例：

	```aardio
	import web.view;
	import win.ui;

	// 创建窗体
	var winform = win.form(text="WebView2 - 设置启动参数")

	// 创建浏览器，三个字符串参数指定代理服务器
	var wb = web.view(winform,,"--proxy-server=SOCKS5://IP地址:端口,direct://");

	// 显示窗口
	winform.show();

	// 启动界面线程消息循环
	win.loopMessage();
	```

	注意，系统代理不支持 SOCKS5，但 Chromium 系列可以支持。
	
	上面的写法完全兼容 Chromium 的写法，你也可以用下面的写法，在 web.view 构造参数中传入表参数，用 startArguments 指定启动参数。

	示例：

	```aardio
	var wb = web.view(winform,{
		startArguments = {  
			proxyServer = "SOCKS5://IP地址:端口,direct://";
		}; 
	})
	```

	上面以驼峰风格写的参数名 proxyServer 会自动替换为连字符风格并在前面加上 "--" 自动转换为 "--proxy-server"，并由 aardio 自动转换为命令行参数，由 aardio 自动处理命令行转义规则。

## 二、代理服务器格式说明

代理服务器的写法格式一般是 WinINet 规定的格式。
Chromium 内核的浏览器做了一些小的改动，参考 [Proxy support in Chrome](https://chromium.googlesource.com/chromium/src/+/HEAD/net/docs/proxy.md)

设置单个完整的代理服务器格式是这样：
`"客户端被代理协议=代理服务器协议://主机地址:端口号"`

等号后面是指代理服务器用什么协议实现的代理。
等号前面指的是指被代理的客户端请求协议。

如果有多个服务器用分号隔开
`"http=http://127.0.0.1:1089;https=http://127.0.0.1:1082"`
上面分别为 http 协议，https 协议指定了不同的代理服务器。

其实现在 http,ftp 这些协议很少见了，而且就算用了也不必要分开设置。
所以等号前面可以省略，直接设置所有协议就可以了。

而你写在等号后面的 "http://" 也是多余的，因为这是默认值，写不写作用是一样。
所以其实就是本文最前面说的，用最简单的写法 "127.0.0.1:1082" 就可以了。
除非 SOCKS 服务器才需要写 "socks=127.0.0.1:1081" 指定一下被代理协议。

注意 aardio 的 web.rest 下面的所有 Client 类基于 web.rest.client。
而 web.rest.client 其实是调用 inet.http 创建 HTTP 客户端，而 inet.http,web.form 都是基本系统 WinINet 组件，
所以设置代理的语法与限制遵守 WinINet 规则。包括操作系统的代理设置也遵守这个规则。

## 三、绕过代理服务器参数格式说明

proxyBypass 指定不走代理的目标主机 IP 或域名，支持通配符，多个地址用分号隔开。

web.rest.client, inet.http 这些创建的客户端用于请求指定的地址，所以 proxyBypass 参数一般没有实际意义。

而 inet.setProxy 以及 inet.conn.setProxy 内部都自动设置了这个参数。

inet.setProxy 设置 proxyBypass 参数的源码如下：

```aardio

if(!proxyBypass){
    proxyBypass="<local>;<lan>;localhost;127.*;windows10.microdone.cn"
}

proxyBypass = ..string.replace(proxyBypass,"%\<\>",{
    ["<lan>"]  ="10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*"
})
```	

`<lan>` 由 aardio 替换为 局域名 IP 地址。


## 四、查看系统代理服务器设置

代码如下：

```aardio
//打开系统代理设置页
if(_WIN10_LATER) raw.execute("ms-settings:network-proxy"); 
else raw.execute("control.exe","inetcpl.cpl,,4"); 
```