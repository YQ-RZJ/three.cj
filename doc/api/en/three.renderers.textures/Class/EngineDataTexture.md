# Class
## class EngineDataTexture
```cj
public class EngineDataTexture <: IReleasable
```
Engine data texture

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the GPU resource (alias of dispose, for chaining-style usage)

### func handleIdx\(\)
```cj
public func handleIdx(): UInt16
```
Texture handle index (read-only plain value; debugging / deep-integration use)

### func init\(IRenderBackend,Int64,Int64,Array<UInt8>,UInt32,UInt64\)
```cj
public init(backend: IRenderBackend, width: Int64, height: Int64, pixels: Array < UInt8 >, format!: UInt32, flags!: UInt64 = 0u64)
```
Constructs a 2D data texture and uploads the pixel data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|IRenderBackend||
|width|Int64||
|height|Int64||
|pixels|Array<UInt8>||
|format|UInt32||
|flags|UInt64||

### func init\(IRenderBackend,Int64,Int64,Int64,Array<UInt8>,UInt32,UInt64\)
```cj
public init(backend: IRenderBackend, width: Int64, height: Int64, depth: Int64, pixels: Array < UInt8 >, format!: UInt32, flags!: UInt64 = 0u64)
```
Constructs a 3D data texture and uploads the voxel data

Parameter: 

|Name|Type|Describe|
|---|---|---|
|backend|IRenderBackend||
|width|Int64||
|height|Int64||
|depth|Int64||
|pixels|Array<UInt8>||
|format|UInt32||
|flags|UInt64||

### func invalid\(\)
```cj
public static func invalid(): EngineDataTexture
```
Invalid placeholder instance (touches no GPU)

### func release\(\)
```cj
public func release(): Bool
```
Releases the GPU resource (idempotent)

### prop depth: Int64
```cj
public prop depth: Int64
```
Texture depth (layers; 1 = 2D)

### prop height: Int64
```cj
public prop height: Int64
```
Texture height (pixels)

### prop isValid: Bool
```cj
public prop isValid: Bool
```
Whether the texture is valid (handle is not the INVALID sentinel)

### prop releasable: Bool
```cj
public prop releasable: Bool
```
Whether the GPU resource is valid

### prop width: Int64
```cj
public prop width: Int64
```
Texture width (pixels)

### let FLAGS\_CLAMP\_UVW
```cj
public static let FLAGS_CLAMP_UVW: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP | GfxTextureFlag.SAMPLER_W_CLAMP
```
Sampler combination: U/V/W clamp (common for 3D LUTs)

### let FLAGS\_CLAMP\_UVW\_POINT
```cj
public static let FLAGS_CLAMP_UVW_POINT: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP | GfxTextureFlag.SAMPLER_W_CLAMP | GfxTextureFlag.SAMPLER_MIN_POINT | GfxTextureFlag.SAMPLER_MAG_POINT
```
Sampler combination: U/V/W clamp + point sampling (exact
lookup without filtering, common for 3D LUTs)

### let FLAGS\_CLAMP\_UV
```cj
public static let FLAGS_CLAMP_UV: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP
```
Sampler combination: U/V clamp

### let FORMAT\_RGBA16F
```cj
public static let FORMAT_RGBA16F: UInt32 = GfxTextureFormat.RGBA16F.value()
```
Common format: RGBA16F (half float)

### let FORMAT\_RGBA32F
```cj
public static let FORMAT_RGBA32F: UInt32 = GfxTextureFormat.RGBA32F.value()
```
Common format: RGBA32F (full float)

### let FORMAT\_RGBA8
```cj
public static let FORMAT_RGBA8: UInt32 = GfxTextureFormat.RGBA8.value()
```
Common format: RGBA8 (4 bytes per pixel)

