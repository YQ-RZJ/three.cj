# 类
## class LuaVM
```cj
public class LuaVM
```
Lua 脚本虚拟机

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>线程安全说明：Lua 状态机不是线程安全的，同一 LuaVM 实例应仅在
单线程内使用；如跨线程需要各自创建独立 LuaVM。</p>

### func callFunction\(Int32,Int32\)
```cj
public func callFunction(nargs: Int32, nresults!: Int32 = LUA_MULTRET): Array < LuaValue >
```
调用栈顶函数（参数需已压栈）

参数: 

|名称|类型|描述|
|---|---|---|
|nargs|Int32|参数个数nresults 期望返回值个数（LUA_MULTRET=-1 表示取全部）|
|nresults|Int32||

返回: 

- 返回值数组

异常: 

- LuaError 运行时错误

### func checkStack\(Int32\)
```cj
public func checkStack(n: Int32): Bool
```
检查栈是否有足够空间（不足则尝试扩展，返回是否成功）

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int32|需要的额外元素个数|

返回: 

- 空间充足或扩展成功时为 true

### func createTable\(Int32,Int32\)
```cj
public func createTable(narr!: Int32 = 0, nrec!: Int32 = 0): Unit
```
创建新表并压栈（lua_createtable）

参数: 

|名称|类型|描述|
|---|---|---|
|narr|Int32|预分配的数组部分容量（默认 0）nrec 预分配的哈希部分容量（默认 0）|
|nrec|Int32||

### func dispose\(\)
```cj
public func dispose(): Unit
```
关闭状态机并释放资源（之后 handle() 失效）

### func doBuffer\(String,String\)
```cj
public func doBuffer(code: String, name!: String = "=(buffer)"): Array < LuaValue >
```
从字节缓冲区加载并执行 Lua 代码（二进制 chunk 或源码）

参数: 

|名称|类型|描述|
|---|---|---|
|code|String|源码或预编译字节码字符串name chunk 名（用于错误消息，默认 "=(buffer)"）|
|name|String||

返回: 

- 返回值数组

异常: 

- LuaError 语法错误或运行时错误

### func doFile\(String\)
```cj
public func doFile(path: String): Array < LuaValue >
```
从文件加载并执行 Lua 脚本

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|Lua 脚本文件路径|

返回: 

- 返回值数组

异常: 

- LuaError 文件不存在 / 语法错误 / 运行时错误

### func doString\(String\)
```cj
public func doString(chunk: String): Array < LuaValue >
```
从字符串加载并执行 Lua 代码（动态解析）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>用法示例：</p>

参数: 

|名称|类型|描述|
|---|---|---|
|chunk|String|Lua 源码字符串|

返回: 

- 返回值数组（可能为空）

异常: 

- LuaError 语法错误或运行时错误

### func gcCollect\(\)
```cj
public func gcCollect(): Unit
```
执行完整 GC 周期

### func gcCountBytes\(\)
```cj
public func gcCountBytes(): Int64
```
获取当前内存使用量余数（字节）

返回: 

- 内存使用量余数字节数

### func gcCountKB\(\)
```cj
public func gcCountKB(): Int64
```
获取当前内存使用量（KB，小数部分见 gcCountBytes）

返回: 

- 内存使用量（KB 整数部分）

### func gcRestart\(\)
```cj
public func gcRestart(): Unit
```
重启 GC

### func gcStep\(Int32\)
```cj
public func gcStep(steps: Int32): Int64
```
执行 n 步增量 GC

参数: 

|名称|类型|描述|
|---|---|---|
|steps|Int32|增量步数|

返回: 

- GC 是否已完成一个周期（1 表示完成）

### func gcStop\(\)
```cj
public func gcStop(): Unit
```
停止 GC

### func getField\(Int32,String\)
```cj
public func getField(idx: Int32, name: String): Unit
```
获取表字段（表在 idx，字段值压栈）——低层 API，供 LuaTable 使用

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|表的栈索引name 字段名|
|name|String||

### func getGlobal\(String\)
```cj
public func getGlobal(name: String): LuaValue
```
读取全局变量并返回 LuaValue

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|全局变量名|

返回: 

- 变量值（不存在时为 LuaValue.Nil）

### func getTop\(\)
```cj
public func getTop(): Int32
```
获取栈顶索引（即栈上元素个数）

返回: 

- 栈顶索引

### func handle\(\)
```cj
public func handle(): CPointer < Unit >
```
底层 lua_State 句柄（供 LuaBinder/LuaTable 等高级封装使用）

### func hasGlobal\(String\)
```cj
public func hasGlobal(name: String): Bool
```
判断全局变量是否存在

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|全局变量名|

返回: 

- 变量存在且非 nil 时为 true

### func init\(Bool\)
```cj
public init(openLibs!: Bool = true)
```
创建 Lua 状态机

参数: 

|名称|类型|描述|
|---|---|---|
|openLibs|Bool|是否打开标准库（base/string/table/math/io/os 等）|

异常: 

- LuaError 创建失败时抛出

### func jitOff\(\)
```cj
public func jitOff(): Int32
```
禁用 JIT 编译引擎（回退解释执行）

返回: 

- 0 表示成功

### func jitOn\(\)
```cj
public func jitOn(): Int32
```
启用 JIT 编译引擎

返回: 

- 0 表示成功

### func loadFile\(String\)
```cj
public func loadFile(path: String): LuaFunction
```
从文件编译 Lua 代码但不执行，返回可重复调用的 LuaFunction

参数: 

|名称|类型|描述|
|---|---|---|
|path|String|Lua 脚本文件路径|

返回: 

- 编译后的函数

异常: 

- LuaError 文件不存在 / 语法错误

### func loadString\(String\)
```cj
public func loadString(chunk: String): LuaFunction
```
从字符串编译 Lua 代码但不执行，返回可重复调用的 LuaFunction

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>用法示例：</p>

参数: 

|名称|类型|描述|
|---|---|---|
|chunk|String|Lua 源码|

返回: 

- 编译后的函数

异常: 

- LuaError 语法错误

### func openLibs\(\)
```cj
public func openLibs(): Unit
```
打开全部标准库（base/package/string/table/math/io/os/debug/jit/ffi 等）

### func pop\(Int32\)
```cj
public func pop(n!: Int32 = 1): Unit
```
从栈顶弹出 n 个元素

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int32|要弹出的元素个数（默认 1）|

### func pushValue\(CPointer<Unit>,LuaValue\)
```cj
public static func pushValue(L: CPointer < Unit >, v: LuaValue): Unit
```
压入 LuaValue 到栈

参数: 

|名称|类型|描述|
|---|---|---|
|L|CPointer<Unit>|底层 lua_State 句柄v 要压入的 LuaValue|
|v|LuaValue||

### func readValue\(CPointer<Unit>,Int32\)
```cj
public static func readValue(L: CPointer < Unit >, idx: Int32): LuaValue
```
从栈索引读取 LuaValue

参数: 

|名称|类型|描述|
|---|---|---|
|L|CPointer<Unit>|底层 lua_State 句柄idx 栈索引|
|idx|Int32||

返回: 

- 对应的 LuaValue（表/函数等返回 nil 占位）

### func setField\(Int32,String\)
```cj
public func setField(idx: Int32, name: String): Unit
```
设置表字段（值已在栈顶，表在 idx）——低层 API，供 LuaTable 使用

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|表的栈索引name 字段名|
|name|String||

### func setGlobal\(String,LuaValue\)
```cj
public func setGlobal(name: String, value: LuaValue): Unit
```
写入全局变量

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|全局变量名value 要写入的变量值|
|value|LuaValue||

### func setTop\(Int32\)
```cj
public func setTop(idx: Int32): Unit
```
设置栈大小（负数 = 从栈顶移除 |n| 个元素）

参数: 

|名称|类型|描述|
|---|---|---|
|idx|Int32|目标栈顶索引（负数表示相对栈顶）|

### prop isValid: Bool
```cj
public prop isValid: Bool
```
状态机是否有效（未被 dispose）

### prop jitVersion: String
```cj
public static prop jitVersion: String
```
LuaJIT 版本字符串（如 "LuaJIT 2.1.x"）

### prop libsOpened: Bool
```cj
public prop libsOpened: Bool
```
是否已打开标准库

### prop version: String
```cj
public static prop version: String
```
Lua 版本字符串（如 "Lua 5.1"）

