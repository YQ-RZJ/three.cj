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


### Low
```cj
Low
```


### Normal
```cj
Normal
```


### TimeCritical
```cj
TimeCritical
```


### func toSDLPriority\(\)
```cj
public func toSDLPriority(): Int32
```
Convert to SDL thread priority value

Return: 

- SDL_ThreadPriority enum value

