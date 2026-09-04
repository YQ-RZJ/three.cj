# Class
## class NetworkHttp
```cj
public class NetworkHttp
```
Static HTTP client utilities

### func execute\(HttpRequest\)
```cj
public static func execute(req: HttpRequest): HttpResponse
```
Executes an HTTP request synchronously (10s default timeout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|req|HttpRequest|The request description|

Return: 

- Returns the HTTP response

### func get\(String,Array<\(String,String\)>\)
```cj
public static func get(url: String, headers!: Array <(String, String) >=[]): HttpResponse
```
Convenience GET (synchronous)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLheaders Request headers (optional)|
|headers|Array<(String,String)>||

Return: 

- Returns the HTTP response

### func post\(String,String,Array<\(String,String\)>\)
```cj
public static func post(url: String, json!: String = "", headers!: Array <(String, String) >=[]): HttpResponse
```
Convenience POST with JSON body (synchronous)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLjson JSON body (empty by default)headers Request headers (optional)|
|json|String||
|headers|Array<(String,String)>||

Return: 

- Returns the HTTP response

