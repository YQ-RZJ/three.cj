# Class
## class SkeletonHelper
```cj
public class SkeletonHelper <: LineSegments
```
Skeleton helper for visualizing Skeleton bone hierarchy

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Object3D\)
```cj
public init(object: Object3D)
```
Construct a skeleton helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|Root object of the bone hierarchy, typically a SkinnedMesh or Object3D containing Bones|

### func setColors\(Color,Color\)
```cj
public func setColors(color1: Color, color2: Color): SkeletonHelper
```
Set bone colors

Parameter: 

|Name|Type|Describe|
|---|---|---|
|color1|Color|Start color (blue 0x0000ff)color2 End color (green 0x00ff00)|
|color2|Color||

Return: 

- Self reference

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Update world matrix, computing bone positions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force update|

### var bones
```cj
public var bones: ArrayList < Bone >
```
Bone list

### var root
```cj
public var root: Object3D
```
Root object

