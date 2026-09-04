# Class
## class RenderContexts
```cj
public open class RenderContexts
```
Render context cache manager

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all contexts

### func get\(Scene,Camera\)
```cj
public func get(scene: Scene, camera: Camera): RenderContext
```
Gets or creates the RenderContext for the given (scene, camera)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene|Scenecamera Camera|
|camera|Camera||

Return: 

- RenderContext instance

### func init\(\)
```cj
public init()
```
Constructs a default render context cache

