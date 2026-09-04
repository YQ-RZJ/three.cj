/**
 * @file[zh-cn] IRenderTarget 渲染目标标记接口
 * @brief[zh-cn] 渲染目标标记接口，解耦 cameras 与 renderers 的包级循环依赖
 * @explain[zh-cn] Three.js 的 CubeCamera.renderTarget 是 WebGLCubeRenderTarget（renderers 包）。
 * 仓颉侧 cameras 包若直接 import renderers 会形成循环（renderers 依赖 cameras），
 * 因此将"渲染目标"抽象为本标记接口：
 * - 实现方（renderers 包 BgfxRenderTarget）实现本接口；
 * - 使用方（cameras 包 CubeCamera）仅以接口持有渲染目标引用，不依赖实现类型。
 *
 * @file[en] IRenderTarget Render target marker interface
 * @brief[en] Render target marker interface, decoupling circular dependency between cameras and renderers
 * @explain[en] In Three.js, CubeCamera.renderTarget is WebGLCubeRenderTarget (renderers package).
 * If the Cangjie cameras package directly imports renderers, a circular dependency forms
 * (renderers depends on cameras), so "render target" is abstracted as this marker interface:
 * - Implementor (BgfxRenderTarget in renderers package) implements this interface;
 * - Consumer (CubeCamera in cameras package) holds render target reference by interface only.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

/**
 * @brief[zh-cn] 渲染目标标记接口：CubeCamera.renderTarget 的元素类型
 *
 * @brief[en] Render target marker interface: element type of CubeCamera.renderTarget
 */
public interface IRenderTarget {
}
