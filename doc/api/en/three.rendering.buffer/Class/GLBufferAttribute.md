# Class
## class GLBufferAttribute
```cj
public class GLBufferAttribute
```
GL buffer attribute class

### func getNeedsUpdate\(\)
```cj
public func getNeedsUpdate(): Bool
```
Check whether the attribute needs update

Return: 

- Returns true if version > 0

### func init\(VertexBufferHandle,Int64,Int64,Int64,Int64,Bool\)
```cj
public init(buffer: VertexBufferHandle, kind!: Int64 = 0, itemSize!: Int64 = 0, elementSize!: Int64 = 0, count!: Int64 = 0, normalized!: Bool = false)
```
Construct a new GL buffer attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|VertexBufferHandle|Native buffer handle (Box-wrapped)kind Data type identifier (corresponding to type in JS)itemSize Data item size per vertexelementSize Byte size corresponding to kindcount Expected number of verticesnormalized Whether to normalize, default false|
|kind|Int64||
|itemSize|Int64||
|elementSize|Int64||
|count|Int64||
|normalized|Bool||

### func setBuffer\(VertexBufferHandle\)
```cj
public func setBuffer(buffer: VertexBufferHandle): GLBufferAttribute
```
Set native buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|buffer|VertexBufferHandle|New buffer handle (Box-wrapped)|

Return: 

- Current instance (supports chaining)

### func setCount\(Int64\)
```cj
public func setCount(count: Int64): GLBufferAttribute
```
Set vertex count

Parameter: 

|Name|Type|Describe|
|---|---|---|
|count|Int64|Expected number of vertices|

Return: 

- Current instance (supports chaining)

### func setItemSize\(Int64\)
```cj
public func setItemSize(itemSize: Int64): GLBufferAttribute
```
Set data item size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|itemSize|Int64|Data item size per vertex|

Return: 

- Current instance (supports chaining)

### func setNeedsUpdate\(Bool\)
```cj
public func setNeedsUpdate(value: Bool): Unit
```
Mark whether the attribute needs update

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Bool|Whether needs update|

### func setType\(Int64,Int64\)
```cj
public func setType(kind: Int64, elementSize: Int64): GLBufferAttribute
```
Set data type and element size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|kind|Int64|Data type identifier (corresponding to type in JS)elementSize Byte size corresponding to kind|
|elementSize|Int64||

Return: 

- Current instance (supports chaining)

### var buffer
```cj
public var buffer: VertexBufferHandle
```
Native buffer handle (Box-wrapped bgfx vertex buffer handle)

### var count
```cj
public var count: Int64
```
Expected number of vertices in VBO

### var elementSize
```cj
public var elementSize: Int64
```
Byte size corresponding to the kind parameter

### var itemSize
```cj
public var itemSize: Int64
```
Data item size per vertex

### var kind
```cj
public var kind: Int64
```
Data type identifier, corresponding to bgfx vertex format attribute type

### var name
```cj
public var name: String
```
Buffer attribute name

### var normalized
```cj
public var normalized: Bool
```
Whether to normalize integer data

### var version
```cj
public var version: Int64
```
Version number, incremented each time needsUpdate is set to true

