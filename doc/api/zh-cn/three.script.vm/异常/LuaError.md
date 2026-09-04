# 类
## class LuaError
```cj
public class LuaError <: Exception
```
Lua 脚本执行异常

### func init\(String,Int32\)
```cj
public init(message: String, code!: Int32 = 2)
```
构造脚本异常

参数: 

|名称|类型|描述|
|---|---|---|
|message|String|错误消息（含栈回溯时更长）code    Lua 错误码（默认 LUA_ERRRUN）|
|code|Int32||

### prop codeName: String
```cj
public prop codeName: String
```
错误码名称（便于日志输出）

### let code
```cj
public let code: Int32
```
Lua 错误码（LUA_ERRRUN 等）

