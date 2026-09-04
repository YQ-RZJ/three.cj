# 类
## class BgfxConstants
```cj
public class BgfxConstants
```
bgfx 常量映射

### func convertBlendFactor\(Int64\)
```cj
public static func convertBlendFactor(factor: Int64): UInt64
```
将 three.js 混合因子转换为 bgfx 混合因子

参数: 

|名称|类型|描述|
|---|---|---|
|factor|Int64|three.js 混合因子常量|

返回: 

- bgfx 混合因子

### func convertBlendFunc\(Int64,Int64,Int64,Int64\)
```cj
public static func convertBlendFunc(srcFactor: Int64, dstFactor: Int64, srcAlphaFactor: Int64, dstAlphaFactor: Int64): UInt64
```
将 three.js 混合模式转换为 bgfx 混合状态

参数: 

|名称|类型|描述|
|---|---|---|
|srcFactor|Int64|源混合因子dstFactor 目标混合因子srcAlphaFactor 源 alpha 混合因子dstAlphaFactor 目标 alpha 混合因子|
|dstFactor|Int64||
|srcAlphaFactor|Int64||
|dstAlphaFactor|Int64||

返回: 

- bgfx 混合状态

### func convertCullMode\(Int64\)
```cj
public static func convertCullMode(side: Int64): UInt64
```
将 three.js 侧面转换为 bgfx 剔除模式

参数: 

|名称|类型|描述|
|---|---|---|
|side|Int64|three.js 侧面常量|

返回: 

- bgfx 剔除模式标志

### func convertDepthFunc\(Int64\)
```cj
public static func convertDepthFunc(depthFunc: Int64): UInt64
```
将 three.js 深度测试模式转换为 bgfx 状态标志

参数: 

|名称|类型|描述|
|---|---|---|
|depthFunc|Int64|three.js 深度测试常量|

返回: 

- bgfx 深度测试状态标志

### let BLEND\_DST\_ALPHA
```cj
public static let BLEND_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_DST_ALPHA
```
混合因子：目标 alpha

### let BLEND\_DST\_COLOR
```cj
public static let BLEND_DST_COLOR: UInt64 = bgfx.STATE_BLEND_DST_COLOR
```
混合因子：目标颜色

### let BLEND\_EQUATION\_ADD
```cj
public static let BLEND_EQUATION_ADD: UInt64 = bgfx.STATE_BLEND_EQUATION_ADD
```
混合方程：加

### let BLEND\_EQUATION\_MAX
```cj
public static let BLEND_EQUATION_MAX: UInt64 = bgfx.STATE_BLEND_EQUATION_MAX
```
混合方程：最大

### let BLEND\_EQUATION\_MIN
```cj
public static let BLEND_EQUATION_MIN: UInt64 = bgfx.STATE_BLEND_EQUATION_MIN
```
混合方程：最小

### let BLEND\_EQUATION\_REVERSE\_SUBTRACT
```cj
public static let BLEND_EQUATION_REVERSE_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_REVSUB
```
混合方程：反减

### let BLEND\_EQUATION\_SUBTRACT
```cj
public static let BLEND_EQUATION_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_SUB
```
混合方程：减

### let BLEND\_ONE
```cj
public static let BLEND_ONE: UInt64 = bgfx.STATE_BLEND_ONE
```
混合因子：一

### let BLEND\_ONE\_MINUS\_DST\_ALPHA
```cj
public static let BLEND_ONE_MINUS_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_DST_ALPHA
```
混合因子：一减目标 alpha

### let BLEND\_ONE\_MINUS\_DST\_COLOR
```cj
public static let BLEND_ONE_MINUS_DST_COLOR: UInt64 = bgfx.STATE_BLEND_INV_DST_COLOR
```
混合因子：一减目标颜色

### let BLEND\_ONE\_MINUS\_SRC\_ALPHA
```cj
public static let BLEND_ONE_MINUS_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_SRC_ALPHA
```
混合因子：一减源 alpha

### let BLEND\_ONE\_MINUS\_SRC\_COLOR
```cj
public static let BLEND_ONE_MINUS_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_INV_SRC_COLOR
```
混合因子：一减源颜色

### let BLEND\_SRC\_ALPHA
```cj
public static let BLEND_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA
```
混合因子：源 alpha

### let BLEND\_SRC\_ALPHA\_SATURATE
```cj
public static let BLEND_SRC_ALPHA_SATURATE: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA_SAT
```
混合因子：源 alpha 饱和

### let BLEND\_SRC\_COLOR
```cj
public static let BLEND_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_SRC_COLOR
```
混合因子：源颜色

### let BLEND\_ZERO
```cj
public static let BLEND_ZERO: UInt64 = bgfx.STATE_BLEND_ZERO
```
混合因子：零

### let CLEAR\_COLOR
```cj
public static let CLEAR_COLOR: UInt16 = bgfx.CLEAR_COLOR
```
清除颜色

### let CLEAR\_DEPTH
```cj
public static let CLEAR_DEPTH: UInt16 = bgfx.CLEAR_DEPTH
```
清除深度

### let CLEAR\_NONE
```cj
public static let CLEAR_NONE: UInt16 = bgfx.CLEAR_NONE
```
无清除

### let CLEAR\_STENCIL
```cj
public static let CLEAR_STENCIL: UInt16 = bgfx.CLEAR_STENCIL
```
清除模板

### let CONSERVATIVE\_RASTER
```cj
public static let CONSERVATIVE_RASTER: UInt64 = bgfx.STATE_CONSERVATIVE_RASTER
```
保守光栅化

### let CULL\_CCW
```cj
public static let CULL_CCW: UInt64 = bgfx.STATE_CULL_CCW
```
逆时针剔除（正面剔除）

### let CULL\_CW
```cj
public static let CULL_CW: UInt64 = bgfx.STATE_CULL_CW
```
顺时针剔除（背面剔除）

### let DEBUG\_NONE
```cj
public static let DEBUG_NONE: UInt32 = bgfx.DEBUG_NONE
```
无调试标志

### let DEBUG\_WIREFRAME
```cj
public static let DEBUG_WIREFRAME: UInt32 = bgfx.DEBUG_WIREFRAME
```
线框模式

### let DEFAULT\_STATE
```cj
public static let DEFAULT_STATE: UInt64 = bgfx.STATE_DEFAULT
```
默认状态

### let DEPTH\_TEST\_ALWAYS
```cj
public static let DEPTH_TEST_ALWAYS: UInt64 = bgfx.STATE_DEPTH_TEST_ALWAYS
```
深度测试：始终通过

### let DEPTH\_TEST\_EQUAL
```cj
public static let DEPTH_TEST_EQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_EQUAL
```
深度测试：等于

### let DEPTH\_TEST\_GEQUAL
```cj
public static let DEPTH_TEST_GEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_GEQUAL
```
深度测试：大于等于

### let DEPTH\_TEST\_GREATER
```cj
public static let DEPTH_TEST_GREATER: UInt64 = bgfx.STATE_DEPTH_TEST_GREATER
```
深度测试：大于

### let DEPTH\_TEST\_LEQUAL
```cj
public static let DEPTH_TEST_LEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_LEQUAL
```
深度测试：小于等于

### let DEPTH\_TEST\_LESS
```cj
public static let DEPTH_TEST_LESS: UInt64 = bgfx.STATE_DEPTH_TEST_LESS
```
深度测试：小于

### let DEPTH\_TEST\_NEVER
```cj
public static let DEPTH_TEST_NEVER: UInt64 = bgfx.STATE_DEPTH_TEST_NEVER
```
深度测试：从不通过

### let DEPTH\_TEST\_NOTEQUAL
```cj
public static let DEPTH_TEST_NOTEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_NOTEQUAL
```
深度测试：不等于

### let FRONT\_CCW
```cj
public static let FRONT_CCW: UInt64 = bgfx.STATE_FRONT_CCW
```
逆时针为正面

### let LINEAA
```cj
public static let LINEAA: UInt64 = bgfx.STATE_LINEAA
```
线框抗锯齿

### let LINES
```cj
public static let LINES: UInt64 = bgfx.STATE_PT_LINES
```
线段

### let LINE\_STRIP
```cj
public static let LINE_STRIP: UInt64 = bgfx.STATE_PT_LINESTRIP
```
线段条带

### let MSAA
```cj
public static let MSAA: UInt64 = bgfx.STATE_MSAA
```
MSAA 抗锯齿

### let NONE
```cj
public static let NONE: UInt64 = bgfx.STATE_NONE
```
无状态

### let POINTS
```cj
public static let POINTS: UInt64 = bgfx.STATE_PT_POINTS
```
点

### let SAMPLER\_COMPARE\_ALWAYS
```cj
public static let SAMPLER_COMPARE_ALWAYS: UInt32 = bgfx.SAMPLER_COMPARE_ALWAYS
```
采样器比较模式：始终

### let SAMPLER\_COMPARE\_EQUAL
```cj
public static let SAMPLER_COMPARE_EQUAL: UInt32 = bgfx.SAMPLER_COMPARE_EQUAL
```
采样器比较模式：等于

### let SAMPLER\_COMPARE\_GEQUAL
```cj
public static let SAMPLER_COMPARE_GEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_GEQUAL
```
采样器比较模式：大于等于

### let SAMPLER\_COMPARE\_GREATER
```cj
public static let SAMPLER_COMPARE_GREATER: UInt32 = bgfx.SAMPLER_COMPARE_GREATER
```
采样器比较模式：大于

### let SAMPLER\_COMPARE\_LEQUAL
```cj
public static let SAMPLER_COMPARE_LEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_LEQUAL
```
采样器比较模式：小于等于

### let SAMPLER\_COMPARE\_LESS
```cj
public static let SAMPLER_COMPARE_LESS: UInt32 = bgfx.SAMPLER_COMPARE_LESS
```
采样器比较模式：小于

### let SAMPLER\_COMPARE\_NEVER
```cj
public static let SAMPLER_COMPARE_NEVER: UInt32 = bgfx.SAMPLER_COMPARE_NEVER
```
采样器比较模式：从不

### let SAMPLER\_COMPARE\_NOTEQUAL
```cj
public static let SAMPLER_COMPARE_NOTEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_NOTEQUAL
```
采样器比较模式：不等于

### let SAMPLER\_MAG\_ANISOTROPIC
```cj
public static let SAMPLER_MAG_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MAG_ANISOTROPIC
```
各向异性最大化过滤

### let SAMPLER\_MAG\_POINT
```cj
public static let SAMPLER_MAG_POINT: UInt32 = bgfx.SAMPLER_MAG_POINT
```
放大过滤：最近邻

### let SAMPLER\_MIN\_ANISOTROPIC
```cj
public static let SAMPLER_MIN_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MIN_ANISOTROPIC
```
各向异性最小化过滤

### let SAMPLER\_MIN\_POINT
```cj
public static let SAMPLER_MIN_POINT: UInt32 = bgfx.SAMPLER_MIN_POINT
```
缩小过滤：最近邻

### let SAMPLER\_MIP\_POINT
```cj
public static let SAMPLER_MIP_POINT: UInt32 = bgfx.SAMPLER_MIP_POINT
```
mip 过滤：最近邻

### let SAMPLER\_U\_BORDER
```cj
public static let SAMPLER_U_BORDER: UInt32 = bgfx.SAMPLER_U_BORDER
```
U 轴边界色

### let SAMPLER\_U\_CLAMP
```cj
public static let SAMPLER_U_CLAMP: UInt32 = bgfx.SAMPLER_U_CLAMP
```
U 轴钳制

### let SAMPLER\_U\_MIRROR
```cj
public static let SAMPLER_U_MIRROR: UInt32 = bgfx.SAMPLER_U_MIRROR
```
U 轴镜像

### let SAMPLER\_V\_BORDER
```cj
public static let SAMPLER_V_BORDER: UInt32 = bgfx.SAMPLER_V_BORDER
```
V 轴边界色

### let SAMPLER\_V\_CLAMP
```cj
public static let SAMPLER_V_CLAMP: UInt32 = bgfx.SAMPLER_V_CLAMP
```
V 轴钳制

### let SAMPLER\_V\_MIRROR
```cj
public static let SAMPLER_V_MIRROR: UInt32 = bgfx.SAMPLER_V_MIRROR
```
V 轴镜像

### let SAMPLER\_W\_CLAMP
```cj
public static let SAMPLER_W_CLAMP: UInt32 = bgfx.SAMPLER_W_CLAMP
```
W 轴钳制

### let STENCIL\_OP\_FAIL\_S\_KEEP
```cj
public static let STENCIL_OP_FAIL_S_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_S_KEEP
```
模板操作 FAIL 阶段：保持

### let STENCIL\_OP\_FAIL\_Z\_KEEP
```cj
public static let STENCIL_OP_FAIL_Z_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_Z_KEEP
```
模板操作 ZFAIL 阶段：保持

### let STENCIL\_OP\_PASS\_Z\_KEEP
```cj
public static let STENCIL_OP_PASS_Z_KEEP: UInt32 = bgfx.STENCIL_OP_PASS_Z_KEEP
```
模板操作 PASS 阶段：保持

### let STENCIL\_OP\_PASS\_Z\_REPLACE
```cj
public static let STENCIL_OP_PASS_Z_REPLACE: UInt32 = bgfx.STENCIL_OP_PASS_Z_REPLACE
```
模板操作 PASS 阶段：替换

### let STENCIL\_TEST\_ALWAYS
```cj
public static let STENCIL_TEST_ALWAYS: UInt32 = bgfx.STENCIL_TEST_ALWAYS
```
模板测试：始终

### let STENCIL\_TEST\_EQUAL
```cj
public static let STENCIL_TEST_EQUAL: UInt32 = bgfx.STENCIL_TEST_EQUAL
```
模板测试：等于

### let STENCIL\_TEST\_GEQUAL
```cj
public static let STENCIL_TEST_GEQUAL: UInt32 = bgfx.STENCIL_TEST_GEQUAL
```
模板测试：大于等于

### let STENCIL\_TEST\_GREATER
```cj
public static let STENCIL_TEST_GREATER: UInt32 = bgfx.STENCIL_TEST_GREATER
```
模板测试：大于

### let STENCIL\_TEST\_LEQUAL
```cj
public static let STENCIL_TEST_LEQUAL: UInt32 = bgfx.STENCIL_TEST_LEQUAL
```
模板测试：小于等于

### let STENCIL\_TEST\_LESS
```cj
public static let STENCIL_TEST_LESS: UInt32 = bgfx.STENCIL_TEST_LESS
```
模板测试：小于等于

### let STENCIL\_TEST\_NEVER
```cj
public static let STENCIL_TEST_NEVER: UInt32 = bgfx.STENCIL_TEST_NEVER
```
模板测试：从不

### let STENCIL\_TEST\_NOTEQUAL
```cj
public static let STENCIL_TEST_NOTEQUAL: UInt32 = bgfx.STENCIL_TEST_NOTEQUAL
```
模板测试：不等于

### let TEXTURE\_BLIT\_DST
```cj
public static let TEXTURE_BLIT_DST: UInt64 = bgfx.TEXTURE_BLIT_DST
```
纹理可作 blit 目标

### let TEXTURE\_FORMAT\_DEPTH
```cj
public static let TEXTURE_FORMAT_DEPTH: UInt32 = bgfx.TextureFormat.D24.value()
```
深度纹理格式

### let TEXTURE\_FORMAT\_DEPTH\_STENCIL
```cj
public static let TEXTURE_FORMAT_DEPTH_STENCIL: UInt32 = bgfx.TextureFormat.D24S8.value()
```
深度模板纹理格式

### let TEXTURE\_FORMAT\_RGBA16F
```cj
public static let TEXTURE_FORMAT_RGBA16F: UInt32 = bgfx.TextureFormat.RGBA16F.value()
```
RGBA16F 纹理格式

### let TEXTURE\_FORMAT\_RGBA32F
```cj
public static let TEXTURE_FORMAT_RGBA32F: UInt32 = bgfx.TextureFormat.RGBA32F.value()
```
RGBA32F 纹理格式

### let TEXTURE\_FORMAT\_RGBA8
```cj
public static let TEXTURE_FORMAT_RGBA8: UInt32 = bgfx.TextureFormat.RGBA8.value()
```
RGBA8 纹理格式

### let TEXTURE\_READ\_BACK
```cj
public static let TEXTURE_READ_BACK: UInt64 = bgfx.TEXTURE_READ_BACK
```
纹理回读

### let TEXTURE\_RT
```cj
public static let TEXTURE_RT: UInt64 = bgfx.TEXTURE_RT
```
渲染目标纹理

### let TEXTURE\_SRGB
```cj
public static let TEXTURE_SRGB: UInt64 = bgfx.TEXTURE_SRGB
```
纹理 sRGB 编码

### let TRIANGLES
```cj
public static let TRIANGLES: UInt64 = 0u64
```
三角形

### let TRIANGLE\_STRIP
```cj
public static let TRIANGLE_STRIP: UInt64 = bgfx.STATE_PT_TRISTRIP
```
三角形条带

### let WRITE\_A
```cj
public static let WRITE_A: UInt64 = bgfx.STATE_WRITE_A
```
写入 A 通道

### let WRITE\_B
```cj
public static let WRITE_B: UInt64 = bgfx.STATE_WRITE_B
```
写入 B 通道

### let WRITE\_G
```cj
public static let WRITE_G: UInt64 = bgfx.STATE_WRITE_G
```
写入 G 通道

### let WRITE\_MASK
```cj
public static let WRITE_MASK: UInt64 = bgfx.STATE_WRITE_MASK
```
写入掩码

### let WRITE\_RGB
```cj
public static let WRITE_RGB: UInt64 = bgfx.STATE_WRITE_RGB
```
写入 RGB 通道

### let WRITE\_R
```cj
public static let WRITE_R: UInt64 = bgfx.STATE_WRITE_R
```
写入 R 通道

### let WRITE\_Z
```cj
public static let WRITE_Z: UInt64 = bgfx.STATE_WRITE_Z
```
写入深度

