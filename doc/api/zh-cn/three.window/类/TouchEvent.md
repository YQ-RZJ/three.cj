# 类
## class TouchEvent
```cj
public class TouchEvent
```
触摸事件

### func init\(Int64,Float32,Float32,Float32,Float32,Float32\)
```cj
public init(fingerID!: Int64, x!: Float32, y!: Float32, dx!: Float32, dy!: Float32, pressure!: Float32)
```
构造触摸事件

参数: 

|名称|类型|描述|
|---|---|---|
|fingerID|Int64|触摸手指实例 IDx 归一化 X 坐标（0~1，相对窗口）y 归一化 Y 坐标（0~1，相对窗口）dx 归一化 X 位移dy 归一化 Y 位移pressure 压力（0~1）|
|x|Float32||
|y|Float32||
|dx|Float32||
|dy|Float32||
|pressure|Float32||

### var dx
```cj
public var dx: Float32 = 0.0
```
归一化 X 位移

### var dy
```cj
public var dy: Float32 = 0.0
```
归一化 Y 位移

### var fingerID
```cj
public var fingerID: Int64 = 0
```
触摸手指实例 ID

### var pressure
```cj
public var pressure: Float32 = 0.0
```
压力（0~1）

### var x
```cj
public var x: Float32 = 0.0
```
归一化 X 坐标（0~1，相对窗口）

### var y
```cj
public var y: Float32 = 0.0
```
归一化 Y 坐标（0~1，相对窗口）

