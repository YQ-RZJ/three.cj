# Class
## class GamepadProvider
```cj
public class GamepadProvider <: InputProvider
```
Gamepad input provider

### func \`init\`\(\)
```cj
public override func `init`(): Unit
```
Initializes (called after window binding)

### func beginFrame\(\)
```cj
public override func beginFrame(): Unit
```
Frame begin: poll gamepad state

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
|axis|GamepadAxis|The axis (e.g. GamepadAxis.LeftX)|

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
|button|GamepadButton|The button (e.g. GamepadButton.South)|

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

### func init\(\)
```cj
public init()
```
Constructs a gamepad provider

### func isGamepadConnected\(\)
```cj
public func isGamepadConnected(): Bool
```
Queries whether the gamepad is connected

Return: 

- true if connected, or false if not opened

### func openGamepadAt\(Int32\)
```cj
public func openGamepadAt(index: Int32): Bool
```
Opens the gamepad at the specified index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int32|The gamepad index (0-based)|

Return: 

- Whether the gamepad was opened successfully

### func openGamepad\(\)
```cj
public func openGamepad(): Bool
```
Opens the first connected gamepad

Return: 

- Whether the gamepad was opened successfully

### func shutdown\(\)
```cj
public override func shutdown(): Unit
```
Cleans up resources

