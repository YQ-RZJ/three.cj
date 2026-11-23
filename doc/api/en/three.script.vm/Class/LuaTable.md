# Class
## class LuaTable
```cj
public class LuaTable <: IReleasable
```
Lua table reference

### func create\(LuaVM,Int32,Int32\)
```cj
public static func create(vm: LuaVM, narr!: Int32 = 0, nrec!: Int32 = 0): LuaTable
```
Creates a new table in the VM and returns a reference

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|
|narr|Int32|Preallocated capacity of the array part|
|nrec|Int32|Preallocated capacity of the hash part|

Return: 

- The reference to the newly created table

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaTable >
```
Gets a table reference from a global variable (null when not a table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|
|name|String|The global variable name|

Return: 

- The table reference, or None if the global is missing or not a table

### func fromStack\(LuaVM,VoidPtr,Int32\)
```cj
public static func fromStack(vm: LuaVM, L: VoidPtr, idx: Int32): Option < LuaTable >
```
Creates a table reference from a stack index (lua_pushvalue + luaL_ref;
None when the value is not a table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The owning virtual machine (used for release)|
|L|VoidPtr|The underlying lua_State handle|
|idx|Int32|The stack index (returns None and leaves the stack untouched when not a table)|

Return: 

- The table reference, or None when the top value is not a table

### func getIndex\(Int32\)
```cj
public func getIndex(i: Int32): LuaValue
```
Reads an array index (t[i], 1-based)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int32|The array index (1-based)|

Return: 

- The value at the index (nil when absent)

### func getValues\(\)
```cj
public func getValues(): Array < LuaValue >
```
Reads the whole array part of the table (t[1]..t[n], n = len()) as an element array

Return: 

- The array-part elements; an empty array when the table has no array part

### func get\(String\)
```cj
public func get(key: String): LuaValue
```
Reads a field (t[k]) and returns a LuaValue

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|The field name|

Return: 

- The field value (nil when absent)

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

### func len\(\)
```cj
public func len(): Int64
```
Table length (array part, #t)

Return: 

- The length of the array part of the table

### func release\(\)
```cj
public func release(): Bool
```
Releases the registry reference

### func setIndex\(Int32,LuaValue\)
```cj
public func setIndex(i: Int32, value: LuaValue): Unit
```
Writes an array index (t[i] = v, 1-based)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int32|The array index (1-based)|
|value|LuaValue|The value to write|

### func set\(String,LuaValue\)
```cj
public func set(key: String, value: LuaValue): Unit
```
Writes a field (t[k] = v)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|The field name|
|value|LuaValue|The value to write|

### prop isArray: Bool
```cj
public prop isArray: Bool
```
Whether the table is an array (consecutive integer keys)

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

