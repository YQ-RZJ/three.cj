# 类
## class UiMouse
```cj
public class UiMouse
```


### func getMouseCursor\(\)
```cj
public static func getMouseCursor(): Int32
```
获取当前鼠标光标类型

### func getMouseDragDelta\(Int32,Float32\)
```cj
public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0f32): ImVec2
```
获取鼠标拖拽增量

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||
|lockThreshold|Float32||

### func getMousePos\(\)
```cj
public static func getMousePos(): ImVec2
```
获取鼠标位置

### func isAnyMouseDown\(\)
```cj
public static func isAnyMouseDown(): Bool
```
是否有任意鼠标按钮按下

### func isMouseClicked\(Int32,Bool\)
```cj
public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool
```
指定鼠标按钮是否刚点击

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||
|repeat_|Bool||

### func isMouseDoubleClicked\(Int32\)
```cj
public static func isMouseDoubleClicked(button: Int32): Bool
```
指定鼠标按钮是否双击

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||

### func isMouseDown\(Int32\)
```cj
public static func isMouseDown(button: Int32): Bool
```
指定鼠标按钮是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||

### func isMouseHoveringRect\(Float32,Float32,Float32,Float32,Bool\)
```cj
public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool
```
鼠标是否在指定矩形区域内悬停

参数: 

|名称|类型|描述|
|---|---|---|
|minX|Float32||
|minY|Float32||
|maxX|Float32||
|maxY|Float32||
|clip|Bool||

### func isMouseReleased\(Int32\)
```cj
public static func isMouseReleased(button: Int32): Bool
```
指定鼠标按钮是否刚释放

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
重置鼠标拖拽增量

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32||

### func setMouseCursor\(Int32\)
```cj
public static func setMouseCursor(cursorType: Int32): Unit
```
设置鼠标光标类型

参数: 

|名称|类型|描述|
|---|---|---|
|cursorType|Int32||

