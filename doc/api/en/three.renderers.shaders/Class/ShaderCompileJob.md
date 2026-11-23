# Class
## class ShaderCompileJob
```cj
public class ShaderCompileJob
```
Shader compilation job

### func waitFor\(\)
```cj
public func waitFor(): Unit
```
Block until compilation completes

### var compileResult
```cj
public var compileResult: Int32 = - 999
```
sc_compile return value (-999 means not yet completed)

### let label
```cj
public let label: String
```
Log label

### let srcSize
```cj
public let srcSize: UInt32
```
Shader source size

### let varyingSize
```cj
public let varyingSize: UInt32
```
Varying definitions size

