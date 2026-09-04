# Class
## class ArrayCamera
```cj
public class ArrayCamera <: PerspectiveCamera & IArrayCameraSource
```
Array camera, manages a group of PerspectiveCamera sub-cameras

### func getCameraCount\(\)
```cj
public func getCameraCount(): Int64
```
Sub-camera count (corresponding to JS: cameraArray.cameras.length)

Return: 

- Count

### func getCameraMatrixWorldInverseElements\(Int64\)
```cj
public func getCameraMatrixWorldInverseElements(i: Int64): Array < Float64 >
```
Inverse view matrix elements of the i-th sub-camera (16 elements, column-major)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Sub-camera index|

Return: 

- Inverse view matrix elements array

### func getCameraProjectionElements\(Int64\)
```cj
public func getCameraProjectionElements(i: Int64): Array < Float64 >
```
Projection matrix elements of the i-th sub-camera (16 elements, column-major)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64|Sub-camera index|

Return: 

- Projection matrix elements array

### func init\(ArrayList<PerspectiveCamera>\)
```cj
public init(cameras!: ArrayList < PerspectiveCamera >= ArrayList < PerspectiveCamera >())
```
Construct a new array camera

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cameras|ArrayList<PerspectiveCamera>|Sub-camera array, default empty array|

### var cameras
```cj
public var cameras: ArrayList < PerspectiveCamera >
```
Sub-camera array. Each sub-camera is an independent PerspectiveCamera corresponding to a viewport

### var isMultiViewCamera
```cj
public var isMultiViewCamera: Bool
```
Whether multi-view camera (similar to ArrayCamera but different semantics, used internally by renderer)

