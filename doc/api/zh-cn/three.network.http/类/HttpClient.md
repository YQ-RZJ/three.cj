# 类
## class HttpClient
```cj
public class HttpClient
```
可配置 HTTP 客户端

### func close\(\)
```cj
public func close(): Unit
```
关闭客户端（释放连接池等资源）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>httpclient4cj 未暴露显式 close，连接池随 GC 回收。</p>

### func enqueue\(HttpRequest,\(HttpResponse\)\->Unit,\(String\)\->Unit\)
```cj
public func enqueue(req: HttpRequest, onSuccess:(HttpResponse) -> Unit, onFailure:(String) -> Unit): Unit
```
执行请求（异步回调）

参数: 

|名称|类型|描述|
|---|---|---|
|req|HttpRequest|请求描述onSuccess 成功回调：(HttpResponse) -> UnitonFailure 失败回调：(String) -> Unit|
|onSuccess|(HttpResponse)->Unit||
|onFailure|(String)->Unit||

### func execute\(HttpRequest\)
```cj
public func execute(req: HttpRequest): HttpResponse
```
执行请求（同步）

参数: 

|名称|类型|描述|
|---|---|---|
|req|HttpRequest|请求描述|

返回: 

- 返回 HTTP 响应

### func init\(Int64,Int64,Int64\)
```cj
public init(connectTimeoutMs!: Int64 = 10000, readTimeoutMs!: Int64 = 10000, writeTimeoutMs!: Int64 = 10000)
```
构造客户端

参数: 

|名称|类型|描述|
|---|---|---|
|connectTimeoutMs|Int64|连接超时（毫秒，默认 10000）readTimeoutMs 读取超时（毫秒，默认 10000）writeTimeoutMs 写入超时（毫秒，默认 10000）|
|readTimeoutMs|Int64||
|writeTimeoutMs|Int64||

### let connectTimeoutMs
```cj
public let connectTimeoutMs: Int64
```
连接超时（毫秒）

### let readTimeoutMs
```cj
public let readTimeoutMs: Int64
```
读取超时（毫秒）

### let writeTimeoutMs
```cj
public let writeTimeoutMs: Int64
```
写入超时（毫秒）

