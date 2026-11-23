# Class
## class InterleavedBuffer
```cj
public open class InterleavedBuffer
```
Interleaved buffer class, packs multiple attribute data into a single array

### func addUpdateRange\(Int64,Int64\)
```cj
public func addUpdateRange(start: Int64, count: Int64): Unit
```
Add data range that needs to be updated to GPU

Parameter: 

|Name|Type|Describe|
|---|---|---|
|start|Int64|Start positioncount Number of components to update|
|count|Int64||

### func clearUpdateRanges\(\)
```cj
public func clearUpdateRanges(): Unit
```
Clear all update ranges

### func clone\(\)
```cj
public open func clone(): InterleavedBuffer
```
Clone this interleaved buffer

Return: 

- New interleaved buffer instance

### func copyAt\(Int64,InterleavedBuffer,Int64\)
```cj
public func copyAt(index1: Int64, interleavedBuffer: InterleavedBuffer, index2: Int64): InterleavedBuffer
```
Copy a vector from another interleaved buffer to this buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index1|Int64|Target index in this bufferinterleavedBuffer Source interleaved bufferindex2 Source index in source buffer|
|interleavedBuffer|InterleavedBuffer||
|index2|Int64||

Return: 

- Current instance

### func copy\(InterleavedBuffer\)
```cj
public func copy(source: InterleavedBuffer): InterleavedBuffer
```
Copy data from another interleaved buffer to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|InterleavedBuffer|Source interleaved buffer|

Return: 

- Current instance

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(Array<Float64>,Int64\)
```cj
public init(array: Array < Float64 >, stride: Int64)
```
Construct interleaved buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|array|Array<Float64>|Array storing attribute datastride Number of elements per vertex|
|stride|Int64||

### func markNeedsUpdate\(\)
```cj
public func markNeedsUpdate(): Unit
```
Mark data as needing update to GPU

### func onUpload\(\(\)\->Unit\)
```cj
public func onUpload(callback:() -> Unit): InterleavedBuffer
```
Set upload callback function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|callback|()->Unit|Callback function|

Return: 

- Current instance

### func setUsage\(Int64\)
```cj
public func setUsage(value: Int64): InterleavedBuffer
```
Set the usage pattern of this interleaved buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64|Usage pattern (e.g. StaticDrawUsage, DynamicDrawUsage)|

Return: 

- Current instance

### func set\(Array<Float64>,Int64\)
```cj
public func set(value: Array < Float64 >, offset!: Int64 = 0): InterleavedBuffer
```
Set array data in this interleaved buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Array<Float64>|Data array to setoffset Offset, default 0|
|offset|Int64||

Return: 

- Current instance

### var array
```cj
public var array: Array < Float64 >
```
Array storing attribute data

### var count
```cj
public var count: Int64
```
Total number of elements in the array

### var onUploadCallback
```cj
public var onUploadCallback:() -> Unit
```
Upload callback, executed after renderer transfers attribute array data to GPU (function type, not serializable)

### var stride
```cj
public var stride: Int64
```
Number of typed array elements per vertex (stride)

### var updateRanges
```cj
public var updateRanges: ArrayList < UpdateRange >
```
Update range list, for updating only part of stored vector components

### var usage
```cj
public var usage: Int64
```
Expected usage pattern for data storage, for optimization purposes

### let uuid
```cj
public let uuid: String
```
Unique identifier of this interleaved buffer (let immutable, not serialized)

### var version
```cj
public var version: Int64
```
Version number, incremented each time needsUpdate is set to true

