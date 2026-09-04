# Class
## class SphericalHarmonics3
```cj
public class SphericalHarmonics3
```
Spherical harmonics coefficient class, containing 9 third-order coefficient vectors

### func addScaledSH\(SphericalHarmonics3,Float64\)
```cj
public func addScaledSH(sh: SphericalHarmonics3, s: Float64): SphericalHarmonics3
```
Add scaled spherical harmonics coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Spherical harmonics to adds Scale factor|
|s|Float64||

Return: 

- This instance

### func add\(SphericalHarmonics3\)
```cj
public func add(sh: SphericalHarmonics3): SphericalHarmonics3
```
Add another spherical harmonics coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Spherical harmonics to add|

Return: 

- This instance

### func clone\(\)
```cj
public func clone(): SphericalHarmonics3
```
Clone current spherical harmonics coefficient

Return: 

- New instance

### func copy\(SphericalHarmonics3\)
```cj
public func copy(sh: SphericalHarmonics3): SphericalHarmonics3
```
Copy values from another spherical harmonics coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Source spherical harmonics|

Return: 

- This instance

### func equals\(SphericalHarmonics3\)
```cj
public func equals(sh: SphericalHarmonics3): Bool
```
Check if equal to another spherical harmonics coefficient

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Spherical harmonics to compare|

Return: 

- Whether equal

### func fromArray\(Array<Float64>,Int64\)
```cj
public func fromArray(array: Array < Float64 >, offset!: Int64 = 0): SphericalHarmonics3
```
Read coefficients from array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Arrayoffset Offset|
|offset|Int64||

Return: 

- This instance

### func getAt\(Vector3\)
```cj
public func getAt(normal: Vector3): Vector3
```
Get radiance at given normal direction (creates new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vector (should be unit vector)|

Return: 

- Radiance

### func getAt\(Vector3,Vector3\)
```cj
public func getAt(normal: Vector3, target: Vector3): Vector3
```
Get radiance at given normal direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vector (should be unit vector)target Target vector|
|target|Vector3||

Return: 

- Radiance

### func getBasisAt\(Vector3,Array<Float64>\)
```cj
public static func getBasisAt(normal: Vector3, shBasis: Array < Float64 >): Unit
```
Static method: compute spherical harmonics basis functions for given normal direction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vector (should be unit vector)shBasis Target array, length at least 9|
|shBasis|Array<Float64>||

### func getIrradianceAt\(Vector3,Vector3\)
```cj
public func getIrradianceAt(normal: Vector3, target: Vector3): Vector3
```
Get irradiance at given normal direction (convolution of radiance with cosine lobe)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vector (should be unit vector)target Target vector|
|target|Vector3||

Return: 

- Irradiance

### func getIrradianceAt\(Vector3\)
```cj
public func getIrradianceAt(normal: Vector3): Vector3
```
Get irradiance at given normal direction (creates new vector)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|normal|Vector3|Normal vector (should be unit vector)|

Return: 

- Irradiance

### func init\(\)
```cj
public init()
```


### func lerp\(SphericalHarmonics3,Float64\)
```cj
public func lerp(sh: SphericalHarmonics3, alpha: Float64): SphericalHarmonics3
```
Linearly interpolate between two spherical harmonics coefficients

Parameter: 

|Name|Type|Describe|
|---|---|---|
|sh|SphericalHarmonics3|Target spherical harmonicsalpha Interpolation factor|
|alpha|Float64||

Return: 

- This instance

### func scale\(Float64\)
```cj
public func scale(s: Float64): SphericalHarmonics3
```
Scale spherical harmonics coefficients

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|Float64|Scale factor|

Return: 

- This instance

### func set\(Array<Vector3>\)
```cj
public func set(coefficients: Array < Vector3 >): SphericalHarmonics3
```
Set spherical harmonics coefficients

Parameter: 

|Name|Type|Describe|
|---|---|---|
|coefficients|Array<Vector3>|Coefficient array|

Return: 

- This instance

### func toArray\(Array<Float64>,Int64\)
```cj
public func toArray(array: Array < Float64 >, offset!: Int64 = 0): Array < Float64 >
```
Write coefficients to array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Target arrayoffset Offset|
|offset|Int64||

Return: 

- Array

### func zero\(\)
```cj
public func zero(): SphericalHarmonics3
```
Zero all coefficients

Return: 

- This instance

### var coefficients
```cj
public var coefficients: Array < Vector3 >
```
Spherical harmonics coefficient array, containing 9 Vector3 instances

