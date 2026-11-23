# Enum
## enum LuaVariant
```cj
public enum LuaVariant
```
Internal variant of LuaValue (package-visible; do not depend on it directly)

### Array\(Array < LuaValue >\)
```cj
Array(Array < LuaValue >)
```
Array value (carried Cangjie-side; pushed as a 1-based Lua table)

### Boolean\(Bool\)
```cj
Boolean(Bool)
```
Boolean value

### Function\(Int64\)
```cj
Function(Int64)
```
Lua function reference (registry ref id)

### Integer\(Int64\)
```cj
Integer(Int64)
```
Integer (LuaJIT supports 64-bit integers)

### Nil
```cj
Nil
```
nil (no value)

### Number\(Float64\)
```cj
Number(Float64)
```
Float number (Lua number)

### Object\(Int64\)
```cj
Object(Int64)
```
Engine object reference (userdata bound to a Cangjie object)

### Str\(String\)
```cj
Str(String)
```
String

### Table\(Int64\)
```cj
Table(Int64)
```
Lua table reference (registry ref id)

