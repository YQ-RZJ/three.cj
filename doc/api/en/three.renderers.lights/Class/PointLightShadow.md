# Class
## class PointLightShadow
```cj
public class PointLightShadow <: LightShadow
```
Shadow configuration specific to PointLight, with a perspective camera internally

### func computeFaceViewMatrix\(Vector3,Int64\)
```cj
public func computeFaceViewMatrix(lightPos: Vector3, faceIndex: Int64): Matrix4
```
Compute the view matrix for a 6-face cube shadow camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|lightPos|Vector3|Light world positionfaceIndex Face index (0..5)|
|faceIndex|Int64||

Return: 

- View matrix for that face

### func getCubeDirection\(Int64\)
```cj
public func getCubeDirection(faceIndex: Int64): Vector3
```
Get the direction vector for the specified face

Parameter: 

|Name|Type|Describe|
|---|---|---|
|faceIndex|Int64|Face index (0..5)|

Return: 

- Direction vector for that face

### func getCubeUp\(Int64\)
```cj
public func getCubeUp(faceIndex: Int64): Vector3
```
Get the up vector for the specified face

Parameter: 

|Name|Type|Describe|
|---|---|---|
|faceIndex|Int64|Face index (0..5)|

Return: 

- Up vector for that face

### func init\(\)
```cj
public init()
```
Construct a new point light shadow configuration

### func updateMatrices\(Light\)
```cj
public override func updateMatrices(light: Light): Unit
```
Override updateMatrices: point light shadow matrix is identity

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The light for which the shadow is being rendered|

### var cubeDirections
```cj
public var cubeDirections: ArrayList < Vector3 >
```
Direction vectors for 6-face cube shadow cameras (+X, -X, +Y, -Y, +Z, -Z)

### var cubeUps
```cj
public var cubeUps: ArrayList < Vector3 >
```
Up vectors for 6-face cube shadow cameras

