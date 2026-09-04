# 枚举
## enum LuaValue
```cj
public enum LuaValue
```
Lua 基础值类型

### Boolean\(Bool\)
```cj
Boolean(Bool)
```
布尔值

### Integer\(Int64\)
```cj
Integer(Int64)
```
整数（LuaJIT 支持 64 位整数）

### Nil
```cj
Nil
```
nil（空值）

### Number\(Float64\)
```cj
Number(Float64)
```
浮点数（Lua number）

### Str\(String\)
```cj
Str(String)
```
字符串

### func boolValue\(Bool\)
```cj
public func boolValue(default!: Bool = false): Bool
```
尝试取布尔值（非 Boolean 返回 default）

参数: 

|名称|类型|描述|
|---|---|---|
|default|Bool|类型不匹配时的默认值|

返回: 

- 布尔值或默认值

### func intValue\(Int64\)
```cj
public func intValue(default!: Int64 = 0): Int64
```
尝试取整数值（Integer 直接取，Number 截断，其余返回 default）

参数: 

|名称|类型|描述|
|---|---|---|
|default|Int64|类型不匹配时的默认值|

返回: 

- 整数值或默认值

### func numberValue\(Float64\)
```cj
public func numberValue(default!: Float64 = 0.0): Float64
```
尝试取浮点值（Number 直接取，Integer 转换，其余返回 default）

参数: 

|名称|类型|描述|
|---|---|---|
|default|Float64|类型不匹配时的默认值|

返回: 

- 浮点值或默认值

### func of\(Float64\)
```cj
public static func of(n: Float64): LuaValue
```
便捷构造：从 Float64 装箱

参数: 

|名称|类型|描述|
|---|---|---|
|n|Float64|浮点值|

返回: 

- 对应的浮点类型 LuaValue

### func of\(Int64\)
```cj
public static func of(n: Int64): LuaValue
```
便捷构造：从 Int64 装箱（整数）

参数: 

|名称|类型|描述|
|---|---|---|
|n|Int64|整数值|

返回: 

- 对应的整数类型 LuaValue

### func of\(String\)
```cj
public static func of(s: String): LuaValue
```
便捷构造：从 String 装箱

参数: 

|名称|类型|描述|
|---|---|---|
|s|String|字符串|

返回: 

- 对应的字符串类型 LuaValue

### func of\(Bool\)
```cj
public static func of(b: Bool): LuaValue
```
便捷构造：从 Bool 装箱

参数: 

|名称|类型|描述|
|---|---|---|
|b|Bool|布尔值|

返回: 

- 对应的布尔类型 LuaValue

### func stringValue\(String\)
```cj
public func stringValue(default!: String = ""): String
```
尝试取字符串值（非 Str 返回 default）

参数: 

|名称|类型|描述|
|---|---|---|
|default|String|类型不匹配时的默认值|

返回: 

- 字符串值或默认值

### prop isNil: Bool
```cj
public prop isNil: Bool
```
是否为 nil

### prop typeName: String
```cj
public prop typeName: String
```
类型名称（对应 lua_typename：nil/boolean/number/string）

