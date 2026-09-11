# Class
## class PhysicsVehicle
```cj
public class PhysicsVehicle
```
Runtime wheeled vehicle

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes the vehicle (removes and releases the vehicle constraint;
the chassis body is managed by the caller)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The chassis body is NOT destroyed here — vehicles often reuse the
chassis; call world.destroyBody(chassis) as needed</p>

### func getWheelWorldTransform\(Int64\)
```cj
public func getWheelWorldTransform(index: Int64): Matrix4
```
Reads the world transform of a wheel (for rendering the wheel mesh)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The wheel index|

Return: 

- The wheel world matrix (three left-handed); identity for an invalid index

### func setDriverInput\(Float64,Float64,Float64,Float64\)
```cj
public func setDriverInput(forward: Float64, steer: Float64, brake!: Float64 = 0.0, handBrake!: Float64 = 0.0): Unit
```
Sets the driver input (throttle/steer/brake/hand-brake)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|forward|Float64|Throttle (-1 reverse ~ 1 forward)steer Steering (-1 left ~ 1 right)brake Brake (0 ~ 1)handBrake Hand brake (0 ~ 1)|
|steer|Float64||
|brake|Float64||
|handBrake|Float64||

### prop chassis: PhysicsBodyHandle
```cj
public prop chassis: PhysicsBodyHandle
```
The chassis body handle (for further chassis control)

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the vehicle is valid (created successfully and not disposed)

### prop wheelCount: Int64
```cj
public prop wheelCount: Int64
```
The wheel count

