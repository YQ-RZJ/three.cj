# Class
## class UiMouse
```cj
public class UiMouse
```


### func getMouseCursor\(\)
```cj
public static func getMouseCursor(): Int32
```
Gets the current mouse cursor type

### func getMouseDragDelta\(Int32,Float32\)
```cj
public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = - 1.0f32): ImVec2
```
Gets the mouse drag delta

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||
|lockThreshold|Float32||

### func getMousePos\(\)
```cj
public static func getMousePos(): ImVec2
```
Gets the mouse position

### func isAnyMouseDown\(\)
```cj
public static func isAnyMouseDown(): Bool
```
Whether any mouse button is down

### func isMouseClicked\(Int32,Bool\)
```cj
public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool
```
Whether the given mouse button was just clicked

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||
|repeat_|Bool||

### func isMouseDoubleClicked\(Int32\)
```cj
public static func isMouseDoubleClicked(button: Int32): Bool
```
Whether the given mouse button was double-clicked

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||

### func isMouseDown\(Int32\)
```cj
public static func isMouseDown(button: Int32): Bool
```
Whether the given mouse button is down

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||

### func isMouseHoveringRect\(Float32,Float32,Float32,Float32,Bool\)
```cj
public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool
```
Whether the mouse is hovering within the given rectangle

Parameter: 

|Name|Type|Describe|
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
Whether the given mouse button was just released

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||

### func resetMouseDragDelta\(Int32\)
```cj
public static func resetMouseDragDelta(button!: Int32 = 0): Unit
```
Resets the mouse drag delta

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|Int32||

### func setMouseCursor\(Int32\)
```cj
public static func setMouseCursor(cursorType: Int32): Unit
```
Sets the mouse cursor type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|cursorType|Int32||

