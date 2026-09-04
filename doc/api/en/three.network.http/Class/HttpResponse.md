# Class
## class HttpResponse
```cj
public class HttpResponse
```
HTTP response

### func bodyString\(\)
```cj
public func bodyString(): String
```
Returns the body as text

Return: 

- Returns the body text, or an empty string when the body is empty

### func header\(String\)
```cj
public func header(name: String): Option < String >
```
Looks up a response header by name

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Header name|

Return: 

- Returns the matching header value, or None when absent

### func init\(Int64,String,Array<\(String,String\)>,Option<String>\)
```cj
public init(code: Int64, message: String, headers!: Array <(String, String) >=[], body!: Option < String >= None)
```
Constructs a response

Parameter: 

|Name|Type|Describe|
|---|---|---|
|code|Int64|Status codemessage Status messageheaders Response headers (optional)body Response body (optional)|
|message|String||
|headers|Array<(String,String)>||
|body|Option<String>||

### prop contentType: String
```cj
public prop contentType: String
```
Response content type (value of the Content-Type header)

### prop isRedirect: Bool
```cj
public prop isRedirect: Bool
```
Whether the response is a redirect (3xx)

### prop isSuccess: Bool
```cj
public prop isSuccess: Bool
```
Whether the response is successful (2xx)

### let body
```cj
public let body: Option < String >
```
Body as text (empty when the body is binary)

### let code
```cj
public let code: Int64
```
Status code (e.g. 200/404/500)

### let headers
```cj
public let headers: Array <(String, String) >
```
Response headers as (name, value) pairs

### let message
```cj
public let message: String
```
Status message (e.g. "OK")

