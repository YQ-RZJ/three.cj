# 类
## class MouseButtonEvent
```cj
public class MouseButtonEvent
```
鼠标按键事件

### func init\(UInt8,Bool,UInt8,Float32,Float32\)
```cj
public init(button!: UInt8, down!: Bool, clicks!: UInt8, x!: Float32, y!: Float32)
```
构造鼠标按键事件

参数: 

|名称|类型|描述|
|---|---|---|
|button|UInt8|鼠标按键索引（SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2）down 是否按下clicks 点击次数（1 单击，2 双击）x 相对窗口的 X 坐标y 相对窗口的 Y 坐标|
|down|Bool||
|clicks|UInt8||
|x|Float32||
|y|Float32||

### var button
```cj
public var button: UInt8 = 0
```
鼠标按键索引（SDL_BUTTON_LEFT=1 / RIGHT=3 / MIDDLE=2）

### var clicks
```cj
public var clicks: UInt8 = 0
```
点击次数（1 单击，2 双击）

### var down
```cj
public var down: Bool = false
```
是否按下

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

