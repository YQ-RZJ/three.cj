# Class
## class LuaFunction
```cj
public class LuaFunction
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

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the registry reference

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaFunction >
```
Gets a function reference from a global variable (null when not a function)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machinename The global variable name|
|name|String||

Return: 

- The function reference, or None if the global is missing or not a function

### func init\(LuaVM,Int32\)
```cj
public init(vm!: LuaVM, ref!: Int32)
```
Wraps an existing registry reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machineref The registry reference (produced by luaL_ref)|
|ref|Int32||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the reference is still valid (not disposed)

### prop ref: Int32
```cj
public prop ref: Int32
```
The registry reference id

