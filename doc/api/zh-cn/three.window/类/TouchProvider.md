# 类
## class TouchProvider
```cj
public class TouchProvider <: InputProvider
```
触摸输入提供者

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
帧末重置边沿状态

### func getTouchByID\(Int64\)
```cj
public func getTouchByID(fingerID: Int64): Option < TouchPoint >
```
获取指定 fingerID 的触摸点

参数: 

|名称|类型|描述|
|---|---|---|
|fingerID|Int64|手指实例 ID|

返回: 

- 触摸点数据；未找到返回 None

### func getTouchCount\(\)
```cj
public func getTouchCount(): Int64
```
获取当前活跃触摸点数量

返回: 

- 触摸点数量

### func getTouch\(Int64\)
```cj
public func getTouch(index: Int64): Option < TouchPoint >
```
获取指定索引的触摸点

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|触摸点索引（0-based）|

返回: 

- 触摸点数据；索引越界返回 None

### func getTouchesBegan\(\)
```cj
public func getTouchesBegan(): ArrayList < TouchPoint >
```
获取本帧新增的触摸点列表

返回: 

- 新增触摸点列表

### func getTouchesEnded\(\)
```cj
public func getTouchesEnded(): ArrayList < Int64 >
```
获取本帧移除的触摸点 fingerID 列表

返回: 

- 移除的 fingerID 列表

### func init\(\)
```cj
public init()
```
构造触摸提供者

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
处理触摸事件

参数: 

|名称|类型|描述|
|---|---|---|
|evt|DispatchEvent|分发事件|

