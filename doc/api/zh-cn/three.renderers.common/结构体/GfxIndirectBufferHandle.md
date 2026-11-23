# 结构体
## struct GfxIndirectBufferHandle
```cj
public struct GfxIndirectBufferHandle <: Equatable < GfxIndirectBufferHandle >
```
间接绘制缓冲句柄

### func \!=\(GfxIndirectBufferHandle\)
```cj
public operator func !=(other: GfxIndirectBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxIndirectBufferHandle||

### func ==\(GfxIndirectBufferHandle\)
```cj
public operator func ==(other: GfxIndirectBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxIndirectBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxIndirectBufferHandle(0xFFFFu16)
```
无效句柄常量

