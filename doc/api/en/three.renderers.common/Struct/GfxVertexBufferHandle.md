# Struct
## struct GfxVertexBufferHandle
```cj
public struct GfxVertexBufferHandle <: Equatable < GfxVertexBufferHandle >
```
Static vertex buffer handle

### func \!=\(GfxVertexBufferHandle\)
```cj
public operator func !=(other: GfxVertexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxVertexBufferHandle||

### func ==\(GfxVertexBufferHandle\)
```cj
public operator func ==(other: GfxVertexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxVertexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxVertexBufferHandle(0xFFFFu16)
```
The invalid-handle constant

