# Class
## class Hex
```cj
public class Hex
```
Hex encoding/decoding utility

### func decode\(String\)
```cj
public static func decode(data: String): Array < UInt8 >
```
Decodes a hex string into a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|String|The hex string (case-insensitive)|

Return: 

- The decoded byte array (an empty array is returned for invalid input)

### func encode\(Array<UInt8>\)
```cj
public static func encode(data: Array < UInt8 >): String
```
Encodes a byte array into a lowercase hex string

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The lowercase hex string (2 characters per byte)

