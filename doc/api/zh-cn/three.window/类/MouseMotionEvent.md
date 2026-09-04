# 类
## class MouseMotionEvent
```cj
public class MouseMotionEvent
```
鼠标移动事件

### func init\(Float32,Float32,Float32,Float32\)
```cj
public init(x!: Float32, y!: Float32, dx!: Float32, dy!: Float32)
```
构造鼠标移动事件

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|相对窗口的 X 坐标y 相对窗口的 Y 坐标dx 相对上一帧的 X 位移dy 相对上一帧的 Y 位移|
|y|Float32||
|dx|Float32||
|dy|Float32||

### var dx
```cj
public var dx: Float32 = 0.0
```
相对上一帧的 X 位移

### var dy
```cj
public var dy: Float32 = 0.0
```
相对上一帧的 Y 位移

### var x
```cj
public var x: Float32 = 0.0
```
相对窗口的 X 坐标

### var y
```cj
public var y: Float32 = 0.0
```
相对窗口的 Y 坐标

