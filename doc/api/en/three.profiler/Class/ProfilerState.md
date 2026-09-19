# Class
## class ProfilerState
```cj
public class ProfilerState
```
State queries — connection status, clock, thread name.

### func isConnected\(\)
```cj
public static func isConnected(): Bool
```
Whether the profiler GUI is connected

### func now\(\)
```cj
public static func now(): Int64
```
Current value of the Tracy high-resolution clock

### func threadName\(String\)
```cj
public static func threadName(name: String): Unit
```
Set the display name of the current thread (Tracy thread panel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

