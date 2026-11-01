# 类
## class PacketWriter
```cj
public class PacketWriter
```
协议包写出器

### func clear\(\)
```cj
public func clear(): Unit
```
清空缓冲区（复用写出器构造下一个包）

### func init\(\)
```cj
public init()
```
构造写出器

### func toArray\(\)
```cj
public func toArray(): Array < UInt8 >
```
取出完整包字节

返回: 

- 已累积内容的副本

### func writeBool\(Bool\)
```cj
public func writeBool(v: Bool): Unit
```
写入布尔值（1 字节：true=1，false=0）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Bool|值|

### func writeBytes\(Array<UInt8>\)
```cj
public func writeBytes(data: Array < UInt8 >): Unit
```
写入原始字节（不带长度前缀）

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|字节数组|

### func writeF32\(Float32\)
```cj
public func writeF32(v: Float32): Unit
```
写入 Float32（4 字节大端 IEEE 754）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float32|值|

### func writeF64\(Float64\)
```cj
public func writeF64(v: Float64): Unit
```
写入 Float64（8 字节大端 IEEE 754）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Float64|值|

### func writeI16\(Int16\)
```cj
public func writeI16(v: Int16): Unit
```
写入 Int16（2 字节大端补码）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int16|值|

### func writeI32\(Int32\)
```cj
public func writeI32(v: Int32): Unit
```
写入 Int32（4 字节大端补码）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int32|值|

### func writeI64\(Int64\)
```cj
public func writeI64(v: Int64): Unit
```
写入 Int64（8 字节大端补码）

参数: 

|名称|类型|描述|
|---|---|---|
|v|Int64|值|

### func writeString\(String\)
```cj
public func writeString(s: String): Unit
```
写入字符串（u32 字节长度 + UTF-8 字节）

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|文本（空串编码为长度 0）|

### func writeU16\(UInt16\)
```cj
public func writeU16(v: UInt16): Unit
```
写入 UInt16（2 字节大端）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt16|值|

### func writeU32\(UInt32\)
```cj
public func writeU32(v: UInt32): Unit
```
写入 UInt32（4 字节大端）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|值|

### func writeU64\(UInt64\)
```cj
public func writeU64(v: UInt64): Unit
```
写入 UInt64（8 字节大端）

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt64|值|

### func writeU8\(UInt8\)
```cj
public func writeU8(v: UInt8): Unit
```
写入单个字节

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt8|字节值|

### prop size: Int64
```cj
public prop size: Int64
```
当前已累积的字节数

