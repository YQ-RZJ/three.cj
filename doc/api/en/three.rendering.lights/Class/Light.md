# Class
## class Light
```cj
public open class Light <: Object3D
```
Abstract base class for all light types

### func copy\(Object3D,Bool\)
```cj
public open func copy(source: Object3D, recursive: Bool): Object3D
```
Copy values from another light instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Self reference

### func dispose\(\)
```cj
public open func dispose(): Unit
```
Dispose GPU resources

### func init\(Color,Float64\)
```cj
public init(color!: Color = Color(0xffffff), intensity!: Float64 = 1.0)
```
Construct a new light

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Light color, default 0xffffffintensity Light intensity, default 1|
|intensity|Float64||

### func init\(UInt32,Float64\)
```cj
public init(hex: UInt32, intensity!: Float64 = 1.0)
```
Construct a new light with UInt32 color value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|hex|UInt32|Color hexadecimal valueintensity Light intensity, default 1|
|intensity|Float64||

### var color
```cj
public var color: Color
```
Light color

### var intensity
```cj
public var intensity: Float64
```
Light intensity, default 1

