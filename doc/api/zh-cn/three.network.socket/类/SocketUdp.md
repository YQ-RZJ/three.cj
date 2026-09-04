# 类
## class SocketUdp
```cj
public class SocketUdp
```
UDP 套接字

### func bind\(\)
```cj
public func bind(): Bool
```
绑定（使用构造时指定的端口）

返回: 

- 绑定成功返回 true；失败返回 false

### func bind\(UInt16\)
```cj
public func bind(port: UInt16): Bool
```
绑定本地端口（同步）

参数: 

|名称|类型|描述|
|---|---|---|
|port|UInt16|要绑定的端口|

返回: 

- 绑定成功返回 true；失败返回 false

### func close\(\)
```cj
public func close(): Unit
```
关闭套接字

### func init\(UInt16\)
```cj
public init(bindPort!: UInt16 = 0)
```
构造 UDP 套接字

参数: 

|名称|类型|描述|
|---|---|---|
|bindPort|UInt16|本地绑定端口（0 = 自动分配）|

### func receive\(\)
```cj
public func receive():(String, Array < UInt8 >)
```
阻塞接收数据

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>远端地址以 "host:port" 形式表达。</p>

返回: 

- 返回 (远端地址字符串, 数据字节)；失败时返回 ("", [])

### func sendString\(String,UInt16,String\)
```cj
public func sendString(host: String, port: UInt16, text: String): Bool
```
发送文本到指定远端（UTF-8）

参数: 

|名称|类型|描述|
|---|---|---|
|host|String|目标 IPport 目标端口text 待发送的文本|
|port|UInt16||
|text|String||

返回: 

- 发送成功返回 true；失败返回 false

### func sendTo\(String,UInt16,Array<UInt8>\)
```cj
public func sendTo(host: String, port: UInt16, data: Array < UInt8 >): Bool
```
发送数据到指定远端

参数: 

|名称|类型|描述|
|---|---|---|
|host|String|目标 IP（如 "127.0.0.1"）port 目标端口data 数据字节|
|port|UInt16||
|data|Array<UInt8>||

返回: 

- 发送成功返回 true；失败返回 false

### prop isBound: Bool
```cj
public prop isBound: Bool
```
是否已绑定

