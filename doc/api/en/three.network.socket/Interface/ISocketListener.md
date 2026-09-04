# Interface
## interface ISocketListener
```cj
public interface ISocketListener
```
Socket event listener interface

### func onClose\(SocketClient\)
```cj
func onClose(client: SocketClient): Unit
```
Callback invoked when the connection is closed

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|SocketClient|The client that fired the event|

### func onError\(SocketClient,String\)
```cj
func onError(client: SocketClient, message: String): Unit
```
Callback invoked on error

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|SocketClient|The client that fired the eventmessage The error message|
|message|String||

### func onMessage\(SocketClient,Array<UInt8>\)
```cj
func onMessage(client: SocketClient, data: Array < UInt8 >): Unit
```
Callback invoked when data is received (raw bytes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|SocketClient|The client that fired the eventdata The raw bytes received|
|data|Array<UInt8>||

### func onOpen\(SocketClient\)
```cj
func onOpen(client: SocketClient): Unit
```
Callback invoked when the connection is established

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|SocketClient|The client that fired the event|

