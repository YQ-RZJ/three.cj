# Class
## class DataMap
```cj
public open class DataMap
```
Generic key-value data mapping base class

### func delete\(String\)
```cj
public func delete(key: String): Unit
```
Deletes the specified key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Key to delete|

### func dispose\(\)
```cj
public func dispose(): Unit
```
Disposes all data

### func get\(String\)
```cj
public func get(key: String): HashMap < String, Any >
```
Gets the value map for the specified key

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Lookup key|

Return: 

- Value map for the key

### func has\(String\)
```cj
public func has(key: String): Bool
```
Checks whether the specified key exists

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Lookup key|

Return: 

- Whether the key exists

### func init\(\)
```cj
public init()
```
Constructs an empty data map

