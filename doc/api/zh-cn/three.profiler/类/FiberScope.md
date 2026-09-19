# 类
## class FiberScope
```cj
public class FiberScope <: Resource
```
纤维作用域 — try/finally 或宏包裹纤维主体

### func close\(\)
```cj
public func close(): Unit
```
离开纤维（幂等；try-with-resources 自动调用）

### func init\(String\)
```cj
public init(name: String)
```
进入纤维作用域

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||

### func isClosed\(\)
```cj
public func isClosed(): Bool
```
Resource.isClosed

