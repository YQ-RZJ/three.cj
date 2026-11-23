# Class
## class GfxTextureFlag
```cj
public class GfxTextureFlag
```
Texture creation flags (sampler bits merged into the low 32 bits)

### let BLIT\_DST
```cj
public static let BLIT_DST: UInt64 = 0x0000400000000000
```
纹理可作 blit 目标

### let COMPUTE\_WRITE
```cj
public static let COMPUTE_WRITE: UInt64 = 0x0000100000000000
```
计算着色器可写

### let NONE
```cj
public static let NONE: UInt64 = 0x0000000000000000
```
无标志

### let READ\_BACK
```cj
public static let READ_BACK: UInt64 = 0x0000800000000000
```
回读纹理

### let RT
```cj
public static let RT: UInt64 = 0x0000001000000000
```
渲染目标纹理

### let RT\_MSAA\_SAMPLE
```cj
public static let RT_MSAA_SAMPLE: UInt64 = 0x0000000800000000
```
渲染目标可作 MSAA 采样源

### let RT\_MSAA\_X16
```cj
public static let RT_MSAA_X16: UInt64 = 0x0000005000000000
```


### let RT\_MSAA\_X2
```cj
public static let RT_MSAA_X2: UInt64 = 0x0000002000000000
```
渲染目标 MSAA x2/x4/x8/x16

### let RT\_MSAA\_X4
```cj
public static let RT_MSAA_X4: UInt64 = 0x0000003000000000
```


### let RT\_MSAA\_X8
```cj
public static let RT_MSAA_X8: UInt64 = 0x0000004000000000
```


### let RT\_WRITE\_ONLY
```cj
public static let RT_WRITE_ONLY: UInt64 = 0x0000008000000000
```
渲染目标只写

### let SAMPLER\_MAG\_ANISOTROPIC
```cj
public static let SAMPLER_MAG_ANISOTROPIC: UInt64 = 0x0000000000000200
```


### let SAMPLER\_MAG\_POINT
```cj
public static let SAMPLER_MAG_POINT: UInt64 = 0x0000000000000100
```


### let SAMPLER\_MIN\_ANISOTROPIC
```cj
public static let SAMPLER_MIN_ANISOTROPIC: UInt64 = 0x0000000000000080
```


### let SAMPLER\_MIN\_POINT
```cj
public static let SAMPLER_MIN_POINT: UInt64 = 0x0000000000000040
```


### let SAMPLER\_MIP\_POINT
```cj
public static let SAMPLER_MIP_POINT: UInt64 = 0x0000000000000400
```


### let SAMPLER\_POINT
```cj
public static let SAMPLER_POINT: UInt64 = 0x0000000000000540
```
点采样组合（MIN/MAG/MIP 全点采样）

### let SAMPLER\_UVW\_BORDER
```cj
public static let SAMPLER_UVW_BORDER: UInt64 = 0x000000000000003F
```
UVW 边界色环绕

### let SAMPLER\_UVW\_CLAMP
```cj
public static let SAMPLER_UVW_CLAMP: UInt64 = 0x000000000000002A
```
UVW 钳位环绕

### let SAMPLER\_UVW\_MIRROR
```cj
public static let SAMPLER_UVW_MIRROR: UInt64 = 0x0000000000000015
```
UVW 镜像环绕

### let SAMPLER\_U\_BORDER
```cj
public static let SAMPLER_U_BORDER: UInt64 = 0x0000000000000003
```


### let SAMPLER\_U\_CLAMP
```cj
public static let SAMPLER_U_CLAMP: UInt64 = 0x0000000000000002
```


### let SAMPLER\_U\_MIRROR
```cj
public static let SAMPLER_U_MIRROR: UInt64 = 0x0000000000000001
```
---- 采样器位（并入低 32 位） ----

### let SAMPLER\_V\_BORDER
```cj
public static let SAMPLER_V_BORDER: UInt64 = 0x000000000000000C
```


### let SAMPLER\_V\_CLAMP
```cj
public static let SAMPLER_V_CLAMP: UInt64 = 0x0000000000000008
```


### let SAMPLER\_V\_MIRROR
```cj
public static let SAMPLER_V_MIRROR: UInt64 = 0x0000000000000004
```


### let SAMPLER\_W\_BORDER
```cj
public static let SAMPLER_W_BORDER: UInt64 = 0x0000000000000030
```


### let SAMPLER\_W\_CLAMP
```cj
public static let SAMPLER_W_CLAMP: UInt64 = 0x0000000000000020
```


### let SAMPLER\_W\_MIRROR
```cj
public static let SAMPLER_W_MIRROR: UInt64 = 0x0000000000000010
```


### let SRGB
```cj
public static let SRGB: UInt64 = 0x0000200000000000
```
sRGB 编码

