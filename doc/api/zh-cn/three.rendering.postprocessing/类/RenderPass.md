# 类
## class RenderPass
```cj
public class RenderPass <: Pass
```
场景渲染 pass

### func init\(Scene,Camera\)
```cj
public init(scene: Scene, camera: Camera)
```
构造 RenderPass

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景|
|camera|Camera|相机|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
渲染场景到 readBuffer

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用）|
|readBuffer|FrameBufferHandle|读 buffer（本 pass 的渲染目标）|
|deltaTime|Float64|帧间隔|

### let camera
```cj
public let camera: Camera
```
待渲染相机

### var clearAlpha
```cj
public var clearAlpha: Option < Float64 >= None
```
clear alpha（可选）

### var clearColor
```cj
public var clearColor: Option < UInt32 >= None
```
clear color（可选）

### var clearDepth
```cj
public var clearDepth: Bool = false
```
是否清深度

### var overrideMaterial
```cj
public var overrideMaterial: Option < Material >= Option < Material >.None
```
override material（可选）

### let scene
```cj
public let scene: Scene
```
待渲染场景

