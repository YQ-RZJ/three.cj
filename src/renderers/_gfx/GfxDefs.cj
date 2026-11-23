/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] GfxDefs 渲染抽象层枚举、状态位与描述结构
 * @brief[zh-cn] 引擎自有的后端无关渲染词汇：纹理格式/标志、缓冲标志、绘制状态、
 * 模板/清除/重置标志、uniform 与顶点属性枚举、能力与统计摘要
 * @explain[zh-cn] 本文件是抽象层契约（IRenderBackend 等）签名所用的词汇底座，
 * 全部为引擎自有定义，不引用任何后端绑定包。设计约束：
 * - 枚举成员的 value() 数值对齐 GPU 通用约定（与本引擎唯一后端的位序一致），
 *   后端实现包内做穷尽 match 翻译；
 * - 位组合标志以类型关联静态成员表达（非散落顶层常量）；
 * - 引擎既有的顶层格式常量（three.utils.constants 的 RGBAFormat、
 *   RGB_S3TC_DXT1_Format 等）不动，它们是引擎层格式词汇，由后端实现包翻译
 *   为本文件的 GfxTextureFormat；
 * - 除 GfxRendererType 与 GfxCapsSummary（查询 API 返回类型，经确认公开）外，
 *   其余声明一律 internal：引擎全部子包可见、模块外不可见。
 *
 * @file[en] GfxDefs render abstraction enums, state bits and descriptor structs
 * @brief[en] Engine-owned backend-agnostic renderers vocabulary: texture formats/flags,
 * buffer flags, draw states, stencil/clear/reset flags, uniform and vertex attribute
 * enums, capability and statistics summaries
 * @explain[en] This file is the vocabulary base of the abstraction contract
 * (IRenderBackend etc.), fully engine-owned without referencing any backend binding
 * package. Design constraints:
 * - Enum member value() numbers follow common GPU conventions (identical to the bit
 *   order of this engine's only backend); the backend implementation package
 *   translates them via exhaustive matches;
 * - Bit-combination flags are expressed as type-associated static members (not
 *   scattered top-level constants);
 * - Existing engine top-level format constants (RGBAFormat, RGB_S3TC_DXT1_Format,
 *   etc. in three.utils.constants) remain untouched: they are the engine-layer format
 *   vocabulary, translated to GfxTextureFormat of this file by the backend package;
 * - Except GfxRendererType and GfxCapsSummary (query-API return types, confirmed
 *   public), all declarations are internal: visible to all engine subpackages and
 *   invisible outside the module.
 *
 * @package three
 */
protected package three.renderers._gfx

// ============================================================================
// ===== 纹理格式 =====
// ============================================================================

/**
 * @brief[zh-cn] 纹理像素格式
 * @explain[zh-cn] 覆盖引擎当前全部使用点：渲染目标色/深格式、常见未压缩颜色格式、
 * BC/ETC/ASTC 压缩格式。后端实现包负责到具体后端格式的穷尽翻译。
 *
 * @brief[en] Texture pixel format
 * @explain[en] Covers all current engine usage: render-target color/depth formats,
 * common uncompressed color formats, BC/ETC/ASTC compressed formats. The backend
 * package translates exhaustively to concrete backend formats.
 */
public enum GfxTextureFormat {
    // ---- 压缩格式 ----
    | BC1 /** BC1 (DXT1)，RGB，4bpp */
    | BC2 /** BC2 (DXT3)，RGBA，8bpp */
    | BC3 /** BC3 (DXT5)，RGBA，8bpp */
    | BC4 /** BC4，单通道，4bpp */
    | BC5 /** BC5，双通道，8bpp */
    | BC6H /** BC6H，HDR RGB，8bpp */
    | BC7 /** BC7，高质量 RGBA，8bpp */
    | ETC1 /** ETC1，RGB，4bpp */
    | ETC2 /** ETC2，RGB，4bpp */
    | ETC2A /** ETC2A，RGBA，8bpp */
    | ASTC4X4
    | ASTC5X4
    | ASTC5X5
    | ASTC6X5
    | ASTC6X6
    | ASTC8X5
    | ASTC8X6
    | ASTC8X8
    | ASTC10X5
    | ASTC10X6
    | ASTC10X8
    | ASTC10X10
    | ASTC12X10
    | ASTC12X12
    // ---- 未压缩格式 ----
    | A8 /** 8 位 alpha 通道 */
    | R8 /** 8 位红通道（无符号归一化） */
    | R16 /** 16 位红通道（无符号归一化） */
    | R16I /** 16 位红通道（有符号整数） */
    | R16F /** 16 位红通道（半精度浮点） */
    | RG8 /** 8+8 位 RG（无符号归一化） */
    | RG16F /** 16+16 位 RG（半精度浮点） */
    | RG32I /** 32+32 位 RG（有符号整数） */
    | RGB9E5F /** 9+9+9+5 位 RGB（共享指数浮点） */
    | RGBA8 /** 8+8+8+8 位 RGBA（无符号归一化） */
    | RGBA16F /** 16 位 x4 RGBA（半精度浮点） */
    | RGBA32I /** 32 位 x4 RGBA（有符号整数） */
    | RGBA32F /** 32 位 x4 RGBA（单精度浮点） */
    | RG11B10F /** 11+11+10 位 RGB（无符号浮点） */
    // ---- 深度格式 ----
    | D24 /** 24 位深度 */
    | D24S8 /** 24 位深度 + 8 位模板 */
    | D32 /** 32 位深度 */
    | D32F /** 32 位浮点深度 */

    public func value(): UInt32 {
        match (this) {
            case BC1 => 0
            case BC2 => 1
            case BC3 => 2
            case BC4 => 3
            case BC5 => 5
            case BC6H => 7
            case BC7 => 9
            case ETC1 => 10
            case ETC2 => 11
            case ETC2A => 12
            case ASTC4X4 => 27
            case ASTC5X4 => 28
            case ASTC5X5 => 29
            case ASTC6X5 => 30
            case ASTC6X6 => 31
            case ASTC8X5 => 32
            case ASTC8X6 => 33
            case ASTC8X8 => 34
            case ASTC10X5 => 35
            case ASTC10X6 => 36
            case ASTC10X8 => 37
            case ASTC10X10 => 38
            case ASTC12X10 => 39
            case ASTC12X12 => 40
            case A8 => 43
            case R8 => 44
            case R16 => 48
            case R16I => 49
            case R16F => 51
            case RG8 => 56
            case RG16F => 63
            case RG32I => 65
            case RGB9E5F => 72
            case RGBA8 => 74
            case RGBA16F => 81
            case RGBA32I => 83
            case RGBA32F => 85
            case RG11B10F => 94
            case D24 => 97
            case D24S8 => 98
            case D32 => 99
            case D32F => 102
        }
    }
}

// ============================================================================
// ===== 纹理标志（UInt64 位组合） =====
// ============================================================================

/**
 * @brief[zh-cn] 纹理创建标志（含并入低 32 位的采样器位）
 * @explain[zh-cn] 供 createTexture* 系列的 flags 参数组合使用，
 * 例如 GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_MIN_POINT。
 *
 * @brief[en] Texture creation flags (sampler bits merged into the low 32 bits)
 * @explain[en] Composed for the flags parameter of the createTexture* family, e.g.
 * GfxTextureFlag.RT | GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_MIN_POINT.
 */
public class GfxTextureFlag {
    /** 无标志 */
    public static let NONE: UInt64 = 0x0000000000000000
    /** 渲染目标纹理 */
    public static let RT: UInt64 = 0x0000001000000000
    /** 纹理可作 blit 目标 */
    public static let BLIT_DST: UInt64 = 0x0000400000000000
    /** 渲染目标只写 */
    public static let RT_WRITE_ONLY: UInt64 = 0x0000008000000000
    /** 渲染目标可作 MSAA 采样源 */
    public static let RT_MSAA_SAMPLE: UInt64 = 0x0000000800000000
    /** 渲染目标 MSAA x2/x4/x8/x16 */
    public static let RT_MSAA_X2: UInt64 = 0x0000002000000000
    public static let RT_MSAA_X4: UInt64 = 0x0000003000000000
    public static let RT_MSAA_X8: UInt64 = 0x0000004000000000
    public static let RT_MSAA_X16: UInt64 = 0x0000005000000000
    /** 计算着色器可写 */
    public static let COMPUTE_WRITE: UInt64 = 0x0000100000000000
    /** sRGB 编码 */
    public static let SRGB: UInt64 = 0x0000200000000000
    /** 回读纹理 */
    public static let READ_BACK: UInt64 = 0x0000800000000000
    /** ---- 采样器位（并入低 32 位） ---- */
    public static let SAMPLER_U_MIRROR: UInt64 = 0x0000000000000001
    public static let SAMPLER_U_CLAMP: UInt64 = 0x0000000000000002
    public static let SAMPLER_U_BORDER: UInt64 = 0x0000000000000003
    public static let SAMPLER_V_MIRROR: UInt64 = 0x0000000000000004
    public static let SAMPLER_V_CLAMP: UInt64 = 0x0000000000000008
    public static let SAMPLER_V_BORDER: UInt64 = 0x000000000000000C
    public static let SAMPLER_W_MIRROR: UInt64 = 0x0000000000000010
    public static let SAMPLER_W_CLAMP: UInt64 = 0x0000000000000020
    public static let SAMPLER_W_BORDER: UInt64 = 0x0000000000000030
    public static let SAMPLER_MIN_POINT: UInt64 = 0x0000000000000040
    public static let SAMPLER_MIN_ANISOTROPIC: UInt64 = 0x0000000000000080
    public static let SAMPLER_MAG_POINT: UInt64 = 0x0000000000000100
    public static let SAMPLER_MAG_ANISOTROPIC: UInt64 = 0x0000000000000200
    public static let SAMPLER_MIP_POINT: UInt64 = 0x0000000000000400
    /** 点采样组合（MIN/MAG/MIP 全点采样） */
    public static let SAMPLER_POINT: UInt64 = 0x0000000000000540
    /** UVW 镜像环绕 */
    public static let SAMPLER_UVW_MIRROR: UInt64 = 0x0000000000000015
    /** UVW 钳位环绕 */
    public static let SAMPLER_UVW_CLAMP: UInt64 = 0x000000000000002A
    /** UVW 边界色环绕 */
    public static let SAMPLER_UVW_BORDER: UInt64 = 0x000000000000003F
}

// ============================================================================
// ===== 采样器标志（UInt32 位组合，绑定纹理时覆盖采样状态用） =====
// ============================================================================

/**
 * @brief[zh-cn] 纹理绑定期采样器标志
 * @explain[zh-cn] 供 setTexture 系列的 flags 参数使用：绑定时以低 32 位
 * 采样器位覆盖纹理创建时的采样状态；0 表示沿用纹理自身的采样设置。
 *
 * @brief[en] Sampler flags at texture binding time
 * @explain[en] Used by the flags parameter of the setTexture family: low 32-bit
 * sampler bits override the sampling state set at texture creation; 0 keeps the
 * texture's own sampler settings.
 */
public class GfxSamplerFlag {
    /** 沿用纹理自身采样设置 */
    public static let NONE: UInt32 = 0x00000000
    public static let U_MIRROR: UInt32 = 0x00000001
    public static let U_CLAMP: UInt32 = 0x00000002
    public static let U_BORDER: UInt32 = 0x00000003
    public static let V_MIRROR: UInt32 = 0x00000004
    public static let V_CLAMP: UInt32 = 0x00000008
    public static let V_BORDER: UInt32 = 0x0000000C
    public static let W_MIRROR: UInt32 = 0x00000010
    public static let W_CLAMP: UInt32 = 0x00000020
    public static let W_BORDER: UInt32 = 0x00000030
    public static let MIN_POINT: UInt32 = 0x00000040
    public static let MIN_ANISOTROPIC: UInt32 = 0x00000080
    public static let MAG_POINT: UInt32 = 0x00000100
    public static let MAG_ANISOTROPIC: UInt32 = 0x00000200
    public static let MIP_POINT: UInt32 = 0x00000400
    /** 点采样组合（MIN/MAG/MIP 全点采样） */
    public static let POINT: UInt32 = 0x00000540
    /** UVW 钳位环绕 */
    public static let UVW_CLAMP: UInt32 = 0x0000002A
    /** 比较模式：小于等于（阴影采样） */
    public static let COMPARE_LEQUAL: UInt32 = 0x00020000
}

// ============================================================================
// ===== 缓冲标志（UInt16 位组合） =====
// ============================================================================

/**
 * @brief[zh-cn] 顶点/索引缓冲创建标志
 *
 * @brief[en] Vertex/index buffer creation flags
 */
public class GfxBufferFlag {
    /** 无标志 */
    public static let NONE: UInt16 = 0x0000
    /** 计算着色器可读 */
    public static let COMPUTE_READ: UInt16 = 0x0100
    /** 计算着色器可写 */
    public static let COMPUTE_WRITE: UInt16 = 0x0200
    /** 计算着色器可读写 */
    public static let COMPUTE_READ_WRITE: UInt16 = 0x0300
    /** 间接绘制缓冲 */
    public static let DRAW_INDIRECT: UInt16 = 0x0400
    /** 允许动态扩容 */
    public static let ALLOW_RESIZE: UInt16 = 0x0800
    /** 32 位索引 */
    public static let INDEX32: UInt16 = 0x1000
}

// ============================================================================
// ===== 绘制状态（UInt64 位组合） =====
// ============================================================================

/**
 * @brief[zh-cn] 绘制状态位（深度测试/写入掩码/混合/剔除/图元类型/MSAA）
 * @explain[zh-cn] 供 setState 的 state 参数组合使用。三角形列表为默认图元
 * （无须设置 PT 位）；混合方程默认相加（无须设置 EQUATION 位）。
 *
 * @brief[en] Draw state bits (depth test / write masks / blending / culling /
 * primitive type / MSAA)
 * @explain[en] Composed for the state parameter of setState. Triangle list is the
 * default primitive type (no PT bits needed); additive blending is the default
 * equation (no EQUATION bits needed).
 */
public class GfxState {
    /** 无状态 */
    public static let NONE: UInt64 = 0x0000000000000000
    /** 默认渲染状态（写 RGB+Z、深度测试 LESS、剔除 CW、三角形列表） */
    public static let DEFAULT: UInt64 = 0x000100410000003F
    // ---- 写入掩码 ----
    public static let WRITE_R: UInt64 = 0x0000000000000001
    public static let WRITE_G: UInt64 = 0x0000000000000002
    public static let WRITE_B: UInt64 = 0x0000000000000004
    public static let WRITE_A: UInt64 = 0x0000000000000008
    public static let WRITE_RGB: UInt64 = 0x0000000000000007
    public static let WRITE_Z: UInt64 = 0x0000004000000000
    // ---- 深度测试 ----
    public static let DEPTH_TEST_LESS: UInt64 = 0x0000000000000010
    public static let DEPTH_TEST_LEQUAL: UInt64 = 0x0000000000000020
    public static let DEPTH_TEST_EQUAL: UInt64 = 0x0000000000000030
    public static let DEPTH_TEST_GEQUAL: UInt64 = 0x0000000000000040
    public static let DEPTH_TEST_GREATER: UInt64 = 0x0000000000000050
    public static let DEPTH_TEST_NOTEQUAL: UInt64 = 0x0000000000000060
    public static let DEPTH_TEST_NEVER: UInt64 = 0x0000000000000070
    public static let DEPTH_TEST_ALWAYS: UInt64 = 0x0000000000000080
    // ---- 混合因子 ----
    public static let BLEND_ZERO: UInt64 = 0x0000000000001000
    public static let BLEND_ONE: UInt64 = 0x0000000000002000
    public static let BLEND_SRC_COLOR: UInt64 = 0x0000000000003000
    public static let BLEND_INV_SRC_COLOR: UInt64 = 0x0000000000004000
    public static let BLEND_SRC_ALPHA: UInt64 = 0x0000000000005000
    public static let BLEND_INV_SRC_ALPHA: UInt64 = 0x0000000000006000
    public static let BLEND_DST_ALPHA: UInt64 = 0x0000000000007000
    public static let BLEND_INV_DST_ALPHA: UInt64 = 0x0000000000008000
    public static let BLEND_DST_COLOR: UInt64 = 0x0000000000009000
    public static let BLEND_INV_DST_COLOR: UInt64 = 0x000000000000A000
    public static let BLEND_SRC_ALPHA_SAT: UInt64 = 0x000000000000B000
    public static let BLEND_FACTOR: UInt64 = 0x000000000000C000
    public static let BLEND_INV_FACTOR: UInt64 = 0x000000000000D000
    // ---- 混合方程（默认相加，无须设置） ----
    public static let BLEND_EQUATION_ADD: UInt64 = 0x0000000000000000
    public static let BLEND_EQUATION_SUB: UInt64 = 0x0000000010000000
    public static let BLEND_EQUATION_REVSUB: UInt64 = 0x0000000020000000
    public static let BLEND_EQUATION_MIN: UInt64 = 0x0000000030000000
    public static let BLEND_EQUATION_MAX: UInt64 = 0x0000000040000000
    /** MRT 独立混合 */
    public static let BLEND_INDEPENDENT: UInt64 = 0x0000000400000000
    /** Alpha 覆盖 */
    public static let BLEND_ALPHA_TO_COVERAGE: UInt64 = 0x0000000800000000
    // ---- 剔除与正面朝向 ----
    public static let CULL_CW: UInt64 = 0x0000001000000000
    public static let CULL_CCW: UInt64 = 0x0000002000000000
    /** 逆时针为正面 */
    public static let FRONT_CCW: UInt64 = 0x0000008000000000
    // ---- 图元类型（三角形列表为默认，无须设置） ----
    public static let PT_TRISTRIP: UInt64 = 0x0001000000000000
    public static let PT_LINES: UInt64 = 0x0002000000000000
    public static let PT_LINESTRIP: UInt64 = 0x0003000000000000
    public static let PT_POINTS: UInt64 = 0x0004000000000000
    // ---- 其他 ----
    /** MSAA 多重采样 */
    public static let MSAA: UInt64 = 0x0100000000000000
    /** 线段抗锯齿 */
    public static let LINEAA: UInt64 = 0x0200000000000000
    /** 保守光栅化 */
    public static let CONSERVATIVE_RASTER: UInt64 = 0x0400000000000000
}

// ============================================================================
// ===== 模板状态位（UInt32 位域） =====
// ============================================================================

/**
 * @brief[zh-cn] 模板状态位（setStencil 的 fstencil/bstencil 位域组合）
 * @explain[zh-cn] 完整位域 = FUNC_REF（bit 0-7，模板参考值）| FUNC_RMASK
 * （bit 8-15，读取掩码）| TEST_*（bit 16-19）| OP_FAIL_S_*（bit 20-23）|
 * OP_FAIL_Z_*（bit 24-27）| OP_PASS_Z_*（bit 28-31）。参考值与掩码由调用方
 * 按位编码（如 ref | 0xFFu32 << 8）。
 *
 * @brief[en] Stencil state bits (composition of the fstencil/bstencil bitfields of setStencil)
 * @explain[en] Full bitfield = FUNC_REF (bits 0-7, stencil reference) | FUNC_RMASK
 * (bits 8-15, read mask) | TEST_* (bits 16-19) | OP_FAIL_S_* (bits 20-23) |
 * OP_FAIL_Z_* (bits 24-27) | OP_PASS_Z_* (bits 28-31). Reference and mask are
 * bit-encoded by the caller (e.g. ref | 0xFFu32 << 8).
 */
public class GfxStencilFlag {
    /** 测试：等于（模板值 == 参考值） */
    public static let TEST_EQUAL: UInt32 = 0x00030000
    /** 测试：始终通过 */
    public static let TEST_ALWAYS: UInt32 = 0x00080000
    /** 模板测试失败时保持 */
    public static let OP_FAIL_S_KEEP: UInt32 = 0x00100000
    /** 深度测试失败时保持 */
    public static let OP_FAIL_Z_KEEP: UInt32 = 0x01000000
    /** 深度测试通过时保持 */
    public static let OP_PASS_Z_KEEP: UInt32 = 0x10000000
    /** 深度测试通过时替换为参考值 */
    public static let OP_PASS_Z_REPLACE: UInt32 = 0x20000000
}

// ============================================================================
// ===== 清除标志（UInt16 位组合） =====
// ============================================================================

/**
 * @brief[zh-cn] 视图清除标志
 *
 * @brief[en] View clear flags
 */
public class GfxClearFlag {
    /** 无 */
    public static let NONE: UInt16 = 0x0000
    /** 清除颜色缓冲 */
    public static let COLOR: UInt16 = 0x0001
    /** 清除深度缓冲 */
    public static let DEPTH: UInt16 = 0x0002
    /** 清除模板缓冲 */
    public static let STENCIL: UInt16 = 0x0004
}

// ============================================================================
// ===== 重置标志（UInt32 位组合） =====
// ============================================================================

/**
 * @brief[zh-cn] 设备重置/呈现参数标志
 *
 * @brief[en] Device reset / presentation flags
 */
public class GfxResetFlag {
    /** 无 */
    public static let NONE: UInt32 = 0x00000000
    /** 垂直同步 */
    public static let VSYNC: UInt32 = 0x00000080
    /** 最大各向异性过滤 */
    public static let MAXANISOTROPY: UInt32 = 0x00000100
    /** MSAA x2/x4/x8/x16 */
    public static let MSAA_X2: UInt32 = 0x00000010
    public static let MSAA_X4: UInt32 = 0x00000020
    public static let MSAA_X8: UInt32 = 0x00000030
    public static let MSAA_X16: UInt32 = 0x00000040
}

// ============================================================================
// ===== uniform 类型 =====
// ============================================================================

/**
 * @brief[zh-cn] uniform 数据类型
 *
 * @brief[en] Uniform data type
 */
public enum GfxUniformType {
    /** 纹理采样器 */
    | Sampler
    /** 4 分量浮点向量 */
    | Vec4
    /** 3x3 浮点矩阵 */
    | Mat3
    /** 4x4 浮点矩阵 */
    | Mat4

    public func value(): UInt32 {
        match (this) {
            case Sampler => 0
            case Vec4 => 2
            case Mat3 => 3
            case Mat4 => 4
        }
    }
}

// ============================================================================
// ===== 顶点属性 =====
// ============================================================================

/**
 * @brief[zh-cn] 顶点属性语义槽位
 *
 * @brief[en] Vertex attribute semantic slot
 */
public enum GfxAttrib {
    | Position
    | Normal
    | Tangent
    | Bitangent
    | Color0
    | Color1
    | Color2
    | Color3
    | Indices
    | Weight
    | TexCoord0
    | TexCoord1
    | TexCoord2
    | TexCoord3
    | TexCoord4
    | TexCoord5
    | TexCoord6
    | TexCoord7

    public func value(): UInt32 {
        match (this) {
            case Position => 0
            case Normal => 1
            case Tangent => 2
            case Bitangent => 3
            case Color0 => 4
            case Color1 => 5
            case Color2 => 6
            case Color3 => 7
            case Indices => 8
            case Weight => 9
            case TexCoord0 => 10
            case TexCoord1 => 11
            case TexCoord2 => 12
            case TexCoord3 => 13
            case TexCoord4 => 14
            case TexCoord5 => 15
            case TexCoord6 => 16
            case TexCoord7 => 17
        }
    }
}

/**
 * @brief[zh-cn] 顶点属性存储类型
 *
 * @brief[en] Vertex attribute storage type
 */
public enum GfxAttribType {
    | `Int8`
    | Uint8
    | Uint10
    | `Int16`
    | Uint16
    | Half
    | Float
    | `Int32`
    | Uint32

    public func value(): UInt32 {
        match (this) {
            case `Int8` => 0
            case Uint8 => 1
            case Uint10 => 2
            case `Int16` => 3
            case Uint16 => 4
            case Half => 5
            case Float => 6
            case `Int32` => 7
            case Uint32 => 8
        }
    }
}

// ============================================================================
// ===== 视图 / 比例 / 访问 =====
// ============================================================================

/**
 * @brief[zh-cn] 视图渲染排序模式
 *
 * @brief[en] View render sorting mode
 */
public enum GfxViewMode {
    /** 默认（顺序渲染，无特殊排序） */
    | Default
    /** 按提交顺序渲染 */
    | Sequential
    /** 按深度升序（从近到远） */
    | DepthAscending
    /** 按深度降序（从远到近，透明物体） */
    | DepthDescending

    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Sequential => 1
            case DepthAscending => 2
            case DepthDescending => 3
        }
    }
}

/**
 * @brief[zh-cn] 后缓冲比例
 * @explain[zh-cn] 用于创建与后缓冲成比例的帧缓冲。
 *
 * @brief[en] Backbuffer ratio
 * @explain[en] Used to create frame buffers proportional to the backbuffer.
 */
public enum GfxBackbufferRatio {
    | Equal
    | Half
    | Quarter
    | Eighth
    | Sixteenth
    | Double

    public func value(): UInt32 {
        match (this) {
            case Equal => 0
            case Half => 1
            case Quarter => 2
            case Eighth => 3
            case Sixteenth => 4
            case Double => 5
        }
    }
}

/**
 * @brief[zh-cn] 计算资源访问权限
 *
 * @brief[en] Compute resource access mode
 */
public enum GfxAccess {
    | Read
    | Write
    | ReadWrite

    public func value(): UInt32 {
        match (this) {
            case Read => 0
            case Write => 1
            case ReadWrite => 2
        }
    }
}

// ============================================================================
// ===== 渲染后端类型（查询 API 返回类型，公开） =====
// ============================================================================

/**
 * @brief[zh-cn] 渲染后端类型
 * @explain[zh-cn] 表示底层图形 API 的种类，经 ThreeRenderer.getRendererType()
 * 对外返回。并非所有平台都支持所有类型。
 *
 * @brief[en] Render backend type
 * @explain[en] The underlying graphics API kind, returned publicly via
 * ThreeRenderer.getRendererType(). Not every type is supported on every platform.
 */
public enum GfxRendererType {
    /** 空操作渲染器（不产生绘制调用） */
    | Noop
    /** AGC（Android Graphics Compositor） */
    | Agc
    /** Direct3D 11 */
    | Direct3D11
    /** Direct3D 12 */
    | Direct3D12
    /** GNM（PlayStation 4） */
    | Gnm
    /** Metal（Apple） */
    | Metal
    /** NVN（Nintendo Switch） */
    | Nvn
    /** OpenGL ES（嵌入式） */
    | OpenGLES
    /** OpenGL（桌面） */
    | OpenGL
    /** Vulkan */
    | Vulkan
    /** WebGPU */
    | WebGPU

    public func value(): UInt32 {
        match (this) {
            case Noop => 0
            case Agc => 1
            case Direct3D11 => 2
            case Direct3D12 => 3
            case Gnm => 4
            case Metal => 5
            case Nvn => 6
            case OpenGLES => 7
            case OpenGL => 8
            case Vulkan => 9
            case WebGPU => 10
        }
    }
}

// ============================================================================
// ===== 描述结构 =====
// ============================================================================

/**
 * @brief[zh-cn] 顶点布局属性描述
 * @explain[zh-cn] 供 createVertexLayout 构建 declare 式顶点布局。
 *
 * @brief[en] Vertex layout attribute descriptor
 * @explain[en] Used by createVertexLayout to build declarative vertex layouts.
 */
public struct GfxAttributeDesc {
    /** 属性语义槽位 */
    public let attrib: GfxAttrib
    /** 分量数量（1-4） */
    public let num: UInt8
    /** 分量存储类型 */
    public let attribType: GfxAttribType
    /** 是否归一化到 [0,1] / [-1,1] */
    public let normalized: Bool
    /** 是否按整数解释（不过归一化） */
    public let asInt: Bool

    public init(attrib: GfxAttrib, num: UInt8, attribType: GfxAttribType, normalized!: Bool = false,
        asInt!: Bool = false) {
        this.attrib = attrib
        this.num = num
        this.attribType = attribType
        this.normalized = normalized
        this.asInt = asInt
    }
}

/**
 * @brief[zh-cn] 帧缓冲附着描述
 * @explain[zh-cn] 供 isFrameBufferValid 预检与多附着帧缓冲构建。
 *
 * @brief[en] Frame buffer attachment descriptor
 * @explain[en] Used by isFrameBufferValid pre-checks and multi-attachment
 * frame buffer construction.
 */
public struct GfxAttachmentDesc {
    /** 附着纹理 */
    public let texture: GfxTextureHandle
    /** 访问模式 */
    public let access: GfxAccess
    /** 数组层起始索引 */
    public let layer: UInt16
    /** 数组层数 */
    public let numLayers: UInt16
    /** mip 级 */
    public let mip: UInt8
    /** resolve 目标 mip */
    public let resolve: UInt8

    public init(texture: GfxTextureHandle, access!: GfxAccess = GfxAccess.Write, layer!: UInt16 = 0u16,
        numLayers!: UInt16 = 1u16, mip!: UInt8 = 0u8, resolve!: UInt8 = 0u8) {
        this.texture = texture
        this.access = access
        this.layer = layer
        this.numLayers = numLayers
        this.mip = mip
        this.resolve = resolve
    }
}

/**
 * @brief[zh-cn] uniform 反射信息
 * @explain[zh-cn] getUniformInfo 的值返回形态（替代指针出参）。
 *
 * @brief[en] Uniform reflection info
 * @explain[en] The value-return form of getUniformInfo (replacing pointer out-params).
 */
public struct GfxUniformDesc {
    /** uniform 名称 */
    public let name: String
    /** 数据类型 */
    public let uniformType: GfxUniformType
    /** 数组长度 */
    public let num: UInt16

    public init(name!: String, uniformType!: GfxUniformType, num!: UInt16 = 1u16) {
        this.name = name
        this.uniformType = uniformType
        this.num = num
    }
}

// ============================================================================
// ===== 能力 / 统计摘要（查询域的值拷贝返回形态） =====
// ============================================================================

/**
 * @brief[zh-cn] 设备能力摘要
 * @explain[zh-cn] getCapsSummary 的值拷贝返回形态（字段全为基本类型，无指针），
 * 经 ThreeRenderer.getCapabilities() 对外返回。
 *
 * @brief[en] Device capability summary
 * @explain[en] The value-copy return form of getCapsSummary (all fields are
 * primitive types, no pointers), returned publicly via ThreeRenderer.getCapabilities().
 */
public struct GfxCapsSummary {
    /** 当前渲染后端类型 */
    public let rendererType: GfxRendererType
    /** GPU 厂商 ID（0 = 未知） */
    public let vendorId: UInt16
    /** GPU 设备 ID（0 = 未知） */
    public let deviceId: UInt16
    /** 能力位集（后端定义的 capability 位组合） */
    public let supported: UInt64
    /** 纹理坐标原点是否在左下角 */
    public let originBottomLeft: Bool
    /** 最大纹理尺寸 */
    public let maxTextureSize: UInt32
    /** 最大视图数 */
    public let maxViews: UInt32

    public init(rendererType: GfxRendererType, vendorId!: UInt16 = 0u16, deviceId!: UInt16 = 0u16,
        supported!: UInt64 = 0u64, originBottomLeft!: Bool = false, maxTextureSize!: UInt32 = 0u32,
        maxViews!: UInt32 = 0u32) {
        this.rendererType = rendererType
        this.vendorId = vendorId
        this.deviceId = deviceId
        this.supported = supported
        this.originBottomLeft = originBottomLeft
        this.maxTextureSize = maxTextureSize
        this.maxViews = maxViews
    }
}

/**
 * @brief[zh-cn] 帧统计摘要
 * @explain[zh-cn] getStatsSummary 的值拷贝返回形态（字段全为基本类型，无指针）。
 *
 * @brief[en] Frame statistics summary
 * @explain[en] The value-copy return form of getStatsSummary (all fields are
 * primitive types, no pointers).
 */
public struct GfxStatsSummary {
    /** CPU 帧耗时（毫秒） */
    public let cpuTimeFrame: Float64
    /** GPU 帧耗时（毫秒） */
    public let gpuTimeFrame: Float64
    /** 绘制调用数 */
    public let drawCalls: UInt32
    /** 计算调用数 */
    public let computeCalls: UInt32
    /** blit 调用数 */
    public let blitCalls: UInt32
    /** 纹理显存占用（字节） */
    public let textureMemoryUsed: Int64

    public init(cpuTimeFrame!: Float64 = 0.0, gpuTimeFrame!: Float64 = 0.0, drawCalls!: UInt32 = 0u32,
        computeCalls!: UInt32 = 0u32, blitCalls!: UInt32 = 0u32, textureMemoryUsed!: Int64 = 0) {
        this.cpuTimeFrame = cpuTimeFrame
        this.gpuTimeFrame = gpuTimeFrame
        this.drawCalls = drawCalls
        this.computeCalls = computeCalls
        this.blitCalls = blitCalls
        this.textureMemoryUsed = textureMemoryUsed
    }
}

/**
 * 后端纹理格式数值 → Gfx 纹理格式（值域 = 引擎实际使用的格式成员）。
 * 供 EngineRenderTarget 等资源对象把 public 构造器收到的后端格式数值
 * 翻译回抽象层枚举。
 */
protected func gfxFormat(v: UInt32): GfxTextureFormat {
    match (v) {
        case 0u32 => GfxTextureFormat.BC1
        case 1u32 => GfxTextureFormat.BC2
        case 2u32 => GfxTextureFormat.BC3
        case 3u32 => GfxTextureFormat.BC4
        case 5u32 => GfxTextureFormat.BC5
        case 7u32 => GfxTextureFormat.BC6H
        case 9u32 => GfxTextureFormat.BC7
        case 10u32 => GfxTextureFormat.ETC1
        case 11u32 => GfxTextureFormat.ETC2
        case 12u32 => GfxTextureFormat.ETC2A
        case 27u32 => GfxTextureFormat.ASTC4X4
        case 28u32 => GfxTextureFormat.ASTC5X4
        case 29u32 => GfxTextureFormat.ASTC5X5
        case 30u32 => GfxTextureFormat.ASTC6X5
        case 31u32 => GfxTextureFormat.ASTC6X6
        case 32u32 => GfxTextureFormat.ASTC8X5
        case 33u32 => GfxTextureFormat.ASTC8X6
        case 34u32 => GfxTextureFormat.ASTC8X8
        case 35u32 => GfxTextureFormat.ASTC10X5
        case 36u32 => GfxTextureFormat.ASTC10X6
        case 37u32 => GfxTextureFormat.ASTC10X8
        case 38u32 => GfxTextureFormat.ASTC10X10
        case 39u32 => GfxTextureFormat.ASTC12X10
        case 40u32 => GfxTextureFormat.ASTC12X12
        case 43u32 => GfxTextureFormat.A8
        case 44u32 => GfxTextureFormat.R8
        case 48u32 => GfxTextureFormat.R16
        case 49u32 => GfxTextureFormat.R16I
        case 51u32 => GfxTextureFormat.R16F
        case 56u32 => GfxTextureFormat.RG8
        case 63u32 => GfxTextureFormat.RG16F
        case 65u32 => GfxTextureFormat.RG32I
        case 72u32 => GfxTextureFormat.RGB9E5F
        case 74u32 => GfxTextureFormat.RGBA8
        case 81u32 => GfxTextureFormat.RGBA16F
        case 83u32 => GfxTextureFormat.RGBA32I
        case 85u32 => GfxTextureFormat.RGBA32F
        case 94u32 => GfxTextureFormat.RG11B10F
        case 97u32 => GfxTextureFormat.D24
        case 98u32 => GfxTextureFormat.D24S8
        case 99u32 => GfxTextureFormat.D32
        case 102u32 => GfxTextureFormat.D32F
        case _ => GfxTextureFormat.RGBA8
    }
}

/**
 * @brief[zh-cn] 构建 GPU blend state 值（纯函数，无后端状态）
 * @explain[zh-cn] 对照 bgfx defines.h：
 * BGFX_STATE_BLEND_FUNC_SEPARATE(srcRGB, dstRGB, srcA, dstA) =
 * ((srcRGB | (dstRGB << 4))) | (((srcA | (dstA << 4))) << 8)
 * BGFX_STATE_BLEND_FUNC(src, dst) = FUNC_SEPARATE(src, dst, src, dst)
 * BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA=0x5000, INV_SRC_ALPHA=0x6000) = 0x6565000
 * 注意：不能直接 OR 三个 BLEND_* 常量 —— 那会把 src/dst factor 合并成单一 factor
 * （0x7000），导致 alpha blend 完全失效（渲染为不透明）。
 * 原位于 bgfx 包 BgfxBackend.makeBlendFunc，因是纯位组合、无后端状态，
 * 迁入 gfx 抽象层供 postprocessing 等包直接取用。
 *
 * @param[zh-cn] srcFactor 源因子（STATE_BLEND_* 常量，已 <<12）
 * @param[zh-cn] dstFactor 目标因子（STATE_BLEND_* 常量，已 <<12）
 * @return[zh-cn] 完整的 blend state 值
 *
 * @brief[en] Builds a GPU blend state value (pure function, no backend state)
 * @explain[en] Mirrors bgfx defines.h:
 * BGFX_STATE_BLEND_FUNC_SEPARATE(srcRGB, dstRGB, srcA, dstA) =
 * ((srcRGB | (dstRGB << 4))) | (((srcA | (dstA << 4))) << 8)
 * BGFX_STATE_BLEND_FUNC(src, dst) = FUNC_SEPARATE(src, dst, src, dst)
 * BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA=0x5000, INV_SRC_ALPHA=0x6000) = 0x6565000
 * Note: do not directly OR the three BLEND_* constants — that would collapse the
 * src/dst factors into a single factor (0x7000), making alpha blend fail completely
 * (rendered opaque).
 * Originally BgfxBackend.makeBlendFunc in the bgfx package; since it is pure bit
 * composition without backend state, it is moved into the gfx abstraction layer so
 * packages such as postprocessing can use it directly.
 *
 * @param[en] srcFactor Source factor (STATE_BLEND_* constant, already <<12)
 * @param[en] dstFactor Destination factor (STATE_BLEND_* constant, already <<12)
 * @return[en] Complete blend state value
 */
protected func gfxBlendFunc(srcFactor: UInt64, dstFactor: UInt64): UInt64 {
    // BGFX_STATE_BLEND_FUNC_SEPARATE(src, dst, src, dst)
    let rgbPart = srcFactor | (dstFactor << 4u64)
    let alphaPart = rgbPart << 8u64
    return rgbPart | alphaPart
}
