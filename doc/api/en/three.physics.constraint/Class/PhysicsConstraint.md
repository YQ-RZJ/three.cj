# Class
## class PhysicsConstraint
```cj
public class PhysicsConstraint
```
Runtime handle wrapper for a constraint

### func cone\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64\)
```cj
public static func cone(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, halfAngle: Float64): PhysicsConstraint
```
Creates a cone constraint: a ball joint with a cone-angle limit (e.g. a shoulder joint)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The anchor point (world coordinates)axis The cone axis direction (world coordinates)halfAngle The cone half-angle (radians)|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|halfAngle|Float64||

Return: 

- The newly created constraint wrapper

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the constraint and removes it from the world

### func distance\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func distance(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor1: Vector3, anchor2: Vector3, minDist: Float64, maxDist: Float64): PhysicsConstraint
```
Creates a distance constraint: keeps the distance between two anchor points (with an optional spring range)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor1 The first anchor point (world coordinates)anchor2 The second anchor point (world coordinates)minDist The minimum distancemaxDist The maximum distance|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor1|Vector3||
|anchor2|Vector3||
|minDist|Float64||
|maxDist|Float64||

Return: 

- The newly created constraint wrapper

### func fixed\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public static func fixed(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraint
```
Creates a fixed constraint: welds two bodies together with no relative motion

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handle|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

Return: 

- The newly created constraint wrapper

### func gear\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64\)
```cj
public static func gear(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, hingeAxis: Vector3, ratio: Float64): PhysicsConstraint
```
Creates a gear constraint: couples the rotation of two hinges at a fixed ratio (transmission)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The anchor point (world coordinates)hingeAxis The hinge-axis directionratio The gear ratio|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|hingeAxis|Vector3||
|ratio|Float64||

Return: 

- The newly created constraint wrapper

### func hinge\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func hinge(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, limitMin!: Float64 = - 3.14159265358979, limitMax!: Float64 = 3.14159265358979): PhysicsConstraint
```
Creates a hinge constraint: rotation about a single axis, with optional angle limits (radians)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The hinge anchor point (world coordinates)axis The rotation axis (world direction)limitMin The minimum rotation angle (radians, default -π, no limit)limitMax The maximum rotation angle (radians, default +π, no limit)|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|limitMin|Float64||
|limitMax|Float64||

Return: 

- The newly created constraint wrapper

### func init\(PhysicsWorld,PhysicsConstraintHandle\)
```cj
public init(world!: PhysicsWorld, handle!: PhysicsConstraintHandle)
```
Creates a constraint wrapper (normally created by the static constructors; no need to call directly)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldhandle The underlying constraint handle|
|handle|PhysicsConstraintHandle||

### func isEnabled\(\)
```cj
public func isEnabled(): Bool
```
Whether the constraint is enabled

Return: 

- true if enabled

### func isValid\(\)
```cj
public func isValid(): Bool
```
Whether the constraint is valid (created and not disposed)

Return: 

- true if valid

### func point\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3\)
```cj
public static func point(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3): PhysicsConstraint
```
Creates a point constraint (ball joint): both bodies share an anchor point and can rotate freely

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The shared anchor point (world coordinates)|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||

Return: 

- The newly created constraint wrapper

### func setEnabled\(Bool\)
```cj
public func setEnabled(enabled: Bool): PhysicsConstraint
```
Sets whether the constraint is enabled

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|true to enable, false to temporarily disable the constraint|

Return: 

- Returns this for chaining

### func sixDOF\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3\)
```cj
public static func sixDOF(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axisX!: Vector3 = Vector3(1.0, 0.0, 0.0)): PhysicsConstraint
```
Creates a six-DOF constraint: shared anchor, each degree of freedom can be Free/Limited/Locked (all Free by default = ball joint)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The shared anchor point (world coordinates)axisX The first local-axis direction (X axis by default)|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axisX|Vector3||

Return: 

- The newly created constraint wrapper

### func slider\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func slider(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, limitMin: Float64, limitMax: Float64): PhysicsConstraint
```
Creates a slider constraint: translation along a single axis (with optional limits), e.g. drawers, pistons

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The slider anchor point (world coordinates)axis The sliding axis (world direction)limitMin The minimum translation distancelimitMax The maximum translation distance|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|limitMin|Float64||
|limitMax|Float64||

Return: 

- The newly created constraint wrapper

### func swingTwist\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Vector3,Float64,Float64\)
```cj
public static func swingTwist(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, twistAxis: Vector3, planeAxis: Vector3, twistMin: Float64, twistMax: Float64): PhysicsConstraint
```
Creates a swing-twist constraint (shoulder/hip joint, with a twist-angle limit)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The owning physics worldbodyA The first body handlebodyB The second body handleanchor The anchor point (world coordinates)twistAxis The twist-axis directionplaneAxis The swing-plane axis directiontwistMin The minimum twist angle (radians)twistMax The maximum twist angle (radians)|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|twistAxis|Vector3||
|planeAxis|Vector3||
|twistMin|Float64||
|twistMax|Float64||

Return: 

- The newly created constraint wrapper

### prop handle: PhysicsConstraintHandle
```cj
public prop handle: PhysicsConstraintHandle
```
Gets the constraint handle (INVALID after disposal)

