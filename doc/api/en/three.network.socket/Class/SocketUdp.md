# Class
## class SocketUdp
```cj
public class SocketUdp
```
UDP socket

### func bind\(UInt16\)
```cj
public func bind(port: UInt16): Bool
```
Binds a local port (synchronous)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|port|UInt16|The port to bind|

Return: 

- Returns true on success, false on failure

### func bind\(\)
```cj
public func bind(): Bool
```
Binds using the port given at construction time

Return: 

- Returns true on success, false on failure

### func close\(\)
```cj
public func close(): Unit
```
Closes the socket

### func init\(UInt16\)
```cj
public init(bindPort!: UInt16 = 0)
```
Constructs a UDP socket

Parameter: 

|Name|Type|Describe|
|---|---|---|
|bindPort|UInt16|Local bind port (0 = automatically assigned)|

### func receive\(\)
```cj
public func receive():(String, Array < UInt8 >)
```
Receives data (blocking)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The remote address is expressed as "host:port".</p>

Return: 

- Returns (remote address string, data bytes); on failure returns ("", [])

### func sendString\(String,UInt16,String\)
```cj
public func sendString(host: String, port: UInt16, text: String): Bool
```
Sends a text string to the specified remote peer (UTF-8)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|host|String|Target IPport Target porttext The text to send|
|port|UInt16||
|text|String||

Return: 

- Returns true on success, false on failure

### func sendTo\(String,UInt16,Array<UInt8>\)
```cj
public func sendTo(host: String, port: UInt16, data: Array < UInt8 >): Bool
```
Sends data to the specified remote peer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|host|String|Target IP (e.g. "127.0.0.1")port Target portdata The data bytes|
|port|UInt16||
|data|Array<UInt8>||

Return: 

- Returns true on success, false on failure

### prop isBound: Bool
```cj
public prop isBound: Bool
```
Whether the socket is bound

