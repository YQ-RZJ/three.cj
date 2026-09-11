# Enum
## enum PhysicsMotorState
```cj
public enum PhysicsMotorState
```
Constraint motor state (corresponds to JPH_MotorState)

### Off
```cj
Off
```
Motor off (no driving at all)

### Position
```cj
Position
```
Position mode (drive to a target position/angle)

### Velocity
```cj
Velocity
```
Velocity mode (maintain a target velocity)

### func value\(\)
```cj
public func value(): UInt32
```
Converts to the JPH_MotorState UInt32 value

Return: 

- The C ABI compatible enum value

