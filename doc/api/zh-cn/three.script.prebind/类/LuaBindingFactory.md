# 类
## class LuaBindingFactory
```cj
public class LuaBindingFactory
```
引擎 Lua 绑定统一工厂（静态工具）

### func installAll\(LuaVM\)
```cj
public static func installAll(vm: LuaVM): Int64
```
全量安装所有已登记绑定

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>可安全重复调用：同名绑定第二次调用会跳过。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|

返回: 

- 实际新增安装的数量；重复安装/跳过的绑定不计入

### func installPackage\(LuaVM,String\)
```cj
public static func installPackage(vm: LuaVM, prefix: String): Int64
```
按包前缀批量安装绑定

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|
|prefix|String|包前缀（如 "three.core.math"；空串 = 全量）|

返回: 

- 实际新增安装的数量

### func install\(LuaVM,String\)
```cj
public static func install(vm: LuaVM, className: String): Bool
```
按绑定类名精确安装单个绑定

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>重复安装同名类返回 true（已被跳过，不抛异常）。</p>

参数: 

|名称|类型|描述|
|---|---|---|
|vm|LuaVM|目标虚拟机|
|className|String|绑定类全名（如 "three.core.math.Vector3"）|

返回: 

- true = 已安装；false = 未登记该类名

### prop boundClasses: Array < String >
```cj
public static prop boundClasses: Array < String >
```
已登记的全部绑定类名（有序不定，用于清单与调试）

### prop count: Int64
```cj
public static prop count: Int64
```
已登记绑定数量

