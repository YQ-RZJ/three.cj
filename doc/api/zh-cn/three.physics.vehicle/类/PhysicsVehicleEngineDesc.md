# 类
## class PhysicsVehicleEngineDesc
```cj
public class PhysicsVehicleEngineDesc
```
轮式载具引擎与变速箱描述

### func init\(\)
```cj
public init()
```
构造引擎/变速箱描述

### var clutchStrength
```cj
public var clutchStrength: Float64 = 10.0
```
离合器强度

### var gearRatios
```cj
public var gearRatios: ArrayList < Float64 >= ArrayList < Float64 >([2.66, 1.78, 1.3, 1.0])
```
前进档位比列表（索引 0 = 1 档）

### var maxRPM
```cj
public var maxRPM: Float64 = 6000.0
```
最大 RPM（超过此值断油）

### var maxTorque
```cj
public var maxTorque: Float64 = 500.0
```
引擎最大扭矩（牛顿·米）

### var minRPM
```cj
public var minRPM: Float64 = 1000.0
```
最小 RPM（低于此值怠速）

### var reverseGearRatios
```cj
public var reverseGearRatios: ArrayList < Float64 >= ArrayList < Float64 >([2.9])
```
倒车档位比列表（正值，内部取反向）

### var shiftDownRPM
```cj
public var shiftDownRPM: Float64 = 2000.0
```
降档转速（RPM）

### var shiftUpRPM
```cj
public var shiftUpRPM: Float64 = 5000.0
```
升档转速（RPM）

### var switchLatency
```cj
public var switchLatency: Float64 = 0.5
```
换挡延迟（秒）

### var switchTime
```cj
public var switchTime: Float64 = 0.3
```
换挡过渡时间（秒）

