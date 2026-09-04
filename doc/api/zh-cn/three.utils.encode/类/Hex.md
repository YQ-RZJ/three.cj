# 类
## class Hex
```cj
public class Hex
```
Hex 十六进制编解码工具

### func decode\(String\)
```cj
public static func decode(data: String): Array < UInt8 >
```
解码 hex 字符串为字节数组

参数: 

|名称|类型|描述|
|---|---|---|
|data|String|hex 字符串（大小写均可）|

返回: 

- 解码后的字节数组（非法输入返回空数组）

### func encode\(Array<UInt8>\)
```cj
public static func encode(data: Array < UInt8 >): String
```
编码字节数组为小写 hex 字符串

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<UInt8>|输入字节数组|

返回: 

- 小写 hex 字符串（每字节 2 字符）

