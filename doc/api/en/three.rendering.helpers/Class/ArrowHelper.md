# Class
## class ArrowHelper
```cj
public class ArrowHelper <: Object3D
```
3D arrow helper for visualizing directions

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy from another arrow helper

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

### func init\(Vector3,Vector3,Float64,UInt32,Float64,Float64\)
```cj
public init(dir!: Vector3 = Vector3(0.0, 0.0, 1.0), origin!: Vector3 = Vector3(0.0, 0.0, 0.0), length!: Float64 = 1.0, color!: UInt32 = 0xffff00, headLength!: Float64 = 0.0, headWidth!: Float64 = 0.0)
```
Construct an arrow helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dir|Vector3|Direction vector (normalized), default +Z directionorigin Origin position, default originlength Arrow length (world units), default 1color Color, default yellow 0xffff00headLength Head length, default length * 0.2headWidth Head width, default headLength * 0.2|
|origin|Vector3||
|length|Float64||
|color|UInt32||
|headLength|Float64||
|headWidth|Float64||

### func setColor\(Color\)
```cj
public func setColor(color: Color): Unit
```
Set the color of the arrow

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|Color|Color value|

### func setDirection\(Vector3\)
```cj
public func setDirection(dir: Vector3): Unit
```
Set the direction of the arrow

Parameter: 

|Name|Type|Describe|
|---|---|---|
|dir|Vector3|Normalized direction vector|

### func setLength\(Float64,Float64,Float64\)
```cj
public func setLength(length: Float64, headLength: Float64, headWidth: Float64): Unit
```
Set the length of the arrow

Parameter: 

|Name|Type|Describe|
|---|---|---|
|length|Float64|Total lengthheadLength Head lengthheadWidth Head width|
|headLength|Float64||
|headWidth|Float64||

### var cone
```cj
public var cone: Mesh
```
Cone head of the arrow

### var line
```cj
public var line: Line
```
Line body of the arrow

