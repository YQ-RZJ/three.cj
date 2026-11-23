# 类
## class PhysicsRayHit
```cj
public class PhysicsRayHit
```
射线查询结果（后端无关）

### func init\(\)
```cj
public init()
```
创建空的射线命中结果

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
被命中刚体的 BodyID（后端私有句柄的整型表示，0 = 无效）

### var fraction
```cj
public var fraction: Float32 = 0.0f32
```
命中比例 0..1（沿射线方向）

### var normal
```cj
public var normal: Vector3 = Vector3()
```
命中面法线（世界空间）

### var point
```cj
public var point: Vector3 = Vector3()
```
命中点世界坐标

