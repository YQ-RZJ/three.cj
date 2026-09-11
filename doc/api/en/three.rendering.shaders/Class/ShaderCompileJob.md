# Class
## class ShaderCompileJob
```cj
public class ShaderCompileJob
```
Shader compilation job

### func init\(String,CPointer<Unit>,UInt32,CPointer<Unit>,UInt32,CPointer<ScOptions>,CPointer<ScResult>\)
```cj
public init(label: String, varyingPtr: CPointer < Unit >, varyingSize: UInt32, srcPtr: CPointer < Unit >, srcSize: UInt32, optionsPtr: CPointer < ScOptions >, resultPtr: CPointer < ScResult >)
```
Constructor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Log label|
|varyingPtr|CPointer<Unit>|Varying definitions C pointer|
|varyingSize|UInt32|Varying definitions size|
|srcPtr|CPointer<Unit>|Shader source C pointer|
|srcSize|UInt32|Shader source size|
|optionsPtr|CPointer<ScOptions>|Compile options C pointer|
|resultPtr|CPointer<ScResult>|Compile result C pointer|

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

### let optionsPtr
```cj
public let optionsPtr: CPointer < ScOptions >
```
Compile options C pointer

### let resultPtr
```cj
public let resultPtr: CPointer < ScResult >
```
Compile result C pointer

### let srcPtr
```cj
public let srcPtr: CPointer < Unit >
```
Shader source C pointer

### let srcSize
```cj
public let srcSize: UInt32
```
Shader source size

### let varyingPtr
```cj
public let varyingPtr: CPointer < Unit >
```
Varying definitions C pointer

### let varyingSize
```cj
public let varyingSize: UInt32
```
Varying definitions size

