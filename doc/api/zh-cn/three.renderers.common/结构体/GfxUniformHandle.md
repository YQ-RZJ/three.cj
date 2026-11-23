# 结构体
## struct GfxUniformHandle
```cj
public struct GfxUniformHandle <: Equatable < GfxUniformHandle >
```
uniform 句柄

### func \!=\(GfxUniformHandle\)
```cj
public operator func !=(other: GfxUniformHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxUniformHandle||

### func ==\(GfxUniformHandle\)
```cj
public operator func ==(other: GfxUniformHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxUniformHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxUniformHandle(0xFFFFu16)
```
无效句柄常量

