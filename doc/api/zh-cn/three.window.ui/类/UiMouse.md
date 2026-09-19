# 类
## class UiMouse
```cj
public class UiMouse
```
鼠标状态查询工具类（静态方法，封装 ImGui 鼠标查询/设置 API）

### func getMouseCursor\(\)
```cj
public static func getMouseCursor(): Int32
```
获取当前鼠标光标类型

返回: 

- 当前光标类型（ImGuiMouseCursor 枚举值）

### func getMouseDragDelta\(Int32,Float32\)
```cj
public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0f32): ImVec2
```
获取鼠标拖拽增量

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|拖拽按钮索引（默认 0=左键）|
|lockThreshold|Float32|锁定阈值（默认 -1.0，使用 ImGui 默认值）|

返回: 

- 拖拽起始位置到当前位置的位移

### func getMousePos\(\)
```cj
public static func getMousePos(): ImVec2
```
获取鼠标位置

返回: 

- 当前鼠标坐标

### func isAnyMouseDown\(\)
```cj
public static func isAnyMouseDown(): Bool
```
是否有任意鼠标按钮按下

返回: 

- 任一鼠标按钮是否处于按下状态

### func isMouseClicked\(Int32,Bool\)
```cj
public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool
```
指定鼠标按钮是否刚点击

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标按钮索引（0=左键，1=右键，2=中键）|
|repeat_|Bool|是否包含重复触发（默认 false）|

返回: 

- 按钮本次是否刚被点击

### func isMouseDoubleClicked\(Int32\)
```cj
public static func isMouseDoubleClicked(button: Int32): Bool
```
指定鼠标按钮是否双击

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标按钮索引（0=左键，1=右键，2=中键）|

返回: 

- 按钮本次是否被双击

### func isMouseDown\(Int32\)
```cj
public static func isMouseDown(button: Int32): Bool
```
指定鼠标按钮是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标按钮索引（0=左键，1=右键，2=中键）|

返回: 

- 按钮当前是否处于按下状态

### func isMouseHoveringRect\(Float32,Float32,Float32,Float32,Bool\)
```cj
public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool
```
鼠标是否在指定矩形区域内悬停

参数: 

|名称|类型|描述|
|---|---|---|
|minX|Float32|矩形区域左上角 X 坐标|
|minY|Float32|矩形区域左上角 Y 坐标|
|maxX|Float32|矩形区域右下角 X 坐标|
|maxY|Float32|矩形区域右下角 Y 坐标|
|clip|Bool|是否限制在当前裁剪区域（默认 true）|

返回: 

- 鼠标是否悬停在矩形区域内

### func isMouseReleased\(Int32\)
```cj
public static func isMouseReleased(button: Int32): Bool
```
指定鼠标按钮是否刚释放

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标按钮索引（0=左键，1=右键，2=中键）|

返回: 

- 按钮本次是否刚释放

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
重置鼠标拖拽增量

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|拖拽按钮索引（默认 0=左键）|

### func setMouseCursor\(Int32\)
```cj
public static func setMouseCursor(cursorType: Int32): Unit
```
设置鼠标光标类型

参数: 

|名称|类型|描述|
|---|---|---|
|cursorType|Int32|光标类型（ImGuiMouseCursor 枚举值）|

