# Class
## class BgfxSAOPass
```cj
public class BgfxSAOPass <: Pass
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
构造：`new SAOPass(scene, camera, resolution)`。
默认输出 Default（0）；needsSwap=true（composer 链约定，写 writeBuffer 后交换）。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Pass.render 入口：执行 SAO 链并输出遮蔽应用到场景。

流程：
1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SAO 计算（view+2）→
4. vBlur（view+3）→ 5. hBlur（view+4）→ 6. 输出（view+5）

子渲染方法各自走 Pass 基类高阶 API（内部经 renderer.execBgfx 序列化到渲染线程），
不再外层包 execBgfx 闭包（避免嵌套死锁）。对齐 BgfxSSAOPass.render。

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

### let OUTPUT\_DEFAULT
```cj
public static let OUTPUT_DEFAULT: Int64 = 0
```
输出模式

### let OUTPUT\_NORMAL
```cj
public static let OUTPUT_NORMAL: Int64 = 2
```


### let OUTPUT\_SAO
```cj
public static let OUTPUT_SAO: Int64 = 1
```


### let SAO\_VIEW\_ID\_BASE
```cj
public static let SAO_VIEW_ID_BASE: UInt16 = 170u16
```
SAO pass 用的 view ID 段约定：SSAO 160~164，GTAO 165~169，SAO 170~175，composer 分配 230+

### var output
```cj
public var output: Int64 = 0
```
输出模式（默认 Default=0，AO 乘到场景色）

### var saoBias
```cj
public var saoBias: Float64 = 0.5
```
遮蔽偏置（默认 0.5）

### var saoBlurDepthCutoff
```cj
public var saoBlurDepthCutoff: Float64 = 0.01
```
模糊深度截止（视图空间深度差阈值，默认 0.01）

### var saoBlurRadius
```cj
public var saoBlurRadius: Int64 = 8
```
模糊半径（默认 8）

### var saoBlurStdDev
```cj
public var saoBlurStdDev: Float64 = 4.0
```
模糊标准差（默认 4）

### var saoBlur
```cj
public var saoBlur: Bool = true
```
是否启用深度受限模糊（默认 true）

### var saoIntensity
```cj
public var saoIntensity: Float64 = 0.18
```
遮蔽强度（默认 0.18）

### var saoKernelRadius
```cj
public var saoKernelRadius: Float64 = 100.0
```
采样核半径（视图空间距离，默认 100）

### var saoMinResolution
```cj
public var saoMinResolution: Float64 = 0.0
```
最小分辨率（默认 0）

### var saoScale
```cj
public var saoScale: Float64 = 1.0
```
遮蔽尺度（默认 1）

