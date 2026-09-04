# Class
## class Spherical
```cj
public class Spherical
```
Spherical coordinates class for representing points in 3D space

### func clone\(\)
```cj
public func clone(): Spherical
```
Clone current spherical coordinates

Return: 

- New spherical coordinates instance

### func copy\(Spherical\)
```cj
public func copy(other: Spherical): Spherical
```
Copy values from another spherical coordinates to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|Spherical|Spherical coordinates to copy|

Return: 

- This instance

### func init\(\)
```cj
public init()
```


### func init\(Float64,Float64,Float64\)
```cj
public init(radius: Float64, phi: Float64, theta: Float64)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64||
|phi|Float64||
|theta|Float64||

### func makeSafe\(\)
```cj
public func makeSafe(): Spherical
```
Clamp polar angle phi to [0.000001, π - 0.000001] range to avoid pole singularity

Return: 

- This instance

### func setFromCartesianCoords\(Float64,Float64,Float64\)
```cj
public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Spherical
```
Set spherical coordinates from Cartesian coordinates

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|x coordinatey y coordinatez z coordinate|
|y|Float64||
|z|Float64||

Return: 

- This instance

### func setFromVector3\(Vector3\)
```cj
public func setFromVector3(v: Vector3): Spherical
```
Set spherical coordinates from Cartesian coordinate vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector containing Cartesian coordinates|

Return: 

- This instance

### func set\(Float64,Float64,Float64\)
```cj
public func set(radius: Float64, phi: Float64, theta: Float64): Spherical
```
Set spherical coordinate components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radiusphi Polar angle in radianstheta Azimuthal angle in radians|
|phi|Float64||
|theta|Float64||

Return: 

- This instance

### func toVector3\(\)
```cj
public func toVector3(): Vector3
```
Convert spherical coordinates to 3D vector

Return: 

- Corresponding 3D vector

### var phi
```cj
public var phi: Float64
```
Polar angle from the y (up) axis in radians

### var radius
```cj
public var radius: Float64
```
Radius, the Euclidean distance from origin to point

### var theta
```cj
public var theta: Float64
```
Azimuthal angle around the y (up) axis in radians

