# Class
## class Crc32
```cj
public class Crc32
```
CRC32 (IEEE 802.3, polynomial 0xEDB88320)

### func update\(UInt32,UInt8\)
```cj
public static func update(crc: UInt32, byte: UInt8): UInt32
```
Feeds one byte into the checksum

Parameter: 

|Name|Type|Describe|
|---|---|---|
|crc|UInt32|Current checksum (start with 0)byte Byte to append|
|byte|UInt8||

Return: 

- Updated checksum

