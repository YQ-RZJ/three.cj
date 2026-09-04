# Enum
## enum GamepadAxis
```cj
public enum GamepadAxis
```
Gamepad axis type

### Invalid
```cj
Invalid
```
Invalid axis (-1 on the C side)

### LeftTrigger
```cj
LeftTrigger
```
Left trigger

### LeftX
```cj
LeftX
```
Left stick X

### LeftY
```cj
LeftY
```
Left stick Y

### RightTrigger
```cj
RightTrigger
```
Right trigger

### RightX
```cj
RightX
```
Right stick X

### RightY
```cj
RightY
```
Right stick Y

### func value\(\)
```cj
public func value(): UInt32
```
Converts the enum value to UInt32 (Invalid is the two's complement of -1)

Return: 

- The corresponding SDL value

