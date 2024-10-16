# 等待网页下载

参考: [创建 Web 窗体](webform.md)  [获取DOM节点对象](getele.md)

## 等待网页下载

我们需要控制网页上的DOM对象,就需要等待网页下载,DOM对象成功创建,否则获取节点将会失败,网页等待是web模拟控制技术的重要组成部分,下面我们介绍 Web 窗体提供的等待下载有关的函数.

本手册中约定使用 wb 变量名表示 web.form 类创建的 Web 窗体对象.使用ele表示 Web 窗体中的元素对象,这也是aardio中默认约定具有特殊意义的变量名,不应将这些默认变量名用于其他目的.

## wb.wait <a id="wait" href="#wait">&#x23;</a>


1. 函数原型：   

   `是否成功下载 = wb.wait( 等待的网址 )`

  
2. 函数说明：   
  
   这是很重要的一个函数,在调用wb.go或wb.post打开网页以后,使用此函数可以等待目标网页完全打开.在页面完全打开以后,我们才能获取并控制网页节点对象.

   等待的网址是一个可选参数,支持 [模式查找语法](../../../builtin/string/patterns.md)  
   如果不指定参数,则等待当前网页完全下载完毕.  
   
   如果打开网址时遇到错误,该函数返回 false  

## wb.waitDoc <a id="waitDoc" href="#waitDoc">&#x23;</a>


1. 函数原型：   

   `document = wb.waitDoc( 框架名 )`

  
2. 函数说明：   
  
   此函数内部循环调用 [wb.getDoc](getele.md#getDoc) ,如果发现文档对象已成功创建就立即返回,而不是等到整个网页下载完毕.  

   因为网络的原因,或者网站本身设计的问题,有一些网页可能很久都显示"正在下载中......",而实际上网页已经全部显示了,正在下载的可能是一些我们根本用不到的HTML节点.这时候这个函数就很有用.  
   
   如果关闭 Web 窗体, wb.waitDoc 则返回 null 。

3. 调用示例   

  
   ```aardio
   //....省略创建 Web 窗体的代码 

   //打开目标网站
   wb.go("http://www.aardio.com/")
   //显示窗体
   winform.show(true) 

   doc = wb.waitDoc();
   ```  


## wb.waitEle <a id="waitEle" href="#waitEle">&#x23;</a>


1. 函数原型：   

   `是否成功下载 = wb.waitEle( HTML节点的ID名name, 框架名 )`

2. 函数说明：   
  
   此函数内部循环调用 [wb.getEle](getele.md#getEle) ,如果发现该节点已成功创建就立即返回,而不是等到整个网页下载完毕.  
   因为网络的原因,或者网站本身设计的问题,有一些网页可能很久都显示"正在下载中......",而实际上网页已经全部显示了,正在下载的可能是一些我们根本用不到的HTML节点.这时候这个函数就很有用.  
   
   如果关闭 Web 窗体,wb.waitEle则返回null,否则该函数一直尝试获取指定的节点,一旦获取成功就返回该节点.

3. 调用示例   

  
   ```aardio
   //....省略创建 Web 窗体的代码 

   //打开目标网站
   wb.go("http://www.aardio.com/")
   //显示窗体
   winform.show(true) 
   ele = wb.waitEle( "__VIEWSTATE" );//等待指定网址,可以使用模式匹配语法

   import console;
   console.log( ele.outerHTML )
   ```  

## wb.waitClose <a id="waitClose" href="#waitClose">&#x23;</a>


1. 函数原型：   

   wb.waitClose()

  
2. 函数说明：   
  
   等待 Web 窗体关闭.