/**
 * @file[zh-cn] 渲染包组
 * @brief[zh-cn] 渲染包分组，用于将多个渲染对象打包为渲染束
 * @explain[zh-cn] 
 * BundleGroup 对应 Three.js 中的 BundleGroup 概念，用于将多个渲染对象组合为一个渲染束，
 * 以便在一次 draw call 中批量提交，提高渲染性能。
 *
 * @file[en] BundleGroup
 * @brief[en] Render bundle group, used to package multiple render objects into render bundles
 * @explain[en] 
 * BundleGroup corresponds to the BundleGroup concept in Three.js, used to combine multiple render objects
 * into a render bundle for batch submission in a single draw call, improving rendering performance.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染包分组，用于将多个渲染对象打包为渲染束
 * @explain[zh-cn] 
 * 将多个渲染对象组合为一个渲染束，以便批量提交。
 *
 * @brief[en] Render bundle group, used to package multiple render objects into render bundles
 * @explain[en] 
 * Combines multiple render objects into a render bundle for batch submission.
 */
public open class BundleGroup {
    /**
     * @brief[zh-cn] 渲染包组标识符
     *
     * @brief[en] Bundle group identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 构造默认渲染包组
     *
     * @brief[en] Constructs a default bundle group
     */
    public init() { this.id = 0 }
}
