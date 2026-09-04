# Class
## class Pipelines
```cj
public open class Pipelines <: DataMap
```
Pipeline collection manager

### func add\(Pipeline\)
```cj
public func add(pipeline: Pipeline): Unit
```
Adds a pipeline to the collection

Parameter: 

|Name|Type|Describe|
|---|---|---|
|pipeline|Pipeline|Pipeline instance|

### func clear\(\)
```cj
public func clear(): Unit
```
Clears all pipelines

### func get\(Int64\)
```cj
public func get(id: Int64): Pipeline
```
Gets a pipeline by ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Pipeline identifier|

Return: 

- Pipeline instance

### func init\(\)
```cj
public init()
```
Constructs a default pipelines collection

### func remove\(Int64\)
```cj
public func remove(id: Int64): Unit
```
Removes a pipeline by ID

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Pipeline identifier|

### var pipelines
```cj
public var pipelines: HashMap < Int64, Pipeline >
```
Pipeline map

