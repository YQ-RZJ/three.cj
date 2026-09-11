# 类
## class SSAOPass
```cj
public class SSAOPass <: Pass
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
构造：`new SSAOPass(scene, camera)`。

参数: 

|名称|类型|描述|
|---|---|---|
|scene|Scene||
|camera|Camera||

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Pass.render 入口：执行 SSAO 链并输出遮蔽应用到场景。

流程：
1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SSAO 计算（view+2）→ 4. blur（view+3）
5. apply pass（view+4）：采样 readBuffer（场景）与 blur 遮蔽图，输出 sceneColor × ao
写 writeBuffer；renderToScreen=true（composer 链最后一个 enabled pass）时写屏幕。

所有 bgfx 调用经 renderer.execBgfx 序列化到渲染线程（对齐 UnrealBloomPass.render）。
writeBuffer/readBuffer 是

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|ThreeRenderer||
|writeBuffer|FrameBufferHandle||
|readBuffer|FrameBufferHandle||
|deltaTime|Float64||

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用）

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let SSAO\_VIEW\_ID\_BASE
```cj
public static let SSAO_VIEW_ID_BASE: UInt16 = 160u16
```
SSAO pass 用的 view ID 段约定：主渲染 view 0，阴影 view 64+，SSAO 从 160 起

### var kernelRadius
```cj
public var kernelRadius: Float64 = 8.0
```
SSAO 采样半径（默认 8）

### var maxDistance
```cj
public var maxDistance: Float64 = 0.1
```
最大遮蔽距离

### var minDistance
```cj
public var minDistance: Float64 = 0.005
```
最小遮蔽距离（避免近邻片元微小深度差伪影）

