# Class
## class DotScreenPass
```cj
public class DotScreenPass <: Pass
```
Dot screen post-processing pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases all GPU resources held by the dot screen pass

### func init\(Vector2,Float64,Float64\)
```cj
public init(center!: Vector2 = Vector2(0.5, 0.5), angle!: Float64 = 1.57, scale!: Float64 = 1.0)
```
Constructs DotScreenPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|center|Vector2|Dot grid center (default (0.5, 0.5))|
|angle|Float64|Dot grid rotation angle (default 1.57 ≈ π/2)|
|scale|Float64|Dot grid density (default 1.0)|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the dot screen pass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (output target of this pass)|
|readBuffer|FrameBufferHandle|Read buffer (previous pass result, bound to tDiffuse)|
|deltaTime|Float64|Frame delta time|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
Sets the pass size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### let DOTSCREEN\_VIEW\_ID\_BASE
```cj
public static let DOTSCREEN_VIEW_ID_BASE: UInt16 = 226u16
```
分配给本 pass 的 bgfx view ID 段。
+0: dot_screen pass（点阵网点处理）
取 226 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225。

### var angle
```cj
public var angle: Float64
```
Dot grid rotation angle (radians), default 1.57 ≈ π/2

### var center
```cj
public var center: Vector2
```
Dot grid center (UV space, 0~1), default (0.5, 0.5)

### var scale
```cj
public var scale: Float64
```
Dot grid density factor (larger value = smaller dots), default 1.0

