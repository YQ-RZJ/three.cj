# 枚举
## enum PhysicsConstraintType
```cj
public enum PhysicsConstraintType
```
约束类型枚举（后端无关，对应 JPH_ConstraintSubType）

### Cone
```cj
Cone
```
锥约束（锥角限制的球关节）

### Distance
```cj
Distance
```
距离约束（保持两刚体锚点间距离，可带弹簧）

### Fixed
```cj
Fixed
```
固定约束（焊接两刚体，无相对运动）

### Gear
```cj
Gear
```
齿轮约束（比例耦合两铰链旋转）

### Hinge
```cj
Hinge
```
铰链约束（绕单轴旋转，可限位/带电机）

### Point
```cj
Point
```
点约束（球关节，共享一个锚点）

### SixDOF
```cj
SixDOF
```
六自由度约束（每轴可 Free/Limited/Locked + 电机）

### Slider
```cj
Slider
```
滑块约束（沿单轴平移，可限位/带电机）

### SwingTwist
```cj
SwingTwist
```
摆动-扭转约束（肩/髋关节）

