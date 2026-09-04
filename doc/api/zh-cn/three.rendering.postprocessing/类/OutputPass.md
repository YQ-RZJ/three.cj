# 类
## class OutputPass
```cj
public class OutputPass <: Pass
```
输出 pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
释放 OutputPass 占用的 GPU 资源

### func init\(Int64,Float64,Bool\)
```cj
public init(toneMapping!: Int64 = ACESFilmicToneMapping, exposure!: Float64 = 1.0, sRGB!: Bool = true)
```
构造 OutputPass

参数: 

|名称|类型|描述|
|---|---|---|
|toneMapping|Int64|色调映射模式（默认 ACESFilmicToneMapping=4）|
|exposure|Float64|曝光（默认 1.0）|
|sRGB|Bool|是否做 sRGB 转换（默认 true）|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
执行输出 pass：色调映射 + sRGB 转换上屏。

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|BgfxRenderer|渲染器|
|writeBuffer|FrameBufferHandle|写 buffer（renderToScreen=false 时写这里）|
|readBuffer|FrameBufferHandle|读 buffer（待转换的线性 HDR 颜色）|
|deltaTime|Float64|帧间隔|

### var exposure
```cj
public var exposure: Float64 = 1.0
```
色调映射曝光，默认 1.0

### var sRGB
```cj
public var sRGB: Bool = true
```
是否做 sRGB OETF 转换（线性 → sRGB），默认 true（上屏前转 sRGB）

### var toneMapping
```cj
public var toneMapping: Int64 = ACESFilmicToneMapping
```
色调映射模式（对照 constants.cj：NoToneMapping=0 ... NeutralToneMapping=7），默认 ACESFilmicToneMapping（=4）

