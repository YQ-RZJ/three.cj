# Interface
## interface IUniformRegistry
```cj
public interface IUniformRegistry <: IReleasable
```
Uniform registry interface: create handles, submit uniform data, bind texture samplers

### func createUniform\(String,GfxUniformType\)
```cj
func createUniform(name: String, uniformType: GfxUniformType): GfxUniformHandle
```
Creates a uniform handle (non-array)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|uniformType|GfxUniformType|Uniform type (Sampler/Vec4/Mat3/Mat4)|

Return: 

- Uniform handle

### func createUniform\(String,GfxUniformType,UInt16\)
```cj
func createUniform(name: String, uniformType: GfxUniformType, num: UInt16): GfxUniformHandle
```
Creates a uniform handle (array version)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|uniformType|GfxUniformType|Uniform type|
|num|UInt16|Array length|

Return: 

- Uniform handle

### func getHandle\(String\)
```cj
func getHandle(name: String): Option < GfxUniformHandle >
```
Gets a uniform handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|

Return: 

- Uniform handle (None if not found)

### func release\(\)
```cj
func release(): Bool
```
Destroys all uniforms held by this registry

Return: 

- true if the release was performed

### func setMat3\(String,PtrArray<Float32>\)
```cj
func setMat3(name: String, data: PtrArray < Float32 >): Unit
```
Sets a mat3 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|data|PtrArray<Float32>|Uniform data (Float32 array)|

### func setMat4\(String,PtrArray<Float32>\)
```cj
func setMat4(name: String, data: PtrArray < Float32 >): Unit
```
Sets a mat4 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|data|PtrArray<Float32>|Uniform data (Float32 array)|

### func setTexture\(String,UInt8,GfxTextureHandle,UInt32\)
```cj
func setTexture(name: String, stage: UInt8, handle: GfxTextureHandle, flags: UInt32): Unit
```
Sets a texture sampler uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|stage|UInt8|Texture stage index|
|handle|GfxTextureHandle|Texture handle|
|flags|UInt32|Sampler flags|

### func setVec4\(String,PtrArray<Float32>\)
```cj
func setVec4(name: String, data: PtrArray < Float32 >): Unit
```
Sets a vec4 uniform

Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String|Uniform name|
|data|PtrArray<Float32>|Uniform data (Float32 array)|

