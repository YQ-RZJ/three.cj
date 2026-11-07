# 类
## class SocketServer
```cj
public class SocketServer <: IReleasable
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

### func init\(UInt16\)
```cj
public init(port: UInt16)
```
构造 TCP 服务端

参数: 

|名称|类型|描述|
|---|---|---|
|port|UInt16|绑定端口|

### func release\(\)
```cj
public func release(): Bool
```
关闭服务端

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>未绑定时为幂等空操作并返回 false。</p>

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

