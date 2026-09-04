/**
 * @file[zh-cn] 背景
 * @brief[zh-cn] 场景背景渲染类，根据场景背景设置决定清除色
 * @explain[zh-cn] 
 * Background 继承自 DataMap，负责根据 scene.background 的类型（Color/Texture/None）
 * 设置 view0 的清除色。当 scene.background 为 Color 时覆盖 renderer.clearColor，
 * 否则保留 renderer.clearColor 已设置的值。
 *
 * @file[en] Background
 * @brief[en] Scene background rendering class, determines clear color based on scene background settings
 * @explain[en] 
 * Background extends DataMap and is responsible for setting the clear color of view0
 * based on the type of scene.background (Color/Texture/None). When scene.background is a Color,
 * it overrides renderer.clearColor; otherwise, it preserves the renderer.clearColor value.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.textures.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] 场景背景渲染类
 * @explain[zh-cn] 
 * 根据 scene.background 类型决定 view0 的清除色：
 * - scene.background = Some(Color) → 用该颜色作为清除色
 * - scene.background = None → 保留 renderer.clearColor
 * - scene.background = Texture/CubeTexture → 暂不支持，保留 renderer.clearColor
 *
 * @brief[en] Scene background rendering class
 * @explain[en] 
 * Determines the clear color of view0 based on scene.background type:
 * - scene.background = Some(Color) → uses that color as clear color
 * - scene.background = None → preserves renderer.clearColor
 * - scene.background = Texture/CubeTexture → not yet supported, preserves renderer.clearColor
 */
public open class Background <: DataMap {
    /**
     * @brief[zh-cn] 背景颜色
     *
     * @brief[en] Background color
     */
    public var color: Color

    /**
     * @brief[zh-cn] 背景纹理
     *
     * @brief[en] Background texture
     */
    public var texture: Texture

    /**
     * @brief[zh-cn] 背景强度
     *
     * @brief[en] Background intensity
     */
    public var intensity: Float64

    /**
     * @brief[zh-cn] 构造默认背景实例
     *
     * @brief[en] Constructs a default background instance
     */
    public init() {
        super()
        this.color = Color(0x000000); this.texture = Texture(); this.intensity = 1.0
    }

    /**
     * @brief[zh-cn] 渲染背景，按 three.js 语义决定 view0 的清除色
     * @explain[zh-cn] 
     * 当 scene.background 为 Color 时覆盖 renderer.clearColor；
     * 否则保留 beginRender 已设置的清除色，避免无条件覆盖导致灰色背景 bug。
     * @param[zh-cn] scene 场景对象
     *
     * @brief[en] Renders the background, determining view0 clear color by Three.js semantics
     * @explain[en] 
     * When scene.background is a Color, overrides renderer.clearColor;
     * otherwise preserves the clear color already set by beginRender, avoiding unconditional override that causes a gray background bug.
     * @param[en] scene Scene object
     */
    public func render(scene: Scene): Unit {
        match (scene.background) {
            case Some(bg) =>
                match (bg) {
                    case c: Color =>
                        let r = UInt8(c.r * 255.0)
                        let g = UInt8(c.g * 255.0)
                        let b = UInt8(c.b * 255.0)
                        let a = UInt8(255)
                        let newColor = (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(a)
                        bgfx_set_view_clear_cj(0, CLEAR_COLOR | CLEAR_DEPTH, newColor, 1.0f32, 0)
                    case _ => ()
                }
            case None => ()
        }
    }
}
