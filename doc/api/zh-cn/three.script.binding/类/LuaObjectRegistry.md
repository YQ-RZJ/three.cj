# 类
## class LuaObjectRegistry
```cj
public class LuaObjectRegistry
```
引擎对象注册表（静态方法集合）

### func classNameOf\(Int64\)
```cj
public static func classNameOf(id: Int64): Option < String >
```
查询对象的绑定类名

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象 id|

返回: 

- 绑定类名；不存在时返回 None

### func getAs\(Int64\)
```cj
public static func getAs < T >(id: Int64): T
```
按 id 取对象并强转为 T

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象 id|

返回: 

- 强转后的对象

异常: 

- Exception 类型不匹配或对象缺失时抛出

### func get\(Int64\)
```cj
public static func get(id: Int64): Option < Any >
```
按 id 取仓颉对象

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|注册时返回的对象 id|

返回: 

- 对象；不存在或已移除时返回 None

### func installBridge\(\)
```cj
public static func installBridge(): Unit
```
安装 LuaVM 对象桥接（push/read userdata）

### func pushArrayFloat\(VoidPtr,Array<Float64>\)
```cj
public static func pushArrayFloat(L: VoidPtr, arr: Array < Float64 >): Unit
```
压 Float64 数组为 Lua table（1-based；空数组压空表）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|arr|Array<Float64>|浮点数组|

### func pushIntArray\(VoidPtr,Array<Int64>\)
```cj
public static func pushIntArray(L: VoidPtr, arr: Array < Int64 >): Unit
```
压 Int64 数组为 Lua table（1-based；空数组压空表）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|arr|Array<Int64>|整数数组|

### func pushStringArray\(VoidPtr,Array<String>\)
```cj
public static func pushStringArray(L: VoidPtr, arr: Array < String >): Unit
```
压 String 数组为 Lua table（1-based；空数组压空表）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|arr|Array<String>|字符串数组|

### func readFloatArray\(VoidPtr,Int32\)
```cj
public static func readFloatArray(L: VoidPtr, idx: Int32): Array < Float64 >
```
读取 Lua table（1-based）为 Float64 数组（非数值槽取 0.0）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|idx|Int32|栈索引（非表时返回空数组）|

返回: 

- 浮点数组

### func readIntArray\(VoidPtr,Int32\)
```cj
public static func readIntArray(L: VoidPtr, idx: Int32): Array < Int64 >
```
读取 Lua table（1-based）为 Int64 数组（非数值槽取 0）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|idx|Int32|栈索引（非表时返回空数组）|

返回: 

- 整数数组

### func readStringArray\(VoidPtr,Int32\)
```cj
public static func readStringArray(L: VoidPtr, idx: Int32): Array < String >
```
读取 Lua table（1-based）为 String 数组（非字符串槽取 ""）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|
|idx|Int32|栈索引（非表时返回空数组）|

返回: 

- 字符串数组

### func register\(Any,String\)
```cj
public static func register(obj: Any, className: String): Int64
```
分配 id 并注册仓颉对象

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Any|仓颉对象（Any）|
|className|String|绑定类名（Lua 侧 metatable 键，如 "three.core.math.Vector3"）|

返回: 

- 对象 id（>0；供 userdata 承载与后续查询）

### func unregister\(Int64\)
```cj
public static func unregister(id: Int64): Bool
```
按 id 移除注册表条目

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|对象 id|

返回: 

- 是否移除成功（条目存在）

### prop count: Int64
```cj
public static prop count: Int64
```
当前注册对象数量

