# Struct
## struct GfxDynamicVertexBufferHandle
```cj
public struct GfxDynamicVertexBufferHandle <: Equatable < GfxDynamicVertexBufferHandle >
```
Dynamic vertex buffer handle

### func \!=\(GfxDynamicVertexBufferHandle\)
```cj
public operator func !=(other: GfxDynamicVertexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxDynamicVertexBufferHandle||

### func ==\(GfxDynamicVertexBufferHandle\)
```cj
public operator func ==(other: GfxDynamicVertexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxDynamicVertexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxDynamicVertexBufferHandle(0xFFFFu16)
```
The invalid-handle constant

