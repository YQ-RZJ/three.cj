# Struct
## struct GfxShaderHandle
```cj
public struct GfxShaderHandle <: Equatable < GfxShaderHandle >
```
Shader handle

### func \!=\(GfxShaderHandle\)
```cj
public operator func !=(other: GfxShaderHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxShaderHandle||

### func ==\(GfxShaderHandle\)
```cj
public operator func ==(other: GfxShaderHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxShaderHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxShaderHandle(0xFFFFu16)
```
The invalid-handle constant

