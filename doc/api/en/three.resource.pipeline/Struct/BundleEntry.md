# Struct
## struct BundleEntry
```cj
public struct BundleEntry
```
Index info of a single entry in the bundle archive header

### func init\(String,UInt32,UInt32,UInt32\)
```cj
public init(name: String, offset: UInt32, size: UInt32, crc32: UInt32)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|offset|UInt32||
|size|UInt32||
|crc32|UInt32||

### var crc32
```cj
public var crc32: UInt32
```
CRC32 checksum of the data

### var name
```cj
public var name: String
```
Entry name (the packing key, usually a relative path)

### var offset
```cj
public var offset: UInt32
```
Offset relative to the data section (bytes)

### var size
```cj
public var size: UInt32
```
Data size in bytes

