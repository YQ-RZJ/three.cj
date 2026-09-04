# Class
## class BgfxShader
```cj
public class BgfxShader
```
bgfx shader compilation

### func compileShader\(BgfxMemory,String\)
```cj
public func compileShader(code: BgfxMemory, name: String): ShaderHandle
```
Compile shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|code|BgfxMemory|Shader code (BgfxMemory, internal pointer)name Shader name (for debugging)|
|name|String||

Return: 

- Shader handle

### func destroyShader\(ShaderHandle\)
```cj
public func destroyShader(handle: ShaderHandle): Unit
```
Destroy shader

Parameter: 

|Name|Type|Describe|
|---|---|---|
|handle|ShaderHandle|Shader handle|

### func init\(BgfxInfo\)
```cj
public init(info!: BgfxInfo = BgfxInfo())
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|info|BgfxInfo||

