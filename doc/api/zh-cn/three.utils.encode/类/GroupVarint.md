# 类
## class GroupVarint
```cj
public class GroupVarint
```


### func decodeGroup\(Array<UInt8>,Int,Array<UInt32>\)
```cj
public static func decodeGroup(input: Array < UInt8 >, baseOffset: Int, output: Array < UInt32 >): Int
```
解码 4 个 UInt32 值

参数: 

|名称|类型|描述|
|---|---|---|
|input|Array<UInt8>|编码后的字节缓冲区|
|baseOffset|Int|本组数据在缓冲区中的起始偏移（字节）|
|output|Array<UInt32>|输出 4 个 UInt32 值的数组（长度须为 4）|

返回: 

- 读取的字节数

### func decodeStream\(Array<UInt8>,Int\)
```cj
public static func decodeStream(data: Array < UInt8 >, count: Int): Array < UInt32 >
```
解码 UInt32 流

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|编码后的字节数组|
|count|Int|预期解码的 UInt32 值数量（须为 4 的倍数）|

返回: 

- 解码后的 UInt32 数组

### func encodeGroup\(Array<UInt32>,Array<UInt8>\)
```cj
public static func encodeGroup(input: Array < UInt32 >, output: Array < UInt8 >): Int
```
编码 4 个 UInt32 值到缓冲区

参数: 

|名称|类型|描述|
|---|---|---|
|input|Array<UInt32>|4 个 UInt32 值的数组（长度须为 4）|
|output|Array<UInt8>|输出字节缓冲区（需至少 17 字节）|

返回: 

- 写入的字节数

### func encodeStream\(Array<UInt32>\)
```cj
public static func encodeStream(stream: Array < UInt32 >): Array < UInt8 >
```
编码 UInt32 流（输入大小须为 4 的倍数）

参数: 

|名称|类型|描述|
|---|---|---|
|stream|Array<UInt32>|输入 UInt32 数组（长度须为 4 的倍数）|

返回: 

- 编码后的字节数组

### func worstBufferSize\(Int\)
```cj
public static func worstBufferSize(count: Int): Int
```
计算最坏情况下的缓冲区大小

参数: 

|名称|类型|描述|
|---|---|---|
|count|Int|UInt32 值的数量|

返回: 

- 最大所需字节数

