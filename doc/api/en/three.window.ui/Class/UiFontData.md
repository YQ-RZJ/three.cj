# Class
## class UiFontData
```cj
public class UiFontData
```
Safe wrapper for in-memory font data (TTF/OTF binary)

### func finalize\(\)
```cj
public func finalize(): Unit
```
Frees the heap memory (no-op when ownership was transferred to the atlas)

### func init\(Array<UInt8>\)
```cj
public init(bytes: Array < UInt8 >)
```
Constructs from a byte array (copied into contiguous LibC heap memory)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bytes|Array<UInt8>|Raw font file bytes|

