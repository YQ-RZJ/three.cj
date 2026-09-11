# Class
## class PhysicsVehicleDesc
```cj
public class PhysicsVehicleDesc
```
Wheeled vehicle description

### func init\(PhysicsBodyDesc\)
```cj
public init(chassisDesc!: PhysicsBodyDesc)
```
Creates a vehicle description

Parameter: 

|Name|Type|Describe|
|---|---|---|
|chassisDesc|PhysicsBodyDesc|The chassis body description|

### var chassisDesc
```cj
public var chassisDesc: PhysicsBodyDesc
```
Chassis body description (shape/mass/friction etc.)

### var drivenWheels
```cj
public var drivenWheels: ArrayList < Int64 >= ArrayList < Int64 >()
```
Driven wheel indices (differentials are created pairwise from this;
empty = single differential driving all wheels)

### var engine
```cj
public var engine: PhysicsVehicleEngineDesc = PhysicsVehicleEngineDesc()
```
Engine and transmission configuration

### var maxPitchRollAngle
```cj
public var maxPitchRollAngle: Float64 = 0.0
```
Maximum pitch/roll angle (radians, 0 = unlimited)

### var wheels
```cj
public var wheels: ArrayList < PhysicsVehicleWheelDesc >= ArrayList < PhysicsVehicleWheelDesc >()
```
Wheel list (index = wheel index)

