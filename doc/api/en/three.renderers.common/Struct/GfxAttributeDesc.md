# Struct
## struct GfxAttributeDesc
```cj
public struct GfxAttributeDesc
```
Vertex layout attribute descriptor

### func init\(GfxAttrib,UInt8,GfxAttribType,Bool,Bool\)
```cj
public init(attrib: GfxAttrib, num: UInt8, attribType: GfxAttribType, normalized!: Bool = false, asInt!: Bool = false)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|attrib|GfxAttrib||
|num|UInt8||
|attribType|GfxAttribType||
|normalized|Bool||
|asInt|Bool||

### let asInt
```cj
public let asInt: Bool
```
是否按整数解释（不过归一化）

### let attribType
```cj
public let attribType: GfxAttribType
```
分量存储类型

### let attrib
```cj
public let attrib: GfxAttrib
```
属性语义槽位

### let normalized
```cj
public let normalized: Bool
```
是否归一化到 [0,1] / [-1,1]

### let num
```cj
public let num: UInt8
```
分量数量（1-4）

