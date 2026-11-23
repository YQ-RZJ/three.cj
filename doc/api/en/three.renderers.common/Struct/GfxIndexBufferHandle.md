# Struct
## struct GfxIndexBufferHandle
```cj
public struct GfxIndexBufferHandle <: Equatable < GfxIndexBufferHandle >
```
Static index buffer handle

### func \!=\(GfxIndexBufferHandle\)
```cj
public operator func !=(other: GfxIndexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxIndexBufferHandle||

### func ==\(GfxIndexBufferHandle\)
```cj
public operator func ==(other: GfxIndexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxIndexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxIndexBufferHandle(0xFFFFu16)
```
The invalid-handle constant

