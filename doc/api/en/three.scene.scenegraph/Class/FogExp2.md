# Class
## class FogExp2
```cj
public class FogExp2
```
Exponential fog class, exponentially increasing opacity with distance

### func clone\(\)
```cj
public func clone(): FogExp2
```
Return a new exponential fog instance with the same values as this instance

Return: 

- New exponential fog instance

### func init\(\)
```cj
public init()
```
No-argument constructor (for fastjson deserialization)

### func init\(Color,Float64\)
```cj
public init(color: Color, density!: Float64 = 0.00025)
```
Construct a new exponential fog

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Fog colordensity Fog density, default 0.00025|
|density|Float64||

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, density!: Float64 = 0.00025)
```
Construct a new exponential fog with a hex color value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Hex color valuedensity Fog density, default 0.00025|
|density|Float64||

### var color
```cj
public var color: Color
```
Fog color

### var density
```cj
public var density: Float64
```
Fog density (exponential decay coefficient), default 0.00025

### var name
```cj
public var name: String
```
User-namable tag

