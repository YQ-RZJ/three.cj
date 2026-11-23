# Class
## class GfxSamplerFlag
```cj
public class GfxSamplerFlag
```
Sampler flags at texture binding time

### let COMPARE\_LEQUAL
```cj
public static let COMPARE_LEQUAL: UInt32 = 0x00020000
```
比较模式：小于等于（阴影采样）

### let MAG\_ANISOTROPIC
```cj
public static let MAG_ANISOTROPIC: UInt32 = 0x00000200
```


### let MAG\_POINT
```cj
public static let MAG_POINT: UInt32 = 0x00000100
```


### let MIN\_ANISOTROPIC
```cj
public static let MIN_ANISOTROPIC: UInt32 = 0x00000080
```


### let MIN\_POINT
```cj
public static let MIN_POINT: UInt32 = 0x00000040
```


### let MIP\_POINT
```cj
public static let MIP_POINT: UInt32 = 0x00000400
```


### let NONE
```cj
public static let NONE: UInt32 = 0x00000000
```
沿用纹理自身采样设置

### let POINT
```cj
public static let POINT: UInt32 = 0x00000540
```
点采样组合（MIN/MAG/MIP 全点采样）

### let UVW\_CLAMP
```cj
public static let UVW_CLAMP: UInt32 = 0x0000002A
```
UVW 钳位环绕

### let U\_BORDER
```cj
public static let U_BORDER: UInt32 = 0x00000003
```


### let U\_CLAMP
```cj
public static let U_CLAMP: UInt32 = 0x00000002
```


### let U\_MIRROR
```cj
public static let U_MIRROR: UInt32 = 0x00000001
```


### let V\_BORDER
```cj
public static let V_BORDER: UInt32 = 0x0000000C
```


### let V\_CLAMP
```cj
public static let V_CLAMP: UInt32 = 0x00000008
```


### let V\_MIRROR
```cj
public static let V_MIRROR: UInt32 = 0x00000004
```


### let W\_BORDER
```cj
public static let W_BORDER: UInt32 = 0x00000030
```


### let W\_CLAMP
```cj
public static let W_CLAMP: UInt32 = 0x00000020
```


### let W\_MIRROR
```cj
public static let W_MIRROR: UInt32 = 0x00000010
```


