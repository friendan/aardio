# 调用火山引擎云服务平台 API

aardio 有一个比较有趣的地方是我们不需要专门的 SDK，
就可以自动支持各家的 HTTP API 接口。

类似调用火山引擎 API 的 web.rest.volcengine.client 类库，
其实就是继承自 web.rest.jsonClient 然后简单添加了一个自动签名算法的代码。
这个小小的客户端就可以方便地调用火山云平台的所有接口了。

别看它小，可是很好用，
使用 web.rest.volcengine.client 只要了解发送什么数据，接收什么数据就可以了。

##  获取火山方舟临时 API Key <a id="GetApiKey" href="#GetApiKey">&#x23;</a>


```aardio
import web.rest.volcengine.client
var http  = web.rest.volcengine.client(
	accessKeyId = "ak";
	secretAccessKey = "sk"; 
	region =  "cn-beijing"; 
	service = "ark";//火山方舟
);

//可选在参数中指定 API 接口网址。
var ark = http.api();

var resp,err = ark.GetApiKey({
	"DurationSeconds": 86400,
	"ResourceType": "endpoint",//endpoint,bot,action 分别为模型接入点,智能体,插件
	"ResourceIds": {"ep-*******"}
})

var meta = resp.ResponseMetadata;
var result = resp.Result;
var apiKey = result.ApiKey;
var expr = result.ExpiredTime;

print(apiKey)
```

## 调用火山方舟的豆包知识库接口 <a id="knowledge " href="#knowledge ">&#x23;</a>


```aardio 
import console.int;
import web.rest.volcengine.client;

//创建火山 API 客户端
var http  = web.rest.volcengine.client(
	accessKeyId = "ak";
	secretAccessKey = "sk"; 
	region =  "cn-north-1"; 
	service = "air";
	accountId = "2101785731"//鼠标放到火山头像上显示的账号ID
);

//声明 API 
var air = http.api("https://api-knowledgebase.ml_platform.cn-beijing.volces.com/api/knowledge/collection/");

//发送请求。参数训明: https://www.volcengine.com/docs/84313/1350012
var resp,err = air.search_knowledge({
	name="aardio";
	project="default";
	dense_weight=0.5;
	limit=3; 
	post_processing={
		get_attachment_link=false;
		rerank_only_chunk=false;
		rerank_switch=false		
	};
	query="aardio 如何解析 JSON"	
})

//获取数据
var data = resp.data;

//提取召回片段
var result = table.map(data.result_list
	,lambda(v,k) '# ' +v.chunk_title +'\r\n\r\n'+ v.content )

//显示结果
for(k,v in result){
	console.log(v)
	console.more();
}

//消耗 token 数，计费规则: https://www.volcengine.com/docs/82379/1099320
console.dumpJson(data.token_usage)


```

## 调用火山方舟的豆包大模型或智能体

这个只要使用通用的 AI 聊天对话客户端 web.rest.aiChat 就可以了。

豆包大模型的接口以及智能体接口都兼容 OpenAI 接口。  
- 豆包智能体的的接口地址为 `https://ark.cn-beijing.volces.com/api/v3/bots`
- 大模型接口地址为 `https://ark.cn-beijing.volces.com/api/v3`

模型 ID 参数可以填模型 ID 也可以填智能体应用的 ID。

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

请参考：[aardio 调用 AI 大模型](aiChat.md)