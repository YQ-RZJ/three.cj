# 类
## class ShaderMaterial
```cj
public open class ShaderMaterial <: Material
```
自定义着色器材质，允许传入自定义vertex/fragment shader源码

### func copy\(ShaderMaterial,Bool\)
```cj
public func copy(source: ShaderMaterial, recursive!: Bool = true): ShaderMaterial
```
将给定ShaderMaterial的属性复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|ShaderMaterial|源材质recursive 是否递归复制|
|recursive|Bool||

返回: 

- 本实例

### func init\(\)
```cj
public init()
```
构造一个新的自定义着色器材质

### func init\(String,String,HashMap<String,Any>\)
```cj
public init(vertexShader: String, fragmentShader: String, uniforms!: HashMap < String, Any >= HashMap < String, Any >())
```
构造一个带指定着色器源码的自定义着色器材质

参数: 

|名称|类型|描述|
|---|---|---|
|vertexShader|String|顶点着色器源码fragmentShader 片段着色器源码uniforms 自定义uniform表|
|fragmentShader|String||
|uniforms|HashMap<String,Any>||

### var fragmentShader
```cj
public var fragmentShader: String
```
片段着色器源码（bgfx .sc格式）

### var uniforms
```cj
public var uniforms: HashMap < String, Any >
```
自定义uniform表，key为uniform名，value为UniformValue对象

### var vertexShader
```cj
public var vertexShader: String
```
顶点着色器源码（bgfx .sc格式）

