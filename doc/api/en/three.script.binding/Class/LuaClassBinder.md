# Class
## class LuaClassBinder
```cj
public class LuaClassBinder
```
Cangjie class → Lua type binding engine

### func constructor\(LuaCtorFn\)
```cj
public func constructor(fn: LuaCtorFn): LuaClassBinder
```
Registers the constructor callback (creates Lua-side ClassTable.new)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fn|LuaCtorFn|The callback creating a Cangjie object from Lua arguments|

Return: 

- The current binder

### func defineClass\(LuaVM,String\)
```cj
public static func defineClass(vm: LuaVM, name: String): LuaClassBinder
```
Declares a bound class (a name may be used only once)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine (triggers object-bridge installation)|
|name|String|The bound class name (also the registry metatable key, e.g. "three.core.math.Vector3")|

Return: 

- The class binder for fluent registration

Exception: 

- Exception Thrown when the class name is already registered

### func install\(LuaVM\)
```cj
public func install(vm: LuaVM): Unit
```
Installs the current class into the target VM

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|

### func method\(String,LuaMethodFn\)
```cj
public func method(name: String, fn: LuaMethodFn): LuaClassBinder
```
Registers an instance method (a first-class function on the metatable, hit via __index)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The Lua-side method name|
|fn|LuaMethodFn|The method callback (self is passed as LuaObjectRef; args exclude self)|

Return: 

- The current binder

### func property\(String,Option<LuaGetterFn>,Option<LuaSetterFn>\)
```cj
public func property(name: String, getter!: Option < LuaGetterFn >= None, setter!: Option < LuaSetterFn >= None): LuaClassBinder
```
Registers a property (dispatched via __index/__newindex, supporting obj.x read/write)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The Lua-side property name|
|getter|Option<LuaGetterFn>|The getter callback (optional; read unavailable when absent)|
|setter|Option<LuaSetterFn>|The setter callback (optional; write unavailable when absent)|

Return: 

- The current binder

### func staticMethod\(String,LuaStaticFn\)
```cj
public func staticMethod(name: String, fn: LuaStaticFn): LuaClassBinder
```
Registers a static method (attached to the class namespace table)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|The Lua-side method name|
|fn|LuaStaticFn|The static callback (args are all request arguments)|

Return: 

- The current binder

