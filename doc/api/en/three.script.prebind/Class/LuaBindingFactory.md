# Class
## class LuaBindingFactory
```cj
public class LuaBindingFactory
```
Unified factory for the engine Lua bindings (static utilities)

### func installAll\(LuaVM\)
```cj
public static func installAll(vm: LuaVM): Int64
```
Installs every registered binding

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Safe to call repeatedly: a class registered twice is skipped.</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|

Return: 

- The number of newly installed bindings; skipped/re-installed ones are not counted

### func installPackage\(LuaVM,String\)
```cj
public static func installPackage(vm: LuaVM, prefix: String): Int64
```
Installs bindings by package prefix

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|
|prefix|String|The package prefix (e.g. "three.core.math"; empty string = all)|

Return: 

- The number of newly installed bindings

### func install\(LuaVM,String\)
```cj
public static func install(vm: LuaVM, className: String): Bool
```
Installs a single binding by its full class name

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Re-installing the same class returns true (skipped, no exception thrown).</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vm|LuaVM|The target virtual machine|
|className|String|The full bound class name (e.g. "three.core.math.Vector3")|

Return: 

- true = installed; false = the class name is not registered

### prop boundClasses: Array < String >
```cj
public static prop boundClasses: Array < String >
```
All registered bound class names (unordered; for docs and debugging)

### prop count: Int64
```cj
public static prop count: Int64
```
The number of registered bindings

