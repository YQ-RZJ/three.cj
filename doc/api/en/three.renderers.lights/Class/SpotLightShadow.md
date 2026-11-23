# Class
## class SpotLightShadow
```cj
public class SpotLightShadow <: LightShadow
```
Shadow configuration specific to SpotLight, dynamically adjusts camera frustum based on light angle

### func copy\(LightShadow\)
```cj
public func copy(source: LightShadow): LightShadow
```
Copy the values from the given SpotLightShadow instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|LightShadow|Source light shadow instance|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new spot light shadow configuration

### func updateMatrices\(Light\)
```cj
public func updateMatrices(light: Light): Unit
```
Update the shadow camera projection matrix and shadow matrix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|light|Light|The SpotLight instance for which the shadow is being rendered|

### var aspect
```cj
public var aspect: Float64
```
Texture aspect ratio correction factor, final aspect=(mapSize.width/mapSize.height)×this.aspect, default 1

### var focus
```cj
public var focus: Float64
```
Focus factor, camera FOV=light angle×focus×RAD2DEG, range [0,1], default 1

