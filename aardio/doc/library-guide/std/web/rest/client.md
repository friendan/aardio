# 用 web.rest 快速开发 HTTP 客户端

aardio 里的 web.rest 设计了一种简单的 HTTP 接口描述规则 —— 可将指定的网址（可选指定模板参数）自动转换为本地函数对象。用法极其简单（ web.rest 本身的实现也非常简单 ）。

web.rest 是一种调用规则，也是 aardio 里的一个名字空间，web.rest 名字空间中的所有类都是 web.rest 的具体实现，所有 web.rest 类都继承自 web.rest.client，用法基本相同。  

web.rest 名字空间的所有客户端默认都可选使用第一个构造参数指定 User Agent，可选用第二个构造参数指定代理服务器，请参考：[设置代理服务器](../../inet/proxy.md) 。

## 一、简单示例 <a id="quickstart" href="#quickstart">&#x23;</a>


```aardio

import console;
import web.rest.jsonLiteClient;

//创建 HTTP( REST ) 客户端。
var http = web.rest.jsonLiteClient();

//声明 HTTP 接口对象
var api = http.api("http://httpbin.org/anything/")

/*
调用 HTTP 接口函数（已经自动转换为了本地函数）。
返回 JSON 自动转换为了 aardio 对象。
*/ 
var result = api.object.method({
    name = "用户名";
    data = "其他数据";
});

//输出服务端返回对象 —— 这个接口返回的是 HTTP 请求信息 
console.dumpJson(result);
console.pause();
```

上面的代码可以直接复制粘贴到 aardio 中运行，该接口返回的是 HTTP 请求信息 —— 用于测试学习非常方便。  

我们主要看下面这句发送请求调用 HTTP 接口的代码：  

```aardio
var result = api.object.method({
    name = "用户名";
    data = "其他数据";
});
```

  
上面的函数调用做了几件事：  

1. 将 api.object.method 每一个下级成员名字追加到请求网址后面，多个名字自动用 "/" 分开。也就是自动生成下面这样的请求地址：  

    ```aardio
    "http://httpbin.org/anything" + "/object" + "/method",
    ```

2. 将函数参数按网页表单编码规则转换为字符串提交，也就是自动执行下面的转换：

    ```aardio
    inet.url.stringifyParameters({
        name = "用户名";
        data = "其他数据";
    })
    ```

3. 解析服务器返回的 JSON ，并作为函数返回值返回。

    实际上这句发送请求的代码会被转换为下面的代码执行：  

    ```aardio
    var result = http.post(
    "http://httpbin.org/anything" + "/object" + "/method",
    inet.url.stringifyParameters({
        name = "用户名";
        data = "其他数据";
    })
    );
    ```

    上面的 object , method 我们称为『网址模板参数』。  
  

##  二、网址模板参数 <a id="url-template-parameters" href="#url-parameters">&#x23;</a>


在声明 API 对象时， HTTP 接口网址中可选使用大括号 `{}` 包含模板参数名，示例：

```aardio
"http://httpbin.org/anything/{org}/{name}/repos"
```

上面的 `{org}` , `{name}` 都是"网址模板参数"。

在调用 HTTP 接口时，HTTP API 对象的所有下级成员名称（模板实参）会逐个替换『网址模板参数』。  

例如下面的代码：

```aardio
import console;
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient();

//声明 HTTP 接口对象
var api = http.api("http://httpbin.org/anything/{org}/{name}/repos")

//调用 HTTP 接口函数
var result = api.aardio.jacen({
    name = "ImTip";
    description = "通用输入法状态提示";
});

console.dumpJson(result);
console.pause();
```

> 如果我们事先在 http.defaultUrlTemplate 里指定了默认的 URL 模板，则谳用 http.api 时可省略参数，或者仅指定以 `/` 或 `.` 开始的 URL 路径部分。一些继承自 web.rest.client 的客户端可能会使用 defaultUrlTemplate 指定默认的 API 接口地址。

上面调用 api.aardio.jacen() 函数的实际请求地址为：

```aardio
"http://httpbin.org/anything/"
  + "aardio" + "/" + "jacen" + "/" + "/repos"
```

模板实参 "aardio" 会替换模板参数  `{org}` ，模板实参 "jacen" 会替换模板参数 `{name}` ，依次从前向后替换（忽略模板名 ）。  

也可以把斜杠写到模板变量里面，例如 `{/name}` ，这表示：如果调用时指定了模板实参则保留斜杠，否则去掉斜杠。

我们也可以在调用时明确指定模板实参的名字，代码如下：

```aardio
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient();

//声明 HTTP 接口对象
var api = http.api("http://httpbin.org/anything/{org}/{name}/repos")

//URL 模板实参，使用名值对指定了参数的名字
var urlParam = { org = "aardio", name = "jacen" } 

//调用 HTTP 接口函数
var result = api[urlParam]({
    name = "ImTip";
    description = "通用输入法状态提示";
});
```

在网址尾部可以用 `{...}` 指定不定个数的模板参数，例如：

```aardio
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient();

//声明 HTTP 接口对象
var api = http.api("http://httpbin.org/anything/{...}")
```

这个  `{...}` 可以省略不写，省略仍然支持不定个数模板参数，多个模板实参会自动用 "/" 分隔。

## 三、HTTP 请求方法 <a id="method" href="#method">&#x23;</a>


HTTP 协议常用的请求方法有：GET，POST，PUT，DELETE，PATCH，HEAD。

我们可以在调用 HTTP 接口函数时，可以将小写的 HTTP 方法名作为函数名调用 —— 就是以该 HTTP 方法发送请求。

例如：

```aardio

import console; 
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient(); 

//可在参数 @2 指定默认 HTTP 方法，不指定默认为 "POST"
var api = http.api("http://httpbin.org/anything/","POST") 

//发送 GET 请求
var ret = api.name.get( a = 1,b = 2);

//发送 POST 请求
var ret = api.name.post( a = 1,b = 2);

//发送 PATCH 请求
var ret = api.name.patch( a = 1,b = 2);

//发送 PUT 请求
var ret = api.name.put( a = 1,b = 2);

//发送 DELETE 请求
var ret = api.name.delete( a = 1,b = 2);

console.dumpJson(ret); 
console.pause(true);
```

这些 http 方法不仅仅可以作为函数使用，也可以作为转换对象 —— 用于转换后续的请求方法，例如：  

```aardio
var ret = api.get.method( a = 1,b = 2);
```

注意 head, get, post, put, patch, delete 等作为 HTTP 接口函数名时不会视为『网址模板实参』被添加到请求网址中。

如果将这些默认 HTTP  方法名前面添加一个斜杠，就可以视为『网址模板实参』而非 HTTP 方法。例如：  

```aardio
var result = api.get["/get"]()
```

上面的代码可以简写为：

```aardio
var result = api.getGet()
```

类似的还有 postPost(), putPut() …… 等函数。

##  四、web.rest 名字空间 <a id="namespace" href="#namespace">&#x23;</a>


web.rest 名字空间的类都继承自 web.rest.client，区别在于请求数据格式或服务器响应数据格式不同。  

最常用的 web.rest 类如下：  

1、web.rest.client

请求为网页表单编码，响应数据直接返回。

3、web.rest.jsonClient  

请求与响应数据都是 JSON 。

3、web.rest.jsonLiteClient

请求为网页表单编码，响应数据为 JSON 。

下面我们看一下 web.rest.jsonLiteClient 的主要源码：

```aardio

import web.json;
import web.rest.client;

namespace web.rest; 

class jsonLiteClient{
  ctor( ... ){
    this = ..web.rest.client( ... ); 
   
    //请求数据 MIME 类型
    this.contentType = "application/x-www-form-urlencoded"; 
    
    //自动转换请求参数
    this.stringifyRequestParameters  = function(param,codepage){
      //省略其他代码
      return ..inet.url.stringifyParameters(p,codepage);
    } 
    
    //期望服务端返回的数据 MIME 类型
    this.acceptType = "application/json,text/json,*/*";
     
    //自动转换服务器响应数据
    this.parseResponseResult = function(s){
      //省略其他代码
      return  ..web.json.parse(s,true);
    }
  }; 
}
```

每个不同的 web.rest 类 —— 主要是修改了转换请求参数格式的 this. stringifyRequestParameters 函数，以及修改服务器响应数据格式的 this. parseResponseResult 。

##  五、获取错误信息 <a id="error" href="#error">&#x23;</a>

在调用 HTTP 接口时，成功返回解析后的响应数据，失败则返回 3 个值：null, 错误信息, 错误代码（可选） 。

这里要特别注意一下：aardio 中的很多函数都是成功返回非 null 值，失败返回 null 与 错误信息 等多个值，一般不会抛出异常。

例如：  

```aardio

import console; 
import web.rest.client;
var http = web.rest.client(); 

var api = http.api("http://httpbin.org/status/500"); 

//发送 GET 请求
var ret,err = api.get( a = 1,b = 2);

if(!ret){

  //出错了输出错误信息
  console.log("出错了",err)

  //获取原始服务器响应数据
  http.lastResponse()
}
else {
  console.dumpJson(ret); 
}

console.pause(true);
```

可以运行 aardio **「 工具 > 网络 > HTTP 状态码检测」**查看返回状态码的相关信息。

http.lastResponse() 可以获取服务器原始响应数据 —— 如果事先导入了 console 库，则在控制台直接显示。

当然上面的代码一般在调试故障时才需要，一般没必要把错误处理写得这么细，上面的代码可以简化如下：

```aardio

import console;
import web.rest.jsonLiteClient;
var restClient = web.rest.jsonLiteClient();   

var duck = restClient.post("http://httpbin.org/post",{
    用户名 = "用户名";
    密码 = "密码";
} )

//这句相当于 if( duck and duck["翅膀"] ) 
if( duck[["翅膀"]] ){ 
    console.log("不管服务器给我的是什么鸭子，总之有翅膀的都是好鸭子")
}
else {
    //出错了
    console.log("怎么回事没翅膀还能叫鸭子吗？");
}

console.pause();
```

`duck[["翅膀"]]` 使用了直接下标 —— duck 为 null 时 `duck[["翅膀"]]` 不会报错，而是返回 null 。

参考：[操作符 - 直接下标](../../../../language-reference/operator/member-access.md)

## 六、自定义 HTTP 请求头 <a id="header" href="#header">&#x23;</a>


可使用 http.addHeaders 自定义 HTTP 请求头，示例：

```aardio

import console; 
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient(); 

//如果所有请求都要添加的相同HTTP头，在这里指定
http.addHeaders = {
    ["Test"] = "test"
}

var api = http.api("http://httpbin.org/anything/") 

//发送 GET 请求
var ret = api.name.get( a = 1,b = 2); 

console.dumpJson(ret); 
console.pause(true);
```

如果每次请求都要动态修改 HTTP 请求头，可以在 http.beforeRequestHeaders 事件函数内返回需要添加的请求头。

基于 web.rest.client 的所有 HTTP 客户端在准备好其他请求参数以后，发送 HTTP 请求以前的最后一步操作就是准备 HTTP 头，在这个构建 HTTP 头的阶段会自动回调 beforeRequestHeaders 函数，beforeRequestHeaders 的回调参数中可以拿到较多的关于本次 HTTP 请求的各种参数与信息，很适合在 函数，beforeRequestHeaders 构造需要动态修改 HTTP 请求头的需求（ 例如实现签名算法并修改 HTTP 头 ）。

下面是自定义 beforeRequestHeaders 的示例：

```aardio
import crypt; 
import web.rest.jsonLiteClient;
import console; 

var http = web.rest.jsonLiteClient(); 

/*
beforeRequestHeaders 在发送请求前触发，返回自定义 HTTP 头。

回调参数说明：
@params 调用接口的表参数（ table 对象）。
@payload 待发送的 HTTP 请求数据（字符串），根据前面的表参数 @params 生成。
@url 请求网址（字符串）。
@httpMethod 请求方法（大写字符串，不需要再转大写）。
@contentType 请求 MIME 类型（字符串）。
*/
http.beforeRequestHeaders = function(params, payload, url, httpMethod, contentType){

    var apiKey = "";
    var secretKey = "";
    var authorization = {
        ["apiKey"] = apiKey;
        ["time"] = tonumber(time());
    }

    authorization["sign"] = crypt.md5(apiKey ++ secretKey ++ authorization.time)

    //通过返回值设置本次请求的 HTTP 头, Content-Type 不需要指定（会自动指定）
    return {
        ["Authorization"] = crypt.encodeBin(web.json.stringify(authorization))
    };
}

//声明 API 对象
var api = http.api("http://httpbin.org/anything/") 

//发送 GET 请求
var ret = api.name.get( a = 1,b = 2); 

console.dumpJson(ret); 
console.pause(true);
```

通常我们应当与一个新的类库以预定义 beforeRequestHeaders 函数，典型的例如 web.rest.tencentCloud 客户端的源码结构如下：

```aardio
import web.rest.jsonClient;
import crypt.hmac;

class web.rest.tencentCloud{
	ctor(...){
		this = ..web.rest.jsonClient(...);
	
		this.beforeRequestHeaders = function(params,payload,url,httpMethod,contentType){
			
			//省略实现签名算法的代码

			//HMAC-SHA256 , 注意 this.config 是类构造传过来的表对象（也可以在创建对象后指定）
			var secretDate = ..crypt.hmac.sha256("TC3" 
				++ this.config.secretKey,strDate).getValue();
				
			//省略实现签名算法的代码
			
			return {
				["Authorization"] = authorization;   
				["X-TC-Timestamp"] = timestamp; 
				["X-TC-Action"] = this.config.action; 
				["X-TC-Version"] = this.config.version; 
				["X-TC-Region"] = this.config.region; 
			} 
		}
	}; 
}
```

完整源码请到标准库中查看。

附：签名经常用到的 HMAC-SHA256 算法：

```aardio
import crypt.hmac;

var key = 'key';
var data =  "Hi There"; 

//HMAC-SHA256
var hmacData = crypt.hmac.sha256(key,data).getValue()
var base64 = crypt.encodeBin( hmacData );
```


##  七、multipart/form-data 编码上传文件 <a id="upload-file" href="#upload-file">&#x23;</a>


示例：

```aardio
import web.rest.client;
var http = web.rest.client();
var api = http.api("https://fontello.com");

//使用文件表单上传文件，可以指定多个字段
var result = api.sendMultipartForm(
    file = "@/test.json"; //上传文件路径前面必须加一个字符 @ ，其他字段不用加
});
```

上面代码也可以写为 api.post.sendMultipartForm() ;

如果需要处理上传进度，可以这样写：  

```aardio
var result = api.sendMultipartForm( {
        file = "@/test.json";
    },function(sendData,sendSize,contentLength,remainSize){
        /*
        sendData 为本次上传数据；
        sendSize 为本次上传字节数；
        contentLength 为要上传的总字节数；
        remainSize 为剩余字节数；
        */
    }
);
```
  
##  八、上传文件 <a id="upload" href="#upload">&#x23;</a>


直接上传文件示例：

```aardio
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient();
var api = http.api("http://httpbin.org/anything");

//上传文件
var result = api.sendFile("/上传文件路径.txt");
```

  
也可以如下指定上传进度回调函数。

```aardio
var result = api.sendFile( "/上传文件路径.txt"
    ,function(sendData,sendSize,contentLength,remainSize){
        /*
        sendData 为本次上传数据；
        sendSize 为本次上传字节数；
        contentLength 为要上传的总字节数；
        remainSize 为剩余字节数；
        */
    }
);
```

  
##  九、下载文件 <a id="download" href="#download">&#x23;</a>


下载文件示例：

```aardio
import console;
import web.rest.jsonLiteClient;
var http = web.rest.client();

var aardio = http.api("https://www.aardio.com");

/*
下载文件:
如果创建文件失败 receiveFile 函数会返回 null 及错误信息，否则返回对象自身。
*/
var ok = aardio.receiveFile("/.test.html").get();
```

  
可选如下指定下载进度回调函数：  

```aardio
aardio.receiveFile("/.test.html",function(recvData,recvSize,contentLength){
    /*
    recvData 为当前下载数据。
    recvSize 为当前下载数据字节数。
    contentLength 为需要下载的总字节数。
    */
    console.log(,recvSize,contentLength)
}).get();
```

  
##  十、自动模式匹配 <a id="pattern-" href="#pattern-">&#x23;</a>


在声明 HTTP 接口对象时，还可以指定模式串 —— 用于自动匹配服务器响应数据，并返回匹配结果。

示例：

```aardio

import console; 
console.showLoading("获取外网IP");

import web.rest.client;
var http = web.rest.client();

//声明 API，参数 @3 指定的模式串用于匹配返回数据
var api = http.api("http://myip.ipip.net",,"(\d+\.\d+\.\d+\.\d+)");

//调用 HTTP 接口 
var ip = api.get();

//显示查询结果
console.log( ip  );

console.pause(true);
```

  
##  十一、普通 HTTP 客户端 <a id="http-client" href="#http-client">&#x23;</a>


web.rest 基于 inet.http （ [请参考：玩转 inet.http](../../inet/http.md)，也可以作为增强版的 HTTP 客户端功能，示例：

```aardio
import console;
import web.rest.jsonClient;

//创建 HTTP 客户端
var http = web.rest.jsonClient();

//发送 GET 请求
var ret = http.get("http://httpbin.org/anything",{
    name = "用户名";
    data = "其他数据";
})

//发送 POST 请求
var ret = http.post("http://httpbin.org/anything",{
    name = "用户名";
    data = "其他数据";
})

console.dumpJson(ret);
console.pause();
```

与 inet.http 不同的是，如果服务端返回数据的编码声明不是 UTF-8，web.rest 会自动转换为 UTF-8 。

##  十二、直接提交原始数据 <a id="raw-string-param" href="#raw-string-param">&#x23;</a>


使用 web.rest 调用 HTTP 接口时，如果提交数据是一个字符串，则不作任何处理 —— 直接提交。

示例：

```aardio

import console;
import web.rest.jsonClient;
var http = web.rest.jsonClient(); 

//示例 JSON
var json = /*
{
    "data":"其他数据",
    "name":"用户名"
}
*/

//如果提交数据是字符串，则不作任何转换直接发送
var ret = http.post("http://httpbin.org/anything",json)

console.dumpJson(ret);
console.pause();
```

## 十三、SSE( Server-Sent Events) 事件流 <a id="sse" href="#sse">&#x23;</a>


所有基于 web.rest.client 的客户端自动支持 SSE 事件流（ MIME 为 "text/event-stream" ），
同时自动兼容 ndjson 流（ MIME 为 "application/x-ndjson" ）。

示例：

```aardio
import web.rest.jsonLiteClient;
var http = web.rest.jsonLiteClient();

var eventSource = http.api(url) 

//参数 @2 或 参数@3 指定接收数据回调函数则自动支持 SSE，兼容 ndjson 流。
eventSource.get( , function(message){   
	//注意这里的 message 已经由 JSON 解析为单个对象
	print("HTTP 服务端推送了事件",type(message))
	print(message);
	
	//返回 false 则停止接收事件
	// return false;
} ) 
```

[SSE 完整范例](../../../../example/Web/REST/sse.html)

## 十三、调用 AI 大模型接口 <a id="aiChat" href="#aiChat">&#x23;</a>

- [web.rest.aiChat 使用指南](aiChat.md)
- [更多 AI 调用范例](../../../../example/AI/aiChat.html)

web.rest.aiChat 是基于 web.rest.jsonClient 实现的 AI 聊天客户端。

web.rest.aiChat 默认使用 OpenAI 兼容接口协议，在模型名称参数前添加 `@` 字符则使用 Anthropic  聊天接口（例如 `@claude-3-5-sonnet-latest"`）。

示例：

```aardio
//创建 AI 客户端
import web.rest.aiChat;
var ai = web.rest.aiChat(    
	key = '密钥';
	url = "https://api.deepseek.com/v1";
	model = "deepseek-chat";//模型名称 
	temperature = 0.1;//温度
	maxTokens = 1024,//最大回复长度
)

//创建消息队列
var msg = web.rest.aiChat.message();

//添加系统提示词。
msg.system("你是桌面智能助手。");

//添加用户提示词
msg.prompt( "请输入问题:" );

import console; 
console.showLoading(" Thinking "); 

//发送请求，参数 @2 如果指定 SSE 回调函数则启用流式推送
ai.messages(msg,console.writeText);//可选用参数 @3 指定一个表包含其他请求参数。
```

SSE 回调函数如果返回 false 则停止接收数据。


  
##  更多范例

aardio 自带 web.rest 范例，范例位置：`~/example/Web/REST`
