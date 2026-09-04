# 类
## class UrlEncode
```cj
public class UrlEncode
```
URL 查询串/表单编码工具

### func decodeQuery\(String\)
```cj
public static func decodeQuery(query: String): Array <(String, String) >
```
解码 URL 查询串为键值对数组

参数: 

|名称|类型|描述|
|---|---|---|
|query|String|编码后的查询串（如 "a=1&b=hello+world"；可含前导 '?'）|

返回: 

- 键值对数组（多值键展平为多条）

### func encodeQuery\(Array<\(String,String\)>\)
```cj
public static func encodeQuery(pairs: Array <(String, String) >): String
```
编码键值对数组为 URL 查询串

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>键值各自经 percentEncode 编码（空格→'+'），用 '=' 与 '&' 拼接。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|pairs|Array<(String,String)>|键值对数组|

返回: 

- 编码后的查询串（如 "a=1&b=hello+world"）

### func percentDecode\(String\)
```cj
public static func percentDecode(s: String): String
```
单值百分号解码

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|已编码字符串（如 "hello+world"）|

返回: 

- 解码后的字符串

### func percentEncode\(String\)
```cj
public static func percentEncode(s: String): String
```
单值百分号编码（表单语义）

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|待编码字符串|

返回: 

- 编码后的字符串

