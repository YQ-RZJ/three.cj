# 类
## class UiSystem
```cj
public class UiSystem
```
系统能力工具：剪贴板、鼠标拖拽判定、输入捕获

### func framerate\(\)
```cj
public static func framerate(): Float32
```
帧率估计（60 帧滚动平均）

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
读取系统剪贴板文本

返回: 

- 剪贴板内容（不可用时为空字符串）

### func init\(\)
```cj
public init()
```
构造系统工具（仅静态方法）

### func ioMouseDelta\(\)
```cj
public static func ioMouseDelta(): Vector2
```
当前帧鼠标位移（任一位置无效时为零向量）

### func ioMousePos\(\)
```cj
public static func ioMousePos(): Vector2
```
当前帧鼠标位置（无效时为 -FLT_MAX）

### func ioMouseWheelH\(\)
```cj
public static func ioMouseWheelH(): Float32
```
水平滚轮增量（>0 左滚，<0 右滚）

### func ioMouseWheel\(\)
```cj
public static func ioMouseWheel(): Float32
```
垂直滚轮增量（>0 上滚，<0 下滚）

### func isIoMouseDown\(Int32\)
```cj
public static func isIoMouseDown(button: Int32): Bool
```
鼠标键按下状态

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标键（0=左, 1=右, 2=中）|

### func isKeyAlt\(\)
```cj
public static func isKeyAlt(): Bool
```
Alt 是否按下

### func isKeyCtrl\(\)
```cj
public static func isKeyCtrl(): Bool
```
Ctrl（macOS 上为 Cmd）是否按下

### func isKeyShift\(\)
```cj
public static func isKeyShift(): Bool
```
Shift 是否按下

### func isKeySuper\(\)
```cj
public static func isKeySuper(): Bool
```
Super（非 macOS 为 Win，macOS 为 Ctrl）是否按下

### func isKeyboardCaptured\(\)
```cj
public static func isKeyboardCaptured(): Bool
```
键盘是否被 ImGui 捕获（为 true 时游戏/场景不应响应键盘）

### func isMouseCaptured\(\)
```cj
public static func isMouseCaptured(): Bool
```
鼠标是否被 ImGui 捕获（为 true 时游戏/场景不应响应鼠标）

### func isMouseDragging\(Int32,Float32\)
```cj
public static func isMouseDragging(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0): Bool
```
判断指定鼠标键是否正在拖拽

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标键（0=左, 1=右, 2=中）|
|lockThreshold|Float32|启动拖拽的位移阈值（-1=使用默认）|

返回: 

- 是否正在拖拽

### func keyMods\(\)
```cj
public static func keyMods(): Int32
```
修饰键合并位掩码（ImGuiMod_Ctrl/Shift/Alt/Super 按位或）

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
重置鼠标拖拽位移基准

参数: 

|名称|类型|描述|
|---|---|---|
|button|Int32|鼠标键|

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Unit
```
写入系统剪贴板文本

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|要写入的文本|

### func wantCaptureKeyboardNextFrame\(Bool\)
```cj
public static func wantCaptureKeyboardNextFrame(want: Bool): Unit
```
请求下一帧捕获键盘（游戏快捷键让位于 UI 输入）

参数: 

|名称|类型|描述|
|---|---|---|
|want|Bool|是否捕获|

### func wantCaptureMouseNextFrame\(Bool\)
```cj
public static func wantCaptureMouseNextFrame(want: Bool): Unit
```
请求下一帧捕获鼠标（游戏输入让位于 UI）

参数: 

|名称|类型|描述|
|---|---|---|
|want|Bool|是否捕获|

### func wantsTextInput\(\)
```cj
public static func wantsTextInput(): Bool
```
ImGui 是否需要文本输入（如 InputText 激活）

