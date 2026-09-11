# Class
## class ShaderCompiler
```cj
public class ShaderCompiler
```
Shader compiler

### func isRunning\(\)
```cj
public static func isRunning(): Bool
```
Whether the compiler is running

Return: 

- True if running

### func progress\(\)
```cj
public static func progress(): Float64
```
Get compilation progress (0.0 ~ 1.0)

Return: 

- Progress ratio, returns 1.0 if no jobs submitted

### func restart\(Int64\)
```cj
public static func restart(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit
```
Restart the compiler (stop then start)

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>适合游戏中途需要重新编译 shader 时调用，释放旧线程后再创建新线程</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stackSize|Int64|Worker stack size (default 8MB)|

### func start\(Int64\)
```cj
public static func start(stackSize!: Int64 = DEFAULT_STACK_SIZE): Unit
```
Start the compiler

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>可多次调用：先 stop() 再 start() 可重新启动，释放旧线程资源</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|stackSize|Int64|Worker stack size (default 8MB)|

### func stop\(\)
```cj
public static func stop(): Unit
```
Stop the compiler

### func submit\(ShaderCompileJob\)
```cj
public static func submit(job: ShaderCompileJob): Unit
```
Submit a compilation job

Parameter: 

|Name|Type|Describe|
|---|---|---|
|job|ShaderCompileJob|Compilation job|

### func totalCompleted\(\)
```cj
public static func totalCompleted(): Int64
```
Gets the number of completed tasks

Return: 

- Number completed

### func totalErrors\(\)
```cj
public static func totalErrors(): Int64
```
Gets the number of compilation failures

Return: 

- Failure count

### func totalSubmitted\(\)
```cj
public static func totalSubmitted(): Int64
```
Gets the total number of submitted tasks

Return: 

- Total submitted

### let DEFAULT\_STACK\_SIZE
```cj
public static let DEFAULT_STACK_SIZE: Int64 = 8 * 1024 * 1024
```
Default thread stack size (8MB, far exceeding typical glslang stack requirements)

