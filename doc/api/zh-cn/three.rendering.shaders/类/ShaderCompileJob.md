# 类
## class ShaderCompileJob
```cj
public class ShaderCompileJob
```
着色器编译任务

### func init\(String,CPointer<Unit>,UInt32,CPointer<Unit>,UInt32,CPointer<ScOptions>,CPointer<ScResult>\)
```cj
public init(label: String, varyingPtr: CPointer < Unit >, varyingSize: UInt32, srcPtr: CPointer < Unit >, srcSize: UInt32, optionsPtr: CPointer < ScOptions >, resultPtr: CPointer < ScResult >)
```
构造器

参数: 

|名称|类型|描述|
|---|---|---|
|label|String|日志标签|
|varyingPtr|CPointer<Unit>|varying 定义 C 指针|
|varyingSize|UInt32|varying 定义大小|
|srcPtr|CPointer<Unit>|shader 源码 C 指针|
|srcSize|UInt32|shader 源码大小|
|optionsPtr|CPointer<ScOptions>|编译选项 C 指针|
|resultPtr|CPointer<ScResult>|编译结果 C 指针|

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

### let optionsPtr
```cj
public let optionsPtr: CPointer < ScOptions >
```
编译选项 C 指针

### let resultPtr
```cj
public let resultPtr: CPointer < ScResult >
```
编译结果 C 指针

### let srcPtr
```cj
public let srcPtr: CPointer < Unit >
```
shader 源码 C 指针

### let srcSize
```cj
public let srcSize: UInt32
```
shader 源码大小

### let varyingPtr
```cj
public let varyingPtr: CPointer < Unit >
```
varying 定义 C 指针

### let varyingSize
```cj
public let varyingSize: UInt32
```
varying 定义大小

