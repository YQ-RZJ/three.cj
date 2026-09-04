# 类
## class MouseProvider
```cj
public class MouseProvider <: InputProvider
```
鼠标输入提供者

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
帧末重置边沿状态和累积量

### func getMouseDX\(\)
```cj
public func getMouseDX(): Float32
```
获取鼠标本帧 X 位移（累积）

返回: 

- 鼠标 X 位移

### func getMouseDY\(\)
```cj
public func getMouseDY(): Float32
```
获取鼠标本帧 Y 位移（累积）

返回: 

- 鼠标 Y 位移

### func getMouseX\(\)
```cj
public func getMouseX(): Float32
```
获取鼠标 X 坐标（相对窗口）

返回: 

- 鼠标 X 坐标

### func getMouseY\(\)
```cj
public func getMouseY(): Float32
```
获取鼠标 Y 坐标（相对窗口）

返回: 

- 鼠标 Y 坐标

### func getWheelX\(\)
```cj
public func getWheelX(): Float32
```
获取滚轮水平滚动量（本帧累积）

返回: 

- 水平滚动量

### func getWheelY\(\)
```cj
public func getWheelY(): Float32
```
获取滚轮垂直滚动量（本帧累积）

返回: 

- 垂直滚动量

### func init\(\)
```cj
public init()
```
构造鼠标提供者

### func isMouseButtonDown\(UInt8\)
```cj
public func isMouseButtonDown(button: UInt8): Bool
```
查询鼠标按键是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|button|UInt8|鼠标按键（SDL_BUTTON_*，如 SDL_BUTTON_LEFT=1）|

返回: 

- 按下返回 true，否则 false

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
处理鼠标事件

参数: 

|名称|类型|描述|
|---|---|---|
|evt|DispatchEvent|分发事件|

