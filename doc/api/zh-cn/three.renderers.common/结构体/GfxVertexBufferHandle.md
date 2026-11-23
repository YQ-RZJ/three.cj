# 结构体
## struct GfxVertexBufferHandle
```cj
public struct GfxVertexBufferHandle <: Equatable < GfxVertexBufferHandle >
```
静态顶点缓冲句柄

### func \!=\(GfxVertexBufferHandle\)
```cj
public operator func !=(other: GfxVertexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxVertexBufferHandle||

### func ==\(GfxVertexBufferHandle\)
```cj
public operator func ==(other: GfxVertexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxVertexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxVertexBufferHandle(0xFFFFu16)
```
无效句柄常量

