# Struct
## struct GfxFrameBufferHandle
```cj
public struct GfxFrameBufferHandle <: Equatable < GfxFrameBufferHandle >
```
Frame buffer handle

### func \!=\(GfxFrameBufferHandle\)
```cj
public operator func !=(other: GfxFrameBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxFrameBufferHandle||

### func ==\(GfxFrameBufferHandle\)
```cj
public operator func ==(other: GfxFrameBufferHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxFrameBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxFrameBufferHandle(0xFFFFu16)
```
The invalid-handle constant

