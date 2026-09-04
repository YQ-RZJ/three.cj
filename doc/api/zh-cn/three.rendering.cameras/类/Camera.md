# 类
## class Camera
```cj
public open class Camera <: Object3D & ICamera
```
相机抽象基类，所有具体相机类型继承本类

### func clone\(\)
```cj
public override func clone(): Object3D
```
返回一个与本实例值相同的新相机实例

返回: 

- 新相机实例

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
将给定相机实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Object3D|源对象recursive 是否递归复制子对象|
|recursive|Bool||

返回: 

- 本实例

### func getWorldDirection\(Vector3\)
```cj
public override func getWorldDirection(target: Vector3): Vector3
```
返回相机朝向的世界方向（左手系 bgfx 下相机朝 +Z）

参数: 

|名称|类型|描述|
|---|---|---|
|target|Vector3|目标向量|

返回: 

- 世界方向向量

### func init\(Float64,Float64\)
```cj
public init(near!: Float64 = 0.1, far!: Float64 = 2000.0)
```
构造一个新的相机

参数: 

|名称|类型|描述|
|---|---|---|
|near|Float64|近裁剪面距离，默认 0.1far 远裁剪面距离，默认 2000|
|far|Float64||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
更新本相机及父级的世界矩阵，并同步 matrixWorldInverse

参数: 

|名称|类型|描述|
|---|---|---|
|force|Bool|是否强制更新|

### func updateWorldMatrix\(Bool,Bool,Bool\)
```cj
public override func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit
```
更新本相机及父级/子级的世界矩阵，并同步 matrixWorldInverse

参数: 

|名称|类型|描述|
|---|---|---|
|updateParents|Bool|是否更新父级updateChildren 是否更新子级force 是否强制更新|
|updateChildren|Bool||
|force|Bool||

### prop reversedDepth: Bool
```cj
public mut prop reversedDepth: Bool
```


### var coordinateSystem
```cj
public var coordinateSystem: Int64
```
坐标系（WebGLCoordinateSystem / WebGPUCoordinateSystem），决定 Z 方向约定

### var far
```cj
public var far: Float64
```
远裁剪面距离。默认 2000

### var matrixWorldInverse
```cj
public var matrixWorldInverse: Matrix4
```
视矩阵的逆矩阵（世界空间 → 观察空间）

### var near
```cj
public var near: Float64
```
近裁剪面距离。默认 0.1

### var projectionMatrixInverse
```cj
public var projectionMatrixInverse: Matrix4
```
投影矩阵的逆矩阵

### var projectionMatrix
```cj
public var projectionMatrix: Matrix4
```
投影矩阵

