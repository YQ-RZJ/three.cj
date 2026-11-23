# 接口
## interface IUniformRegistry
```cj
public interface IUniformRegistry <: IReleasable
```
uniform 注册表接口：创建句柄、提交 uniform 数据、绑定纹理采样器

### func createUniform\(String,GfxUniformType\)
```cj
func createUniform(name: String, uniformType: GfxUniformType): GfxUniformHandle
```
创建 uniform 句柄（非数组）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|uniformType|GfxUniformType|uniform 类型（Sampler/Vec4/Mat3/Mat4）|

返回: 

- uniform 句柄

### func createUniform\(String,GfxUniformType,UInt16\)
```cj
func createUniform(name: String, uniformType: GfxUniformType, num: UInt16): GfxUniformHandle
```
创建 uniform 句柄（数组版本）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|uniformType|GfxUniformType|uniform 类型|
|num|UInt16|数组长度|

返回: 

- uniform 句柄

### func getHandle\(String\)
```cj
func getHandle(name: String): Option < GfxUniformHandle >
```
获取 uniform 句柄

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|

返回: 

- uniform 句柄（若不存在返回 None）

### func release\(\)
```cj
func release(): Bool
```
销毁本注册表持有的全部 uniform

返回: 

- true 表示执行了释放

### func setMat3\(String,PtrArray<Float32>\)
```cj
func setMat3(name: String, data: PtrArray < Float32 >): Unit
```
设置 mat3 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|data|PtrArray<Float32>|uniform 数据（Float32 数组）|

### func setMat4\(String,PtrArray<Float32>\)
```cj
func setMat4(name: String, data: PtrArray < Float32 >): Unit
```
设置 mat4 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|data|PtrArray<Float32>|uniform 数据（Float32 数组）|

### func setTexture\(String,UInt8,GfxTextureHandle,UInt32\)
```cj
func setTexture(name: String, stage: UInt8, handle: GfxTextureHandle, flags: UInt32): Unit
```
设置纹理采样器 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|stage|UInt8|纹理阶段索引|
|handle|GfxTextureHandle|纹理句柄|
|flags|UInt32|采样器标志|

### func setVec4\(String,PtrArray<Float32>\)
```cj
func setVec4(name: String, data: PtrArray < Float32 >): Unit
```
设置 vec4 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|data|PtrArray<Float32>|uniform 数据（Float32 数组）|

