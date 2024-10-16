# 在网页中调用 aardio 代码

参考: [创建 Web 窗体](webform.md) [在aardio中执行网页脚本](doScript.md)

## wb.external

1. 接口语法：   

  
   ```aardio
   wb.external = { 
      成员名字 = 值
   }
   ```  

2. 函数说明：   
  
   定义 wb.external 为一个 table 对象,然后我们可以在网页脚本中直接访问 external 对象。

   aardio 要求你显示的指定 external 以及 external 的成员,是需要你基于本机安全去考虑哪些方法应当公开给网页访问。

3. 调用示例：   

  
   ```aardio
   //....省略创建 Web 窗体的代码 

   //创建 external 接口
   wb.external = {
      //可以通过javascript脚本访问external接口的所有成员
      aardio_func = function( arg ){
         win.msgbox("我被网页上的脚本调用了" + arg + "
         aardio的语法与Javascript很接近哦" )
      }
   }

   //在网页上执行 javascript 脚本
   wb.doScript("javascript:external.aardio_func(123);")
   ```  

4. 调用示例： 

  
   ```aardio
   //....省略创建 Web 窗体的代码 

   //只要是 Web 窗体external内的成员，都可以从网页上调用
   wb.external = { 
      showmsg = function (txt){
         win.msgbox(txt, "aardio");
         return true;
      }
   }

   //在网页的 JavaScript 里可以直接调用 external 成员
   wb.write( "
   <button onclick='external.showmsg(123)' >我是网页上的按钮</button>
   " )
   ```  
 
   external 使用的是 IDispatch 接口,请参考: [创建IDispatch接口](../../../builtin/com/ImplInterface.md#IDispatch)