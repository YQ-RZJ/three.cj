/**
 * @file[zh-cn] 渲染目标纹理访问接口
 * @brief[zh-cn] 解除 core→textures 循环依赖的接口，RenderTarget 通过本接口访问 Texture 的集成字段
 * @explain[zh-cn] RenderTarget 通过本接口访问 Texture 的 Level 8 集成字段，无需直接导入 three.rendering.textures.Texture。Texture 在 textures 包中 implement 本接口。对照规范第 9 节「循环依赖解决策略」：本接口位于 core 包（无 textures 依赖），textures 单向依赖 core 实现接口，core 侧经接口访问，依赖关系变为单向无环。
 *
 * @file[en] Render Target Texture Access Interface
 * @brief[en] Interface to break core→textures circular dependency, RenderTarget accesses Texture fields through this interface
 * @explain[en] RenderTarget accesses Texture's Level 8 integration fields through this interface, without directly importing three.rendering.textures.Texture. Texture implements this interface in the textures package. Per Section 9 "Circular Dependency Resolution Strategy": this interface resides in the core package (no textures dependency), textures unidirectionally depends on core to implement the interface, core accesses via the interface, making the dependency unidirectional and acyclic.
 */
package three.rendering.rendertarget

/**
 * @brief[zh-cn] 渲染目标纹理访问接口
 * @explain[zh-cn] RenderTarget 在 setSize/copy/setDepthTexture 中需访问 Texture 的 width/height/depth/isArrayTexture/isData3DTexture/renderTarget/clone 等字段。为避免 three.core 反向导入 three.rendering.textures 造成循环依赖，定义本接口在 core 包中，由 Texture 实现。仓颉接口属性需用 prop 声明。
 *
 * @brief[en] Render target texture access interface
 * @explain[en] RenderTarget needs to access Texture's width/height/depth/isArrayTexture/isData3DTexture/renderTarget/clone fields in setSize/copy/setDepthTexture. To avoid three.core reverse-importing three.rendering.textures causing circular dependency, this interface is defined in the core package and implemented by Texture. Cangjie interface properties must be declared with prop.
 */
public interface IRenderTargetTexture {
    /**
     * @brief[zh-cn] 贴图宽度（像素）
     *
     * @brief[en] Texture width in pixels
     */
    mut prop rtWidth: Int64
    /**
     * @brief[zh-cn] 贴图高度（像素）
     *
     * @brief[en] Texture height in pixels
     */
    mut prop rtHeight: Int64
    /**
     * @brief[zh-cn] 贴图深度（3D 纹理用）
     *
     * @brief[en] Texture depth (for 3D textures)
     */
    mut prop rtDepth: Int64
    /**
     * @brief[zh-cn] 是否数组纹理
     *
     * @brief[en] Whether this is an array texture
     */
    mut prop rtIsArrayTexture: Bool
    /**
     * @brief[zh-cn] 是否 3D 数据纹理
     *
     * @brief[en] Whether this is a 3D data texture
     */
    func rtIsData3DTexture(): Bool
    /**
     * @brief[zh-cn] 渲染目标反向引用（core 包内类型，同包直接引用避免 Any）
     *
     * @brief[en] Render target back reference (core package type, same-package direct reference to avoid Any)
     */
    mut prop rtRenderTarget: ?RenderTarget
    /**
     * @brief[zh-cn] 是否渲染目标纹理
     *
     * @brief[en] Whether this is a render target texture
     */
    mut prop rtIsRenderTargetTexture: Bool
    /**
     * @brief[zh-cn] 克隆自身（返回 IRenderTargetTexture）
     *
     * @brief[en] Clone itself (returns IRenderTargetTexture)
     */
    func rtClone(): IRenderTargetTexture
}
