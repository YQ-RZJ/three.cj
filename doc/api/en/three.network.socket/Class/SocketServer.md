# Class
## class SocketServer
```cj
public class SocketServer
```
TCP server

### func accept\(\)
```cj
public func accept(): Option < SocketClient >
```
Accepts a client connection (blocking)

Return: 

- Returns a wrapped SocketClient, or None when not bound or on error

### func bind\(\)
```cj
public func bind(): Bool
```
Binds the port (synchronous)

Return: 

- Returns true on success, false on failure

### func close\(\)
```cj
public func close(): Unit
```
Closes the server

### func init\(UInt16\)
```cj
public init(port: UInt16)
```
Constructs a TCP server

Parameter: 

|Name|Type|Describe|
|---|---|---|
|port|UInt16|Bind port|

### prop isBound: Bool
```cj
public prop isBound: Bool
```
Whether the server is bound

### let port
```cj
public let port: UInt16
```
Bind port

