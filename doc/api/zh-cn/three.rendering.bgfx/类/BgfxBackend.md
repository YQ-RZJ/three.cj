# 类
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

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
|---|---|---|
|mainViewId|UInt16||

### func blit\(Texture,Texture,UInt16\)
```cj
public override func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit
```
Blit 操作

用全屏 quad 触发 bgfx_submit_cj。

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
|---|---|---|
|renderObject|IRenderObject||

### func draw\(BufferGeometry,Material\)
```cj
public override func draw(geometry: BufferGeometry, material: Material): Unit
```
draw：旧版兼容

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
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


参数: 

|名称|类型|描述|
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
初始化 bgfx 后端

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器实例|

### func makeBlendFunc\(UInt64,UInt64\)
```cj
public static func makeBlendFunc(srcFactor: UInt64, dstFactor: UInt64): UInt64
```


参数: 

|名称|类型|描述|
|---|---|---|
|srcFactor|UInt64|源因子（STATE_BLEND_* 常量，已 <<12）|
|dstFactor|UInt64|目标因子（STATE_BLEND_* 常量，已 <<12）|

返回: 

- 完整的 blend state 值makeBlendFunc：构建 bgfx blend state对照 bgfx defines.h:BGFX_STATE_BLEND_FUNC_SEPARATE(srcRGB, dstRGB, srcA, dstA) =((srcRGB | (dstRGB << 4))) | (((srcA | (dstA << 4))) << 8)BGFX_STATE_BLEND_FUNC(src, dst) = FUNC_SEPARATE(src, dst, src, dst)BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA=0x5000, INV_SRC_ALPHA=0x6000) = 0x6565000注意：不能直接 OR 三个 BLEND_* 常量 —— 那会把 src/dst factor 合并成单一 factor（0x7000），导致 alpha blend 完全失效（渲染为不透明）。

### func prepareShadowMap\(Scene\)
```cj
public override func prepareShadowMap(scene: Scene): Unit
```
阴影深度预 pass：收集场景中 castShadow 的方向光，渲染深度到阴影 framebuffer。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||

### func setClearColor\(UInt32\)
```cj
public override func setClearColor(color: UInt32): Unit
```


参数: 

|名称|类型|描述|
|---|---|---|
|color|UInt32||

### func setScissor\(Int32,Int32,Int32,Int32\)
```cj
public override func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```


参数: 

|名称|类型|描述|
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

参数: 

|名称|类型|描述|
|---|---|---|
|value|Int64||

### func setViewport\(Int32,Int32,Int32,Int32\)
```cj
public override func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit
```
===== 视口/裁剪/清除颜色 =====

参数: 

|名称|类型|描述|
|---|---|---|
|x|Int32||
|y|Int32||
|w|Int32||
|h|Int32||

### var maxDirLights
```cj
public var maxDirLights: Int64 = 4
```
方向光数量上限（含无阴影的）

### var maxDirShadows
```cj
public var maxDirShadows: Int64 = 4
```
带阴影的方向光数量上限

### var maxHemiLights
```cj
public var maxHemiLights: Int64 = 4
```
半球光数量上限

### var maxPointLights
```cj
public var maxPointLights: Int64 = 4
```
点光源数量上限（含无阴影的）

### var maxPointShadows
```cj
public var maxPointShadows: Int64 = 2
```
带阴影的点光源数量上限（cube 阴影，每个占 1 个纹理单元）

### var maxSpotLights
```cj
public var maxSpotLights: Int64 = 4
```
聚光灯数量上限（含无阴影的）

### var maxSpotShadows
```cj
public var maxSpotShadows: Int64 = 2
```
带阴影的聚光灯数量上限

