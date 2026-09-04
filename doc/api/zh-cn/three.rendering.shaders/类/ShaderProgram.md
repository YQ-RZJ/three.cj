# 类
## class ShaderProgram
```cj
public class ShaderProgram <: IShaderProgram
```
着色器程序定义，包含顶点和片段着色器源码

### func compileBgfx\(Array<String>\)
```cj
public func compileBgfx(extraDefines!: Array < String >= Array < String >()): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|extraDefines|Array<String>|额外的 #define 标志数组（如 "USE_MAP=1"）；默认空（仅含跨平台语言宏定义）编译 bgfx shader（带变体 #define 标志）使用 libshaderc 动态编译 GLSL 源码为 bgfx 二进制 shader|

### func createVariant\(String,ShaderProgram\)
```cj
public static func createVariant(name: String, base: ShaderProgram): ShaderProgram
```
从基类 ShaderProgram 创建变体，直接复用已解析的 bgfx 着色器源码，
避免每帧重复执行 ShaderChunks.resolve() 的昂贵字符串处理。

参数: 

|名称|类型|描述|
|---|---|---|
|name|String||
|base|ShaderProgram||

### func init\(String,String,String,String\)
```cj
public init(name: String, vertexShader: String, fragmentShader: String, varyingDef!: String = "")
```
构造着色器程序

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|着色器程序名称vertexShader 顶点着色器源码fragmentShader 片段着色器源码varyingDef varying 定义（.sc 格式），默认为空|
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
片段着色器 bgfx 解析后源码

### var fragmentShader
```cj
public var fragmentShader: String
```
片段着色器原始源码

### var fshHandle
```cj
public var fshHandle: ShaderHandle
```
片段着色器 bgfx 句柄

### var name
```cj
public var name: String
```
着色器程序名称

### var programHandle
```cj
public var programHandle: ProgramHandle
```
bgfx 程序句柄

### var varyingDef
```cj
public var varyingDef: String
```
varying 定义源码（.sc 格式）

### var vertexShaderBgfx
```cj
public var vertexShaderBgfx: String
```
顶点着色器 bgfx 解析后源码

### var vertexShader
```cj
public var vertexShader: String
```
顶点着色器原始源码

### var vshHandle
```cj
public var vshHandle: ShaderHandle
```
顶点着色器 bgfx 句柄

