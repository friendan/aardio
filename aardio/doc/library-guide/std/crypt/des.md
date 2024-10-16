# DES 多语言通用加密算法指南

不同编程语言中DES加解密结果要保持一致要注意以下一些要点：
1. 工作模式默认 CBC，填充模式 PKCS5（兼容  PKCS7），不同语言要保持一致。
    aardio 可调用 setKeyParamMode 函数切换到 ECB 模式见下面的示例，ECB 模式不使用向量 IV 。
2. 向量要一致，默认使用'\x12\x34\x56\x78\x90\xAB\xCD\xEF'
3. 密钥要一致，DES密钥为8位，3DES可以使用24位密钥
4. 使用的文本编码要一致，同一个字符串，使用 UTF8 或 GBK 编码在内存中存储的实际数据可能是不一样的。在 aardio 中使用 string.fromto进行转换。
5. 如果加密后返回的密文用了BASE64或16进制编码，那么在解密时同样也先做对应的逆向解码。


## 密钥长度有什么影响，不同语言密钥长度为什么不一样

要特别注意 aardio 根据密钥长度自动选择算法，规则如下：

- 小于等于 8 字节使用 DES 算法。
- 小于等于 16 字节使用 2DES 算法。
- 小于等于 24 字节使用 3DES 算法。

所以一定要把密钥长度先处理好。

但是在其他一些语言里，你可能会看到 des, 2des 使用 32 位密钥，
其实非常简单，直接取前几位密钥，后面凑字数的密钥直接不要就可以。

在 aardio 里就这样处理：

- DES 算法就是 `key = string.left(key,8)`
- 2DES 算法就是 `key = string.left(key,16)`
- 3DES 算法就是 `key = string.left(key,24)`

如果对方的密钥用 BASE64 编码了，在 aardio 里这样解码：
`key = crypt.decodeBin(base64Key)`

## DES 加解密的 aardio 代码如下：

```aardio
import console;  
import crypt.des; 

var des = crypt.des(); 

//可选修改工作模式为 工作模式 ECB （ECB 不使用向量 IV ）
//des.setKeyParamMode(2/*_CRYPT_MODE_ECB*/);

des.setPassword("abcd1234" ) 

//加密
var sstr = des.encrypt("测试字符串");

//解密
var str = des.decrypt(sstr);

console.log( str, sstr ) 
console.pause(true);
```

## 兼容 aardio DES 加解密的 PHP 代码如下：

```php

<?
class CryptDes
{
    public $key = "";
    public $iv = "\x12\x34\x56\x78\x90\xAB\xCD\xEF";
    public function init_crypt($key)
    {
        $this->key = $key; 
    }
    public function encrypt($str)
    { 
        $size = mcrypt_get_block_size(MCRYPT_DES, MCRYPT_MODE_CBC);
        $str = $this->pkcs5Pad($str, $size);
        $hexString = bin2hex(mcrypt_cbc(MCRYPT_DES, $this->key, $str, MCRYPT_ENCRYPT, $this->iv));
        return strtoupper($hexString);
    }
    public function decrypt($str)
    { 
        $strBin = $this->hex2bin(strtolower($str));
        $str = mcrypt_cbc(MCRYPT_DES, $this->key, $strBin, MCRYPT_DECRYPT, $this->iv);
        $str = $this->pkcs5Unpad($str);
        return $str;
    }
    public function hex2bin($hexData)
    {
        $binData = '';
        for ($i = 0; $i < strlen($hexData); $i += 2) {
            $binData .= chr(hexdec(substr($hexData, $i, 2)));
        }
        return $binData;
    }
    public function pkcs5Pad($text, $blocksize)
    {
        $pad = $blocksize - strlen($text) % $blocksize;
        return $text . str_repeat(chr($pad), $pad);
    }
    public function pkcs5Unpad($text)
    {
        $pad = ord($text[strlen($text) - 1]);
        if ($pad > strlen($text)) {
            return false;
        }
        if (strspn($text, chr($pad), strlen($text) - $pad) != $pad) {
            return false;
        }
        return substr($text, 0, -1 * $pad);
    }
} 
$des = new CryptDes(); 
$des->init_crypt("abcd1234"); 
$sstr = $des->encrypt("def测试"); //加密
$str = $des->decrypt($sstr); //解密
echo $sstr;
?>
```

意上面的PHP版本将加密结果转换为了 16 进制字符，

在 aardio 中使用 string.unhex() 函数转回来， 注意 aardio  使用 UTF8 编码，上面的 PHP 文件也应该存为 UTF8 编码，如果P HP 使用 GBK 编码，那么相应的在 aardio 中 也要做 GBK 编码转换。

aardio 示例代码如下：

```aardio
import console;

import crypt.des;
var des = crypt.des();
des.setPassword("abcd1234" )

var phpsstr = "077E5E400A140170";//服务端返回的加密数据
phpsstr = string.unhex( phpsstr,"" ); //十六进制解码

var str = des.decrypt(phpsstr) ; //DES解码
str = string.fromto(str,0,65001) //PHP页面使用了UTF8，用这句转回来

console.log( str )
console.pause()
```

## 兼容 aardio DES 加解密的 JAVA 代码如下：

```java

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.security.Key;
import java.security.SecureRandom;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

public class Encrypt {

    SecretKeySpec key;

    public Encrypt(String str) {
        setKey(str);// 生成密匙
    }

    public Encrypt() {
        setKey("ABCDEFGH");
    }

    // 根据参数生成KEY
    public void setKey(String strKey) {
        this.key = new SecretKeySpec(strKey.getBytes(), "DES");  ;
    }

    //加密String明文输入,String密文输出
    public String getEncString(String strMing) {
        byte[] byteMi = null;
        byte[] byteMing = null;
        String strMi = "";
        BASE64Encoder base64en = new BASE64Encoder();
        try {
            byteMing = strMing.getBytes("UTF8");
            byteMi = this.getEncCode(byteMing);
            strMi = base64en.encode(byteMi);
        } catch (Exception e) {
            throw new RuntimeException(
                    "DES加解密异常: " + e);
        } finally {
            base64en = null;
            byteMing = null;
            byteMi = null;
        }
        return strMi;
    }

    // 解密 以String密文输入,String明文输出
    public String getDesString(String strMi) {
        BASE64Decoder base64De = new BASE64Decoder();
        byte[] byteMing = null;
        byte[] byteMi = null;
        String strMing = "";
        try {
            byteMi = base64De.decodeBuffer(strMi);
            byteMing = this.getDesCode(byteMi);
            strMing = new String(byteMing, "UTF8");
        } catch (Exception e) {
            throw new RuntimeException(
                    "DES加解密异常: " + e);
        } finally {
            base64De = null;
            byteMing = null;
            byteMi = null;
        }
        return strMing;
    }

    // 加密以byte[]明文输入,byte[]密文输出

    private static byte[] iv = {0x12,0x34,0x56,0x78,(byte)0x90,(byte)0xAB,(byte)0xCD,(byte)0xEF};
    private byte[] getEncCode(byte[] byteS) {
        IvParameterSpec zeroIv = new IvParameterSpec(iv);
        byte[] byteFina = null;
        Cipher cipher;
        try {
            cipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, this.key, zeroIv);
            byteFina = cipher.doFinal(byteS);
        } catch (Exception e) {
            throw new RuntimeException(
                    "DES加解密异常: " + e);
        } finally {
            cipher = null;
        }
        return byteFina;
    }

    //解密以byte[]密文输入,以byte[]明文输出

    private byte[] getDesCode(byte[] byteD) {
        IvParameterSpec zeroIv = new IvParameterSpec(iv);
        byte[] byteFina = null;
        Cipher cipher;
        try {
            cipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, this.key, zeroIv);
            byteFina = cipher.doFinal(byteD);
        } catch (Exception e) {
            throw new RuntimeException(
                    "DES加解密异常: " + e);
        } finally {
            cipher = null;
        }
        return byteFina;
    }

    public static void main(String args[]) {
        Encrypt des = new Encrypt();
        try {
            BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
            System.out.print("请输入明文: >");

            String str1 = in.readLine().trim();
            PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(str1)));
            String str2 = des.getEncString(str1);
            String deStr = des.getDesString(str2);
            System.out.println("密文:" + str2);
            System.out.println("明文:" + deStr);

            out.println("密文:" + str2);
            out.println("明文:" + deStr);
            out.close();
        }catch(Exception e) {
            System.out.println(e);
        }
    }
}
```

## 兼容 aardio DES 加解密的 C# 代码如下：

```csharp

using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;
using System.IO;

namespace CSharpLibrary  
{  
    public class CSharpObject  
    { 
        private static byte[] DES_IV = { 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF };
        public static string Encrypt4Base64(string pToEncrypt, string sKey)
        { 
            DESCryptoServiceProvider des = new DESCryptoServiceProvider();
            des.Key = Encoding.GetEncoding("GBK").GetBytes(sKey);
            des.IV = DES_IV;
        
            MemoryStream ms = new MemoryStream();
            CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(), CryptoStreamMode.Write);
        
            byte[] inputByteArray = Encoding.GetEncoding("GBK").GetBytes(pToEncrypt);
            cs.Write(inputByteArray, 0, inputByteArray.Length);
            cs.FlushFinalBlock();
        
            return Convert.ToBase64String(ms.ToArray());
        }
    }   
} 

```