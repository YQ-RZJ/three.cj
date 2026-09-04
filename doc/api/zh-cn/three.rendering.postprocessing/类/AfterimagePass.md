# 类
## class AfterimagePass
```cj
public class AfterimagePass <: Pass
```
残影后处理 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 afterimage pass 占用的所有 GPU 资源

### func init\(Float64\)
```cj
public init(damp!: Float64 = 0.96)
```
构造 AfterimagePass

参数: 

|名称|类型|描述|
|---|---|---|
|damp|Float64|阻尼系数（默认 0.96）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行 afterimage pass

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（copy pass 的输出目标）|
|readBuffer|FrameBufferHandle|读 buffer（当前帧输入，绑到 tNew）|
|deltaTime|Float64|帧间隔|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
设置 pass 尺寸，创建/重建内部双 RT

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64||
|height|Int64||

### let AFTERIMAGE\_VIEW\_ID\_BASE
```cj
public static let AFTERIMAGE_VIEW_ID_BASE: UInt16 = 221u16
```
分配给本 pass 的 bgfx view ID 段。
+0: comp pass（残影融合）
+1: copy pass（结果输出）
取 221 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 / TAA 219~220。

### var damp
```cj
public var damp: Float64
```
阻尼系数（0~1），越大残影衰减越慢、拖尾越长，默认 0.96

