# Class
## class MD5
```cj
public class MD5
```
MD5 digest algorithm utility class

### func computeRaw\(Array<UInt8>\)
```cj
public static func computeRaw(data: Array < UInt8 >): Array < UInt8 >
```
Computes the MD5 digest of a byte array and returns the raw 16-byte digest

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The 16-byte MD5 digest

### func compute\(String\)
```cj
public static func compute(message: String): String
```
Computes the MD5 digest of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The string to process|

Return: 

- The MD5 digest as a 32-character lowercase hex string

### func compute\(Array<UInt8>\)
```cj
public static func compute(data: Array < UInt8 >): String
```
Computes the MD5 digest of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The MD5 digest as a 32-character lowercase hex string

