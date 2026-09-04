# Class
## class Base64
```cj
public class Base64
```
Base64 encoding/decoding utility

### func decode\(String\)
```cj
public static func decode(data: String): Array < UInt8 >
```
Decodes a Base64 string to a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|String|Base64 string (tolerates `\r`/`\n` line breaks)|

Return: 

- The decoded byte array, or an empty array on invalid characters or malformed padding

### func encode\(Array<UInt8>\)
```cj
public static func encode(data: Array < UInt8 >): String
```
Encodes a byte array into a Base64 string

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The Base64-encoded string (a `\r\n` line break is added every 76 characters)

