# 类
## class TexturePass
```cj
public class TexturePass <: Pass & IReleasable
```
贴纹理 pass

### func init\(EngineDataTexture,Float64\)
```cj
public init(map: EngineDataTexture, opacity!: Float64 = 1.0)
```
构造 TexturePass

参数: 

|名称|类型|描述|
|---|---|---|
|map|EngineDataTexture|待渲纹理（bgfx GfxTextureHandle）|
|opacity|Float64|不透明度（默认 1.0）|

### func release\(\)
```cj
public override func release(): Bool
```
释放 TexturePass 占用的 GPU 资源

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
执行纹理 pass：把 map 渲到 readBuffer 或屏幕

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|GfxFrameBufferHandle|写 buffer（本 pass 不用，结果写 readBuffer 或屏幕）|
|readBuffer|GfxFrameBufferHandle|读 buffer（renderToScreen=false 时写这里）|
|deltaTime|Float64|帧间隔|

### var map
```cj
public var map: EngineDataTexture
```
待渲纹理（bgfx GfxTextureHandle）

### var opacity
```cj
public var opacity: Float64 = 1.0
```
不透明度 [0,1]，默认 1.0（完全不透明）

