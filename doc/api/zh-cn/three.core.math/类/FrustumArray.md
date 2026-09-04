# 类
## class FrustumArray
```cj
public class FrustumArray
```
视锥体数组类，用于多层渲染的视锥体裁剪

### func clone\(\)
```cj
public func clone(): FrustumArray
```
克隆当前视锥体数组

返回: 

- 新的视锥体数组实例

### func containsPoint\(Vector3\)
```cj
public func containsPoint(point: Vector3): Bool
```
判断点是否在任意视锥体内

参数: 

|名称|类型|描述|
|---|---|---|
|point|Vector3|点|

返回: 

- 是否包含

### func copy\(FrustumArray\)
```cj
public func copy(source: FrustumArray): FrustumArray
```
复制另一个视锥体数组的值

参数: 

|名称|类型|描述|
|---|---|---|
|source|FrustumArray|源视锥体数组|

返回: 

- 当前实例

### func get\(Int64\)
```cj
public func get(index: Int64): Frustum
```
获取指定索引的视锥体

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|索引|

返回: 

- 视锥体

### func init\(Array<Frustum>\)
```cj
public init(frustums: Array < Frustum >)
```
用指定视锥体数组构造 FrustumArray

参数: 

|名称|类型|描述|
|---|---|---|
|frustums|Array<Frustum>|视锥体数组|

### func intersectsBox\(Box3\)
```cj
public func intersectsBox(box: Box3): Bool
```
判断包围盒是否与任意视锥体相交

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
判断 3D 对象是否与任意视锥体相交

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
判断球体是否与任意视锥体相交

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
判断精灵是否与任意视锥体相交

参数: 

|名称|类型|描述|
|---|---|---|
|sprite|IFrustumCullable|精灵（Sprite <: Object3D <: IFrustumCullable）|

返回: 

- 是否相交

### func setFromArrayCamera\(IArrayCameraSource\)
```cj
public func setFromArrayCamera(cameraArray: IArrayCameraSource): FrustumArray
```
从数组相机设置视锥体数组

参数: 

|名称|类型|描述|
|---|---|---|
|cameraArray|IArrayCameraSource|实现 IArrayCameraSource 的数组相机|

返回: 

- 当前实例

### var frustums
```cj
public var frustums: Array < Frustum >
```
视锥体数组

