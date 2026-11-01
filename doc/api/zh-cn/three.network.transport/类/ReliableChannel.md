# 类
## class ReliableChannel
```cj
public class ReliableChannel
```
可靠 UDP 通道

### func bind\(\)
```cj
public func bind(): Bool
```
绑定本地端口并启动收包线程（同步）

返回: 

- 绑定成功返回 true

### func close\(\)
```cj
public func close(): Unit
```
关闭通道并停止收包线程

### func init\(String,UInt16,UInt16\)
```cj
public init(remoteHost: String, remotePort: UInt16, bindPort!: UInt16 = 0)
```
构造可靠通道（需调用 bind）

参数: 

|名称|类型|描述|
|---|---|---|
|remoteHost|String|远端主机remotePort 远端端口bindPort 本地绑定端口（0 = 自动分配）|
|remotePort|UInt16||
|bindPort|UInt16||

### func send\(Array<UInt8>\)
```cj
public func send(data: Array < UInt8 >): Bool
```
发送可靠包（挂 pending 待确认；任意线程可调用）

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|载荷（≤ RELIABLE_MAX_PAYLOAD）|

返回: 

- 入队并发送成功返回 true

### func update\(\)
```cj
public func update(): Unit
```
主循环每帧驱动：超时重发 + 按序派发回调

### prop pendingCount: Int64
```cj
public prop pendingCount: Int64
```
在途未确认包数量

### prop rttMs: Int64
```cj
public prop rttMs: Int64
```
平滑 RTT（毫秒；未采样时为 0）

### var maxResendDelayMs
```cj
public var maxResendDelayMs: Float64 = 2000.0
```
重发间隔上限（毫秒，默认 2000）

### var onMessage
```cj
public var onMessage: Option <(Array < UInt8 >) -> Unit >= None
```
数据到达回调（主循环 update 派发，按序）

### let remoteHost
```cj
public let remoteHost: String
```
远端主机

### let remotePort
```cj
public let remotePort: UInt16
```
远端端口

### var resendDelayMs
```cj
public var resendDelayMs: Float64 = 100.0
```
初始重发间隔（毫秒，默认 100）

