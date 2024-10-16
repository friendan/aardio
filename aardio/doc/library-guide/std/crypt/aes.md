# AES 多语言通用加密算法指南

aardio,PHP,C#,Java 等不同编程语言中 AES 加解密结果要保持一致要注意以下一些要点：

1. 工作模式 CBC ，填充模式 PKCS7，不同语言要保持一致。
要注意 PKCS5 与 PKCS7 的填充规则是相同的，区别是PKCS5填充1到8字节,PKCS7填充1到255字节，而AES实际使用的数据区分组为 16 字节（128位），所以即使填充模式指定 PKCS5 - 实际使用的也是 PKCS7。下面的 JAVA代码里只能选 PKCS5 ，而 C#代码里只能选 PKCS7, 这都是兼容的没有问题。
2. 在下面的示例中，加密向量统一设为与密钥相同。
3. 不同编程语言使用的文本编码要一致，同一个字符串，使用UTF8或GBK编码在内存中存储的实际数据可能是不一样的。在aardio中默认编码为UTF-8,使用 string.fromto进行转换为其他编码。
4. 如果加密后返回的密文用了BASE64或16进制编码，那么在解密时同样也先做对应的逆向解码。

## aardio 实现 AES 加密、解密的代码：

```aardio
import console;  
import crypt.bin;
import crypt.aes;

//创建AES加密算法容器
var aes = crypt.aes();

//设置密钥(最大32个字节)
aes.setPassword("1234567812345678");

//不指定加密向量时默认设为密钥的值
//aes.setInitVector("1234567812345678")

//加密
var str = aes.encrypt("Test String");

//BASE64编码加密结果
console.log( crypt.bin.encodeBase64( str ) );

//解密
str = aes.decrypt(str);
console.log(str);

console.pause(true);
```

## 要保持 AES 加解密结果与上面的 aardio 代码一致， C# 语言 AES 加解密代码如下：

```csharp
using System;
using System.Text;
using System.Security.Cryptography;

namespace TestApp
{
    class Aes
    {
        static void Main(string[] args)
        {
            String str = "Test String";
            String encryptData = Aes.Encrypt(str, "1234567812345678", "1234567812345678");
            Console.WriteLine(encryptData);

            String dstr = Aes.Decrypt("xL1eEwu9WCDRiscUbPPPSA==", "1234567812345678", "1234567812345678");
            Console.WriteLine(dstr);
            Console.ReadKey();
        }

        public static string Encrypt(string toEncrypt, string key, string iv)
        {
            byte[] keyArray = UTF8Encoding.UTF8.GetBytes(key);
            byte[] ivArray = UTF8Encoding.UTF8.GetBytes(iv);
            byte[] toEncryptArray = UTF8Encoding.UTF8.GetBytes(toEncrypt);

            RijndaelManaged rm = new RijndaelManaged();
            rm.Key = keyArray;
            rm.IV = ivArray;
            rm.Mode = CipherMode.CBC;
            rm.Padding = PaddingMode.PKCS7;

            ICryptoTransform cTransform = rm.CreateEncryptor();
            byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
            return Convert.ToBase64String(resultArray, 0, resultArray.Length);
        }

        public static string Decrypt(string toDecrypt, string key, string iv)
        {
            byte[] keyArray = UTF8Encoding.UTF8.GetBytes(key);
            byte[] ivArray = UTF8Encoding.UTF8.GetBytes(iv);
            byte[] toEncryptArray = Convert.FromBase64String(toDecrypt);

            RijndaelManaged rm = new RijndaelManaged();
            rm.Key = keyArray;
            rm.IV = ivArray;
            rm.Mode = CipherMode.CBC;
            rm.Padding = PaddingMode.PKCS7;

            ICryptoTransform cTransform = rm.CreateDecryptor();
            byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
            return UTF8Encoding.UTF8.GetString(resultArray);
        }
    }
}
```

## 要保持 AES 加解密结果与上面的 aardio 代码一致， PHP 语言 AES 加解密代码如下：

```php

import console;
import php;

php.code =/***

//AES加密
function aes_encrypt($encryptKey,$encryptStr) {
    $localIV = $encryptKey;
    $encryptKey = $encryptKey;
   
    $module = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, $localIV);
    mcrypt_generic_init($module, $encryptKey, $localIV);
   
    $block = mcrypt_get_block_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
    $pad = $block - (strlen($encryptStr) % $block);
    $encryptStr .= str_repeat(chr($pad), $pad);

    $encrypted = mcrypt_generic($module, $encryptStr);
    mcrypt_generic_deinit($module);
    mcrypt_module_close($module);

    return base64_encode($encrypted);

}

//AES解密
function aes_decrypt($encryptKey,$encryptStr) {
    $localIV = $encryptKey;
    $encryptKey = $encryptKey;

    $module = mcrypt_module_open(MCRYPT_RIJNDAEL_128, '', MCRYPT_MODE_CBC, $localIV);
    mcrypt_generic_init($module, $encryptKey, $localIV);

    $encryptedData = base64_decode($encryptStr);
    $encryptedData = mdecrypt_generic($module, $encryptedData);
   
    $e = ord($encryptedData[strlen($encryptedData)-1]);
    if($e<=16)$encryptedData=substr($encryptedData, 0,strlen($encryptedData)-$e);
    return $encryptedData;
}


$result = aes_encrypt("1234567812345678",'Test String');
$decryptString = aes_decrypt("1234567812345678",$result);

echo $result;
echo $decryptString;
```

因为 PHP7.1 废弃了mcrypt，所以写法不一样，
要保持加解密结果与上面的aardio代码一致，需要这样写：

```php
<?php

//AES加密
function aes_encrypt($key,$str)
{  
    return base64_encode( openssl_encrypt($str, 'AES-128-CBC',$key,OPENSSL_RAW_DATA,$key) );;
}

//AES解密
function aes_decrypt($key,$str)
{
    return openssl_decrypt(base64_decode($str), 'AES-128-CBC', $key, OPENSSL_RAW_DATA, $key);
}

$result = aes_encrypt("1234567812345678",'Test String');
$str = aes_decrypt("1234567812345678",$result);

echo $result."<br>";
echo $str;
?>
```

## 要保持 AES 加解密结果与上面的 aardio 代码一致， Java 语言 AES 加解密代码如下：

```java
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.Cipher;  
import javax.crypto.KeyGenerator;  
import javax.crypto.SecretKey;  
import javax.crypto.spec.SecretKeySpec;  
import sun.misc.BASE64Decoder;  
import sun.misc.BASE64Encoder;
  
public class AESCrypt {   
 
    public static String encrypt(String source, String key) throws Exception { 
         
        byte[] sourceBytes = source.getBytes("UTF-8");  
        byte[] keyBytes = key.getBytes("UTF-8"); 
        
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");   
        IvParameterSpec ivParameterSpec = new IvParameterSpec(keyBytes);
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(keyBytes, "AES"),ivParameterSpec);   
         
        byte[] decrypted = cipher.doFinal(sourceBytes);  
        return new sun.misc.BASE64Encoder().encode(decrypted);  
    }  
        
    public static String decrypt(String encryptStr, String key) throws Exception {  
        byte[] sourceBytes = new sun.misc.BASE64Decoder().decodeBuffer(encryptStr);  
        byte[] keyBytes = key.getBytes("UTF-8"); 
        
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");   
        IvParameterSpec ivParameterSpec = new IvParameterSpec(keyBytes); 
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(keyBytes, "AES"),ivParameterSpec); 
           
        byte[] decoded = cipher.doFinal(sourceBytes);    
        return new String(decoded, "UTF-8");  
    }  
      
}  
```