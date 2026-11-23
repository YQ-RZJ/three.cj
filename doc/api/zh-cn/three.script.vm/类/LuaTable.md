# 类
## class LuaTable
```cj
public class LuaTable <: IReleasable
```
Lua 表引用

### func create\(LuaVM,Int32,Int32\)
```cj
public static func create(vm: LuaVM, narr!: Int32 = 0, nrec!: Int32 = 0): LuaTable
```
在 VM 中创建一个新表并返回引用

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|
|narr|Int32|预分配数组部分容量|
|nrec|Int32|预分配哈希部分容量|

返回: 

- 新建表的引用

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaTable >
```
从全局变量获取表引用（非表则返回 null）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|
|name|String|全局变量名|

返回: 

- 表引用；若全局变量不存在或不是表则返回 None

### func fromStack\(LuaVM,VoidPtr,Int32\)
```cj
public static func fromStack(vm: LuaVM, L: VoidPtr, idx: Int32): Option < LuaTable >
```
从栈索引建立表引用（lua_pushvalue + luaL_ref；非表返回 None）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机（引用释放时使用 handle）|
|L|VoidPtr|底层 lua_State 句柄|
|idx|Int32|栈索引（值不为表时返回 None，栈不变）|

返回: 

- 表引用；栈顶值不是表时返回 None

### func getIndex\(Int32\)
```cj
public func getIndex(i: Int32): LuaValue
```
读取数组索引（t[i]，1 起始）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int32|数组索引（从 1 开始）|

返回: 

- 索引处的值（不存在时返回 nil）

### func getValues\(\)
```cj
public func getValues(): Array < LuaValue >
```
以数值数组形式读取表中全部数组段元素（t[1]..t[n]，n = len()）

返回: 

- 数组段元素；表无数组部分时返回空数组

### func get\(String\)
```cj
public func get(key: String): LuaValue
```
读取字段（t[k]），返回 LuaValue

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|字段名|

返回: 

- 字段值（不存在时返回 nil）

### func init\(LuaVM,Int32\)
```cj
public init(vm!: LuaVM, ref!: Int32)
```
包装一个已存在的注册表引用

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机|
|ref|Int32|注册表引用（由 luaL_ref 产生）|

### func len\(\)
```cj
public func len(): Int64
```
表长度（数组部分，#t）

返回: 

- 表数组部分的长度

### func release\(\)
```cj
public func release(): Bool
```
释放注册表引用

### func setIndex\(Int32,LuaValue\)
```cj
public func setIndex(i: Int32, value: LuaValue): Unit
```
写入数组索引（t[i] = v，1 起始）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int32|数组索引（从 1 开始）|
|value|LuaValue|要写入的值|

### func set\(String,LuaValue\)
```cj
public func set(key: String, value: LuaValue): Unit
```
写入字段（t[k] = v）

参数: 

|名称|类型|描述|
|---|---|---|
|key|String|字段名|
|value|LuaValue|要写入的值|

### prop isArray: Bool
```cj
public prop isArray: Bool
```
表是否为数组（连续整数键）

### prop ref: Int32
```cj
public prop ref: Int32
```
注册表引用 id

### prop releasable: Bool
```cj
public prop releasable: Bool
```
是否有效（未被释放）

