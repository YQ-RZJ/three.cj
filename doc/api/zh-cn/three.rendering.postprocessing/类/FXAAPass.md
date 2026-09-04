# 类
## class FXAAPass
```cj
public class FXAAPass <: ShaderPass
```
FXAA 后处理 pass

### func bindExtraUniforms\(BgfxRenderer,BgfxUniforms\)
```cj
public override func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit
```
在父类 render 的 submit 前绑定额外 uniform：u_resolution.xy = 1/width, 1/height

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|uniforms|BgfxUniforms|父类已创建 tDiffuse sampler 的 uniform 注册表（复用同一实例）|

### func init\(\)
```cj
public init()
```
构造 FXAAPass

