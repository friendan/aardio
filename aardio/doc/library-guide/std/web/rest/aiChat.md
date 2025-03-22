# aardio 调用 AI 大模型

## 一、基本用法

[本节的完整范例源代码](../../../../example/AI/aiChat.html)

1. 创建 AI 客户端

    ```aardio
    import web.rest.aiChat;
    var aiClient = web.rest.aiChat({
        key = '这里指定 API 密钥';
        url = "这指指定大模型接口地址";
        model = "这里指定模型名称";
        temperature = 0.1;//可选指定温度
        topP = 0.8;//可选指定 top-p 参数
        maxTokens = 1024,//可选指定最大回复长度
   } )
   ```

    一般指定了 temperature 就不要指定 topP，与编程有关的 temperature 参数应当偏低以增强准确性与严谨性。

    对于推理模型可选在参数表中添加 reasoning 字段自定义推理强度，
    以 Claude 3.7 为例：

    ```aardio
    import web.rest.aiChat;
    var aiClient = web.rest.aiChat({
        key = '这里指定 API 密钥';
        url = "这指指定大模型接口地址";
        model = "claude-3.7-sonnet"; 
        maxTokens = 2048,//可选指定最大回复长度
        reasoning = {
            maxTokens = 2048；
        }
   } )
   ```    

   如果是 OpenAI 的模型，则配置字段 reasoning 内可使用 effort 字段 指定推理强度，可选值为  "high", "medium", 或 "low" 。

   可选使用 aiClient.extraParameters 指定一个表，表中的键值对将作为参数添加到所有请求数据中。

   可选使用 aiClient.extraUrlParameters 指定一个表，表中的键值对将作为 URL 参数添加到所有请求网址。

2. 创建聊天消息对列，保存对话上下文。

    ```aardio
    var msg = web.rest.aiChat.message();

    //可调用 msg.system() 函数添加系统提示词。
    msg.system("你是桌面智能助手。");

    //添加用户提示词
    msg.prompt( "请输入问题:" );
    ```

    也可以用模拟 AI 的角色添加回复到消息对列

    ```aardio
    //模拟 AI 角色
    msg.assistant("请输入问题:" );
    ```

    这样自问自答的历史消息可以起到小样本学习的作用，让 AI 后面的回复更符合要求，小样本学习的效果有时候会非常好。


3. 发头请求，接收 AI 回复

    ```aardio
    var resp,err = aiClient.messages(msg,
        function(deltaText,reasoning){

            //推理模型会首先通过 reasoning 参数输出推理过程（同样是增量字符串），同时 deltaText 为空字符串 "" 。
		    if(reasoning) return;
            
            //回复完成则 为 null 。
            console.writeText(deltaText)
            
            //如果需要输入增量输入到目标窗口
            //key.sendString(deltaText)
            
            //显示为屏幕汽泡提示，支持增量文本。
            //winex.tooltip.popupDelta(deltaText) 
        }
    );
    ```

   调用 ai.messages 就开始对话，如果参数 @2 指定了回调函数，就自动切换到 SSE 流式调用，也就是打字效果逐步回复，并且重复回调你传入的 SSE 回调函数。每次回调都会传入当前回复的文本作为 deltaText 参数，当 AI 回复结束时 deltaText 为 null 。

   如果指定了 SSE 回调函数，resp 成功返回 true （失败 非 true ）。如果未指定 SSE 回调函数，则 resp 为 AI 生成的回复对象（表对象）。

   如果失败 resp 为 null 或 false 等非真值，而 err 包含可能的错误字符串。

   web.rest.aiChat 继承自 web.rest.client，所以也可以用 aiClient.lastResponseError() 获取错误对象，用 aiClient.lastResponseString() 获取服务器的错误应答，或者用 aiClient.lastStatusCode 得到 HTTP 响应状态码。更多用法请参考 [使用 web.rest 客户端](client.md)

[本节的完整范例源代码](../../../../example/AI/aiChat.html)

## 二、兼容接口

1. OpenAI 兼容接口。

    web.rest.aiChat 默认使用  OpenAI 兼容接口。

    基本上大部分大模型接口都是 OpenAI 兼容接口，或者提供  OpenAI 兼容接口。例如 DeepSeek 接口就是  OpenAI 兼容接口。。

    这类接口地址基本都以 `/v1` 结尾，例如 `https://api.deepseek.com/v1` 。
    因此很多应用不用写 `/v1`，但这样实际带来一些麻烦，例如 `https://generativelanguage.googleapis.com/v1beta` 就不一样。

    在 aardio 里，如果接口地址只写到域名部分后面没有路径，aardio 会自动加  `/v1`，否则就不加。
    因此在 aardio 中填写以下格式的接口地址都是允许的：

    ```
    https://api.deepseek.com
    https://api.deepseek.com/v1
    https://generativelanguage.googleapis.com/v1beta

    ```

    以上几种写法都是允许的，尾部有没有斜杠都是允许的。

2. Anthropic 接口

    如果在模型名前面加一个 `@` 则会走  Anthropic 家的接口，也就是 Claude 大模型官网接口。示例：

    ```aardio
    import web.rest.aiChat;
    var aiClient = web.rest.aiChat(    
        key = '密钥';
        url = "https://api.anthropic.com/v1";
        model = "@claude-3-5-sonnet-latest";
        temperature = 0.1;
    )
    ```

3. Ollama 接口

    Ollama 本地模型在 aardio 或  ImTip 中的接口地址写以下任何一个都可以：

    ```
    http://localhost:11434
    http://localhost:11434/v1/
    http://localhost:11434/api/
    ```

    Ollama 只要填网址和模型名称，key不需要指定。

    请参考： [自动部署本地 Ollama 模型](../../../../example/AI/ollama.html)

4. 豆包模型与智能体接口

    豆包大模型的接口以及智能体接口都兼容 OpenAI 接口。豆包智能体的的接口地址为 `https://ark.cn-beijing.volces.com/api/v3/bots`，大模型接口地址为 `https://ark.cn-beijing.volces.com/api/v3`， 模型 ID 参数可以填模型 ID 也可以填智能体应用的 ID。
    示例：

    ```aardio
    import web.rest.aiChat;
    var aiClient = web.rest.aiChat(    
        key = '密钥';
        url = "https://ark.cn-beijing.volces.com/api/v3/bots"; //不是智能体去掉 "bots"
        model = "bot-20250115093718-r9gcj";//模型或智能体 ID
        temperature = 0.1;//温度 
    )
    ```

5. 通义模型与智能体接口

    使用 web.rest.aiChat 可以兼容阿里通义千问的大模型接口以及智能体接口，他们原来是不兼容的，不过 aardio 已经自动做了兼容。

    调用阿里大模型与智能体，API 接口网址只要写 `https://dashscope.aliyuncs.com` 就可以，然后 model 参数写模型 ID 或者智能体应用 ID。当然你也可以直接写阿里提供的接口网址。

    ```aardio
    import web.rest.aiChat;
    var aiClient = web.rest.aiChat(   
        key = '密钥';
        url = "https://dashscope.aliyuncs.com";
        model = "qwen-coder-plus"; //这里写模型 ID 或者智能体应用 ID，aardio 会自动兼容
        temperature = 0.1;
        maxTokens = 1024,
    )
    ```

## 三、AI 续写与补全应用

如果需要更好的效果，则建议在 AI 提示词中添加更多的信息，例如让 AI 知道目标进程的文件名，并要求 AI 根据不同的程序给出更合适的解答，完整示例请参考： [范例 - 超级热键调用 AI 大模型自动续写补全](../../../example/AI/aiHotkey.html) 

aardio 基于上面的范例已经内置了 F1 键 AI 助手，运行效果：

![F1 键助手](https://imtip.aardio.com/screenshots/fim.gif)

利用 F1 键还可以在 aardio 中调用 AI 写其他编程语言的代码，例如写 Python 代码：

![F1 键助手写 Python 代码](https://www.aardio.com/zh-cn/doc/images/fim-py.gif)

在调用 AI 续写补全时，清晰的提示很重要。例如上面我们简明扼要地通过变量命名与注释让 AI 明确  pyCode 里放的是 Python 代码。在编码补全时，在清晰的注释提示后面补全有更好的效果。 注意用法，那么在 aardio 环境中调用 AI 写前端代码、Python 代码、 Go 语言的代码的效果会很好，利用 AI 可以更好地利用 aardio 在混合语言编程上的优势。

## 四、AI 调用本地函数（ Function calling ） <a id="function-calling" href="#function-calling">&#x23;</a>

注意不是所有大模型接口都支持 function calling 。    
如果服务端报错缺少 content 字段，这是因为接口不支持 function calling，只能处理包含 content 的普通消息。  
不支持 function calling 有可能不会直接报错，而是反复地调用本地函数，要注意这个问题。

DeepSeek 已经支持 function calling，DeepSeek R1 暂不支持 。  
豆包专业版大模型支持 function calling ，并有针对 function calling 优化的模型。
但豆包智能体据我测试 function calling 用不了。

使用 function calling 的具体步骤如下：

首先在创建 AI 客户端时，使用 tools 字段指定支持 function calling 的本地函数。  
tools 应当指定一个数组，数组的每个成员指定一个函数定义，细节可参考调用的大模型相关文档。

示例：

```aardio
var aiClient = web.rest.aiChat(
	key = "密钥";
	url = "https://api.*****.net/v1";//接口地址
	model = "模型名称"; 
    temperature = 0.5; 
	tools = { //关键在于增加 tools 字段声明可以调用的本地函数，细节请参考 API 文档。
        {
            "type": "function",
            "function": {
                "name": "getWeather",
                "description": "获取给定地点的天气",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "地点的位置信息，比如北京"
                        },
                        "unit": {
                            "type": "string",
                            "enum": {
                                "摄氏度",
                                "华氏度"
                            }
                        }
                    },
                    "required": {
                        "location"
                    }
                }
            }
        }
    }
)

```
 
然后我们需要在 aiClient.external 表里定义允许 AI 调用的同名函数，与前面的 tools 里声明的函数名称与原型说明要匹配。

示例：

```aardio
//导出允许 AI 调用的函数
aiClient.external = {
	getWeather = function(args){ 
		
		//如果重复调用相同的函数，是因为模型实际并不支持 function calling
		console.log("正在调用函数，参数：",args.location,args.unit)
		
		//尽量用自然语言描述清楚
		return  args.location + "天气晴，24~30 度，以自然语言回复不要输出 JSON"
	} 
}
```

然后创建对话消息队列，示例如下：

```aardio
//单独 创建 AI 会话消息队列以保存聊天上下文。
var chatMsg = web.rest.aiChat.message();

//添加用户提示词
chatMsg.prompt("杭州天气如何？" );
```

最后发送请求启动对话：

```aardio
console.showLoading(" Thinking "); 

//调用聊天接口。
var ok,err = ai.messages(chatMsg,console.writeText);
```

[完整版范例源码](../../../../example/AI/function-calling.html)

## 五、AI 搜索 <a id="search" href="#search">&#x23;</a>

如果是用于 aardio 编程的 AI 助手推荐使用 aardio 提供的 <a href="http://aardio.com/vip" >VIP 专属接口</a>，
aardio 提供了专业版知识库，匹配速度更快，也更加智能与准确。

### 调用 Tavily 搜索接口 <a id="exa" href="#exa">&#x23;</a>

Tavily 搜索质量不错，而且只要注册账号就可以每月可以免费搜索 1000 次。

示例：

```aardio

//导入 Tavily 搜索接口
import web.rest.jsonClient;
var http = web.rest.jsonClient();
http.setAuthToken("接口密钥");
var tavily = http.api("https://api.tavily.com");

//搜索，不建议指定 include_raw_content 参数（ 返回的 raw_content 可能有乱码 ）.
var resp = tavily.search(
	query = "aardio 如何读写 JSON",
	max_results = 3, //限制返回结果数，默认值为 5。
	//topic = "news", //限定返回最新数据，可用 days 字段限制天数（默认为 3 天内）。 
	include_domains = {"www.aardio.com"}, //可选用这个字段限定搜索的域名
)

//创建对话消息队列
import web.rest.aiChat; 
var msg = web.rest.aiChat.message();
 
//将搜索结果添加到系统提示词
msg.url(resp[["results"]])

//添加用户提示词
msg.prompt( "DeepSeek 有哪些成就" );
```

### 调用 Exa 搜索接口 <a id="exa" href="#exa">&#x23;</a>

一般需要根据用户的最后一个提示词进行搜索，并将搜索结果添加到最后一个用户提示词之前。

```aardio
//导入 Exa 搜索接口
import web.rest.jsonClient; 
var exaClient = web.rest.jsonClient(); 
exaClient.setHeaders({ "x-api-key":"接口密钥"} )
var exa = exaClient.api("https://api.exa.ai/");

//搜索
var searchData,err = exa.search({
    query:"DeepSeek 有哪些成就", 
    contents={text= true}
    numResults:2,
    includeDomains:{"www.aardio.com"},//可以在指定网站内搜索
    type:"keyword" //一般 keyword 搜索就够了（价格低一些）
})

//创建对话消息队列
import web.rest.aiChat; 
var msg = web.rest.aiChat.message();
 
//将搜索结果添加到系统提示词
msg.url(searchData[["data"]][["webPages"]][["value"]])

//添加用户提示词
msg.prompt( "DeepSeek 有哪些成就" );
```

exa.ai 的搜索质量不错。

### 调用博查搜索接口 <a id="bocha" href="#bocha">&#x23;</a>


```aardio
import web.rest.aiChat;

//创建对话消息队列
var msg = web.rest.aiChat.message();

//导入博查搜索接口
var bochaClient = web.rest.jsonClient(); 
bochaClient.setAuthToken("接口密钥");
var bocha = bochaClient.api("https://api.bochaai.com/v1/{method}-search");

//搜索
var searchData,err = bocha.web({ 
    "query": "DeepSeek 最近有哪些新闻事件",
    "freshness": "noLimit",
    "answer": false,
    "stream": false,
    "count": 2; //返回的搜索结果数量，不必要太多，前两三条就可以了
})

//将搜索结果添加到系统提示词
msg.url(searchData[["data"]][["webPages"]][["value"]])

//添加用户提示词
msg.prompt( "DeepSeek 最近有哪些新闻事件" );
```

## 六、调用 RAG 知识库接口

请参考：[调用火山方舟知识库接口](volcengine.md#knowledge)