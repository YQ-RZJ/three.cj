/**
 * @file[zh-cn] 阴影贴图全屏blit材质
 * @brief[zh-cn] 阴影贴图全屏blit材质（bgfx4cj扩展），用全屏四边形采样shadowMap铺满屏幕
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。用一个全屏四边形 + 简单 sampler2D 采样把 shadowMap 铺满屏幕。
 * 用于 debug mode 6：直观查看阴影贴图内容是否正确生成。
 * 关联 ShaderLibs 程序名 "shadowblit"。
 *
 * @file[en] Shadow Blit Material
 * @brief[en] Shadow map fullscreen blit material (bgfx4cj extension), samples shadowMap with fullscreen quad
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Uses a fullscreen quad with simple sampler2D sampling to fill the screen with the shadow map.
 * Used in debug mode 6 to visually inspect shadow map content.
 * Associated ShaderLibs program name "shadowblit".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 阴影贴图全屏blit材质，用全屏四边形采样shadowMap铺满屏幕
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。用于 debug mode 6：直观查看阴影贴图内容是否正确生成。
 *
 * @brief[en] Shadow map fullscreen blit material, samples shadowMap with fullscreen quad
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Used in debug mode 6 to visually inspect shadow map content.
 */
public class ShadowBlitMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的阴影贴图全屏blit材质
     *
     * @brief[en] Construct a new shadow blit material
     */
    public init() {
        super()
        this.kind = "ShadowBlitMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定ShadowBlitMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShadowBlitMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ShadowBlitMaterial): ShadowBlitMaterial {
        super.copy(source)
        return this
    }
}
