/**
 * @file[zh-cn] 深度图灰度可视化材质
 * @brief[zh-cn] 深度图灰度可视化材质（bgfx4cj扩展），将线性深度归一化映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将线性深度归一化映射为灰度：近=白、远=黑。
 * 用于 debug mode 1：直观验证场景深度分布是否正确。
 * 关联 ShaderLibs 程序名 "depthviz"（BgfxBackend._getOrCreateProgram 按 kind 映射）。
 *
 * @file[en] Depth Visualization Material
 * @brief[en] Depth visualization material (bgfx4cj extension), maps linear depth to grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps linear depth to normalized grayscale: near=white, far=black.
 * Used in debug mode 1 to visually verify scene depth distribution correctness.
 * Associated ShaderLibs program name "depthviz" (BgfxBackend._getOrCreateProgram maps by kind).
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 深度图灰度可视化材质，将线性深度归一化映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将线性深度归一化映射为灰度：近=白、远=黑。
 * 用于 debug mode 1：直观验证场景深度分布是否正确。
 *
 * @brief[en] Depth visualization material, maps linear depth to normalized grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps linear depth to normalized grayscale: near=white, far=black.
 * Used in debug mode 1 to visually verify scene depth distribution correctness.
 */
public class DepthVizMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的深度图灰度可视化材质
     *
     * @brief[en] Construct a new depth visualization material
     */
    public init() {
        super()
        this.kind = "DepthVizMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定DepthVizMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given DepthVizMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: DepthVizMaterial): DepthVizMaterial {
        super.copy(source)
        return this
    }
}
