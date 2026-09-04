# Class
## class Attributes
```cj
public open class Attributes <: DataMap
```
Manages the mapping between vertex attributes and backend buffers

### func destroy\(BufferAttribute\)
```cj
public func destroy(attribute: BufferAttribute): Unit
```
Destroys the buffer for the given attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|BufferAttribute|Vertex attribute|

### func get\(BufferAttribute\)
```cj
public func get(attribute: BufferAttribute): Int64
```
Gets the backend buffer handle for the given attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|BufferAttribute|Vertex attribute|

Return: 

- Buffer handle

### func init\(Backend\)
```cj
public init(backend: Backend)
```
Constructs an attributes manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|Backend|Rendering backend instance|

### func updateInstanced\(InstancedBufferAttribute\)
```cj
public func updateInstanced(attribute: InstancedBufferAttribute): Unit
```
Updates the buffer data for the given instanced attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|InstancedBufferAttribute|Instanced vertex attribute|

### func update\(BufferAttribute\)
```cj
public func update(attribute: BufferAttribute): Unit
```
Updates the buffer data for the given attribute

Parameter: 

|Name|Type|Describe|
|---|---|---|
|attribute|BufferAttribute|Vertex attribute|

### var backend
```cj
public var backend: Backend
```
Reference to the backend

