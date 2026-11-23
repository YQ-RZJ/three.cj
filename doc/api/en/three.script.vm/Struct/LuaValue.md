# Struct
## struct LuaValue
```cj
public struct LuaValue <: Hashable & Equatable < LuaValue > & Comparable < LuaValue > & IHeapNode
```
Lua value type

### func \!=\(LuaValue\)
```cj
public operator func !=(rhs: LuaValue): Bool
```
Inequality (Equatable<LuaValue>)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|LuaValue||

### func ==\(LuaValue\)
```cj
public operator func ==(rhs: LuaValue): Bool
```
Equality (Equatable<LuaValue>)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|rhs|LuaValue||

### func Array\(Array<LuaValue>\)
```cj
public static func Array(elems: Array < LuaValue >): LuaValue
```
Array value (carried Cangjie-side; pushed as a 1-based Lua table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|elems|Array<LuaValue>|Arbitrary LuaValue array (nested arrays allowed)|

### func Boolean\(Bool\)
```cj
public static func Boolean(b: Bool): LuaValue
```
Boolean value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|b|Bool||

### func Function\(Int64\)
```cj
public static func Function(ref: Int64): LuaValue
```
Lua function reference (registry ref id)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ref|Int64|The registry reference|

### func Integer\(Int64\)
```cj
public static func Integer(i: Int64): LuaValue
```
Integer (LuaJIT supports 64-bit integers)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|i|Int64||

### func Number\(Float64\)
```cj
public static func Number(n: Float64): LuaValue
```
Float number (Lua number)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|n|Float64||

### func Object\(Int64\)
```cj
public static func Object(id: Int64): LuaValue
```
Engine object reference (userdata bound to a Cangjie object)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|id|Int64|Index into the global object registry|

### func Str\(String\)
```cj
public static func Str(s: String): LuaValue
```
String

Parameter: 

|Name|Type|Describe|
|---|---|---|
|s|String||

### func Table\(Int64\)
```cj
public static func Table(ref: Int64): LuaValue
```
Lua table reference (registry ref id)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|ref|Int64|The registry reference|

### func arrayValues\(Array<LuaValue>\)
```cj
public func arrayValues(default!: Array < LuaValue >=[]): Array < LuaValue >
```
Reads the array elements (Array variant); otherwise returns default

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Array<LuaValue>|Fallback value when the type does not match|

Return: 

- The array elements or the default

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

### func compare\(LuaValue\)
```cj
public func compare(that: LuaValue): Ordering
```
Comparison order (Comparable<LuaValue>)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|that|LuaValue||

### func hashCode\(\)
```cj
public func hashCode(): Int64
```
Computes the hash value (Hashable)

### func init\(\)
```cj
public init()
```
Constructs the nil value

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

### func lessThan\(IHeapNode\)
```cj
public func lessThan(other: IHeapNode): Bool
```
Compares with another heap node (IHeapNode)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|other|IHeapNode|The other node|

Return: 

- true when this has higher priority than other (compare is LT); false when other is not a LuaValue

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

### func objectId\(Int64\)
```cj
public func objectId(default!: Int64 = 0): Int64
```
Tries to read the object registry id (returns default when not an Object)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Int64|Fallback value when the type does not match|

Return: 

- The object registry id or the default

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

### func of\(Array<Float64>\)
```cj
public static func of(arr: Array < Float64 >): LuaValue
```
Convenience constructor: boxes an Array<Float64> (→ Array variant)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Float64>|The float array|

Return: 

- The corresponding array LuaValue

### func of\(Array<Int64>\)
```cj
public static func of(arr: Array < Int64 >): LuaValue
```
Convenience constructor: boxes an Array<Int64> (→ Array variant)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<Int64>|The integer array|

Return: 

- The corresponding array LuaValue

### func of\(Array<String>\)
```cj
public static func of(arr: Array < String >): LuaValue
```
Convenience constructor: boxes an Array<String> (→ Array variant)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<String>|The string array|

Return: 

- The corresponding array LuaValue

### func of\(Array<LuaValue>\)
```cj
public static func of(arr: Array < LuaValue >): LuaValue
```
Convenience constructor: boxes an Array<LuaValue> (→ Array variant)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|arr|Array<LuaValue>|The LuaValue array|

Return: 

- The corresponding array LuaValue

### func refId\(Int64\)
```cj
public func refId(default!: Int64 = 0): Int64
```
Reads the registry reference id (Table/Function variants); otherwise returns default

Parameter: 

|Name|Type|Describe|
|---|---|---|
|default|Int64|Fallback value when the type does not match|

Return: 

- The registry ref id or the default

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

### func toArrayFloat\(\)
```cj
public func toArrayFloat(): Array < Float64 >
```
Converts the array to a native Float64 array (elements via numberValue, non-numbers become 0.0)

Return: 

- The float array; empty when not an Array variant

### func toArrayInt\(\)
```cj
public func toArrayInt(): Array < Int64 >
```
Converts the array to a native Int64 array (elements via intValue, non-integers become 0)

Return: 

- The integer array; empty when not an Array variant

### func toArrayString\(\)
```cj
public func toArrayString(): Array < String >
```
Converts the array to a native String array (elements via stringValue, non-strings become "")

Return: 

- The string array; empty when not an Array variant

### func unrefValue\(VoidPtr\)
```cj
public func unrefValue(L: VoidPtr): Unit
```
Releases the registry reference of a Table/Function variant (luaL_unref)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|L|VoidPtr|The underlying lua_State handle|

### prop Nil: LuaValue
```cj
public static prop Nil: LuaValue
```
nil (no value)

### prop index: Int64
```cj
public mut prop index: Int64
```
Index in the heap (IHeapNode), -1 means not in the heap

### prop isArray: Bool
```cj
public prop isArray: Bool
```
是否为数组变体

### prop isBool: Bool
```cj
public prop isBool: Bool
```
是否为布尔变体

### prop isFunction: Bool
```cj
public prop isFunction: Bool
```
Whether the value is a function reference (Function variant)

### prop isInteger: Bool
```cj
public prop isInteger: Bool
```
是否为整数变体（Integer）

### prop isNil: Bool
```cj
public prop isNil: Bool
```
Whether the value is nil

### prop isNumber: Bool
```cj
public prop isNumber: Bool
```
是否为数值变体（Number/Integer）

### prop isObject: Bool
```cj
public prop isObject: Bool
```
Whether the value is an engine object reference

### prop isString: Bool
```cj
public prop isString: Bool
```
是否为字符串变体

### prop isTable: Bool
```cj
public prop isTable: Bool
```
Whether the value is a table reference (Table variant)

### prop typeName: String
```cj
public prop typeName: String
```
Type name (matching lua_typename: nil/boolean/number/string/userdata/table/function)

