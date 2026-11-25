/**
 * @file bgfx 常量定义
 * @brief bgfx C99 API 的所有常量定义
 * @explain 本文件包含了来自 bgfx defines.h 的所有常量，包括渲染状态标志、
 *         模板缓冲标志、清除标志、调试标志、纹理标志、采样器标志、
 *         重置标志、能力标志等。
 * @note 这些常量直接映射自 C 头文件 bgfx/defines.h 中的宏定义。
 * @see https://github.com/bkaradzic/bgfx/blob/master/include/bgfx/defines.h
 */
protected package three._vendor.bgfx4cj.bgfx

// =============================================================================
// API Version
// =============================================================================

/** @brief bgfx API 版本号（对齐新版 bgfx defines.h） */
public const BGFX_API_VERSION: UInt32 = 161

// =============================================================================
// State - Color RGB/alpha/depth write
// =============================================================================

/** @brief 红色通道写入启用 */
public const STATE_WRITE_R: UInt64 = 0x0000000000000001
/** @brief 绿色通道写入启用 */
public const STATE_WRITE_G: UInt64 = 0x0000000000000002
/** @brief 蓝色通道写入启用 */
public const STATE_WRITE_B: UInt64 = 0x0000000000000004
public const STATE_WRITE_A: UInt64 = 0x0000000000000008
/** @brief 深度缓冲写入启用 */
public const STATE_WRITE_Z: UInt64 = 0x0000004000000000
public const STATE_WRITE_RGB: UInt64 = 0x0000000000000007
/** @brief 颜色+深度写入掩码 */
public const STATE_WRITE_MASK: UInt64 = 0x000000400000000F

// =============================================================================
// State - Depth test
// =============================================================================

/** @brief 深度测试：小于 */
public const STATE_DEPTH_TEST_LESS: UInt64 = 0x0000000000000010
/** @brief 深度测试：小于等于 */
public const STATE_DEPTH_TEST_LEQUAL: UInt64 = 0x0000000000000020
/** @brief 深度测试：等于 */
public const STATE_DEPTH_TEST_EQUAL: UInt64 = 0x0000000000000030
/** @brief 深度测试：大于等于 */
public const STATE_DEPTH_TEST_GEQUAL: UInt64 = 0x0000000000000040
/** @brief 深度测试：大于 */
public const STATE_DEPTH_TEST_GREATER: UInt64 = 0x0000000000000050
/** @brief 深度测试：不等于 */
public const STATE_DEPTH_TEST_NOTEQUAL: UInt64 = 0x0000000000000060
/** @brief 深度测试：从不通过 */
public const STATE_DEPTH_TEST_NEVER: UInt64 = 0x0000000000000070
/** @brief 深度测试：始终通过 */
public const STATE_DEPTH_TEST_ALWAYS: UInt64 = 0x0000000000000080
/** @brief 深度测试位偏移 */
public const STATE_DEPTH_TEST_SHIFT: UInt64 = 4
/** @brief 深度测试位掩码 */
public const STATE_DEPTH_TEST_MASK: UInt64 = 0x00000000000000F0

// =============================================================================
// State - Blend
// =============================================================================

/** @brief 混合因子：零 */
public const STATE_BLEND_ZERO: UInt64 = 0x0000000000001000
/** @brief 混合因子：一 */
public const STATE_BLEND_ONE: UInt64 = 0x0000000000002000
/** @brief 混合因子：源颜色 */
public const STATE_BLEND_SRC_COLOR: UInt64 = 0x0000000000003000
/** @brief 混合因子：1-源颜色 */
public const STATE_BLEND_INV_SRC_COLOR: UInt64 = 0x0000000000004000
/** @brief 混合因子：源 Alpha */
public const STATE_BLEND_SRC_ALPHA: UInt64 = 0x0000000000005000
/** @brief 混合因子：1-源 Alpha */
public const STATE_BLEND_INV_SRC_ALPHA: UInt64 = 0x0000000000006000
/** @brief 混合因子：目标 Alpha */
public const STATE_BLEND_DST_ALPHA: UInt64 = 0x0000000000007000
/** @brief 混合因子：1-目标 Alpha */
public const STATE_BLEND_INV_DST_ALPHA: UInt64 = 0x0000000000008000
/** @brief 混合因子：目标颜色 */
public const STATE_BLEND_DST_COLOR: UInt64 = 0x0000000000009000
/** @brief 混合因子：1-目标颜色 */
public const STATE_BLEND_INV_DST_COLOR: UInt64 = 0x000000000000A000
/** @brief 混合因子：源 Alpha 饱和 */
public const STATE_BLEND_SRC_ALPHA_SAT: UInt64 = 0x000000000000B000
/** @brief 混合因子：常量颜色 */
public const STATE_BLEND_FACTOR: UInt64 = 0x000000000000C000
/** @brief 混合因子：1-常量颜色 */
public const STATE_BLEND_INV_FACTOR: UInt64 = 0x000000000000D000
/** @brief 混合位偏移 */
public const STATE_BLEND_SHIFT: UInt64 = 12
/** @brief 混合位掩码 */
public const STATE_BLEND_MASK: UInt64 = 0x000000000FFFF000

// =============================================================================
// State - Blend equation
// =============================================================================

/** @brief 混合方程：相加 */
public const STATE_BLEND_EQUATION_ADD: UInt64 = 0x0000000000000000
/** @brief 混合方程：相减 */
public const STATE_BLEND_EQUATION_SUB: UInt64 = 0x0000000010000000
/** @brief 混合方程：反向相减 */
public const STATE_BLEND_EQUATION_REVSUB: UInt64 = 0x0000000020000000
/** @brief 混合方程：取最小值 */
public const STATE_BLEND_EQUATION_MIN: UInt64 = 0x0000000030000000
/** @brief 混合方程：取最大值 */
public const STATE_BLEND_EQUATION_MAX: UInt64 = 0x0000000040000000
/** @brief 混合方程位偏移 */
public const STATE_BLEND_EQUATION_SHIFT: UInt64 = 28
/** @brief 混合方程位掩码 */
public const STATE_BLEND_EQUATION_MASK: UInt64 = 0x00000003F0000000

// =============================================================================
// State - Cull
// =============================================================================

/** @brief 背面剔除：顺时针 */
public const STATE_CULL_CW: UInt64 = 0x0000001000000000
/** @brief 背面剔除：逆时针 */
public const STATE_CULL_CCW: UInt64 = 0x0000002000000000
/** @brief 剔除位偏移 */
public const STATE_CULL_SHIFT: UInt64 = 36
/** @brief 剔除位掩码 */
public const STATE_CULL_MASK: UInt64 = 0x0000003000000000

// =============================================================================
// State - Alpha reference
// =============================================================================

/** @brief Alpha 参考值位偏移 */
public const STATE_ALPHA_REF_SHIFT: UInt64 = 40
/** @brief Alpha 参考值位掩码 */
public const STATE_ALPHA_REF_MASK: UInt64 = 0x0000FF0000000000

// =============================================================================
// State - Primitive type
// =============================================================================

/** @brief 图元类型：三角形条带 */
public const STATE_PT_TRISTRIP: UInt64 = 0x0001000000000000
/** @brief 图元类型：线段列表 */
public const STATE_PT_LINES: UInt64 = 0x0002000000000000
/** @brief 图元类型：线段条带 */
public const STATE_PT_LINESTRIP: UInt64 = 0x0003000000000000
/** @brief 图元类型：点列表 */
public const STATE_PT_POINTS: UInt64 = 0x0004000000000000
/** @brief 图元类型位偏移 */
public const STATE_PT_SHIFT: UInt64 = 48
/** @brief 图元类型位掩码 */
public const STATE_PT_MASK: UInt64 = 0x0007000000000000

// =============================================================================
// State - Point size
// =============================================================================

/** @brief 点大小位偏移 */
public const STATE_POINT_SIZE_SHIFT: UInt64 = 52
/** @brief 点大小位掩码 */
public const STATE_POINT_SIZE_MASK: UInt64 = 0x00F0000000000000

// =============================================================================
// State - Other flags
// =============================================================================

/** @brief 启用 MSAA 多重采样 */
public const STATE_MSAA: UInt64 = 0x0100000000000000
/** @brief 启用线段抗锯齿 */
public const STATE_LINEAA: UInt64 = 0x0200000000000000
/** @brief 启用保守光栅化 */
public const STATE_CONSERVATIVE_RASTER: UInt64 = 0x0400000000000000
/** @brief 无状态设置 */
public const STATE_NONE: UInt64 = 0x0000000000000000
/** @brief 逆时针为正面 */
public const STATE_FRONT_CCW: UInt64 = 0x0000008000000000
/** @brief 独立混合模式（MRT） */
public const STATE_BLEND_INDEPENDENT: UInt64 = 0x0000000400000000
public const STATE_BLEND_ALPHA_TO_COVERAGE: UInt64 = 0x0000000800000000
/** @brief 默认渲染状态 */
public const STATE_DEFAULT: UInt64 = 0x000100410000003F
/** @brief 状态掩码 */
public const STATE_MASK: UInt64 = 0xFFFFFFFFFFFFFFFF

// =============================================================================
// State - Reserved
// =============================================================================

/** @brief 保留位偏移 */
public const STATE_RESERVED_SHIFT: UInt64 = 61
/** @brief 保留位掩码 */
public const STATE_RESERVED_MASK: UInt64 = 0xE000000000000000

// =============================================================================
// Stencil - Function ref/rmask
// =============================================================================

/** @brief 模板比较函数参考值偏移 */
public const STENCIL_FUNC_REF_SHIFT: UInt32 = 0
/** @brief 模板比较函数参考值掩码 */
public const STENCIL_FUNC_REF_MASK: UInt32 = 0x000000FF

/** @brief 模板比较函数读取掩码偏移 */
public const STENCIL_FUNC_RMASK_SHIFT: UInt32 = 8
/** @brief 模板比较函数读取掩码 */
public const STENCIL_FUNC_RMASK_MASK: UInt32 = 0x0000FF00

// =============================================================================
// Stencil - General
// =============================================================================

/** @brief 无模板操作（RMASK 全开，禁用模板测试） */
public const STENCIL_NONE: UInt32 = 0x0000FF00
/** @brief 模板掩码 */
public const STENCIL_MASK: UInt32 = 0xFFFFFFFF

// =============================================================================
// Stencil - Test
// =============================================================================

/** @brief 模板测试：小于 */
public const STENCIL_TEST_LESS: UInt32 = 0x00010000
/** @brief 模板测试：小于等于 */
public const STENCIL_TEST_LEQUAL: UInt32 = 0x00020000
/** @brief 模板测试：等于 */
public const STENCIL_TEST_EQUAL: UInt32 = 0x00030000
/** @brief 模板测试：大于等于 */
public const STENCIL_TEST_GEQUAL: UInt32 = 0x00040000
/** @brief 模板测试：大于 */
public const STENCIL_TEST_GREATER: UInt32 = 0x00050000
/** @brief 模板测试：不等于 */
public const STENCIL_TEST_NOTEQUAL: UInt32 = 0x00060000
/** @brief 模板测试：从不通过 */
public const STENCIL_TEST_NEVER: UInt32 = 0x00070000
/** @brief 模板测试：始终通过 */
public const STENCIL_TEST_ALWAYS: UInt32 = 0x00080000
/** @brief 模板测试位偏移 */
public const STENCIL_TEST_SHIFT: UInt32 = 16
/** @brief 模板测试位掩码 */
public const STENCIL_TEST_MASK: UInt32 = 0x000F0000

// =============================================================================
// Stencil - Operation fail (stencil)
// =============================================================================

/** @brief 模板操作：模板测试失败时置零 */
public const STENCIL_OP_FAIL_S_ZERO: UInt32 = 0x00000000
/** @brief 模板操作：模板测试失败时保持 */
public const STENCIL_OP_FAIL_S_KEEP: UInt32 = 0x00100000
/** @brief 模板操作：模板测试失败时替换 */
public const STENCIL_OP_FAIL_S_REPLACE: UInt32 = 0x00200000
/** @brief 模板操作：模板测试失败时自增 */
public const STENCIL_OP_FAIL_S_INCR: UInt32 = 0x00300000
/** @brief 模板操作：模板测试失败时自增（饱和） */
public const STENCIL_OP_FAIL_S_INCRSAT: UInt32 = 0x00400000
/** @brief 模板操作：模板测试失败时自减 */
public const STENCIL_OP_FAIL_S_DECR: UInt32 = 0x00500000
/** @brief 模板操作：模板测试失败时自减（饱和） */
public const STENCIL_OP_FAIL_S_DECRSAT: UInt32 = 0x00600000
/** @brief 模板操作：模板测试失败时翻转 */
public const STENCIL_OP_FAIL_S_INVERT: UInt32 = 0x00700000
/** @brief 模板操作（模板测试失败）位偏移 */
public const STENCIL_OP_FAIL_S_SHIFT: UInt32 = 20
/** @brief 模板操作（模板测试失败）位掩码 */
public const STENCIL_OP_FAIL_S_MASK: UInt32 = 0x00F00000

// =============================================================================
// Stencil - Operation fail (depth)
// =============================================================================

/** @brief 深度测试失败时置零 */
public const STENCIL_OP_FAIL_Z_ZERO: UInt32 = 0x00000000
/** @brief 深度测试失败时保持 */
public const STENCIL_OP_FAIL_Z_KEEP: UInt32 = 0x01000000
/** @brief 深度测试失败时替换 */
public const STENCIL_OP_FAIL_Z_REPLACE: UInt32 = 0x02000000
/** @brief 深度测试失败时自增 */
public const STENCIL_OP_FAIL_Z_INCR: UInt32 = 0x03000000
/** @brief 深度测试失败时自增（饱和） */
public const STENCIL_OP_FAIL_Z_INCRSAT: UInt32 = 0x04000000
/** @brief 深度测试失败时自减 */
public const STENCIL_OP_FAIL_Z_DECR: UInt32 = 0x05000000
/** @brief 深度测试失败时自减（饱和） */
public const STENCIL_OP_FAIL_Z_DECRSAT: UInt32 = 0x06000000
/** @brief 深度测试失败时翻转 */
public const STENCIL_OP_FAIL_Z_INVERT: UInt32 = 0x07000000
/** @brief 深度测试失败操作位偏移 */
public const STENCIL_OP_FAIL_Z_SHIFT: UInt32 = 24
/** @brief 深度测试失败操作位掩码 */
public const STENCIL_OP_FAIL_Z_MASK: UInt32 = 0x0F000000

// =============================================================================
// Stencil - Operation pass (depth)
// =============================================================================

/** @brief 深度测试通过时置零 */
public const STENCIL_OP_PASS_Z_ZERO: UInt32 = 0x00000000
/** @brief 深度测试通过时保持 */
public const STENCIL_OP_PASS_Z_KEEP: UInt32 = 0x10000000
/** @brief 深度测试通过时替换 */
public const STENCIL_OP_PASS_Z_REPLACE: UInt32 = 0x20000000
/** @brief 深度测试通过时自增 */
public const STENCIL_OP_PASS_Z_INCR: UInt32 = 0x30000000
/** @brief 深度测试通过时自增（饱和） */
public const STENCIL_OP_PASS_Z_INCRSAT: UInt32 = 0x40000000
/** @brief 深度测试通过时自减 */
public const STENCIL_OP_PASS_Z_DECR: UInt32 = 0x50000000
/** @brief 深度测试通过时自减（饱和） */
public const STENCIL_OP_PASS_Z_DECRSAT: UInt32 = 0x60000000
/** @brief 深度测试通过时翻转 */
public const STENCIL_OP_PASS_Z_INVERT: UInt32 = 0x70000000
/** @brief 深度测试通过操作位偏移 */
public const STENCIL_OP_PASS_Z_SHIFT: UInt32 = 28
/** @brief 深度测试通过操作位掩码 */
public const STENCIL_OP_PASS_Z_MASK: UInt32 = 0xF0000000

// =============================================================================
// Clear flags
// =============================================================================

/** @brief 清除标志：无 */
public const CLEAR_NONE: UInt16 = 0x0000
/** @brief 清除颜色缓冲 */
public const CLEAR_COLOR: UInt16 = 0x0001
/** @brief 清除深度缓冲 */
public const CLEAR_DEPTH: UInt16 = 0x0002
/** @brief 清除模板缓冲 */
public const CLEAR_STENCIL: UInt16 = 0x0004
/** @brief 丢弃颜色缓冲 0 */
public const CLEAR_DISCARD_COLOR_0: UInt16 = 0x0008
/** @brief 丢弃颜色缓冲 1-7 */
public const CLEAR_DISCARD_COLOR_1: UInt16 = 0x0010
public const CLEAR_DISCARD_COLOR_2: UInt16 = 0x0020
public const CLEAR_DISCARD_COLOR_3: UInt16 = 0x0040
public const CLEAR_DISCARD_COLOR_4: UInt16 = 0x0080
public const CLEAR_DISCARD_COLOR_5: UInt16 = 0x0100
public const CLEAR_DISCARD_COLOR_6: UInt16 = 0x0200
public const CLEAR_DISCARD_COLOR_7: UInt16 = 0x0400
/** @brief 丢弃深度缓冲 */
public const CLEAR_DISCARD_DEPTH: UInt16 = 0x0800
/** @brief 丢弃模板缓冲 */
public const CLEAR_DISCARD_STENCIL: UInt16 = 0x1000
/** @brief 丢弃颜色缓冲掩码 */
public const CLEAR_DISCARD_COLOR_MASK: UInt16 = 0x07F8
/** @brief 丢弃掩码 */
public const CLEAR_DISCARD_MASK: UInt16 = 0x1FF8

// =============================================================================
// Discard flags
// =============================================================================

/** @brief 丢弃标志：无 */
public const DISCARD_NONE: UInt8 = 0x00
/** @brief 丢弃绑定 */
public const DISCARD_BINDINGS: UInt8 = 0x01
/** @brief 丢弃索引缓冲 */
public const DISCARD_INDEX_BUFFER: UInt8 = 0x02
/** @brief 丢弃实例数据 */
public const DISCARD_INSTANCE_DATA: UInt8 = 0x04
/** @brief 丢弃状态 */
public const DISCARD_STATE: UInt8 = 0x08
/** @brief 丢弃变换 */
public const DISCARD_TRANSFORM: UInt8 = 0x10
/** @brief 丢弃顶点流 */
public const DISCARD_VERTEX_STREAMS: UInt8 = 0x20
/** @brief 丢弃所有 */
public const DISCARD_ALL: UInt8 = 0xFF

// =============================================================================
// Debug flags
// =============================================================================

/** @brief 调试标志：无 */
public const DEBUG_NONE: UInt32 = 0x00000000
/** @brief 调试线框模式 */
public const DEBUG_WIREFRAME: UInt32 = 0x00000001
/** @brief 调试 IFH 模式 */
public const DEBUG_IFH: UInt32 = 0x00000002
/** @brief 调试统计信息 */
public const DEBUG_STATS: UInt32 = 0x00000004
/** @brief 调试文本覆盖 */
public const DEBUG_TEXT: UInt32 = 0x00000008
/** @brief 调试性能分析器 */
public const DEBUG_PROFILER: UInt32 = 0x00000010

// =============================================================================
// Frame flags（bgfx_frame 参数，UInt8）
// =============================================================================

/** @brief 帧标志：无（正常提交并呈现） */
public const FRAME_NONE: UInt8 = 0x00
/** @brief 帧标志：图形调试器捕获 */
public const FRAME_DEBUG_CAPTURE: UInt8 = 0x01
/** @brief 帧标志：丢弃全部绘制调用 */
public const FRAME_DISCARD: UInt8 = 0x02
/** @brief 帧标志：执行命令但不呈现后缓冲 */
public const FRAME_FLUSH: UInt8 = 0x04

// =============================================================================
// Buffer - Flags（新版 bgfx 不再使用 BGFX_BUFFER_COMPUTE_FORMAT_*/TYPE_* 常量）
// =============================================================================

/** @brief 无缓冲标志 */
public const BUFFER_NONE: UInt16 = 0x0000
/** @brief 计算缓冲：可读 */
public const BUFFER_COMPUTE_READ: UInt16 = 0x0100
/** @brief 计算缓冲：可写 */
public const BUFFER_COMPUTE_WRITE: UInt16 = 0x0200
/** @brief 间接绘制缓冲 */
public const BUFFER_DRAW_INDIRECT: UInt16 = 0x0400
/** @brief 允许调整大小 */
public const BUFFER_ALLOW_RESIZE: UInt16 = 0x0800
/** @brief 32 位索引 */
public const BUFFER_INDEX32: UInt16 = 0x1000
/** @brief 计算缓冲：读写 */
public const BUFFER_COMPUTE_READ_WRITE: UInt16 = 0x0300

// =============================================================================
// Texture - Flags
// =============================================================================

/** @brief 纹理标志：无 */
public const TEXTURE_NONE: UInt64 = 0x0000000000000000
/** @brief 纹理 MSAA 采样 */
public const TEXTURE_MSAA_SAMPLE: UInt64 = 0x0000000800000000
/** @brief 渲染目标纹理 */
public const TEXTURE_RT: UInt64 = 0x0000001000000000
/** @brief 计算写入纹理 */
public const TEXTURE_COMPUTE_WRITE: UInt64 = 0x0000100000000000
public const TEXTURE_SRGB: UInt64 = 0x0000200000000000
public const TEXTURE_BLIT_DST: UInt64 = 0x0000400000000000
/** @brief 读取回传纹理 */
public const TEXTURE_READ_BACK: UInt64 = 0x0000800000000000
/** @brief 纹理与其他设备/进程共享 */
public const TEXTURE_EXTERNAL_SHARED: UInt64 = 0x0001000000000000
/** @brief 纹理可用任意 sRGB 性采样/渲染（每次绑定需显式声明编码，见 SAMPLER_SRGB/ATTACHMENT_SRGB） */
public const TEXTURE_SRGB_MUTABLE: UInt64 = 0x0040000000000000

/** @brief 纹理保留位偏移（高 4 位为内部标志，勿用） */
public const TEXTURE_RESERVED_SHIFT: UInt64 = 60
/** @brief 纹理保留位掩码 */
public const TEXTURE_RESERVED_MASK: UInt64 = 0xF000000000000000

/** @brief 纹理 RT MSAA x2 */
public const TEXTURE_RT_MSAA_X2: UInt64 = 0x0000002000000000
/** @brief 纹理 RT MSAA x4 */
public const TEXTURE_RT_MSAA_X4: UInt64 = 0x0000003000000000
/** @brief 纹理 RT MSAA x8 */
public const TEXTURE_RT_MSAA_X8: UInt64 = 0x0000004000000000
/** @brief 纹理 RT MSAA x16 */
public const TEXTURE_RT_MSAA_X16: UInt64 = 0x0000005000000000
/** @brief 纹理 RT MSAA 位偏移 */
public const TEXTURE_RT_MSAA_SHIFT: UInt64 = 36
/** @brief 纹理 RT MSAA 位掩码 */
public const TEXTURE_RT_MSAA_MASK: UInt64 = 0x0000007000000000

/** @brief 纹理 RT 只写 */
public const TEXTURE_RT_WRITE_ONLY: UInt64 = 0x0000008000000000
/** @brief 纹理 RT 位偏移 */
public const TEXTURE_RT_SHIFT: UInt64 = 36
/** @brief 纹理 RT 位掩码 */
public const TEXTURE_RT_MASK: UInt64 = 0x000000F000000000

// =============================================================================
// Sampler - Wrap U
// =============================================================================

/** @brief 采样器 U 方向环绕模式：镜像 */
public const SAMPLER_U_MIRROR: UInt32 = 0x00000001
/** @brief 采样器 U 方向环绕模式：钳位 */
public const SAMPLER_U_CLAMP: UInt32 = 0x00000002
/** @brief 采样器 U 方向环绕模式：边界 */
public const SAMPLER_U_BORDER: UInt32 = 0x00000003
/** @brief 采样器 U 方向位偏移 */
public const SAMPLER_U_SHIFT: UInt32 = 0
/** @brief 采样器 U 方向位掩码 */
public const SAMPLER_U_MASK: UInt32 = 0x00000003

// =============================================================================
// Sampler - Wrap V
// =============================================================================

/** @brief 采样器 V 方向环绕模式：镜像 */
public const SAMPLER_V_MIRROR: UInt32 = 0x00000004
/** @brief 采样器 V 方向环绕模式：钳位 */
public const SAMPLER_V_CLAMP: UInt32 = 0x00000008
/** @brief 采样器 V 方向环绕模式：边界 */
public const SAMPLER_V_BORDER: UInt32 = 0x0000000C
/** @brief 采样器 V 方向位偏移 */
public const SAMPLER_V_SHIFT: UInt32 = 2
/** @brief 采样器 V 方向位掩码 */
public const SAMPLER_V_MASK: UInt32 = 0x0000000C

// =============================================================================
// Sampler - Wrap W
// =============================================================================

/** @brief 采样器 W 方向环绕模式：镜像 */
public const SAMPLER_W_MIRROR: UInt32 = 0x00000010
/** @brief 采样器 W 方向环绕模式：钳位 */
public const SAMPLER_W_CLAMP: UInt32 = 0x00000020
/** @brief 采样器 W 方向环绕模式：边界 */
public const SAMPLER_W_BORDER: UInt32 = 0x00000030
/** @brief 采样器 W 方向位偏移 */
public const SAMPLER_W_SHIFT: UInt32 = 4
/** @brief 采样器 W 方向位掩码 */
public const SAMPLER_W_MASK: UInt32 = 0x00000030

// =============================================================================
// Sampler - Min/Mag/Mip
// =============================================================================

/** @brief 采样器缩小过滤：点采样 */
public const SAMPLER_MIN_POINT: UInt32 = 0x00000040
/** @brief 采样器缩小过滤：各向异性 */
public const SAMPLER_MIN_ANISOTROPIC: UInt32 = 0x00000080
/** @brief 采样器缩小过滤位偏移 */
public const SAMPLER_MIN_SHIFT: UInt32 = 6
/** @brief 采样器缩小过滤位掩码 */
public const SAMPLER_MIN_MASK: UInt32 = 0x000000C0

/** @brief 采样器放大过滤：点采样 */
public const SAMPLER_MAG_POINT: UInt32 = 0x00000100
/** @brief 采样器放大过滤：各向异性 */
public const SAMPLER_MAG_ANISOTROPIC: UInt32 = 0x00000200
/** @brief 采样器放大过滤位偏移 */
public const SAMPLER_MAG_SHIFT: UInt32 = 8
/** @brief 采样器放大过滤位掩码 */
public const SAMPLER_MAG_MASK: UInt32 = 0x00000300

/** @brief 采样器多级渐远纹理过滤：点采样 */
public const SAMPLER_MIP_POINT: UInt32 = 0x00000400
/** @brief 采样器多级渐远纹理位偏移 */
public const SAMPLER_MIP_SHIFT: UInt32 = 10
/** @brief 采样器多级渐远纹理位掩码 */
public const SAMPLER_MIP_MASK: UInt32 = 0x00000400

// =============================================================================
// Sampler - Compare
// =============================================================================

/** @brief 采样器比较模式：小于 */
public const SAMPLER_COMPARE_LESS: UInt32 = 0x00010000
/** @brief 采样器比较模式：小于等于 */
public const SAMPLER_COMPARE_LEQUAL: UInt32 = 0x00020000
/** @brief 采样器比较模式：等于 */
public const SAMPLER_COMPARE_EQUAL: UInt32 = 0x00030000
/** @brief 采样器比较模式：大于等于 */
public const SAMPLER_COMPARE_GEQUAL: UInt32 = 0x00040000
/** @brief 采样器比较模式：大于 */
public const SAMPLER_COMPARE_GREATER: UInt32 = 0x00050000
/** @brief 采样器比较模式：不等于 */
public const SAMPLER_COMPARE_NOTEQUAL: UInt32 = 0x00060000
/** @brief 采样器比较模式：从不通过 */
public const SAMPLER_COMPARE_NEVER: UInt32 = 0x00070000
/** @brief 采样器比较模式：始终通过 */
public const SAMPLER_COMPARE_ALWAYS: UInt32 = 0x00080000
/** @brief 采样器比较模式位偏移 */
public const SAMPLER_COMPARE_SHIFT: UInt32 = 16
/** @brief 采样器比较模式位掩码 */
public const SAMPLER_COMPARE_MASK: UInt32 = 0x000F0000

// =============================================================================
// Sampler - Border color and reserved
// =============================================================================

/** @brief 采样器边框颜色位偏移 */
public const SAMPLER_BORDER_COLOR_SHIFT: UInt32 = 24
/** @brief 采样器边框颜色位掩码 */
public const SAMPLER_BORDER_COLOR_MASK: UInt32 = 0x0F000000
/** @brief 采样器保留位偏移 */
public const SAMPLER_RESERVED_SHIFT: UInt32 = 28
/** @brief 采样器保留位掩码 */
public const SAMPLER_RESERVED_MASK: UInt32 = 0xF0000000

// =============================================================================
// Sampler - Combined flags
// =============================================================================

/** @brief 采样器无标志 */
public const SAMPLER_NONE: UInt32 = 0x00000000
/** @brief 采样模板纹理 */
public const SAMPLER_SAMPLE_STENCIL: UInt32 = 0x00100000
/** @brief 采样时做 sRGB 转换（仅对 TEXTURE_SRGB_MUTABLE 纹理生效） */
public const SAMPLER_SRGB: UInt32 = 0x00200000
/** @brief 采样器点采样模式 */
public const SAMPLER_POINT: UInt32 = 0x00000540
/** @brief 采样器 UVW 镜像环绕 */
public const SAMPLER_UVW_MIRROR: UInt32 = 0x00000015
/** @brief 采样器 UVW 钳位环绕 */
public const SAMPLER_UVW_CLAMP: UInt32 = 0x0000002A
/** @brief 采样器 UVW 边界环绕 */
public const SAMPLER_UVW_BORDER: UInt32 = 0x0000003F
/** @brief 采样器有效位掩码 */
public const SAMPLER_BITS_MASK: UInt32 = 0x000F03FF

// =============================================================================
// Reset flags
// =============================================================================

/** @brief 重置标志：MSAA 2x */
public const RESET_MSAA_X2: UInt32 = 0x00000010
/** @brief 重置标志：MSAA 4x */
public const RESET_MSAA_X4: UInt32 = 0x00000020
/** @brief 重置标志：MSAA 8x */
public const RESET_MSAA_X8: UInt32 = 0x00000030
/** @brief 重置标志：MSAA 16x */
public const RESET_MSAA_X16: UInt32 = 0x00000040
/** @brief MSAA 位偏移 */
public const RESET_MSAA_SHIFT: UInt32 = 4
/** @brief MSAA 位掩码 */
public const RESET_MSAA_MASK: UInt32 = 0x00000070

/** @brief 重置标志：无 */
public const RESET_NONE: UInt32 = 0x00000000
/** @brief 全屏模式 */
public const RESET_FULLSCREEN: UInt32 = 0x00000001
/** @brief 垂直同步 */
public const RESET_VSYNC: UInt32 = 0x00000080
/** @brief 最大各向异性过滤 */
public const RESET_MAXANISOTROPY: UInt32 = 0x00000100
/** @brief 捕获帧 */
public const RESET_CAPTURE: UInt32 = 0x00000200
/** @brief 渲染后刷新 */
public const RESET_FLUSH_AFTER_RENDER: UInt32 = 0x00002000
/** @brief 渲染后翻转 */
public const RESET_FLIP_AFTER_RENDER: UInt32 = 0x00004000
/** @brief SRGB 后缓冲 */
public const RESET_SRGB_BACKBUFFER: UInt32 = 0x00008000
/** @brief HDR10 输出 */
public const RESET_HDR10: UInt32 = 0x00010000
/** @brief HiDPI 支持 */
public const RESET_HIDPI: UInt32 = 0x00020000
/** @brief 深度钳位 */
public const RESET_DEPTH_CLAMP: UInt32 = 0x00040000
/** @brief 挂起渲染 */
public const RESET_SUSPEND: UInt32 = 0x00080000
/** @brief 透明后缓冲 */
public const RESET_TRANSPARENT_BACKBUFFER: UInt32 = 0x00100000

/** @brief 全屏标志位偏移 */
public const RESET_FULLSCREEN_SHIFT: UInt32 = 0
/** @brief 全屏标志位掩码 */
public const RESET_FULLSCREEN_MASK: UInt32 = 0x00000001
/** @brief 保留位偏移 */
public const RESET_RESERVED_SHIFT: UInt32 = 31
/** @brief 保留位掩码 */
public const RESET_RESERVED_MASK: UInt32 = 0x80000000

// =============================================================================
// Swap chain flags（新版 bgfx SwapChain.flags，与 RESET_* 的表面标志对应）
// =============================================================================

/** @brief 交换链标志：无 */
public const SWAP_CHAIN_NONE: UInt32 = 0x00000000
/** @brief 全屏（暂不支持） */
public const SWAP_CHAIN_FULLSCREEN: UInt32 = 0x00000001
/** @brief MSAA 2x */
public const SWAP_CHAIN_MSAA_X2: UInt32 = 0x00000010
/** @brief MSAA 4x */
public const SWAP_CHAIN_MSAA_X4: UInt32 = 0x00000020
/** @brief MSAA 8x */
public const SWAP_CHAIN_MSAA_X8: UInt32 = 0x00000030
/** @brief MSAA 16x */
public const SWAP_CHAIN_MSAA_X16: UInt32 = 0x00000040
/** @brief MSAA 位偏移 */
public const SWAP_CHAIN_MSAA_SHIFT: UInt32 = 4
/** @brief MSAA 位掩码 */
public const SWAP_CHAIN_MSAA_MASK: UInt32 = 0x00000070
/** @brief SRGB 后缓冲 */
public const SWAP_CHAIN_SRGB_BACKBUFFER: UInt32 = 0x00008000
/** @brief HDR10 输出 */
public const SWAP_CHAIN_HDR10: UInt32 = 0x00010000
/** @brief HiDPI 支持 */
public const SWAP_CHAIN_HIDPI: UInt32 = 0x00020000
/** @brief 透明后缓冲 */
public const SWAP_CHAIN_TRANSPARENT_BACKBUFFER: UInt32 = 0x00100000
/** @brief 全屏标志位偏移 */
public const SWAP_CHAIN_FULLSCREEN_SHIFT: UInt32 = 0
/** @brief 全屏标志位掩码 */
public const SWAP_CHAIN_FULLSCREEN_MASK: UInt32 = 0x00000001

// =============================================================================
// Frame buffer attachment flags（Attachment.flags，UInt8）
// =============================================================================

/** @brief 附加标志：无 */
public const ATTACHMENT_NONE: UInt8 = 0x00
/** @brief resolve 时自动生成 mipmap */
public const ATTACHMENT_AUTO_GEN_MIPS: UInt8 = 0x01
/** @brief 深度面只读绑定 */
public const ATTACHMENT_READ_ONLY_DEPTH: UInt8 = 0x02
/** @brief 模板面只读绑定 */
public const ATTACHMENT_READ_ONLY_STENCIL: UInt8 = 0x04
/** @brief SRGB 附加视图 */
public const ATTACHMENT_SRGB: UInt8 = 0x08

// =============================================================================
// Native window handle types（PlatformData.type）
// =============================================================================

/** @brief 平台默认句柄类型（Linux 为 X11） */
public const NATIVE_WINDOW_HANDLE_TYPE_DEFAULT: UInt32 = 0
/** @brief Wayland */
public const NATIVE_WINDOW_HANDLE_TYPE_WAYLAND: UInt32 = 1

// =============================================================================
// Capability flags（对齐新版 defines.h BGFX_CAPS_* 布局）
// =============================================================================

/** @brief 能力标志：独立混合 */
public const CAPS_BLEND_INDEPENDENT: UInt64 = 0x0000000000000001
/** @brief 能力标志：计算着色器 */
public const CAPS_COMPUTE: UInt64 = 0x0000000000000002
/** @brief 能力标志：保守光栅化 */
public const CAPS_CONSERVATIVE_RASTER: UInt64 = 0x0000000000000004
/** @brief 能力标志：间接绘制 */
public const CAPS_DRAW_INDIRECT: UInt64 = 0x0000000000000008
/** @brief 能力标志：计数间接绘制 */
public const CAPS_DRAW_INDIRECT_COUNT: UInt64 = 0x0000000000000010
/** @brief 能力标志：片元排序 */
public const CAPS_FRAGMENT_ORDERING: UInt64 = 0x0000000000000020
/** @brief 能力标志：图形调试器 */
public const CAPS_GRAPHICS_DEBUGGER: UInt64 = 0x0000000000000040
/** @brief 能力标志：HDR10 */
public const CAPS_HDR10: UInt64 = 0x0000000000000080
/** @brief 能力标志：图像读写 */
public const CAPS_IMAGE_RW: UInt64 = 0x0000000000000100
/** @brief 能力标志：32 位索引 */
public const CAPS_INDEX32: UInt64 = 0x0000000000000200
/** @brief 能力标志：图元 ID */
public const CAPS_PRIMITIVE_ID: UInt64 = 0x0000000000000400
/** @brief 能力标志：多线程渲染 */
public const CAPS_RENDERER_MULTITHREADED: UInt64 = 0x0000000000000800
/** @brief 能力标志：交换链 */
public const CAPS_SWAP_CHAIN: UInt64 = 0x0000000000001000
/** @brief 能力标志：立方体贴图数组 */
public const CAPS_TEXTURE_CUBE_ARRAY: UInt64 = 0x0000000000002000
/** @brief 能力标志：纹理直接访问 */
public const CAPS_TEXTURE_DIRECT_ACCESS: UInt64 = 0x0000000000004000
/** @brief 能力标志：外部纹理 */
public const CAPS_TEXTURE_EXTERNAL: UInt64 = 0x0000000000008000
/** @brief 能力标志：外部共享纹理 */
public const CAPS_TEXTURE_EXTERNAL_SHARED: UInt64 = 0x0000000000010000
/** @brief 能力标志：透明后缓冲 */
public const CAPS_TRANSPARENT_BACKBUFFER: UInt64 = 0x0000000000020000
/** @brief 能力标志：可变速率着色 */
public const CAPS_VARIABLE_RATE_SHADING: UInt64 = 0x0000000000040000
/** @brief 能力标志：Uint10 顶点属性 */
public const CAPS_VERTEX_ATTRIB_UINT10: UInt64 = 0x0000000000080000
/** @brief 能力标志：硬件视频解码 */
public const CAPS_VIDEO_DECODE: UInt64 = 0x0000000000100000
/** @brief 能力标志：顶点着色器视口层 */
public const CAPS_VIEWPORT_LAYER_ARRAY: UInt64 = 0x0000000000200000

// =============================================================================
// Texture format capabilities
// =============================================================================

/** @brief 纹理格式能力：无 */
public const CAPS_FORMAT_TEXTURE_NONE: UInt32 = 0x00000000
/** @brief 支持 2D 纹理 */
public const CAPS_FORMAT_TEXTURE_2D: UInt32 = 0x00000001
/** @brief 支持 SRGB 2D 纹理 */
public const CAPS_FORMAT_TEXTURE_2D_SRGB: UInt32 = 0x00000002
/** @brief 模拟 2D 纹理 */
public const CAPS_FORMAT_TEXTURE_2D_EMULATED: UInt32 = 0x00000004
/** @brief 支持 3D 纹理 */
public const CAPS_FORMAT_TEXTURE_3D: UInt32 = 0x00000008
/** @brief 支持 SRGB 3D 纹理 */
public const CAPS_FORMAT_TEXTURE_3D_SRGB: UInt32 = 0x00000010
/** @brief 模拟 3D 纹理 */
public const CAPS_FORMAT_TEXTURE_3D_EMULATED: UInt32 = 0x00000020
/** @brief 支持立方体贴图 */
public const CAPS_FORMAT_TEXTURE_CUBE: UInt32 = 0x00000040
/** @brief 支持 SRGB 立方体贴图 */
public const CAPS_FORMAT_TEXTURE_CUBE_SRGB: UInt32 = 0x00000080
/** @brief 模拟立方体贴图 */
public const CAPS_FORMAT_TEXTURE_CUBE_EMULATED: UInt32 = 0x00000100
/** @brief 支持顶点缓冲纹理 */
public const CAPS_FORMAT_TEXTURE_VERTEX: UInt32 = 0x00000200
/** @brief 支持图像读取 */
public const CAPS_FORMAT_TEXTURE_IMAGE_READ: UInt32 = 0x00000400
/** @brief 支持图像写入 */
public const CAPS_FORMAT_TEXTURE_IMAGE_WRITE: UInt32 = 0x00000800
/** @brief 支持帧缓冲 */
public const CAPS_FORMAT_TEXTURE_FRAMEBUFFER: UInt32 = 0x00001000
/** @brief 支持 MSAA 帧缓冲 */
public const CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA: UInt32 = 0x00002000
/** @brief 支持 MSAA */
public const CAPS_FORMAT_TEXTURE_MSAA: UInt32 = 0x00004000
/** @brief 支持自动生成 Mip */
public const CAPS_FORMAT_TEXTURE_MIP_AUTOGEN: UInt32 = 0x00008000
/** @brief 可用作后缓冲格式 */
public const CAPS_FORMAT_TEXTURE_BACKBUFFER: UInt32 = 0x00010000
/** @brief 可用作视频解码目标 */
public const CAPS_FORMAT_TEXTURE_VIDEO_DECODE_DST: UInt32 = 0x00020000

// =============================================================================
// Video codec capabilities（Caps.codecs 表项，UInt32）
// =============================================================================

/** @brief 视频编解码能力：不支持 */
public const CAPS_VIDEO_CODEC_NONE: UInt32 = 0x00000000
/** @brief 支持 8 位采样深度 */
public const CAPS_VIDEO_CODEC_BIT_8: UInt32 = 0x00000001
/** @brief 支持 10 位采样深度 */
public const CAPS_VIDEO_CODEC_BIT_10: UInt32 = 0x00000002
/** @brief 支持 12 位采样深度 */
public const CAPS_VIDEO_CODEC_BIT_12: UInt32 = 0x00000004
/** @brief 支持 4:2:0 色度子采样 */
public const CAPS_VIDEO_CODEC_CHROMA_420: UInt32 = 0x00000008
/** @brief 支持 4:2:2 色度子采样 */
public const CAPS_VIDEO_CODEC_CHROMA_422: UInt32 = 0x00000010
/** @brief 支持 4:4:4 色度子采样 */
public const CAPS_VIDEO_CODEC_CHROMA_444: UInt32 = 0x00000020

// =============================================================================
// Resolve flags
// =============================================================================

/** @brief 解析标志：无 */
public const RESOLVE_NONE: UInt8 = 0x00
/** @brief 自动生成 Mip */
public const RESOLVE_AUTO_GEN_MIPS: UInt8 = 0x01

// =============================================================================
// PCI IDs
// =============================================================================

/** @brief PCI ID：无（任意） */
public const PCI_ID_NONE: UInt16 = 0x0000
/** @brief PCI ID：软件光栅化器 */
public const PCI_ID_SOFTWARE_RASTERIZER: UInt16 = 0x0001
/** @brief PCI ID：AMD */
public const PCI_ID_AMD: UInt16 = 0x1002
/** @brief PCI ID：Apple */
public const PCI_ID_APPLE: UInt16 = 0x106B
/** @brief PCI ID：Intel */
public const PCI_ID_INTEL: UInt16 = 0x8086
/** @brief PCI ID：NVIDIA */
public const PCI_ID_NVIDIA: UInt16 = 0x10DE
/** @brief PCI ID：Microsoft */
public const PCI_ID_MICROSOFT: UInt16 = 0x1414
/** @brief PCI ID：ARM */
public const PCI_ID_ARM: UInt16 = 0x13B5

// =============================================================================
// Cube map faces
// =============================================================================

/** @brief 立方体贴图 +X 面 */
public const CUBE_MAP_POSITIVE_X: UInt8 = 0x00
/** @brief 立方体贴图 -X 面 */
public const CUBE_MAP_NEGATIVE_X: UInt8 = 0x01
/** @brief 立方体贴图 +Y 面 */
public const CUBE_MAP_POSITIVE_Y: UInt8 = 0x02
/** @brief 立方体贴图 -Y 面 */
public const CUBE_MAP_NEGATIVE_Y: UInt8 = 0x03
/** @brief 立方体贴图 +Z 面 */
public const CUBE_MAP_POSITIVE_Z: UInt8 = 0x04
/** @brief 立方体贴图 -Z 面 */
public const CUBE_MAP_NEGATIVE_Z: UInt8 = 0x05

// =============================================================================
// Video decoder flags（VideoDecoderInit.flags / VideoDecoderFrame.flags，UInt8）
// =============================================================================

/** @brief 视频解码器初始化：无标志 */
public const VIDEO_DECODER_INIT_NONE: UInt8 = 0x00
/** @brief 视频解码器初始化：按 ptsUs 缓存已提交的访问单元以支持回放/循环 */
public const VIDEO_DECODER_INIT_RETAIN: UInt8 = 0x01

/** @brief 视频解码帧提交：无标志 */
public const VIDEO_DECODE_FRAME_NONE: UInt8 = 0x00
/** @brief 视频解码帧提交：位置切换后的首批数据（首个 AU 必须是干净 IDR） */
public const VIDEO_DECODE_FRAME_SET: UInt8 = 0x01
/** @brief 视频解码帧提交：跳过本次画面挑选（批量加载时避免画面抖动） */
public const VIDEO_DECODE_FRAME_NO_BLIT: UInt8 = 0x02
/** @brief 视频解码帧提交：标记片段最后一个访问单元 */
public const VIDEO_DECODE_FRAME_FINAL: UInt8 = 0x04
/** @brief 视频解码帧提交：播放时间超过缓存范围时按模循环 */
public const VIDEO_DECODE_FRAME_LOOP: UInt8 = 0x08
