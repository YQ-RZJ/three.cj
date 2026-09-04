# Class
## class ChainMap
```cj
public open class ChainMap
```
Chained key-value map, looking up keys across multiple DataMaps by priority

### func addMap\(DataMap\)
```cj
public func addMap(map: DataMap): Unit
```
Adds a DataMap to the end of the chain

Parameter: 

|Name|Type|Describe|
|---|---|---|
|map|DataMap|DataMap to add|

### func delete\(String\)
```cj
public func delete(key: String): Unit
```
Deletes the specified key from all DataMaps in the chain

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Key to delete|

### func get\(String\)
```cj
public func get(key: String): Option < HashMap < String, Any >>
```
Looks up a key in chain order

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|Lookup key|

Return: 

- Found value map, or None if not found

### func has\(String\)
```cj
public func has(key: String): Bool
```
Checks whether the specified key exists in the chain

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
Constructs an empty chain map

