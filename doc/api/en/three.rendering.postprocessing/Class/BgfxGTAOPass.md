# Class
## class BgfxGTAOPass
```cj
public class BgfxGTAOPass <: Pass
```


### func dispose\(\)
```cj
public override func dispose(): Unit
```
销毁全部 GPU 资源（composer.dispose 或 renderer.shutdown 调用）

### func init\(Scene,Camera\)
```cj
public init(scene: Scene, camera: Camera)
```
构造：对齐 `new GTAOPass(scene, camera, width, height)`。
默认输出 Default（0）；needsSwap=true（Pass 基类默认）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Pass.render 入口：执行 GTAO 链并输出遮蔽应用到场景。

流程：
1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. GTAO 计算（view+2）→
4. PoissonDenoise（view+3）→ 5. 输出（view+4）：按 output 模式写 writeBuffer/屏幕

各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer||
|writeBuffer|FrameBufferHandle||
|readBuffer|FrameBufferHandle||
|deltaTime|Float64||

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用）

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### let GTAO\_VIEW\_ID\_BASE
```cj
public static let GTAO_VIEW_ID_BASE: UInt16 = 165u16
```
GTAO pass 用的 view ID 段约定：SSAO 160~164，GTAO 165~169，SAO 170~175，composer 分配 230+

### let OUTPUT\_AO
```cj
public static let OUTPUT_AO: Int64 = 4
```


### let OUTPUT\_DEFAULT
```cj
public static let OUTPUT_DEFAULT: Int64 = 0
```


### let OUTPUT\_DENOISE
```cj
public static let OUTPUT_DENOISE: Int64 = 5
```


### let OUTPUT\_DEPTH
```cj
public static let OUTPUT_DEPTH: Int64 = 2
```


### let OUTPUT\_DIFFUSE
```cj
public static let OUTPUT_DIFFUSE: Int64 = 1
```


### let OUTPUT\_NORMAL
```cj
public static let OUTPUT_NORMAL: Int64 = 3
```


### let OUTPUT\_OFF
```cj
public static let OUTPUT_OFF: Int64 = - 1
```
输出模式（GTAOPass.OUTPUT）

### var blendIntensity
```cj
public var blendIntensity: Float64 = 1.0
```
AO 混合强度（默认 1.0）

### var depthPhi
```cj
public var depthPhi: Float64 = 2.0
```
PD 深度阈值（默认 2）

### var distanceExponent
```cj
public var distanceExponent: Float64 = 1.0
```
GTAO 距离指数（默认 1.0）

### var distanceFallOff
```cj
public var distanceFallOff: Float64 = 1.0
```
GTAO 距离衰减（默认 1.0）

### var lumaPhi
```cj
public var lumaPhi: Float64 = 10.0
```
PD 亮度阈值（默认 10）

### var normalPhi
```cj
public var normalPhi: Float64 = 3.0
```
PD 法线阈值（默认 3）

### var output
```cj
public var output: Int64 = 0
```
输出模式（默认 Default=0，GTAO+Denoise 混合到场景）

### var pdRadius
```cj
public var pdRadius: Float64 = 8.0
```
PD 采样半径（默认 8）

### var radius
```cj
public var radius: Float64 = 0.25
```
GTAO 采样半径（默认 0.25）

### var scale
```cj
public var scale: Float64 = 1.0
```
GTAO 遮蔽指数（默认 1.0）

### var thickness
```cj
public var thickness: Float64 = 1.0
```
GTAO 厚度（默认 1.0）

