# Enum
## enum ThreadPriority
```cj
public enum ThreadPriority
```
Thread priority (corresponds to SDL_ThreadPriority)

### High
```cj
High
```
High priority

### Low
```cj
Low
```
Low priority

### Normal
```cj
Normal
```
Normal priority

### TimeCritical
```cj
TimeCritical
```
Time-critical (highest) priority

### func toSDLPriority\(\)
```cj
public func toSDLPriority(): Int32
```
Convert to SDL thread priority value

Return: 

- SDL_ThreadPriority enum value

