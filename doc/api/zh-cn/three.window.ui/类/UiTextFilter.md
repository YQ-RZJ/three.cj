# 类
## class UiTextFilter
```cj
public class UiTextFilter
```
=============================================================================

### func clear\(\)
```cj
public func clear(): Unit
```
清除过滤条件

### func destroy\(\)
```cj
public func destroy(): Unit
```


### func draw\(String\)
```cj
public func draw(label!: String = "Filter"): Bool
```
绘制过滤器输入框

参数: 

|名称|类型|描述|
|---|---|---|
|label|String||

### func init\(String\)
```cj
public init(defaultFilter!: String = "")
```


参数: 

|名称|类型|描述|
|---|---|---|
|defaultFilter|String||

### func isActive\(\)
```cj
public func isActive(): Bool
```
是否激活（有过滤条件）

### func passFilter\(String\)
```cj
public func passFilter(text: String): Bool
```
测试文本是否通过过滤

参数: 

|名称|类型|描述|
|---|---|---|
|text|String||

