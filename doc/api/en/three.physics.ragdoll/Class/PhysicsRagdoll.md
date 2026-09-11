# Class
## class PhysicsRagdoll
```cj
public class PhysicsRagdoll
```
Runtime ragdoll: jointed rigid-body simulation once added to the world

### func activate\(\)
```cj
public func activate(): Unit
```
Activates (wakes) the ragdoll

### func addToWorld\(PhysicsActivation\)
```cj
public func addToWorld(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
Adds the ragdoll to the physics world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|activation|PhysicsActivation|The activation mode (default: activate immediately)|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Destroys the ragdoll (automatically removes it from the world and releases all bodies/constraints)

### func driveToPoseUsingKinematics\(PhysicsSkeletonPose,Float32\)
```cj
public func driveToPoseUsingKinematics(pose: PhysicsSkeletonPose, deltaTime: Float32): Unit
```
Kinematically drives the ragdoll toward the target pose (moves bodies directly; suited to death-animation blending)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pose|PhysicsSkeletonPose|The target posedeltaTime This frame's time step (seconds)|
|deltaTime|Float32||

### func driveToPoseUsingMotors\(PhysicsSkeletonPose\)
```cj
public func driveToPoseUsingMotors(pose: PhysicsSkeletonPose): Unit
```
Drives the ragdoll toward the target pose using joint motors (applies torque; suited to active characters)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pose|PhysicsSkeletonPose|The target pose|

### func getBodyID\(Int64\)
```cj
public func getBodyID(bodyIndex: Int64): UInt32
```
Gets the BodyID of a part's rigid body

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bodyIndex|Int64|The part index|

Return: 

- The body BodyID (usable in collision callbacks/queries)

### func getPose\(PhysicsSkeletonPose\)
```cj
public func getPose(pose: PhysicsSkeletonPose): Unit
```
Reads the current ragdoll pose into the given pose object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pose|PhysicsSkeletonPose|The output pose (its joint states are filled after the call)|

### func getRootTransform\(\)
```cj
public func getRootTransform():(Vector3, Quaternion)
```
Gets the ragdoll root transform (world-space position and rotation)

Return: 

- A (root position, root rotation) tuple (three left-handed)

### func isActive\(\)
```cj
public func isActive(): Bool
```
Whether the ragdoll is active (not sleeping)

### func removeFromWorld\(\)
```cj
public func removeFromWorld(): Unit
```
Removes the ragdoll from the physics world (it can be re-added with addToWorld)

### func setPose\(PhysicsSkeletonPose\)
```cj
public func setPose(pose: PhysicsSkeletonPose): Unit
```
Sets the ragdoll pose directly (instant, no velocity introduced)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pose|PhysicsSkeletonPose|The target pose|

### prop bodyCount: Int64
```cj
public prop bodyCount: Int64
```
The number of rigid bodies (parts)

### prop constraintCount: Int64
```cj
public prop constraintCount: Int64
```
The number of joint constraints

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the ragdoll is valid (created successfully and not disposed)

### prop skeleton: PhysicsSkeleton
```cj
public prop skeleton: PhysicsSkeleton
```
The skeleton associated with the ragdoll

