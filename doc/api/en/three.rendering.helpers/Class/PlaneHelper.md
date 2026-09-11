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

### func init\(\)
```cj
public init()
```
Construct a plane helper

### func init\(Plane,Float64,UInt32\)
```cj
public init(plane: Plane, size!: Float64 = 1.0, hex!: UInt32 = 0xffff00)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|plane|Plane||
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

