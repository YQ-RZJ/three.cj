# 类
## class BgfxRenderLists
```cj
public class BgfxRenderLists <: IReleasable
```
bgfx 渲染列表管理

### func get\(Int64\)
```cj
public func get(sceneId: Int64): BgfxRenderList
```
获取渲染列表

参数: 

|名称|类型|描述|
|---|---|---|
|sceneId|Int64|场景 ID|

返回: 

- 渲染列表

### func init\(\)
```cj
public init()
```


### func release\(\)
```cj
public func release(): Bool
```
释放所有渲染列表

