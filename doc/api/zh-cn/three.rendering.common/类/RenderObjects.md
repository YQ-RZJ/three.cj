# 类
## class RenderObjects
```cj
public open class RenderObjects
```
渲染对象缓存管理器

### func clear\(\)
```cj
public func clear(): Unit
```
清空所有缓存

### func get\(Object3D,BufferGeometry,Material,RenderContext,Camera,Scene\)
```cj
public func get(mesh: Object3D, geometry: BufferGeometry, material: Material, context: RenderContext, camera: Camera, scene: Scene): RenderObject
```
获取或创建 (object, material, camera) 对应的 RenderObject

参数: 

|名称|类型|描述|
|---|---|---|
|mesh|Object3D|渲染对象geometry 几何体material 材质context 渲染上下文camera 相机scene 场景|
|geometry|BufferGeometry||
|material|Material||
|context|RenderContext||
|camera|Camera||
|scene|Scene||

返回: 

- RenderObject 实例

### func init\(\)
```cj
public init()
```
构造默认渲染对象缓存

