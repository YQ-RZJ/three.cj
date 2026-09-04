# 类
## class RecursiveMutex
```cj
public class RecursiveMutex
```
可重入互斥锁

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁互斥锁（仅建议在无竞争时调用）

### func init\(\)
```cj
public init()
```
构造器

### func lock\(\)
```cj
public func lock(): Unit
```
锁定（阻塞）。同一线程可重复调用，仅递增深度。

### func tryLock\(\)
```cj
public func tryLock(): Bool
```
尝试锁定（非阻塞）。同一线程可重复调用，仅递增深度。

返回: 

- 成功返回 true

### func unlock\(\)
```cj
public func unlock(): Unit
```
解锁。深度减一，归零后才真正释放底层锁。

### func withLock\(\(\)\->T\)
```cj
public func withLock < T >(callback:() -> T): T
```
执行回调函数并加锁，返回结果。回调结束后自动解锁。

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->T|回调函数|

返回: 

- 回调函数返回值

