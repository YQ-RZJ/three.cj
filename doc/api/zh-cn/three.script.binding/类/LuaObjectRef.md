# 类
## class LuaObjectRef
```cj
public class LuaObjectRef
```
引擎对象引用（方法/属性回调的 self）

### func cast\(\)
```cj
public func cast < T >(): T
```
取回真实对象并强转为 T

异常: 

- Exception 类型不匹配或对象缺失时抛出

### func obj\(\)
```cj
public func obj(): Any
```
取回真实对象（Any）

返回: 

- 注册表保存的仓颉对象

异常: 

- Exception 对象已移除时抛出

### prop id: Int64
```cj
public prop id: Int64
```
对象注册表 id

