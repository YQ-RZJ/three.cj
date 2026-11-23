# 枚举
## enum PhysicsMotorState
```cj
public enum PhysicsMotorState
```
约束电机状态（对应 JPH_MotorState）

### Off
```cj
Off
```
电机关闭（不做任何驱动）

### Position
```cj
Position
```
位置模式（驱动到目标位置/角度）

### Velocity
```cj
Velocity
```
速度模式（维持目标速度）

### func value\(\)
```cj
public func value(): UInt32
```
转换为 JPH_MotorState 的 UInt32 值

返回: 

- C ABI 兼容的枚举值

