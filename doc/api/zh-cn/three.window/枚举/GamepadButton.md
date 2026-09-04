# 枚举
## enum GamepadButton
```cj
public enum GamepadButton
```
手柄按键类型

### Back
```cj
Back
```
返回键

### Count
```cj
Count
```
按键总数（非真实按键，标记枚举末尾）

### DPadDown
```cj
DPadDown
```
十字键下

### DPadLeft
```cj
DPadLeft
```
十字键左

### DPadRight
```cj
DPadRight
```
十字键右

### DPadUp
```cj
DPadUp
```
十字键上

### East
```cj
East
```
右侧按键（如 Xbox B）

### Guide
```cj
Guide
```
主页键

### Invalid
```cj
Invalid
```
无效按键（C 端为 -1）

### LeftPaddle1
```cj
LeftPaddle1
```
左侧拨片 1

### LeftPaddle2
```cj
LeftPaddle2
```
左侧拨片 2

### LeftShoulder
```cj
LeftShoulder
```
左肩键

### LeftStick
```cj
LeftStick
```
左摇杆按下

### Misc1
```cj
Misc1
```
杂项键 1

### Misc2
```cj
Misc2
```
杂项键 2

### Misc3
```cj
Misc3
```
杂项键 3

### Misc4
```cj
Misc4
```
杂项键 4

### Misc5
```cj
Misc5
```
杂项键 5

### Misc6
```cj
Misc6
```
杂项键 6

### North
```cj
North
```
顶部按键（如 Xbox Y）

### RightPaddle1
```cj
RightPaddle1
```
右侧拨片 1

### RightPaddle2
```cj
RightPaddle2
```
右侧拨片 2

### RightShoulder
```cj
RightShoulder
```
右肩键

### RightStick
```cj
RightStick
```
右摇杆按下

### South
```cj
South
```
底部按键（如 Xbox A）

### Start
```cj
Start
```
开始键

### Touchpad
```cj
Touchpad
```
触摸板

### West
```cj
West
```
左侧按键（如 Xbox X）

### func value\(\)
```cj
public func value(): UInt32
```
转换为 UInt32（Invalid 为 -1 的补码）

返回: 

- 对应的 SDL 数值

