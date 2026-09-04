# 类
## class CameraHelper
```cj
public class CameraHelper <: LineSegments
```
相机视锥体辅助对象，用于可视化相机的视锥体

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源

### func init\(Camera\)
```cj
public init(camera: Camera)
```
构造相机辅助对象

参数: 

|名称|类型|描述|
|---|---|---|
|camera|Camera|要可视化的相机|

### func setColors\(Color,Color,Color,Color,Color\)
```cj
public func setColors(frustum: Color, cone: Color, up: Color, target: Color, cross: Color): CameraHelper
```
设置辅助对象各分段的颜色

参数: 

|名称|类型|描述|
|---|---|---|
|frustum|Color|视锥线颜色cone 锥体线颜色up 上方向线颜色target 目标线颜色cross 十字线颜色|
|cone|Color||
|up|Color||
|target|Color||
|cross|Color||

返回: 

- 自身引用

### func update\(\)
```cj
public func update(): Unit
```
更新相机视锥体线框

### var camera
```cj
public var camera: Camera
```
被可视化的相机

### var pointMap
```cj
public var pointMap: HashMap < String, ArrayList < Int64 >>
```
顶点映射表：点名称到几何体中的顶点索引数组

