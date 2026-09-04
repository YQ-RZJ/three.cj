# Class
## class Object3D
```cj
public open class Object3D <: EventDispatcher & IFrustumCullable & IBox3Expandable & ILoadResult & IPropertyBindingRoot
```
3D object base class, parent of all scene objects

### func ==\(Object3D\)
```cj
public operator func ==(other: Object3D): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|Object3D||

### func add\(Object3D\)
```cj
public open func add(child: Object3D): Object3D
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|child|Object3D||

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|matrix|Matrix4||

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion||

### func attach\(Object3D\)
```cj
public func attach(object: Object3D): Object3D
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D||

### func clear\(\)
```cj
public func clear(): Unit
```


### func clone\(\)
```cj
public open func clone(): Object3D
```


### func copy\(Object3D,Bool\)
```cj
public open func copy(source: Object3D, recursive: Bool): Object3D
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D||
|recursive|Bool||

### func getChildAt\(Int64\)
```cj
public func getChildAt(i: Int64): IBox3Expandable
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Child object index|

Return: 

- Child object (Object3D implements IBox3Expandable)第 i 个子对象

### func getChildCount\(\)
```cj
public func getChildCount(): Int64
```


Return: 

- Number of child objects子对象数量

### func getObjectById\(Int64\)
```cj
public func getObjectById(id: Int64): Option < Object3D >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64||

### func getObjectByName\(String\)
```cj
public func getObjectByName(name: String): Option < Object3D >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func getObjectsByProperty\(String,Any,ArrayList<Object3D>\)
```cj
public func getObjectsByProperty(name: String, value: Any, result: ArrayList < Object3D >): ArrayList < Object3D >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|value|Any||
|result|ArrayList<Object3D>||

### func getPreciseVertexCount\(\)
```cj
public open func getPreciseVertexCount(): Int64
```


Return: 

- Vertex count (0 means precise traversal is not supported)精确模式逐顶点遍历的顶点数open：允许 Mesh 覆写（排除 InstancedMesh）返回 position 属性顶点数；无几何体/无 position 属性返回 0

### func getPreciseVertexPosition\(Int64\)
```cj
public open func getPreciseVertexPosition(i: Int64): Array < Float64 >
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Vertex index|

Return: 

- World-space coordinates [x, y, z]第 i 个顶点的世界空间位置基类默认直接读 position 属性（无 morph/skin）；Mesh 覆写以应用蒙皮/变形

### func getProperty\(String\)
```cj
public func getProperty(name: String): Any
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func getUuid\(\)
```cj
public func getUuid(): String
```
IPropertyBindingRoot 接口实现（2026-08-20）：供 PropertyBinding 以接口持有节点引用

### func getWorldBoundingBox\(\)
```cj
public func getWorldBoundingBox(): Option <(Array < Float64 >, Array < Float64 >) >
```


Return: 

- Some(([minX,minY,minZ], [maxX,maxY,maxZ])) or None (no geometry)计算对象自身（不含子对象）的世界空间包围盒

### func getWorldBoundingSphere\(\)
```cj
public open func getWorldBoundingSphere(): Option < Array < Float64 >>
```


Return: 

- Some([cx, cy, cz, radius]) or None (no geometry)计算对象的世界空间包围球open：允许 Sprite 等子类覆写特殊包围球计算

### func getWorldDirection\(Vector3\)
```cj
public open func getWorldDirection(target: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3||

### func getWorldPosition\(Vector3\)
```cj
public func getWorldPosition(target: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3||

### func getWorldQuaternion\(Quaternion\)
```cj
public func getWorldQuaternion(target: Quaternion): Quaternion
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Quaternion||

### func getWorldScale\(Vector3\)
```cj
public func getWorldScale(target: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3||

### func init\(\)
```cj
public init()
```


### func localToWorld\(Vector3\)
```cj
public func localToWorld(vector: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|vector|Vector3||

### func lookAt\(Vector3\)
```cj
public func lookAt(target: Vector3): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|target|Vector3||

### func onAfterRender\(\)
```cj
public func onAfterRender(): Unit
```


### func onAfterShadow\(\)
```cj
public func onAfterShadow(): Unit
```


### func onBeforeRender\(\)
```cj
public func onBeforeRender(): Unit
```


### func onBeforeShadow\(\)
```cj
public func onBeforeShadow(): Unit
```


### func raycast\(Raycaster,ArrayList<Intersection>\)
```cj
public open func raycast(raycaster: Raycaster, intersects: ArrayList < Intersection >): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|raycaster|Raycaster||
|intersects|ArrayList<Intersection>||

### func removeFromParent\(\)
```cj
public func removeFromParent(): Unit
```


### func remove\(Object3D\)
```cj
public open func remove(child: Object3D): Object3D
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|child|Object3D||

### func rotateOnAxis\(Vector3,Float64\)
```cj
public func rotateOnAxis(axis: Vector3, angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func rotateOnWorldAxis\(Vector3,Float64\)
```cj
public func rotateOnWorldAxis(axis: Vector3, angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func rotateX\(Float64\)
```cj
public func rotateX(angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64||

### func rotateY\(Float64\)
```cj
public func rotateY(angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64||

### func rotateZ\(Float64\)
```cj
public func rotateZ(angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|angle|Float64||

### func setRotationFromAxisAngle\(Vector3,Float64\)
```cj
public func setRotationFromAxisAngle(axis: Vector3, angle: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func setRotationFromEuler\(Euler\)
```cj
public func setRotationFromEuler(euler: Euler): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|euler|Euler||

### func setRotationFromMatrix\(Matrix4\)
```cj
public func setRotationFromMatrix(m: Matrix4): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|m|Matrix4||

### func setRotationFromQuaternion\(Quaternion\)
```cj
public func setRotationFromQuaternion(q: Quaternion): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|q|Quaternion||

### func translateOnAxis\(Vector3,Float64\)
```cj
public func translateOnAxis(axis: Vector3, distance: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|Vector3||
|distance|Float64||

### func translateX\(Float64\)
```cj
public func translateX(distance: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### func translateY\(Float64\)
```cj
public func translateY(distance: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### func translateZ\(Float64\)
```cj
public func translateZ(distance: Float64): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|distance|Float64||

### func traverseAncestors\(\(Object3D\)\->Unit\)
```cj
public func traverseAncestors(callback:(Object3D) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|(Object3D)->Unit||

### func traverseVisible\(\(Object3D\)\->Unit\)
```cj
public func traverseVisible(callback:(Object3D) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|(Object3D)->Unit||

### func traverse\(\(Object3D\)\->Unit\)
```cj
public open func traverse(callback:(Object3D) -> Unit): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|(Object3D)->Unit||

### func updateMatrixWorld\(Bool\)
```cj
public open func updateMatrixWorld(force: Bool): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool||

### func updateMatrix\(\)
```cj
public func updateMatrix(): Unit
```


### func updateWorldMatrix\(Bool,Bool,Bool\)
```cj
public open func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|updateParents|Bool||
|updateChildren|Bool||
|force|Bool||

### func worldToLocal\(Vector3\)
```cj
public func worldToLocal(vector: Vector3): Vector3
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|vector|Vector3||

### prop animationsJson: String
```cj
public open mut prop animationsJson: String
```


### prop customDepthMaterialJson: String
```cj
public open mut prop customDepthMaterialJson: String
```


### prop customDistanceMaterialJson: String
```cj
public open mut prop customDistanceMaterialJson: String
```


### prop userDataJson: String
```cj
public open mut prop userDataJson: String
```


### var animations
```cj
public var animations: ArrayList < IAnimationClip >
```
animations：动画剪辑列表（接口类型 IAnimationClip），通过

### var castShadow
```cj
public var castShadow: Bool
```


### var children
```cj
public var children: ArrayList < Object3D >
```


### var customDepthMaterial
```cj
public var customDepthMaterial: Option < IMaterial >
```
customDepthMaterial/customDistanceMaterial：材质接口类型（IMaterial），通过

### var customDistanceMaterial
```cj
public var customDistanceMaterial: Option < IMaterial >
```


### var frustumCulled
```cj
public var frustumCulled: Bool
```


### var id
```cj
public var id: Int64
```


### var isStatic
```cj
public var isStatic: Bool
```


### var kind
```cj
public var kind: String
```


### var layers
```cj
public var layers: Layers
```


### var matrixAutoUpdate
```cj
public var matrixAutoUpdate: Bool
```


### var matrixWorldAutoUpdate
```cj
public var matrixWorldAutoUpdate: Bool
```


### var matrixWorldNeedsUpdate
```cj
public var matrixWorldNeedsUpdate: Bool
```


### var matrixWorld
```cj
public var matrixWorld: Matrix4
```


### var matrix
```cj
public var matrix: Matrix4
```


### var modelViewMatrix
```cj
public var modelViewMatrix: Matrix4
```


### var name
```cj
public var name: String
```


### var normalMatrix
```cj
public var normalMatrix: Matrix3
```


### var parent
```cj
public var parent: Option < Object3D >
```
parent：与 children 构成循环引用，序列化忽略（与 three.js 一致，由 add/remove 维护）

### var pivot
```cj
public var pivot: Vector3
```


### var position
```cj
public var position: Vector3
```


### var quaternion
```cj
public var quaternion: Quaternion
```


### var receiveShadow
```cj
public var receiveShadow: Bool
```


### var renderOrder
```cj
public var renderOrder: Float64
```


### var rotation
```cj
public var rotation: Euler
```


### var scale
```cj
public var scale: Vector3
```


### var up
```cj
public var up: Vector3
```


### var userData
```cj
public var userData: HashMap < String, Any >
```
通过

### var uuid
```cj
public var uuid: String
```


### var visible
```cj
public var visible: Bool
```


