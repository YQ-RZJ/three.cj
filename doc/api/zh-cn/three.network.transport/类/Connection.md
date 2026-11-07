# 类
## class Connection
```cj
public class Connection <: IReleasable
```
TCP 游戏连接

### func connect\(\)
```cj
public func connect(): Bool
```
建立连接并启动收包线程（同步阻塞）

返回: 

- 连接成功返回 true（成功时同步触发 onConnected）；失败返回 false

### func init\(String,UInt16\)
```cj
public init(host: String, port: UInt16)
```
构造连接（不发起连接，需调用 connect）

参数: 

|名称|类型|描述|
|---|---|---|
|host|String|目标主机（IP 或域名）port 目标端口|
|port|UInt16||

### func release\(\)
```cj
public func release(): Bool
```
关闭连接（用户主动；不触发 onDisconnected、不自动重连）

### func sendString\(String\)
```cj
public func sendString(s: String): Bool
```
发送文本数据帧（UTF-8）

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|文本|

返回: 

- 发送成功返回 true

### func send\(Array<UInt8>\)
```cj
public func send(data: Array < UInt8 >): Bool
```
发送数据帧（FRAME_DATA；任意线程可调用）

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|载荷字节（不含帧头，内部自动组帧）|

返回: 

- 发送成功返回 true；未连接或写失败返回 false

### func update\(\)
```cj
public func update(): Unit
```
主循环每帧驱动：心跳发送 + 断线检测 + 回调派发 + 自动重连

### prop isConnected: Bool
```cj
public prop isConnected: Bool
```
是否已连接

### var autoReconnect
```cj
public var autoReconnect: Bool = false
```
断线后是否自动重连（默认 false）

### var heartbeatIntervalMs
```cj
public var heartbeatIntervalMs: Float64 = 5000.0
```
心跳发送间隔（毫秒；0 = 禁用心跳，默认 5000）

### var heartbeatTimeoutMs
```cj
public var heartbeatTimeoutMs: Float64 = 15000.0
```
心跳超时（毫秒；连续无帧超过该值判定断线，0 = 禁用检测，默认 15000）

### let host
```cj
public let host: String
```
目标主机

### var maxReconnectDelayMs
```cj
public var maxReconnectDelayMs: Float64 = 30000.0
```
自动重连退避上限（毫秒，默认 30000）

### var onConnected
```cj
public var onConnected: Option <() -> Unit >= None
```
连接建立回调（主循环线程执行）

### var onDisconnected
```cj
public var onDisconnected: Option <(String) -> Unit >= None
```
断线回调（主循环线程执行，参数为原因）

### var onMessage
```cj
public var onMessage: Option <(Array < UInt8 >) -> Unit >= None
```
数据帧回调（在收包线程执行，注意线程模型）

### let port
```cj
public let port: UInt16
```
目标端口

