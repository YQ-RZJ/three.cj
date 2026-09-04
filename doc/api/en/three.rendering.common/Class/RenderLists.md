# Class
## class RenderLists
```cj
public open class RenderLists
```
Render list cache manager

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all render lists

### func get\(Scene,Camera\)
```cj
public func get(scene: Scene, camera: Camera): RenderList
```
Gets or creates the RenderList for the given (scene, camera)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scenecamera Camera|
|camera|Camera||

Return: 

- RenderList instance

### func init\(\)
```cj
public init()
```
Constructs a default render list cache

