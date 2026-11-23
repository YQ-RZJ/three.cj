# Class
## class RectAreaLight
```cj
public class RectAreaLight <: Light
```
A light that emits from a rectangular area

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy the values from the given rectangular area light instance to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy child objects|
|recursive|Bool||

Return: 

- This instance

### func init\(Color,Float64,Float64,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0, width!: Float64 = 10.0, height!: Float64 = 10.0)
```
Construct a new rectangular area light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1width Rectangle width, default 10height Rectangle height, default 10|
|intensity|Float64||
|width|Float64||
|height|Float64||

### prop power: Float64
```cj
public mut prop power: Float64
```
Direct access to the rectangular area light power (lumens)

### var height
```cj
public var height: Float64
```
Rectangle height, default 10

### var width
```cj
public var width: Float64
```
Rectangle width, default 10

