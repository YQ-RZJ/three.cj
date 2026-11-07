# Class
## class PhysicsHeightField
```cj
public class PhysicsHeightField <: IReleasable
```
Runtime height field

### func projectOntoSurface\(Float64,Float64\)
```cj
public func projectOntoSurface(x: Float64, z: Float64): Vector3
```
Projects a world-space point onto the terrain surface (ground height)

Parameter: 

|Name|Type|Describe|
|---|---|---|
|x|Float64|World X coordinatez World Z coordinate|
|z|Float64||

Return: 

- The surface point (three left-handed); a point with y = -3.4e38 whenoutside the terrain or invalid

### func release\(\)
```cj
public func release(): Bool
```
disposes the height-field terrain (removes from the world and releases the body)

### prop bodyID: UInt32
```cj
public prop bodyID: UInt32
```
The terrain body ID (usable with collision queries)

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the height field is valid (created successfully and not disposed)

### prop sampleCount: Int64
```cj
public prop sampleCount: Int64
```
The sample count per side

