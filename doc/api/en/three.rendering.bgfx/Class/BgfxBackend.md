# Class
## class BgfxBackend
```cj
public class BgfxBackend <: Backend
```


### func beginRender\(IRenderContext\)
```cj
public override func beginRender(renderContext: IRenderContext): Unit
```
开始渲染 pass

执行：
- bgfx_set_view_rect_cj （视口）
- bgfx_set_view_clear_cj （清除标志 + 颜色）
- bgfx_set_view_frame_buffer_cj （FBO，若有）
- setViewTransform （投影+视图矩阵）

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext||

### func beginRender\(RenderContext\)
```cj
public override func beginRender(renderContext: RenderContext): Unit
```
beginRender：重载接受 RenderContext 具体类
注意：必须设置 view transform（相机矩阵），否则 bgfx 无视角变换画面全黑

顺序：
1. bgfx_set_view_rect_cj —— 视口（用 renderContext.viewport）
2. bgfx_set_view_clear_cj —— 清除色 + 深度（用 BgfxRenderer.clearColor）
3. _setViewTransform —— view + proj 矩阵（从 renderContext 读取，_render 中已填充）

不调用 bgfx_touch_cj：touch 会重置 view 状态，导致后续 submit 失效（全黑）。
bgfx 中 submit 已标记 view 活跃，frame 触发双缓冲交换。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext||

### func bindShadowUniforms\(\)
```cj
public override func bindShadowUniforms(): Unit
```
绑定阴影 uniform 到主 pass draw。

### func blitShadowMap\(UInt16\)
```cj
public override func blitShadowMap(mainViewId: UInt16): Unit
```
全屏 blit 阴影贴图到屏幕（debug mode 6 用）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mainViewId|UInt16||

### func blit\(Texture,Texture,UInt16\)
```cj
public override func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit
```
Blit 操作

用全屏 quad 触发 bgfx_submit_cj。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|textureSrc|Texture||
|textureDst|Texture||
|viewId|UInt16||

### func clear\(IRenderContext,Bool,Bool,Bool\)
```cj
public override func clear(renderContext: IRenderContext, color: Bool, depth: Bool, stencil: Bool): Unit
```
清除缓冲

执行 bgfx_set_view_clear_cj。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext||
|color|Bool||
|depth|Bool||
|stencil|Bool||

### func clear\(\)
```cj
public override func clear(): Unit
```
clear：无参数版本

### func destroy\(\)
```cj
public override func destroy(): Unit
```
destroy：dispose 别名

### func dispose\(\)
```cj
public override func dispose(): Unit
```
销毁后端

执行 bgfx_shutdown_cj。

### func draw\(IRenderObject\)
```cj
public override func draw(renderObject: IRenderObject): Unit
```
执行 draw 调用（IRenderObject 版本）

完整 5 步流程：
1. bgfx_set_transform_cj —— transform matrix（via BgfxMemory）
2. bgfx_set_vertex_buffer_with_layout_cj —— vertex buffer（从几何体创建）
3. bgfx_set_index_buffer_cj —— index buffer（若有）
4. bgfx_set_state_cj —— render state
5. bgfx_submit_cj —— submit with program handle from material

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderObject|IRenderObject||

### func draw\(BufferGeometry,Material\)
```cj
public override func draw(geometry: BufferGeometry, material: Material): Unit
```
draw：旧版兼容

Parameter: 

|Name|Type|Describe|
|---|---|---|
|geometry|BufferGeometry||
|material|Material||

### func finishRender\(IRenderContext\)
```cj
public override func finishRender(renderContext: IRenderContext): Unit
```
结束渲染 pass

执行 bgfx_touch_cj 标记 view 活跃 + bgfx_frame_cj 触发双缓冲交换
（注意：bgfx_frame_cj 必须在每次渲染循环中调用，否则画面不更新）

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|IRenderContext||

### func finishRender\(RenderContext\)
```cj
public override func finishRender(renderContext: RenderContext): Unit
```
finishRender：重载接受 RenderContext 具体类

触发 view 活跃标记 + bgfx_frame 双缓冲交换。
bgfx 中 view 只有被 touch/submit 时才渲染
（含 clear + draw）。缺 touch 时 view0 的 clear 从未执行 → backbuffer 未清除，
显示 swap chain 初始内容（灰）。此 touch 在 submit 之后调用，不会使已提交的
draw call 失效（此前"touch 导致全黑"的注释为误判，实际为缺 touch 导致全灰）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderContext|RenderContext||

### func getCoordinateSystem\(\)
```cj
public func getCoordinateSystem(): Int64
```
坐标系统 getter
返回 WebGPUCoordinateSystem（2001，左手系）

### func getMaxAnisotropy\(\)
```cj
public override func getMaxAnisotropy(): Int64
```


### func getMaxTextureSize\(\)
```cj
public override func getMaxTextureSize(): Int64
```
===== 能力查询 =====

### func hasFeature\(String\)
```cj
public override func hasFeature(name: String): Bool
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|name|String||

### func init\(\)
```cj
public init()
```


### func initialize\(Renderer\)
```cj
public override func initialize(renderer: Renderer): Unit
```
Initialize bgfx backend

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|Renderer|Renderer instance|

### func makeBlendFunc\(UInt64,UInt64\)
```cj
public static func makeBlendFunc(srcFactor: UInt64, dstFactor: UInt64): UInt64
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|srcFactor|UInt64|Source factor (STATE_BLEND_* constant, already <<12)|
|dstFactor|UInt64|Destination factor (STATE_BLEND_* constant, already <<12)|

Return: 

- Complete blend state value

### func prepareShadowMap\(Scene\)
```cj
public override func prepareShadowMap(scene: Scene): Unit
```
阴影深度预 pass：收集场景中 castShadow 的方向光，渲染深度到阴影 framebuffer。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene||

### func setClearColor\(UInt32\)
```cj
public override func setClearColor(color: UInt32): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|color|UInt32||

### func setScissor\(Int32,Int32,Int32,Int32\)
```cj
public override func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int32||
|y|Int32||
|w|Int32||
|h|Int32||

### func setShadowType\(Int64\)
```cj
public func setShadowType(value: Int64): Unit
```
转调阴影类型设置到内部 BgfxShadowMap 实例。
对照 BgfxShadowMap.setShadowType：记录类型变更（触发后续重建阴影贴图和材质重编译）。
sp_vsm 等测试通过 renderer.setShadowType(VSM_SHADOW_MAP) 切换为 VSM 模式。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|value|Int64||

### func setViewport\(Int32,Int32,Int32,Int32\)
```cj
public override func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
===== 视口/裁剪/清除颜色 =====

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Int32||
|y|Int32||
|w|Int32||
|h|Int32||

### var maxDirLights
```cj
public var maxDirLights: Int64 = 4
```
Max directional lights (including non-shadowed)

### var maxDirShadows
```cj
public var maxDirShadows: Int64 = 4
```
Max directional shadow lights

### var maxHemiLights
```cj
public var maxHemiLights: Int64 = 4
```
Max hemisphere lights

### var maxPointLights
```cj
public var maxPointLights: Int64 = 4
```
Max point lights (including non-shadowed)

### var maxPointShadows
```cj
public var maxPointShadows: Int64 = 2
```
Max point shadow lights (cube shadow, each occupies 1 texture unit)

### var maxSpotLights
```cj
public var maxSpotLights: Int64 = 4
```
Max spot lights (including non-shadowed)

### var maxSpotShadows
```cj
public var maxSpotShadows: Int64 = 2
```
Max spot shadow lights

