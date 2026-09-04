# Interface
## interface IRenderer
```cj
public interface IRenderer
```
Renderer interface: renderer parameter type for CubeCamera.update, declaring render target switching methods

### func getRenderTarget\(\)
```cj
func getRenderTarget(): Option < IRenderTarget >
```
Gets the current render target

Return: 

- Current render target (None for default framebuffer)

### func setRenderTarget\(IRenderTarget,Int64,Int64\)
```cj
func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit
```
Sets the render target (CubeCamera 6-face rendering: cubeFace 0~5 + mipLevel)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderTarget|IRenderTarget|Render targetcubeFace Cube face index (0~5)mipLevel Mipmap level|
|cubeFace|Int64||
|mipLevel|Int64||

