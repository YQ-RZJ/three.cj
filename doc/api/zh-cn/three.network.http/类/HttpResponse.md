# 类
## class HttpResponse
```cj
public class HttpResponse
```
HTTP 响应

### func bodyString\(\)
```cj
public func bodyString(): String
```
获取正文文本

返回: 

- 返回正文文本；空正文返回空串

### func header\(String\)
```cj
public func header(name: String): Option < String >
```
按名称获取响应头

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|头部名称|

返回: 

- 返回匹配的头部值；不存在返回 None

### func init\(Int64,String,Array<\(String,String\)>,Option<String>\)
```cj
public init(code: Int64, message: String, headers!: Array <(String, String) >=[], body!: Option < String >= None)
```
构造响应

参数: 

|名称|类型|描述|
|---|---|---|
|code|Int64|状态码message 状态消息headers 响应头部（可选）body 正文（可选）|
|message|String||
|headers|Array<(String,String)>||
|body|Option<String>||

### prop contentType: String
```cj
public prop contentType: String
```
响应内容类型（Content-Type 头的值）

### prop isRedirect: Bool
```cj
public prop isRedirect: Bool
```
是否重定向（3xx）

### prop isSuccess: Bool
```cj
public prop isSuccess: Bool
```
是否成功（2xx）

### let body
```cj
public let body: Option < String >
```
正文（文本形式；二进制时为空）

### let code
```cj
public let code: Int64
```
状态码（200/404/500 等）

### let headers
```cj
public let headers: Array <(String, String) >
```
响应头部（name, value 键值对）

### let message
```cj
public let message: String
```
状态消息（如 "OK"）

