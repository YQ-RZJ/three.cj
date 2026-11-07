# Class
## class SocketServer
```cj
public class SocketServer <: IReleasable
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

### func init\(UInt16\)
```cj
public init(port: UInt16)
```
Constructs a TCP server

Parameter: 

|Name|Type|Describe|
|---|---|---|
|port|UInt16|Bind port|

### func release\(\)
```cj
public func release(): Bool
```
Closes the server

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Idempotent no-op returning false when not bound.</p>

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

