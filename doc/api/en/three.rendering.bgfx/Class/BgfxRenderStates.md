# Class
## class BgfxRenderStates
```cj
public class BgfxRenderStates <: IReleasable
```
bgfx render state management

### func get\(Int64\)
```cj
public func get(sceneId: Int64): BgfxRenderState
```
Get render state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sceneId|Int64|Scene ID|

Return: 

- Render state

### func init\(\)
```cj
public init()
```


### func release\(\)
```cj
public func release(): Bool
```
dispose all render states

