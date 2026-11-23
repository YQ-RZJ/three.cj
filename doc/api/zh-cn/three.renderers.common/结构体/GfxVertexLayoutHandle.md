# 结构体
## struct GfxVertexLayoutHandle
```cj
public struct GfxVertexLayoutHandle <: Equatable < GfxVertexLayoutHandle >
```
顶点布局句柄

### func \!=\(GfxVertexLayoutHandle\)
```cj
public operator func !=(other: GfxVertexLayoutHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxVertexLayoutHandle||

### func ==\(GfxVertexLayoutHandle\)
```cj
public operator func ==(other: GfxVertexLayoutHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxVertexLayoutHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxVertexLayoutHandle(0xFFFFu16)
```
无效句柄常量

