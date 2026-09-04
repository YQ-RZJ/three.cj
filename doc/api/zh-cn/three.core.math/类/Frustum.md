# 类
## class Frustum
```cj
public class Frustum
```
视锥体类，由6个平面定义

### func clone\(\)
```cj
public func clone(): Frustum
```
克隆当前视锥体

返回: 

- 新的视锥体实例

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
判断点是否在视锥体内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|要检测的点|

返回: 

- 是否包含

### func copy\(Frustum\)
```cj
public func copy(f: Frustum): Frustum
```
复制另一个视锥体的值到当前实例

参数: 

|名称|类型|描述|
|---|---|---|
|f|Frustum|源视锥体|

返回: 

- 当前实例

### func equals\(Frustum\)
```cj
public func equals(f: Frustum): Bool
```
判断是否与另一个视锥体相等

参数: 

|名称|类型|描述|
|---|---|---|
|f|Frustum|另一个视锥体|

返回: 

- 是否相等

### func init\(\)
```cj
public init()
```


### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断包围盒是否与视锥体相交

参数: 

|名称|类型|描述|
|---|---|---|
|box|Box3|包围盒|

返回: 

- 是否相交

### func intersectsObject\(IFrustumCullable\)
```cj
public func intersectsObject(object: IFrustumCullable): Bool
```
判断 3D 对象是否与视锥体相交

参数: 

|名称|类型|描述|
|---|---|---|
|object|IFrustumCullable|实现 IFrustumCullable 的对象（Object3D 及子类）|

返回: 

- 是否相交

### func intersectsSphere\(Sphere\)
```cj
public func intersectsSphere(sphere: Sphere): Bool
```
判断球体是否与视锥体相交

参数: 

|名称|类型|描述|
|---|---|---|
|sphere|Sphere|球体|

返回: 

- 是否相交

### func intersectsSprite\(IFrustumCullable\)
```cj
public func intersectsSprite(sprite: IFrustumCullable): Bool
```
判断精灵是否与视锥体相交

参数: 

|名称|类型|描述|
|---|---|---|
|sprite|IFrustumCullable|精灵（Sprite <: Object3D <: IFrustumCullable）|

返回: 

- 是否相交

### func setFromProjectionMatrix\(Matrix4,Int64,Bool\)
```cj
public func setFromProjectionMatrix(m: Matrix4, coordinateSystem!: Int64 = WebGPUCoordinateSystem, reversedDepth!: Bool = false): Frustum
```
从投影矩阵设置视锥体

参数: 

|名称|类型|描述|
|---|---|---|
|m|Matrix4|投影矩阵（或 projScreen = projectionMatrix × matrixWorldInverse）coordinateSystem 坐标系（WebGL 2000 / WebGPU 2001），默认 WebGPU（左手系）reversedDepth 是否反向深度（WebGPU 反向 Z [1,0]），默认 false|
|coordinateSystem|Int64||
|reversedDepth|Bool||

返回: 

- 当前实例

### func set\(Plane,Plane,Plane,Plane,Plane,Plane\)
```cj
public func set(p0: Plane, p1: Plane, p2: Plane, p3: Plane, p4: Plane, p5: Plane): Frustum
```
设置视锥体的6个平面

参数: 

|名称|类型|描述|
|---|---|---|
|p0|Plane|第0个平面p1 第1个平面p2 第2个平面p3 第3个平面p4 第4个平面p5 第5个平面|
|p1|Plane||
|p2|Plane||
|p3|Plane||
|p4|Plane||
|p5|Plane||

返回: 

- 当前实例

### let isFrustum
```cj
public let isFrustum: Bool = true
```
类型标记（is+类名 冗余成员，不参与序列化）

### var planes
```cj
public var planes: Array < Plane >
```
视锥体的6个裁剪平面

