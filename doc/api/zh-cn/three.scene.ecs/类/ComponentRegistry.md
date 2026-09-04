# 类
## class ComponentRegistry
```cj
public class ComponentRegistry
```
组件类注册表

### func factoryOf\(Int64\)
```cj
public static func factoryOf(id: Int64):?(() -> Component)
```
按类 ID 查询组件工厂

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|组件类 ID|

返回: 

- 未登记返回 None

### func idOf\(String\)
```cj
public static func idOf(uniqueKey: String):?Int64
```
按唯一键查询组件类 ID

参数: 

|名称|类型|描述|
|---|---|---|
|uniqueKey|String|定义点唯一键|

返回: 

- 未登记返回 None

### func registerAlloc\(String,\(\)\->Component\)
```cj
public static func registerAlloc(uniqueKey: String, factory:() -> Component): Int64
```
登记组件类并分配类 ID（幂等）

参数: 

|名称|类型|描述|
|---|---|---|
|uniqueKey|String|定义点唯一键（宏生成）factory 组件无参工厂|
|factory|()->Component||

返回: 

- 分配到的组件类 ID

### prop count: Int64
```cj
public static prop count: Int64
```
已分配的组件类 ID 总数

