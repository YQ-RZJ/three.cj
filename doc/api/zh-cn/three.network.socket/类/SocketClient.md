# 类
## class SocketClient
```cj
public class SocketClient
```
TCP 客户端

### func close\(\)
```cj
public func close(): Unit
```
关闭连接

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>关闭后触发 onClose。</p>

### func connect\(\)
```cj
public func connect(): Bool
```
建立连接（同步阻塞）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>连接成功时触发 onOpen，失败时触发 onError。</p>

返回: 

- 连接成功返回 true；失败返回 false

### func init\(String,UInt16\)
```cj
public init(host: String, port: UInt16)
```
构造 TCP 客户端

参数: 

|名称|类型|描述|
|---|---|---|
|host|String|目标主机（IP 或域名）port 目标端口|
|port|UInt16||

### func readString\(\)
```cj
public func readString(): String
```
接收文本（阻塞）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>按单次 read 返回；如需读取一整行可在上层自行组包。</p>

返回: 

- 返回本次 read 读取的数据解码为 UTF-8 的字符串；无数据时返回空串

### func read\(Array<UInt8>\)
```cj
public func read(buf: Array < UInt8 >): Int64
```
接收数据（阻塞）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>收到数据时触发 onMessage，出错时触发 onError。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|buf|Array<UInt8>|接收缓冲区，最多读取 buf 大小字节|

返回: 

- 返回实际读取的字节数；连接关闭或出错返回 -1

### func writeString\(String\)
```cj
public func writeString(s: String): Bool
```
发送文本（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|待发送的文本|

返回: 

- 发送成功返回 true；失败返回 false

### func write\(Array<UInt8>\)
```cj
public func write(data: Array < UInt8 >): Bool
```
发送原始字节

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|待发送的字节数组|

返回: 

- 发送成功返回 true；失败返回 false

### prop isConnected: Bool
```cj
public prop isConnected: Bool
```
是否已连接

### let host
```cj
public let host: String
```
目标主机

### var listener
```cj
public var listener: Option < ISocketListener >= None
```
事件监听器

### let port
```cj
public let port: UInt16
```
目标端口

