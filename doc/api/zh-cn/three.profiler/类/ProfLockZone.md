# 类
## class ProfLockZone
```cj
public class ProfLockZone <: Resource
```
锁跟踪作用域 — 登记 lockable 上下文并在退出时上报 unlock

### func close\(\)
```cj
public func close(): Unit
```
释放（发射 afterUnlock，幂等；try-with-resources 自动调用）

### func init\(String,String,UInt32\)
```cj
public init(name: String, file: String, line: UInt32)
```
登记并进入锁作用域（beforeLock + afterLock）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|file|String||
|line|UInt32||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed

