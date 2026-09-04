# Class
## class ObjectPool < T > where T <: Object
```cj
public class ObjectPool < T > where T <: Object
```
Generic object pool

### func allocate\(\)
```cj
public func allocate(): T
```
Gets an object (creates a new one via the factory when the pool is empty)

Return: 

- A newly created or reused object

### func clear\(\)
```cj
public func clear(): Unit
```
Clears the cache

### func init\(Int64,\(\)\->T,?\(T\)\->Unit,?\(T\)\->Unit\)
```cj
public init(capacity: Int64, factory:() -> T, onRecycle:?(T) -> Unit, onReuse:?(T) -> Unit)
```
Constructs an object pool (with recycle/reuse callbacks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Maximum cache capacity (<= 0 means unlimited)factory Object factory returning a new instanceonRecycle Callback on recycle (optional, for resetting state)onReuse Callback on reuse (optional, for initializing state)|
|factory|()->T||
|onRecycle|?(T)->Unit||
|onReuse|?(T)->Unit||

### func init\(Int64,\(\)\->T\)
```cj
public init(capacity: Int64, factory:() -> T)
```
Constructs an object pool (without callbacks)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Maximum cache capacity (<= 0 means unlimited)factory Object factory returning a new instance|
|factory|()->T||

### func recycle\(T\)
```cj
public func recycle(obj: T): Bool
```
Recycles an object back into the pool

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|T|The object to recycle|

Return: 

- Whether the recycle succeeded (false when the pool is full)

### func size\(\)
```cj
public func size(): Int64
```
Number of objects currently cached in the pool

Return: 

- The number of cached objects

