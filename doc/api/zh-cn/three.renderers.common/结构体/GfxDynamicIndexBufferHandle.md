# 结构体
## struct GfxDynamicIndexBufferHandle
```cj
public struct GfxDynamicIndexBufferHandle <: Equatable < GfxDynamicIndexBufferHandle >
```
动态索引缓冲句柄

### func \!=\(GfxDynamicIndexBufferHandle\)
```cj
public operator func !=(other: GfxDynamicIndexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxDynamicIndexBufferHandle||

### func ==\(GfxDynamicIndexBufferHandle\)
```cj
public operator func ==(other: GfxDynamicIndexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxDynamicIndexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxDynamicIndexBufferHandle(0xFFFFu16)
```
无效句柄常量

