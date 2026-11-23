# Struct
## struct GfxProgramHandle
```cj
public struct GfxProgramHandle <: Equatable < GfxProgramHandle >
```
Shader program handle (linked vertex + fragment shader)

### func \!=\(GfxProgramHandle\)
```cj
public operator func !=(other: GfxProgramHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxProgramHandle||

### func ==\(GfxProgramHandle\)
```cj
public operator func ==(other: GfxProgramHandle): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|GfxProgramHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether this handle is valid

### let INVALID
```cj
public static let INVALID = GfxProgramHandle(0xFFFFu16)
```
The invalid-handle constant

