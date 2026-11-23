# 结构体
## struct GfxDynamicVertexBufferHandle
```cj
public struct GfxDynamicVertexBufferHandle <: Equatable < GfxDynamicVertexBufferHandle >
```
动态顶点缓冲句柄

### func \!=\(GfxDynamicVertexBufferHandle\)
```cj
public operator func !=(other: GfxDynamicVertexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxDynamicVertexBufferHandle||

### func ==\(GfxDynamicVertexBufferHandle\)
```cj
public operator func ==(other: GfxDynamicVertexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxDynamicVertexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxDynamicVertexBufferHandle(0xFFFFu16)
```
无效句柄常量

