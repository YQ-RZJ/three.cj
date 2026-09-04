# 类
## class ArrayCamera
```cj
public class ArrayCamera <: PerspectiveCamera & IArrayCameraSource
```
数组相机，管理一组 PerspectiveCamera 子相机

### func getCameraCount\(\)
```cj
public func getCameraCount(): Int64
```
子相机数量（对照 JS: cameraArray.cameras.length）

返回: 

- 数量

### func getCameraMatrixWorldInverseElements\(Int64\)
```cj
public func getCameraMatrixWorldInverseElements(i: Int64): Array < Float64 >
```
第 i 个子相机的视图矩阵逆元素（16 个，列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子相机索引|

返回: 

- 视图矩阵逆元素数组

### func getCameraProjectionElements\(Int64\)
```cj
public func getCameraProjectionElements(i: Int64): Array < Float64 >
```
第 i 个子相机的投影矩阵元素（16 个，列主序）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64|子相机索引|

返回: 

- 投影矩阵元素数组

### func init\(ArrayList<PerspectiveCamera>\)
```cj
public init(cameras!: ArrayList < PerspectiveCamera >= ArrayList < PerspectiveCamera >())
```
构造一个新的数组相机

参数: 

|名称|类型|描述|
|---|---|---|
|cameras|ArrayList<PerspectiveCamera>|子相机数组，默认空数组|

### var cameras
```cj
public var cameras: ArrayList < PerspectiveCamera >
```
子相机数组。每个子相机是一独立 PerspectiveCamera，对应一个视口

### var isMultiViewCamera
```cj
public var isMultiViewCamera: Bool
```
是否多视图相机（与 ArrayCamera 类似但语义不同，渲染器内部用）

