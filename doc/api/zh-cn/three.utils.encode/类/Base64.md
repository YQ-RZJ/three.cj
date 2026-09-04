# 类
## class Base64
```cj
public class Base64
```
Base64 编解码工具

### func decode\(String\)
```cj
public static func decode(data: String): Array < UInt8 >
```
解码 Base64 字符串为字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|String|Base64 字符串（兼容 `\r` `\n` 折行）|

返回: 

- 解码后的字节数组；含非法字符或 padding 不规范时返回空数组

### func encode\(Array<UInt8>\)
```cj
public static func encode(data: Array < UInt8 >): String
```
编码字节数组为 Base64 字符串

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- Base64 编码字符串（每 76 字符加 `\r\n` 折行）

