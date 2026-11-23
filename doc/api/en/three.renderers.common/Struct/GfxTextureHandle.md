# Struct
## struct GfxTextureHandle
```cj
public struct GfxTextureHandle <: Equatable < GfxTextureHandle >
```
Texture handle

### func \!=\(GfxTextureHandle\)
```cj
public operator func !=(other: GfxTextureHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxTextureHandle||

### func ==\(GfxTextureHandle\)
```cj
public operator func ==(other: GfxTextureHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxTextureHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxTextureHandle(0xFFFFu16)
```
The invalid-handle constant

