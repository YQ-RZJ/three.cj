# 类
## class PhysicsVehicleDesc
```cj
public class PhysicsVehicleDesc
```
轮式载具描述

### func init\(PhysicsBodyDesc\)
```cj
public init(chassisDesc!: PhysicsBodyDesc)
```
构造载具描述

参数: 

|名称|类型|描述|
|---|---|---|
|chassisDesc|PhysicsBodyDesc|底盘刚体描述|

### var chassisDesc
```cj
public var chassisDesc: PhysicsBodyDesc
```
底盘刚体描述（含形状/质量/摩擦等）

### var drivenWheels
```cj
public var drivenWheels: ArrayList < Int64 >= ArrayList < Int64 >()
```
驱动车轮索引列表（差速器按此成对创建；空 = 全轮驱动单差速器）

### var engine
```cj
public var engine: PhysicsVehicleEngineDesc = PhysicsVehicleEngineDesc()
```
引擎与变速箱配置

### var maxPitchRollAngle
```cj
public var maxPitchRollAngle: Float64 = 0.0
```
最大俯仰/横滚角（弧度，0 = 不限制）

### var wheels
```cj
public var wheels: ArrayList < PhysicsVehicleWheelDesc >= ArrayList < PhysicsVehicleWheelDesc >()
```
车轮列表（索引即车轮索引）

