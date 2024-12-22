# process库

process库提供进程管理函数。

## 进程

1. 什么是进程

    进程( process )是指一个正在执行的程序，一个计算机中的可执行 EXE 文件在运行后创建的程序实例。进程是由进程控制块、程序段、数据段组成。一个进程可以包含若干线程(Thread)，线程可以并发执行。
  

2. 进程ID

    进程被创建时，系统会赋给它一个唯一的标识符，这就是进程 ID。系统中运行的其他进程不会有相同的 ID 值，这个值也是可以被使用的，例如父进程可以通过创建子进程时得到的 ID 来和子进程通信。 

    在 aardio 中进程 ID 是一个数值。
  

3. 进程句柄

    进程对象是一种内核对象，每个内核对象实际上是由内核分配的一块内存，而且只能由内核来访问。这一内存块是一个数据结构，它的成员包含有关于该对象的信息。当调用创建内核对象的函数时，函数返回一个标志该对象的句柄。进程句柄可以被进程中的任意线程使用，可以把它传给各种 WIN32 函数，这样系统就知道想要操纵的是哪一个内核对象.  
  
在 aardio 中进程句柄是一个指针对象。

4. 进程对象

    aardio 的 process 库提供 process 类可以创建进程控制对象，可以启动进程或打开现有进程，获取进程内核对象的句，并提供一系列管理、控制目标进程的函数。

## 创建进程对象

1. 函数原型：    

    ```aardio
    //无参数返回当前进程对象
    prcs = process() 

    //传入进程ID打开已运行的进程对象
    prcs = process( 进程ID ) 

    //运行可执行文件,创建新的进程,可选传入任意个数文本参数
    prcs = process( "exe执行2文件路径","启动参数1", "启动参数2" ... ) 

    //运行可执行文件,创建新的进程,可选用 startInfo 参数指定启动选项
    prcs = process( "exe执行2文件路径",启动参数, startInfo)
    ```  
  
2. 函数说明：   
  
    process 是一个类，用于创建进程对象。
    而process 类的构造函数支持动态的参数，有四种用法：
    - 无参数,打开当前进程
    - 第一个参数指定进程 ID，打开指定进程。
    - 第一个参数指定可执行文件路径，并可选指定一个或多个字符串参数作为启动参数。如果传入多个启动参数，则包含空格的参数会在首尾加上双引号，并进行适当的转义处理，并最终合并为一个启动参数。
    - 使用可执行文件路径作为参数，第二个参数为启动参数， 启动参数可以是一个字符串，也可以指定一个参数表对象，参数表可以包含指定命名参数的名值对参数，也可以包含指定多个启动参数的字符串数组，参数表会自动合并为一个参数，带空格的参数首尾会自能加双引号并进行适当的转义处理。 第三个参数可选传入一个表指定启动选项，此表参数可指定 process.STARTUPINFO 结构体， 或者指定 process.STARTUPINFO 结构体的一部分字段。

3. 调用示例：   
  
    ```aardio
    import process;

    //创建进程并且暂停进程
    var prcs = process(  "请指定程序路径.exe",,{suspended = true /*启动后停止运行*/} ) 

    //继续执行线程 
    thread.resume( prcs.thandle )
    ```  

在本文档中,使用 prcs 表示 process 类构造的进程实例。

## 进程对象属性

更多进程属性请参考 [《 process 库参考 》](../../../library-reference/process/_.html#processObject) 

- prcs.id 表示进程ID
- prcs.handle 表示进程句柄
- prcs.tid 表示线程 ID

## prcs.free()

1. 函数原型：   

    `prcs.free()`

  
2. 函数说明：   
  
    关闭进程对象，指释放进程句柄，并非关闭目标进程(停止运行)。 

## prcs.terminate()

1. 函数原型：   

    `prcs.terminate()`

  
2. 函数说明：   
  
    强制杀除目标进程，使之停止运行。
    这是暴力中断进程，不宜太多使用，因为目标进程没有机会去做退出时释放资源保存数据的操作。 
    
    如果是窗口程序，可尝试调用 prcs.closeMainWindow() 函数关闭进程主窗口能否退出程序。

3. 调用示例：
  
    ```aardio
    import process; 

    //创建进程对象
    var prcs = process( "目标程序路径.exe"  ) //注意这里必须要是绝对路径

    thread.delay(1000)

    //杀除进程
    prcs.terminate()
    ```  

## prcs.readNumber

1. 函数原型：   

    `num =  prcs.readNumber ( 目标进程内存地址,"原生数据类型" )`

2. 函数说明：   
  
    自目标进程的指定内存地址,读取指定类型据类型的数字值.请参考:[原生数据类型](../../builtin/raw/datatype.md)

    可选的类型有:"int" "byte","word","long" 以及无符号数值数据 "INT","BYTE","WORD","LONG"。

## prcs.writeNumber

1. 函数原型：   

    `prcs.writeNumber ( 目标进程内存地址,要写入的数值,"原生数据类型" )`

2. 函数说明：   
  
    向目标进程的指定内存地址,写入指定类型据类型的数字值.请参考:[原生数据类型](../../builtin/raw/datatype.md)

    可选的类型有:"int" "byte","word","long"以及无符号数值数据"INT","BYTE","WORD","LONG"。

2. 调用示例： 

  
    ```aardio
    import process; 
    import fsys; 

    //创建进程对象
    var prcs = process( "目标程序路径.exe"  ) //注意这里必须要是绝对路径

    var n = prcs.readNumber( 0x101d1,"word" );  //读内存 word 类型数值
    prcs.writeNumber(0x101d1,n,"word");  //写入内存 word 类型数值
    ```  

## prcs.readString

1. 函数原型：   

    `prcs.readString(目标进程内存地址,要读取的字符串长度)`

  
2. 函数说明：   
  
    自目标进程的指定内存地址，读取指定长度的字符串值。

## prcs.writeString

1. 函数原型：   

    `prcs.writeString(目标进程内存地址,要写入的字符串)`

  
2. 函数说明：   
  
    向目标进程的指定内存地址，写入指定长度的字符串值。

## prcs.readStruct

1. 函数原型：   

    `num =  prcs.readStruct ( 目标进程内存地址,结构体 )`

2. 函数说明：   
  
    自目标进程的指定内存地址，读取自定义的 struct 结构体。
    
    参考:
    
    [原生数据类型](../../builtin/raw/datatype.md)

    [使用结构体](../../builtin/raw/struct.md)

## prcs.malloc

1. 函数原型：   

    `addr = prcs.malloc ( 要分配的内存长度,访问类型,分配类型 )`
  
2. 函数说明：   
  
    在目标进程分配内存，分配类型与访问类型可省略。此函数分配的内存默认可读写、可执行，可以用于写入机器码等。
    
    也可以显式指定分配类型与访问类型(一般无此必要)，访问类型为 _PAGE_ 前缀的常量,而分配类型为 _MEM_ 前缀的常量。

    在『开发环境』中输入该前缀可自动显示相关常量。


## prcs.mfree

1. 函数原型：   

    `prcs.mfree( 内存地址,释放长度=0,释放类型=0x8000 )`

  
2. 函数说明：   
    
    该函数用于释放 prcs.malloc 分配的内存地址。
    请注意此函数名字为 memery free 的缩写,首字母 m 表示memery(内存)，注意与 prcs.free() 区别。

    第二个参数,第三个参数通常不需要指定。
    如果将第三个参数指定为 0x4000，则仅仅释放指定长度的内存，这种方式释放不彻底，内存页还将存在。一般不应显式指定第二个参数以及第三个参数。

## prcs.remoteApi

1. 函数原型：   

    ```aardio
    remoteFunc = prcs.remoteApi( 函数原型, 这里是函数地址,调用约定="stdcall" )
    remoteFunc = prcs.remoteApi( 函数原型, DLL文件名,函数名字,调用约定="stdcall" )
    ``` 
  
2. 函数说明：   
  
    该函数内部实际上是调用 raw.remoteApi，
    所有参数用法与 raw.remoteApi 相同，唯一的区别是不需要使用进程 ID 参数。

    请参考: [raw.remoteApi](../../builtin/raw/remoteApi.md)

    使用 process 库启动的进程对象可以获取更高的权限，因此推荐使用 prcs.remoteApi 来代替 raw.remoteApi 。

    注意：不是所有目标进程能都支持这个功能。
    
## process.execute

1. 函数原型：   

    `process.execute( EXE文件路径, 启动参数="",操作类型 = "open",显示属性,工作目录="",调用窗口句柄=0  )`

  
2. 函数说明：   
  
    运行EXE程序,除第一个参数以外，其他参数可选。
    aardio 应用程序根目录路径，也支持系统目录下的相对路径。
    此函数与 Windows 开始菜单里的"运行"功能类似，在"开始菜单->运行"中可以输入的指令，在这里也可以直接输入。

    第三个参数可选的操作类型:
    - "edit"  
    打开编辑器编辑文档，如果 lpFile 不是一个文档，则这个函数会失败  
    - "explore"  
    以 lpFile 为路径打开资源管理器  
    - "find"  
    从指定目录开始搜索  
    - "open"  
    根据 lpFile 打开对应文件，该文件可以为可执行文件、文档或者文件夹  
    - "print"  
    根据 lpFile 打印文档，若lpFile不是一个文档则该函数会失败  
    - "properties"  
    显示文件或文件夹的属性

    第四个参数:显示属性使用 `_SW_` 开头的常量,在开发环境中输入 `_SW_` 会自动提示可用的常量。例如 `0/*_SW_HIDE*/` 表示隐藏窗口。

3. 调用示例 

    
    ```aardio
    import process 

    //直接运行,系统程序可以使用相对路径
    process.execute(  "Explorer.exe"," /select," + io._exepath )
    ```  

## process.executeWait

1. 函数原型：   

    `process.executeWait( EXE文件路径, 启动参数="",操作类型 = "open",显示属性 ,工作目录="",调用窗口句柄=0  )`

  
2. 函数说明：   
  
    此函数与 process.execute用法完全相同，唯一的区别是会等待目标程序关闭再返回。

## process.exploreSelect

1. 函数原型：   

    `process.exploreSelect( 文件路径  )`

  
2. 函数说明：   
  
    打开资源管理器,并选定该文件.

3. 调用示例：   
  
    以下示例打开资源管理器，并选定截屏图像文件。

    ```aardio
    import process
    import com.picture;

    var pic = com.picture.snap()//抓屏 
    pic.Save( "/抓屏.jpg" )

    //打开浏览器,选定该文件
    process.exploreSelect("/抓屏.jpg")
    ```  

## process.kill

1. 函数原型：   

    `process.kill( exe文件名 )`

  
2. 函数说明：   
  
    根据 EXE 文件名杀除进程。

2. 调用示例：   
  
    
    ```aardio
    import process 

    //关闭所有同名进程 
    process.kill( "指定要关闭的执行程序名称.exe" )
    ```  

## process.each

1. 函数原型：   

  
    ```aardio
    for processEntry in process.each( exeFileName ) { 

    }
    ```  

2. 函数说明：   
  
    查找参数 @exeFileName 指定 EXE 文件名的进程，并且循环遍历找到的进程。

    查找时支持完全匹配、模式匹配，并且忽略大小写。
    
    参考:
    
    [模式查找语法](../../builtin/string/patterns.md)

    [枚举与遍历的区别](../../../language-reference/function/enum-and-each.md) 
    
    [迭代器](../../../language-reference/statements/iterator.md)

3. 调用示例：   
  
    ```aardio
    import console;
    import process;

    for processEntry in process.each( ".*.exe" ) {  
        console.log("进程ID",processEntry.th32ProcessID); 
        console.log("进程文件名", processEntry.szExeFile);
    }

    console.pause();
    ```