# Class
## class SavePass
```cj
public class SavePass <: Pass
```
Save pass

### func dispose\(\)
```cj
public override func dispose(): Unit
```
Releases the GPU resources held by SavePass (internal RT)

### func init\(\)
```cj
public init()
```
Constructs SavePass

### func render\(ThreeRenderer,FrameBufferHandle,FrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle, deltaTime: Float64): Unit
```
Executes the save pass: copies the readBuffer into the renderTarget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|FrameBufferHandle|Write buffer (unused by this pass; result goes to renderTarget)|
|readBuffer|FrameBufferHandle|Read buffer (copy source)|
|deltaTime|Float64|Frame delta time|

### func setSize\(Int64,Int64\)
```cj
public override func setSize(width: Int64, height: Int64): Unit
```
Sets the internal RT size (destroy and rebuild)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64||
|height|Int64||

### var renderTarget
```cj
public var renderTarget: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
```
Internal render target (color RT, RGBA16F, no depth)

