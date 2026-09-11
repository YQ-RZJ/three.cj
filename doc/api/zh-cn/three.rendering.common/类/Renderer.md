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

### func getSize\(\)
```cj
public func getSize():(Int64, Int64)
```
获取逻辑渲染尺寸

返回: 

- (逻辑宽度, 逻辑高度)

### func init\(Backend,Bool,Bool,Bool,Bool,Int64,Bool,Bool\)
```cj
public init(backend: Backend, alpha!: Bool = true, depth!: Bool = true, stencil!: Bool = false, antialias!: Bool = false, samples!: Int64 = 0, logarithmicDepthBuffer!: Bool = false, reversedDepthBuffer!: Bool = false)
```
构造器，指定渲染后端和渲染选项

参数: 

|名称|类型|描述|
|---|---|---|
|backend|Backend|渲染后端实例alpha 是否启用透明，默认 truedepth 是否启用深度缓冲，默认 truestencil 是否启用模板缓冲，默认 falseantialias 是否启用抗锯齿，默认 falsesamples 采样数，0 表示自动，默认 0logarithmicDepthBuffer 是否启用对数深度缓冲，默认 falsereversedDepthBuffer 是否启用反转深度缓冲，默认 false|
|alpha|Bool||
|depth|Bool||
|stencil|Bool||
|antialias|Bool||
|samples|Int64||
|logarithmicDepthBuffer|Bool||
|reversedDepthBuffer|Bool||

### func init\(\)
```cj
public init()
```
默认无参构造器，向后兼容

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

### var backend
```cj
public var backend: Backend
```
渲染后端

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

