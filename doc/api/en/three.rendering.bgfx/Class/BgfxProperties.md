# Class
## class BgfxProperties
```cj
public class BgfxProperties
```
bgfx properties storage

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes all data

### func get\(Object3D\)
```cj
public func get(obj: Object3D): HashMap < String, Any >
```
Gets object's associated data map

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Object|

Return: 

- Property map

### func has\(Object3D\)
```cj
public func has(obj: Object3D): Bool
```
Checks if object has associated data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Object|

Return: 

- Whether has associated data

### func init\(\)
```cj
public init()
```


### func remove\(Object3D\)
```cj
public func remove(obj: Object3D): Unit
```
Removes object's associated data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Object|

### func update\(Object3D,String,Any\)
```cj
public func update(obj: Object3D, key: String, value: Any): Unit
```
Updates a property of an object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Object3D|Objectkey Property keyvalue Property value|
|key|String||
|value|Any||

