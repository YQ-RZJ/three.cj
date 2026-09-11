# Enum
## enum LuaValue
```cj
public enum LuaValue
```
Lua base value type

### Boolean\(Bool\)
```cj
Boolean(Bool)
```
Boolean value

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

### Str\(String\)
```cj
Str(String)
```
String

### func boolValue\(Bool\)
```cj
public func boolValue(default!: Bool = false): Bool
```
Tries to read the boolean value (returns default when not a Boolean)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Bool|Fallback value when the type does not match|

Return: 

- The boolean value or the default

### func intValue\(Int64\)
```cj
public func intValue(default!: Int64 = 0): Int64
```
Tries to read the integer value (Integer taken directly, Number truncated, otherwise default)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Int64|Fallback value when the type does not match|

Return: 

- The integer value or the default

### func numberValue\(Float64\)
```cj
public func numberValue(default!: Float64 = 0.0): Float64
```
Tries to read the float value (Number taken directly, Integer converted, otherwise default)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Float64|Fallback value when the type does not match|

Return: 

- The float value or the default

### func of\(Bool\)
```cj
public static func of(b: Bool): LuaValue
```
Convenience constructor: boxes a Bool

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Bool|The boolean value|

Return: 

- The corresponding boolean LuaValue

### func of\(Float64\)
```cj
public static func of(n: Float64): LuaValue
```
Convenience constructor: boxes a Float64

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Float64|The float value|

Return: 

- The corresponding number LuaValue

### func of\(Int64\)
```cj
public static func of(n: Int64): LuaValue
```
Convenience constructor: boxes an Int64 (integer)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Int64|The integer value|

Return: 

- The corresponding integer LuaValue

### func of\(String\)
```cj
public static func of(s: String): LuaValue
```
Convenience constructor: boxes a String

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String|The string|

Return: 

- The corresponding string LuaValue

### func stringValue\(String\)
```cj
public func stringValue(default!: String = ""): String
```
Tries to read the string value (returns default when not a Str)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|String|Fallback value when the type does not match|

Return: 

- The string value or the default

### prop isNil: Bool
```cj
public prop isNil: Bool
```
Whether the value is nil

### prop typeName: String
```cj
public prop typeName: String
```
Type name (matching lua_typename: nil/boolean/number/string)

