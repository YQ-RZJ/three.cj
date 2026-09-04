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


Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String||
|varyingPtr|CPointer<Unit>||
|varyingSize|UInt32||
|srcPtr|CPointer<Unit>||
|srcSize|UInt32||
|optionsPtr|CPointer<ScOptions>||
|resultPtr|CPointer<ScResult>||

### func waitFor\(\)
```cj
public func waitFor(): Unit
```
Block until compilation completes

### var compileResult
```cj
public var compileResult: Int32 = - 999
```


### let label
```cj
public let label: String
```


### let optionsPtr
```cj
public let optionsPtr: CPointer < ScOptions >
```


### let resultPtr
```cj
public let resultPtr: CPointer < ScResult >
```


### let srcPtr
```cj
public let srcPtr: CPointer < Unit >
```


### let srcSize
```cj
public let srcSize: UInt32
```


### let varyingPtr
```cj
public let varyingPtr: CPointer < Unit >
```


### let varyingSize
```cj
public let varyingSize: UInt32
```


