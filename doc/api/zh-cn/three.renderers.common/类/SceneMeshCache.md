# 类
## class SceneMeshCache
```cj
public class SceneMeshCache
```
帧级场景网格缓存

### func get\(Object3D,Int64,Bool\)
```cj
public func get(scene: Object3D, frame: Int64, visibleOnly!: Bool = false): ArrayList < RenderObject >
```
获取本帧场景中的 Mesh 渲染对象列表

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Object3D|场景根节点frame 帧号（由 Renderer 维护，每帧自增）|
|frame|Int64||
|visibleOnly|Bool||

返回: 

- Mesh 渲染对象列表（内部引用，调用方只读）

### func init\(\)
```cj
public init()
```
构造空的场景网格缓存

