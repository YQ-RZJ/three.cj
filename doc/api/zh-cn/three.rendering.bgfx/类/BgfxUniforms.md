# 类
## class BgfxUniforms
```cj
public class BgfxUniforms
```
bgfx Uniform 变量管理

### func createUniform\(String,UInt32\)
```cj
public func createUniform(name: String, uniformType: UInt32): UniformHandle
```
创建 uniform 句柄

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称uniformType uniform 类型（BGFX_UNIFORM_VEC4/BGFX_UNIFORM_MAT3/BGFX_UNIFORM_MAT4/BGFX_UNIFORM_SAMPLER 等）|
|uniformType|UInt32||

返回: 

- uniform 句柄（Box 包装）

### func createUniform\(String,UInt32,UInt16\)
```cj
public func createUniform(name: String, uniformType: UInt32, num: UInt16): UniformHandle
```
创建 uniform 句柄（数组 uniform 版本）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称uniformType uniform 类型num 数组长度|
|uniformType|UInt32||
|num|UInt16||

返回: 

- uniform 句柄

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁所有 uniform

### func getHandle\(String\)
```cj
public func getHandle(name: String): Option < UniformHandle >
```
获取 uniform 句柄

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|

返回: 

- uniform 句柄（若不存在返回 None）

### func init\(\)
```cj
public init()
```


### func setMat3\(String,BgfxMemory\)
```cj
public func setMat3(name: String, data: BgfxMemory): Unit
```
设置 mat3 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称data 数据（BgfxMemory，内部取指针）|
|data|BgfxMemory||

### func setMat4\(String,BgfxMemory\)
```cj
public func setMat4(name: String, data: BgfxMemory): Unit
```
设置 mat4 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称data 数据（BgfxMemory，内部取指针）|
|data|BgfxMemory||

### func setTexture\(String,UInt8,TextureHandle,UInt32\)
```cj
public func setTexture(name: String, stage: UInt8, handle: TextureHandle, flags: UInt32): Unit
```
设置纹理采样器 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称stage 纹理阶段索引handle 纹理句柄flags 采样器标志|
|stage|UInt8||
|handle|TextureHandle||
|flags|UInt32||

### func setVec4\(String,BgfxMemory\)
```cj
public func setVec4(name: String, data: BgfxMemory): Unit
```
设置 vec4 uniform

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称data 数据（BgfxMemory，内部取指针）|
|data|BgfxMemory||

