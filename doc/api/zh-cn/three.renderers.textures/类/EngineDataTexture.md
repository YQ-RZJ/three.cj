# 类
## class EngineDataTexture
```cj
public class EngineDataTexture <: IReleasable
```
引擎数据纹理

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放 GPU 资源（dispose 的别名，满足链式习惯）

### func handleIdx\(\)
```cj
public func handleIdx(): UInt16
```
纹理句柄索引（只读裸值；调试打印/深度集成用途）

### func init\(IRenderBackend,Int64,Int64,Array<UInt8>,UInt32,UInt64\)
```cj
public init(backend: IRenderBackend, width: Int64, height: Int64, pixels: Array < UInt8 >, format!: UInt32, flags!: UInt64 = 0u64)
```
构造 2D 数据纹理并上传像素数据

参数: 

|名称|类型|描述|
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
构造 3D 数据纹理并上传体素数据

参数: 

|名称|类型|描述|
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
无效占位实例（不触达 GPU）

### func release\(\)
```cj
public func release(): Bool
```
释放 GPU 资源（幂等）

### prop depth: Int64
```cj
public prop depth: Int64
```
纹理深（层数；1=2D）

### prop height: Int64
```cj
public prop height: Int64
```
纹理高（像素）

### prop isValid: Bool
```cj
public prop isValid: Bool
```
纹理是否有效（句柄非 INVALID 哨兵）

### prop releasable: Bool
```cj
public prop releasable: Bool
```
GPU 资源是否有效

### prop width: Int64
```cj
public prop width: Int64
```
纹理宽（像素）

### let FLAGS\_CLAMP\_UVW
```cj
public static let FLAGS_CLAMP_UVW: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP | GfxTextureFlag.SAMPLER_W_CLAMP
```
采样组合：U/V/W 三方向钳位（3D LUT 常用）

### let FLAGS\_CLAMP\_UVW\_POINT
```cj
public static let FLAGS_CLAMP_UVW_POINT: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP | GfxTextureFlag.SAMPLER_W_CLAMP | GfxTextureFlag.SAMPLER_MIN_POINT | GfxTextureFlag.SAMPLER_MAG_POINT
```
采样组合：U/V/W 三方向钳位 + 点采样（无过滤的精确查询，
3D LUT 常用）

### let FLAGS\_CLAMP\_UV
```cj
public static let FLAGS_CLAMP_UV: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP
```
采样组合：U/V 方向钳位

### let FORMAT\_RGBA16F
```cj
public static let FORMAT_RGBA16F: UInt32 = GfxTextureFormat.RGBA16F.value()
```
常用格式：RGBA16F（半浮点）

### let FORMAT\_RGBA32F
```cj
public static let FORMAT_RGBA32F: UInt32 = GfxTextureFormat.RGBA32F.value()
```
常用格式：RGBA32F（全浮点）

### let FORMAT\_RGBA8
```cj
public static let FORMAT_RGBA8: UInt32 = GfxTextureFormat.RGBA8.value()
```
常用格式：RGBA8（每像素 4 字节）

