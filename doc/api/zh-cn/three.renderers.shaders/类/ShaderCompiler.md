# 类
## class ShaderCompiler
```cj
public class ShaderCompiler
```
着色器编译器

### func isRunning\(\)
```cj
public static func isRunning(): Bool
```
是否正在运行

返回: 

- 正在运行返回 true

### func progress\(\)
```cj
public static func progress(): Float64
```
获取编译进度（0.0 ~ 1.0）

返回: 

- 进度百分比，无任务时返回 1.0

### func restart\(Int64\)
```cj
public static func restart(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit
```
重启编译器（先停止再启动）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>适合游戏中途需要重新编译 shader 时调用，释放旧线程后再创建新线程</p>

参数: 

|名称|类型|描述|
|---|---|---|
|stackSize|Int64|worker 栈大小（默认 8MB）|

### func start\(Int64\)
```cj
public static func start(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit
```
启动编译器

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>可多次调用：先 stop() 再 start() 可重新启动，释放旧线程资源</p>

参数: 

|名称|类型|描述|
|---|---|---|
|stackSize|Int64|worker 栈大小（默认 8MB）|

### func stop\(\)
```cj
public static func stop(): Unit
```
停止编译器

### func submit\(ShaderCompileJob\)
```cj
public static func submit(job: ShaderCompileJob): Unit
```
提交编译任务

参数: 

|名称|类型|描述|
|---|---|---|
|job|ShaderCompileJob|编译任务|

### func totalCompleted\(\)
```cj
public static func totalCompleted(): Int64
```
获取已完成的任务数

返回: 

- 已完成数

### func totalErrors\(\)
```cj
public static func totalErrors(): Int64
```
获取编译失败数

返回: 

- 失败数

### func totalSubmitted\(\)
```cj
public static func totalSubmitted(): Int64
```
获取已提交的任务总数

返回: 

- 已提交总数

### let DEFAULT\_STACK\_SIZE
```cj
public static let DEFAULT_STACK_SIZE: Int64 = 8 * 1024 * 1024
```
默认线程栈大小（8MB，远超 glslang 典型栈需求）

