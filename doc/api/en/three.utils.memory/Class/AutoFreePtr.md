# Class
## class AutoFreePtr < T > where T <: CType
```cj
public class AutoFreePtr < T > where T <: CType
```
Auto-free pointer wrapper

### func dispose\(\)
```cj
public func dispose(): Unit
```
Automatically calls LibC.free to release the pointer

### func get\(\)
```cj
public func get(): CPointer < T >
```
Returns the raw pointer

Return: 

- CPointer<T>

### func init\(\)
```cj
public init()
```
Constructs an empty AutoFreePtr

### func init\(CPointer<T>\)
```cj
public init(p: CPointer < T >)
```
Constructs an AutoFreePtr wrapping a pointer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|p|CPointer<T>|The pointer to manage|

### func isValid\(\)
```cj
public func isValid(): Bool
```
Checks whether a valid pointer is held

Return: 

- true if not null

### func release\(\)
```cj
public func release(): CPointer < T >
```
Releases ownership and returns the raw pointer (no longer managed)

Return: 

- The raw CPointer<T>

