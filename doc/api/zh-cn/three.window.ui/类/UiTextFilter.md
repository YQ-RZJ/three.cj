# 类
## class UiTextFilter
```cj
public class UiTextFilter
```
文本过滤器，支持按过滤条件筛选文本列表

### func clear\(\)
```cj
public func clear(): Unit
```
清除过滤条件

### func destroy\(\)
```cj
public func destroy(): Unit
```
销毁过滤器并释放底层资源

### func draw\(String\)
```cj
public func draw(label!: String = "Filter"): Bool
```
绘制过滤器输入框

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|输入框标签文本（默认 "Filter"）|

返回: 

- 过滤条件本次是否发生变化

### func init\(String\)
```cj
public init(defaultFilter!: String = "")
```
构造文本过滤器

参数: 

|名称|类型|描述|
|---|---|---|
|defaultFilter|String|默认过滤条件文本（默认空字符串）|

### func isActive\(\)
```cj
public func isActive(): Bool
```
是否激活（有过滤条件）

返回: 

- 当前是否存在有效过滤条件

### func passFilter\(String\)
```cj
public func passFilter(text: String): Bool
```
测试文本是否通过过滤

参数: 

|名称|类型|描述|
|---|---|---|
|text|String|待测试的文本|

返回: 

- 文本是否通过过滤条件

