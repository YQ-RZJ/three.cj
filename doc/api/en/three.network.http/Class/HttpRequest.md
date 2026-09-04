# Class
## class HttpRequest
```cj
public class HttpRequest
```
HTTP request description

### func delete\(String,Array<\(String,String\)>\)
```cj
public static func delete(url: String, headers!: Array <(String, String) >=[]): HttpRequest
```
Convenience factory for a DELETE request

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLheaders Request headers (optional)|
|headers|Array<(String,String)>||

Return: 

- Returns the constructed DELETE request

### func get\(String,Array<\(String,String\)>\)
```cj
public static func get(url: String, headers!: Array <(String, String) >=[]): HttpRequest
```
Convenience factory for a GET request

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLheaders Request headers (optional)|
|headers|Array<(String,String)>||

Return: 

- Returns the constructed GET request

### func init\(String,String,Array<\(String,String\)>,Option<String>\)
```cj
public init(url: String, method!: String = "GET", headers!: Array <(String, String) >=[], body!: Option < String >= None)
```
Constructs a request

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLmethod HTTP method (defaults to GET)headers Request headers (optional)body Request body (optional)|
|method|String||
|headers|Array<(String,String)>||
|body|Option<String>||

### func post\(String,String,Array<\(String,String\)>\)
```cj
public static func post(url: String, json!: String = "", headers!: Array <(String, String) >=[]): HttpRequest
```
Convenience factory for a POST request with a JSON body

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLjson JSON body (empty by default; empty means no body attached)headers Request headers (optional; a JSON Content-Type is added when omitted)|
|json|String||
|headers|Array<(String,String)>||

Return: 

- Returns the constructed POST request

### func put\(String,Option<String>,Array<\(String,String\)>\)
```cj
public static func put(url: String, body!: Option < String >= None, headers!: Array <(String, String) >=[]): HttpRequest
```
Convenience factory for a PUT request

Parameter: 

|Name|Type|Describe|
|---|---|---|
|url|String|Request URLbody Request body (optional)headers Request headers (optional)|
|body|Option<String>||
|headers|Array<(String,String)>||

Return: 

- Returns the constructed PUT request

### let body
```cj
public let body: Option < String >
```
Optional request body (usually empty for GET)

### let headers
```cj
public let headers: Array <(String, String) >
```
Request headers as (name, value) pairs

### let method
```cj
public let method: String
```
HTTP method (GET/POST/PUT/DELETE/HEAD/PATCH)

### let url
```cj
public let url: String
```
Request URL

