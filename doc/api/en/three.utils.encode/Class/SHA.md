# Class
## class SHA
```cj
public class SHA
```
SHA family secure digest algorithm utility class

### func sha1Raw\(Array<UInt8>\)
```cj
public static func sha1Raw(data: Array < UInt8 >): Array < UInt8 >
```
Computes the SHA-1 digest (raw 20 bytes) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The raw 20-byte SHA-1 digest

### func sha1\(Array<UInt8>\)
```cj
public static func sha1(data: Array < UInt8 >): String
```
Computes the SHA-1 digest (lowercase hex) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The SHA-1 digest as a 40-character lowercase hex string

### func sha1\(String\)
```cj
public static func sha1(message: String): String
```
Computes the SHA-1 digest (lowercase hex) of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The input string|

Return: 

- The SHA-1 digest as a 40-character lowercase hex string

### func sha224\(Array<UInt8>\)
```cj
public static func sha224(data: Array < UInt8 >): String
```
Computes the SHA-224 digest (lowercase hex) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The SHA-224 digest as a 56-character lowercase hex string

### func sha224\(String\)
```cj
public static func sha224(message: String): String
```
Computes the SHA-224 digest (lowercase hex) of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The input string|

Return: 

- The SHA-224 digest as a 56-character lowercase hex string

### func sha256Raw\(Array<UInt8>\)
```cj
public static func sha256Raw(data: Array < UInt8 >): Array < UInt8 >
```
Computes the SHA-256 digest (raw 32 bytes) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The raw 32-byte SHA-256 digest

### func sha256\(Array<UInt8>\)
```cj
public static func sha256(data: Array < UInt8 >): String
```
Computes the SHA-256 digest (lowercase hex) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The SHA-256 digest as a 64-character lowercase hex string

### func sha256\(String\)
```cj
public static func sha256(message: String): String
```
Computes the SHA-256 digest (lowercase hex) of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The input string|

Return: 

- The SHA-256 digest as a 64-character lowercase hex string

### func sha384\(Array<UInt8>\)
```cj
public static func sha384(data: Array < UInt8 >): String
```
Computes the SHA-384 digest (lowercase hex) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The SHA-384 digest as a 96-character lowercase hex string

### func sha384\(String\)
```cj
public static func sha384(message: String): String
```
Computes the SHA-384 digest (lowercase hex) of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The input string|

Return: 

- The SHA-384 digest as a 96-character lowercase hex string

### func sha512Raw\(Array<UInt8>\)
```cj
public static func sha512Raw(data: Array < UInt8 >): Array < UInt8 >
```
Computes the SHA-512 digest (raw 64 bytes) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The raw 64-byte SHA-512 digest

### func sha512\(Array<UInt8>\)
```cj
public static func sha512(data: Array < UInt8 >): String
```
Computes the SHA-512 digest (lowercase hex) of a byte array

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt8>|The input byte array|

Return: 

- The SHA-512 digest as a 128-character lowercase hex string

### func sha512\(String\)
```cj
public static func sha512(message: String): String
```
Computes the SHA-512 digest (lowercase hex) of a string (UTF-8 encoded)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|The input string|

Return: 

- The SHA-512 digest as a 128-character lowercase hex string

