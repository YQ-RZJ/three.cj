/**
 * @file[zh-cn] IBackground
 * @brief[zh-cn] 场景背景标记接口
 * @explain[zh-cn] three.js 的 Scene.background 类型为 Color | Texture | CubeTexture（联合类型）。cj 侧仓颉无联合类型，原用 Option<Any> 表达；为消除 Any，定义本标记接口。实现方（math 包 Color、textures 包 Texture/CubeTexture）实现本接口；使用方（scenes 包 Scene）仅以接口持有背景引用，渲染器（Background）运行时 match 具体类型分派（Color → clear 色，Texture/CubeTexture → 环境贴图）。
 *
 * @file[en] IBackground
 * @brief[en] Scene background marker interface
 * @explain[en] In three.js, Scene.background is of type Color | Texture | CubeTexture (union type). Cangjie has no union types, so Option<Any> was originally used; to eliminate Any, this marker interface is defined. Implementers (math package Color, textures package Texture/CubeTexture) implement this interface; consumers (scenes package Scene) hold background references via the interface, and the renderer (Background) dispatches at runtime by matching concrete types (Color → clear color, Texture/CubeTexture → environment map). JS reference: Scene.background (Color/Texture/CubeTexture union).
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 场景背景标记接口：Scene.background 的元素类型
 * @explain[zh-cn] 消除 Any，让 Color/Texture/CubeTexture 共享统一接口类型
 *
 * @brief[en] Scene background marker interface: element type of Scene.background
 * @explain[en] Eliminates Any, allowing Color/Texture/CubeTexture to share a unified interface type
 */
public interface IBackground {
}
