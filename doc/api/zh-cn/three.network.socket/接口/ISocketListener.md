# 接口
## interface ISocketListener
```cj
public interface ISocketListener
```
Socket 事件监听器接口

### func onClose\(SocketClient\)
```cj
func onClose(client: SocketClient): Unit
```
连接关闭回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|SocketClient|触发事件的客户端|

### func onError\(SocketClient,String\)
```cj
func onError(client: SocketClient, message: String): Unit
```
错误回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|SocketClient|触发事件的客户端message 错误消息|
|message|String||

### func onMessage\(SocketClient,Array<UInt8>\)
```cj
func onMessage(client: SocketClient, data: Array < UInt8 >): Unit
```
收到数据回调（原始字节）

参数: 

|名称|类型|描述|
|---|---|---|
|client|SocketClient|触发事件的客户端data 收到的原始字节|
|data|Array<UInt8>||

### func onOpen\(SocketClient\)
```cj
func onOpen(client: SocketClient): Unit
```
连接建立回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|SocketClient|触发事件的客户端|

