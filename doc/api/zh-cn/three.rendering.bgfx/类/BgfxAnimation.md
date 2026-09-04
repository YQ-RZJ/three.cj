# 类
## class BgfxAnimation
```cj
public class BgfxAnimation
```
bgfx 动画管理

### func init\(\)
```cj
public init()
```


### func isRunning\(\)
```cj
public func isRunning(): Bool
```
是否正在运行

返回: 

- 是否正在运行

### func setCallback\(AnimationCallback\)
```cj
public func setCallback(cb: AnimationCallback): Unit
```
设置动画回调

参数: 

|名称|类型|描述|
|---|---|---|
|cb|AnimationCallback|动画回调函数|

### func start\(\)
```cj
public func start(): Unit
```
启动动画循环

### func stop\(\)
```cj
public func stop(): Unit
```
停止动画循环

### func tick\(\)
```cj
public func tick(): Unit
```
执行一帧动画

