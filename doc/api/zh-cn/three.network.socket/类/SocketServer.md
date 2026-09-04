# 类
## class SocketServer
```cj
public class SocketServer
```
TCP 服务端

### func accept\(\)
```cj
public func accept(): Option < SocketClient >
```
阻塞接受一个客户端连接

返回: 

- 返回包装好的 SocketClient；未绑定或出错时返回 None

### func bind\(\)
```cj
public func bind(): Bool
```
绑定端口（同步）

返回: 

- 绑定成功返回 true；失败返回 false

### func close\(\)
```cj
public func close(): Unit
```
关闭服务端

### func init\(UInt16\)
```cj
public init(port: UInt16)
```
构造 TCP 服务端

参数: 

|名称|类型|描述|
|---|---|---|
|port|UInt16|绑定端口|

### prop isBound: Bool
```cj
public prop isBound: Bool
```
是否已绑定

### let port
```cj
public let port: UInt16
```
绑定端口

