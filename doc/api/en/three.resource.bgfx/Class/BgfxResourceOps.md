# Class
## class BgfxResourceOps
```cj
public class BgfxResourceOps
```
Wrapper class for bgfx low-level resource operations

### func createFrameBuffer\(UInt8,Array<TextureHandle>,Bool\)
```cj
public func createFrameBuffer(numAttachments: UInt8, handles: Array < TextureHandle >, destroyHandles: Bool): FrameBufferHandle
```
Create a frame buffer from multiple texture handles

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numAttachments|UInt8|Number of attachmentshandles Array of attachment texture handlesdestroyHandles Whether bgfx automatically destroys these texture handles when the FB is destroyed|
|handles|Array<TextureHandle>||
|destroyHandles|Bool||

Return: 

- Frame buffer handle由多个纹理句柄创建 frame buffer（attachments 顺序对应 attachment 索引）。

### func createTexture2D\(UInt16,UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
Create a 2D texture

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|UInt16|Texture width in pixelsh Texture height in pixelshasMips Whether to generate mipmapsnumLayers Number of layers (1 for regular 2D texture)format Texture format (e.g., TextureFormat.RGBA16F.value())flags Texture flags (e.g., TEXTURE_RT | SAMPLER_U_CLAMP | SAMPLER_V_CLAMP)mem Texture data memory (None for empty RT; Some for data)|
|h|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

Return: 

- Texture handle创建 2D 纹理。

### func destroyFrameBuffer\(FrameBufferHandle\)
```cj
public func destroyFrameBuffer(fb: FrameBufferHandle): Unit
```
Destroy a frame buffer handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fb|FrameBufferHandle|Frame buffer handle to destroy销毁 frame buffer 句柄。|

### func destroyTexture\(TextureHandle\)
```cj
public func destroyTexture(tex: TextureHandle): Unit
```
Destroy a texture handle

Parameter: 

|Name|Type|Describe|
|---|---|---|
|tex|TextureHandle|Texture handle to destroy销毁纹理句柄。|

### func init\(\)
```cj
public init()
```


