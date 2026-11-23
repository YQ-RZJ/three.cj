# Enum
## enum PhysicsConstraintType
```cj
public enum PhysicsConstraintType
```
Constraint-type enum (backend-agnostic, corresponds to JPH_ConstraintSubType)

### Cone
```cj
Cone
```
Cone constraint (ball joint limited by a cone angle)

### Distance
```cj
Distance
```
Distance constraint (keeps the distance between two anchors, spring-capable)

### Fixed
```cj
Fixed
```
Fixed constraint (welds two bodies with no relative motion)

### Gear
```cj
Gear
```
Gear constraint (couples two hinge rotations at a ratio)

### Hinge
```cj
Hinge
```
Hinge constraint (rotation about a single axis, limitable/motorized)

### Point
```cj
Point
```
Point constraint (ball joint, shared anchor point)

### SixDOF
```cj
SixDOF
```
Six-DOF constraint (each axis Free/Limited/Locked + motor)

### Slider
```cj
Slider
```
Slider constraint (translation along a single axis, limitable/motorized)

### SwingTwist
```cj
SwingTwist
```
Swing-twist constraint (shoulder/hip joint)

