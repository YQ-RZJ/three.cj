# 类
## class TexturePass
```cj
public class TexturePass <: Pass
```
贴纹理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 TexturePass 占用的 GPU 资源

### func init\(TextureHandle,Float64\)
```cj
public init(map: TextureHandle, opacity!: Float64 = 1.0)
```
构造 TexturePass

参数: 

|名称|类型|描述|
|---|---|---|
|map|TextureHandle|待渲纹理（bgfx TextureHandle）|
|opacity|Float64|不透明度（默认 1.0）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行纹理 pass：把 map 渲到 readBuffer 或屏幕

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用，结果写 readBuffer 或屏幕）|
|readBuffer|FrameBufferHandle|读 buffer（renderToScreen=false 时写这里）|
|deltaTime|Float64|帧间隔|

### var map
```cj
public var map: TextureHandle
```
待渲纹理（bgfx TextureHandle）

### var opacity
```cj
public var opacity: Float64 = 1.0
```
不透明度 [0,1]，默认 1.0（完全不透明）

