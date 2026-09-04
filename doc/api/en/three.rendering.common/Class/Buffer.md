# Class
## class Buffer
```cj
public open class Buffer <: Binding
```
GPU buffer management class

### func createIndexBuffer\(Array<UInt32>,Int64\)
```cj
public func createIndexBuffer(data: Array < UInt32 >, size: Int64): Int64
```
Creates an index buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<UInt32>|Index data arraysize Data size|
|size|Int64||

Return: 

- Buffer handle

### func createVertexBuffer\(Array<Float32>,Int64\)
```cj
public func createVertexBuffer(data: Array < Float32 >, size: Int64): Int64
```
Creates a vertex buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|Array<Float32>|Vertex data arraysize Data size|
|size|Int64||

Return: 

- Buffer handle

### func destroyBuffer\(Int64\)
```cj
public func destroyBuffer(handle: Int64): Unit
```
Destroys a buffer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|Int64|Buffer handle|

### func init\(Backend\)
```cj
public init(backend: Backend)
```
Constructs a buffer associated with the specified backend

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|Backend|Rendering backend instance|

### func updateBuffer\(Int64,Array<Float32>\)
```cj
public func updateBuffer(handle: Int64, data: Array < Float32 >): Unit
```
Updates buffer data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|Int64|Buffer handledata Update data|
|data|Array<Float32>||

### var backend
```cj
public var backend: Backend
```
Reference to the backend

