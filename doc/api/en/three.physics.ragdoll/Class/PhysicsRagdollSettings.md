# Class
## class PhysicsRagdollSettings
```cj
public class PhysicsRagdollSettings
```
Ragdoll settings: a skeleton + parts array, able to create a runtime ragdoll

### func createRagdoll\(PhysicsWorld\)
```cj
public func createRagdoll(world: PhysicsWorld): PhysicsRagdoll
```
Creates a runtime ragdoll in the given physics world

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The target physics world|

Return: 

- The runtime ragdoll

### func init\(PhysicsSkeleton,Array<RagdollPartSettings>\)
```cj
public init(skeleton!: PhysicsSkeleton, parts!: Array < RagdollPartSettings >)
```
Creates ragdoll settings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|PhysicsSkeleton|The skeleton (part count must equal joint count)parts The parts array (indices correspond to joint indices)|
|parts|Array<RagdollPartSettings>||

### var disableParentChildCollisions
```cj
public var disableParentChildCollisions: Bool = true
```
Whether to disable collisions between parent/child parts (default true)

### var minSeparationDistance
```cj
public var minSeparationDistance: Float32 = 0.0f32
```
Minimum parent-child separation distance (meters)

### var stabilize
```cj
public var stabilize: Bool = true
```
Whether to auto-stabilize before creation (default true)

