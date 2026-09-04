# Class
## class DirectionalLight
```cj
public class DirectionalLight <: Light
```
Directional light that illuminates the scene from a specific direction

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from another directional light instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Self reference

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
Construct a new directional light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1|
|intensity|Float64||

### var shadow
```cj
public var shadow: DirectionalLightShadow
```
Shadow configuration object

### var target
```cj
public var target: Object3D
```
Target object the light is pointing at

