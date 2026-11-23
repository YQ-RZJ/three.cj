# Class
## class PhysicsConstraintDesc
```cj
public class PhysicsConstraintDesc
```
Constraint creation description (backend-agnostic)

### func init\(PhysicsConstraintType,PhysicsConstraintSpace,Vector3,Vector3,Vector3,Vector3,Vector3,Float64,Float64,Bool,UInt64\)
```cj
public init(constraintType!: PhysicsConstraintType, space!: PhysicsConstraintSpace = PhysicsConstraintSpace.WorldSpace, anchor1!: Vector3 = Vector3(), anchor2!: Vector3 = Vector3(), axis1!: Vector3 = Vector3(0.0, 1.0, 0.0), axis2!: Vector3 = Vector3(0.0, 1.0, 0.0), planeAxis!: Vector3 = Vector3(1.0, 0.0, 0.0), limitMin!: Float64 = 0.0, limitMax!: Float64 = 0.0, enabled!: Bool = true, userData!: UInt64 = 0)
```
Creates a constraint description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|constraintType|PhysicsConstraintType|The constraint typespace The constraint space; WorldSpace by defaultanchor1 The body-1 anchor; origin by defaultanchor2 The body-2 anchor; origin by defaultaxis1 The body-1 axis; (0,1,0) by defaultaxis2 The body-2 axis; (0,1,0) by defaultplaneAxis The plane axis (SwingTwist); (1,0,0) by defaultlimitMin The minimum limit; 0 by defaultlimitMax The maximum limit; 0 by defaultenabled Whether the constraint is enabled; true by defaultuserData User data; 0 by default|
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
Body-1 anchor (world or local coordinates, depending on space)

### var anchor2
```cj
public var anchor2: Vector3
```
Body-2 anchor (world or local coordinates, depending on space)

### var axis1
```cj
public var axis1: Vector3
```
Body-1 axis (hinge/slider/twist/gear axis)

### var axis2
```cj
public var axis2: Vector3
```
Body-2 axis (hinge/slider/twist/gear axis)

### var constraintType
```cj
public var constraintType: PhysicsConstraintType
```
The constraint type

### var enabled
```cj
public var enabled: Bool
```
Whether the constraint is enabled

### var limitMax
```cj
public var limitMax: Float64
```
Maximum limit (angle in radians or distance in meters, depending on type)

### var limitMin
```cj
public var limitMin: Float64
```
Minimum limit (angle in radians or distance in meters, depending on type)

### var planeAxis
```cj
public var planeAxis: Vector3
```
Plane axis (SwingTwist swing-direction reference, local or world)

### var space
```cj
public var space: PhysicsConstraintSpace
```
The constraint space (LocalToBodyCOM / WorldSpace)

### var userData
```cj
public var userData: UInt64
```
User data

