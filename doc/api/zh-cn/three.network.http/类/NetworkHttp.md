# 类
## class NetworkHttp
```cj
public class NetworkHttp
```
HTTP 客户端静态工具

### func execute\(HttpRequest\)
```cj
public static func execute(req: HttpRequest): HttpResponse
```
执行一次 HTTP 请求（同步，默认 10s 超时）

参数: 

|名称|类型|描述|
|---|---|---|
|req|HttpRequest|请求描述|

返回: 

- 返回 HTTP 响应

### func get\(String,Array<\(String,String\)>\)
```cj
public static func get(url: String, headers!: Array <(String, String) >=[]): HttpResponse
```
便捷 GET（同步）

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLheaders 请求头部（可选）|
|headers|Array<(String,String)>||

返回: 

- 返回 HTTP 响应

### func post\(String,String,Array<\(String,String\)>\)
```cj
public static func post(url: String, json!: String = "", headers!: Array <(String, String) >=[]): HttpResponse
```
便捷 POST JSON（同步）

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLjson JSON 正文（默认空）headers 请求头部（可选）|
|json|String||
|headers|Array<(String,String)>||

返回: 

- 返回 HTTP 响应

