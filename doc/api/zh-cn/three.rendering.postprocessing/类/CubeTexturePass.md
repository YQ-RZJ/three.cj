# 类
## class CubeTexturePass
```cj
public class CubeTexturePass <: Pass
```
立方体贴图背景 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 CubeTexturePass 占用的 GPU 资源（cube mesh + shader 缓存）。

### func init\(Camera,CubeTexture,Float64\)
```cj
public init(camera: Camera, cubeTex: CubeTexture, opacity!: Float64 = 1.0)
```
构造 CubeTexturePass。

参数: 

|名称|类型|描述|
|---|---|---|
|camera|Camera|相机|
|cubeTex|CubeTexture|立方体贴图|
|opacity|Float64|不透明度（默认 1.0）|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行立方体贴图 pass：把 cubeTex 渲到 readBuffer 或屏幕。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|FrameBufferHandle|读 buffer（renderToScreen=false 时写这里）|
|deltaTime|Float64|帧间隔|

### let CUBE\_VIEW\_ID
```cj
public static let CUBE_VIEW_ID: UInt16 = 150u16
```
view id（150，避开 shadow 50~127/SSAO 160/ShaderPass 200~209/SavePass 210/
TexturePass 211/OutputPass 212/MaskPass 220~221/OutlinePass 223~239/SSRPass 240+）。

关键：bgfx 按 view id 升序渲染，CubeTexturePass 必须在 OutputPass（212）之前渲染，
否则 OutputPass 先上屏、cube 后渲进 readBuffer 无人上屏 → cube 背景不可见。
150 < 212 满足"RenderPass(view0) → CubeTexturePass(150) → OutputPass(212)"顺序。

### let camera
```cj
public let camera: Camera
```
相机（取投影/朝向）

### var cubeTex
```cj
public var cubeTex: CubeTexture
```
立方体贴图引用

### var opacity
```cj
public var opacity: Float64 = 1.0
```
不透明度 [0,1]

