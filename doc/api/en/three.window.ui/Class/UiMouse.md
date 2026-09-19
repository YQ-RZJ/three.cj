# Class
## class UiMouse
```cj
public class UiMouse
```
Mouse state query utility class (static methods wrapping ImGui mouse query/set APIs)

### func getMouseCursor\(\)
```cj
public static func getMouseCursor(): Int32
```
Gets the current mouse cursor type

Return: 

- Current cursor type (ImGuiMouseCursor enum value)

### func getMouseDragDelta\(Int32,Float32\)
```cj
public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0f32): ImVec2
```
Gets the mouse drag delta

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Drag button index (default 0=left)|
|lockThreshold|Float32|Lock threshold (default -1.0, uses ImGui default)|

Return: 

- Displacement from drag start to current position

### func getMousePos\(\)
```cj
public static func getMousePos(): ImVec2
```
Gets the mouse position

Return: 

- Current mouse coordinates

### func isAnyMouseDown\(\)
```cj
public static func isAnyMouseDown(): Bool
```
Whether any mouse button is down

Return: 

- Whether any mouse button is currently down

### func isMouseClicked\(Int32,Bool\)
```cj
public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool
```
Whether the given mouse button was just clicked

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button index (0=left, 1=right, 2=middle)|
|repeat_|Bool|Whether to include repeat triggers (default false)|

Return: 

- Whether the button was just clicked this frame

### func isMouseDoubleClicked\(Int32\)
```cj
public static func isMouseDoubleClicked(button: Int32): Bool
```
Whether the given mouse button was double-clicked

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button index (0=left, 1=right, 2=middle)|

Return: 

- Whether the button was double-clicked this frame

### func isMouseDown\(Int32\)
```cj
public static func isMouseDown(button: Int32): Bool
```
Whether the given mouse button is down

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button index (0=left, 1=right, 2=middle)|

Return: 

- Whether the button is currently down

### func isMouseHoveringRect\(Float32,Float32,Float32,Float32,Bool\)
```cj
public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool
```
Whether the mouse is hovering within the given rectangle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|minX|Float32|Top-left X coordinate of the rectangle|
|minY|Float32|Top-left Y coordinate of the rectangle|
|maxX|Float32|Bottom-right X coordinate of the rectangle|
|maxY|Float32|Bottom-right Y coordinate of the rectangle|
|clip|Bool|Whether to clamp to the current clip rect (default true)|

Return: 

- Whether the mouse is hovering inside the rectangle

### func isMouseReleased\(Int32\)
```cj
public static func isMouseReleased(button: Int32): Bool
```
Whether the given mouse button was just released

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Mouse button index (0=left, 1=right, 2=middle)|

Return: 

- Whether the button was just released this frame

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
Resets the mouse drag delta

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32|Drag button index (default 0=left)|

### func setMouseCursor\(Int32\)
```cj
public static func setMouseCursor(cursorType: Int32): Unit
```
Sets the mouse cursor type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cursorType|Int32|Cursor type (ImGuiMouseCursor enum value)|

