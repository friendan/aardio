# 文件路径

# 应用程序根目录与 EXE 根目录  <a id="app-path" href="#app-path">&#x23;</a>

aardio 应用程序根目录指的是：

*   开发时指工程目录。
*   运行时指启动 EXE 文件所在目录。
*   不在当前工程内且单独运行的 aardio 文件，指启动该 aardio 文件所在的目录。
*   在创建线程、协程时 - 可以在参数中改变线程或协程的应用程序根目录，只能在启动线程或协程时设置一次，不允许在后续修改应用程序根目录。

aardio 文件路径的特殊语法：

* 文件路径以单个 `\` 或 `/` 作为首字符表示 aardio 应用程序根目录。
* 文件路径以 `~` 开始表示当前启动 EXE 文件所在目录。

aardio 中所有用到文件路径的函数或功能都支持以上语法与规则。例如在窗体中设置图片的路径，`$` 包含操作符，string.load ，string.save以及标准库里基本所有用到文件路径参数的函数。

当前目录（以 `./` 表示 ）容易被改变， 例如打开系统文件对话框就会导致当前目录改变。或者在 aardio 中调用 fsys.setCurDir() 也能改变当前目录。 而 aardio 的 「应用程序根目录」对于一个 aardio 程序总是表示确定的位置，更加可靠。  

对于 `$` 包含操作符，以及 raw.loadDll() string.load() string.loadBuffer() 函数，如果以 `~` 开头表示的 EXE 根目录下的路径不存在，会自动切换为 `\` 开头的应用程序根目录下的路径并尝试读取文件。

## io.fullpath 函数 <a id="fullpath" href="#fullpath">&#x23;</a>

1. 函数原型：   

    `绝对路径 = io.fullpath( 相对路径 )`
  
2. 函数说明：   
  
    io.fullpath 将输入参数指定的相对路径转换为绝对路径。

    转换规则如下: 
    - 如果路径以双反斜杆 `\\` 开始，不作转换直接返回，路径前加 `\\?\` 可避免转换并支持畸形路径。
    - 如果路径以双正斜杠 `//` 开始，移除第一个斜杠后返回，不作其他转换，可用于表示系统分区根目录,
    - 如果路径以单个 `\` 或`/` 字符开始，作为 aardio 应用程序根目录下的相对路径转换并返回完整路径。
    - 如果路径以 `~` 开始，作为当前运行的 EXE 根目录下的相对路径转换并返回完整路径。
    - 其他路径按系统规则转换为完整路径。
    - 传入空字符串或空值返回 null 。
      
    此函数并不会检测路径是否存在，但会检测参数是否正确的路径名，并纠正错误的写法，例如将正斜杠修正为反斜杠。

    aardio 自带的文件操作函数基本都会自动调用 io.fullpath 转换参数传入的文件路径。 

    但是要注意在文件路径开始以 `~` 表示 EXE 启动目录以及以单个  `\` 或 `/` 作为首字符表示 aardio 应用程序根目录的写法仅适用于 aardio，其他外部组件或外部接口并不支持，我们需要调用 io.fullpath 将 aardio 路径转换为其他外部程序可以识别的绝对路径。

3. 调用示例：   
  
    ```aardio
    var path = io.fullpath( "/res/test.jpg" )
    ```

## io.localpath 函数 <a id="localpath" href="#localpath">&#x23;</a>


1. 函数原型：   

    `绝对路径 = io.localpath( 相对路径 )`

  
2. 函数说明：   

    如果参数指定的文件路径使用了 aardio 专用格式则转换为系统支持的完整路径，否则返回空值。

    转换规则如下： 
    - 如果路径以双反斜杆 `\\` 开始，不作转换直接返回 null 空值。
    - 如果路径以双正斜杠 `//` 开始，移除第一个斜杠后返回，不作其他转换，可用于表示系统分区根目录。
    - 如果以单个 `\`  `/` 字符开始，将参数作为 aardio 应用程序根目录下的相对路径转换并返回完整路径。
    - 如果路径以 `~` 开始，将参数作为当前启动 EXE 根目录下的相对路径转换并返回完整路径。
    - 其他格式路径不作转换返回 null 空值。

## io.exist 函数

1. 函数原型：   

    `fullpath = io.exist( path,mode )`
  
2. 函数说明：   

    指定的文件路径参数 @path 如果不是字符串、不是一个合法的路径、或是一个空字符串时该函数返回 null 值。否则，此函数调用 io.fullpath 将文件路径转换为绝对路径，如果文件存在返回绝对路径,否则返 回 null 。

    参数 @mode 用于添加检测条件，可选值如下：
    - null 值或省略，仅检查文件路径是否存在。
    - 2，检查文件是否可写，失败返回 null 值，路径如果是目录或只读文件返回 null。
    - 4，检查文件是否可读，失败返回 null 值，路径如果是一个目录返回 null。
    - 6，检查文件是否可读写，失败返回 null 值，路径如果是一个目录返回 null。

    传入错误的参数 @path 时，io.exist 不会抛出异常，而是返回 null 值。

    > null 在条件表达式中可以转换为 false , 表示条件假值。
  
3. 调用示例：   
  
    ```aardio
    var fullpath = io.exist(  "/res/test.jpg" );

    if(!fullpath){
      error("文件不存在")
    }
    ```  

## io.splitpath 函数

1. 函数原型：   

    ```aardio
    var pathInfo = io.splitpath( filepath )
    ```

  
2. 函数说明：   
  
    该函数拆分参数 filepath 指定的文件路径为多个部分，并返回包含这些拆分部分的对象 pathInfo 。

    pathInfo 有以下成员:  
    - pathInfo.dir 表示文件路径所在的目录路径，以斜杠结束  
    - pathInfo.name 表示文件名(无后缀)  
    - pathInfo.ext 表示文件后缀名(包含圆点)  
    - pathInfo.file 包含后缀名的完整文件名  
    - pathInfo.drive 所在的分区号,以冒号结束。  
    - `pathInfo.dir ++ pathInfo.file` 等于完整的文件路径。  

3. 调用示例： 


    ```aardio
    //新建一个控制台程序，main.aardio 代码如下

    //将参数去掉引号
    var path = string.trim( _CMDLINE ,'"');

    //拆分为目录名,文件名,后缀名,分区号
    var pathInfo = io.splitpath(path)

    //重命名
    io.rename( path,pathInfo.dir ++ pathInfo.ext )

    //发布该程序为 exe 文件,将需要去掉文件名字的文件 - 往该 exe 上一拖即可.
    ```  

## io._exepath

只读属性，返回启动主程序的exe文件路径，开发环境中此属性返回 aardio.exe 的完整文件路径。

## io._exedir

只读属性，返回启动主程序的 exe 文件所在的目录路径，开发环境中此属性返回 aardio.exe 所在的目录路径。

## io._exefile

只读属性，返回启动主程序的 exe 文件名