# Struct
## struct GfxOcclusionQueryHandle
```cj
public struct GfxOcclusionQueryHandle <: Equatable < GfxOcclusionQueryHandle >
```
Occlusion query handle

### func \!=\(GfxOcclusionQueryHandle\)
```cj
public operator func !=(other: GfxOcclusionQueryHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxOcclusionQueryHandle||

### func ==\(GfxOcclusionQueryHandle\)
```cj
public operator func ==(other: GfxOcclusionQueryHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxOcclusionQueryHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxOcclusionQueryHandle(0xFFFFu16)
```
The invalid-handle constant

