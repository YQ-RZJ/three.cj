# 类
## class StereoCamera
```cj
public class StereoCamera
```
立体相机

### func init\(\)
```cj
public init()
```
构造立体相机

### func update\(PerspectiveCamera\)
```cj
public func update(camera: PerspectiveCamera): Unit
```
同步本立体相机与给定主相机。主相机投影变化时重新计算左右眼投影矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|camera|PerspectiveCamera|主透视相机|

### var aspect
```cj
public var aspect: Float64
```
宽高比，左右眼共用

### var cameraL
```cj
public var cameraL: PerspectiveCamera
```
左眼相机

### var cameraR
```cj
public var cameraR: PerspectiveCamera
```
右眼相机

### var eyeSep
```cj
public var eyeSep: Float64
```
左右眼间距（米），默认 0.064

### var kind
```cj
public var kind: String
```
类型标签

