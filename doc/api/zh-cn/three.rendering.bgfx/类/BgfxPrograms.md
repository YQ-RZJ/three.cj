# 类
## class BgfxPrograms
```cj
public class BgfxPrograms
```
bgfx 着色器程序管理

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有着色器程序

### func getProgram\(String,ShaderHandle,ShaderHandle,String\)
```cj
public func getProgram(paramKey: String, vertexShader: ShaderHandle, fragmentShader: ShaderHandle, name: String): BgfxProgramData
```
获取或创建着色器程序

参数: 

|名称|类型|描述|
|---|---|---|
|paramKey|String|参数哈希键vertexShader 顶点着色器句柄fragmentShader 片段着色器句柄name 程序名称|
|vertexShader|ShaderHandle||
|fragmentShader|ShaderHandle||
|name|String||

返回: 

- 程序数据

### func init\(BgfxProgram,BgfxShaderCache,BgfxShader\)
```cj
public init(program!: BgfxProgram, shaderCache!: BgfxShaderCache, shader!: BgfxShader)
```


参数: 

|名称|类型|描述|
|---|---|---|
|program|BgfxProgram||
|shaderCache|BgfxShaderCache||
|shader|BgfxShader||

### func releaseProgram\(BgfxProgramData\)
```cj
public func releaseProgram(data: BgfxProgramData): Unit
```
释放程序

参数: 

|名称|类型|描述|
|---|---|---|
|data|BgfxProgramData|程序数据|

### func size\(\)
```cj
public func size(): Int64
```
获取程序数量

返回: 

- 程序数量

