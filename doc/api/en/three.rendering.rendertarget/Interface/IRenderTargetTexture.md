# Interface
## interface IRenderTargetTexture
```cj
public interface IRenderTargetTexture
```
Render target texture access interface

### func rtClone\(\)
```cj
func rtClone(): IRenderTargetTexture
```
Clone itself (returns IRenderTargetTexture)

### func rtIsData3DTexture\(\)
```cj
func rtIsData3DTexture(): Bool
```
Whether this is a 3D data texture

### prop rtDepth: Int64
```cj
mut prop rtDepth: Int64
```
Texture depth (for 3D textures)

### prop rtHeight: Int64
```cj
mut prop rtHeight: Int64
```
Texture height in pixels

### prop rtIsArrayTexture: Bool
```cj
mut prop rtIsArrayTexture: Bool
```
Whether this is an array texture

### prop rtIsRenderTargetTexture: Bool
```cj
mut prop rtIsRenderTargetTexture: Bool
```
Whether this is a render target texture

### prop rtRenderTarget:?RenderTarget
```cj
mut prop rtRenderTarget:?RenderTarget
```
Render target back reference (core package type, same-package direct reference to avoid Any)

### prop rtWidth: Int64
```cj
mut prop rtWidth: Int64
```
Texture width in pixels

