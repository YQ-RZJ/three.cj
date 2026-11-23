# Struct
## struct GfxUniformHandle
```cj
public struct GfxUniformHandle <: Equatable < GfxUniformHandle >
```
Uniform handle

### func \!=\(GfxUniformHandle\)
```cj
public operator func !=(other: GfxUniformHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxUniformHandle||

### func ==\(GfxUniformHandle\)
```cj
public operator func ==(other: GfxUniformHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxUniformHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxUniformHandle(0xFFFFu16)
```
The invalid-handle constant

