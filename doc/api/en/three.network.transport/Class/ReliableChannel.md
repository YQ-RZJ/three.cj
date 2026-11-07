# Class
## class ReliableChannel
```cj
public class ReliableChannel <: IReleasable
```
Reliable UDP channel

### func bind\(\)
```cj
public func bind(): Bool
```
Binds the local port and starts the receive thread (synchronous)

Return: 

- True on successful bind

### func init\(String,UInt16,UInt16\)
```cj
public init(remoteHost: String, remotePort: UInt16, bindPort!: UInt16 = 0)
```
Constructs a reliable channel (call bind)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|remoteHost|String|Remote hostremotePort Remote portbindPort Local bind port (0 = auto-assigned)|
|remotePort|UInt16||
|bindPort|UInt16||

### func release\(\)
```cj
public func release(): Bool
```
Closes the channel and stops the receive thread

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Idempotent no-op returning false when not bound.</p>

### func send\(Array<UInt8>\)
```cj
public func send(data: Array < UInt8 >): Bool
```
Sends a reliable packet (parked in pending; callable from any thread)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|Payload (≤ RELIABLE_MAX_PAYLOAD)|

Return: 

- True when enqueued and sent

### func update\(\)
```cj
public func update(): Unit
```
Per-frame main-loop driver: timeout resends + in-order callback dispatch

### prop pendingCount: Int64
```cj
public prop pendingCount: Int64
```
Number of in-flight unconfirmed packets

### prop rttMs: Int64
```cj
public prop rttMs: Int64
```
Smoothed RTT in ms (0 before any sample)

### var maxResendDelayMs
```cj
public var maxResendDelayMs: Float64 = 2000.0
```
Resend interval cap in ms (default 2000)

### var onMessage
```cj
public var onMessage: Option <(Array < UInt8 >) -> Unit >= None
```
Data callback (dispatched in order on main-loop update)

### let remoteHost
```cj
public let remoteHost: String
```
Remote host

### let remotePort
```cj
public let remotePort: UInt16
```
Remote port

### var resendDelayMs
```cj
public var resendDelayMs: Float64 = 100.0
```
Initial resend interval in ms (default 100)

