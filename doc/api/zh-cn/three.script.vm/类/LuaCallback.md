# 类
## class LuaCallback
```cj
public class LuaCallback <: IReleasable
```
Lua 函数回调

### func call\(Array<LuaValue>\)
```cj
public func call(args!: Array < LuaValue >=[]): Array < LuaValue >
```
调用 Lua 函数（保护调用，lua_pcall）

参数: 

|名称|类型|描述|
|---|---|---|
|args|Array<LuaValue>|参数数组（LuaValue；空数组 = 无参数）|

返回: 

- 返回值数组（可能为空；表/函数经 _readValue 转为引用变体）

异常: 

- LuaError 运行时错误，或 VM 已关闭/回调已释放；
LuaReentryLimitError 重入深度达到 LuaCallback.reentryLimit

### func fromValue\(LuaVM,LuaValue\)
```cj
public static func fromValue(vm: LuaVM, v: LuaValue): Option < LuaCallback >
```
从 LuaValue 构造回调

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机|
|v|LuaValue|目标值（须为 LuaValue.Function(ref) 且 ref>0；VM 须有效）|

返回: 

- 回调；值不是函数引用或 VM 已关闭时返回 None

### func release\(\)
```cj
public func release(): Bool
```
释放注册表引用（IReleasable 无参实现；幂等）

返回: 

- 本次调用真正执行了 unref 时返回 true；已释放（幂等命中）返回 false

### func release\(LuaVM\)
```cj
public func release(vm: LuaVM): Unit
```
释放注册表引用（luaL_unref）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机（校验 VM 仍有效后再执行；已关闭则跳过释放并置无效）|

### prop reentryLimit: Int64
```cj
public static mut prop reentryLimit: Int64
```
Lua 回调重入深度上限（默认 -1 = 按栈大小自适应）

### prop ref: Int64
```cj
public prop ref: Int64
```
注册表引用 id

### prop releasable: Bool
```cj
public prop releasable: Bool
```
是否有效（未被释放且持有引用）

