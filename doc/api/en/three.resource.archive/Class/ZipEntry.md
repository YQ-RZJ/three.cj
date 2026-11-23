# Class
## class ZipEntry
```cj
public class ZipEntry
```
ZIP entry metadata (from the central directory)

### func init\(String,Bool,Int64,Int64,UInt32,UInt16,UInt16,Int64\)
```cj
public init(name: String, isDirectory: Bool, compressedSize: Int64, uncompressedSize: Int64, crc32: UInt32, method: UInt16, flags: UInt16, localOffset: Int64)
```
Creates entry metadata

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Entry path inside the archive (relative, '/' separated)|
|isDirectory|Bool|Whether this is a directory entry (name ends with '/')|
|compressedSize|Int64|Compressed size in bytes|
|uncompressedSize|Int64|Uncompressed size in bytes|
|crc32|UInt32|CRC32 of the uncompressed data (as recorded in the central directory)|
|method|UInt16|Compression method (0=stored, 8=deflate)|
|flags|UInt16|General purpose flags (bit0 = encrypted)|
|localOffset|Int64|Local header offset inside the archive|

### let compressedSize
```cj
public let compressedSize: Int64
```
Compressed size in bytes

### let crc32
```cj
public let crc32: UInt32
```
CRC32 of the uncompressed data (as recorded in the central directory)

### let flags
```cj
public let flags: UInt16
```
General purpose flags (bit0 = encrypted)

### let isDirectory
```cj
public let isDirectory: Bool
```
Whether this is a directory entry (name ends with '/')

### let method
```cj
public let method: UInt16
```
Compression method (0=stored, 8=deflate)

### let name
```cj
public let name: String
```
Entry path inside the archive (relative, '/' separated)

### let uncompressedSize
```cj
public let uncompressedSize: Int64
```
Uncompressed size in bytes

