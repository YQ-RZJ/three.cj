# Enum
## enum GamepadButton
```cj
public enum GamepadButton
```
Gamepad button type

### Back
```cj
Back
```
Back button

### Count
```cj
Count
```
Total number of buttons (not a real button; marks the end of the enum)

### DPadDown
```cj
DPadDown
```
D-pad down

### DPadLeft
```cj
DPadLeft
```
D-pad left

### DPadRight
```cj
DPadRight
```
D-pad right

### DPadUp
```cj
DPadUp
```
D-pad up

### East
```cj
East
```
Right button (e.g. Xbox B)

### Guide
```cj
Guide
```
Guide button

### Invalid
```cj
Invalid
```
Invalid button (-1 on the C side)

### LeftPaddle1
```cj
LeftPaddle1
```
Left paddle 1

### LeftPaddle2
```cj
LeftPaddle2
```
Left paddle 2

### LeftShoulder
```cj
LeftShoulder
```
Left shoulder button

### LeftStick
```cj
LeftStick
```
Left stick pressed

### Misc1
```cj
Misc1
```
Misc button 1

### Misc2
```cj
Misc2
```
Misc button 2

### Misc3
```cj
Misc3
```
Misc button 3

### Misc4
```cj
Misc4
```
Misc button 4

### Misc5
```cj
Misc5
```
Misc button 5

### Misc6
```cj
Misc6
```
Misc button 6

### North
```cj
North
```
Top button (e.g. Xbox Y)

### RightPaddle1
```cj
RightPaddle1
```
Right paddle 1

### RightPaddle2
```cj
RightPaddle2
```
Right paddle 2

### RightShoulder
```cj
RightShoulder
```
Right shoulder button

### RightStick
```cj
RightStick
```
Right stick pressed

### South
```cj
South
```
Bottom button (e.g. Xbox A)

### Start
```cj
Start
```
Start button

### Touchpad
```cj
Touchpad
```
Touchpad

### West
```cj
West
```
Left button (e.g. Xbox X)

### func value\(\)
```cj
public func value(): UInt32
```
Converts the enum value to UInt32 (Invalid is the two's complement of -1)

Return: 

- The corresponding SDL value

