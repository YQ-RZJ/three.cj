# Class
## class BgfxShaderCache
```cj
public class BgfxShaderCache
```
bgfx shader cache

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all caches

### func getFragmentShaderStage\(Int64,String,BgfxShader,BgfxMemory\)
```cj
public func getFragmentShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage
```
Get fragment shader stage

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material IDcode Shader codeshader Shader compilermem Shader data memory|
|code|String||
|shader|BgfxShader||
|mem|BgfxMemory||

Return: 

- Shader stage

### func getShaderStage\(String,BgfxShader,BgfxMemory,String\)
```cj
public func getShaderStage(code: String, shader: BgfxShader, mem: BgfxMemory, name: String): ShaderStage
```
Get or create shader stage

Parameter: 

|Name|Type|Describe|
|---|---|---|
|code|String|Shader codeshader Shader compilermem Shader data memoryname Shader name|
|shader|BgfxShader||
|mem|BgfxMemory||
|name|String||

Return: 

- Shader stage

### func getVertexShaderStage\(Int64,String,BgfxShader,BgfxMemory\)
```cj
public func getVertexShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage
```
Get vertex shader stage

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material IDcode Shader codeshader Shader compilermem Shader data memory|
|code|String||
|shader|BgfxShader||
|mem|BgfxMemory||

Return: 

- Shader stage

### func init\(\)
```cj
public init()
```


### func remove\(Int64\)
```cj
public func remove(materialId: Int64): Unit
```
Remove shader references for a material

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material ID|

### func update\(Int64,String,String\)
```cj
public func update(materialId: Int64, vertexCode: String, fragmentCode: String): Unit
```
Update shader references for a material

Parameter: 

|Name|Type|Describe|
|---|---|---|
|materialId|Int64|Material IDvertexCode Vertex shader codefragmentCode Fragment shader code|
|vertexCode|String||
|fragmentCode|String||

