# Class
## class UiWindow
```cj
public class UiWindow
```
ImGui window widget

### func beginChild\(String,Float32,Float32,Int32,Int32\)
```cj
public static func beginChild(id: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32, childFlags!: Int32 = 0, windowFlags!: Int32 = 0): Bool
```
Creates a child window (use inside begin/end)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|String|Child window ID|
|w|Float32|Width (0=auto)|
|h|Float32|Height (0=auto)|
|childFlags|Int32|Child window flags|
|windowFlags|Int32|Window flags|

Return: 

- Whether visible

### func begin\(\)
```cj
public func begin(): Bool
```
Begins the window (calls ImGui Begin)

Return: 

- Whether the window is visible

### func createWithClose\(String,Int32\)
```cj
public static func createWithClose(title: String, flags!: Int32 = 0): UiWindow
```
Creates a window with a close button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window title|
|flags|Int32|Window flags (default 0)|

Return: 

- Window instance

### func create\(String,Int32\)
```cj
public static func create(title: String, flags!: Int32 = 0): UiWindow
```
Creates a normal window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window title|
|flags|Int32|Window flags (default 0)|

Return: 

- Window instance

### func draw\(\(\)\->Unit\)
```cj
public func draw(content:() -> Unit): Bool
```
Automatically manages begin/end with a closure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Drawing closure|

Return: 

- Whether the window is visible

### func endChild\(\)
```cj
public static func endChild(): Unit
```
Ends the child window

### func end\(\)
```cj
public func end(): Unit
```
Ends the window (calls ImGui End)

### func getScrollMaxX\(\)
```cj
public static func getScrollMaxX(): Float32
```
Gets the maximum scroll X

### func getScrollMaxY\(\)
```cj
public static func getScrollMaxY(): Float32
```
Gets the maximum scroll Y

### func getScrollX\(\)
```cj
public static func getScrollX(): Float32
```
Gets the current scroll X

### func getScrollY\(\)
```cj
public static func getScrollY(): Float32
```
Gets the current scroll Y

### func getWindowHeight\(\)
```cj
public static func getWindowHeight(): Float32
```
Gets the current window height

### func getWindowPos\(\)
```cj
public static func getWindowPos(): ImVec2
```
Gets the current window position

### func getWindowSize\(\)
```cj
public static func getWindowSize(): ImVec2
```
Gets the current window size

### func getWindowWidth\(\)
```cj
public static func getWindowWidth(): Float32
```
Gets the current window width

### func init\(String,Int32\)
```cj
public init(title!: String, flags!: Int32 = 0)
```
Constructs a normal window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window title|
|flags|Int32|Window flags (default 0)|

### func init\(String,CPointer<Int32>,Int32\)
```cj
public init(title!: String, open!: CPointer < Int32 >, flags!: Int32 = 0)
```
Constructs a window with a close button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|title|String|Window title|
|open|CPointer<Int32>|Pointer to open state|
|flags|Int32|Window flags|

### func isWindowAppearing\(\)
```cj
public static func isWindowAppearing(): Bool
```
Whether the current window is appearing (animation transition)

### func isWindowCollapsed\(\)
```cj
public static func isWindowCollapsed(): Bool
```
Whether the current window is collapsed

### func isWindowFocused\(Int32\)
```cj
public static func isWindowFocused(flags!: Int32 = 0): Bool
```
Whether the current window is focused

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|Int32|ImGuiFocusedFlags (default 0)|

### func isWindowHovered\(Int32\)
```cj
public static func isWindowHovered(flags!: Int32 = 0): Bool
```
Whether the current window is hovered

Parameter: 

|Name|Type|Describe|
|---|---|---|
|flags|Int32|ImGuiHoveredFlags (default 0)|

### func setNextWindowBgAlpha\(Float32\)
```cj
public static func setNextWindowBgAlpha(alpha: Float32): Unit
```
Sets the background alpha of the next window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|alpha|Float32|Transparency (0.0~1.0)|

### func setNextWindowCollapsed\(Bool,Int32\)
```cj
public static func setNextWindowCollapsed(collapsed: Bool, cond!: Int32 = 0): Unit
```
Sets the collapsed state of the next window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|collapsed|Bool|Whether collapsed|
|cond|Int32|Condition flags|

### func setNextWindowFocus\(\)
```cj
public static func setNextWindowFocus(): Unit
```
Sets the next window to gain focus

### func setNextWindowPosVec\(ImVec2,Int32,ImVec2\)
```cj
public static func setNextWindowPosVec(pos: ImVec2, cond!: Int32 = 0, pivot!: ImVec2 = ImVec2(0.0, 0.0)): Unit
```
Sets the position of the next window (vector form)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pos|ImVec2|Position in pixels|
|cond|Int32|Condition flags|
|pivot|ImVec2|Pivot point|

### func setNextWindowPos\(Float32,Float32,Int32,Float32,Float32\)
```cj
public static func setNextWindowPos(x: Float32, y: Float32, cond!: Int32 = 0, pivotX!: Float32 = 0.0f32, pivotY!: Float32 = 0.0f32): Unit
```
Sets the position of the next window (call before begin()/draw())

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float32|X coordinate in pixels|
|y|Float32|Y coordinate in pixels|
|cond|Int32|Condition flags (ImGuiCond, 0=always)|
|pivotX|Float32|Pivot X (0=left, 0.5=center, 1=right)|
|pivotY|Float32|Pivot Y (0=top, 0.5=center, 1=bottom)|

### func setNextWindowSizeConstraints\(Float32,Float32,Float32,Float32\)
```cj
public static func setNextWindowSizeConstraints(minW: Float32, minH: Float32, maxW: Float32, maxH: Float32): Unit
```
Sets the size constraints of the next window

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minW|Float32|Minimum width|
|minH|Float32|Minimum height|
|maxW|Float32|Maximum width (FLT_MAX=unlimited)|
|maxH|Float32|Maximum height (FLT_MAX=unlimited)|

### func setNextWindowSize\(Float32,Float32,Int32\)
```cj
public static func setNextWindowSize(w: Float32, h: Float32, cond!: Int32 = 0): Unit
```
Sets the size of the next window (call before begin()/draw())

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Float32|Width in pixels (0=auto-fit)|
|h|Float32|Height in pixels (0=auto-fit)|
|cond|Int32|Condition flags|

### func setScrollHereX\(Float32\)
```cj
public static func setScrollHereX(centerXRatio!: Float32 = 0.5f32): Unit
```
Centers the scroll position at the current cursor X

Parameter: 

|Name|Type|Describe|
|---|---|---|
|centerXRatio|Float32||

### func setScrollHereY\(Float32\)
```cj
public static func setScrollHereY(centerYRatio!: Float32 = 0.5f32): Unit
```
Centers the scroll position at the current cursor Y

Parameter: 

|Name|Type|Describe|
|---|---|---|
|centerYRatio|Float32||

### func setScrollX\(Float32\)
```cj
public static func setScrollX(scrollX: Float32): Unit
```
Sets the scroll X

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scrollX|Float32||

### func setScrollY\(Float32\)
```cj
public static func setScrollY(scrollY: Float32): Unit
```
Sets the scroll Y

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scrollY|Float32||

