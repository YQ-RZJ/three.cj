# 类
## class KeyboardProvider
```cj
public class KeyboardProvider <: InputProvider
```
键盘输入提供者

### func endFrame\(\)
```cj
public override func endFrame(): Unit
```
帧末重置边沿状态

### func init\(\)
```cj
public init()
```
构造键盘提供者

### func isKeyDown\(UInt32\)
```cj
public func isKeyDown(scancode: UInt32): Bool
```
查询键盘某键当前是否按下

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32|键盘扫描码（SDL_SCANCODE_*）|

返回: 

- 按下返回 true，否则 false

### func isKeyPressed\(UInt32\)
```cj
public func isKeyPressed(scancode: UInt32): Bool
```
查询键盘某键本帧是否刚按下（边沿触发）

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32|键盘扫描码（SDL_SCANCODE_*）|

返回: 

- 刚按下返回 true，否则 false

### func isKeyReleased\(UInt32\)
```cj
public func isKeyReleased(scancode: UInt32): Bool
```
查询键盘某键本帧是否刚释放（边沿触发）

参数: 

|名称|类型|描述|
|---|---|---|
|scancode|UInt32|键盘扫描码（SDL_SCANCODE_*）|

返回: 

- 刚释放返回 true，否则 false

### func onEvent\(DispatchEvent\)
```cj
public override func onEvent(evt: DispatchEvent): Unit
```
处理键盘事件

参数: 

|名称|类型|描述|
|---|---|---|
|evt|DispatchEvent|分发事件|

