# Struct
## struct GfxDynamicIndexBufferHandle
```cj
public struct GfxDynamicIndexBufferHandle <: Equatable < GfxDynamicIndexBufferHandle >
```
Dynamic index buffer handle

### func \!=\(GfxDynamicIndexBufferHandle\)
```cj
public operator func !=(other: GfxDynamicIndexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxDynamicIndexBufferHandle||

### func ==\(GfxDynamicIndexBufferHandle\)
```cj
public operator func ==(other: GfxDynamicIndexBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxDynamicIndexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxDynamicIndexBufferHandle(0xFFFFu16)
```
The invalid-handle constant

