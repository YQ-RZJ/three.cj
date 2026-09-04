# Class
## class FXAAPass
```cj
public class FXAAPass <: ShaderPass
```
FXAA post-processing pass

### func bindExtraUniforms\(BgfxRenderer,BgfxUniforms\)
```cj
public override func bindExtraUniforms(renderer: BgfxRenderer, uniforms: BgfxUniforms): Unit
```
Binds the extra uniform before the parent render's submit: u_resolution.xy = 1/width, 1/height

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|The renderer|
|uniforms|BgfxUniforms|The uniform registry where the parent has created the tDiffuse sampler (reused instance)|

### func init\(\)
```cj
public init()
```
Constructs FXAAPass

