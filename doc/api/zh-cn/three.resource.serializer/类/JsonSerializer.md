# 类
## class JsonSerializer
```cj
public class JsonSerializer
```
JSON 序列化便捷工具类

### func fromJsonBytes\(Array<Byte>\)where T <: JsonStreamDeserializable < T >
```cj
public static func fromJsonBytes < T >(jsonBytes: Array < Byte >): T where T <: JsonStreamDeserializable < T >
```
JSON 字节（UTF-8）转对象

参数: 

|名称|类型|描述|
|---|---|---|
|jsonBytes|Array<Byte>|UTF-8 编码的 JSON 字节数组|

返回: 

- 反序列化出的 T 实例

### func fromJson\(String\)where T <: JsonStreamDeserializable < T >
```cj
public static func fromJson < T >(json: String): T where T <: JsonStreamDeserializable < T >
```
JSON 字符串转对象

参数: 

|名称|类型|描述|
|---|---|---|
|json|String|JSON 字符串|

返回: 

- 反序列化出的 T 实例

### func isValidJson\(String\)where T <: JsonStreamDeserializable < T >
```cj
public static func isValidJson < T >(json: String): Bool where T <: JsonStreamDeserializable < T >
```
判断 JSON 字符串是否合法（可解析为指定类型）

参数: 

|名称|类型|描述|
|---|---|---|
|json|String|JSON 字符串|

返回: 

- true 表示可解析

### func toJsonBytes\(JsonStreamSerializable\)
```cj
public static func toJsonBytes(obj: JsonStreamSerializable): Array < Byte >
```
对象转 JSON 字节（UTF-8）

参数: 

|名称|类型|描述|
|---|---|---|
|obj|JsonStreamSerializable|实现 JsonStreamSerializable 的对象|

返回: 

- UTF-8 编码的 JSON 字节数组

### func toJson\(JsonStreamSerializable\)
```cj
public static func toJson(obj: JsonStreamSerializable): String
```
对象转 JSON 字符串

参数: 

|名称|类型|描述|
|---|---|---|
|obj|JsonStreamSerializable|实现 JsonStreamSerializable 的对象（|

返回: 

- JSON 字符串

