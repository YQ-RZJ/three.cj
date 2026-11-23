# Interface
## interface ISocketListener
```cj
public interface ISocketListener
```
Socket event listener interface

### func onClose\(ISocketClient\)
```cj
func onClose(client: ISocketClient): Unit
```
Callback invoked when the connection is closed

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|ISocketClient|The client that fired the event|

### func onError\(ISocketClient,String\)
```cj
func onError(client: ISocketClient, message: String): Unit
```
Callback invoked on error

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|ISocketClient|The client that fired the eventmessage The error message|
|message|String||

### func onMessage\(ISocketClient,Array<UInt8>\)
```cj
func onMessage(client: ISocketClient, data: Array < UInt8 >): Unit
```
Callback invoked when data is received (raw bytes)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|ISocketClient|The client that fired the eventdata The raw bytes received|
|data|Array<UInt8>||

### func onOpen\(ISocketClient\)
```cj
func onOpen(client: ISocketClient): Unit
```
Callback invoked when the connection is established

Parameter: 

|Name|Type|Describe|
|---|---|---|
|client|ISocketClient|The client that fired the event|

