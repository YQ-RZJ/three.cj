# 类
## class ChainMap
```cj
public open class ChainMap
```
链式键值映射，按优先级在多个 DataMap 中查找键

### func addMap\(DataMap\)
```cj
public func addMap(map: DataMap): Unit
```
添加 DataMap 到链尾

参数: 

|名称|类型|描述|
|---|---|---|
|map|DataMap|要添加的 DataMap|

### func delete\(String\)
```cj
public func delete(key: String): Unit
```
从链中所有 DataMap 删除指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|要删除的键|

### func get\(String\)
```cj
public func get(key: String): Option < HashMap < String, Any >>
```
按链顺序查找键对应的值

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|查找键|

返回: 

- 找到的值映射，未找到返回 None

### func has\(String\)
```cj
public func has(key: String): Bool
```
检查链中是否存在指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|查找键|

返回: 

- 是否存在

### func init\(\)
```cj
public init()
```
构造空链式映射

