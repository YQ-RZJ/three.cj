# 类
## class Hash
```cj
public class Hash
```
非加密哈希算法工具类

### func fnv1a32\(Array<UInt8>\)
```cj
public static func fnv1a32(data: Array < UInt8 >): Int64
```
计算 FNV-1a 32 位哈希值

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|待哈希的字节数组|

返回: 

- 32 位无符号整数哈希值（用 Int64 容纳，保留位模式）

### func murmurHash32\(Array<UInt8>,UInt32\)
```cj
public static func murmurHash32(data: Array < UInt8 >, seed!: UInt32 = 1102u32): Int64
```
计算 MurmurHash3 32 位哈希值（x86 版本）

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|待哈希的字节数组seed 哈希种子（默认 1102），用于生成不同哈希空间|
|seed|UInt32||

返回: 

- 32 位无符号整数哈希值（用 Int64 容纳，保留位模式）

