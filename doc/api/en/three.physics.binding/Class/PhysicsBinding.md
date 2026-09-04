# Class
## class PhysicsBinding
```cj
public class PhysicsBinding
```
Convenient binding API between Object3D and physics rigid bodies (static methods, no instance state)

### func bind\(PhysicsWorld,Object3D,PhysicsShape,PhysicsMotionType,Float64,Float64,Bool,Bool\)
```cj
public static func bind(world: PhysicsWorld, object3d: Object3D, shape: PhysicsShape, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0, syncToObj!: Bool = true, isSensor!: Bool = false): RigidBody
```
Creates a physics rigid body and binds it to a render object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instanceobject3d The render object to bind physics toshape The physics shapemotionType Motion type (Dynamic/Kinematic/Static), defaults to Dynamicfriction Friction coefficient, defaults to 0.2restitution Restitution coefficient, defaults to 0.0syncToObj Whether to sync the body transform back to the object every frame, defaults to trueisSensor Whether to act as a sensor (pass-through, no collision), defaults to false|
|object3d|Object3D||
|shape|PhysicsShape||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||
|syncToObj|Bool||
|isSensor|Bool||

Return: 

- Returns the created RigidBody instance (for runtime control)

### func ground\(PhysicsWorld,Mesh,Float64\)
```cj
public static func ground(world: PhysicsWorld, mesh: Mesh, yPosition!: Float64 = 0.0): RigidBody
```
Creates and binds a static ground (large plane)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The plane shape is approximated by a large box in the backend.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instancemesh The Mesh used as the ground's visual representationyPosition The ground y coordinate, defaults to 0|
|mesh|Mesh||
|yPosition|Float64||

Return: 

- Returns the created static RigidBody instance

### func meshBox\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshBox(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
Adds physics to a Mesh (derives a Box shape from BoxGeometry automatically)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instancemesh Target Mesh (its geometry is used to derive the shape)motionType Motion type, defaults to Dynamicfriction Friction coefficient, defaults to 0.2restitution Restitution coefficient, defaults to 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

Return: 

- Returns the created RigidBody instance

### func meshCapsule\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshCapsule(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
Adds physics to a Mesh (derives a Capsule shape from CapsuleGeometry automatically)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>CapsuleGeometry(radius, length): length includes the total height of
both hemispherical caps; halfHeight = (length - 2 * radius) / 2.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instancemesh Target Mesh (its geometry is used to derive the shape)motionType Motion type, defaults to Dynamicfriction Friction coefficient, defaults to 0.2restitution Restitution coefficient, defaults to 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

Return: 

- Returns the created RigidBody instance

### func meshCylinder\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshCylinder(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
Adds physics to a Mesh (derives a Cylinder shape from CylinderGeometry automatically)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>For CylinderGeometry(radiusTop, radiusBottom, height), height is the
full height; halfHeight = height / 2.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instancemesh Target Mesh (its geometry is used to derive the shape)motionType Motion type, defaults to Dynamicfriction Friction coefficient, defaults to 0.2restitution Restitution coefficient, defaults to 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

Return: 

- Returns the created RigidBody instance

### func meshSphere\(PhysicsWorld,Mesh,PhysicsMotionType,Float64,Float64\)
```cj
public static func meshSphere(world: PhysicsWorld, mesh: Mesh, motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, friction!: Float64 = 0.2, restitution!: Float64 = 0.0): RigidBody
```
Adds physics to a Mesh (derives a Sphere shape from SphereGeometry automatically)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instancemesh Target Mesh (its geometry is used to derive the shape)motionType Motion type, defaults to Dynamicfriction Friction coefficient, defaults to 0.2restitution Restitution coefficient, defaults to 0.0|
|mesh|Mesh||
|motionType|PhysicsMotionType||
|friction|Float64||
|restitution|Float64||

Return: 

- Returns the created RigidBody instance

### func unbind\(PhysicsWorld,Object3D\)
```cj
public static func unbind(world: PhysicsWorld, object3d: Object3D): Unit
```
Removes the physics binding of a Mesh (does not destroy the body)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world instanceobject3d The render object to unbind|
|object3d|Object3D||

