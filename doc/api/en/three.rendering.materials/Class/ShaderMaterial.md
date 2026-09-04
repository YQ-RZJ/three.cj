# Class
## class ShaderMaterial
```cj
public open class ShaderMaterial <: Material
```
Custom shader material, allowing custom vertex/fragment shader source code

### func copy\(ShaderMaterial,Bool\)
```cj
public func copy(source: ShaderMaterial, recursive!: Bool = true): ShaderMaterial
```
Copy the properties from the given ShaderMaterial to this instance

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|ShaderMaterial|Source materialrecursive Whether to copy recursively|
|recursive|Bool||

Return: 

- This instance

### func init\(\)
```cj
public init()
```
Construct a new custom shader material

### func init\(String,String,HashMap<String,Any>\)
```cj
public init(vertexShader: String, fragmentShader: String, uniforms!: HashMap < String, Any >= HashMap < String, Any >())
```
Construct a custom shader material with specified shader source code

Parameter: 

|Name|Type|Describe|
|---|---|---|
|vertexShader|String|Vertex shader source codefragmentShader Fragment shader source codeuniforms Custom uniform table|
|fragmentShader|String||
|uniforms|HashMap<String,Any>||

### var fragmentShader
```cj
public var fragmentShader: String
```
Fragment shader source code (bgfx .sc format)

### var uniforms
```cj
public var uniforms: HashMap < String, Any >
```
Custom uniform table, key is uniform name, value is UniformValue object

### var vertexShader
```cj
public var vertexShader: String
```
Vertex shader source code (bgfx .sc format)

