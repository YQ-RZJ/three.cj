# Class
## class PlaneHelper
```cj
public class PlaneHelper <: Line
```
Plane helper for visualizing Plane objects

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose GPU resources

### func init\(Plane,Float64,UInt32\)
```cj
public init(plane: Plane, size!: Float64 = 1.0, hex!: UInt32 = 0xffff00)
```
Construct a plane helper

Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane|The plane to visualizesize Edge length, default 1hex Color, default yellow 0xffff00|
|size|Float64||
|hex|UInt32||

### func updateMatrixWorld\(Bool\)
```cj
public override func updateMatrixWorld(force: Bool): Unit
```
Update world matrix, transforming the plane to the correct position

Parameter: 

|Name|Type|Describe|
|---|---|---|
|force|Bool|Whether to force update|

### var plane
```cj
public var plane: Plane
```
The plane being visualized

### var size
```cj
public var size: Float64
```
Helper line edge length

