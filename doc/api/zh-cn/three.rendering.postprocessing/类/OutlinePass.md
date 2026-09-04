# 类
## class OutlinePass
```cj
public class OutlinePass <: Pass
```
Outline 后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 OutlinePass 占用的 GPU 资源（所有 RT + shader 缓存）。

### func init\(Vector2,Scene,Camera,ArrayList<Object3D>\)
```cj
public init(resolution: Vector2, scene: Scene, camera: Camera, selectedObjects: ArrayList < Object3D >)
```
构造 OutlinePass。

参数: 

|名称|类型|描述|
|---|---|---|
|resolution|Vector2|效果分辨率（Vector2）|
|scene|Scene|待渲染场景|
|camera|Camera|待渲染相机|
|selectedObjects|ArrayList<Object3D>|选中的 3D 物体（描边目标）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 Outline pass。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（本 pass 不用，结果写 readBuffer）|
|readBuffer|FrameBufferHandle|读 buffer（renderToScreen=false 时写这里）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸（重建所有 RT）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let OUTLINE\_VIEW\_ID\_BASE
```cj
public static let OUTLINE_VIEW_ID_BASE: UInt16 = 223u16
```
view id 基址（223，避开 SSAO 160/Bloom 200/ShaderPass 200~209/
SavePass 210/TexturePass 211/OutputPass 212/SMAA 214~216/
SSAA 217/TAA 219~220/MaskPass 220~221/CubeTexturePass 222 区段）。
OutlinePass 内部 7+ 个 pass，分配 223~239（17 个 view id 够用）。

### var downSampleRatio
```cj
public var downSampleRatio: Int64 = 2
```
降采样比例

### var edgeGlow
```cj
public var edgeGlow: Float64 = 0.0
```
边缘发光强度（动画 glow/pulse）

### var edgeStrength
```cj
public var edgeStrength: Float64 = 3.0
```
边缘强度

### var edgeThickness
```cj
public var edgeThickness: Float64 = 1.0
```
边缘厚度

### var hiddenEdgeColor
```cj
public var hiddenEdgeColor: Color = Color(0.1, 0.04, 0.02)
```
隐藏边颜色

### var patternTexture
```cj
public var patternTexture: Option < Texture >= None
```
图案纹理（需 usePatternTexture=true）

### var pulsePeriod
```cj
public var pulsePeriod: Float64 = 0.0
```
脉冲周期（动画 pulse）

### let renderCamera
```cj
public let renderCamera: Camera
```
待渲染相机

### let renderScene
```cj
public let renderScene: Scene
```
待渲染场景

### var resolution
```cj
public var resolution: Vector2 = Vector2(256.0, 256.0)
```
效果分辨率（Vector2）

### var selectedObjects
```cj
public var selectedObjects: ArrayList < Object3D >
```
选中的 3D 物体（描边目标）

### var usePatternTexture
```cj
public var usePatternTexture: Bool = false
```
是否使用图案纹理

### var visibleEdgeColor
```cj
public var visibleEdgeColor: Color = Color(1.0, 1.0, 1.0)
```
可见边颜色

