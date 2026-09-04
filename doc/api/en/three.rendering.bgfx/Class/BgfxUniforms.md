# Class
## class BgfxUniforms
```cj
public class BgfxUniforms
```
bgfx uniform variable management

### func createUniform\(String,UInt32,UInt16\)
```cj
public func createUniform(name: String, uniformType: UInt32, num: UInt16): UniformHandle
```
Create uniform handle (array uniform version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform nameuniformType Uniform typenum Array length|
|uniformType|UInt32||
|num|UInt16||

Return: 

- Uniform handle

### func createUniform\(String,UInt32\)
```cj
public func createUniform(name: String, uniformType: UInt32): UniformHandle
```
Create uniform handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform nameuniformType Uniform type (BGFX_UNIFORM_VEC4/BGFX_UNIFORM_MAT3/BGFX_UNIFORM_MAT4/BGFX_UNIFORM_SAMPLER etc.)|
|uniformType|UInt32||

Return: 

- Uniform handle (Box wrapper)

### func dispose\(\)
```cj
public func dispose(): Unit
```
Dispose all uniforms

### func getHandle\(String\)
```cj
public func getHandle(name: String): Option < UniformHandle >
```
Get uniform handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|

Return: 

- Uniform handle (None if not found)

### func init\(\)
```cj
public init()
```


### func setMat3\(String,BgfxMemory\)
```cj
public func setMat3(name: String, data: BgfxMemory): Unit
```
Set mat3 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform namedata Data (BgfxMemory, internal pointer)|
|data|BgfxMemory||

### func setMat4\(String,BgfxMemory\)
```cj
public func setMat4(name: String, data: BgfxMemory): Unit
```
Set mat4 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform namedata Data (BgfxMemory, internal pointer)|
|data|BgfxMemory||

### func setTexture\(String,UInt8,TextureHandle,UInt32\)
```cj
public func setTexture(name: String, stage: UInt8, handle: TextureHandle, flags: UInt32): Unit
```
Set texture sampler uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform namestage Texture stage indexhandle Texture handleflags Sampler flags|
|stage|UInt8||
|handle|TextureHandle||
|flags|UInt32||

### func setVec4\(String,BgfxMemory\)
```cj
public func setVec4(name: String, data: BgfxMemory): Unit
```
Set vec4 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform namedata Data (BgfxMemory, internal pointer)|
|data|BgfxMemory||

