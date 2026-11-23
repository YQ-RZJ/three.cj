# 接口
## interface ISocketListener
```cj
public interface ISocketListener
```
Socket 事件监听器接口

### func onClose\(ISocketClient\)
```cj
func onClose(client: ISocketClient): Unit
```
连接关闭回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|ISocketClient|触发事件的客户端|

### func onError\(ISocketClient,String\)
```cj
func onError(client: ISocketClient, message: String): Unit
```
错误回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|ISocketClient|触发事件的客户端message 错误消息|
|message|String||

### func onMessage\(ISocketClient,Array<UInt8>\)
```cj
func onMessage(client: ISocketClient, data: Array < UInt8 >): Unit
```
收到数据回调（原始字节）

参数: 

|名称|类型|描述|
|---|---|---|
|client|ISocketClient|触发事件的客户端data 收到的原始字节|
|data|Array<UInt8>||

### func onOpen\(ISocketClient\)
```cj
func onOpen(client: ISocketClient): Unit
```
连接建立回调

参数: 

|名称|类型|描述|
|---|---|---|
|client|ISocketClient|触发事件的客户端|

