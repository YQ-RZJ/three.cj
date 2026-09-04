/**
 * @file[zh-cn] bgfx 背景渲染
 * @brief[zh-cn] 替代 WebGLBackground，渲染场景背景（颜色/纹理/天空盒）
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLBackground.js。WebGLBackground 负责渲染场景的背景（纯色、纹理或天空盒）。bgfx 通过 bgfx_set_view_clear_cj 设置清除颜色。
 *
 * @file[en] bgfx Background Rendering
 * @brief[en] Replace WebGLBackground, render scene background (color/texture/skybox)
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLBackground.js. WebGLBackground renders scene backgrounds (solid color, texture, or skybox). bgfx sets clear color via bgfx_set_view_clear_cj.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 背景渲染
 * @explain[zh-cn] 对照 WebGLBackground，管理场景背景的渲染。bgfx 通过 bgfx_set_view_clear_cj 设置清除颜色。
 *
 * @brief[en] bgfx background rendering
 * @explain[en] Mirrors WebGLBackground, managing scene background rendering. bgfx sets clear color via bgfx_set_view_clear_cj.
 */
public class BgfxBackground {
    /**
     * @brief[zh-cn] 当前清除颜色 R 分量
     */
    private var clearColorR: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 当前清除颜色 G 分量
     */
    private var clearColorG: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 当前清除颜色 B 分量
     */
    private var clearColorB: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 当前清除 Alpha 分量
     */
    private var clearColorA: Float32 = 1.0f32
    /**
     * @brief[zh-cn] 当前背景版本号
     */
    private var currentBackgroundVersion: Int64 = 0

    public init() {}

    /**
     * @brief[zh-cn] 渲染背景
     * @explain[zh-cn] 对照 WebGLBackground.render()
     * @param[zh-cn] viewId bgfx 视图 ID
     * r 背景颜色 R 分量 (0-1)
     * g 背景颜色 G 分量 (0-1)
     * b 背景颜色 B 分量 (0-1)
     * a 背景颜色 A 分量 (0-1)
     * forceClear 是否强制清除
     *
     * @brief[en] Render background
     * @explain[en] Mirrors WebGLBackground.render()
     * @param[en] viewId bgfx view ID
     * r Background color R component (0-1)
     * g Background color G component (0-1)
     * b Background color B component (0-1)
     * a Background color A component (0-1)
     * forceClear Whether to force clear
     */
    public func render(viewId: ViewId, r: Float32, g: Float32, b: Float32, a: Float32, forceClear: Bool): Unit {
        // 检查颜色是否变化
        let colorChanged = (r != clearColorR || g != clearColorG || b != clearColorB || a != clearColorA)

        if (colorChanged || forceClear) {
            clearColorR = r
            clearColorG = g
            clearColorB = b
            clearColorA = a

            // 设置视图清除颜色（BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH）
            let clearFlags: UInt16 = CLEAR_COLOR | CLEAR_DEPTH  // COLOR | DEPTH
            bgfx_set_view_clear_cj(viewId, clearFlags,
                uint32FromRGBA(r, g, b, a), 1.0f32, 0u8)
        }
    }

    /**
     * @brief[zh-cn] 将 RGBA 浮点颜色转换为 uint32（ABGR 格式，bgfx 使用）
     * @param[zh-cn] r R 分量 (0-1)
     * g G 分量 (0-1)
     * b B 分量 (0-1)
     * a A 分量 (0-1)
     * @return[zh-cn] ABGR 格式的 uint32 颜色值
     *
     * @brief[en] Convert RGBA float color to uint32 (ABGR format, used by bgfx)
     * @param[en] r R component (0-1)
     * g G component (0-1)
     * b B component (0-1)
     * a A component (0-1)
     * @return[en] ABGR format uint32 color value
     */
    private func uint32FromRGBA(r: Float32, g: Float32, b: Float32, a: Float32): UInt32 {
        let ri = UInt32(r * 255.0f32 + 0.5f32)
        let gi = UInt32(g * 255.0f32 + 0.5f32)
        let bi = UInt32(b * 255.0f32 + 0.5f32)
        let ai = UInt32(a * 255.0f32 + 0.5f32)
        return (ai << 24) | (bi << 16) | (gi << 8) | ri
    }
}
