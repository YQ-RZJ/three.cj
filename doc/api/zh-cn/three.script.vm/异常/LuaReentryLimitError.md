# 类
## class LuaReentryLimitError
```cj
public class LuaReentryLimitError <: Exception
```
Lua 回调重入深度超限异常

### func init\(String\)
```cj
public init(message: String)
```
构造重入超限异常

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|错误消息|

