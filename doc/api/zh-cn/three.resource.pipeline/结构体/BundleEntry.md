# 结构体
## struct BundleEntry
```cj
public struct BundleEntry
```
资源包档案头中单条资源的索引信息

### func init\(String,UInt32,UInt32,UInt32\)
```cj
public init(name: String, offset: UInt32, size: UInt32, crc32: UInt32)
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|offset|UInt32||
|size|UInt32||
|crc32|UInt32||

### var crc32
```cj
public var crc32: UInt32
```
数据 CRC32 校验值

### var name
```cj
public var name: String
```
资源名（打包时的 key，通常为相对路径）

### var offset
```cj
public var offset: UInt32
```
数据区相对偏移（字节）

### var size
```cj
public var size: UInt32
```
数据字节数

