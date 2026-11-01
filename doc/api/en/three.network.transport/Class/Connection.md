# Class
## class Connection
```cj
public class Connection
```
Game-grade TCP connection

### func close\(\)
```cj
public func close(): Unit
```
Closes the connection (user-initiated; no onDisconnected, no auto reconnect)

### func connect\(\)
```cj
public func connect(): Bool
```
Establishes the connection and starts the receive thread (blocking)

Return: 

- True on success (onConnected fired synchronously); false on failure

### func init\(String,UInt16\)
```cj
public init(host: String, port: UInt16)
```
Constructs a connection (call connect to establish)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|host|String|Target host (IP or domain)port Target port|
|port|UInt16||

### func sendString\(String\)
```cj
public func sendString(s: String): Bool
```
Sends a text data frame (UTF-8)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|Text|

Return: 

- True on success

### func send\(Array<UInt8>\)
```cj
public func send(data: Array < UInt8 >): Bool
```
Sends a data frame (FRAME_DATA; callable from any thread)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Payload bytes (framing added internally)|

Return: 

- True on success; false when not connected or on write failure

### func update\(\)
```cj
public func update(): Unit
```
Per-frame main-loop driver: heartbeat send + liveness check + callback
dispatch + auto reconnect

### prop isConnected: Bool
```cj
public prop isConnected: Bool
```
Whether connected

### var autoReconnect
```cj
public var autoReconnect: Bool = false
```
Whether to reconnect automatically after a broken connection (default false)

### var heartbeatIntervalMs
```cj
public var heartbeatIntervalMs: Float64 = 5000.0
```
Heartbeat send interval in ms (0 = disabled, default 5000)

### var heartbeatTimeoutMs
```cj
public var heartbeatTimeoutMs: Float64 = 15000.0
```
Heartbeat timeout in ms (no frame beyond this marks broken, 0 = disabled,
default 15000)

### let host
```cj
public let host: String
```
Target host

### var maxReconnectDelayMs
```cj
public var maxReconnectDelayMs: Float64 = 30000.0
```
Auto reconnect backoff cap in ms (default 30000)

### var onConnected
```cj
public var onConnected: Option <() -> Unit >= None
```
Connected callback (runs on the main-loop thread)

### var onDisconnected
```cj
public var onDisconnected: Option <(String) -> Unit >= None
```
Disconnected callback (main-loop thread; parameter is the reason)

### var onMessage
```cj
public var onMessage: Option <(Array < UInt8 >) -> Unit >= None
```
Data-frame callback (runs on the receive thread; mind the threading model)

### let port
```cj
public let port: UInt16
```
Target port

