# Class
## class LuaVM
```cj
public class LuaVM
```
Lua scripting virtual machine

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Thread-safety: Lua states are not thread-safe. A LuaVM instance should only
be used within a single thread; create separate LuaVM instances across threads.</p>

### func callFunction\(Int32,Int32\)
```cj
public func callFunction(nargs: Int32, nresults!: Int32 = LUA_MULTRET): Array < LuaValue >
```
Calls the function on top of the stack (arguments must already be pushed)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|nargs|Int32|The number of argumentsnresults The expected number of results (LUA_MULTRET=-1 means all)|
|nresults|Int32||

Return: 

- The result array

Exception: 

- LuaError On a runtime error

### func checkStack\(Int32\)
```cj
public func checkStack(n: Int32): Bool
```
Checks whether the stack has enough space (grows it if needed) and returns success

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int32|The number of additional elements needed|

Return: 

- true if there is enough space or the growth succeeded

### func createTable\(Int32,Int32\)
```cj
public func createTable(narr!: Int32 = 0, nrec!: Int32 = 0): Unit
```
Creates a new table and pushes it onto the stack (lua_createtable)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|narr|Int32|Pre-allocated array-part capacity (default 0)nrec Pre-allocated hash-part capacity (default 0)|
|nrec|Int32||

### func dispose\(\)
```cj
public func dispose(): Unit
```
Closes the state and releases resources (handle() becomes invalid afterwards)

### func doBuffer\(String,String\)
```cj
public func doBuffer(code: String, name!: String = "=(buffer)"): Array < LuaValue >
```
Loads and executes Lua code from a byte buffer (binary chunk or source)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|code|String|The source or precompiled bytecode stringname The chunk name (used in error messages, default "=(buffer)")|
|name|String||

Return: 

- The result array

Exception: 

- LuaError On a syntax or runtime error

### func doFile\(String\)
```cj
public func doFile(path: String): Array < LuaValue >
```
Loads and executes a Lua script from a file

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|The Lua script file path|

Return: 

- The result array

Exception: 

- LuaError When the file is missing, or on a syntax/runtime error

### func doString\(String\)
```cj
public func doString(chunk: String): Array < LuaValue >
```
Loads and executes Lua code from a string (dynamic parsing)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Example usage:
let r = vm.doString("return 1 + 2, 'hi'")
r[0].numberValue() == 3.0; r[1].stringValue() == "hi"</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|chunk|String|The Lua source string|

Return: 

- The result array (may be empty)

Exception: 

- LuaError On a syntax or runtime error

### func gcCollect\(\)
```cj
public func gcCollect(): Unit
```
Performs a full GC cycle

### func gcCountBytes\(\)
```cj
public func gcCountBytes(): Int64
```
Gets the remainder of the current memory usage (bytes)

Return: 

- The byte remainder of the memory usage

### func gcCountKB\(\)
```cj
public func gcCountKB(): Int64
```
Gets the current memory usage in KB (fractional part via gcCountBytes)

Return: 

- The memory usage in KB (integer part)

### func gcRestart\(\)
```cj
public func gcRestart(): Unit
```
Restarts the garbage collector

### func gcStep\(Int32\)
```cj
public func gcStep(steps: Int32): Int64
```
Performs n steps of incremental GC

Parameter: 

|Name|Type|Describe|
|---|---|---|
|steps|Int32|The number of incremental steps|

Return: 

- Whether GC finished a cycle (1 means finished)

### func gcStop\(\)
```cj
public func gcStop(): Unit
```
Stops the garbage collector

### func getField\(Int32,String\)
```cj
public func getField(idx: Int32, name: String): Unit
```
Gets a table field (table at idx; the field value is pushed) — low-level API for LuaTable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|The stack index of the tablename The field name|
|name|String||

### func getGlobal\(String\)
```cj
public func getGlobal(name: String): LuaValue
```
Reads a global variable and returns it as a LuaValue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The global variable name|

Return: 

- The variable value (LuaValue.Nil if it does not exist)

### func getTop\(\)
```cj
public func getTop(): Int32
```
Gets the top stack index (the number of elements on the stack)

Return: 

- The top stack index

### func handle\(\)
```cj
public func handle(): CPointer < Unit >
```
The underlying lua_State handle (for LuaBinder/LuaTable and other wrappers)

### func hasGlobal\(String\)
```cj
public func hasGlobal(name: String): Bool
```
Checks whether a global variable exists

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The global variable name|

Return: 

- true if the variable exists and is not nil

### func init\(Bool\)
```cj
public init(openLibs!: Bool = true)
```
Creates a Lua state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|openLibs|Bool|Whether to open the standard libraries (base/string/table/math/io/os etc.)|

Exception: 

- LuaError Thrown when the state cannot be created

### func jitOff\(\)
```cj
public func jitOff(): Int32
```
Disables the JIT compilation engine (falls back to interpretation)

Return: 

- 0 on success

### func jitOn\(\)
```cj
public func jitOn(): Int32
```
Enables the JIT compilation engine

Return: 

- 0 on success

### func loadFile\(String\)
```cj
public func loadFile(path: String): LuaFunction
```
Compiles Lua code from a file without executing it, returning a reusable LuaFunction

Parameter: 

|Name|Type|Describe|
|---|---|---|
|path|String|The Lua script file path|

Return: 

- The compiled function

Exception: 

- LuaError When the file is missing or on a syntax error

### func loadString\(String\)
```cj
public func loadString(chunk: String): LuaFunction
```
Compiles Lua code from a string without executing it, returning a reusable LuaFunction

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Example usage:
let f = vm.loadString("function(a,b) return a+b end")
let r = f.call([LuaValue.of(3.0), LuaValue.of(4.0)])</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|chunk|String|The Lua source|

Return: 

- The compiled function

Exception: 

- LuaError On a syntax error

### func openLibs\(\)
```cj
public func openLibs(): Unit
```
Opens all standard libraries (base/package/string/table/math/io/os/debug/jit/ffi etc.)

### func pop\(Int32\)
```cj
public func pop(n!: Int32 = 1): Unit
```
Pops n elements from the top of the stack

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int32|The number of elements to pop (default 1)|

### func pushValue\(CPointer<Unit>,LuaValue\)
```cj
public static func pushValue(L: CPointer < Unit >, v: LuaValue): Unit
```
Pushes a LuaValue onto the stack

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|CPointer<Unit>|The underlying lua_State handlev The LuaValue to push|
|v|LuaValue||

### func readValue\(CPointer<Unit>,Int32\)
```cj
public static func readValue(L: CPointer < Unit >, idx: Int32): LuaValue
```
Reads a LuaValue from a stack index

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|CPointer<Unit>|The underlying lua_State handleidx The stack index|
|idx|Int32||

Return: 

- The corresponding LuaValue (nil placeholder for tables/functions etc.)

### func setField\(Int32,String\)
```cj
public func setField(idx: Int32, name: String): Unit
```
Sets a table field (value already on top of the stack, table at idx) — low-level API for LuaTable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|The stack index of the tablename The field name|
|name|String||

### func setGlobal\(String,LuaValue\)
```cj
public func setGlobal(name: String, value: LuaValue): Unit
```
Writes a global variable

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The global variable namevalue The value to write|
|value|LuaValue||

### func setTop\(Int32\)
```cj
public func setTop(idx: Int32): Unit
```
Sets the stack size (a negative value removes |n| elements from the top)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|idx|Int32|The target top index (negative values are relative to the top)|

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the state is still valid (not disposed)

### prop jitVersion: String
```cj
public static prop jitVersion: String
```
The LuaJIT version string (e.g. "LuaJIT 2.1.x")

### prop libsOpened: Bool
```cj
public prop libsOpened: Bool
```
Whether the standard libraries have been opened

### prop version: String
```cj
public static prop version: String
```
The Lua version string (e.g. "Lua 5.1")

