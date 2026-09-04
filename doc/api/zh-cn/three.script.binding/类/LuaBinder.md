# 类
## class LuaBinder
```cj
public class LuaBinder
```
仓颉 ↔ Lua 绑定器（静态方法集合）

### func registerFunction\(LuaVM,String,\(Array<LuaValue>\)\->Array<LuaValue>\)
```cj
public static func registerFunction(vm: LuaVM, name: String, fn:(Array < LuaValue >) -> Array < LuaValue >): Int64
```
注册仓颉函数为 Lua 全局函数

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>用法示例：</p>

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机name Lua 侧全局函数名fn   仓颉回调：(LuaValue 参数数组) -> 返回值数组|
|name|String||
|fn|(Array<LuaValue>)->Array<LuaValue>||

返回: 

- 注册的 id（供 unregister 使用；-1 表示失败）

### func registerFunctions\(LuaVM,HashMap<String,\(Array<LuaValue>\)\->Array<LuaValue>>\)
```cj
public static func registerFunctions(vm: LuaVM, funcs: HashMap < String,(Array < LuaValue >) -> Array < LuaValue >>): Unit
```
注册一组仓颉函数为 Lua 全局函数（批量）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机funcs 函数名 → 仓颉回调|
|funcs|HashMap<String,(Array<LuaValue>)->Array<LuaValue>>||

### func registerTableMethod\(LuaVM,LuaTable,String,\(Array<LuaValue>\)\->Array<LuaValue>\)
```cj
public static func registerTableMethod(vm: LuaVM, table: LuaTable, name: String, fn:(Array < LuaValue >) -> Array < LuaValue >): Int64
```
把仓颉函数注册为 Lua 表的字段（方法）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机table 目标表（LuaTable 引用）name  字段名fn    仓颉回调|
|table|LuaTable||
|name|String||
|fn|(Array<LuaValue>)->Array<LuaValue>||

返回: 

- 注册的 id

### func unregister\(Int64\)
```cj
public static func unregister(id: Int64): Unit
```
按注册 id 移除回调

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|注册时返回的回调 id|

### prop handlerCount: Int64
```cj
public static prop handlerCount: Int64
```
当前注册的回调数量

