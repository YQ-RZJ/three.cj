# 类
## class Composite
```cj
public class Composite
```
Composite 复合属性绑定，用于 AnimationObjectGroup

### func bind\(\)
```cj
public func bind(): Unit
```
绑定所有活跃绑定

### func getValue\(Array<Float64>,Int64\)
```cj
public func getValue(array: Array < Float64 >, offset: Int64): Unit
```
获取值 — 绑定所有绑定后，从第一个有效绑定获取值

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|目标数组offset 写入偏移|
|offset|Int64||

### func init\(AnimationObjectGroup,String,HashMap<String,Any>\)
```cj
public init(targetGroup: AnimationObjectGroup, path: String, optionalParsedPath: HashMap < String, Any >)
```
创建复合绑定，为目标对象组中的每个对象创建绑定

参数: 

|名称|类型|描述|
|---|---|---|
|targetGroup|AnimationObjectGroup|目标对象组path 属性路径optionalParsedPath 已解析的路径信息|
|path|String||
|optionalParsedPath|HashMap<String,Any>||

### func setValue\(Array<Float64>,Int64\)
```cj
public func setValue(array: Array < Float64 >, offset: Int64): Unit
```
设置值 — 对所有活跃绑定设置值

参数: 

|名称|类型|描述|
|---|---|---|
|array|Array<Float64>|源数组offset 读取偏移|
|offset|Int64||

### func unbind\(\)
```cj
public func unbind(): Unit
```
解绑所有活跃绑定

