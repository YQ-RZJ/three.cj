# Class
## class HemisphereLight
```cj
public class HemisphereLight <: Light
```
Hemisphere light illuminating from sky and ground directions

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from another hemisphere light instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Self reference

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Dispose GPU resources

### func init\(Color,Color,Float64\)
```cj
public init(skyColor!: Color = Color(0xffffff), groundColor!: Color = Color(0x000000), intensity!: Float64 = 1.0)
```
Construct a new hemisphere light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skyColor|Color|Sky direction light color, default 0xffffffgroundColor Ground direction light color, default 0x000000intensity Light intensity, default 1|
|groundColor|Color||
|intensity|Float64||

### var groundColor
```cj
public var groundColor: Color
```
Ground (bottom) direction light color

### var skyColor
```cj
public var skyColor: Color
```
Sky (top) direction light color

