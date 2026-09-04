# 类
## class EventRecord
```cj
public class EventRecord
```
事件记录（监听器句柄）

### func init\(\)
```cj
public init()
```
默认构造器

### var callback
```cj
public var callback:(Array < Object >) -> Unit
```
回调函数

### var id
```cj
public var id: Int64
```
唯一 ID

### var name
```cj
public var name: String
```
事件名称

### var once
```cj
public var once: Bool
```
是否仅触发一次

### var target
```cj
public var target:?Object
```
目标对象（用于过滤分发）

