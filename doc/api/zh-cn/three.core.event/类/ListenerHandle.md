# 类
## class ListenerHandle
```cj
public class ListenerHandle
```
监听器句柄，包装回调函数以支持引用比较

### func init\(\(Event\)\->Unit\)
```cj
public init(callback:(Event) -> Unit)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|callback|(Event)->Unit|回调函数|

### let callback
```cj
public let callback:(Event) -> Unit
```
回调函数

