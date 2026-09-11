# 类
## class PhysicsSoftBodyDesc
```cj
public class PhysicsSoftBodyDesc
```
软体描述

### func init\(\)
```cj
public init()
```
构造软体描述

### var bendType
```cj
public var bendType: UInt32 = 0
```
弯曲约束类型（0 = 无）

### var compliance
```cj
public var compliance: Float64 = 0.00001
```
边约束柔顺度（0 = 刚性）

### var friction
```cj
public var friction: Float64 = 0.2
```
摩擦系数

### var gravityFactor
```cj
public var gravityFactor: Float64 = 1.0
```
重力因子（1 = 正常重力）

### var indices
```cj
public var indices: ArrayList < UInt32 >= ArrayList < UInt32 >()
```
三角形索引列表（每 3 个一组）

### var layer
```cj
public var layer: PhysicsLayer = PhysicsLayer.Moving
```
对象层（Moving/Static）

### var linearDamping
```cj
public var linearDamping: Float64 = 0.1
```
线阻尼

### var numIterations
```cj
public var numIterations: UInt32 = 5
```
求解迭代次数

### var pinnedVertices
```cj
public var pinnedVertices: ArrayList < Int64 >= ArrayList < Int64 >()
```
固定顶点索引列表（逆质量 = 0）

### var pressure
```cj
public var pressure: Float64 = 0.0
```
内部压力（封闭网格充气效果）

### var restitution
```cj
public var restitution: Float64 = 0.0
```
弹性系数

### var vertexRadius
```cj
public var vertexRadius: Float64 = 0.0
```
顶点半径（碰撞增厚）

### var vertices
```cj
public var vertices: ArrayList < Vector3 >= ArrayList < Vector3 >()
```
顶点位置列表（世界空间）

