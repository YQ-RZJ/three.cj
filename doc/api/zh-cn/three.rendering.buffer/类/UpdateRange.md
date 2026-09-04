# 类
## class UpdateRange
```cj
public class UpdateRange
```
更新范围，用于标记需要更新到 GPU 的数据范围

### func init\(Int64,Int64\)
```cj
public init(start: Int64, count: Int64)
```
无参构造（供 fastjson 反序列化使用）

参数: 

|名称|类型|描述|
|---|---|---|
|start|Int64||
|count|Int64||

### func init\(\)
```cj
public init()
```
无参构造（供 fastjson 反序列化使用）

### var count
```cj
public var count: Int64
```
元素数量

### var start
```cj
public var start: Int64
```
起始位置

