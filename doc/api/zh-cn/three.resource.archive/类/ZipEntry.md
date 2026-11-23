# 类
## class ZipEntry
```cj
public class ZipEntry
```
ZIP 条目元信息（来自中央目录）

### func init\(String,Bool,Int64,Int64,UInt32,UInt16,UInt16,Int64\)
```cj
public init(name: String, isDirectory: Bool, compressedSize: Int64, uncompressedSize: Int64, crc32: UInt32, method: UInt16, flags: UInt16, localOffset: Int64)
```
创建条目元信息

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|条目路径（ZIP 内部相对路径，'/' 分隔）|
|isDirectory|Bool|是否目录条目（名称以 '/' 结尾）|
|compressedSize|Int64|压缩后字节大小|
|uncompressedSize|Int64|解压后字节大小|
|crc32|UInt32|解压后数据的 CRC32（中央目录登记值）|
|method|UInt16|压缩方法（0=stored，8=deflate）|
|flags|UInt16|通用标志位（bit0=加密）|
|localOffset|Int64|本地文件头在归档中的偏移|

### let compressedSize
```cj
public let compressedSize: Int64
```
压缩后字节大小

### let crc32
```cj
public let crc32: UInt32
```
解压后数据的 CRC32（中央目录登记值）

### let flags
```cj
public let flags: UInt16
```
通用标志位（bit0=加密）

### let isDirectory
```cj
public let isDirectory: Bool
```
是否目录条目（名称以 '/' 结尾）

### let method
```cj
public let method: UInt16
```
压缩方法（0=stored，8=deflate）

### let name
```cj
public let name: String
```
条目路径（ZIP 内部相对路径，'/' 分隔）

### let uncompressedSize
```cj
public let uncompressedSize: Int64
```
解压后字节大小

