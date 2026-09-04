# 类
## class DataMap
```cj
public open class DataMap
```
通用键值数据映射基类

### func delete\(String\)
```cj
public func delete(key: String): Unit
```
删除指定键

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|要删除的键|

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有数据

### func get\(String\)
```cj
public func get(key: String): HashMap < String, Any >
```
获取指定键对应的值映射

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|查找键|

返回: 

- 键对应的值映射

### func has\(String\)
```cj
public func has(key: String): Bool
```
检查是否存在指定键

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
构造空数据映射

