# Class
## class SharedPtr < T > where T <: CType
```cj
public class SharedPtr < T > where T <: CType
```
Reference-counted shared smart pointer

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the current reference (manual call; ~init is the fallback)

### func get\(\)
```cj
public func get(): CPointer < T >
```
Returns the raw pointer (without incrementing the reference count)

Return: 

- The raw CPointer<T>

### func init\(\)
```cj
public init()
```
Constructs an empty SharedPtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
Constructs a SharedPtr wrapping a pointer (released via default LibC.free)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer to manage|

### func init\(CPointer<T>,\(CPointer<T>\)\->Unit\)
```cj
public init(p: CPointer < T >, deleter:(CPointer < T >) -> Unit)
```
Constructs a SharedPtr wrapping a pointer (with a custom deleter)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer to managedeleter Custom deleter function|
|deleter|(CPointer<T>)->Unit||

### func init\(SharedPtr<T>\)
```cj
public init(other: SharedPtr < T >)
```
Copy constructor: shares ownership, increments the reference count (thread-safe)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|SharedPtr<T>|The source SharedPtr|

### func isValid\(\)
```cj
public func isValid(): Bool
```
Checks whether a valid pointer is held

Return: 

- true if a valid pointer is held

### func reset\(CPointer<T>\)
```cj
public func reset(p: CPointer < T >): Unit
```
Resets to manage a new pointer (decrements the old reference count)

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

### func useCount\(\)
```cj
public func useCount(): Int64
```
Returns the current reference count (thread-safe)

Return: 

- The reference count

