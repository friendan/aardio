# .NET 程序集调试指南

## 一、dotNet.loadFile 函数：

`dotNet.loadFile(dll,pdbPath) `
此函数可用于加载程序集，主要作用是用于加载 DLL 的同时加载调试 pdb 文件。

1. 参数 `dll` 指定程序集路径时不能省略文件后缀 ".dll" ，不像 dotNet.load 函数指定的是程序集名称 —— 不需要写 ".dll" 后缀。

    虽然也可以用 `dll` 参数指定 DLL 的内存数据实现内存加载 DLL。 但并没有 dotNet.load,dotNet.reference 函数那样将内存程序集绑定程序集名称的作用。

2. 可选用参数 `pdbPath` 指定用于调试的 `*.pdb` 文件路径。

## 二、附加调试步骤：

1. 首先在 VS 中生成 Debug 版本 DLL 与 pdb 文件，然后在 aardio 中用下面的代码加载程序集：

    ```aardio
    var assembly = dotNet.loadFile("\Debug\CSNET2ClassLibrary.dll","\Debug\CSNET2ClassLibrary.pdb");
    ```

2. 用 VS 打开 DLL 的源码工程，然后用下面的代码附加调试进程。 

    ```aardio
    import com.dte;
    com.dte().AttachProcesses();
    ```

C# 的断点经常会失效，不要误以为是代码没执行，这时候可以在 C# 代码里加上 `System.Diagnostics.Debug.WriteLine()` 打印到调试输出窗口来辅助调试。

## 三、打开 C# 项目常见问题：

注意 VS 打开一些 C# 项目会出现一个 BUG：选择 .NET 目标版本选项为灰色禁用状态。可能网上各种解决方案都不起作用，这里提供一个方法大家可以试试：

在 VS 里直接双击编辑 * csproj 文件.找到设置 .NET 版本的配置,例如:
`<TargetFrameworks>netcoreapp3.0;net40</TargetFrameworks>`

然后将其修改为所需版本,例如:
`<TargetFrameworks>net40</TargetFrameworks>`
不用管 VS 里那个版本选项仍然是灰色，版本实际已经切换过去了。

如果你不想写个几十 KB 的 DLL 带上一百多 MB 的运行时，
那么请选择 .NET 2 ~ 4.x ，这些版本主流桌面系统都自带了，aardio 可以自动兼容。

另外 VS 里可能一些项目依赖会出现黄色警告，这时候你点恢复包什么的可能没有用。如果新版本 VS 就试试打开项目耐心等待一会再看看，如果等了不行，关掉或打开代理服务器再重新打开试一试。
