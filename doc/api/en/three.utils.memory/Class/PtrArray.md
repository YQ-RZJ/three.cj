# Class
## class PtrArray < T > where T <: CType
```cj
public class PtrArray < T > where T <: CType
```
Pointer-backed array

### func data\(\)
```cj
public func data(): CPointer < T >
```
Returns the underlying contiguous memory pointer (for bgfx FFI; caller does not take ownership)

Return: 

- CPointer<T>

### func dispose\(\)
```cj
public func dispose(): Unit
```
Manually frees the underlying memory (GC will also free it; use this for timely release)

### func get\(Int64\)
```cj
public func get(index: Int64): T
```
Reads the element at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Index|

Return: 

- The element value

### func init\(Int64\)
```cj
public init(size: Int64)
```
Constructs an empty array of the given length (memory zeroed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|size|Int64|Number of elements|

### func init\(Array<T>\)
```cj
public init(values: Array < T >)
```
Constructs from a Cangjie Array (one-shot data upload to contiguous memory)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|values|Array<T>|Source data|

### func set\(Int64,T\)
```cj
public func set(index: Int64, value: T): Unit
```
Writes the element at the given index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|Indexvalue The element value|
|value|T||

### func size\(\)
```cj
public func size(): Int64
```
Number of elements

Return: 

- Number of elements

### func toArray\(\)
```cj
public func toArray(): Array < T >
```
Reads the C-memory data back into a Cangjie Array

Return: 

- The copied Array<T>

