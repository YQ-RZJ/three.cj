# Class
## class BgfxConstants
```cj
public class BgfxConstants
```
bgfx constants mapping

### func convertBlendFactor\(Int64\)
```cj
public static func convertBlendFactor(factor: Int64): UInt64
```
Converts three.js blend factor to bgfx blend factor

Parameter: 

|Name|Type|Describe|
|---|---|---|
|factor|Int64|Three.js blend factor constant|

Return: 

- bgfx blend factor

### func convertBlendFunc\(Int64,Int64,Int64,Int64\)
```cj
public static func convertBlendFunc(srcFactor: Int64, dstFactor: Int64, srcAlphaFactor: Int64, dstAlphaFactor: Int64): UInt64
```
Converts three.js blend mode to bgfx blend state

Parameter: 

|Name|Type|Describe|
|---|---|---|
|srcFactor|Int64|Source blend factordstFactor Destination blend factorsrcAlphaFactor Source alpha blend factordstAlphaFactor Destination alpha blend factor|
|dstFactor|Int64||
|srcAlphaFactor|Int64||
|dstAlphaFactor|Int64||

Return: 

- bgfx blend state

### func convertCullMode\(Int64\)
```cj
public static func convertCullMode(side: Int64): UInt64
```
Converts three.js side to bgfx cull mode

Parameter: 

|Name|Type|Describe|
|---|---|---|
|side|Int64|Three.js side constant|

Return: 

- bgfx cull mode flag

### func convertDepthFunc\(Int64\)
```cj
public static func convertDepthFunc(depthFunc: Int64): UInt64
```
Converts three.js depth test mode to bgfx state flag

Parameter: 

|Name|Type|Describe|
|---|---|---|
|depthFunc|Int64|Three.js depth test constant|

Return: 

- bgfx depth test state flag

### let BLEND\_DST\_ALPHA
```cj
public static let BLEND_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_DST_ALPHA
```
Blend factor: dst alpha

### let BLEND\_DST\_COLOR
```cj
public static let BLEND_DST_COLOR: UInt64 = bgfx.STATE_BLEND_DST_COLOR
```
Blend factor: dst color

### let BLEND\_EQUATION\_ADD
```cj
public static let BLEND_EQUATION_ADD: UInt64 = bgfx.STATE_BLEND_EQUATION_ADD
```
Blend equation: add

### let BLEND\_EQUATION\_MAX
```cj
public static let BLEND_EQUATION_MAX: UInt64 = bgfx.STATE_BLEND_EQUATION_MAX
```
Blend equation: max

### let BLEND\_EQUATION\_MIN
```cj
public static let BLEND_EQUATION_MIN: UInt64 = bgfx.STATE_BLEND_EQUATION_MIN
```
Blend equation: min

### let BLEND\_EQUATION\_REVERSE\_SUBTRACT
```cj
public static let BLEND_EQUATION_REVERSE_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_REVSUB
```
Blend equation: reverse subtract

### let BLEND\_EQUATION\_SUBTRACT
```cj
public static let BLEND_EQUATION_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_SUB
```
Blend equation: subtract

### let BLEND\_ONE
```cj
public static let BLEND_ONE: UInt64 = bgfx.STATE_BLEND_ONE
```
Blend factor: one

### let BLEND\_ONE\_MINUS\_DST\_ALPHA
```cj
public static let BLEND_ONE_MINUS_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_DST_ALPHA
```
Blend factor: one minus dst alpha

### let BLEND\_ONE\_MINUS\_DST\_COLOR
```cj
public static let BLEND_ONE_MINUS_DST_COLOR: UInt64 = bgfx.STATE_BLEND_INV_DST_COLOR
```
Blend factor: one minus dst color

### let BLEND\_ONE\_MINUS\_SRC\_ALPHA
```cj
public static let BLEND_ONE_MINUS_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_SRC_ALPHA
```
Blend factor: one minus src alpha

### let BLEND\_ONE\_MINUS\_SRC\_COLOR
```cj
public static let BLEND_ONE_MINUS_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_INV_SRC_COLOR
```
Blend factor: one minus src color

### let BLEND\_SRC\_ALPHA
```cj
public static let BLEND_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA
```
Blend factor: src alpha

### let BLEND\_SRC\_ALPHA\_SATURATE
```cj
public static let BLEND_SRC_ALPHA_SATURATE: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA_SAT
```
Blend factor: src alpha saturate

### let BLEND\_SRC\_COLOR
```cj
public static let BLEND_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_SRC_COLOR
```
Blend factor: src color

### let BLEND\_ZERO
```cj
public static let BLEND_ZERO: UInt64 = bgfx.STATE_BLEND_ZERO
```
Blend factor: zero

### let CLEAR\_COLOR
```cj
public static let CLEAR_COLOR: UInt16 = bgfx.CLEAR_COLOR
```
Clear color

### let CLEAR\_DEPTH
```cj
public static let CLEAR_DEPTH: UInt16 = bgfx.CLEAR_DEPTH
```
Clear depth

### let CLEAR\_NONE
```cj
public static let CLEAR_NONE: UInt16 = bgfx.CLEAR_NONE
```
Clear none

### let CLEAR\_STENCIL
```cj
public static let CLEAR_STENCIL: UInt16 = bgfx.CLEAR_STENCIL
```
Clear stencil

### let CONSERVATIVE\_RASTER
```cj
public static let CONSERVATIVE_RASTER: UInt64 = bgfx.STATE_CONSERVATIVE_RASTER
```
Conservative rasterization

### let CULL\_CCW
```cj
public static let CULL_CCW: UInt64 = bgfx.STATE_CULL_CCW
```
Counter-clockwise culling (front-face culling)

### let CULL\_CW
```cj
public static let CULL_CW: UInt64 = bgfx.STATE_CULL_CW
```
Clockwise culling (back-face culling)

### let DEBUG\_NONE
```cj
public static let DEBUG_NONE: UInt32 = bgfx.DEBUG_NONE
```
No debug flags

### let DEBUG\_WIREFRAME
```cj
public static let DEBUG_WIREFRAME: UInt32 = bgfx.DEBUG_WIREFRAME
```
Wireframe mode

### let DEFAULT\_STATE
```cj
public static let DEFAULT_STATE: UInt64 = bgfx.STATE_DEFAULT
```
Default state

### let DEPTH\_TEST\_ALWAYS
```cj
public static let DEPTH_TEST_ALWAYS: UInt64 = bgfx.STATE_DEPTH_TEST_ALWAYS
```
Depth test: always

### let DEPTH\_TEST\_EQUAL
```cj
public static let DEPTH_TEST_EQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_EQUAL
```
Depth test: equal

### let DEPTH\_TEST\_GEQUAL
```cj
public static let DEPTH_TEST_GEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_GEQUAL
```
Depth test: greater-or-equal

### let DEPTH\_TEST\_GREATER
```cj
public static let DEPTH_TEST_GREATER: UInt64 = bgfx.STATE_DEPTH_TEST_GREATER
```
Depth test: greater

### let DEPTH\_TEST\_LEQUAL
```cj
public static let DEPTH_TEST_LEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_LEQUAL
```
Depth test: less-or-equal

### let DEPTH\_TEST\_LESS
```cj
public static let DEPTH_TEST_LESS: UInt64 = bgfx.STATE_DEPTH_TEST_LESS
```
Depth test: less

### let DEPTH\_TEST\_NEVER
```cj
public static let DEPTH_TEST_NEVER: UInt64 = bgfx.STATE_DEPTH_TEST_NEVER
```
Depth test: never

### let DEPTH\_TEST\_NOTEQUAL
```cj
public static let DEPTH_TEST_NOTEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_NOTEQUAL
```
Depth test: not-equal

### let FRONT\_CCW
```cj
public static let FRONT_CCW: UInt64 = bgfx.STATE_FRONT_CCW
```
Counter-clockwise front face

### let LINEAA
```cj
public static let LINEAA: UInt64 = bgfx.STATE_LINEAA
```
Line anti-aliasing

### let LINES
```cj
public static let LINES: UInt64 = bgfx.STATE_PT_LINES
```
Lines

### let LINE\_STRIP
```cj
public static let LINE_STRIP: UInt64 = bgfx.STATE_PT_LINESTRIP
```
Line strip

### let MSAA
```cj
public static let MSAA: UInt64 = bgfx.STATE_MSAA
```
MSAA anti-aliasing

### let NONE
```cj
public static let NONE: UInt64 = bgfx.STATE_NONE
```
None state

### let POINTS
```cj
public static let POINTS: UInt64 = bgfx.STATE_PT_POINTS
```
Points

### let SAMPLER\_COMPARE\_ALWAYS
```cj
public static let SAMPLER_COMPARE_ALWAYS: UInt32 = bgfx.SAMPLER_COMPARE_ALWAYS
```
Sampler compare: always

### let SAMPLER\_COMPARE\_EQUAL
```cj
public static let SAMPLER_COMPARE_EQUAL: UInt32 = bgfx.SAMPLER_COMPARE_EQUAL
```
Sampler compare: equal

### let SAMPLER\_COMPARE\_GEQUAL
```cj
public static let SAMPLER_COMPARE_GEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_GEQUAL
```
Sampler compare: greater-or-equal

### let SAMPLER\_COMPARE\_GREATER
```cj
public static let SAMPLER_COMPARE_GREATER: UInt32 = bgfx.SAMPLER_COMPARE_GREATER
```
Sampler compare: greater

### let SAMPLER\_COMPARE\_LEQUAL
```cj
public static let SAMPLER_COMPARE_LEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_LEQUAL
```
Sampler compare: less-or-equal

### let SAMPLER\_COMPARE\_LESS
```cj
public static let SAMPLER_COMPARE_LESS: UInt32 = bgfx.SAMPLER_COMPARE_LESS
```
Sampler compare: less

### let SAMPLER\_COMPARE\_NEVER
```cj
public static let SAMPLER_COMPARE_NEVER: UInt32 = bgfx.SAMPLER_COMPARE_NEVER
```
Sampler compare: never

### let SAMPLER\_COMPARE\_NOTEQUAL
```cj
public static let SAMPLER_COMPARE_NOTEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_NOTEQUAL
```
Sampler compare: not-equal

### let SAMPLER\_MAG\_ANISOTROPIC
```cj
public static let SAMPLER_MAG_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MAG_ANISOTROPIC
```
Anisotropic mag filter

### let SAMPLER\_MAG\_POINT
```cj
public static let SAMPLER_MAG_POINT: UInt32 = bgfx.SAMPLER_MAG_POINT
```
Mag filter: nearest

### let SAMPLER\_MIN\_ANISOTROPIC
```cj
public static let SAMPLER_MIN_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MIN_ANISOTROPIC
```
Anisotropic min filter

### let SAMPLER\_MIN\_POINT
```cj
public static let SAMPLER_MIN_POINT: UInt32 = bgfx.SAMPLER_MIN_POINT
```
Min filter: nearest

### let SAMPLER\_MIP\_POINT
```cj
public static let SAMPLER_MIP_POINT: UInt32 = bgfx.SAMPLER_MIP_POINT
```
Mip filter: nearest

### let SAMPLER\_U\_BORDER
```cj
public static let SAMPLER_U_BORDER: UInt32 = bgfx.SAMPLER_U_BORDER
```
U axis border

### let SAMPLER\_U\_CLAMP
```cj
public static let SAMPLER_U_CLAMP: UInt32 = bgfx.SAMPLER_U_CLAMP
```
U axis clamp

### let SAMPLER\_U\_MIRROR
```cj
public static let SAMPLER_U_MIRROR: UInt32 = bgfx.SAMPLER_U_MIRROR
```
U axis mirror

### let SAMPLER\_V\_BORDER
```cj
public static let SAMPLER_V_BORDER: UInt32 = bgfx.SAMPLER_V_BORDER
```
V axis border

### let SAMPLER\_V\_CLAMP
```cj
public static let SAMPLER_V_CLAMP: UInt32 = bgfx.SAMPLER_V_CLAMP
```
V axis clamp

### let SAMPLER\_V\_MIRROR
```cj
public static let SAMPLER_V_MIRROR: UInt32 = bgfx.SAMPLER_V_MIRROR
```
V axis mirror

### let SAMPLER\_W\_CLAMP
```cj
public static let SAMPLER_W_CLAMP: UInt32 = bgfx.SAMPLER_W_CLAMP
```
W axis clamp

### let STENCIL\_OP\_FAIL\_S\_KEEP
```cj
public static let STENCIL_OP_FAIL_S_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_S_KEEP
```
Stencil op fail-stencil: keep

### let STENCIL\_OP\_FAIL\_Z\_KEEP
```cj
public static let STENCIL_OP_FAIL_Z_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_Z_KEEP
```
Stencil op fail-depth: keep

### let STENCIL\_OP\_PASS\_Z\_KEEP
```cj
public static let STENCIL_OP_PASS_Z_KEEP: UInt32 = bgfx.STENCIL_OP_PASS_Z_KEEP
```
Stencil op pass-depth: keep

### let STENCIL\_OP\_PASS\_Z\_REPLACE
```cj
public static let STENCIL_OP_PASS_Z_REPLACE: UInt32 = bgfx.STENCIL_OP_PASS_Z_REPLACE
```
Stencil op pass-depth: replace

### let STENCIL\_TEST\_ALWAYS
```cj
public static let STENCIL_TEST_ALWAYS: UInt32 = bgfx.STENCIL_TEST_ALWAYS
```
Stencil test: always

### let STENCIL\_TEST\_EQUAL
```cj
public static let STENCIL_TEST_EQUAL: UInt32 = bgfx.STENCIL_TEST_EQUAL
```
Stencil test: equal

### let STENCIL\_TEST\_GEQUAL
```cj
public static let STENCIL_TEST_GEQUAL: UInt32 = bgfx.STENCIL_TEST_GEQUAL
```
Stencil test: greater-or-equal

### let STENCIL\_TEST\_GREATER
```cj
public static let STENCIL_TEST_GREATER: UInt32 = bgfx.STENCIL_TEST_GREATER
```
Stencil test: greater

### let STENCIL\_TEST\_LEQUAL
```cj
public static let STENCIL_TEST_LEQUAL: UInt32 = bgfx.STENCIL_TEST_LEQUAL
```
Stencil test: less-or-equal

### let STENCIL\_TEST\_LESS
```cj
public static let STENCIL_TEST_LESS: UInt32 = bgfx.STENCIL_TEST_LESS
```
Stencil test: less-or-equal

### let STENCIL\_TEST\_NEVER
```cj
public static let STENCIL_TEST_NEVER: UInt32 = bgfx.STENCIL_TEST_NEVER
```
Stencil test: never

### let STENCIL\_TEST\_NOTEQUAL
```cj
public static let STENCIL_TEST_NOTEQUAL: UInt32 = bgfx.STENCIL_TEST_NOTEQUAL
```
Stencil test: not-equal

### let TEXTURE\_BLIT\_DST
```cj
public static let TEXTURE_BLIT_DST: UInt64 = bgfx.TEXTURE_BLIT_DST
```
Texture blit destination

### let TEXTURE\_FORMAT\_DEPTH
```cj
public static let TEXTURE_FORMAT_DEPTH: UInt32 = bgfx.TextureFormat.D24S8.value()
```
深度附件（创建出的 FB 为 INVALID）；D24S8 在各后端均可渲染、可比较采样。

### let TEXTURE\_FORMAT\_DEPTH\_STENCIL
```cj
public static let TEXTURE_FORMAT_DEPTH_STENCIL: UInt32 = bgfx.TextureFormat.D24S8.value()
```
Depth-stencil texture format

### let TEXTURE\_FORMAT\_RGBA16F
```cj
public static let TEXTURE_FORMAT_RGBA16F: UInt32 = bgfx.TextureFormat.RGBA16F.value()
```
RGBA16F texture format

### let TEXTURE\_FORMAT\_RGBA32F
```cj
public static let TEXTURE_FORMAT_RGBA32F: UInt32 = bgfx.TextureFormat.RGBA32F.value()
```
RGBA32F texture format

### let TEXTURE\_FORMAT\_RGBA8
```cj
public static let TEXTURE_FORMAT_RGBA8: UInt32 = bgfx.TextureFormat.RGBA8.value()
```
RGBA8 texture format

### let TEXTURE\_READ\_BACK
```cj
public static let TEXTURE_READ_BACK: UInt64 = bgfx.TEXTURE_READ_BACK
```
Texture read back

### let TEXTURE\_RT
```cj
public static let TEXTURE_RT: UInt64 = bgfx.TEXTURE_RT
```
Render target texture

### let TEXTURE\_SRGB
```cj
public static let TEXTURE_SRGB: UInt64 = bgfx.TEXTURE_SRGB
```
Texture sRGB encoding

### let TRIANGLES
```cj
public static let TRIANGLES: UInt64 = 0u64
```
Triangles

### let TRIANGLE\_STRIP
```cj
public static let TRIANGLE_STRIP: UInt64 = bgfx.STATE_PT_TRISTRIP
```
Triangle strip

### let WRITE\_A
```cj
public static let WRITE_A: UInt64 = bgfx.STATE_WRITE_A
```
Write A channel

### let WRITE\_B
```cj
public static let WRITE_B: UInt64 = bgfx.STATE_WRITE_B
```
Write B channel

### let WRITE\_G
```cj
public static let WRITE_G: UInt64 = bgfx.STATE_WRITE_G
```
Write G channel

### let WRITE\_MASK
```cj
public static let WRITE_MASK: UInt64 = bgfx.STATE_WRITE_MASK
```
Write mask

### let WRITE\_RGB
```cj
public static let WRITE_RGB: UInt64 = bgfx.STATE_WRITE_RGB
```
Write RGB channels

### let WRITE\_R
```cj
public static let WRITE_R: UInt64 = bgfx.STATE_WRITE_R
```
Write R channel

### let WRITE\_Z
```cj
public static let WRITE_Z: UInt64 = bgfx.STATE_WRITE_Z
```
Write depth

