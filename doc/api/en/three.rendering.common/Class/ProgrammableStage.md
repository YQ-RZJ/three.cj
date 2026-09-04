# Class
## class ProgrammableStage
```cj
public open class ProgrammableStage
```
Shader programmable stage description

### func getCode\(\)
```cj
public func getCode(): String
```
Gets the shader code

Return: 

- Shader code

### func getStage\(\)
```cj
public func getStage(): String
```
Gets the shader stage

Return: 

- Shader stage

### func init\(String,String\)
```cj
public init(code: String, kind: String)
```
Constructs a programmable stage with specified code and kind

Parameter: 

|Name|Type|Describe|
|---|---|---|
|code|String|Shader codekind Shader kind|
|kind|String||

### var code
```cj
public var code: String
```
Shader code

### var kind
```cj
public var kind: String
```
Shader kind (e.g., "vertex", "fragment", "compute")

### var stage
```cj
public var stage: String
```
Shader stage (defaults to the same as kind)

