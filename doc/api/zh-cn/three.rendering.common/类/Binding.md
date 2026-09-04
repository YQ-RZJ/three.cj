# 类
## class Binding
```cj
public open class Binding
```
单个绑定资源描述，表示 uniform buffer、sampler 等资源绑定

### func init\(String,Any,String\)
```cj
public init(name: String, value: Any, kind: String)
```
构造绑定，指定名称、值和类型

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|绑定名称value 绑定值kind 绑定类型|
|value|Any||
|kind|String||

### func init\(String,Any\)
```cj
public init(name: String, value: Any)
```
构造绑定，指定名称和值，默认类型为 "uniform"

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|绑定名称value 绑定值|
|value|Any||

### var kind
```cj
public var kind: String
```
绑定类型（如 "uniform"、"buffer" 等）

### var name
```cj
public var name: String
```
绑定名称

### var value
```cj
public var value: Any
```
绑定值

### var visibility
```cj
public var visibility: Int64
```
着色器可见性标志

