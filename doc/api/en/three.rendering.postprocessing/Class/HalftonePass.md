# Class
## class HalftonePass
```cj
public class HalftonePass <: Pass
```
RGB halftone post-processing pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases all GPU resources held by the halftone pass

### func init\(Int64,Float64,Float64,Float64,Float64,Float64,Float64,Int64,Bool,Bool\)
```cj
public init(shape!: Int64 = 1, radius!: Float64 = 4.0, rotateR!: Float64 = 3.141592653589793 / 12.0, rotateG!: Float64 = 3.141592653589793 / 12.0 * 2.0, rotateB!: Float64 = 3.141592653589793 / 12.0 * 3.0, scatter!: Float64 = 0.0, blending!: Float64 = 1.0, blendingMode!: Int64 = 1, greyscale!: Bool = false, disable!: Bool = false)
```
Constructs HalftonePass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|shape|Int64|Dot shape (default 1=Dot)|
|radius|Float64|Dot radius (default 4)|
|rotateR|Float64|R channel rotation angle (default PI/12)|
|rotateG|Float64|G channel rotation angle (default PI/12*2)|
|rotateB|Float64|B channel rotation angle (default PI/12*3)|
|scatter|Float64|Scatter dithering (default 0)|
|blending|Float64|Blending strength (default 1)|
|blendingMode|Int64|Blending mode (default 1=Linear)|
|greyscale|Bool|Grayscale (default false)|
|disable|Bool|Disabled pass-through (default false)|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the halftone pass

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

### let HALFTONE\_VIEW\_ID\_BASE
```cj
public static let HALFTONE_VIEW_ID_BASE: UInt16 = 227u16
```
分配给本 pass 的 bgfx view ID 段。
+0: halftone pass（RGB 半色调网点处理）
取 227 起避开 SSAO 160 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
DotScreenPass 226。

### var blendingMode
```cj
public var blendingMode: Int64
```
Blending mode (1=Linear 2=Multiply 3=Add 4=Lighter 5=Darker), default 1

### var blending
```cj
public var blending: Float64
```
Blending strength (0=full original 1=full halftone), default 1

### var disable
```cj
public var disable: Bool
```
Whether to disable (true=pass the original image through), default false

### var greyscale
```cj
public var greyscale: Bool
```
Whether to output grayscale, default false

### var radius
```cj
public var radius: Float64
```
Dot radius (pixels), default 4

### var rotateB
```cj
public var rotateB: Float64
```
B channel grid rotation angle (radians), default PI/12*3

### var rotateG
```cj
public var rotateG: Float64
```
G channel grid rotation angle (radians), default PI/12*2

### var rotateR
```cj
public var rotateR: Float64
```
R channel grid rotation angle (radians), default PI/12

### var scatter
```cj
public var scatter: Float64
```
Scatter dithering amount (0=no dithering), default 0

### var shape
```cj
public var shape: Int64
```
Dot shape (1=Dot 2=Ellipse 3=Line 4=Square 5=Diamond), default 1

