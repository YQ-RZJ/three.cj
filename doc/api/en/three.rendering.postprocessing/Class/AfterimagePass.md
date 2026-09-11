# Class
## class AfterimagePass
```cj
public class AfterimagePass <: Pass
```
Afterimage post-processing pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases all GPU resources held by the afterimage pass

### func init\(Float64\)
```cj
public init(damp!: Float64 = 0.96)
```
Constructs AfterimagePass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|damp|Float64|Damping factor (default 0.96)|

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the afterimage pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (output target of the copy pass)|
|readBuffer|FrameBufferHandle|Read buffer (current frame input, bound to tNew)|
|deltaTime|Float64|Frame delta time|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
Sets the pass size, creating/rebuilding the internal dual RTs

Parameter: 

|Name|Type|Describe|
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
Damping factor (0~1); larger = slower afterimage decay, longer trails, default 0.96

