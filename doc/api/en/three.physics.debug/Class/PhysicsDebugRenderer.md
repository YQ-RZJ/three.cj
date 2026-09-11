# Class
## class PhysicsDebugRenderer
```cj
public class PhysicsDebugRenderer
```
Jolt debug-renderer bridge

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the collected primitive cache

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the renderer (releases the procs table and the Jolt instance)

### func drawBodies\(PhysicsWorld,Bool\)
```cj
public func drawBodies(world: PhysicsWorld, wireframe!: Bool = true): Unit
```
Captures one frame of debug primitives: draws all body shapes
(wireframe and/or shaded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics worldwireframe Wireframe or not (default true)|
|wireframe|Bool||

### func drawConstraints\(PhysicsWorld\)
```cj
public func drawConstraints(world: PhysicsWorld): Unit
```
Captures one frame of debug primitives: draws all constraints

Parameter: 

|Name|Type|Describe|
|---|---|---|
|world|PhysicsWorld|The physics world|

### func init\(\)
```cj
public init()
```
Creates the bridge and registers the debug-renderer callbacks

### func nextFrame\(\)
```cj
public func nextFrame(): Unit
```
Ends this capture pass (triggers Jolt NextFrame, clears internal state)

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the renderer is valid

### prop lineCount: Int64
```cj
public prop lineCount: Int64
```
Number of line segments collected this frame

