# 类
## class Backend
```cj
public open class Backend
```
渲染后端抽象基类

### func beginCompute\(ComputePipeline\)
```cj
public open func beginCompute(computeContext: ComputePipeline): Unit
```
开始 compute pass

参数: 

|名称|类型|描述|
|---|---|---|
|computeContext|ComputePipeline|计算管线|

### func beginRender\(IRenderContext\)
```cj
public open func beginRender(renderContext: IRenderContext): Unit
```
开始渲染 pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|IRenderContext|渲染上下文|

### func beginRender\(RenderContext\)
```cj
public open func beginRender(renderContext: RenderContext): Unit
```
beginRender 重载，接受 RenderContext 具体类

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|RenderContext|渲染上下文|

### func bindShadowUniforms\(\)
```cj
public open func bindShadowUniforms(): Unit
```
绑定阴影 uniform 到主 pass draw，基类默认抛异常

### func blitShadowMap\(UInt16\)
```cj
public open func blitShadowMap(mainViewId: UInt16): Unit
```
全屏 blit 阴影贴图到屏幕（debug 模式用），基类默认抛异常

参数: 

|名称|类型|描述|
|---|---|---|
|mainViewId|UInt16|主渲染 view ID（blit 输出目标）|

### func blit\(Texture,Texture,UInt16\)
```cj
public open func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit
```
Blit 操作，从源纹理复制到目标纹理

参数: 

|名称|类型|描述|
|---|---|---|
|textureSrc|Texture|源纹理textureDst 目标纹理viewId view ID|
|textureDst|Texture||
|viewId|UInt16||

### func clear\(IRenderContext,Bool,Bool,Bool\)
```cj
public open func clear(renderContext: IRenderContext, color: Bool, depth: Bool, stencil: Bool): Unit
```
清除缓冲

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|IRenderContext|渲染上下文color 是否清除颜色缓冲depth 是否清除深度缓冲stencil 是否清除模板缓冲|
|color|Bool||
|depth|Bool||
|stencil|Bool||

### func clear\(RenderContext,Bool,Bool,Bool\)
```cj
public open func clear(renderContext: RenderContext, color: Bool, depth: Bool, stencil: Bool): Unit
```
clear 重载，接受 RenderContext 具体类

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|RenderContext|渲染上下文color 是否清除颜色缓冲depth 是否清除深度缓冲stencil 是否清除模板缓冲|
|color|Bool||
|depth|Bool||
|stencil|Bool||

### func clear\(\)
```cj
public open func clear(): Unit
```
clear 无参数版本（旧版兼容）

### func compute\(ComputePipeline\)
```cj
public open func compute(computeNode: ComputePipeline): Unit
```
执行 compute dispatch

参数: 

|名称|类型|描述|
|---|---|---|
|computeNode|ComputePipeline|计算节点|

### func copyTo\(Texture,Texture\)
```cj
public open func copyTo(textureSrc: Texture, textureDst: Texture): Unit
```
拷贝纹理

参数: 

|名称|类型|描述|
|---|---|---|
|textureSrc|Texture|源纹理textureDst 目标纹理|
|textureDst|Texture||

### func createBindings\(Bindings\)
```cj
public open func createBindings(bindings: Bindings): Unit
```
创建绑定

参数: 

|名称|类型|描述|
|---|---|---|
|bindings|Bindings|绑定对象|

### func createPipeline\(IRenderObject\)
```cj
public open func createPipeline(renderObject: IRenderObject): ComputePipeline
```
创建管线

参数: 

|名称|类型|描述|
|---|---|---|
|renderObject|IRenderObject|渲染对象|

返回: 

- 计算管线实例

### func createProgram\(ProgrammableStage\)
```cj
public open func createProgram(program: ProgrammableStage): Unit
```
创建程序

参数: 

|名称|类型|描述|
|---|---|---|
|program|ProgrammableStage|可编程阶段|

### func createSampler\(Sampler\)
```cj
public open func createSampler(sampler: Sampler): Unit
```
创建采样器

参数: 

|名称|类型|描述|
|---|---|---|
|sampler|Sampler|采样器|

### func createTexture\(Texture\)
```cj
public open func createTexture(texture: Texture): Unit
```
创建纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理|

### func destroyTexture\(Texture\)
```cj
public open func destroyTexture(texture: Texture): Unit
```
销毁纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理|

### func destroy\(\)
```cj
public open func destroy(): Unit
```
destroy 是 dispose 的别名（旧版兼容）

### func dispose\(\)
```cj
public open func dispose(): Unit
```
销毁后端，释放资源

### func draw\(IRenderObject\)
```cj
public open func draw(renderObject: IRenderObject): Unit
```
执行 draw 调用

参数: 

|名称|类型|描述|
|---|---|---|
|renderObject|IRenderObject|渲染对象|

### func draw\(BufferGeometry,Material\)
```cj
public open func draw(geometry: BufferGeometry, material: Material): Unit
```
draw 旧版兼容（geometry + material）

参数: 

|名称|类型|描述|
|---|---|---|
|geometry|BufferGeometry|缓冲几何体material 材质|
|material|Material||

### func finishCompute\(ComputePipeline\)
```cj
public open func finishCompute(computeContext: ComputePipeline): Unit
```
结束 compute pass

参数: 

|名称|类型|描述|
|---|---|---|
|computeContext|ComputePipeline|计算管线|

### func finishRender\(IRenderContext\)
```cj
public open func finishRender(renderContext: IRenderContext): Unit
```
结束渲染 pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|IRenderContext|渲染上下文|

### func finishRender\(RenderContext\)
```cj
public open func finishRender(renderContext: RenderContext): Unit
```
finishRender 重载，接受 RenderContext 具体类

参数: 

|名称|类型|描述|
|---|---|---|
|renderContext|RenderContext|渲染上下文|

### func generateMipmaps\(Texture\)
```cj
public open func generateMipmaps(texture: Texture): Unit
```
生成 mipmap

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理|

### func getMaxAnisotropy\(\)
```cj
public open func getMaxAnisotropy(): Int64
```
获取最大各向异性

返回: 

- 最大各向异性值

### func getMaxTextureSize\(\)
```cj
public open func getMaxTextureSize(): Int64
```
获取最大纹理尺寸

返回: 

- 最大纹理尺寸

### func hasFeature\(String\)
```cj
public open func hasFeature(name: String): Bool
```
查询是否支持指定特性

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|特性名称|

返回: 

- 是否支持

### func init\(\)
```cj
public init()
```


### func initialize\(Renderer\)
```cj
public open func initialize(renderer: Renderer): Unit
```
初始化渲染后端

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器实例|

### func prepareShadowMap\(Scene\)
```cj
public open func prepareShadowMap(scene: Scene): Unit
```
阴影深度预 pass 钩子，基类默认抛异常，子类 override 实现具体阴影深度 pass

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene|渲染场景（含光源与 caster 几何体）|

### func resolveRenderTarget\(RenderTarget\)
```cj
public open func resolveRenderTarget(renderTarget: RenderTarget): Unit
```
解析渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|renderTarget|RenderTarget|渲染目标|

### func setClearColor\(UInt32\)
```cj
public open func setClearColor(color: UInt32): Unit
```
设置清除颜色

参数: 

|名称|类型|描述|
|---|---|---|
|color|UInt32|清除颜色（UInt32 RGBA）|

### func setScissor\(Int32,Int32,Int32,Int32\)
```cj
public open func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
设置裁剪区域

参数: 

|名称|类型|描述|
|---|---|---|
|x|Int32|裁剪区域 X 坐标y 裁剪区域 Y 坐标w 裁剪区域宽度h 裁剪区域高度|
|y|Int32||
|w|Int32||
|h|Int32||

### func setViewport\(Int32,Int32,Int32,Int32\)
```cj
public open func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
设置视口

参数: 

|名称|类型|描述|
|---|---|---|
|x|Int32|视口 X 坐标y 视口 Y 坐标w 视口宽度h 视口高度|
|y|Int32||
|w|Int32||
|h|Int32||

### func updateTexture\(Texture\)
```cj
public open func updateTexture(texture: Texture): Unit
```
更新纹理

参数: 

|名称|类型|描述|
|---|---|---|
|texture|Texture|纹理|

### var clearColor
```cj
public var clearColor: UInt32 = 0x00000000u32
```
清除色（UInt32 RGBA）

### var coordinateSystem
```cj
public var coordinateSystem: Int64 = 2000
```
坐标系统（默认 2000 = WebGPUCoordinateSystem）

### var hwnd
```cj
public var hwnd: Option < UIntNative >= None
```
平台窗口句柄

### var initialized
```cj
public var initialized: Bool = false
```
是否已初始化

### var kind
```cj
public var kind: String
```
后端类型标识（"WebGL"/"WebGPU"/"bgfx"）

### var renderer
```cj
public var renderer: Option < Renderer >= None
```
渲染器引用

