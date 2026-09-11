# 类
## class MaskPass
```cj
public open class MaskPass <: Pass
```
遮罩 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 MaskPass 占用的 GPU 资源（几何缓存 + shader 缓存）。

### func init\(Scene,Camera\)
```cj
public init(scene: Scene, camera: Camera)
```
构造 MaskPass。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景|
|camera|Camera|相机|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行遮罩 pass：把场景几何体写入 stencil buffer。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（与 readBuffer 两侧都打 stencil 标记）|
|readBuffer|FrameBufferHandle|读 buffer|
|deltaTime|Float64|帧间隔|

### let MASK\_VIEW\_ID\_BASE
```cj
public static let MASK_VIEW_ID_BASE: UInt16 = 220u16
```
view id 基址（220~221，避开 SSAO 160/Bloom 200/ShaderPass 200~209/SavePass 210/
TexturePass 211/OutputPass 212/SMAA 214~216/SSAA 217/TAA 219~220 区段）。
+0 = readBuffer view，+1 = writeBuffer view。

### let camera
```cj
public let camera: Camera
```
待渲染相机

### var inverse
```cj
public var inverse: Bool = false
```
是否反转遮罩

### let scene
```cj
public let scene: Scene
```
待渲染场景（定义遮罩几何）

