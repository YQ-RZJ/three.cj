# 类
## class Crc32
```cj
public class Crc32
```
CRC32（IEEE 802.3，多项式 0xEDB88320）

### func update\(UInt32,UInt8\)
```cj
public static func update(crc: UInt32, byte: UInt8): UInt32
```
追加一个字节到校验值

参数: 

|名称|类型|描述|
|---|---|---|
|crc|UInt32|当前校验值（首个字节传 0）byte 追加的字节|
|byte|UInt8||

返回: 

- 更新后的校验值

