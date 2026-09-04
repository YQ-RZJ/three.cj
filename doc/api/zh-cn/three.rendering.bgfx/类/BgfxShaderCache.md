# 类
## class BgfxShaderCache
```cj
public class BgfxShaderCache
```
bgfx 着色器缓存

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放所有缓存

### func getFragmentShaderStage\(Int64,String,BgfxShader,BgfxMemory\)
```cj
public func getFragmentShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage
```
获取片段着色器阶段

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 IDcode 着色器代码shader 着色器编译器mem 着色器数据内存|
|code|String||
|shader|BgfxShader||
|mem|BgfxMemory||

返回: 

- 着色器阶段

### func getShaderStage\(String,BgfxShader,BgfxMemory,String\)
```cj
public func getShaderStage(code: String, shader: BgfxShader, mem: BgfxMemory, name: String): ShaderStage
```
获取或创建着色器阶段

参数: 

|名称|类型|描述|
|---|---|---|
|code|String|着色器代码shader 着色器编译器mem 着色器数据内存name 着色器名称|
|shader|BgfxShader||
|mem|BgfxMemory||
|name|String||

返回: 

- 着色器阶段

### func getVertexShaderStage\(Int64,String,BgfxShader,BgfxMemory\)
```cj
public func getVertexShaderStage(materialId: Int64, code: String, shader: BgfxShader, mem: BgfxMemory): ShaderStage
```
获取顶点着色器阶段

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 IDcode 着色器代码shader 着色器编译器mem 着色器数据内存|
|code|String||
|shader|BgfxShader||
|mem|BgfxMemory||

返回: 

- 着色器阶段

### func init\(\)
```cj
public init()
```


### func remove\(Int64\)
```cj
public func remove(materialId: Int64): Unit
```
移除材质的着色器引用

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 ID|

### func update\(Int64,String,String\)
```cj
public func update(materialId: Int64, vertexCode: String, fragmentCode: String): Unit
```
更新材质的着色器引用

参数: 

|名称|类型|描述|
|---|---|---|
|materialId|Int64|材质 IDvertexCode 顶点着色器代码fragmentCode 片段着色器代码|
|vertexCode|String||
|fragmentCode|String||

