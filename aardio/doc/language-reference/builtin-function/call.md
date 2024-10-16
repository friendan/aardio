# call() 函数

call() 函数用于调用一个 aardio 函数,并可自定义 owner 对象，并获取错误信息  

1. 函数原型：   

   `返回值,错误信息 = call(函数,owner,其他参数 ... )`

2. 函数说明：   
  
   call 函数可以调用并执行一个函数对象,  
   与普通函数调用不同的是:可显式指定 owner 对象,并可获取错误信息而不是直接抛出异常.  
  
3. 调用示例：   

   ```aardio
   import console;
   
   var ok = call(console.log,console,123) 
   
   var ok,err = call(notfound,console,123) 
   if(!ok) console.log("出错了",err) 
   
   console.pause();
   ```