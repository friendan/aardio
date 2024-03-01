  
	// 启动RPC服务允许aardio/electron互调函数,创建BrowserWindow主窗口
    const aardio = require('aardio') 
    
    // 管理electron进程的生命周期 
    const app = require('electron').app 
    
	aardio.ready( win=> { 
		win.removeMenu()
		
		win.on('closed', () => {  
			
		})  	
	} )

	app.on('window-all-closed', () => {
		app.quit(); // 退出electron进程
	}) 