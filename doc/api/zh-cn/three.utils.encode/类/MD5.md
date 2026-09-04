# 类
## class MD5
```cj
public class MD5
```
MD5 摘要算法工具类

### func computeRaw\(Array<UInt8>\)
```cj
public static func computeRaw(data: Array < UInt8 >): Array < UInt8 >
```
对字节数组执行 MD5 处理，返回 16 字节原始摘要

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 16 字节 MD5 摘要

### func compute\(String\)
```cj
public static func compute(message: String): String
```
对字符串执行 MD5 处理（UTF-8 编码）

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|要处理的字符串|

返回: 

- 32 字符小写 16 进制 MD5 摘要

### func compute\(Array<UInt8>\)
```cj
public static func compute(data: Array < UInt8 >): String
```
对字节数组执行 MD5 处理

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 32 字符小写 16 进制 MD5 摘要

