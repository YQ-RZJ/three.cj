# Class
## class PoolManager
```cj
public class PoolManager
```
Multi-type object pool management

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The maximum cache capacity of each per-type pool is set uniformly at
construction time.</p>

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all caches

### func get\(Int64\)
```cj
public func get(id: Int64): Object
```
Tries to get an object instance from the pool for the given ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type ID|

Return: 

- A newly created or reused object

Exception: 

- IllegalStateException When the ID is not registered

### func init\(\)
```cj
public init()
```
Constructs a manager with the default capacity of 128

### func init\(Int64\)
```cj
public init(capacity: Int64)
```
Constructs a manager

Parameter: 

|Name|Type|Describe|
|---|---|---|
|capacity|Int64|Maximum cache capacity of each per-type pool|

### func isRegister\(Int64\)
```cj
public func isRegister(id: Int64): Bool
```
Checks whether the given type is registered

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type ID|

Return: 

- true if registered, false otherwise

### func recycle\(Int64,Object\)
```cj
public func recycle(id: Int64, obj: Object): Unit
```
Recycles an object back to the pool for the given ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type IDobj The object to recycle|
|obj|Object||

Exception: 

- IllegalStateException When the ID is not registered

### func register\(Int64,\(\)\->Object\)
```cj
public func register(id: Int64, factory:() -> Object): Unit
```
Registers a pool for the given ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type IDfactory Object factory|
|factory|()->Object||

Exception: 

- IllegalStateException When the ID is already registered

### func register\(Int64,\(\)\->Object,?\(Object\)\->Unit,?\(Object\)\->Unit\)
```cj
public func register(id: Int64, factory:() -> Object, onRecycle:?(Object) -> Unit, onReuse:?(Object) -> Unit): Unit
```
Registers a pool with callbacks

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type IDfactory Object factoryonRecycle Recycle callbackonReuse Reuse callback|
|factory|()->Object||
|onRecycle|?(Object)->Unit||
|onReuse|?(Object)->Unit||

Exception: 

- IllegalStateException When the ID is already registered

### func unregister\(Int64\)
```cj
public func unregister(id: Int64): Unit
```
Unregisters the given type

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Object-type ID|

