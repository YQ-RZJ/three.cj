# Class
## class InstancedInterleavedBuffer
```cj
public class InstancedInterleavedBuffer <: InterleavedBuffer
```
Instanced interleaved buffer class, extends InterleavedBuffer

### func clone\(\)
```cj
public func clone(): InstancedInterleavedBuffer
```
Clone this instanced interleaved buffer

Return: 

- New instanced interleaved buffer instance

### func copy\(InstancedInterleavedBuffer\)
```cj
public func copy(source: InstancedInterleavedBuffer): InstancedInterleavedBuffer
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|InstancedInterleavedBuffer|Source interleaved buffer|

Return: 

- This instance

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(Array<Float64>,Int64,Int64\)
```cj
public init(array: Array < Float64 >, stride: Int64, meshPerAttribute!: Int64 = 1)
```
Construct instanced interleaved buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array storing attribute datastride Number of elements per vertexmeshPerAttribute Number of times each attribute value is repeated, default 1|
|stride|Int64||
|meshPerAttribute|Int64||

### var meshPerAttribute
```cj
public var meshPerAttribute: Int64
```
Defines the number of times each attribute value is repeated across instances, default 1

