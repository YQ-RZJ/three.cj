# Class
## class LuaObjectRegistry
```cj
public class LuaObjectRegistry
```
Engine object registry (a collection of static methods)

### func classNameOf\(Int64\)
```cj
public static func classNameOf(id: Int64): Option < String >
```
Queries the bound class name of the object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The object id|

Return: 

- The bound class name, or None if absent

### func getAs\(Int64\)
```cj
public static func getAs < T >(id: Int64): T
```
Fetches the object by id and casts it to T

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The object id|

Return: 

- The cast object

Exception: 

- Exception Thrown when the type does not match or the object is missing

### func get\(Int64\)
```cj
public static func get(id: Int64): Option < Any >
```
Fetches the Cangjie object by id

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The object id returned at registration|

Return: 

- The object, or None if absent/removed

### func installBridge\(\)
```cj
public static func installBridge(): Unit
```
Installs the LuaVM object bridge (push/read userdata)

### func pushArrayFloat\(VoidPtr,Array<Float64>\)
```cj
public static func pushArrayFloat(L: VoidPtr, arr: Array < Float64 >): Unit
```
Pushes an Array<Float64> as a Lua table (1-based; empty array pushes an empty table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|arr|Array<Float64>|The float array|

### func pushIntArray\(VoidPtr,Array<Int64>\)
```cj
public static func pushIntArray(L: VoidPtr, arr: Array < Int64 >): Unit
```
Pushes an Array<Int64> as a Lua table (1-based; empty array pushes an empty table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|arr|Array<Int64>|The integer array|

### func pushStringArray\(VoidPtr,Array<String>\)
```cj
public static func pushStringArray(L: VoidPtr, arr: Array < String >): Unit
```
Pushes an Array<String> as a Lua table (1-based; empty array pushes an empty table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|arr|Array<String>|The string array|

### func readFloatArray\(VoidPtr,Int32\)
```cj
public static func readFloatArray(L: VoidPtr, idx: Int32): Array < Float64 >
```
Reads a Lua table (1-based) as an Array<Float64> (non-number slots become 0.0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|idx|Int32|The stack index (returns an empty array when not a table)|

Return: 

- The float array

### func readIntArray\(VoidPtr,Int32\)
```cj
public static func readIntArray(L: VoidPtr, idx: Int32): Array < Int64 >
```
Reads a Lua table (1-based) as an Array<Int64> (non-number slots become 0)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|idx|Int32|The stack index (returns an empty array when not a table)|

Return: 

- The integer array

### func readStringArray\(VoidPtr,Int32\)
```cj
public static func readStringArray(L: VoidPtr, idx: Int32): Array < String >
```
Reads a Lua table (1-based) as an Array<String> (non-string slots become "")

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|
|idx|Int32|The stack index (returns an empty array when not a table)|

Return: 

- The string array

### func register\(Any,String\)
```cj
public static func register(obj: Any, className: String): Int64
```
Allocates an id and registers a Cangjie object

Parameter: 

|Name|Type|Describe|
|---|---|---|
|obj|Any|The Cangjie object (Any)|
|className|String|The bound class name (the Lua-side metatable key, e.g. "three.core.math.Vector3")|

Return: 

- The object id (>0; carried by userdata and used for later lookups)

### func unregister\(Int64\)
```cj
public static func unregister(id: Int64): Bool
```
Removes the registry entry by id

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|The object id|

Return: 

- Whether an entry was removed

### prop count: Int64
```cj
public static prop count: Int64
```
The number of currently registered objects

