# 类
## class SHA
```cj
public class SHA
```
SHA 系列安全摘要算法工具类

### func sha1Raw\(Array<UInt8>\)
```cj
public static func sha1Raw(data: Array < UInt8 >): Array < UInt8 >
```
计算 SHA-1 摘要（原始 20 字节），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 20 字节 SHA-1 原始摘要

### func sha1\(Array<UInt8>\)
```cj
public static func sha1(data: Array < UInt8 >): String
```
计算 SHA-1 摘要（小写 hex），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 40 字符小写 16 进制 SHA-1 摘要

### func sha1\(String\)
```cj
public static func sha1(message: String): String
```
计算 SHA-1 摘要（小写 hex），输入字符串（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|输入字符串|

返回: 

- 40 字符小写 16 进制 SHA-1 摘要

### func sha224\(Array<UInt8>\)
```cj
public static func sha224(data: Array < UInt8 >): String
```
计算 SHA-224 摘要（小写 hex），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 56 字符小写 16 进制 SHA-224 摘要

### func sha224\(String\)
```cj
public static func sha224(message: String): String
```
计算 SHA-224 摘要（小写 hex），输入字符串（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|输入字符串|

返回: 

- 56 字符小写 16 进制 SHA-224 摘要

### func sha256Raw\(Array<UInt8>\)
```cj
public static func sha256Raw(data: Array < UInt8 >): Array < UInt8 >
```
计算 SHA-256 摘要（原始 32 字节），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 32 字节 SHA-256 原始摘要

### func sha256\(Array<UInt8>\)
```cj
public static func sha256(data: Array < UInt8 >): String
```
计算 SHA-256 摘要（小写 hex），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 64 字符小写 16 进制 SHA-256 摘要

### func sha256\(String\)
```cj
public static func sha256(message: String): String
```
计算 SHA-256 摘要（小写 hex），输入字符串（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|输入字符串|

返回: 

- 64 字符小写 16 进制 SHA-256 摘要

### func sha384\(Array<UInt8>\)
```cj
public static func sha384(data: Array < UInt8 >): String
```
计算 SHA-384 摘要（小写 hex），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 96 字符小写 16 进制 SHA-384 摘要

### func sha384\(String\)
```cj
public static func sha384(message: String): String
```
计算 SHA-384 摘要（小写 hex），输入字符串（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|输入字符串|

返回: 

- 96 字符小写 16 进制 SHA-384 摘要

### func sha512Raw\(Array<UInt8>\)
```cj
public static func sha512Raw(data: Array < UInt8 >): Array < UInt8 >
```
计算 SHA-512 摘要（原始 64 字节），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 64 字节 SHA-512 原始摘要

### func sha512\(Array<UInt8>\)
```cj
public static func sha512(data: Array < UInt8 >): String
```
计算 SHA-512 摘要（小写 hex），输入字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 128 字符小写 16 进制 SHA-512 摘要

### func sha512\(String\)
```cj
public static func sha512(message: String): String
```
计算 SHA-512 摘要（小写 hex），输入字符串（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|输入字符串|

返回: 

- 128 字符小写 16 进制 SHA-512 摘要

