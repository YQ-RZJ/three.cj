# 类
## class Intersection
```cj
public class Intersection
```
射线投射相交结果

### func init\(Float64,Vector3\)
```cj
public init(distance!: Float64 = 0.0, point!: Vector3 = Vector3())
```
构造相交结果

参数: 

|名称|类型|描述|
|---|---|---|
|distance|Float64|从射线原点到相交点的距离，默认 0.0point 相交点，默认零向量|
|point|Vector3||

### var barycoord
```cj
public var barycoord:?Vector3
```
相交点处的重心坐标（Mesh 命中用）

### var distanceToRay
```cj
public var distanceToRay: Float64
```
相交点到射线的距离（Points 命中用）

### var distance
```cj
public var distance: Float64
```
从射线原点到相交点的距离

### var faceIndex
```cj
public var faceIndex: Int64
```
相交面的索引

### var face
```cj
public var face:?Face
```
相交面信息（Mesh 命中用）

### var index
```cj
public var index: Int64
```
相交的顶点/线段索引（Points/Line 命中用）

### var instanceId
```cj
public var instanceId: Int64
```
相交的 InstancedMesh 实例索引

### var normal
```cj
public var normal:?Vector3
```
相交点处的插值法向量

### var obj
```cj
public var obj:?Object3D
```
被相交的 3D 对象

### var point
```cj
public var point: Vector3
```
相交点（世界坐标）

### var uv1
```cj
public var uv1:?Vector2
```
第二组相交点处 UV 坐标

### var uv
```cj
public var uv:?Vector2
```
相交点处的 UV 坐标

