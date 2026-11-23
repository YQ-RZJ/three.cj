# 结构体
## struct GfxTextureHandle
```cj
public struct GfxTextureHandle <: Equatable < GfxTextureHandle >
```
纹理句柄

### func \!=\(GfxTextureHandle\)
```cj
public operator func !=(other: GfxTextureHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxTextureHandle||

### func ==\(GfxTextureHandle\)
```cj
public operator func ==(other: GfxTextureHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxTextureHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxTextureHandle(0xFFFFu16)
```
无效句柄常量

