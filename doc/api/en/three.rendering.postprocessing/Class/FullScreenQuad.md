# Class
## class FullScreenQuad
```cj
public class FullScreenQuad
```
Full-screen quad shared resources

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the GPU resources held by the full-screen quad

### func ensureResources\(ThreeRenderer\)
```cj
public func ensureResources(renderer: ThreeRenderer): Unit
```
Ensures the full-screen quad cached resources are created (lazily)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer (bgfx resource creation is serialized to the render thread via its high-level API)|

### func init\(\)
```cj
public init()
```


### func setRenderer\(ThreeRenderer\)
```cj
public func setRenderer(renderer: ThreeRenderer): Unit
```
Injects the renderer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|ThreeRenderer|Renderer|

### func submitWithState\(UInt16,ProgramHandle,UInt64\)
```cj
public func submitWithState(viewId: UInt16, prog: ProgramHandle, state: UInt64): Unit
```
Submits the full-screen quad with a custom render state (e.g. additive blending)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|The bgfx view id|
|prog|ProgramHandle|The compiled program handle|
|state|UInt64|The full render state (first argument of bgfx_set_state_cj)|

### func submit\(UInt16,ProgramHandle\)
```cj
public func submit(viewId: UInt16, prog: ProgramHandle): Unit
```
Submits the full-screen quad (using the cached VB/IB/layout)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|viewId|UInt16|The bgfx view id|
|prog|ProgramHandle|The compiled program handle|

