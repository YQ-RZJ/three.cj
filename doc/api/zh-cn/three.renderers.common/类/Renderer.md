# 类
## class Renderer
```cj
public open class Renderer
```
渲染器抽象基类

### func \_collectRenderObjects\(Object3D,RenderList,Camera\)
```cj
public open func _collectRenderObjects(obj: Object3D, renderList: RenderList, camera: Camera): Unit
```
递归收集场景中的渲染对象

参数: 

|名称|类型|描述|
|---|---|---|
|obj|Object3D|当前遍历的节点renderList 渲染列表camera 相机|
|renderList|RenderList||
|camera|Camera||

### func \_fillRenderContext\(RenderContext\)
```cj
public open func _fillRenderContext(renderContext: RenderContext): Unit
```
子类钩子，填充子类专有的 RenderContext 字段

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|RenderContext|待填充的渲染上下文|

### func \_render\(Scene,Camera\)
```cj
public open func _render(scene: Scene, camera: Camera): Unit
```
渲染调度主流程，编排完整的渲染管线

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景camera 相机|
|camera|Camera||

### func getPixelRatio\(\)
```cj
public func getPixelRatio(): Float64
```
获取当前像素比

返回: 

- 像素比

### func getRenderViewId\(\)
```cj
public open func getRenderViewId(): UInt16
```
获取当前渲染使用的 bgfx view id

返回: 

- bgfx view id

### func getSceneMeshes\(Object3D,Bool\)
```cj
public func getSceneMeshes(scene: Object3D, visibleOnly!: Bool = false): ArrayList < RenderObject >
```
获取本帧场景中的 Mesh 渲染对象列表（帧级共享缓存）

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Object3D|场景根节点visibleOnly 是否只返回可见对象（SSR 等 pass 需要跳过不可见对象防止自反射）|
|visibleOnly|Bool||

返回: 

- Mesh 渲染对象列表（内部引用，调用方只读）

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
获取逻辑渲染尺寸

返回: 

- (逻辑宽度, 逻辑高度)

### func gfxBackend\(\)
```cj
public func gfxBackend(): IRenderBackend
```
返回渲染后端（GPU API 资源通道，供 EngineRenderTarget/EngineDataTexture 等资源对象构造时使用）

返回: 

- 渲染后端实例（IRenderBackend 契约）

### func init\(\)
```cj
public init()
```
默认无参构造器（空后端占位，向后兼容）

### func renderPass\(Scene,Camera,Bool,Option<UInt16>,Option<\(Int32,Int32,Int32,Int32\)>,Option<UInt32>\)
```cj
public func renderPass(scene: Scene, camera: Camera, present!: Bool = false, viewId!: Option < UInt16 >= None, viewport!: Option <(Int32, Int32, Int32, Int32) >= None, clearColor!: Option < UInt32 >= None): Unit
```
渲染单个 pass（供后处理离屏渲染调用，不触发上屏，支持指定 viewId/viewport/clearColor）

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||
|camera|Camera||
|present|Bool||
|viewId|Option<UInt16>||
|viewport|Option<(Int32,Int32,Int32,Int32)>||
|clearColor|Option<UInt32>||

### func render\(Scene,Camera\)
```cj
public open func render(scene: Scene, camera: Camera): Unit
```
渲染入口，更新场景变换矩阵后执行渲染

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|场景camera 相机|
|camera|Camera||

### func setPixelRatio\(Float64\)
```cj
public func setPixelRatio(value: Float64): Unit
```
设置像素比

参数: 

|名称|类型|描述|
|---|---|---|
|value|Float64|新的像素比（必须 > 0）|

### func setSize\(Int64,Int64\)
```cj
public func setSize(w: Int64, h: Int64): Unit
```
设置渲染尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|w|Int64|渲染逻辑宽度h 渲染逻辑高度|
|h|Int64||

### var alpha
```cj
public var alpha: Bool = true
```
是否启用透明

### var autoClearColor
```cj
public var autoClearColor: Bool = true
```
是否自动清除颜色缓冲

### var autoClearDepth
```cj
public var autoClearDepth: Bool = true
```
是否自动清除深度缓冲

### var autoClearStencil
```cj
public var autoClearStencil: Bool = true
```
是否自动清除模板缓冲

### var autoClear
```cj
public var autoClear: Bool = true
```
是否自动清除帧缓冲

### var background
```cj
public var background: Background = Background()
```
背景渲染器

### var depth
```cj
public var depth: Bool = true
```
是否启用深度缓冲

### var enableSpatialCulling
```cj
public var enableSpatialCulling: Bool = true
```
是否启用空间剔除（BVH 加速）

### var frameIndex
```cj
public var frameIndex: Int64 = 0
```
帧序号（每次 render() 自增）

### var height
```cj
public var height: Int64 = 600
```
渲染高度（物理像素 / 后备缓冲高度）

### var info
```cj
public var info: Info = Info()
```
渲染统计信息

### var lighting
```cj
public var lighting: Lighting = Lighting()
```
光照管理器

### var logarithmicDepthBuffer
```cj
public var logarithmicDepthBuffer: Bool = false
```
是否启用对数深度缓冲

### var outputColorSpace
```cj
public var outputColorSpace: String = "srgb"
```
输出颜色空间

### var pixelRatio
```cj
public var pixelRatio: Float64 = 1.0
```
像素比

### var renderBundles
```cj
public var renderBundles: RenderBundles = RenderBundles()
```
渲染包管理器

### var renderContexts
```cj
public var renderContexts: RenderContexts
```
渲染上下文缓存

### var renderLists
```cj
public var renderLists: RenderLists
```
渲染列表缓存

### var renderObjects
```cj
public var renderObjects: RenderObjects
```
渲染对象缓存

### var reversedDepthBuffer
```cj
public var reversedDepthBuffer: Bool = false
```
是否启用反转深度缓冲

### var samples
```cj
public var samples: Int64 = 0
```
采样数（MSAA）

### var sortObjects
```cj
public var sortObjects: Bool = true
```
是否自动排序渲染对象

### var stencil
```cj
public var stencil: Bool = false
```
是否启用模板缓冲

### var toneMappingExposure
```cj
public var toneMappingExposure: Float64 = 1.0
```
色调映射曝光度

### var toneMapping
```cj
public var toneMapping: Int64 = 0
```
色调映射模式

### var width
```cj
public var width: Int64 = 800
```
渲染宽度（物理像素 / 后备缓冲宽度）

