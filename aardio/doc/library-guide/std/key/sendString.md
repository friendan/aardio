# 自动发送文本


## winex.editor.sendString 

winex.editor.sendStringByClip 将文本临时复制到剪贴板并模拟粘贴文本的快捷键发送文本，在发送前后会备份与恢复剪贴板的文本与图像等。

示例：

```aardio
import winex.editor;

winex.editor.sendString('abc 中文\t你好\naaa')
```

这个函数会检测目标窗口类名与运行程序的文件名，并自动选择合适的发送方式。
对于经典文本框会使用句柄直接设置文本，相当于调用 winex.sendString。对于 winex.editor.sendStringByClipExe 表指定的程序名，会调用 winex.editor.sendStringByClip 通过剪贴板发送文本。对于其他程序调用 key.sendString 发送文本。

## key.sendString

这个函数的兼容性最好，类似输入法可以广泛适用于所有可输入的目标窗口。

示例：

```aardio
import key; 
key.sendString("test 直接发送字符串。");
```

对于非控制字符（字节码大于等于 32 ）key.sendString 可直接发送字符到目标窗口，不需要发送按键也不受输入法影响。

但换行符发送回车键，制表符发送 tab 键，其他控制字符被忽略。这在大多时候没有问题，但如果刚好前面的字符触发并显示了类似弹出自动完成列表这样的行为，则发送回车键或 tab 键会导致触发其他操作而不是发送字符。

发送单行且不包含制表符的文本，key.sendString 是最佳选择。

> key.send 函数类似于 key.sendString，但是 key.send 对于能作为键名使用的字符优先发送字符所在的按键而不是发送字符，例如 `key.send("(")` 发送的该符号所在的按键，输出的是 "9" 。

## winex.sendString

这个函数适用于支持 EM_REPLACESEL 消息的传统编辑框。

兼容性不及 key.sendString，但对于支持 EM_REPLACESEL 消息的目标窗口则最最佳选择。

示例：

```aardio
import winex; 
winex.sendString("test \n\t 发送字符串。");
```

winex.sendString 直接向目标窗口输入纯文本内容，所有字符都不需要发送按键也不受输入法影响。

可选用第二个参数指定目标窗口句柄，可后台发送文本。不指定目标窗口则自动获取当前输入窗口句柄。

## winex.setText

发送 WM_SETTEXT 消息设置控件的全部文本。

```aardio
import winex;

//获取输入框句柄
var hwnd = winex.getFocus();

winex.setText(hwnd,"测试文本");
```

第一个参数指定窗口句柄，可后台发送。

无句柄控件不支持 WM_SETTEXT 消息。传统窗口与控件在接收 WM_SETTEXT 消息时会改变窗口标题或控件文本，不仅仅是编辑框会处理这个消息。

## winex.say，winex.sayIme

仅支持处理 WM_CHAR 或 WM_IME_CHAR 消息的窗口，忽略控制字符，类似 Chrome 浏览器窗口只能发送多字节字符（例如中文）。

示例：

```aardio
import winex; 
winex.say("test \n\t 发送字符串。");
```

可选用第二个参数指定目标窗口句柄，可后台发送文本。不指定目标窗口则自动获取当前输入窗口句柄。

## winex.key.send

后台发送按键与 WM_CHAR 消息，兼容性类似 winex.say。

示例：


```aardio
import winex.key; 
winex.key.send(,"TEST")(
```

可选用第一个参数指定目标窗口句柄，可后台发送文本。不指定目标窗口则自动获取当前输入窗口句柄。

## 使用剪贴板发送文本
