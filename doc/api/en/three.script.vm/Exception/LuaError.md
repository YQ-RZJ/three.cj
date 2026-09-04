# Class
## class LuaError
```cj
public class LuaError <: Exception
```
Lua script execution exception

### func init\(String,Int32\)
```cj
public init(message: String, code!: Int32 = 2)
```
Constructs a script exception

Parameter: 

|Name|Type|Describe|
|---|---|---|
|message|String|Error message (longer when it includes a stack traceback)code    Lua error code (defaults to LUA_ERRRUN)|
|code|Int32||

### prop codeName: String
```cj
public prop codeName: String
```
Error code name (useful for logging)

### let code
```cj
public let code: Int32
```
Lua error code (LUA_ERRRUN etc.)

