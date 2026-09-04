# 类
## class MouseWheelEvent
```cj
public class MouseWheelEvent
```
鼠标滚轮事件

### func init\(Float32,Float32\)
```cj
public init(x!: Float32, y!: Float32)
```
构造鼠标滚轮事件

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|水平滚动量（通常 -1/0/1）y 垂直滚动量（通常 -1/0/1，向上为正）|
|y|Float32||

### var x
```cj
public var x: Float32 = 0.0
```
水平滚动量（通常 -1/0/1）

### var y
```cj
public var y: Float32 = 0.0
```
垂直滚动量（通常 -1/0/1，向上为正）

