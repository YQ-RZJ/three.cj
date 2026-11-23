# 类
## class ShaderCompileJob
```cj
public class ShaderCompileJob
```
着色器编译任务

### func waitFor\(\)
```cj
public func waitFor(): Unit
```
阻塞等待编译完成

### var compileResult
```cj
public var compileResult: Int32 = - 999
```
sc_compile 返回值（-999 表示尚未完成）

### let label
```cj
public let label: String
```
日志标签

### let srcSize
```cj
public let srcSize: UInt32
```
shader 源码大小

### let varyingSize
```cj
public let varyingSize: UInt32
```
varying 定义大小

