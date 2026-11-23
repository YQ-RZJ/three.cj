# 结构体
## struct GfxIndexBufferHandle
```cj
public struct GfxIndexBufferHandle <: Equatable < GfxIndexBufferHandle >
```
静态索引缓冲句柄

### func \!=\(GfxIndexBufferHandle\)
```cj
public operator func !=(other: GfxIndexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxIndexBufferHandle||

### func ==\(GfxIndexBufferHandle\)
```cj
public operator func ==(other: GfxIndexBufferHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxIndexBufferHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxIndexBufferHandle(0xFFFFu16)
```
无效句柄常量

