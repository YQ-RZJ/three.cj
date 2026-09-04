# 类
## class SMAAPass
```cj
public class SMAAPass <: Pass
```
SMAA 后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 SMAAPass 占用的所有 GPU 资源（edges/weights RT + area/search LUT + 3 个 shader）。

### func init\(\)
```cj
public init()
```
构造 SMAAPass。

差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 SMAA pass（3 pass：Edges → Weights → Blend）。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（pass 3 输出）|
|readBuffer|FrameBufferHandle|读 buffer（pass 1/3 输入）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸（重建内部 edges/weights RT + 创建 LUT）。

调用约定：caller（EffectComposer.setSize/addPass）已把本方法包进 renderer.execBgfx，
故本方法直接调 bgfx API，不再嵌套 renderer.execBgfx（避免死锁）。

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let SMAA\_VIEW\_BLEND
```cj
public static let SMAA_VIEW_BLEND: UInt16 = 216u16
```


### let SMAA\_VIEW\_EDGES
```cj
public static let SMAA_VIEW_EDGES: UInt16 = 214u16
```
SMAA pass 用的 view ID 段约定（避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/
SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213）。
- SMAA_VIEW_EDGES（214）：pass 1 - 颜色边缘检测
- SMAA_VIEW_WEIGHTS（215）：pass 2 - 混合权重计算
- SMAA_VIEW_BLEND（216）：pass 3 - 邻域混合输出

### let SMAA\_VIEW\_WEIGHTS
```cj
public static let SMAA_VIEW_WEIGHTS: UInt16 = 215u16
```


