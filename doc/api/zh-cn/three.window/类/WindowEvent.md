# 类
## class WindowEvent
```cj
public class WindowEvent
```
窗口事件

### func init\(UInt32,Int32,Int32\)
```cj
public init(`type`!: UInt32, data1!: Int32, data2!: Int32)
```
构造窗口事件

参数: 

|名称|类型|描述|
|---|---|---|
|`type`|UInt32|窗口事件类型（SDL_EVENT_WINDOW_*）data1 事件相关数据 1（如 resize 的宽度）data2 事件相关数据 2（如 resize 的高度）|
|data1|Int32||
|data2|Int32||

### var \`type\`
```cj
public var `type`: UInt32 = 0
```
窗口事件类型（SDL_EVENT_WINDOW_*）

### var data1
```cj
public var data1: Int32 = 0
```
事件相关数据 1（如 resize 的宽度）

### var data2
```cj
public var data2: Int32 = 0
```
事件相关数据 2（如 resize 的高度）

