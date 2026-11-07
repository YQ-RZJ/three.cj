# Class
## class BgfxPrograms
```cj
public class BgfxPrograms <: IReleasable
```
bgfx shader program management

### func getProgram\(String,ShaderHandle,ShaderHandle,String\)
```cj
public func getProgram(paramKey: String, vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData
```
Gets or creates shader program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|paramKey|String|Parameter hash keyvertexShader Vertex shader handlefragmentShader Fragment shader handlename Program name|
|vertexShader|ShaderHandle||
|fragmentShader|ShaderHandle||
|name|String||

Return: 

- Program data

### func init\(BgfxProgram,BgfxShaderCache,BgfxShader\)
```cj
public init(program!: BgfxProgram, shaderCache!: BgfxShaderCache, shader!: BgfxShader)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|program|BgfxProgram||
|shaderCache|BgfxShaderCache||
|shader|BgfxShader||

### func releaseProgram\(BgfxProgramData\)
```cj
public func releaseProgram(data: BgfxProgramData): Unit
```
Releases program

Parameter: 

|Name|Type|Describe|
|---|---|---|
|data|BgfxProgramData|Program data|

### func release\(\)
```cj
public func release(): Bool
```
dispose all shader programs

### func size\(\)
```cj
public func size(): Int64
```
Gets program count

Return: 

- Program count

