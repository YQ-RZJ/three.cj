# 类
## class PhysicsShapeHit
```cj
public class PhysicsShapeHit
```
形状碰撞/投射查询结果（collideShape/castShape，后端无关）

### func init\(\)
```cj
public init()
```
创建空的形状命中结果

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
被命中刚体的 BodyID（0 = 无效）

### var fraction
```cj
public var fraction: Float32 = 0.0f32
```
命中比例 0..1（仅 castShape 有效；collideShape 为 0）

### var isBackFaceHit
```cj
public var isBackFaceHit: Bool = false
```
是否为背面命中（castShape 有效）

### var normal
```cj
public var normal: Vector3 = Vector3()
```
穿透轴方向（从被撞体指向查询形状）

### var penetrationDepth
```cj
public var penetrationDepth: Float32 = 0.0f32
```
穿透深度（collideShape 有效）

### var point
```cj
public var point: Vector3 = Vector3()
```
接触点（查询形状表面，世界坐标）

### var subShapeID1
```cj
public var subShapeID1: UInt32 = 0
```
查询形状子形状 ID

### var subShapeID2
```cj
public var subShapeID2: UInt32 = 0
```
被命中形状子形状 ID

