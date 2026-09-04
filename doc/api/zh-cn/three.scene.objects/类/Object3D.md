# 类
## class Object3D
```cj
public open class Object3D <: EventDispatcher & IFrustumCullable & IBox3Expandable & ILoadResult & IPropertyBindingRoot
```
3D 对象基类，所有场景对象的父类

### func ==\(Object3D\)
```cj
public operator func ==(other: Object3D): Bool
```


参数: 

|名称|类型|描述|
|---|---|---|
|other|Object3D||

### func add\(Object3D\)
```cj
public open func add(child: Object3D): Object3D
```


参数: 

|名称|类型|描述|
|---|---|---|
|child|Object3D||

### func applyMatrix4\(Matrix4\)
```cj
public func applyMatrix4(matrix: Matrix4): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|matrix|Matrix4||

### func applyQuaternion\(Quaternion\)
```cj
public func applyQuaternion(q: Quaternion): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion||

### func attach\(Object3D\)
```cj
public func attach(object: Object3D): Object3D
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D||
|recursive|Bool||

### func getChildAt\(Int64\)
```cj
public func getChildAt(i: Int64): IBox3Expandable
```


参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子对象索引|

返回: 

- 子对象（Object3D 实现了 IBox3Expandable）

### func getChildCount\(\)
```cj
public func getChildCount(): Int64
```


返回: 

- 子对象数量

### func getObjectById\(Int64\)
```cj
public func getObjectById(id: Int64): Option < Object3D >
```


参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64||

### func getObjectByName\(String\)
```cj
public func getObjectByName(name: String): Option < Object3D >
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func getObjectsByProperty\(String,Any,ArrayList<Object3D>\)
```cj
public func getObjectsByProperty(name: String, value: Any, result: ArrayList < Object3D >): ArrayList < Object3D >
```


参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|value|Any||
|result|ArrayList<Object3D>||

### func getPreciseVertexCount\(\)
```cj
public open func getPreciseVertexCount(): Int64
```


返回: 

- 顶点数（0 表示不支持精确遍历）

### func getPreciseVertexPosition\(Int64\)
```cj
public open func getPreciseVertexPosition(i: Int64): Array < Float64 >
```


参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|顶点索引|

返回: 

- 世界空间坐标 [x, y, z]

### func getProperty\(String\)
```cj
public func getProperty(name: String): Any
```


参数: 

|名称|类型|描述|
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


返回: 

- Some(([minX,minY,minZ], [maxX,maxY,maxZ])) 或 None（无几何体）

### func getWorldBoundingSphere\(\)
```cj
public open func getWorldBoundingSphere(): Option < Array < Float64 >>
```


返回: 

- Some([cx, cy, cz, radius]) 或 None（无几何体）

### func getWorldDirection\(Vector3\)
```cj
public open func getWorldDirection(target: Vector3): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3||

### func getWorldPosition\(Vector3\)
```cj
public func getWorldPosition(target: Vector3): Vector3
```


参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3||

### func getWorldQuaternion\(Quaternion\)
```cj
public func getWorldQuaternion(target: Quaternion): Quaternion
```


参数: 

|名称|类型|描述|
|---|---|---|
|target|Quaternion||

### func getWorldScale\(Vector3\)
```cj
public func getWorldScale(target: Vector3): Vector3
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|vector|Vector3||

### func lookAt\(Vector3\)
```cj
public func lookAt(target: Vector3): Unit
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|child|Object3D||

### func rotateOnAxis\(Vector3,Float64\)
```cj
public func rotateOnAxis(axis: Vector3, angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func rotateOnWorldAxis\(Vector3,Float64\)
```cj
public func rotateOnWorldAxis(axis: Vector3, angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func rotateX\(Float64\)
```cj
public func rotateX(angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64||

### func rotateY\(Float64\)
```cj
public func rotateY(angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64||

### func rotateZ\(Float64\)
```cj
public func rotateZ(angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|angle|Float64||

### func setRotationFromAxisAngle\(Vector3,Float64\)
```cj
public func setRotationFromAxisAngle(axis: Vector3, angle: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3||
|angle|Float64||

### func setRotationFromEuler\(Euler\)
```cj
public func setRotationFromEuler(euler: Euler): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|euler|Euler||

### func setRotationFromMatrix\(Matrix4\)
```cj
public func setRotationFromMatrix(m: Matrix4): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4||

### func setRotationFromQuaternion\(Quaternion\)
```cj
public func setRotationFromQuaternion(q: Quaternion): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|q|Quaternion||

### func translateOnAxis\(Vector3,Float64\)
```cj
public func translateOnAxis(axis: Vector3, distance: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|axis|Vector3||
|distance|Float64||

### func translateX\(Float64\)
```cj
public func translateX(distance: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64||

### func translateY\(Float64\)
```cj
public func translateY(distance: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64||

### func translateZ\(Float64\)
```cj
public func translateZ(distance: Float64): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64||

### func traverseAncestors\(\(Object3D\)\->Unit\)
```cj
public func traverseAncestors(callback:(Object3D) -> Unit): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|(Object3D)->Unit||

### func traverseVisible\(\(Object3D\)\->Unit\)
```cj
public func traverseVisible(callback:(Object3D) -> Unit): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|(Object3D)->Unit||

### func traverse\(\(Object3D\)\->Unit\)
```cj
public open func traverse(callback:(Object3D) -> Unit): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|callback|(Object3D)->Unit||

### func updateMatrixWorld\(Bool\)
```cj
public open func updateMatrixWorld(force: Bool): Unit
```


参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
|---|---|---|
|updateParents|Bool||
|updateChildren|Bool||
|force|Bool||

### func worldToLocal\(Vector3\)
```cj
public func worldToLocal(vector: Vector3): Vector3
```


参数: 

|名称|类型|描述|
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


