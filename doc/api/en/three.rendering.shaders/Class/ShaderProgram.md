# Class
## class ShaderProgram
```cj
public class ShaderProgram <: IShaderProgram
```
Shader program definition containing vertex and fragment shader sources

### func compileBgfx\(Array<String>\)
```cj
public func compileBgfx(extraDefines!: Array < String >= Array < String >()): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|extraDefines|Array<String>|Extra #define flag array (e.g. "USE_MAP=1"); default empty (only cross-platform language macro definitions)|

### func createVariant\(String,ShaderProgram\)
```cj
public static func createVariant(name: String, base: ShaderProgram): ShaderProgram
```
从基类 ShaderProgram 创建变体，直接复用已解析的 bgfx 着色器源码，
避免每帧重复执行 ShaderChunks.resolve() 的昂贵字符串处理。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||
|base|ShaderProgram||

### func init\(String,String,String,String\)
```cj
public init(name: String, vertexShader: String, fragmentShader: String, varyingDef!: String = "")
```
Construct a shader program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Shader program namevertexShader Vertex shader sourcefragmentShader Fragment shader sourcevaryingDef Varying definition (.sc format), default empty|
|vertexShader|String||
|fragmentShader|String||
|varyingDef|String||

### func resetHandles\(\)
```cj
public func resetHandles(): Unit
```
把三个句柄重置为无效（强制 compileBgfxWithDefines 重编译）。
供 postprocessing 等外部层调用，避免其直接构造 bgfx 原生句柄。

### func resolveShaders\(\)
```cj
public func resolveShaders(): Unit
```


### var fragmentShaderBgfx
```cj
public var fragmentShaderBgfx: String
```
Fragment shader bgfx resolved source

### var fragmentShader
```cj
public var fragmentShader: String
```
Fragment shader raw source

### var fshHandle
```cj
public var fshHandle: ShaderHandle
```
Fragment shader bgfx handle

### var name
```cj
public var name: String
```
Shader program name

### var programHandle
```cj
public var programHandle: ProgramHandle
```
bgfx program handle

### var varyingDef
```cj
public var varyingDef: String
```
Varying definition source (.sc format)

### var vertexShaderBgfx
```cj
public var vertexShaderBgfx: String
```
Vertex shader bgfx resolved source

### var vertexShader
```cj
public var vertexShader: String
```
Vertex shader raw source

### var vshHandle
```cj
public var vshHandle: ShaderHandle
```
Vertex shader bgfx handle

