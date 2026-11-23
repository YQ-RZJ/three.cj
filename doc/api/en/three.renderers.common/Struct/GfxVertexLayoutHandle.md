# Struct
## struct GfxVertexLayoutHandle
```cj
public struct GfxVertexLayoutHandle <: Equatable < GfxVertexLayoutHandle >
```
Vertex layout handle

### func \!=\(GfxVertexLayoutHandle\)
```cj
public operator func !=(other: GfxVertexLayoutHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxVertexLayoutHandle||

### func ==\(GfxVertexLayoutHandle\)
```cj
public operator func ==(other: GfxVertexLayoutHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxVertexLayoutHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxVertexLayoutHandle(0xFFFFu16)
```
The invalid-handle constant

