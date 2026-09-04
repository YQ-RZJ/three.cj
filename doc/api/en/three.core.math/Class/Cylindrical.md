# Class
## class Cylindrical
```cj
public class Cylindrical
```
Cylindrical coordinates class for representing points in 3D space

### func clone\(\)
```cj
public func clone(): Cylindrical
```
Clone the current cylindrical coordinates

Return: 

- New cylindrical coordinate instance

### func copy\(Cylindrical\)
```cj
public func copy(other: Cylindrical): Cylindrical
```
Copy values from another cylindrical coordinate to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|Cylindrical|Cylindrical coordinate to copy|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct default cylindrical coordinates (1, 0, 0)

### func init\(Float64,Float64,Float64\)
```cj
public init(radius: Float64, theta: Float64, y: Float64)
```
Construct cylindrical coordinates with specified components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radiustheta Angle (radians)y Height|
|theta|Float64||
|y|Float64||

### func setFromCartesianCoords\(Float64,Float64,Float64\)
```cj
public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Cylindrical
```
Set cylindrical coordinates from Cartesian coordinates

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
public func setFromVector3(v: Vector3): Cylindrical
```
Set cylindrical coordinates from a Cartesian coordinate vector

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Vector3|Vector containing Cartesian coordinates|

Return: 

- This instance

### func set\(Float64,Float64,Float64\)
```cj
public func set(radius: Float64, theta: Float64, y: Float64): Cylindrical
```
Set cylindrical coordinate components

Parameter: 

|Name|Type|Describe|
|---|---|---|
|radius|Float64|Radiustheta Angle (radians)y Height|
|theta|Float64||
|y|Float64||

Return: 

- This instance

### var radius
```cj
public var radius: Float64
```
Distance from origin to a point on the xz plane

### var theta
```cj
public var theta: Float64
```
Angle measured counterclockwise from the positive z axis on the xz plane (radians)

### var y
```cj
public var y: Float64
```
Height above the xz plane

