# 类
## class PacketReader
```cj
public class PacketReader
```
协议包读取器

### func init\(Array<UInt8>\)
```cj
public init(data: Array < UInt8 >)
```
构造读取器

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|包字节（持有引用，不拷贝）|

### func readBool\(\)
```cj
public func readBool(): Bool
```
读取布尔值（1 字节：非 0 为 true）

返回: 

- 值

### func readBytes\(\)
```cj
public func readBytes(): Array < UInt8 >
```
读取长度前缀字节块（u32 长度 + 字节）

返回: 

- 字节数组副本

### func readF32\(\)
```cj
public func readF32(): Float32
```
读取 Float32（4 字节大端 IEEE 754）

返回: 

- 值

### func readF64\(\)
```cj
public func readF64(): Float64
```
读取 Float64（8 字节大端 IEEE 754）

返回: 

- 值

### func readI16\(\)
```cj
public func readI16(): Int16
```
读取 Int16（2 字节大端补码）

返回: 

- 值

### func readI32\(\)
```cj
public func readI32(): Int32
```
读取 Int32（4 字节大端补码）

返回: 

- 值

### func readI64\(\)
```cj
public func readI64(): Int64
```
读取 Int64（8 字节大端补码）

返回: 

- 值

### func readString\(\)
```cj
public func readString(): String
```
读取字符串（u32 字节长度 + UTF-8）

返回: 

- 文本

### func readU16\(\)
```cj
public func readU16(): UInt16
```
读取 UInt16（2 字节大端）

返回: 

- 值

### func readU32\(\)
```cj
public func readU32(): UInt32
```
读取 UInt32（4 字节大端）

返回: 

- 值

### func readU64\(\)
```cj
public func readU64(): UInt64
```
读取 UInt64（8 字节大端）

返回: 

- 值

### func readU8\(\)
```cj
public func readU8(): UInt8
```
读取单个字节

返回: 

- 字节值

### func skip\(Int64\)
```cj
public func skip(n: Int64): Unit
```
跳过 n 个字节

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int64|跳过的字节数|

### prop hasMore: Bool
```cj
public prop hasMore: Bool
```
是否还有未读字节

### prop position: Int64
```cj
public prop position: Int64
```
当前游标位置（字节偏移，用于调试/跳过）

### prop remaining: Int64
```cj
public prop remaining: Int64
```
剩余未读字节数

