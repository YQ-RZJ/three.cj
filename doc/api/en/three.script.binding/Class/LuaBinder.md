# Class
## class LuaBinder
```cj
public class LuaBinder
```
Cangjie-Lua binder (a collection of static methods)

### func registerFunction\(LuaVM,String,\(Array<LuaValue>\)\->Array<LuaValue>\)
```cj
public static func registerFunction(vm: LuaVM, name: String, fn:(Array < LuaValue >) -> Array < LuaValue >): Int64
```
Registers a Cangjie function as a Lua global function

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Example usage:
LuaBinder.registerFunction(vm, "add") { args ->
[LuaValue.of(args[0].numberValue() + args[1].numberValue())]
}</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machinename The Lua-side global function namefn   The Cangjie callback: (LuaValue argument array) -> result array|
|name|String||
|fn|(Array<LuaValue>)->Array<LuaValue>||

Return: 

- The registered id (for unregister; -1 on failure)

### func registerFunctions\(LuaVM,HashMap<String,\(Array<LuaValue>\)\->Array<LuaValue>>\)
```cj
public static func registerFunctions(vm: LuaVM, funcs: HashMap < String,(Array < LuaValue >) -> Array < LuaValue >>): Unit
```
Registers a batch of Cangjie functions as Lua global functions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machinefuncs Function name → Cangjie callback|
|funcs|HashMap<String,(Array<LuaValue>)->Array<LuaValue>>||

### func registerTableMethod\(LuaVM,LuaTable,String,\(Array<LuaValue>\)\->Array<LuaValue>\)
```cj
public static func registerTableMethod(vm: LuaVM, table: LuaTable, name: String, fn:(Array < LuaValue >) -> Array < LuaValue >): Int64
```
Registers a Cangjie function as a field (method) of a Lua table

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machinetable The target table (LuaTable reference)name  The field namefn    The Cangjie callback|
|table|LuaTable||
|name|String||
|fn|(Array<LuaValue>)->Array<LuaValue>||

Return: 

- The registered id

### func unregister\(Int64\)
```cj
public static func unregister(id: Int64): Unit
```
Removes a callback by its registered id

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The callback id returned at registration|

### prop handlerCount: Int64
```cj
public static prop handlerCount: Int64
```
The number of currently registered callbacks

