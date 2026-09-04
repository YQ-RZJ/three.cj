# Class
## class UniformBuffer
```cj
public open class UniformBuffer
```
Uniform buffer class

### func init\(String,Int64\)
```cj
public init(name: String, byteLength: Int64)
```
Constructor with specified name and byte length

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Buffer namebyteLength Buffer byte length|
|byteLength|Int64||

### func setData\(Array<Float32>\)
```cj
public func setData(data: Array < Float32 >): Unit
```
Set buffer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float32>|New data array|

### func update\(\)
```cj
public func update(): Unit
```
Update buffer data to GPU

### var byteLength
```cj
public var byteLength: Int64
```
Buffer byte length

### var data
```cj
public var data: Array < Float32 >
```
Buffer data array

### var name
```cj
public var name: String
```
Buffer name

