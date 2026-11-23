# Class
## class FXAAPass
```cj
public class FXAAPass <: ShaderPass
```
FXAA post-processing pass

### func bindExtraUniforms\(Renderer,IUniformRegistry\)
```cj
public override func bindExtraUniforms(renderer: Renderer, uniforms: IUniformRegistry): Unit
```
Binds the extra uniform before the parent render's submit: u_resolution.xy = 1/width, 1/height

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|The renderer|
|uniforms|IUniformRegistry|The uniform registry where the parent has created the tDiffuse sampler (reused instance)|

### func init\(\)
```cj
public init()
```
Constructs FXAAPass

