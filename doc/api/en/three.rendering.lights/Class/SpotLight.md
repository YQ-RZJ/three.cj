# Class
## class SpotLight
```cj
public open class SpotLight <: Light
```
A light that emits from a point in a cone shape along a direction

### func copy\(Object3D,Bool\)
```cj
public open override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy the values from the given spot light instance to this instance

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

### func init\(Color,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, distance!: Float64 = 0.0, angle!: Float64 = PI / 3.0, penumbra!: Float64 = 0.0, decay!: Float64 = 2.0)
```
Construct a new spot light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1distance Light range, default 0angle Cone vertex angle (radians), default π/3penumbra Penumbra size, default 0decay Physical decay coefficient, default 2|
|intensity|Float64||
|distance|Float64||
|angle|Float64||
|penumbra|Float64||
|decay|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
Direct access to the spot light power (lumens)

### var angle
```cj
public var angle: Float64
```
The angle at the cone vertex (radians), range [0, π/2], default π/3

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

### var map
```cj
public var map: Option < Texture >
```
Texture modulating the spotlight light, default null

### var penumbra
```cj
public var penumbra: Float64
```
Penumbra size, 0=hard edge cone, 1=fully soft edge, default 0

### var shadow
```cj
public var shadow: SpotLightShadow
```
Shadow configuration object

### var target
```cj
public var target: Object3D
```
The target object the light points to, affecting the light direction

