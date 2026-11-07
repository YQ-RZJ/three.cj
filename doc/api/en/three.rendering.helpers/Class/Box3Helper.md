# Class
## class Box3Helper
```cj
public class Box3Helper <: LineSegments & IReleasable
```
Box3 axis-aligned bounding box helper

### func init\(\)
```cj
public init()
```
Construct a Box3 helper

### func init\(Box3,UInt32\)
```cj
public init(box: Box3, color!: UInt32 = 0xffff00)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|box|Box3||
|color|UInt32||

### func release\(\)
```cj
public func release(): Bool
```
Release GPU resources

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

