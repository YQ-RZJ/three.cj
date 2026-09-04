# 类
## class InputEngine
```cj
public class InputEngine
```
输入引擎：键盘/鼠标/手柄/触摸状态查询的统一门面

### func bindWindow\(WindowEngine\)
```cj
public func bindWindow(win: WindowEngine): Unit
```
绑定窗口引擎（Provider 状态来源）

参数: 

|名称|类型|描述|
|---|---|---|
|win|WindowEngine||

### func closeGamepad\(\)
```cj
public func closeGamepad(): Unit
```
关闭手柄

### func getGamepadAxis\(GamepadAxis\)
```cj
public func getGamepadAxis(axis: GamepadAxis): Int16
```
获取手柄轴值（范围 -32768 ~ 32767）

参数: 

|名称|类型|描述|
|---|---|---|
|axis|GamepadAxis||

返回: 

- 轴值；未连接返回 0

### func getGamepadButton\(GamepadButton\)
```cj
public func getGamepadButton(button: GamepadButton): Bool
```
获取手柄按键状态

参数: 

|名称|类型|描述|
|---|---|---|
|button|GamepadButton||

返回: 

- 是否按下；未连接返回 false

### func getGamepadInstanceID\(\)
```cj
public func getGamepadInstanceID(): Int64
```
获取手柄实例 ID

返回: 

- 手柄实例 ID；未打开返回 -1

### func getGamepadName\(\)
```cj
public func getGamepadName(): String
```
获取手柄名称

返回: 

- 手柄名称；未连接返回空串

### func getMouseDX\(\)
```cj
public func getMouseDX(): Float32
```
获取鼠标本帧 X 位移

返回: 

- 鼠标 X 位移；未绑定窗口返回 0.0

### func getMouseDY\(\)
```cj
public func getMouseDY(): Float32
```
获取鼠标本帧 Y 位移

返回: 

- 鼠标 Y 位移；未绑定窗口返回 0.0

### func getMouseX\(\)
```cj
public func getMouseX(): Float32
```
获取鼠标 X 坐标（相对窗口）

返回: 

- 鼠标 X 坐标；未绑定窗口返回 0.0

### func getMouseY\(\)
```cj
public func getMouseY(): Float32
```
获取鼠标 Y 坐标（相对窗口）

返回: 

- 鼠标 Y 坐标；未绑定窗口返回 0.0

### func getTouchByID\(Int64\)
```cj
public func getTouchByID(fingerID: Int64): Option < TouchPoint >
```
获取指定 fingerID 的触摸点

参数: 

|名称|类型|描述|
|---|---|---|
|fingerID|Int64|手指实例 ID|

返回: 

- 触摸点数据；未找到或未绑定窗口返回 None

### func getTouchCount\(\)
```cj
public func getTouchCount(): Int64
```
获取当前活跃触摸点数量

返回: 

- 触摸点数量；未绑定窗口返回 0

### func getTouch\(Int64\)
```cj
public func getTouch(index: Int64): Option < TouchPoint >
```
获取指定索引的触摸点

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|触摸点索引（0-based）|

返回: 

- 触摸点数据；索引越界或未绑定窗口返回 None

### func getWheelX\(\)
```cj
public func getWheelX(): Float32
```
获取滚轮水平滚动量（本帧累积）

返回: 

- 水平滚动量；未绑定窗口返回 0.0

### func getWheelY\(\)
```cj
public func getWheelY(): Float32
```
获取滚轮垂直滚动量（本帧累积）

返回: 

- 垂直滚动量；未绑定窗口返回 0.0

### func getWindow\(\)
```cj
public func getWindow(): Option < WindowEngine >
```
获取当前绑定的窗口引擎

返回: 

- 绑定的窗口引擎；未绑定时返回 None

### func init\(\)
```cj
public init()
```
构造输入引擎

### func isGamepadConnected\(\)
```cj
public func isGamepadConnected(): Bool
```
查询手柄是否已连接

返回: 

- 已连接返回 true；未打开返回 false

### func isKeyDown\(UInt32\)
```cj
public func isKeyDown(scancode: UInt32): Bool
```
查询键盘某键当前是否按下（scancode 为 SDL_SCANCODE_*）

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32||

返回: 

- 按下返回 true；未绑定窗口或未注册 KeyboardProvider 返回 false

### func isKeyPressed\(UInt32\)
```cj
public func isKeyPressed(scancode: UInt32): Bool
```
查询键盘某键本帧是否刚按下（边沿触发）

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32||

返回: 

- 刚按下返回 true；未绑定窗口返回 false

### func isKeyReleased\(UInt32\)
```cj
public func isKeyReleased(scancode: UInt32): Bool
```
查询键盘某键本帧是否刚释放（边沿触发）

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32||

返回: 

- 刚释放返回 true；未绑定窗口返回 false

### func isMouseButtonDown\(UInt8\)
```cj
public func isMouseButtonDown(button: UInt8): Bool
```
查询鼠标按键是否按下（button 为 SDL_BUTTON_*）

参数: 

|名称|类型|描述|
|---|---|---|
|button|UInt8||

返回: 

- 按下返回 true；未绑定窗口返回 false

### func openGamepadAt\(Int32\)
```cj
public func openGamepadAt(index: Int32): Bool
```
打开指定索引的手柄

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int32||

返回: 

- 是否成功

### func openGamepad\(\)
```cj
public func openGamepad(): Bool
```
打开第一个已连接的手柄

返回: 

- 是否成功

