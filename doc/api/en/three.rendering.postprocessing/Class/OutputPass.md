# Class
## class OutputPass
```cj
public class OutputPass <: Pass
```
Output pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases the GPU resources held by OutputPass

### func init\(Int64,Float64,Bool\)
```cj
public init(toneMapping!: Int64 = ACESFilmicToneMapping, exposure!: Float64 = 1.0, sRGB!: Bool = true)
```
Constructs OutputPass

Parameter: 

|Name|Type|Describe|
|---|---|---|
|toneMapping|Int64|Tone mapping mode (default ACESFilmicToneMapping=4)|
|exposure|Float64|Exposure (default 1.0)|
|sRGB|Bool|Whether to perform sRGB conversion (default true)|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行输出 pass：色调映射 + sRGB 转换上屏。

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（renderToScreen=false 时写这里）|
|readBuffer|FrameBufferHandle|读 buffer（待转换的线性 HDR 颜色）|
|deltaTime|Float64|帧间隔|

### var exposure
```cj
public var exposure: Float64 = 1.0
```
Tone mapping exposure, default 1.0

### var sRGB
```cj
public var sRGB: Bool = true
```
Whether to perform sRGB OETF conversion (linear → sRGB), default true (convert to sRGB before presenting)

### var toneMapping
```cj
public var toneMapping: Int64 = ACESFilmicToneMapping
```
Tone mapping mode (see constants.cj: NoToneMapping=0 ... NeutralToneMapping=7), default ACESFilmicToneMapping (=4)

