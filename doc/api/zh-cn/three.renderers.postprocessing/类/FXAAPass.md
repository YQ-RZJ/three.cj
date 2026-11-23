# 类
## class FXAAPass
```cj
public class FXAAPass <: ShaderPass
```
FXAA 后处理 pass

### func bindExtraUniforms\(Renderer,IUniformRegistry\)
```cj
public override func bindExtraUniforms(renderer: Renderer, uniforms: IUniformRegistry): Unit
```
在父类 render 的 submit 前绑定额外 uniform：u_resolution.xy = 1/width, 1/height

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|uniforms|IUniformRegistry|父类已创建 tDiffuse sampler 的 uniform 注册表（复用同一实例）|

### func init\(\)
```cj
public init()
```
构造 FXAAPass

