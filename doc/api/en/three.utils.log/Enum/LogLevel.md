# Enum
## enum LogLevel
```cj
public enum LogLevel
```
Log-level enum

### Debug
```cj
Debug
```
Debug level

### Error
```cj
Error
```
Error level

### Info
```cj
Info
```
Info level

### Off
```cj
Off
```
Turns logging off

### Trace
```cj
Trace
```
Trace level (most verbose)

### Warn
```cj
Warn
```
Warn level

### func fromValue\(UInt32\)
```cj
public static func fromValue(v: UInt32): LogLevel
```
Converts a UInt32 back to the enum value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|UInt32|The numeric value|

Return: 

- The matching enum value (unknown values fall back to Off)

### func value\(\)
```cj
public func value(): UInt32
```
Converts the enum value to UInt32

Return: 

- The corresponding numeric value

