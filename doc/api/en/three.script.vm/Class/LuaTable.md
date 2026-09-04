# Class
## class LuaTable
```cj
public class LuaTable
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
|vm|LuaVM|The target virtual machinenarr Preallocated capacity of the array partnrec Preallocated capacity of the hash part|
|narr|Int32||
|nrec|Int32||

Return: 

- The reference to the newly created table

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the registry reference

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaTable >
```
Gets a table reference from a global variable (null when not a table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machinename The global variable name|
|name|String||

Return: 

- The table reference, or None if the global is missing or not a table

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
|vm|LuaVM|The owning virtual machineref The registry reference (produced by luaL_ref)|
|ref|Int32||

### func len\(\)
```cj
public func len(): Int64
```
Table length (array part, #t)

Return: 

- The length of the array part of the table

### func setIndex\(Int32,LuaValue\)
```cj
public func setIndex(i: Int32, value: LuaValue): Unit
```
Writes an array index (t[i] = v, 1-based)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int32|The array index (1-based)value The value to write|
|value|LuaValue||

### func set\(String,LuaValue\)
```cj
public func set(key: String, value: LuaValue): Unit
```
Writes a field (t[k] = v)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|key|String|The field namevalue The value to write|
|value|LuaValue||

### prop isArray: Bool
```cj
public prop isArray: Bool
```
Whether the table is an array (consecutive integer keys)

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

