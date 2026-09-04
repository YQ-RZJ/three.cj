# 类
## class RenderObject
```cj
public open class RenderObject <: IRenderObject
```
渲染对象

### func getGeometryId\(\)
```cj
public func getGeometryId(): Int64
```
返回几何体 ID

返回: 

- 几何体哈希 ID

### func getGroupOrder\(\)
```cj
public func getGroupOrder(): Float64
```
返回组顺序

返回: 

- 组顺序值

### func getHash\(\)
```cj
public func getHash(): Int64
```
返回渲染对象哈希（用于去重缓存）

返回: 

- 渲染对象哈希值

### func getMaterialId\(\)
```cj
public func getMaterialId(): Int64
```
返回材质 ID

返回: 

- 材质哈希 ID

### func getMatrix\(\)
```cj
public func getMatrix(): Array < Float64 >
```
返回 world matrix（16 个 Float64 列主序）

返回: 

- 世界矩阵元素数组

### func getNodeChain\(\)
```cj
public func getNodeChain(): ArrayList < Object3D >
```
返回节点链

返回: 

- 节点链列表

### func getObjectId\(\)
```cj
public func getObjectId(): Int64
```
返回对象 ID

返回: 

- 对象 ID

### func getRenderOrder\(\)
```cj
public func getRenderOrder(): Float64
```
返回渲染顺序

返回: 

- 渲染顺序值

### func init\(Int64,Object3D,BufferGeometry,Material,RenderContext,Camera,Scene\)
```cj
public init(id: Int64, `object`: Object3D, geometry: BufferGeometry, material: Material, context: RenderContext, camera: Camera, scene: Scene)
```
完整构造器

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|唯一标识object 渲染对象geometry 几何体material 材质context 渲染上下文camera 相机scene 场景|
|`object`|Object3D||
|geometry|BufferGeometry||
|material|Material||
|context|RenderContext||
|camera|Camera||
|scene|Scene||

### func init\(Int64,Object3D,BufferGeometry,Material,Matrix4\)
```cj
public init(id: Int64, mesh: Object3D, geometry: BufferGeometry, material: Material, worldMatrix: Matrix4)
```
简化构造器（兼容旧式调用），不传 context/camera/scene 时使用默认值

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|唯一标识mesh 渲染对象geometry 几何体material 材质worldMatrix 世界矩阵（仅用于提取 position）|
|mesh|Object3D||
|geometry|BufferGeometry||
|material|Material||
|worldMatrix|Matrix4||

### func onAdd\(\)
```cj
public func onAdd(): Unit
```
添加到渲染器时调用

### func onDispose\(\)
```cj
public func onDispose(): Unit
```
释放时调用

### func onRemove\(\)
```cj
public func onRemove(): Unit
```
从渲染器移除时调用

### func onUpdate\(\)
```cj
public func onUpdate(): Unit
```
属性更新时调用

### func updateWorldMatrix\(\)
```cj
public func updateWorldMatrix(): Unit
```
更新变换矩阵，从根节点逐级计算 world matrix

### var \`object\`
```cj
public var `object`: Object3D
```
渲染对象（Mesh/Line/Points 等 Object3D 子类）

### var bindings
```cj
public var bindings: ArrayList < Binding >= ArrayList < Binding >()
```
绑定组列表

### var camera
```cj
public var camera: Camera
```
相机

### var context
```cj
public var context: RenderContext
```
渲染上下文

### var geometry
```cj
public var geometry: BufferGeometry
```
几何体

### var groupOrder
```cj
public var groupOrder: Float64 = 0.0
```
组顺序

### var id
```cj
public var id: Int64
```
唯一标识

### var initialized
```cj
public var initialized: Bool = false
```
是否已初始化

### var material
```cj
public var material: Material
```
材质

### var mesh
```cj
public var mesh: Object3D
```
mesh 别名（兼容 BgfxRenderer 中 ro.mesh 访问）

### var modelViewMatrix
```cj
public var modelViewMatrix: Matrix4 = Matrix4()
```
模型视图矩阵

### var nodeChain
```cj
public var nodeChain: ArrayList < Object3D >= ArrayList < Object3D >()
```
节点链（用于变换层级遍历）

### var normalMatrix
```cj
public var normalMatrix: Matrix3 = Matrix3()
```
法线矩阵

### var position
```cj
public var position: Vector3 = Vector3()
```
位置（从 worldMatrix 提取，用于排序/遮挡查询）

### var renderOrder
```cj
public var renderOrder: Float64 = 0.0
```
渲染顺序

### var scene
```cj
public var scene: Scene
```
场景

### var sortKey
```cj
public var sortKey: Float64 = 0.0
```
排序键（用于透明对象排序）

### var worldMatrix
```cj
public var worldMatrix: Matrix4 = Matrix4()
```
世界矩阵（对象到世界空间）

### var z
```cj
public var z: Float64 = 0.0
```
深度值（相机空间 z，用于排序）

