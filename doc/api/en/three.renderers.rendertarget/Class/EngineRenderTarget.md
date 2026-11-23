# Class
## class EngineRenderTarget
```cj
public class EngineRenderTarget <: IReleasable
```
Engine render target

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the GPU resources (alias of dispose, for chaining-style usage)

### func init\(IRenderBackend,Int64,Int64,UInt32,UInt64,Bool\)
```cj
public init(backend: IRenderBackend, width: Int64, height: Int64, format!: UInt32, flags!: UInt64, depth!: Bool = true)
```
Constructs the render target and creates GPU resources

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|IRenderBackend||
|width|Int64||
|height|Int64||
|format|UInt32||
|flags|UInt64||
|depth|Bool||

### func release\(\)
```cj
public func release(): Bool
```
Releases the GPU resources (idempotent)

### func resize\(Int64,Int64\)
```cj
public func resize(width: Int64, height: Int64): Unit
```
Rebuilds at the given size (reusing the format/flags/depth configuration from construction)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|New width (physical pixels)height New height (physical pixels)|
|height|Int64||

### prop height: Int64
```cj
public prop height: Int64
```
RT height (physical pixels)

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the GPU resources are valid

### prop width: Int64
```cj
public prop width: Int64
```
RT width (physical pixels)

