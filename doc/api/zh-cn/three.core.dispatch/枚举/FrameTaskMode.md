# 枚举
## enum FrameTaskMode
```cj
public enum FrameTaskMode
```
帧任务模式

### CONSUME
```cj
CONSUME
```
消耗型：每次 run pop 一个参数执行，参数队列空时自动结束

### LOOP
```cj
LOOP
```
循环型：每次 run next() 不消耗参数，由 callback 决定何时停止本帧

### ONCE
```cj
ONCE
```
一次性：执行一次 callback 后自动 unregister，不使用参数队列

