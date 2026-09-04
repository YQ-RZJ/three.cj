# Class
## class MouseProvider
```cj
public class MouseProvider <: InputProvider
```
Mouse input provider

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
Resets edge states and accumulated values at frame end

### func getMouseDX\(\)
```cj
public func getMouseDX(): Float32
```
Gets the mouse X delta accumulated this frame

Return: 

- The mouse X delta

### func getMouseDY\(\)
```cj
public func getMouseDY(): Float32
```
Gets the mouse Y delta accumulated this frame

Return: 

- The mouse Y delta

### func getMouseX\(\)
```cj
public func getMouseX(): Float32
```
Gets the mouse X position (relative to the window)

Return: 

- The mouse X position

### func getMouseY\(\)
```cj
public func getMouseY(): Float32
```
Gets the mouse Y position (relative to the window)

Return: 

- The mouse Y position

### func getWheelX\(\)
```cj
public func getWheelX(): Float32
```
Gets the horizontal wheel scroll amount (accumulated this frame)

Return: 

- The horizontal scroll amount

### func getWheelY\(\)
```cj
public func getWheelY(): Float32
```
Gets the vertical wheel scroll amount (accumulated this frame)

Return: 

- The vertical scroll amount

### func init\(\)
```cj
public init()
```
Constructs a mouse provider

### func isMouseButtonDown\(UInt8\)
```cj
public func isMouseButtonDown(button: UInt8): Bool
```
Queries whether a mouse button is pressed

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|UInt8|Mouse button (SDL_BUTTON_*, e.g. SDL_BUTTON_LEFT=1)|

Return: 

- true if pressed, false otherwise

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
Handles mouse events

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|DispatchEvent|The dispatch event|

