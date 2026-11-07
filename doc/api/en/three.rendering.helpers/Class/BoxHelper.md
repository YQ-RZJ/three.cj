# Class
## class BoxHelper
```cj
public class BoxHelper <: LineSegments & IReleasable
```
Box helper for visualizing the axis-aligned bounding box of an Object3D

### func copy\(Object3D,Bool\)
```cj
public override func copy(source: Object3D, recursive: Bool): Object3D
```
Copy from another box helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|Object3D|Source objectrecursive Whether to recursively copy children|
|recursive|Bool||

Return: 

- Self reference

### func init\(\)
```cj
public init()
```
Construct a box helper

### func init\(Object3D,UInt32\)
```cj
public init(object: Object3D, color!: UInt32 = 0xffff00)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D||
|color|UInt32||

### func release\(\)
```cj
public func release(): Bool
```
Release GPU resources

### func setFromObject\(Object3D\)
```cj
public func setFromObject(object: Object3D): BoxHelper
```
Change the monitored object and refresh the bounding box

Parameter: 

|Name|Type|Describe|
|---|---|---|
|object|Object3D|New monitored object|

Return: 

- Self reference

### func update\(\)
```cj
public func update(): Unit
```
Update bounding box vertex data

### var object
```cj
public var object: Object3D
```
The object being monitored

