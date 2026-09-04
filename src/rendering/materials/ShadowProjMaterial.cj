/**
 * @file[zh-cn] 阴影投影UV可视化材质
 * @brief[zh-cn] 阴影投影UV可视化材质（bgfx4cj扩展），输出阴影UV覆盖范围
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。把 receiver 顶点经 directionalShadowMatrix 投影后的 xy 当颜色输出，
 * 顶点位置体现 UV 覆盖范围。
 * 用于 debug mode 7：验证阴影矩阵是否正确把世界坐标变换到 [0,1]² 阴影 UV 空间。
 * 关联 ShaderLibs 程序名 "shadowproj"。
 *
 * @file[en] Shadow Projection UV Material
 * @brief[en] Shadow projection UV visualization material (bgfx4cj extension), outputs shadow UV coverage
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Outputs the xy of receiver vertices after projection by directionalShadowMatrix as color,
 * with vertex positions showing UV coverage.
 * Used in debug mode 7 to verify that the shadow matrix correctly transforms world coordinates to [0,1]² shadow UV space.
 * Associated ShaderLibs program name "shadowproj".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 阴影投影UV可视化材质，输出阴影UV覆盖范围
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。用于 debug mode 7：验证阴影矩阵是否正确把世界坐标变换到 [0,1]² 阴影 UV 空间。
 *
 * @brief[en] Shadow projection UV visualization material, outputs shadow UV coverage
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Used in debug mode 7 to verify that the shadow matrix correctly
 * transforms world coordinates to [0,1]² shadow UV space.
 */
public class ShadowProjMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的阴影投影UV可视化材质
     *
     * @brief[en] Construct a new shadow projection UV material
     */
    public init() {
        super()
        this.kind = "ShadowProjMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定ShadowProjMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShadowProjMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: ShadowProjMaterial): ShadowProjMaterial {
        super.copy(source)
        return this
    }
}
