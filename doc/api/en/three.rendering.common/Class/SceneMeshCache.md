# Class
## class SceneMeshCache
```cj
public class SceneMeshCache
```
Frame-level scene mesh cache

### func get\(Object3D,Int64,Bool\)
```cj
public func get(scene: Object3D, frame: Int64, visibleOnly!: Bool = false): ArrayList < RenderObject >
```
Get this frame's list of Mesh render objects

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Object3D|Scene root nodeframe Frame index (maintained by the Renderer, incremented every frame)|
|frame|Int64||
|visibleOnly|Bool||

Return: 

- Mesh render object list (internal reference, read-only for callers)

### func init\(\)
```cj
public init()
```
Constructs an empty scene mesh cache

