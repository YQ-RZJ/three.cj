# Class
## class PhysicsVehicleWheelDesc
```cj
public class PhysicsVehicleWheelDesc
```
Wheel description of a wheeled vehicle

### func init\(Vector3\)
```cj
public init(position!: Vector3)
```
Creates a wheel description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|position|Vector3|The mount position (chassis local space)|

### var angularDamping
```cj
public var angularDamping: Float64 = 0.2
```
Wheel angular damping

### var inertia
```cj
public var inertia: Float64 = 0.5
```
Wheel rotational inertia

### var lateralFriction
```cj
public var lateralFriction: Float64 = 1.0
```
Tire lateral friction coefficient

### var longitudinalFriction
```cj
public var longitudinalFriction: Float64 = 1.0
```
Tire longitudinal friction coefficient

### var maxBrakeTorque
```cj
public var maxBrakeTorque: Float64 = 1500.0
```
Maximum brake torque (N·m)

### var maxHandBrakeTorque
```cj
public var maxHandBrakeTorque: Float64 = 0.0
```
Maximum hand-brake torque (N·m; 0 = no hand-brake response)

### var maxSteerAngle
```cj
public var maxSteerAngle: Float64 = 0.0
```
Maximum steer angle (radians; 0 = no steering)

### var position
```cj
public var position: Vector3 = Vector3(0.0, 0.0, 0.0)
```
Wheel mount position (chassis local space)

### var radius
```cj
public var radius: Float64 = 0.3
```
Wheel radius (meters)

### var suspensionDamping
```cj
public var suspensionDamping: Float64 = 0.5
```
Suspension damping ratio (0~1)

### var suspensionFrequency
```cj
public var suspensionFrequency: Float64 = 1.5
```
Suspension natural frequency (Hz, mode=Frequency)

### var suspensionMaxLength
```cj
public var suspensionMaxLength: Float64 = 0.5
```
Suspension maximum length (meters, fully extended)

### var suspensionMinLength
```cj
public var suspensionMinLength: Float64 = 0.3
```
Suspension minimum length (meters, fully compressed)

### var width
```cj
public var width: Float64 = 0.2
```
Wheel width (meters)

