# Class
## class InstancedBufferAttribute
```cj
public class InstancedBufferAttribute <: BufferAttribute
```
Instanced buffer attribute, extends BufferAttribute

### func copy\(InstancedBufferAttribute\)
```cj
public func copy(source: InstancedBufferAttribute): InstancedBufferAttribute
```
Copy data from another instanced buffer attribute to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|InstancedBufferAttribute|Source instanced buffer attribute|

Return: 

- Reference to this instance

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(Array<Float64>,Int64,Bool,Int64\)
```cj
public init(array: Array < Float64 >, itemSize: Int64, normalized!: Bool = false, meshPerAttribute!: Int64 = 1)
```
Construct a new instanced buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array storing attribute dataitemSize Number of data items per vertexnormalized Whether to normalize, default falsemeshPerAttribute Number of times each attribute value is repeated, default 1|
|itemSize|Int64||
|normalized|Bool||
|meshPerAttribute|Int64||

### var meshPerAttribute
```cj
public var meshPerAttribute: Int64
```
Defines the number of times this attribute value is repeated across instances

