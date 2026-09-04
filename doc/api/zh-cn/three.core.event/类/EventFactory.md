# 类
## class EventFactory
```cj
public class EventFactory
```
事件对象池

### func allocate\(\)
```cj
public func allocate(): EventRecord
```
分配一个 EventRecord 实例

返回: 

- 已分配 ID 的 EventRecord，调用方需立即设置 name/target/once/callback

### func clear\(\)
```cj
public func clear(): Unit
```
清空对象池

### func init\(\)
```cj
public init()
```
默认构造器

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
指定初始预分配容量的构造器

参数: 

|名称|类型|描述|
|---|---|---|
|capacity|Int64|预先创建的对象数量，热路径调用前预热|

### func recycle\(EventRecord\)
```cj
public func recycle(record: EventRecord): Unit
```
回收 EventRecord 实例

参数: 

|名称|类型|描述|
|---|---|---|
|record|EventRecord|待回收的实例|

### prop allocatedCount: Int64
```cj
public prop allocatedCount: Int64
```
已分配数量

### prop freeCount: Int64
```cj
public prop freeCount: Int64
```
池中空闲数量

