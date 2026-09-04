# 枚举
## enum ThreadPriority
```cj
public enum ThreadPriority
```
线程优先级（对应 SDL_ThreadPriority）

### High
```cj
High
```
高优先级

### Low
```cj
Low
```
低优先级

### Normal
```cj
Normal
```
正常优先级

### TimeCritical
```cj
TimeCritical
```
时间关键（最高）优先级

### func toSDLPriority\(\)
```cj
public func toSDLPriority(): Int32
```
转换为 SDL 线程优先级数值

返回: 

- SDL_ThreadPriority 枚举值

