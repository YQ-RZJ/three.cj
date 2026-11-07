# Class
## class BgfxRenderLists
```cj
public class BgfxRenderLists <: IReleasable
```
bgfx render list management

### func get\(Int64\)
```cj
public func get(sceneId: Int64): BgfxRenderList
```
Gets render list

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sceneId|Int64|Scene ID|

Return: 

- Render list

### func init\(\)
```cj
public init()
```


### func release\(\)
```cj
public func release(): Bool
```
dispose all render lists

