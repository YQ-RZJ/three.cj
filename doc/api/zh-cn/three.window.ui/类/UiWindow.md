# 类
## class UiWindow
```cj
public class UiWindow
```
ImGui 窗口组件

### func beginChild\(String,Float32,Float32,Int32,Int32\)
```cj
public static func beginChild(id: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32, childFlags!: Int32 = 0, windowFlags!: Int32 = 0): Bool
```
创建子窗口（在 begin/end 内使用）

参数: 

|名称|类型|描述|
|---|---|---|
|id|String|子窗口 ID|
|w|Float32|宽度（0=自动）|
|h|Float32|高度（0=自动）|
|childFlags|Int32|子窗口标志|
|windowFlags|Int32|窗口标志|

返回: 

- 是否可见

### func begin\(\)
```cj
public func begin(): Bool
```
开始窗口（调用 ImGui Begin）

返回: 

- 窗口是否可见

### func createWithClose\(String,Int32\)
```cj
public static func createWithClose(title: String, flags!: Int32 = 0): UiWindow
```
创建带关闭按钮的窗口

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题|
|flags|Int32|窗口标志（默认 0）|

返回: 

- 窗口实例

### func create\(String,Int32\)
```cj
public static func create(title: String, flags!: Int32 = 0): UiWindow
```
创建普通窗口

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题|
|flags|Int32|窗口标志（默认 0）|

返回: 

- 窗口实例

### func draw\(\(\)\->Unit\)
```cj
public func draw(content:() -> Unit): Bool
```
使用闭包自动管理 begin/end

参数: 

|名称|类型|描述|
|---|---|---|
|content|()->Unit|绘制闭包|

返回: 

- 窗口是否可见

### func endChild\(\)
```cj
public static func endChild(): Unit
```
结束子窗口

### func end\(\)
```cj
public func end(): Unit
```
结束窗口（调用 ImGui End）

### func getScrollMaxX\(\)
```cj
public static func getScrollMaxX(): Float32
```
获取滚动 X 最大值

### func getScrollMaxY\(\)
```cj
public static func getScrollMaxY(): Float32
```
获取滚动 Y 最大值

### func getScrollX\(\)
```cj
public static func getScrollX(): Float32
```
获取当前滚动 X

### func getScrollY\(\)
```cj
public static func getScrollY(): Float32
```
获取当前滚动 Y

### func getWindowHeight\(\)
```cj
public static func getWindowHeight(): Float32
```
获取当前窗口高度

### func getWindowPos\(\)
```cj
public static func getWindowPos(): ImVec2
```
获取当前窗口位置

### func getWindowSize\(\)
```cj
public static func getWindowSize(): ImVec2
```
获取当前窗口尺寸

### func getWindowWidth\(\)
```cj
public static func getWindowWidth(): Float32
```
获取当前窗口宽度

### func init\(String,Int32\)
```cj
public init(title!: String, flags!: Int32 = 0)
```
构造普通窗口

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题|
|flags|Int32|窗口标志（默认 0）|

### func init\(String,CPointer<Int32>,Int32\)
```cj
public init(title!: String, open!: CPointer < Int32 >, flags!: Int32 = 0)
```
构造带关闭按钮的窗口

参数: 

|名称|类型|描述|
|---|---|---|
|title|String|窗口标题|
|open|CPointer<Int32>|打开状态指针|
|flags|Int32|窗口标志|

### func isWindowAppearing\(\)
```cj
public static func isWindowAppearing(): Bool
```
当前窗口是否正在出现（动画过渡）

### func isWindowCollapsed\(\)
```cj
public static func isWindowCollapsed(): Bool
```
当前窗口是否折叠

### func isWindowFocused\(Int32\)
```cj
public static func isWindowFocused(flags!: Int32 = 0): Bool
```
当前窗口是否获得焦点

参数: 

|名称|类型|描述|
|---|---|---|
|flags|Int32|ImGuiFocusedFlags（默认 0）|

### func isWindowHovered\(Int32\)
```cj
public static func isWindowHovered(flags!: Int32 = 0): Bool
```
当前窗口是否被悬停

参数: 

|名称|类型|描述|
|---|---|---|
|flags|Int32|ImGuiHoveredFlags（默认 0）|

### func setNextWindowBgAlpha\(Float32\)
```cj
public static func setNextWindowBgAlpha(alpha: Float32): Unit
```
设置下一个窗口的背景透明度

参数: 

|名称|类型|描述|
|---|---|---|
|alpha|Float32|透明度（0.0~1.0）|

### func setNextWindowCollapsed\(Bool,Int32\)
```cj
public static func setNextWindowCollapsed(collapsed: Bool, cond!: Int32 = 0): Unit
```
设置下一个窗口的折叠状态

参数: 

|名称|类型|描述|
|---|---|---|
|collapsed|Bool|是否折叠|
|cond|Int32|条件标志|

### func setNextWindowFocus\(\)
```cj
public static func setNextWindowFocus(): Unit
```
设置下一个窗口获得焦点

### func setNextWindowPosVec\(ImVec2,Int32,ImVec2\)
```cj
public static func setNextWindowPosVec(pos: ImVec2, cond!: Int32 = 0, pivot!: ImVec2 = ImVec2(0.0, 0.0)): Unit
```
设置下一个窗口的位置（向量形式）

参数: 

|名称|类型|描述|
|---|---|---|
|pos|ImVec2|位置（像素）|
|cond|Int32|条件标志|
|pivot|ImVec2|枢轴|

### func setNextWindowPos\(Float32,Float32,Int32,Float32,Float32\)
```cj
public static func setNextWindowPos(x: Float32, y: Float32, cond!: Int32 = 0, pivotX!: Float32 = 0.0f32, pivotY!: Float32 = 0.0f32): Unit
```
设置下一个窗口的位置（在 begin()/draw() 前调用）

参数: 

|名称|类型|描述|
|---|---|---|
|x|Float32|X 坐标（像素）|
|y|Float32|Y 坐标（像素）|
|cond|Int32|条件标志（ImGuiCond，0=总是）|
|pivotX|Float32|枢轴 X（0=左, 0.5=中, 1=右）|
|pivotY|Float32|枢轴 Y（0=上, 0.5=中, 1=下）|

### func setNextWindowSizeConstraints\(Float32,Float32,Float32,Float32\)
```cj
public static func setNextWindowSizeConstraints(minW: Float32, minH: Float32, maxW: Float32, maxH: Float32): Unit
```
设置下一个窗口的尺寸约束

参数: 

|名称|类型|描述|
|---|---|---|
|minW|Float32|最小宽度|
|minH|Float32|最小高度|
|maxW|Float32|最大宽度（FLT_MAX=不限）|
|maxH|Float32|最大高度（FLT_MAX=不限）|

### func setNextWindowSize\(Float32,Float32,Int32\)
```cj
public static func setNextWindowSize(w: Float32, h: Float32, cond!: Int32 = 0): Unit
```
设置下一个窗口的尺寸（在 begin()/draw() 前调用）

参数: 

|名称|类型|描述|
|---|---|---|
|w|Float32|宽度（像素，0=自动适配）|
|h|Float32|高度（像素，0=自动适配）|
|cond|Int32|条件标志|

### func setScrollHereX\(Float32\)
```cj
public static func setScrollHereX(centerXRatio!: Float32 = 0.5f32): Unit
```
将当前滚动位置居中到当前光标 X

参数: 

|名称|类型|描述|
|---|---|---|
|centerXRatio|Float32||

### func setScrollHereY\(Float32\)
```cj
public static func setScrollHereY(centerYRatio!: Float32 = 0.5f32): Unit
```
将当前滚动位置居中到当前光标 Y

参数: 

|名称|类型|描述|
|---|---|---|
|centerYRatio|Float32||

### func setScrollX\(Float32\)
```cj
public static func setScrollX(scrollX: Float32): Unit
```
设置滚动 X

参数: 

|名称|类型|描述|
|---|---|---|
|scrollX|Float32||

### func setScrollY\(Float32\)
```cj
public static func setScrollY(scrollY: Float32): Unit
```
设置滚动 Y

参数: 

|名称|类型|描述|
|---|---|---|
|scrollY|Float32||

