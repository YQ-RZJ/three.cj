# Class
## class UrlEncode
```cj
public class UrlEncode
```
URL query-string / form encoding utility

### func decodeQuery\(String\)
```cj
public static func decodeQuery(query: String): Array <(String, String) >
```
Decodes a URL query string into an array of key-value pairs

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|String|The encoded query string (e.g. "a=1&b=hello+world"; may start with '?')|

Return: 

- The array of key-value pairs (multi-value keys are flattened into separate entries)

### func encodeQuery\(Array<\(String,String\)>\)
```cj
public static func encodeQuery(pairs: Array <(String, String) >): String
```
Encodes an array of key-value pairs into a URL query string

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Each key and value is passed through percentEncode (space→'+') and joined with '=' and '&'.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pairs|Array<(String,String)>|The array of key-value pairs|

Return: 

- The encoded query string (e.g. "a=1&b=hello+world")

### func percentDecode\(String\)
```cj
public static func percentDecode(s: String): String
```
Single-value percent-decoding

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|The encoded string (e.g. "hello+world")|

Return: 

- The decoded string

### func percentEncode\(String\)
```cj
public static func percentEncode(s: String): String
```
Single-value percent-encoding (form semantics)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|The string to encode|

Return: 

- The encoded string

