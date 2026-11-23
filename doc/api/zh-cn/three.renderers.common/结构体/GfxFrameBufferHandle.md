# 结构体
## struct GfxFrameBufferHandle
```cj
public struct GfxFrameBufferHandle <: Equatable < GfxFrameBufferHandle >
```
帧缓冲句柄

### func \!=\(GfxFrameBufferHandle\)
```cj
public operator func !=(other: GfxFrameBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxFrameBufferHandle||

### func ==\(GfxFrameBufferHandle\)
```cj
public operator func ==(other: GfxFrameBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxFrameBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxFrameBufferHandle(0xFFFFu16)
```
无效句柄常量

