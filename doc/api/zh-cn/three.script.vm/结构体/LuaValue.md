# 结构体
## struct LuaValue
```cj
public struct LuaValue <: Hashable & Equatable < LuaValue > & Comparable < LuaValue > & IHeapNode
```
Lua 值类型

### func \!=\(LuaValue\)
```cj
public operator func !=(rhs: LuaValue): Bool
```
判不等（Equatable<LuaValue>）

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|LuaValue||

### func ==\(LuaValue\)
```cj
public operator func ==(rhs: LuaValue): Bool
```
判等（Equatable<LuaValue>）

参数: 

|名称|类型|描述|
|---|---|---|
|rhs|LuaValue||

### func Array\(Array<LuaValue>\)
```cj
public static func Array(elems: Array < LuaValue >): LuaValue
```
数组值（仓颉侧承载；压栈时转换为 1-based Lua table）

参数: 

|名称|类型|描述|
|---|---|---|
|elems|Array<LuaValue>|任意 LuaValue 数组（可嵌套）|

### func Boolean\(Bool\)
```cj
public static func Boolean(b: Bool): LuaValue
```
布尔值

参数: 

|名称|类型|描述|
|---|---|---|
|b|Bool||

### func Function\(Int64\)
```cj
public static func Function(ref: Int64): LuaValue
```
Lua 函数引用（注册表 ref id）

参数: 

|名称|类型|描述|
|---|---|---|
|ref|Int64|注册表引用|

### func Integer\(Int64\)
```cj
public static func Integer(i: Int64): LuaValue
```
整数（LuaJIT 支持 64 位整数）

参数: 

|名称|类型|描述|
|---|---|---|
|i|Int64||

### func Number\(Float64\)
```cj
public static func Number(n: Float64): LuaValue
```
浮点数（Lua number）

参数: 

|名称|类型|描述|
|---|---|---|
|n|Float64||

### func Object\(Int64\)
```cj
public static func Object(id: Int64): LuaValue
```
引擎对象引用（绑定到仓颉对象的 userdata）

参数: 

|名称|类型|描述|
|---|---|---|
|id|Int64|全局对象注册表索引|

### func Str\(String\)
```cj
public static func Str(s: String): LuaValue
```
字符串

参数: 

|名称|类型|描述|
|---|---|---|
|s|String||

### func Table\(Int64\)
```cj
public static func Table(ref: Int64): LuaValue
```
Lua 表引用（注册表 ref id）

参数: 

|名称|类型|描述|
|---|---|---|
|ref|Int64|注册表引用|

### func arrayValues\(Array<LuaValue>\)
```cj
public func arrayValues(default!: Array < LuaValue >=[]): Array < LuaValue >
```
取数组元素（Array 变体）；其余返回 default

参数: 

|名称|类型|描述|
|---|---|---|
|default|Array<LuaValue>|类型不匹配时的默认值|

返回: 

- 数组元素或默认值

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

### func compare\(LuaValue\)
```cj
public func compare(that: LuaValue): Ordering
```
比较序（Comparable<LuaValue>）

参数: 

|名称|类型|描述|
|---|---|---|
|that|LuaValue||

### func hashCode\(\)
```cj
public func hashCode(): Int64
```
计算哈希值（Hashable）

### func init\(\)
```cj
public init()
```
构造为空值（Nil）

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

### func lessThan\(IHeapNode\)
```cj
public func lessThan(other: IHeapNode): Bool
```
与另一个堆节点比较（IHeapNode）

参数: 

|名称|类型|描述|
|---|---|---|
|other|IHeapNode|另一节点|

返回: 

- this 比 other 更优先（compare 为 LT）；other 非 LuaValue 时返回 false

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

### func objectId\(Int64\)
```cj
public func objectId(default!: Int64 = 0): Int64
```
尝试取对象注册表 id（非 Object 返回 default）

参数: 

|名称|类型|描述|
|---|---|---|
|default|Int64|类型不匹配时的默认值|

返回: 

- 对象注册表 id 或默认值

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

### func of\(Array<Float64>\)
```cj
public static func of(arr: Array < Float64 >): LuaValue
```
便捷构造：从 Float64 数组装箱（→ Array 变体）

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<Float64>|浮点数组|

返回: 

- 对应的数组类型 LuaValue

### func of\(Array<Int64>\)
```cj
public static func of(arr: Array < Int64 >): LuaValue
```
便捷构造：从 Int64 数组装箱（→ Array 变体）

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<Int64>|整数数组|

返回: 

- 对应的数组类型 LuaValue

### func of\(Array<String>\)
```cj
public static func of(arr: Array < String >): LuaValue
```
便捷构造：从 String 数组装箱（→ Array 变体）

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<String>|字符串数组|

返回: 

- 对应的数组类型 LuaValue

### func of\(Array<LuaValue>\)
```cj
public static func of(arr: Array < LuaValue >): LuaValue
```
便捷构造：从 LuaValue 数组装箱（→ Array 变体）

参数: 

|名称|类型|描述|
|---|---|---|
|arr|Array<LuaValue>|任意 LuaValue 数组|

返回: 

- 对应的数组类型 LuaValue

### func refId\(Int64\)
```cj
public func refId(default!: Int64 = 0): Int64
```
取注册表引用 id（Table/Function 变体）；其余返回 default

参数: 

|名称|类型|描述|
|---|---|---|
|default|Int64|类型不匹配时的默认值|

返回: 

- 注册表 ref id 或默认值

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

### func toArrayFloat\(\)
```cj
public func toArrayFloat(): Array < Float64 >
```
数组转 Float64 原生数组（元素经 numberValue 转换，非数值取 0.0）

返回: 

- 浮点数组；非 Array 变体返回空数组

### func toArrayInt\(\)
```cj
public func toArrayInt(): Array < Int64 >
```
数组转 Int64 原生数组（元素经 intValue 转换，非整数值取 0）

返回: 

- 整数数组；非 Array 变体返回空数组

### func toArrayString\(\)
```cj
public func toArrayString(): Array < String >
```
数组转 String 原生数组（元素经 stringValue 转换，非字符串取 ""）

返回: 

- 字符串数组；非 Array 变体返回空数组

### func unrefValue\(VoidPtr\)
```cj
public func unrefValue(L: VoidPtr): Unit
```
释放 Table/Function 变体的注册表引用（luaL_unref）

参数: 

|名称|类型|描述|
|---|---|---|
|L|VoidPtr|底层 lua_State 句柄|

### prop Nil: LuaValue
```cj
public static prop Nil: LuaValue
```
nil（空值）

### prop index: Int64
```cj
public mut prop index: Int64
```
在堆中的索引（IHeapNode），-1 表示不在堆中

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
是否为函数引用（Function 变体）

### prop isInteger: Bool
```cj
public prop isInteger: Bool
```
是否为整数变体（Integer）

### prop isNil: Bool
```cj
public prop isNil: Bool
```
是否为 nil

### prop isNumber: Bool
```cj
public prop isNumber: Bool
```
是否为数值变体（Number/Integer）

### prop isObject: Bool
```cj
public prop isObject: Bool
```
是否为引擎对象引用

### prop isString: Bool
```cj
public prop isString: Bool
```
是否为字符串变体

### prop isTable: Bool
```cj
public prop isTable: Bool
```
是否为表引用（Table 变体）

### prop typeName: String
```cj
public prop typeName: String
```
类型名称（对应 lua_typename：nil/boolean/number/string/userdata/table/function）

