# 类
## class InputProvider
```cj
public open class InputProvider
```
输入提供者抽象基类

### func \`init\`\(\)
```cj
public open func `init`(): Unit
```
初始化提供者（绑定窗口后调用）

### func beginFrame\(\)
```cj
public open func beginFrame(): Unit
```
每帧开始：轮询设备状态（如手柄）+ 准备接收事件

### func endFrame\(\)
```cj
public open func endFrame(): Unit
```
每帧结束：重置边沿状态（如 pressed/released）和累积量（如位移/滚轮）

### func getWindow\(\)
```cj
public func getWindow(): Option < WindowEngine >
```
获取绑定的窗口引擎

返回: 

- 绑定的窗口引擎；未绑定时返回 None

### func isBound\(\)
```cj
public func isBound(): Bool
```
是否已绑定窗口

### func onEvent\(DispatchEvent\)
```cj
public open func onEvent(evt: DispatchEvent): Unit
```
处理一条分发事件

参数: 

|名称|类型|描述|
|---|---|---|
|evt|DispatchEvent|分发器投递的轻量事件|

### func shutdown\(\)
```cj
public open func shutdown(): Unit
```
清理资源（窗口关闭时调用）

