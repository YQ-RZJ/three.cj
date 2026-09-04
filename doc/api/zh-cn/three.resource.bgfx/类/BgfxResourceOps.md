# 类
## class BgfxResourceOps
```cj
public class BgfxResourceOps
```
bgfx 底层资源操作封装类

### func createFrameBuffer\(UInt8,Array<TextureHandle>,Bool\)
```cj
public func createFrameBuffer(numAttachments: UInt8, handles: Array < TextureHandle >, destroyHandles: Bool): FrameBufferHandle
```
由多个纹理句柄创建帧缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|numAttachments|UInt8|attachment 数量handles attachments 纹理句柄数组destroyHandles bgfx 销毁 FB 时是否自动销毁这些 texture 句柄|
|handles|Array<TextureHandle>||
|destroyHandles|Bool||

返回: 

- frame buffer 句柄

### func createTexture2D\(UInt16,UInt16,Bool,UInt16,UInt32,UInt64,Option<BgfxMemory>\)
```cj
public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: UInt32, flags: UInt64, mem: Option < BgfxMemory >): TextureHandle
```
创建 2D 纹理

参数: 

|名称|类型|描述|
|---|---|---|
|w|UInt16|纹理宽（像素）h 纹理高（像素）hasMips 是否生成 mipmapnumLayers 图层数（1=普通 2D 纹理）format 纹理格式（TextureFormat.RGBA16F.value() 等）flags 纹理 flags（TEXTURE_RT | SAMPLER_U_CLAMP | SAMPLER_V_CLAMP 等）mem 纹理数据内存（None 表示空 RT；Some 表示有数据）|
|h|UInt16||
|hasMips|Bool||
|numLayers|UInt16||
|format|UInt32||
|flags|UInt64||
|mem|Option<BgfxMemory>||

返回: 

- 纹理句柄

### func destroyFrameBuffer\(FrameBufferHandle\)
```cj
public func destroyFrameBuffer(fb: FrameBufferHandle): Unit
```
销毁帧缓冲句柄

参数: 

|名称|类型|描述|
|---|---|---|
|fb|FrameBufferHandle|待销毁 frame buffer 句柄|

### func destroyTexture\(TextureHandle\)
```cj
public func destroyTexture(tex: TextureHandle): Unit
```
销毁纹理句柄

参数: 

|名称|类型|描述|
|---|---|---|
|tex|TextureHandle|待销毁纹理句柄|

### func init\(\)
```cj
public init()
```


