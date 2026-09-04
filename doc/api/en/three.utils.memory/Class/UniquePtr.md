# Class
## class UniquePtr < T > where T <: CType
```cj
public class UniquePtr < T > where T <: CType
```
Exclusive-ownership smart pointer

### func dispose\(\)
```cj
public func dispose(): Unit
```
Frees the managed pointer (manual call; ~init is the fallback)

### func get\(\)
```cj
public func get(): CPointer < T >
```
Returns the raw pointer (ownership is not transferred)

Return: 

- The raw CPointer<T>

### func init\(\)
```cj
public init()
```
Constructs an empty UniquePtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
Constructs a UniquePtr wrapping a pointer (released via default LibC.free)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer to manage|

### func init\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public init(p: CPointer < T >, deleter:(CPointer < T >) -> Unit)
```
Constructs a UniquePtr wrapping a pointer (with a custom deleter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer to managedeleter Custom deleter function|
|deleter|(CPointer<T>)->Unit||

### func isValid\(\)
```cj
public func isValid(): Bool
```
Checks whether a valid pointer is held

Return: 

- true if a valid pointer is held

### func move\(\)
```cj
public func move(): UniquePtr < T >
```
Transfers ownership to a new UniquePtr

Return: 

- A new UniquePtr holding the original ownership

### func release\(\)
```cj
public func release(): CPointer < T >
```
Releases ownership and returns the raw pointer (lifecycle no longer managed)

Return: 

- The raw CPointer<T>

### func reset\(CPointer<T>\)
```cj
public func reset(p: CPointer < T >): Unit
```
Resets to manage a new pointer (the old pointer is freed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The new pointer|

### func reset\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public func reset(p: CPointer < T >, deleter:(CPointer < T >) -> Unit): Unit
```
Resets to manage a new pointer with a custom deleter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The new pointerdeleter The new deleter|
|deleter|(CPointer<T>)->Unit||

