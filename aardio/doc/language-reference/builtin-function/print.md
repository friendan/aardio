# print 函数

### 函数原型   

`print( ... )`


支持多个不定参数，每个参数都会调用 tostring 转换为字符串。

### 函数说明   

print 函数非常特别，它属于内置函数，又不是保留函数，可以自由重写。  
但是一般用户代码中不应当重写此函数，应当交由框加或库来管理 print 函数。也不应将 print 赋值到其他变量后再进行调用，因为 print 函数随时可能被改变指向。

aardio 代码在解析[模板语法](../templating/syntax.md)时，将自动调用 print 函数输出数据。在不同类型的应用中，print 可能指向不同的输出函数。例如在 HTTP 服务端中 print 将自动指向 response.write 函数。而在调用 string.loadcode 时 print 将临时指向拼接字符串的代码。

在未调用重写 print 函数的库或函数的默认情况下：

- 如果在开发环境中且首次调用模板或 print 输出的是 HTML 代码，则创建网页浏览器控件并显示该 HTML 代码生成的网页内容。print 函数用于输出网页时不会自动添加分隔符与换行。
- 否则 print 函数将默认调用 io.print 函数向控制台窗口输出内容。print 函数在默认调用 io.print 前会自动打开控制台，之后在退出非界面线程( 指未导入 win.ui 的线程 ) 前会暂停控制台。print 指向 io.print 函数时会自动添加分隔符与换行。

通常情况下，用户应当调用确定的 response.write，console.log 等函数而不是可变的 print 函数。 

对于非常简单的控制台示例程序，可以使用 print 函数简化代码。这是因为 print 函数有默认打开控制台以及在退出非界面线程前暂停控制台的功能，可以简化示例代码。 

例如：

```aardio
for(i=1;10;1){
	print(i);
}
```

但是 print 函数并不能支持复杂的控制台功能，而且要考虑 print 函数可能被重写的特性。对于正式开发的控制台程序，仍然应当使用 console 库，例如：

```aardio
import console;
for(i=1;10;1){
	console.log(i);
}
console.pause();
```

console 库函数有自动打开控制台的功能，但退出线程时必须主动调用 `console.pause()` 才能暂停控制台。这是因为 console 库在 aardio 中被大量使用，很可能我们在创建线程或子进制时会调用到 console 库，如果默认执行  `console.pause()` 就可能导致不需要的暂停操作（ 同样的原因，我们应当避免在写库时直接调用默认具有暂停控制台功能的 print 函数 ）。如果需要 console 库在退出时自动暂停（避免控制台自动关闭）则只要将 `import console` 改为  `import console.int` 就可以。

在正式开发的 aardio 程序中，print 函数应当总是被模板语法自动调用，不建议在用户代码中显式调用 print 函数。