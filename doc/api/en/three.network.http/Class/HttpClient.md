# Class
## class HttpClient
```cj
public class HttpClient
```
Configurable HTTP client

### func close\(\)
```cj
public func close(): Unit
```
Closes the client (releases resources such as the connection pool)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>httpclient4cj does not expose an explicit close; the connection pool
is reclaimed by GC.</p>

### func enqueue\(HttpRequest,\(HttpResponse\)\->Unit,\(String\)\->Unit\)
```cj
public func enqueue(req: HttpRequest, onSuccess:(HttpResponse) -> Unit, onFailure:(String) -> Unit): Unit
```
Executes a request asynchronously via callbacks

Parameter: 

|Name|Type|Describe|
|---|---|---|
|req|HttpRequest|The request descriptiononSuccess Success callback: (HttpResponse) -> UnitonFailure Failure callback: (String) -> Unit|
|onSuccess|(HttpResponse)->Unit||
|onFailure|(String)->Unit||

### func execute\(HttpRequest\)
```cj
public func execute(req: HttpRequest): HttpResponse
```
Executes a request synchronously

Parameter: 

|Name|Type|Describe|
|---|---|---|
|req|HttpRequest|The request description|

Return: 

- Returns the HTTP response

### func init\(Int64,Int64,Int64\)
```cj
public init(connectTimeoutMs!: Int64 = 10000, readTimeoutMs!: Int64 = 10000, writeTimeoutMs!: Int64 = 10000)
```
Constructs a client

Parameter: 

|Name|Type|Describe|
|---|---|---|
|connectTimeoutMs|Int64|Connect timeout in milliseconds (default 10000)readTimeoutMs Read timeout in milliseconds (default 10000)writeTimeoutMs Write timeout in milliseconds (default 10000)|
|readTimeoutMs|Int64||
|writeTimeoutMs|Int64||

### let connectTimeoutMs
```cj
public let connectTimeoutMs: Int64
```
Connect timeout in milliseconds

### let readTimeoutMs
```cj
public let readTimeoutMs: Int64
```
Read timeout in milliseconds

### let writeTimeoutMs
```cj
public let writeTimeoutMs: Int64
```
Write timeout in milliseconds

