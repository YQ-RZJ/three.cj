# Class
## class SdlTimer
```cj
public class SdlTimer
```
SDL timer utility (static methods)

### func delayNS\(UInt64\)
```cj
public static func delayNS(ns: UInt64): Unit
```
Delay for the specified nanoseconds

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ns|UInt64|Number of nanoseconds to delay|

### func delay\(UInt32\)
```cj
public static func delay(ms: UInt32): Unit
```
Delay for the specified milliseconds

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ms|UInt32|Number of milliseconds to delay|

### func getPerformanceCounter\(\)
```cj
public static func getPerformanceCounter(): UInt64
```
Get high-precision performance counter value

Return: 

- Current performance counter value

### func getPerformanceFrequency\(\)
```cj
public static func getPerformanceFrequency(): UInt64
```
Get performance counter frequency (counts per second)

Return: 

- Performance counter frequency

### func getTicksNS\(\)
```cj
public static func getTicksNS(): UInt64
```
Get nanoseconds since SDL initialization

Return: 

- Nanoseconds since SDL initialization

### func getTicks\(\)
```cj
public static func getTicks(): UInt64
```
Get milliseconds since SDL initialization

Return: 

- Milliseconds since SDL initialization

