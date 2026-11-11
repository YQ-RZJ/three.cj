# Class
## class UiSystem
```cj
public class UiSystem
```
System utilities: clipboard, mouse drag detection, input capture

### func framerate\(\)
```cj
public static func framerate(): Float32
```
Framerate estimate (60-frame rolling average)

### func getClipboardText\(\)
```cj
public static func getClipboardText(): String
```
Reads the system clipboard text

Return: 

- Clipboard content (empty string when unavailable)

### func init\(\)
```cj
public init()
```
Constructs the system utility (static-only)

### func ioMouseDelta\(\)
```cj
public static func ioMouseDelta(): Vector2
```
Current-frame mouse delta (zero when either position is invalid)

### func ioMousePos\(\)
```cj
public static func ioMousePos(): Vector2
```
Current-frame mouse position (-FLT_MAX when invalid)

### func ioMouseWheelH\(\)
```cj
public static func ioMouseWheelH(): Float32
```
Horizontal wheel delta (>0 left, <0 right)

### func ioMouseWheel\(\)
```cj
public static func ioMouseWheel(): Float32
```
Vertical wheel delta (>0 up, <0 down)

### func isIoMouseDown\(Int32\)
```cj
public static func isIoMouseDown(button: Int32): Bool
```
Mouse button down state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button (0=left, 1=right, 2=middle)|

### func isKeyAlt\(\)
```cj
public static func isKeyAlt(): Bool
```
Whether Alt is down

### func isKeyCtrl\(\)
```cj
public static func isKeyCtrl(): Bool
```
Whether Ctrl (Cmd on macOS) is down

### func isKeyShift\(\)
```cj
public static func isKeyShift(): Bool
```
Whether Shift is down

### func isKeySuper\(\)
```cj
public static func isKeySuper(): Bool
```
Whether Super (Win key, Ctrl on macOS) is down

### func isKeyboardCaptured\(\)
```cj
public static func isKeyboardCaptured(): Bool
```
Whether ImGui captures the keyboard (do not dispatch to game/scene when true)

### func isMouseCaptured\(\)
```cj
public static func isMouseCaptured(): Bool
```
Whether ImGui captures the mouse (do not dispatch to game/scene when true)

### func isMouseDragging\(Int32,Float32\)
```cj
public static func isMouseDragging(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0): Bool
```
Whether the given mouse button is dragging

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button (0=left, 1=right, 2=middle)|
|lockThreshold|Float32|Drag lock threshold (-1=default)|

Return: 

- Whether dragging

### func keyMods\(\)
```cj
public static func keyMods(): Int32
```
Merged modifier mask (bitwise-or of ImGuiMod_Ctrl/Shift/Alt/Super)

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
Resets the mouse drag delta reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button|

### func setClipboardText\(String\)
```cj
public static func setClipboardText(text: String): Unit
```
Writes text to the system clipboard

Parameter: 

|Name|Type|Describe|
|---|---|---|
|text|String|Text to write|

### func wantCaptureKeyboardNextFrame\(Bool\)
```cj
public static func wantCaptureKeyboardNextFrame(want: Bool): Unit
```
Requests keyboard capture for the next frame (game shortcuts yield to UI input)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|want|Bool|Whether to capture|

### func wantCaptureMouseNextFrame\(Bool\)
```cj
public static func wantCaptureMouseNextFrame(want: Bool): Unit
```
Requests mouse capture for the next frame (game input yields to UI)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|want|Bool|Whether to capture|

### func wantsTextInput\(\)
```cj
public static func wantsTextInput(): Bool
```
Whether ImGui wants text input (e.g. InputText active)

