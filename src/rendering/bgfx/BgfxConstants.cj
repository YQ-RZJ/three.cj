/**
 * @file[zh-cn] bgfx 常量映射
 * @brief[zh-cn] 替代 WebGLConstants + WebGPUConstants，定义 three.js 常量到 bgfx 常量的映射
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLConstants.js 和 WebGPUConstants.js。在 WebGL 中需要将 three.js 常量映射为 WebGL 常量，在 bgfx 中直接使用 bgfx 定义的常量。所有数值一律引用 bgfx4cj 常量，不硬编码。
 *
 * @file[en] bgfx Constants Mapping
 * @brief[en] Replaces WebGLConstants + WebGPUConstants, defines mappings from three.js constants to bgfx constants
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLConstants.js and WebGPUConstants.js. In WebGL, three.js constants are mapped to WebGL constants; in bgfx, bgfx-defined constants are used directly. All values reference bgfx4cj constants, no hardcoding.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx as bgfx
import three.utils.constants.*

/**
 * @brief[zh-cn] bgfx 常量映射
 * @explain[zh-cn] 提供 three.js 渲染常量到 bgfx 常量的映射。对照 WebGLConstants，将 GL 常量替换为 bgfx 等效值。
 *
 * @brief[en] bgfx constants mapping
 * @explain[en] Provides mappings from three.js rendering constants to bgfx constants. Corresponds to WebGLConstants, replacing GL constants with bgfx equivalents.
 */
public class BgfxConstants {
    // ===== 绘制模式 =====
    /**
     * @brief[zh-cn] 三角形
     *
     * @brief[en] Triangles
     */
    public static let TRIANGLES: UInt64 = 0u64
    /**
     * @brief[zh-cn] 三角形条带
     *
     * @brief[en] Triangle strip
     */
    public static let TRIANGLE_STRIP: UInt64 = bgfx.STATE_PT_TRISTRIP
    /**
     * @brief[zh-cn] 线段
     *
     * @brief[en] Lines
     */
    public static let LINES: UInt64 = bgfx.STATE_PT_LINES
    /**
     * @brief[zh-cn] 线段条带
     *
     * @brief[en] Line strip
     */
    public static let LINE_STRIP: UInt64 = bgfx.STATE_PT_LINESTRIP
    /**
     * @brief[zh-cn] 点
     *
     * @brief[en] Points
     */
    public static let POINTS: UInt64 = bgfx.STATE_PT_POINTS

    // ===== 纹理标志 =====
    /**
     * @brief[zh-cn] 渲染目标纹理
     *
     * @brief[en] Render target texture
     */
    public static let TEXTURE_RT: UInt64 = bgfx.TEXTURE_RT
    /**
     * @brief[zh-cn] 纹理可作 blit 目标
     *
     * @brief[en] Texture blit destination
     */
    public static let TEXTURE_BLIT_DST: UInt64 = bgfx.TEXTURE_BLIT_DST
    /**
     * @brief[zh-cn] 纹理 sRGB 编码
     *
     * @brief[en] Texture sRGB encoding
     */
    public static let TEXTURE_SRGB: UInt64 = bgfx.TEXTURE_SRGB
    /**
     * @brief[zh-cn] 纹理回读
     *
     * @brief[en] Texture read back
     */
    public static let TEXTURE_READ_BACK: UInt64 = bgfx.TEXTURE_READ_BACK

    // ===== 采样器标志 =====
    /**
     * @brief[zh-cn] U 轴钳制
     *
     * @brief[en] U axis clamp
     */
    public static let SAMPLER_U_CLAMP: UInt32 = bgfx.SAMPLER_U_CLAMP
    /**
     * @brief[zh-cn] U 轴镜像
     *
     * @brief[en] U axis mirror
     */
    public static let SAMPLER_U_MIRROR: UInt32 = bgfx.SAMPLER_U_MIRROR
    /**
     * @brief[zh-cn] U 轴边界色
     *
     * @brief[en] U axis border
     */
    public static let SAMPLER_U_BORDER: UInt32 = bgfx.SAMPLER_U_BORDER
    /**
     * @brief[zh-cn] V 轴钳制
     *
     * @brief[en] V axis clamp
     */
    public static let SAMPLER_V_CLAMP: UInt32 = bgfx.SAMPLER_V_CLAMP
    /**
     * @brief[zh-cn] V 轴镜像
     *
     * @brief[en] V axis mirror
     */
    public static let SAMPLER_V_MIRROR: UInt32 = bgfx.SAMPLER_V_MIRROR
    /**
     * @brief[zh-cn] V 轴边界色
     *
     * @brief[en] V axis border
     */
    public static let SAMPLER_V_BORDER: UInt32 = bgfx.SAMPLER_V_BORDER
    /**
     * @brief[zh-cn] W 轴钳制
     *
     * @brief[en] W axis clamp
     */
    public static let SAMPLER_W_CLAMP: UInt32 = bgfx.SAMPLER_W_CLAMP
    /**
     * @brief[zh-cn] 缩小过滤：最近邻
     *
     * @brief[en] Min filter: nearest
     */
    public static let SAMPLER_MIN_POINT: UInt32 = bgfx.SAMPLER_MIN_POINT
    /**
     * @brief[zh-cn] 放大过滤：最近邻
     *
     * @brief[en] Mag filter: nearest
     */
    public static let SAMPLER_MAG_POINT: UInt32 = bgfx.SAMPLER_MAG_POINT
    /**
     * @brief[zh-cn] mip 过滤：最近邻
     *
     * @brief[en] Mip filter: nearest
     */
    public static let SAMPLER_MIP_POINT: UInt32 = bgfx.SAMPLER_MIP_POINT

    // ===== Sampler 比较标志 =====
    /**
     * @brief[zh-cn] 采样器比较模式：小于等于
     *
     * @brief[en] Sampler compare: less-or-equal
     */
    public static let SAMPLER_COMPARE_LEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_LEQUAL
    /**
     * @brief[zh-cn] 采样器比较模式：小于
     *
     * @brief[en] Sampler compare: less
     */
    public static let SAMPLER_COMPARE_LESS: UInt32 = bgfx.SAMPLER_COMPARE_LESS
    /**
     * @brief[zh-cn] 采样器比较模式：等于
     *
     * @brief[en] Sampler compare: equal
     */
    public static let SAMPLER_COMPARE_EQUAL: UInt32 = bgfx.SAMPLER_COMPARE_EQUAL
    /**
     * @brief[zh-cn] 采样器比较模式：大于等于
     *
     * @brief[en] Sampler compare: greater-or-equal
     */
    public static let SAMPLER_COMPARE_GEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_GEQUAL
    /**
     * @brief[zh-cn] 采样器比较模式：大于
     *
     * @brief[en] Sampler compare: greater
     */
    public static let SAMPLER_COMPARE_GREATER: UInt32 = bgfx.SAMPLER_COMPARE_GREATER
    /**
     * @brief[zh-cn] 采样器比较模式：不等于
     *
     * @brief[en] Sampler compare: not-equal
     */
    public static let SAMPLER_COMPARE_NOTEQUAL: UInt32 = bgfx.SAMPLER_COMPARE_NOTEQUAL
    /**
     * @brief[zh-cn] 采样器比较模式：从不
     *
     * @brief[en] Sampler compare: never
     */
    public static let SAMPLER_COMPARE_NEVER: UInt32 = bgfx.SAMPLER_COMPARE_NEVER
    /**
     * @brief[zh-cn] 采样器比较模式：始终
     *
     * @brief[en] Sampler compare: always
     */
    public static let SAMPLER_COMPARE_ALWAYS: UInt32 = bgfx.SAMPLER_COMPARE_ALWAYS
    /**
     * @brief[zh-cn] 各向异性最小化过滤
     *
     * @brief[en] Anisotropic min filter
     */
    public static let SAMPLER_MIN_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MIN_ANISOTROPIC
    /**
     * @brief[zh-cn] 各向异性最大化过滤
     *
     * @brief[en] Anisotropic mag filter
     */
    public static let SAMPLER_MAG_ANISOTROPIC: UInt32 = bgfx.SAMPLER_MAG_ANISOTROPIC

    // ===== 深度测试 =====
    /**
     * @brief[zh-cn] 深度测试：从不通过
     *
     * @brief[en] Depth test: never
     */
    public static let DEPTH_TEST_NEVER: UInt64 = bgfx.STATE_DEPTH_TEST_NEVER
    /**
     * @brief[zh-cn] 深度测试：小于
     *
     * @brief[en] Depth test: less
     */
    public static let DEPTH_TEST_LESS: UInt64 = bgfx.STATE_DEPTH_TEST_LESS
    /**
     * @brief[zh-cn] 深度测试：等于
     *
     * @brief[en] Depth test: equal
     */
    public static let DEPTH_TEST_EQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_EQUAL
    /**
     * @brief[zh-cn] 深度测试：小于等于
     *
     * @brief[en] Depth test: less-or-equal
     */
    public static let DEPTH_TEST_LEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_LEQUAL
    /**
     * @brief[zh-cn] 深度测试：大于
     *
     * @brief[en] Depth test: greater
     */
    public static let DEPTH_TEST_GREATER: UInt64 = bgfx.STATE_DEPTH_TEST_GREATER
    /**
     * @brief[zh-cn] 深度测试：大于等于
     *
     * @brief[en] Depth test: greater-or-equal
     */
    public static let DEPTH_TEST_GEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_GEQUAL
    /**
     * @brief[zh-cn] 深度测试：不等于
     *
     * @brief[en] Depth test: not-equal
     */
    public static let DEPTH_TEST_NOTEQUAL: UInt64 = bgfx.STATE_DEPTH_TEST_NOTEQUAL
    /**
     * @brief[zh-cn] 深度测试：始终通过
     *
     * @brief[en] Depth test: always
     */
    public static let DEPTH_TEST_ALWAYS: UInt64 = bgfx.STATE_DEPTH_TEST_ALWAYS

    // ===== 混合因子 =====
    /**
     * @brief[zh-cn] 混合因子：零
     *
     * @brief[en] Blend factor: zero
     */
    public static let BLEND_ZERO: UInt64 = bgfx.STATE_BLEND_ZERO
    /**
     * @brief[zh-cn] 混合因子：一
     *
     * @brief[en] Blend factor: one
     */
    public static let BLEND_ONE: UInt64 = bgfx.STATE_BLEND_ONE
    /**
     * @brief[zh-cn] 混合因子：源颜色
     *
     * @brief[en] Blend factor: src color
     */
    public static let BLEND_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_SRC_COLOR
    /**
     * @brief[zh-cn] 混合因子：一减源颜色
     *
     * @brief[en] Blend factor: one minus src color
     */
    public static let BLEND_ONE_MINUS_SRC_COLOR: UInt64 = bgfx.STATE_BLEND_INV_SRC_COLOR
    /**
     * @brief[zh-cn] 混合因子：源 alpha
     *
     * @brief[en] Blend factor: src alpha
     */
    public static let BLEND_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA
    /**
     * @brief[zh-cn] 混合因子：一减源 alpha
     *
     * @brief[en] Blend factor: one minus src alpha
     */
    public static let BLEND_ONE_MINUS_SRC_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_SRC_ALPHA
    /**
     * @brief[zh-cn] 混合因子：目标 alpha
     *
     * @brief[en] Blend factor: dst alpha
     */
    public static let BLEND_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_DST_ALPHA
    /**
     * @brief[zh-cn] 混合因子：一减目标 alpha
     *
     * @brief[en] Blend factor: one minus dst alpha
     */
    public static let BLEND_ONE_MINUS_DST_ALPHA: UInt64 = bgfx.STATE_BLEND_INV_DST_ALPHA
    /**
     * @brief[zh-cn] 混合因子：目标颜色
     *
     * @brief[en] Blend factor: dst color
     */
    public static let BLEND_DST_COLOR: UInt64 = bgfx.STATE_BLEND_DST_COLOR
    /**
     * @brief[zh-cn] 混合因子：一减目标颜色
     *
     * @brief[en] Blend factor: one minus dst color
     */
    public static let BLEND_ONE_MINUS_DST_COLOR: UInt64 = bgfx.STATE_BLEND_INV_DST_COLOR
    /**
     * @brief[zh-cn] 混合因子：源 alpha 饱和
     *
     * @brief[en] Blend factor: src alpha saturate
     */
    public static let BLEND_SRC_ALPHA_SATURATE: UInt64 = bgfx.STATE_BLEND_SRC_ALPHA_SAT

    // ===== 混合方程 =====
    /**
     * @brief[zh-cn] 混合方程：加
     *
     * @brief[en] Blend equation: add
     */
    public static let BLEND_EQUATION_ADD: UInt64 = bgfx.STATE_BLEND_EQUATION_ADD
    /**
     * @brief[zh-cn] 混合方程：减
     *
     * @brief[en] Blend equation: subtract
     */
    public static let BLEND_EQUATION_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_SUB
    /**
     * @brief[zh-cn] 混合方程：反减
     *
     * @brief[en] Blend equation: reverse subtract
     */
    public static let BLEND_EQUATION_REVERSE_SUBTRACT: UInt64 = bgfx.STATE_BLEND_EQUATION_REVSUB
    /**
     * @brief[zh-cn] 混合方程：最小
     *
     * @brief[en] Blend equation: min
     */
    public static let BLEND_EQUATION_MIN: UInt64 = bgfx.STATE_BLEND_EQUATION_MIN
    /**
     * @brief[zh-cn] 混合方程：最大
     *
     * @brief[en] Blend equation: max
     */
    public static let BLEND_EQUATION_MAX: UInt64 = bgfx.STATE_BLEND_EQUATION_MAX

    // ===== 剔除模式 =====
    /**
     * @brief[zh-cn] 顺时针剔除（背面剔除）
     *
     * @brief[en] Clockwise culling (back-face culling)
     */
    public static let CULL_CW: UInt64 = bgfx.STATE_CULL_CW
    /**
     * @brief[zh-cn] 逆时针剔除（正面剔除）
     *
     * @brief[en] Counter-clockwise culling (front-face culling)
     */
    public static let CULL_CCW: UInt64 = bgfx.STATE_CULL_CCW

    // ===== 写入掩码 =====
    /**
     * @brief[zh-cn] 写入 R 通道
     *
     * @brief[en] Write R channel
     */
    public static let WRITE_R: UInt64 = bgfx.STATE_WRITE_R
    /**
     * @brief[zh-cn] 写入 G 通道
     *
     * @brief[en] Write G channel
     */
    public static let WRITE_G: UInt64 = bgfx.STATE_WRITE_G
    /**
     * @brief[zh-cn] 写入 B 通道
     *
     * @brief[en] Write B channel
     */
    public static let WRITE_B: UInt64 = bgfx.STATE_WRITE_B
    /**
     * @brief[zh-cn] 写入 A 通道
     *
     * @brief[en] Write A channel
     */
    public static let WRITE_A: UInt64 = bgfx.STATE_WRITE_A
    /**
     * @brief[zh-cn] 写入深度
     *
     * @brief[en] Write depth
     */
    public static let WRITE_Z: UInt64 = bgfx.STATE_WRITE_Z
    /**
     * @brief[zh-cn] 写入 RGB 通道
     *
     * @brief[en] Write RGB channels
     */
    public static let WRITE_RGB: UInt64 = bgfx.STATE_WRITE_RGB
    /**
     * @brief[zh-cn] 写入掩码
     *
     * @brief[en] Write mask
     */
    public static let WRITE_MASK: UInt64 = bgfx.STATE_WRITE_MASK

    // ===== 其他状态 =====
    /**
     * @brief[zh-cn] MSAA 抗锯齿
     *
     * @brief[en] MSAA anti-aliasing
     */
    public static let MSAA: UInt64 = bgfx.STATE_MSAA
    /**
     * @brief[zh-cn] 线框抗锯齿
     *
     * @brief[en] Line anti-aliasing
     */
    public static let LINEAA: UInt64 = bgfx.STATE_LINEAA
    /**
     * @brief[zh-cn] 保守光栅化
     *
     * @brief[en] Conservative rasterization
     */
    public static let CONSERVATIVE_RASTER: UInt64 = bgfx.STATE_CONSERVATIVE_RASTER
    /**
     * @brief[zh-cn] 逆时针为正面
     *
     * @brief[en] Counter-clockwise front face
     */
    public static let FRONT_CCW: UInt64 = bgfx.STATE_FRONT_CCW
    /**
     * @brief[zh-cn] 默认状态
     *
     * @brief[en] Default state
     */
    public static let DEFAULT_STATE: UInt64 = bgfx.STATE_DEFAULT
    /**
     * @brief[zh-cn] 无状态
     *
     * @brief[en] None state
     */
    public static let NONE: UInt64 = bgfx.STATE_NONE

    // ===== 调试标志 =====
    /**
     * @brief[zh-cn] 无调试标志
     *
     * @brief[en] No debug flags
     */
    public static let DEBUG_NONE: UInt32 = bgfx.DEBUG_NONE
    /**
     * @brief[zh-cn] 线框模式
     *
     * @brief[en] Wireframe mode
     */
    public static let DEBUG_WIREFRAME: UInt32 = bgfx.DEBUG_WIREFRAME

    // ===== 清除标志 =====
    /**
     * @brief[zh-cn] 清除颜色
     *
     * @brief[en] Clear color
     */
    public static let CLEAR_COLOR: UInt16 = bgfx.CLEAR_COLOR
    /**
     * @brief[zh-cn] 清除深度
     *
     * @brief[en] Clear depth
     */
    public static let CLEAR_DEPTH: UInt16 = bgfx.CLEAR_DEPTH
    /**
     * @brief[zh-cn] 清除模板
     *
     * @brief[en] Clear stencil
     */
    public static let CLEAR_STENCIL: UInt16 = bgfx.CLEAR_STENCIL
    /**
     * @brief[zh-cn] 无清除
     *
     * @brief[en] Clear none
     */
    public static let CLEAR_NONE: UInt16 = bgfx.CLEAR_NONE

    // ===== 纹理格式 =====
    /**
     * @brief[zh-cn] RGBA8 纹理格式
     *
     * @brief[en] RGBA8 texture format
     */
    public static let TEXTURE_FORMAT_RGBA8: UInt32 = bgfx.TextureFormat.RGBA8.value()
    /**
     * @brief[zh-cn] RGBA16F 纹理格式
     *
     * @brief[en] RGBA16F texture format
     */
    public static let TEXTURE_FORMAT_RGBA16F: UInt32 = bgfx.TextureFormat.RGBA16F.value()
    /**
     * @brief[zh-cn] RGBA32F 纹理格式
     *
     * @brief[en] RGBA32F texture format
     */
    public static let TEXTURE_FORMAT_RGBA32F: UInt32 = bgfx.TextureFormat.RGBA32F.value()
    /**
     * @brief[zh-cn] 深度纹理格式
     *
     * @brief[en] Depth texture format
     */
    public static let TEXTURE_FORMAT_DEPTH: UInt32 = bgfx.TextureFormat.D24.value()
    /**
     * @brief[zh-cn] 深度模板纹理格式
     *
     * @brief[en] Depth-stencil texture format
     */
    public static let TEXTURE_FORMAT_DEPTH_STENCIL: UInt32 = bgfx.TextureFormat.D24S8.value()

    // ===== 模板操作 =====
    /**
     * @brief[zh-cn] 模板测试：小于等于
     *
     * @brief[en] Stencil test: less-or-equal
     */
    public static let STENCIL_TEST_LESS: UInt32 = bgfx.STENCIL_TEST_LESS
    /**
     * @brief[zh-cn] 模板测试：小于等于
     *
     * @brief[en] Stencil test: less-or-equal
     */
    public static let STENCIL_TEST_LEQUAL: UInt32 = bgfx.STENCIL_TEST_LEQUAL
    /**
     * @brief[zh-cn] 模板测试：等于
     *
     * @brief[en] Stencil test: equal
     */
    public static let STENCIL_TEST_EQUAL: UInt32 = bgfx.STENCIL_TEST_EQUAL
    /**
     * @brief[zh-cn] 模板测试：大于等于
     *
     * @brief[en] Stencil test: greater-or-equal
     */
    public static let STENCIL_TEST_GEQUAL: UInt32 = bgfx.STENCIL_TEST_GEQUAL
    /**
     * @brief[zh-cn] 模板测试：大于
     *
     * @brief[en] Stencil test: greater
     */
    public static let STENCIL_TEST_GREATER: UInt32 = bgfx.STENCIL_TEST_GREATER
    /**
     * @brief[zh-cn] 模板测试：不等于
     *
     * @brief[en] Stencil test: not-equal
     */
    public static let STENCIL_TEST_NOTEQUAL: UInt32 = bgfx.STENCIL_TEST_NOTEQUAL
    /**
     * @brief[zh-cn] 模板测试：从不
     *
     * @brief[en] Stencil test: never
     */
    public static let STENCIL_TEST_NEVER: UInt32 = bgfx.STENCIL_TEST_NEVER
    /**
     * @brief[zh-cn] 模板测试：始终
     *
     * @brief[en] Stencil test: always
     */
    public static let STENCIL_TEST_ALWAYS: UInt32 = bgfx.STENCIL_TEST_ALWAYS
    /**
     * @brief[zh-cn] 模板操作 FAIL 阶段：保持
     *
     * @brief[en] Stencil op fail-stencil: keep
     */
    public static let STENCIL_OP_FAIL_S_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_S_KEEP
    /**
     * @brief[zh-cn] 模板操作 ZFAIL 阶段：保持
     *
     * @brief[en] Stencil op fail-depth: keep
     */
    public static let STENCIL_OP_FAIL_Z_KEEP: UInt32 = bgfx.STENCIL_OP_FAIL_Z_KEEP
    /**
     * @brief[zh-cn] 模板操作 PASS 阶段：保持
     *
     * @brief[en] Stencil op pass-depth: keep
     */
    public static let STENCIL_OP_PASS_Z_KEEP: UInt32 = bgfx.STENCIL_OP_PASS_Z_KEEP
    /**
     * @brief[zh-cn] 模板操作 PASS 阶段：替换
     *
     * @brief[en] Stencil op pass-depth: replace
     */
    public static let STENCIL_OP_PASS_Z_REPLACE: UInt32 = bgfx.STENCIL_OP_PASS_Z_REPLACE

    /**
     * @brief[zh-cn] 将 three.js 深度测试模式转换为 bgfx 状态标志
     * @param[zh-cn] depthFunc three.js 深度测试常量
     * @return[zh-cn] bgfx 深度测试状态标志
     *
     * @brief[en] Converts three.js depth test mode to bgfx state flag
     * @param[en] depthFunc Three.js depth test constant
     * @return[en] bgfx depth test state flag
     */
    public static func convertDepthFunc(depthFunc: Int64): UInt64 {
        if (depthFunc == NeverDepth) { return DEPTH_TEST_NEVER }
        if (depthFunc == LessDepth) { return DEPTH_TEST_LESS }
        if (depthFunc == EqualDepth) { return DEPTH_TEST_EQUAL }
        if (depthFunc == LessEqualDepth) { return DEPTH_TEST_LEQUAL }
        if (depthFunc == GreaterDepth) { return DEPTH_TEST_GREATER }
        if (depthFunc == GreaterEqualDepth) { return DEPTH_TEST_GEQUAL }
        if (depthFunc == NotEqualDepth) { return DEPTH_TEST_NOTEQUAL }
        if (depthFunc == AlwaysDepth) { return DEPTH_TEST_ALWAYS }
        return DEPTH_TEST_LEQUAL  // 默认
    }

    /**
     * @brief[zh-cn] 将 three.js 混合模式转换为 bgfx 混合状态
     * @param[zh-cn] srcFactor 源混合因子
     * dstFactor 目标混合因子
     * srcAlphaFactor 源 alpha 混合因子
     * dstAlphaFactor 目标 alpha 混合因子
     * @return[zh-cn] bgfx 混合状态
     *
     * @brief[en] Converts three.js blend mode to bgfx blend state
     * @param[en] srcFactor Source blend factor
     * dstFactor Destination blend factor
     * srcAlphaFactor Source alpha blend factor
     * dstAlphaFactor Destination alpha blend factor
     * @return[en] bgfx blend state
     */
    public static func convertBlendFunc(srcFactor: Int64, dstFactor: Int64, srcAlphaFactor: Int64, dstAlphaFactor: Int64): UInt64 {
        var state: UInt64 = 0u64
        state = state | convertBlendFactor(srcFactor)
        state = state | (convertBlendFactor(dstFactor) << 4u64)
        if (srcAlphaFactor != srcFactor || dstAlphaFactor != dstFactor) {
            state = state | bgfx.STATE_BLEND_INDEPENDENT
            state = state | (convertBlendFactor(srcAlphaFactor) << 8u64)
            state = state | (convertBlendFactor(dstAlphaFactor) << 12u64)
        }
        return state
    }

    /**
     * @brief[zh-cn] 将 three.js 混合因子转换为 bgfx 混合因子
     * @param[zh-cn] factor three.js 混合因子常量
     * @return[zh-cn] bgfx 混合因子
     *
     * @brief[en] Converts three.js blend factor to bgfx blend factor
     * @param[en] factor Three.js blend factor constant
     * @return[en] bgfx blend factor
     */
    public static func convertBlendFactor(factor: Int64): UInt64 {
        if (factor == ZeroFactor) { return BLEND_ZERO }
        if (factor == OneFactor) { return BLEND_ONE }
        if (factor == SrcColorFactor) { return BLEND_SRC_COLOR }
        if (factor == OneMinusSrcColorFactor) { return BLEND_ONE_MINUS_SRC_COLOR }
        if (factor == SrcAlphaFactor) { return BLEND_SRC_ALPHA }
        if (factor == OneMinusSrcAlphaFactor) { return BLEND_ONE_MINUS_SRC_ALPHA }
        if (factor == DstAlphaFactor) { return BLEND_DST_ALPHA }
        if (factor == OneMinusDstAlphaFactor) { return BLEND_ONE_MINUS_DST_ALPHA }
        if (factor == DstColorFactor) { return BLEND_DST_COLOR }
        if (factor == OneMinusDstColorFactor) { return BLEND_ONE_MINUS_DST_COLOR }
        if (factor == SrcAlphaSaturateFactor) { return BLEND_SRC_ALPHA_SATURATE }
        return BLEND_ONE  // 默认
    }

    /**
     * @brief[zh-cn] 将 three.js 侧面转换为 bgfx 剔除模式
     * @explain[zh-cn] bgfx 使用 STATE_FRONT_CCW，CCW = front face。FrontSide → CULL_CW（剔除背面），BackSide → CULL_CCW（剔除正面），DoubleSide → 0（不剔除）。
     * @param[zh-cn] side three.js 侧面常量
     * @return[zh-cn] bgfx 剔除模式标志
     *
     * @brief[en] Converts three.js side to bgfx cull mode
     * @explain[en] bgfx uses STATE_FRONT_CCW, CCW = front face. FrontSide → CULL_CW (cull back), BackSide → CULL_CCW (cull front), DoubleSide → 0 (no culling).
     * @param[en] side Three.js side constant
     * @return[en] bgfx cull mode flag
     */
    public static func convertCullMode(side: Int64): UInt64 {
        if (side == FrontSide) { return CULL_CW }
        if (side == BackSide) { return CULL_CCW }
        return 0u64
    }
}
