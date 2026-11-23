# Struct
## struct GfxIndirectBufferHandle
```cj
public struct GfxIndirectBufferHandle <: Equatable < GfxIndirectBufferHandle >
```
Indirect buffer handle

### func \!=\(GfxIndirectBufferHandle\)
```cj
public operator func !=(other: GfxIndirectBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxIndirectBufferHandle||

### func ==\(GfxIndirectBufferHandle\)
```cj
public operator func ==(other: GfxIndirectBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxIndirectBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxIndirectBufferHandle(0xFFFFu16)
```
The invalid-handle constant

