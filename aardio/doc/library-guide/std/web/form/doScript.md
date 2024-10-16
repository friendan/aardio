# 执行网页脚本

参考: [创建 Web 窗体](webform.md) [在网页脚本中调用 aardio 函数](external.md)

## wb.doScript

1. 函数原型：   

   `wb.doScript( 要执行的脚本代码,框架名字="",脚本语言名称="javascript" )`

2. 函数说明：   
  
   执行网页脚本,第二个参数、第三个参数都是可选参数。

3. 调用示例：   

  
   ```aardio
   //....省略创建 Web 窗体的代码 

   wb.write("<a href='#' onclick='func()'>执行wb.doScript创建的函数</a>")

   js = /*

   function func(){
   alert('我是js,我的语法与aardio很相似,都是C系语法哦')
   }
   func();
   */

   wb.doScript( js )
   ```