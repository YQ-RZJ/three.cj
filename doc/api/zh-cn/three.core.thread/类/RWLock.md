# 类
## class RWLock
```cj
public class RWLock
```
读写锁（多读者单写者）

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁读写锁

### func init\(\)
```cj
public init()
```
构造器：创建读写锁

### func lockRead\(\)
```cj
public func lockRead(): Unit
```
以读模式锁定（阻塞，可多个读者）

### func lockWrite\(\)
```cj
public func lockWrite(): Unit
```
以写模式锁定（阻塞，独占）

### func tryLockRead\(\)
```cj
public func tryLockRead(): Bool
```
尝试以读模式锁定（非阻塞）

返回: 

- 成功返回 true

### func tryLockWrite\(\)
```cj
public func tryLockWrite(): Bool
```
尝试以写模式锁定（非阻塞）

返回: 

- 成功返回 true

### func unlock\(\)
```cj
public func unlock(): Unit
```
解锁

