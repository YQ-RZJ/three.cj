# Class
## class LuaFunction
```cj
public class LuaFunction <: IReleasable
```
Lua function reference

### func call\(Array<LuaValue>\)
```cj
public func call(args!: Array < LuaValue >=[]): Array < LuaValue >
```
Calls the function

Parameter: 

|Name|Type|Describe|
|---|---|---|
|args|Array<LuaValue>|Argument array (LuaValue; empty array means no arguments)|

Return: 

- The result array (may be empty)

Exception: 

- LuaError On a runtime error

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaFunction >
```
Gets a function reference from a global variable (null when not a function)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|
|name|String|The global variable name|

Return: 

- The function reference, or None if the global is missing or not a function

### func fromStack\(LuaVM,VoidPtr,Int32\)
```cj
public static func fromStack(vm: LuaVM, L: VoidPtr, idx: Int32): Option < LuaFunction >
```
Creates a function reference from a stack index (lua_pushvalue + luaL_ref;
None when the value is not a function)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine (used for release)|
|L|VoidPtr|The underlying lua_State handle|
|idx|Int32|The stack index (returns None and leaves the stack untouched when not a function)|

Return: 

- The function reference, or None when the top value is not a function

### func init\(LuaVM,Int32\)
```cj
public init(vm!: LuaVM, ref!: Int32)
```
Wraps an existing registry reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine|
|ref|Int32|The registry reference (produced by luaL_ref)|

### func release\(\)
```cj
public func release(): Bool
```
Releases the registry reference

### prop ref: Int32
```cj
public prop ref: Int32
```
The registry reference id

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the reference is still valid (not disposed)

