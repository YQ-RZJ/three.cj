# 类
## class LuaFunction
```cj
public class LuaFunction
```
Lua 函数引用

### func call\(Array<LuaValue>\)
```cj
public func call(args!: Array < LuaValue >=[]): Array < LuaValue >
```
调用函数

参数: 

|名称|类型|描述|
|---|---|---|
|args|Array<LuaValue>|参数数组（LuaValue；空数组 = 无参数）|

返回: 

- 返回值数组（可能为空）

异常: 

- LuaError 运行时错误

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放注册表引用

### func fromGlobal\(LuaVM,String\)
```cj
public static func fromGlobal(vm: LuaVM, name: String): Option < LuaFunction >
```
从全局变量获取函数引用（非函数则返回 null）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机name 全局变量名|
|name|String||

返回: 

- 函数引用；若全局变量不存在或不是函数则返回 None

### func init\(LuaVM,Int32\)
```cj
public init(vm!: LuaVM, ref!: Int32)
```
包装一个已存在的注册表引用

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|所属虚拟机ref 注册表引用（由 luaL_ref 产生）|
|ref|Int32||

### prop isValid: Bool
```cj
public prop isValid: Bool
```
是否有效（未被释放）

### prop ref: Int32
```cj
public prop ref: Int32
```
注册表引用 id

