# 类
## class PhysicsVehicleWheelDesc
```cj
public class PhysicsVehicleWheelDesc
```
轮式载具车轮描述

### func init\(Vector3\)
```cj
public init(position!: Vector3)
```
构造车轮描述

参数: 

|名称|类型|描述|
|---|---|---|
|position|Vector3|安装位置（底盘局部空间）|

### var angularDamping
```cj
public var angularDamping: Float64 = 0.2
```
车轮角阻尼

### var inertia
```cj
public var inertia: Float64 = 0.5
```
车轮转动惯量

### var lateralFriction
```cj
public var lateralFriction: Float64 = 1.0
```
轮胎横向摩擦系数

### var longitudinalFriction
```cj
public var longitudinalFriction: Float64 = 1.0
```
轮胎纵向摩擦系数

### var maxBrakeTorque
```cj
public var maxBrakeTorque: Float64 = 1500.0
```
最大刹车力矩（牛顿·米）

### var maxHandBrakeTorque
```cj
public var maxHandBrakeTorque: Float64 = 0.0
```
最大手刹力矩（牛顿·米；0 表示不响应手刹）

### var maxSteerAngle
```cj
public var maxSteerAngle: Float64 = 0.0
```
最大转向角（弧度；0 表示不转向）

### var position
```cj
public var position: Vector3 = Vector3(0.0, 0.0, 0.0)
```
车轮安装位置（底盘局部空间）

### var radius
```cj
public var radius: Float64 = 0.3
```
车轮半径（米）

### var suspensionDamping
```cj
public var suspensionDamping: Float64 = 0.5
```
悬挂阻尼比（0~1）

### var suspensionFrequency
```cj
public var suspensionFrequency: Float64 = 1.5
```
悬挂自然频率（Hz，mode=Frequency）

### var suspensionMaxLength
```cj
public var suspensionMaxLength: Float64 = 0.5
```
悬挂最大长度（米，完全伸展）

### var suspensionMinLength
```cj
public var suspensionMinLength: Float64 = 0.3
```
悬挂最小长度（米，完全压缩）

### var width
```cj
public var width: Float64 = 0.2
```
车轮宽度（米）

