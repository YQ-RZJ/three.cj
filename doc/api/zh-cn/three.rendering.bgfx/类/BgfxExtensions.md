# 类
## class BgfxExtensions
```cj
public class BgfxExtensions
```
bgfx 扩展兼容层

### func \`init\`\(\)
```cj
public func `init`(): Unit
```
初始化扩展

### func get\(String\)
```cj
public func get(name: String): Option < String >
```
获取扩展对象

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|扩展名称|

返回: 

- 扩展标记（可用时返回 Some）

### func has\(String\)
```cj
public func has(name: String): Bool
```
检查扩展是否可用

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|扩展名称|

返回: 

- 是否可用

### func init\(\)
```cj
public init()
```


