# Class
## class KeyboardProvider
```cj
public class KeyboardProvider <: InputProvider
```
Keyboard input provider

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
Resets edge states at frame end

### func init\(\)
```cj
public init()
```
Constructs a keyboard provider

### func isKeyDown\(UInt32\)
```cj
public func isKeyDown(scancode: UInt32): Bool
```
Queries whether a key is currently held down

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32|Key scancode (SDL_SCANCODE_*)|

Return: 

- true if held down, false otherwise

### func isKeyPressed\(UInt32\)
```cj
public func isKeyPressed(scancode: UInt32): Bool
```
Queries whether a key was just pressed this frame (edge-triggered)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32|Key scancode (SDL_SCANCODE_*)|

Return: 

- true if just pressed, false otherwise

### func isKeyReleased\(UInt32\)
```cj
public func isKeyReleased(scancode: UInt32): Bool
```
Queries whether a key was just released this frame (edge-triggered)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scancode|UInt32|Key scancode (SDL_SCANCODE_*)|

Return: 

- true if just released, false otherwise

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
Handles keyboard events

Parameter: 

|Name|Type|Describe|
|---|---|---|
|evt|DispatchEvent|The dispatch event|

