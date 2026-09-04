# 类
## class BgfxTimestampQueryPool
```cj
public class BgfxTimestampQueryPool
```
bgfx 时间戳查询池

### func allocate\(\)
```cj
public func allocate(): TimestampQuery
```
分配一个查询

返回: 

- 时间戳查询对象

### func beginQuery\(TimestampQuery\)
```cj
public func beginQuery(query: TimestampQuery): Unit
```
记录开始时间

参数: 

|名称|类型|描述|
|---|---|---|
|query|TimestampQuery|时间戳查询对象|

### func endQuery\(TimestampQuery\)
```cj
public func endQuery(query: TimestampQuery): Unit
```
记录结束时间

参数: 

|名称|类型|描述|
|---|---|---|
|query|TimestampQuery|时间戳查询对象|

### func getResult\(TimestampQuery\)
```cj
public func getResult(query: TimestampQuery): Float64
```
获取查询结果（毫秒）

参数: 

|名称|类型|描述|
|---|---|---|
|query|TimestampQuery|时间戳查询对象|

返回: 

- 查询结果（毫秒）

### func init\(Int64\)
```cj
public init(poolSize!: Int64 = 256)
```


参数: 

|名称|类型|描述|
|---|---|---|
|poolSize|Int64||

