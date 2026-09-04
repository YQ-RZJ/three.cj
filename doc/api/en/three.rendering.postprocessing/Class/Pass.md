# Class
## class Pass
```cj
public open class Pass
```
Post-processing pass abstract base class

### func dispose\(\)
```cj
public open func dispose(): Unit
```
Releases the GPU resources held by the pass

### func init\(\)
```cj
public init()
```


### func onAttach\(EffectComposer\)
```cj
public open func onAttach(composer: EffectComposer): Unit
```
Hook called when attached to a composer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|composer|EffectComposer|The EffectComposer being attached to|

### func render\(BgfxRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public open func render(renderer: BgfxRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the pass render logic

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|BgfxRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (FrameBufferHandle)|
|readBuffer|FrameBufferHandle|Read buffer (previous pass result)|
|deltaTime|Float64|Frame delta time (seconds)|

### func setQuad\(FullScreenQuad\)
```cj
public func setQuad(quad: FullScreenQuad): Unit
```
Injects the shared full-screen quad

Parameter: 

|Name|Type|Describe|
|---|---|---|
|quad|FullScreenQuad|The shared full-screen quad held by the composer|

### func setSize\(Int64,Int64\)
```cj
public open func setSize(width: Int64, height: Int64): Unit
```
Sets the pass's internal RT size

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### var clear
```cj
public var clear: Bool = false
```
If true, clears the buffer before rendering; default false

### var enabled
```cj
public var enabled: Bool = true
```
If false, the composer skips this pass; default true

### let isPass
```cj
public let isPass: Bool = true
```
Type flag used to identify a Pass at runtime

### var needsSwap
```cj
public var needsSwap: Bool = true
```
If true, the composer swaps the read/write buffers after rendering; default true

### var quad
```cj
public var quad: Option < FullScreenQuad >= None
```
Shared full-screen quad (held as a singleton by EffectComposer, injected via setQuad on addPass)

### var renderToScreen
```cj
public var renderToScreen: Bool = false
```
If true, the pass result renders directly to the screen; default false

