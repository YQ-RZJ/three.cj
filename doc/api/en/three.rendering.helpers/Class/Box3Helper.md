# Class
## class Box3Helper
```cj
public class Box3Helper <: LineSegments
```
Box3 axis-aligned bounding box helper

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Box3,UInt32\)
```cj
public init(box: Box3, color!: UInt32 = 0xffff00)
```
Construct a Box3 helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3|The Box3 bounding box to visualizecolor Wireframe color, default yellow 0xffff00|
|color|UInt32||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Update world matrix, adjusting position and scale based on bounding box center and size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force update|

### var box
```cj
public var box: Box3
```
The bounding box being visualized

