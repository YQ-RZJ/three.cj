# Class
## class PointLight
```cj
public class PointLight <: Light
```
A light that emits uniformly in all directions from a point

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy the values from the given point light instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy child objects|
|recursive|Bool||

Return: 

- This instance

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Dispose GPU-related resources allocated by this instance, should be called when the instance is no longer used

### func init\(Color,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, decay!: Float64 = 2.0)
```
Construct a new point light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1distance Light range, default 0decay Physical decay coefficient, default 2|
|intensity|Float64||
|distance|Float64||
|decay|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
Direct access to the point light power (lumens)

### var decay
```cj
public var decay: Float64
```
Physical decay coefficient along the light direction, 1=constant, 2=physically correct, default 2

### var distance
```cj
public var distance: Float64
```
Light range, 0 means no decay, default 0

### var shadow
```cj
public var shadow: PointLightShadow
```
Shadow configuration object

