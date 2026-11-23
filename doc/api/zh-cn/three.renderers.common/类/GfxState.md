# 类
## class GfxState
```cj
public class GfxState
```
绘制状态位（深度测试/写入掩码/混合/剔除/图元类型/MSAA）

### let BLEND\_ALPHA\_TO\_COVERAGE
```cj
public static let BLEND_ALPHA_TO_COVERAGE: UInt64 = 0x0000000800000000
```
Alpha 覆盖

### let BLEND\_DST\_ALPHA
```cj
public static let BLEND_DST_ALPHA: UInt64 = 0x0000000000007000
```


### let BLEND\_DST\_COLOR
```cj
public static let BLEND_DST_COLOR: UInt64 = 0x0000000000009000
```


### let BLEND\_EQUATION\_ADD
```cj
public static let BLEND_EQUATION_ADD: UInt64 = 0x0000000000000000
```
---- 混合方程（默认相加，无须设置） ----

### let BLEND\_EQUATION\_MAX
```cj
public static let BLEND_EQUATION_MAX: UInt64 = 0x0000000040000000
```


### let BLEND\_EQUATION\_MIN
```cj
public static let BLEND_EQUATION_MIN: UInt64 = 0x0000000030000000
```


### let BLEND\_EQUATION\_REVSUB
```cj
public static let BLEND_EQUATION_REVSUB: UInt64 = 0x0000000020000000
```


### let BLEND\_EQUATION\_SUB
```cj
public static let BLEND_EQUATION_SUB: UInt64 = 0x0000000010000000
```


### let BLEND\_FACTOR
```cj
public static let BLEND_FACTOR: UInt64 = 0x000000000000C000
```


### let BLEND\_INDEPENDENT
```cj
public static let BLEND_INDEPENDENT: UInt64 = 0x0000000400000000
```
MRT 独立混合

### let BLEND\_INV\_DST\_ALPHA
```cj
public static let BLEND_INV_DST_ALPHA: UInt64 = 0x0000000000008000
```


### let BLEND\_INV\_DST\_COLOR
```cj
public static let BLEND_INV_DST_COLOR: UInt64 = 0x000000000000A000
```


### let BLEND\_INV\_FACTOR
```cj
public static let BLEND_INV_FACTOR: UInt64 = 0x000000000000D000
```


### let BLEND\_INV\_SRC\_ALPHA
```cj
public static let BLEND_INV_SRC_ALPHA: UInt64 = 0x0000000000006000
```


### let BLEND\_INV\_SRC\_COLOR
```cj
public static let BLEND_INV_SRC_COLOR: UInt64 = 0x0000000000004000
```


### let BLEND\_ONE
```cj
public static let BLEND_ONE: UInt64 = 0x0000000000002000
```


### let BLEND\_SRC\_ALPHA
```cj
public static let BLEND_SRC_ALPHA: UInt64 = 0x0000000000005000
```


### let BLEND\_SRC\_ALPHA\_SAT
```cj
public static let BLEND_SRC_ALPHA_SAT: UInt64 = 0x000000000000B000
```


### let BLEND\_SRC\_COLOR
```cj
public static let BLEND_SRC_COLOR: UInt64 = 0x0000000000003000
```


### let BLEND\_ZERO
```cj
public static let BLEND_ZERO: UInt64 = 0x0000000000001000
```
---- 混合因子 ----

### let CONSERVATIVE\_RASTER
```cj
public static let CONSERVATIVE_RASTER: UInt64 = 0x0400000000000000
```
保守光栅化

### let CULL\_CCW
```cj
public static let CULL_CCW: UInt64 = 0x0000002000000000
```


### let CULL\_CW
```cj
public static let CULL_CW: UInt64 = 0x0000001000000000
```
---- 剔除与正面朝向 ----

### let DEFAULT
```cj
public static let DEFAULT: UInt64 = 0x000100410000003F
```
默认渲染状态（写 RGB+Z、深度测试 LESS、剔除 CW、三角形列表）

### let DEPTH\_TEST\_ALWAYS
```cj
public static let DEPTH_TEST_ALWAYS: UInt64 = 0x0000000000000080
```


### let DEPTH\_TEST\_EQUAL
```cj
public static let DEPTH_TEST_EQUAL: UInt64 = 0x0000000000000030
```


### let DEPTH\_TEST\_GEQUAL
```cj
public static let DEPTH_TEST_GEQUAL: UInt64 = 0x0000000000000040
```


### let DEPTH\_TEST\_GREATER
```cj
public static let DEPTH_TEST_GREATER: UInt64 = 0x0000000000000050
```


### let DEPTH\_TEST\_LEQUAL
```cj
public static let DEPTH_TEST_LEQUAL: UInt64 = 0x0000000000000020
```


### let DEPTH\_TEST\_LESS
```cj
public static let DEPTH_TEST_LESS: UInt64 = 0x0000000000000010
```
---- 深度测试 ----

### let DEPTH\_TEST\_NEVER
```cj
public static let DEPTH_TEST_NEVER: UInt64 = 0x0000000000000070
```


### let DEPTH\_TEST\_NOTEQUAL
```cj
public static let DEPTH_TEST_NOTEQUAL: UInt64 = 0x0000000000000060
```


### let FRONT\_CCW
```cj
public static let FRONT_CCW: UInt64 = 0x0000008000000000
```
逆时针为正面

### let LINEAA
```cj
public static let LINEAA: UInt64 = 0x0200000000000000
```
线段抗锯齿

### let MSAA
```cj
public static let MSAA: UInt64 = 0x0100000000000000
```
MSAA 多重采样

### let NONE
```cj
public static let NONE: UInt64 = 0x0000000000000000
```
无状态

### let PT\_LINESTRIP
```cj
public static let PT_LINESTRIP: UInt64 = 0x0003000000000000
```


### let PT\_LINES
```cj
public static let PT_LINES: UInt64 = 0x0002000000000000
```


### let PT\_POINTS
```cj
public static let PT_POINTS: UInt64 = 0x0004000000000000
```


### let PT\_TRISTRIP
```cj
public static let PT_TRISTRIP: UInt64 = 0x0001000000000000
```
---- 图元类型（三角形列表为默认，无须设置） ----

### let WRITE\_A
```cj
public static let WRITE_A: UInt64 = 0x0000000000000008
```


### let WRITE\_B
```cj
public static let WRITE_B: UInt64 = 0x0000000000000004
```


### let WRITE\_G
```cj
public static let WRITE_G: UInt64 = 0x0000000000000002
```


### let WRITE\_RGB
```cj
public static let WRITE_RGB: UInt64 = 0x0000000000000007
```


### let WRITE\_R
```cj
public static let WRITE_R: UInt64 = 0x0000000000000001
```
---- 写入掩码 ----

### let WRITE\_Z
```cj
public static let WRITE_Z: UInt64 = 0x0000004000000000
```


