# aardio 如何调用 soImage 快速识别简单验证码

## 一. 介绍

aardio 中提供了很多 OCR 组件可以用于识别验证码。

soImage 是 aardio 中常用的图像处理扩展库。使用 soImage 也可以实现简单的 OCR 功能。使用 soImage 的好处是简单且不需要第三方组件，soImage 的体积很小并支持生成独立 EXE 文件。

注意 soImage 可用于识别简单验证码，复杂验证码请改用其他更大的 OCR 组件。

## 二. 使用简单 OCR 代码生成器

在 aardio 的范例中提供了专门为 soImage 扩展库生成字库与 OCR 范例的工具：

[简单 OCR 生成器](../../../example/Automation/ComputerVision/soImage.ocr.html)

在 aardio 中运行上面的简单 OCR 生成器。

1. 输入验证码图像下载网址。
2. 点击『获取下一个图像』按钮。
3. 首先人工识别并输入图像上的文本，并继续点击『获取下一个图像』按钮以生成自动识别图像的样本数据。

该工具会自动生成识别验证码所需的字库样本与调用代码。

## 三. soImage 扩展库识别验证码示例

下面是一个使用 soImage 扩展库识别简单验证码的完整 aardio 代码示例：

```aardio
import soImage;
import inet.http;

//字库由 soImage 范例提供的工具自动生成
var ziku = {
"1":"11111111111111111111111111";
"2":"11111111000000110000001100";
"3":"11111110000000100000001000";
"4":"10000010100000101000001010";
"5":"11111110100000001000000010";
"6":"11111111100000011000000110";
"7":"11111110000000100000001000";
"8":"11111111100000111000001110";
"8":"11111111100000111000001110";
"9":"11111110100000101000001010"; 
"0":"11111111100000111000001110";
}

//创建图像对象
var img = soImage();

//下载图像
img.loadUrl("https://www.******.com/***.php")
 
//识别图像并返回文本
var text = img.ocr(ziku);

```