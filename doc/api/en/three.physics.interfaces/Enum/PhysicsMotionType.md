# Enum
## enum PhysicsMotionType
```cj
public enum PhysicsMotionType
```
Rigid-body motion type (backend-agnostic abstraction, corresponds to JPH_MotionType)

### Dynamic
```cj
Dynamic
```
Driven by gravity/collisions/forces (standard simulated object)

### Kinematic
```cj
Kinematic
```
Position/velocity controlled by the user (excluded from dynamics)

### Static
```cj
Static
```
Completely static (static objects such as grounds/walls)

