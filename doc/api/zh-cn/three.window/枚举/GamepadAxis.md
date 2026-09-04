# 枚举
## enum GamepadAxis
```cj
public enum GamepadAxis
```
手柄轴类型

### Invalid
```cj
Invalid
```
无效轴（C 端为 -1）

### LeftTrigger
```cj
LeftTrigger
```
左扳机

### LeftX
```cj
LeftX
```
左摇杆 X

### LeftY
```cj
LeftY
```
左摇杆 Y

### RightTrigger
```cj
RightTrigger
```
右扳机

### RightX
```cj
RightX
```
右摇杆 X

### RightY
```cj
RightY
```
右摇杆 Y

### func value\(\)
```cj
public func value(): UInt32
```
转换为 UInt32（Invalid 为 -1 的补码）

返回: 

- 对应的 SDL 数值

