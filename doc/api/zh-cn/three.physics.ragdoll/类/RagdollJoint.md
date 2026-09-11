# 类
## class RagdollJoint
```cj
public class RagdollJoint
```
布娃娃部件到父部件的摆动-扭转关节描述

### func cone\(Vector3,Vector3,Float32,Float32,Float32,Float32\)
```cj
public static func cone(anchor: Vector3, twistAxis: Vector3, halfConeAngle: Float32, twistMin!: Float32 = - 3.1415927f32, twistMax!: Float32 = 3.1415927f32, maxFrictionTorque!: Float32 = 0.0f32): RagdollJoint
```
便捷工厂：锥形摆动关节（两个方向摆动范围相同）

参数: 

|名称|类型|描述|
|---|---|---|
|anchor|Vector3|关节锚点（子/父质心空间共用同一锚点）twistAxis 扭转轴（沿骨骼方向）halfConeAngle 摆动半锥角（弧度）；越小关节越"硬"twistMin 最小扭转角（弧度，默认 -π 自由扭转）twistMax 最大扭转角（弧度，默认 +π）maxFrictionTorque 最大摩擦扭矩（默认 0）|
|twistAxis|Vector3||
|halfConeAngle|Float32||
|twistMin|Float32||
|twistMax|Float32||
|maxFrictionTorque|Float32||

返回: 

- 锥形关节描述

### func init\(\)
```cj
public init()
```
创建关节描述

### var maxFrictionTorque
```cj
public var maxFrictionTorque: Float32 = 0.0f32
```


### var normalHalfConeAngle
```cj
public var normalHalfConeAngle: Float32 = 0.0f32
```


### var planeAxis1
```cj
public var planeAxis1: Vector3 = Vector3(0.0, 0.0, 1.0)
```


### var planeAxis2
```cj
public var planeAxis2: Vector3 = Vector3(0.0, 0.0, 1.0)
```


### var planeHalfConeAngle
```cj
public var planeHalfConeAngle: Float32 = 0.0f32
```


### var position1
```cj
public var position1: Vector3 = Vector3()
```


### var position2
```cj
public var position2: Vector3 = Vector3()
```


### var twistAxis1
```cj
public var twistAxis1: Vector3 = Vector3(0.0, 1.0, 0.0)
```


### var twistAxis2
```cj
public var twistAxis2: Vector3 = Vector3(0.0, 1.0, 0.0)
```


### var twistMaxAngle
```cj
public var twistMaxAngle: Float32 = 3.1415927f32
```


### var twistMinAngle
```cj
public var twistMinAngle: Float32 = - 3.1415927f32
```


