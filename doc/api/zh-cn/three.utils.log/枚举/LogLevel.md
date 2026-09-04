# 枚举
## enum LogLevel
```cj
public enum LogLevel
```
日志等级枚举

### Debug
```cj
Debug
```
调试级

### Error
```cj
Error
```
错误级

### Info
```cj
Info
```
信息级

### Off
```cj
Off
```
关闭日志输出

### Trace
```cj
Trace
```
跟踪级（最详细）

### Warn
```cj
Warn
```
警告级

### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): LogLevel
```
从 UInt32 转换回枚举值

参数: 

|名称|类型|描述|
|---|---|---|
|v|UInt32|数值|

返回: 

- 对应的枚举值（未知数值回落到 Off）

### func value\(\)
```cj
public func value(): UInt32
```
将枚举值转换为 UInt32

返回: 

- 对应的数值

