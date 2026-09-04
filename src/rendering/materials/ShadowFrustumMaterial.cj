/**
 * @file[zh-cn] 阴影相机视锥可视化材质
 * @brief[zh-cn] 阴影相机视锥可视化材质（bgfx4cj扩展）
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。与 ShadowProjMaterial 共用思路（ShaderLibs 里复用 shadowproj 程序），
 * 用于 debug mode 5：把视锥顶点经 lightProj * lightView 变换后输出。
 * 实际 sp_shadowfrustum 项目通常用 LineSegments 几何直接绘制 box，此材质保留兼容入口。
 * 关联 ShaderLibs 程序名 "shadowfrustum"。
 *
 * @file[en] Shadow Frustum Material
 * @brief[en] Shadow camera frustum visualization material (bgfx4cj extension)
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Shares approach with ShadowProjMaterial (reuses shadowproj program in ShaderLibs).
 * Used in debug mode 5: transforms frustum vertices via lightProj * lightView and outputs them.
 * In practice, sp_shadowfrustum projects typically use LineSegments geometry to draw the box directly;
 * this material is kept for compatibility.
 * Associated ShaderLibs program name "shadowfrustum".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 阴影相机视锥可视化材质
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。用于 debug mode 5：把视锥顶点经 lightProj * lightView 变换后输出。
 *
 * @brief[en] Shadow camera frustum visualization material
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Used in debug mode 5: transforms frustum vertices via lightProj * lightView.
 */
public class ShadowFrustumMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的阴影相机视锥可视化材质
     *
     * @brief[en] Construct a new shadow frustum material
     */
    public init() {
        super()
        this.kind = "ShadowFrustumMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定ShadowFrustumMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShadowFrustumMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ShadowFrustumMaterial): ShadowFrustumMaterial {
        super.copy(source)
        return this
    }
}
