# 类
## class Mutex
```cj
public class Mutex
```
互斥锁

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁互斥锁

### func init\(\)
```cj
public init()
```
构造器：创建互斥锁

### func lock\(\)
```cj
public func lock(): Unit
```
锁定（阻塞）

### func tryLock\(\)
```cj
public func tryLock(): Bool
```
尝试锁定（非阻塞）

返回: 

- 成功返回 true

### func unlock\(\)
```cj
public func unlock(): Unit
```
解锁

