# 类
## class Pass
```cj
public open class Pass <: IReleasable
```
后处理 pass 抽象基类

### func \_cachedUniform\(String,GfxUniformType,UInt16\)
```cj
public func _cachedUniform(name: String, uniformType: GfxUniformType, num!: UInt16 = 1u16): GfxUniformHandle
```
按名取 uniform 句柄（首次创建后缓存，本 pass 私有）

参数: 

|名称|类型|描述|
|---|---|---|
|name|String|uniform 名称|
|uniformType|GfxUniformType|uniform 类型|
|num|UInt16|数组长度（非数组传 1）|

返回: 

- 缓存的 uniform 句柄

### func \_disposePassUniforms\(\)
```cj
public func _disposePassUniforms(): Unit
```
释放本 pass 私有的 uniform 缓存与句柄缓存

### func \_passUniforms\(\)
```cj
public func _passUniforms(): IUniformRegistry
```
取本 pass 私有的 uniform 缓存（首次调用时创建）

返回: 

- 本 pass 私有的 uniform 注册表实例

### func \_setScalarUniform\(Renderer,GfxUniformHandle,Int64,Float64\)
```cj
public func _setScalarUniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, value: Float64): Unit
```
把单个标量写入槽位 slot 的 vec4 缓冲并提交（x=value, y/z/w=0）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|handle|GfxUniformHandle|uniform 句柄|
|slot|Int64|槽位编号|
|value|Float64|标量值（写入 x 分量）|

### func \_setVec2Uniform\(Renderer,GfxUniformHandle,Int64,Float64,Float64\)
```cj
public func _setVec2Uniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, x: Float64, y: Float64): Unit
```
把两个标量写入槽位 slot 的 vec4 缓冲并提交（x=x, y=y, z/w=0）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|handle|GfxUniformHandle|uniform 句柄|
|slot|Int64|槽位编号|
|x|Float64|写入 x 分量的值|
|y|Float64|写入 y 分量的值|

### func \_setVec4Uniform\(Renderer,GfxUniformHandle,Int64,Float64,Float64,Float64,Float64\)
```cj
public func _setVec4Uniform(renderer: Renderer, handle: GfxUniformHandle, slot: Int64, x: Float64, y: Float64, z: Float64, w: Float64): Unit
```
把四个标量写入槽位 slot 的 vec4 缓冲并提交（x/y/z/w 全写）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|handle|GfxUniformHandle|uniform 句柄|
|slot|Int64|槽位编号|
|x|Float64|写入 x 分量的值|
|y|Float64|写入 y 分量的值|
|z|Float64|写入 z 分量的值|
|w|Float64|写入 w 分量的值|

### func bindTexture\(Renderer,UInt8,GfxUniformHandle,GfxTextureHandle,UInt32\)
```cj
public func bindTexture(renderer: Renderer, stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit
```
绑定纹理到指定 stage 的 sampler

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|stage|UInt8|纹理 stage（0..MAX_TEXTURE_SAMPLERS-1）|
|sampler|GfxUniformHandle|sampler uniform 句柄|
|tex|GfxTextureHandle|待绑纹理句柄|
|flags|UInt32|采样器 flags（如 GfxSamplerFlag.U_CLAMP|V_CLAMP，0 表示用纹理默认）|

### func clearRenderTarget\(ThreeRenderer,UInt16,UInt16,UInt32,Float32,UInt8\)
```cj
public func clearRenderTarget(renderer: ThreeRenderer, viewId: UInt16, flags: UInt16, color: UInt32, depth!: Float32 = 1.0f32, stencil!: UInt8 = 0u8): Unit
```
设置某 view 的 clear（颜色 + 深度 + 模板）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|viewId|UInt16|view id|
|flags|UInt16|clear 标志位（GfxClearFlag.COLOR/DEPTH/STENCIL 组合）|
|color|UInt32|clear 颜色（UInt32）|
|depth|Float32|clear 深度（0.0~1.0，默认 1.0）|
|stencil|UInt8|clear 模板值（默认 0）|

### func getTexture\(ThreeRenderer,GfxFrameBufferHandle,UInt8\)
```cj
public func getTexture(renderer: ThreeRenderer, fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle
```
取 frame buffer 指定 attachment 的纹理句柄

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|fb|GfxFrameBufferHandle|源 frame buffer|
|attachment|UInt8|attachment 索引（0=主 color，1=depth 等）|

返回: 

- attachment 对应的纹理句柄

### func init\(\)
```cj
public init()
```


### func onAttach\(EffectComposer\)
```cj
public open func onAttach(composer: EffectComposer): Unit
```
挂载到 composer 时的钩子

参数: 

|名称|类型|描述|
|---|---|---|
|composer|EffectComposer|挂载的 EffectComposer|

### func release\(\)
```cj
public open func release(): Bool
```
基类默认 no-op，子类覆写释放自身 GPU 资源

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public open func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
执行 pass 渲染逻辑

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|writeBuffer|GfxFrameBufferHandle|写入 buffer|
|readBuffer|GfxFrameBufferHandle|读取 buffer（上一 pass 结果）|
|deltaTime|Float64|帧间隔（秒）|

### func setQuad\(FullScreenQuad\)
```cj
public func setQuad(quad: FullScreenQuad): Unit
```
注入共享全屏 quad

参数: 

|名称|类型|描述|
|---|---|---|
|quad|FullScreenQuad|composer 持有的共享全屏 quad|

### func setRenderTarget\(ThreeRenderer,UInt16,GfxFrameBufferHandle\)
```cj
public func setRenderTarget(renderer: ThreeRenderer, viewId: UInt16, fb: GfxFrameBufferHandle): Unit
```
设置某 view 的渲染目标 frame buffer

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|viewId|UInt16|view id（pass 持有，由 EffectComposer.allocViewId 分配）|
|fb|GfxFrameBufferHandle|目标 frame buffer；传无效句柄表示写交换链（屏幕）|

### func setSize\(Int64,Int64\)
```cj
public open func setSize(width: Int64, height: Int64): Unit
```
设置 pass 内部 RT 尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### func setStencil\(ThreeRenderer,UInt32,UInt32\)
```cj
public func setStencil(renderer: ThreeRenderer, fstencil: UInt32, bstencil: UInt32): Unit
```
设置模板状态（per-draw 瞬态）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|fstencil|UInt32|前面 stencil 位域（GfxStencilFlag 组合）|
|bstencil|UInt32|后面 stencil 位域（同上）|

### func setUniformFloats\(Renderer,GfxUniformHandle,Array<Float64>,UInt16\)
```cj
public func setUniformFloats(renderer: Renderer, handle: GfxUniformHandle, values: Array < Float64 >, num!: UInt16 = 1u16): Unit
```
设置 uniform 数据（安全重载，无需外部管理指针）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|handle|GfxUniformHandle|uniform 句柄|
|values|Array<Float64>|uniform 数据（Float64 数组，按 float32 写入）|
|num|UInt16|数组长度（默认 1）|

### func setUniform\(Renderer,GfxUniformHandle,PtrArray<Float32>,UInt16\)
```cj
public func setUniform(renderer: Renderer, handle: GfxUniformHandle, data: PtrArray < Float32 >, num!: UInt16 = 1u16): Unit
```
设置 uniform 数据

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|Renderer|渲染器|
|handle|GfxUniformHandle|uniform 句柄|
|data|PtrArray<Float32>|uniform 数据（float32 数组）|
|num|UInt16|数组长度（默认 1）|

### func setViewport\(ThreeRenderer,UInt16,UInt16,UInt16,UInt16,UInt16\)
```cj
public func setViewport(renderer: ThreeRenderer, viewId: UInt16, x: UInt16, y: UInt16, w: UInt16, h: UInt16): Unit
```
设置某 view 的视口矩形（像素）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|viewId|UInt16|view id|
|x|UInt16|视口左上角 x（像素）|
|y|UInt16|视口左上角 y（像素）|
|w|UInt16|视口宽（像素）|
|h|UInt16|视口高（像素）|

### func submitQuadWithState\(UInt16,GfxProgramHandle,UInt64\)
```cj
public func submitQuadWithState(viewId: UInt16, prog: GfxProgramHandle, state: UInt64): Unit
```
用共享 quad 提交全屏四边形，使用自定义 render state（如加性混合）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|view id|
|prog|GfxProgramHandle|已编译 program 句柄|
|state|UInt64|完整 render state 位域（setState 第 1 参）|

### func submitQuad\(UInt16,GfxProgramHandle\)
```cj
public func submitQuad(viewId: UInt16, prog: GfxProgramHandle): Unit
```
用共享 quad 提交全屏四边形（默认覆盖写 state）

参数: 

|名称|类型|描述|
|---|---|---|
|viewId|UInt16|view id|
|prog|GfxProgramHandle|已编译 program 句柄|

### func touchView\(ThreeRenderer,UInt16\)
```cj
public func touchView(renderer: ThreeRenderer, viewId: UInt16): Unit
```
触发某 view 的 empty submit（仅推进 clear / view 序号，不绘制）

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer|渲染器|
|viewId|UInt16|view id|

### var clear
```cj
public var clear: Bool = false
```
若为 true，pass 渲染前清 buffer，默认 false

### var enabled
```cj
public var enabled: Bool = true
```
若为 false，composer 跳过本 pass，默认 true

### let isPass
```cj
public let isPass: Bool = true
```
类型标志，用于运行期判断是否为 Pass

### var needsSwap
```cj
public var needsSwap: Bool = true
```
若为 true，pass 渲染后 composer 交换 read/write buffer，默认 true

### var quad
```cj
public var quad: Option < FullScreenQuad >= None
```
共享全屏 quad（由 EffectComposer 持单例，addPass 时经 setQuad 注入）

### var renderToScreen
```cj
public var renderToScreen: Bool = false
```
若为 true，pass 结果直接渲染到屏幕，默认 false

