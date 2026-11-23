# 结构体
## struct GfxProgramHandle
```cj
public struct GfxProgramHandle <: Equatable < GfxProgramHandle >
```
着色器程序句柄（顶点+片段着色器链接产物）

### func \!=\(GfxProgramHandle\)
```cj
public operator func !=(other: GfxProgramHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxProgramHandle||

### func ==\(GfxProgramHandle\)
```cj
public operator func ==(other: GfxProgramHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxProgramHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxProgramHandle(0xFFFFu16)
```
无效句柄常量

