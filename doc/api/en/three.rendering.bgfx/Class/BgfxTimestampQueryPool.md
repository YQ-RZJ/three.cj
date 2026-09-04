# Class
## class BgfxTimestampQueryPool
```cj
public class BgfxTimestampQueryPool
```
bgfx timestamp query pool

### func allocate\(\)
```cj
public func allocate(): TimestampQuery
```
Allocate a query

Return: 

- Timestamp query object

### func beginQuery\(TimestampQuery\)
```cj
public func beginQuery(query: TimestampQuery): Unit
```
Record start time

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|TimestampQuery|Timestamp query object|

### func endQuery\(TimestampQuery\)
```cj
public func endQuery(query: TimestampQuery): Unit
```
Record end time

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|TimestampQuery|Timestamp query object|

### func getResult\(TimestampQuery\)
```cj
public func getResult(query: TimestampQuery): Float64
```
Get query result (milliseconds)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|query|TimestampQuery|Timestamp query object|

Return: 

- Query result (milliseconds)

### func init\(Int64\)
```cj
public init(poolSize!: Int64 = 256)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|poolSize|Int64||

