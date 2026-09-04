# 类
## class PhysicsBodyDesc
```cj
public class PhysicsBodyDesc
```
刚体创建描述（后端无关）

### func init\(PhysicsShape,Vector3,Quaternion,PhysicsMotionType,PhysicsLayer,PhysicsActivation,Float64,Float64,Bool,Float64,Float64,Float64,Float64,Bool\)
```cj
public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(), motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, layer!: PhysicsLayer = PhysicsLayer.Moving, activation!: PhysicsActivation = PhysicsActivation.Activate, friction!: Float64 = 0.2, restitution!: Float64 = 0.0, autoSync!: Bool = true, mass!: Float64 = - 1.0, gravityFactor!: Float64 = 1.0, linearDamping!: Float64 = 0.05, angularDamping!: Float64 = 0.05, isSensor!: Bool = false)
```
创建刚体描述

参数: 

|名称|类型|描述|
|---|---|---|
|shape|PhysicsShape|碰撞形状position 初始位置，默认原点rotation 初始旋转，默认单位四元数motionType 运动类型，默认 Dynamiclayer 物理层，默认 Movingactivation 激活策略，默认 Activatefriction 摩擦系数，默认 0.2restitution 弹性系数，默认 0autoSync 是否自动同步 transform，默认 truemass 质量，默认 -1（自动计算）gravityFactor 重力因子，默认 1linearDamping 线阻尼，默认 0.05angularDamping 角阻尼，默认 0.05isSensor 是否为传感器，默认 false|
|position|Vector3||
|rotation|Quaternion||
|motionType|PhysicsMotionType||
|layer|PhysicsLayer||
|activation|PhysicsActivation||
|friction|Float64||
|restitution|Float64||
|autoSync|Bool||
|mass|Float64||
|gravityFactor|Float64||
|linearDamping|Float64||
|angularDamping|Float64||
|isSensor|Bool||

### var activation
```cj
public var activation: PhysicsActivation
```
激活策略

### var angularDamping
```cj
public var angularDamping: Float64
```
角阻尼（默认 0.05）

### var autoSync
```cj
public var autoSync: Bool
```
是否自动同步 transform 到绑定的 Object3D

### var friction
```cj
public var friction: Float64
```
摩擦系数（0~1，默认 0.2）

### var gravityFactor
```cj
public var gravityFactor: Float64
```
重力因子（1 = 正常重力，0 = 无重力，默认 1）

### var isSensor
```cj
public var isSensor: Bool
```
是否为传感器刚体（只检测碰撞不产生物理响应，默认 false）

### var layer
```cj
public var layer: PhysicsLayer
```
物理层（碰撞分组）

### var linearDamping
```cj
public var linearDamping: Float64
```
线阻尼（默认 0.05）

### var mass
```cj
public var mass: Float64
```
质量（千克，<=0 时由后端从形状自动计算，默认 -1 = 自动）

### var motionType
```cj
public var motionType: PhysicsMotionType
```
运动类型

### var position
```cj
public var position: Vector3
```
初始位置（世界坐标）

### var restitution
```cj
public var restitution: Float64
```
弹性系数（0~1，默认 0）

### var rotation
```cj
public var rotation: Quaternion
```
初始旋转（四元数，单位四元数 = 无旋转）

### var shape
```cj
public var shape: PhysicsShape
```
碰撞形状

