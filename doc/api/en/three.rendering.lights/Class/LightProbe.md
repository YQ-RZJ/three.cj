# Class
## class LightProbe
```cj
public class LightProbe <: Light
```
Light probe using spherical harmonics to describe scene lighting environment

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from another light probe instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Self reference

### func init\(SphericalHarmonics3,Float64\)
```cj
public init(sh!: SphericalHarmonics3 = SphericalHarmonics3(), intensity!: Float64 = 1.0)
```
Construct a new light probe

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Spherical harmonics coefficients, default empty SH3intensity Light intensity, default 1|
|intensity|Float64||

### var sh
```cj
public var sh: SphericalHarmonics3
```
Spherical harmonics coefficients describing scene lighting

