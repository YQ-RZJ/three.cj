# Class
## class SocketClient
```cj
public class SocketClient
```
TCP client

### func close\(\)
```cj
public func close(): Unit
```
Closes the connection

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Fires onClose after closing.</p>

### func connect\(\)
```cj
public func connect(): Bool
```
Establishes a connection (synchronous, blocking)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Fires onOpen on success and onError on failure.</p>

Return: 

- Returns true on success, false on failure

### func init\(String,UInt16\)
```cj
public init(host: String, port: UInt16)
```
Constructs a TCP client

Parameter: 

|Name|Type|Describe|
|---|---|---|
|host|String|Target host (IP or domain name)port Target port|
|port|UInt16||

### func readString\(\)
```cj
public func readString(): String
```
Receives text (blocking)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Returns a single read; assemble frames yourself at the call site when
reading whole lines.</p>

Return: 

- Returns the data of a single read decoded as a UTF-8 string, or anempty string when there is no data

### func read\(Array<UInt8>\)
```cj
public func read(buf: Array < UInt8 >): Int64
```
Receives data (blocking)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Fires onMessage when data arrives and onError on failure.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buf|Array<UInt8>|Receive buffer; reads at most buf.size bytes|

Return: 

- Returns the actual number of bytes read, or -1 when the connectionis closed or an error occurs

### func writeString\(String\)
```cj
public func writeString(s: String): Bool
```
Sends a text string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|The text to send|

Return: 

- Returns true on success, false on failure

### func write\(Array<UInt8>\)
```cj
public func write(data: Array < UInt8 >): Bool
```
Sends raw bytes

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The byte array to send|

Return: 

- Returns true on success, false on failure

### prop isConnected: Bool
```cj
public prop isConnected: Bool
```
Whether the client is connected

### let host
```cj
public let host: String
```
Target host

### var listener
```cj
public var listener: Option < ISocketListener >= None
```
Event listener

### let port
```cj
public let port: UInt16
```
Target port

