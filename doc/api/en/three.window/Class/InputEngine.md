# Class
## class InputEngine
```cj
public class InputEngine
```
Input engine: unified facade for keyboard/mouse/gamepad/touch state querying

### func bindWindow\(WindowEngine\)
```cj
public func bindWindow(win: WindowEngine): Unit
```
Binds the window engine (Provider state source)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|win|WindowEngine||

### func closeGamepad\(\)
```cj
public func closeGamepad(): Unit
```
Closes the gamepad

### func getGamepadAxis\(GamepadAxis\)
```cj
public func getGamepadAxis(axis: GamepadAxis): Int16
```
Gets the gamepad axis value (range -32768 ~ 32767)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|axis|GamepadAxis||

Return: 

- The axis value, or 0 if not connected

### func getGamepadButton\(GamepadButton\)
```cj
public func getGamepadButton(button: GamepadButton): Bool
```
Gets the gamepad button state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|GamepadButton||

Return: 

- true if pressed, or false if not connected

### func getGamepadInstanceID\(\)
```cj
public func getGamepadInstanceID(): Int64
```
Gets the gamepad instance ID

Return: 

- The gamepad instance ID, or -1 if not opened

### func getGamepadName\(\)
```cj
public func getGamepadName(): String
```
Gets the gamepad name

Return: 

- The gamepad name, or an empty string if not connected

### func getMouseDX\(\)
```cj
public func getMouseDX(): Float32
```
Gets the mouse X movement delta this frame

Return: 

- The mouse X delta, or 0.0 if no window is bound

### func getMouseDY\(\)
```cj
public func getMouseDY(): Float32
```
Gets the mouse Y movement delta this frame

Return: 

- The mouse Y delta, or 0.0 if no window is bound

### func getMouseX\(\)
```cj
public func getMouseX(): Float32
```
Gets the mouse X coordinate relative to the window

Return: 

- The mouse X coordinate, or 0.0 if no window is bound

### func getMouseY\(\)
```cj
public func getMouseY(): Float32
```
Gets the mouse Y coordinate relative to the window

Return: 

- The mouse Y coordinate, or 0.0 if no window is bound

### func getTouchByID\(Int64\)
```cj
public func getTouchByID(fingerID: Int64): Option < TouchPoint >
```
Gets the touch point with the specified finger ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fingerID|Int64|Finger instance ID|

Return: 

- The touch point data, or None if not found or no window is bound

### func getTouchCount\(\)
```cj
public func getTouchCount(): Int64
```
Gets the number of active touch points

Return: 

- The number of touch points, or 0 if no window is bound

### func getTouch\(Int64\)
```cj
public func getTouch(index: Int64): Option < TouchPoint >
```
Gets the touch point at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Touch point index (0-based)|

Return: 

- The touch point data, or None if index is out of bounds or no window is bound

### func getWheelX\(\)
```cj
public func getWheelX(): Float32
```
Gets the horizontal wheel scroll amount (accumulated this frame)

Return: 

- The horizontal scroll amount, or 0.0 if no window is bound

### func getWheelY\(\)
```cj
public func getWheelY(): Float32
```
Gets the vertical wheel scroll amount (accumulated this frame)

Return: 

- The vertical scroll amount, or 0.0 if no window is bound

### func getWindow\(\)
```cj
public func getWindow(): Option < WindowEngine >
```
Gets the currently bound window engine

Return: 

- The bound window engine, or None if not bound

### func init\(\)
```cj
public init()
```
Constructs the input engine

### func isGamepadConnected\(\)
```cj
public func isGamepadConnected(): Bool
```
Returns whether the gamepad is connected

Return: 

- true if connected, or false if not opened

### func isKeyDown\(UInt32\)
```cj
public func isKeyDown(scancode: UInt32): Bool
```
Returns whether a keyboard key is currently held down (scancode is SDL_SCANCODE_*)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32||

Return: 

- true if held down, or false if no window is bound or no KeyboardProvider registered

### func isKeyPressed\(UInt32\)
```cj
public func isKeyPressed(scancode: UInt32): Bool
```
Returns whether a keyboard key was just pressed this frame (edge-triggered)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32||

Return: 

- true if just pressed, or false if no window is bound

### func isKeyReleased\(UInt32\)
```cj
public func isKeyReleased(scancode: UInt32): Bool
```
Returns whether a keyboard key was just released this frame (edge-triggered)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32||

Return: 

- true if just released, or false if no window is bound

### func isMouseButtonDown\(UInt8\)
```cj
public func isMouseButtonDown(button: UInt8): Bool
```
Returns whether a mouse button is held down (button is SDL_BUTTON_*)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|button|UInt8||

Return: 

- true if held down, or false if no window is bound

### func openGamepadAt\(Int32\)
```cj
public func openGamepadAt(index: Int32): Bool
```
Opens the gamepad at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int32||

Return: 

- Whether the gamepad was opened successfully

### func openGamepad\(\)
```cj
public func openGamepad(): Bool
```
Opens the first connected gamepad

Return: 

- Whether the gamepad was opened successfully

