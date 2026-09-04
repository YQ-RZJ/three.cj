# 类
## class PhysicsConstraintDesc
```cj
public class PhysicsConstraintDesc
```
约束创建描述（后端无关）

### func init\(PhysicsConstraintType,PhysicsConstraintSpace,Vector3,Vector3,Vector3,Vector3,Vector3,Float64,Float64,Bool,UInt64\)
```cj
public init(constraintType!: PhysicsConstraintType, space!: PhysicsConstraintSpace = PhysicsConstraintSpace.WorldSpace, anchor1!: Vector3 = Vector3(), anchor2!: Vector3 = Vector3(), axis1!: Vector3 = Vector3(0.0, 1.0, 0.0), axis2!: Vector3 = Vector3(0.0, 1.0, 0.0), planeAxis!: Vector3 = Vector3(1.0, 0.0, 0.0), limitMin!: Float64 = 0.0, limitMax!: Float64 = 0.0, enabled!: Bool = true, userData!: UInt64 = 0)
```
创建约束描述

参数: 

|名称|类型|描述|
|---|---|---|
|constraintType|PhysicsConstraintType|约束类型space 约束空间，默认 WorldSpaceanchor1 刚体 1 锚点，默认原点anchor2 刚体 2 锚点，默认原点axis1 刚体 1 轴，默认 (0,1,0)axis2 刚体 2 轴，默认 (0,1,0)planeAxis 平面轴（SwingTwist），默认 (1,0,0)limitMin 限位最小值，默认 0limitMax 限位最大值，默认 0enabled 是否启用，默认 trueuserData 用户数据，默认 0|
|space|PhysicsConstraintSpace||
|anchor1|Vector3||
|anchor2|Vector3||
|axis1|Vector3||
|axis2|Vector3||
|planeAxis|Vector3||
|limitMin|Float64||
|limitMax|Float64||
|enabled|Bool||
|userData|UInt64||

### var anchor1
```cj
public var anchor1: Vector3
```
刚体 1 锚点（世界坐标或局部坐标，依 space）

### var anchor2
```cj
public var anchor2: Vector3
```
刚体 2 锚点（世界坐标或局部坐标，依 space）

### var axis1
```cj
public var axis1: Vector3
```
刚体 1 轴（铰链/滑块/扭转/齿轮轴）

### var axis2
```cj
public var axis2: Vector3
```
刚体 2 轴（铰链/滑块/扭转/齿轮轴）

### var constraintType
```cj
public var constraintType: PhysicsConstraintType
```
约束类型

### var enabled
```cj
public var enabled: Bool
```
约束是否启用

### var limitMax
```cj
public var limitMax: Float64
```
限位最大值（角度弧度或距离米，依约束类型）

### var limitMin
```cj
public var limitMin: Float64
```
限位最小值（角度弧度或距离米，依约束类型）

### var planeAxis
```cj
public var planeAxis: Vector3
```
平面轴（SwingTwist 摆动方向参考，局部或世界）

### var space
```cj
public var space: PhysicsConstraintSpace
```
约束空间（LocalToBodyCOM / WorldSpace）

### var userData
```cj
public var userData: UInt64
```
用户数据

