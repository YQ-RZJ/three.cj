# 结构体
## struct GfxOcclusionQueryHandle
```cj
public struct GfxOcclusionQueryHandle <: Equatable < GfxOcclusionQueryHandle >
```
遮挡查询句柄

### func \!=\(GfxOcclusionQueryHandle\)
```cj
public operator func !=(other: GfxOcclusionQueryHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxOcclusionQueryHandle||

### func ==\(GfxOcclusionQueryHandle\)
```cj
public operator func ==(other: GfxOcclusionQueryHandle): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|GfxOcclusionQueryHandle||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否为有效句柄

### let INVALID
```cj
public static let INVALID = GfxOcclusionQueryHandle(0xFFFFu16)
```
无效句柄常量

