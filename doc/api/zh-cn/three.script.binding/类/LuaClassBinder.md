# 类
## class LuaClassBinder
```cj
public class LuaClassBinder
```
仓颉类 → Lua 类型绑定引擎

### func constructor\(LuaCtorFn\)
```cj
public func constructor(fn: LuaCtorFn): LuaClassBinder
```
注册构造回调（生成 Lua 侧类表.new）

参数: 

|名称|类型|描述|
|---|---|---|
|fn|LuaCtorFn|由 Lua 参数创建仓颉对象的回调|

返回: 

- 当前绑定器

### func defineClass\(LuaVM,String\)
```cj
public static func defineClass(vm: LuaVM, name: String): LuaClassBinder
```
声明绑定类（同名类只允许一次）

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机（触发对象桥接安装）|
|name|String|绑定类名（同时作为注册表 metatable 键，如 "three.core.math.Vector3"）|

返回: 

- 类绑定器（链式注册）

异常: 

- Exception 同名类重复注册时抛出

### func install\(LuaVM\)
```cj
public func install(vm: LuaVM): Unit
```
将当前类安装到目标 VM

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|

### func method\(String,LuaMethodFn\)
```cj
public func method(name: String, fn: LuaMethodFn): LuaClassBinder
```
注册实例方法（metatable 上一等函数，经 __index 命中）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|Lua 侧方法名|
|fn|LuaMethodFn|方法回调（self 经 LuaObjectRef 传入，args 不含 self）|

返回: 

- 当前绑定器

### func property\(String,Option<LuaGetterFn>,Option<LuaSetterFn>\)
```cj
public func property(name: String, getter!: Option < LuaGetterFn >= None, setter!: Option < LuaSetterFn >= None): LuaClassBinder
```
注册属性（经 __index/__newindex 分派，支持 obj.x 读写）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|Lua 侧属性名|
|getter|Option<LuaGetterFn>|取值回调（可空；为空则该属性只读不可用）|
|setter|Option<LuaSetterFn>|写值回调（可空；为空则该属性只写不可用）|

返回: 

- 当前绑定器

### func staticMethod\(String,LuaStaticFn\)
```cj
public func staticMethod(name: String, fn: LuaStaticFn): LuaClassBinder
```
注册静态方法（挂在类命名空间表上）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|Lua 侧方法名|
|fn|LuaStaticFn|静态回调（args 为全部请求参数）|

返回: 

- 当前绑定器

