# 类
## class ScopeGuard
```cj
public class ScopeGuard
```
RAII 作用域守卫

### func dismiss\(\)
```cj
public func dismiss(): Unit
```
取消执行清理回调

### func dispose\(\)
```cj
public func dispose(): Unit
```
执行清理回调（如果未被取消）

### func init\(\(\)\->Unit\)
```cj
public init(callback:() -> Unit)
```
构造 ScopeGuard

参数: 

|名称|类型|描述|
|---|---|---|
|callback|()->Unit|离开作用域时要执行的清理函数|

