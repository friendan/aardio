# aardio 模板语法

aardio 语言内置的模板语法规则如下：

- aardio 代码如果以 HTML 代码开始，或代码包含 `<?` 或 `?>` 标记则启用模板语法。部分库模块中支持 aardio 模板语法的函数可能要求字符串参数以`<?` 或 `?>` 标记开始才会启用 aardio 模板语法。

- aardio 代码可以是纯 aardio 代码，也可以是纯 HTML，或者是 HTML、aardio 相互混合的模板代码。
- 启用模板语法的 aardio 代码，纯 aardio 代码必须置于开始标记 `<?` 与 结束标记 `?>` 之间。 aardio 将不在 `<? ..... ?>` 之内的部分作为字符串参数并调用全局函数 print 函数输出。 

- aardio 总是忽略代码文件开始的空白字符（包含空格、制表符，换行），不会将文件开始的空白字符作为模板数据输出。

- aardio 文件只能以 UTF-8 编码保存，不建议添加 UTF8 BOM。如果文件添加了 BOM，aardio 仍然会自动移除 BOM 不会将 BOM 头作为模板数据输出。

- 模板开始标记 `<?` 必须独立，不能紧跟英文字母。例如 `<?xml...` 不被解析为 aardio 代码段开始标记。

- 可以使用 `<?=表达式?>` 输出文本 - 作用类似于 print( 表达式 )，可用逗号分隔多个表达式。 aardio 会忽略表达式前面等号首尾的空白字符 , 下面的写法也是允许的：  
  
   ```aardio
   <?
   = 表达式1,表达式2
   ?>
   ``` 

- 模板输出函数 print 使用规则。

   aardio 代码在解析模板语法时，将自动调用全局 print 函数（ `..print` ）输出数据。
   * aardio 中 print 函数只能用于捕获或修改模板输出，此函数不可随意改动指向，应交由负责模板输出的框架自动管理。
   * print 函数随时可能被动态指向不同的模板输出函数，非必要不建议在普通代码中直接使用 print 函数。也不应保存 print 函数到其他变量后再进行调用。例如在服务端网页开发时，建议直接调用 response.write 而不是调用 print 函数。
   * print 允许接收多个参数，并且必须对每个参数调用 `tostring()` 将参数转换为字符串。
   * 在一个独立 aardio 模板文件解析结束时，print 函数将收到一个 null 参数调用，print 函数应当在此时完成输出操作。

   print 函数可能被负责模板输出的库或框架重新定义并指向不同的实际函数，以实现不同的模板输出应用。例如在 HTTP 服务端中 print 将自动指向 response.write 函数。而在调用 string.loadcode 时 print 将临时指向拼接字符串的代码， 请在内置库 builtin.string 中查看 string.loadcode 函数的源代码，以了解如何通过自定义 print 函数捕获或修改模板输出。

   如果没有加载任何修改 print 函数的功能，print 函数默认指向 io.print 函数（如提前导入 console 则能自动打开控制台）。如在开发环境中运行代码且首次调用模板或 print 输出的是 HTML，则会创建一个网页控件以预览模板输出的内容。

   可以粘贴下面的示例代码到 aardio 编辑器中然后按 F5 直接运行以预览模板输出效果：

   ```aardio
   <!doctype html>
   <html><head><meta charset="utf-8"><title>帮助页面</title></head>
   <body>当前时间<? = time() ?>
   </body></html>
   ```  





