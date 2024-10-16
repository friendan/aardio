# Go / aardio 原生类型转换

aardio 可以使用 table 定义结构体(struct)，在结构体中可以定义原生类型类型。

请参考：

- [raw 库](../../builtin/raw/api.md) 
- [原生数据类型](../../builtin/raw/datatype.md)

  
## aardio，C 语言，cgo，Go 类型对应关系

| aardio | C 语言 | cgo | Go |
| --- | --- | --- | --- |
| BYTE | char | C.char | byte,bool |
| byte | singed char | C.schar | int8 |
| BYTE | unsigned char | C.uchar | uint8,byte |
| word | short | C.short | int16 |
| WORD | unsigned short | C.ushort | uint16 |
| int | int | C.int | int32,rune |
| INT | unsigned int | C.uint | uint32 |
| int | long | C.long | int32 |
| INT | unsigned long | C.ulong | uint32 |
| long | long long | C.longlong | int64 |
| LONG | unsigned long long | C.ulonglong | uint64 |
| float | float | C.float | float32 |
| double | double | C.double | float64 |
| INT | size\_t | C.size\_t | uint |
| pointer | void \* |  | unsafe.Pointer |

要特别注意 Go 的 bool 类型只有 1 个字节，相当于 aardio 中的 BYTE，而 aardio 中的 bool 类型则是 32 位 4 个字节，相当于 WinAPI 定义的 BOOL 类型。

aardio 调用 Go 示例，首先调用 Go 编译器生成 DLL 文件： 

```aardio
//调用编译后的 DLL 不需要导入此为
import golang;

//创建 Go 编译器（ 仅仅调用编译后的 DLL 不需要 ）。 
var go = golang();

//Go 源码：与 aardio 一样默认 UTF-8 编码
go.main = /**********
package main

import "C" //单独导入这句启用 CGO
import "fmt" //https://pkg.go.dev/fmt
import "unsafe" //https://pkg.go.dev/unsafe

type MyStruct struct { 
    Int8Field   int8
    Int16Field  int16
    Int32Field  int32
    Int64Field  int64
    UintField   uint
    Uint8Field  uint8
    Uint16Field uint16
    Uint32Field uint32
    Uint64Field uint64
    Float32Field float32
    Float64Field float64
    pStr *C.char 
}

//在注释里用 export 声明为 DLL 导出函数  
//export SetStruct
func SetStruct(p uintptr) {  
    // aardio 结构体转换为 Go 结构体
    st := (*MyStruct)(unsafe.Pointer(p)) 
    st.Int8Field = 8
 
    //Go 用 fmt.Println 打印变量很方便，可传入多个任意类型的参数。 
    fmt.Println( "在 Go 中打印结构体：",st );
    
    var str = C.GoString(st.pStr);
    fmt.Printf("Go says: %s!\n", str) 
}

//初始化函数，可以重复写多个
func init() { }

//必须写个空的入口函数，实际不会执行
func main() {} 
**********/

//上面的 go.main 会自动保存到文件，然后编译 Go 源码生成同名 DLL 文件
go.buildShared("/.go/testStruct.go");
```  
然后在 aardio 中调用上面生成的 DLL:  

```aardio
import console.int;
//加载 Go 编译的 DLL，注意要指定 cdecl 调用约定。 
var goDll = raw.loadDll($"/.go/testStruct.dll",,"cdecl");
//如果已经生成 DLL，用$操符符可以嵌入 DLL 到代码中实现内存加载（发布后不需要带 DLL 文件）。
//声明结构体
class myStruct {
    byte Int8Field;//Go类型 int8
    word Int16Field;//Go类型 int16
    int32 Int32Field;//Go类型 int32
    long64 Int64Field;//Go类型 int64 
    BYTE Uint8Field;//Go类型 uint8
    WORD Uint16Field;//Go类型 uint16
    INT32 Uint32Field;//Go类型 uint32
    LONG64 Uint64Field;//Go类型 uint64
    float Float32Field;//Go类型 float32
    double Float64Field;//Go类型 float64
    string pStr = "这是 aardio 字符串"
}

//创建结构体
var struct = myStruct();

//调用 Go 函数，传结构体（结构体总是传址）
goDll.SetStruct(struct); 

//打印结构体
console.dumpJson(struct);
```  

调用 Go 写的 DLL 请注意：  
  
1.  加载 Go 写的 DLL 然后迅速（几秒以内）退出，Go 程序可能会崩溃。  
    这不是因为你写的代码有任何问题，而是 Go 需要额外启动运行时，无法应付这种快速退出的情况。  
    这时在后面加一句 thread.delay(2000) 就可以解决。  
    
    实际上除了写测试代码，一般也不会打开一个程序就在几秒内退出。  
    所以稍加注意一下，避免这个问题并不难。  
  
    只有 Go 写的 DLL 有这个问题，其他语言写的 DLL 没这种问题。  
  
2. 在同一个进程内， Go 写的同一个 DLL 应当只加载一次。  
    当然在 DLL 没有卸载前，反复调用 raw.loadDll() 只是增加引用计数，不会重复加载 DLL。  
    
    如果多线程内存加载同一个 Go 写的 DLL 就会加载多个不同的副本。  
    这时候务必在 raw.loadDll("go.dll","共享名称") 的第 2 个参数指定共享名称，以避免重复加载。  
  
3. 要注意在 aardio 中 DLL 不应当作为线程参数传递，实际上也没必要这样做。  

    只要用 raw.loadDll() 加载同名 DLL (或加载相同共享名称的内存 DLL) 是不会重复加载的。