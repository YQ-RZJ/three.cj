# 类
## class PhysicsPointHit
```cj
public class PhysicsPointHit
```
点碰撞查询结果（collidePoint，后端无关）

### func init\(\)
```cj
public init()
```
创建空的点碰撞命中结果

### var bodyID
```cj
public var bodyID: UInt32 = 0
```
被命中刚体的 BodyID（0 = 无效）

### var subShapeID
```cj
public var subShapeID: UInt32 = 0
```
被命中形状的子形状 ID

