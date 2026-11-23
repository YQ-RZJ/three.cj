# Class
## class LuaCallback
```cj
public class LuaCallback <: IReleasable
```
Lua function callback

### func call\(Array<LuaValue>\)
```cj
public func call(args!: Array < LuaValue >=[]): Array < LuaValue >
```
Calls the Lua function (protected lua_pcall)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|args|Array<LuaValue>|The argument array (LuaValue; empty array means no arguments)|

Return: 

- The result array (may be empty; tables/functions become reference variants via _readValue)

Exception: 

- LuaError On a runtime error, or when the VM is closed / the callback is released;
LuaReentryLimitError when nesting reaches LuaCallback.reentryLimit

### func fromValue\(LuaVM,LuaValue\)
```cj
public static func fromValue(vm: LuaVM, v: LuaValue): Option < LuaCallback >
```
Builds a callback from a LuaValue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine|
|v|LuaValue|The target value (must be LuaValue.Function(ref) with ref>0; the VM must be valid)|

Return: 

- The callback, or None when the value is not a function reference or the VM is closed

### func release\(\)
```cj
public func release(): Bool
```
Releases the registry reference (IReleasable parameterless implementation; idempotent)

Return: 

- true if this call actually unref'd; false if already released (idempotent hit)

### func release\(LuaVM\)
```cj
public func release(vm: LuaVM): Unit
```
Releases the registry reference (luaL_unref)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine (used to verify the VM is still valid; whenclosed the release is skipped and the callback is invalidated)|

### prop reentryLimit: Int64
```cj
public static mut prop reentryLimit: Int64
```
Lua callback reentry depth limit (default -1 = adaptive from stack size).

### prop ref: Int64
```cj
public prop ref: Int64
```
The registry reference id

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the callback is still usable (not released and holds a reference)

