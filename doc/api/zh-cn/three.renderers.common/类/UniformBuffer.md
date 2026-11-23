# 类
## class UniformBuffer
```cj
public open class UniformBuffer
```
Uniform 缓冲类

### func init\(String,Int64\)
```cj
public init(name: String, byteLength: Int64)
```
构造器，指定名称和字节长度

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|缓冲名称byteLength 缓冲字节长度|
|byteLength|Int64||

### func setData\(Array<Float32>\)
```cj
public func setData(data: Array < Float32 >): Unit
```
设置缓冲数据

参数: 

|名称|类型|描述|
|---|---|---|
|data|Array<Float32>|新的数据数组|

### func update\(\)
```cj
public func update(): Unit
```
更新缓冲数据到 GPU

### var byteLength
```cj
public var byteLength: Int64
```
缓冲字节长度

### var data
```cj
public var data: Array < Float32 >
```
缓冲数据数组

### var name
```cj
public var name: String
```
缓冲名称

