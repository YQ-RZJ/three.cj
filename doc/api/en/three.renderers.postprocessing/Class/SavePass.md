# Class
## class SavePass
```cj
public class SavePass <: Pass & IReleasable
```
Save pass

### func init\(\)
```cj
public init()
```
Constructs SavePass

### func release\(\)
```cj
public override func release(): Bool
```
Releases the GPU resources held by SavePass (internal RT)

### func render\(ThreeRenderer,GfxFrameBufferHandle,GfxFrameBufferHandle,Float64\)
```cj
public override func render(renderer: ThreeRenderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle, deltaTime: Float64): Unit
```
Executes the save pass: copies the readBuffer into the renderTarget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|
|writeBuffer|GfxFrameBufferHandle|Write buffer (unused by this pass; result goes to renderTarget)|
|readBuffer|GfxFrameBufferHandle|Read buffer (copy source)|
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

### prop releasable: Bool
```cj
public prop releasable: Bool
```
whether the internal RT exists and has not been released

