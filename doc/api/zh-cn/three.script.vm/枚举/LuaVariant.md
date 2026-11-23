# 枚举
## enum LuaVariant
```cj
public enum LuaVariant
```
LuaValue 内部变体（包内可见，外部勿直接依赖）

### Array\(Array < LuaValue >\)
```cj
Array(Array < LuaValue >)
```
数组值（仓颉侧承载；压栈时转换为 1-based Lua table）

### Boolean\(Bool\)
```cj
Boolean(Bool)
```
布尔值

### Function\(Int64\)
```cj
Function(Int64)
```
Lua 函数引用（注册表 ref id）

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

### Object\(Int64\)
```cj
Object(Int64)
```
引擎对象引用（绑定到仓颉对象的 userdata）

### Str\(String\)
```cj
Str(String)
```
字符串

### Table\(Int64\)
```cj
Table(Int64)
```
Lua 表引用（注册表 ref id）

