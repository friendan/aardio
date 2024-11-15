# 内置函数

内置函数是由 aardio 内核或者标准库 builtin 模块提供的函数。

以下内置函数属于保留函数，保留函数全局有效且不能修改。 <a id="reserved-functions" href="#reserved-functions">&#x23;</a>

- eval 计算表达式
- import 导入库
- type 类型检测
- assert 断言
- assert2 断言并指定抛出异常的调用级别 
- assertf 反断言
- error 抛出异常
- errput 输出错误信息，但不会抛出异常
- rget 在多返回值中获取指定返回值
- callex 调用函数，并可自定义 owner 参数与错误处理函数
- call 调用函数且不会抛出异常，可用首个返回值判断调用是否成功
- invoke 调用函数，并可自定义 owner 参数，失败直接抛出异常。
- dumpcode 编译 aardio 代码
- collectgarbage 回收内存
- tostring 转换参数为字符串
- topointer  转换参数为指针
- tonumber 转换参数为数值
- sleep 休眠
- execute 调用系统命令行
- setlocale 区域设置
- setprivilege 指定进程权限
- loadcode 加载 aardio 代码或代码文件
- loadcodex 直接执行 aardio 代码或代码文件
- reduce 对数组中的每个值从左到右开始缩减，并计算为一个值

保留函数特点：

- 保留函数在所有名字空间中都可以直接使用保留函数而不必在保留函数名前面添加 `..` 操作符。
- 所有保留函数在 aardio 编辑器中默认显示为蓝色高亮的样式，与语法关键字相同。

注意 import 比较特殊。import 是一个语法关键字，同时又是一个保留函数名。必须使用类似 `global.import()` 的格式才能调用 import 函数。

> 使用 import 语句导入的库会发布到 EXE 执行程序中，但  `global.import()` 导入的库不会被发布（ 除非使用 import 语句导入了相同的库）。

aardio 还提供了以下未设置为保留函数的普通全局函数：

- lasterr 获取系统错误
- publish  发布消息
- subscribe 订阅消息
- print 模板输出函数

这几个函数并非全局对象，在非全局名字空间使用时要加上 `..` 前缀，例如 `..lasterr()`。


 
