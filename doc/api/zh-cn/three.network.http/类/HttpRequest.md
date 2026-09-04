# 类
## class HttpRequest
```cj
public class HttpRequest
```
HTTP 请求描述

### func delete\(String,Array<\(String,String\)>\)
```cj
public static func delete(url: String, headers!: Array <(String, String) >=[]): HttpRequest
```
便捷构造：DELETE 请求

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLheaders 请求头部（可选）|
|headers|Array<(String,String)>||

返回: 

- 返回构造好的 DELETE 请求

### func get\(String,Array<\(String,String\)>\)
```cj
public static func get(url: String, headers!: Array <(String, String) >=[]): HttpRequest
```
便捷构造：GET 请求

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLheaders 请求头部（可选）|
|headers|Array<(String,String)>||

返回: 

- 返回构造好的 GET 请求

### func init\(String,String,Array<\(String,String\)>,Option<String>\)
```cj
public init(url: String, method!: String = "GET", headers!: Array <(String, String) >=[], body!: Option < String >= None)
```
构造请求

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLmethod HTTP 方法（默认 GET）headers 请求头部（可选）body 请求正文（可选）|
|method|String||
|headers|Array<(String,String)>||
|body|Option<String>||

### func post\(String,String,Array<\(String,String\)>\)
```cj
public static func post(url: String, json!: String = "", headers!: Array <(String, String) >=[]): HttpRequest
```
便捷构造：POST 请求（JSON 正文）

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLjson JSON 正文（默认空；为空时不再附加正文）headers 请求头部（可选，未指定时自动添加 JSON Content-Type）|
|json|String||
|headers|Array<(String,String)>||

返回: 

- 返回构造好的 POST 请求

### func put\(String,Option<String>,Array<\(String,String\)>\)
```cj
public static func put(url: String, body!: Option < String >= None, headers!: Array <(String, String) >=[]): HttpRequest
```
便捷构造：PUT 请求

参数: 

|名称|类型|描述|
|---|---|---|
|url|String|请求 URLbody 请求正文（可选）headers 请求头部（可选）|
|body|Option<String>||
|headers|Array<(String,String)>||

返回: 

- 返回构造好的 PUT 请求

### let body
```cj
public let body: Option < String >
```
请求正文（可选，GET 通常为空）

### let headers
```cj
public let headers: Array <(String, String) >
```
请求头部（name, value 键值对）

### let method
```cj
public let method: String
```
HTTP 方法（GET/POST/PUT/DELETE/HEAD/PATCH）

### let url
```cj
public let url: String
```
请求 URL

