# loadcode() 函数

loadcode() 加载 aardio 代码或 aardio 代码文件，并返回加载代码创建的函数对象。

1. 函数原型：   

	`函数对象,错误信息 = loadcode( codeString | filepath )`
  
2. 函数说明：   
  
	参数 @1 可以是包含 aardio 代码的字符串值，也可以是 aardio 代码文件的路径.路径可以用斜杠作为首字符表示应用程序根目录。loadcode 函数并不立即执行代码，而是返回一个函数对象.  
	
	如果加载代码失败，则返回的函数对象为 null 值，并在第二个返回值中返回错误信息.  
	
	一个类似的函数是 [loadcodex](loadcodex.md) 函数，loadcodex 立即运行代码并返回被调用代码的返回值。
	
3. 调用示例：   
  
	```aardio
	import console; 

	//生成一个测试用代码文件 
	string.save("/.test.aardio"," 
	var a,b,c = ...;//文件也是一个匿名函数,可以这样接收参数 
	myTestFunc = function(){ 
		return'loadcode->myFunc'; 
	}"); 

	//加载代码文件返回一个函数对象 
	var func = loadcode("/.test.aardio") 

	//执行代码文件 
	func("a参数","b参数","c参数")

	//执行该代码文件中定义的函数 
	var str = myTestFunc(); 

	//暂停控制台并显示 str 变量 
	console.logPause(str);
	```