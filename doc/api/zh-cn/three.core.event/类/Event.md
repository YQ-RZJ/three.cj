# 类
## class Event
```cj
public class Event
```
事件对象，在分发事件时传递给监听器

### func init\(String\)
```cj
public init(`type`: String)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|String||

### var \`type\`
```cj
public var `type`: String
```
事件类型

### var target
```cj
public var target:?EventDispatcher
```
事件目标（分发事件的对象），由 dispatchEvent 自动设置

