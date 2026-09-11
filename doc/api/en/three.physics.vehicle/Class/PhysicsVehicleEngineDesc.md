# Class
## class PhysicsVehicleEngineDesc
```cj
public class PhysicsVehicleEngineDesc
```
Engine and transmission description of a wheeled vehicle

### func init\(\)
```cj
public init()
```
Creates an engine/transmission description

### var clutchStrength
```cj
public var clutchStrength: Float64 = 10.0
```
Clutch strength

### var gearRatios
```cj
public var gearRatios: ArrayList < Float64 >= ArrayList < Float64 >([2.66, 1.78, 1.3, 1.0])
```
Forward gear ratios (index 0 = 1st gear)

### var maxRPM
```cj
public var maxRPM: Float64 = 6000.0
```
Maximum RPM (fuel cut above this value)

### var maxTorque
```cj
public var maxTorque: Float64 = 500.0
```
Engine maximum torque (N·m)

### var minRPM
```cj
public var minRPM: Float64 = 1000.0
```
Minimum RPM (idle below this value)

### var reverseGearRatios
```cj
public var reverseGearRatios: ArrayList < Float64 >= ArrayList < Float64 >([2.9])
```
Reverse gear ratios (positive; reversed internally)

### var shiftDownRPM
```cj
public var shiftDownRPM: Float64 = 2000.0
```
Shift-down RPM

### var shiftUpRPM
```cj
public var shiftUpRPM: Float64 = 5000.0
```
Shift-up RPM

### var switchLatency
```cj
public var switchLatency: Float64 = 0.5
```
Shift latency (seconds)

### var switchTime
```cj
public var switchTime: Float64 = 0.3
```
Shift transition time (seconds)

