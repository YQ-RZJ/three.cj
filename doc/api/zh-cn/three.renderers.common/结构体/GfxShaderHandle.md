# 结构体
## struct GfxShaderHandle
```cj
public struct GfxShaderHandle <: Equatable < GfxShaderHandle >
```
着色器句柄

### func \!=\(GfxShaderHandle\)
```cj
public operator func !=(other: GfxShaderHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxShaderHandle||

### func ==\(GfxShaderHandle\)
```cj
public operator func ==(other: GfxShaderHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxShaderHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxShaderHandle(0xFFFFu16)
```
无效句柄常量

