# Class
## class BgfxAttributeDesc
```cj
public class BgfxAttributeDesc
```
Vertex attribute descriptor

### func init\(\)
```cj
public init()
```


### var asInt
```cj
public var asInt: Bool = false
```
Whether the attribute is integer

### var attribType
```cj
public var attribType: UInt32 = 0u32
```
Attribute data type

### var attrib
```cj
public var attrib: UInt32 = 0u32
```
Attribute semantics (POSITION, NORMAL, TEXCOORD0, etc.)

### var name
```cj
public var name: String = ""
```
Attribute name

### var normalized
```cj
public var normalized: Bool = false
```
Whether the attribute is normalized

### var num
```cj
public var num: UInt8 = 4u8
```
Number of attribute components (1-4)

