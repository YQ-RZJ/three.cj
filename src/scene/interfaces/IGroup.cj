/**
 * @file[zh-cn] IGroup
 * @brief[zh-cn] 渲染组标记接口（three.interfaces 独立接口包）
 * @explain[zh-cn] Three.js 的 Material.onBeforeRender 回调参数 group 是 Group 类型（objects 包）。
 * 仓颉侧 materials 包若直接 import objects 会形成循环依赖，
 * 因此将"渲染组"抽象为标记接口：实现方（objects 包 Group）实现本接口；
 * 使用方（materials 包 Material 回调参数）仅以接口持有渲染组引用，不依赖实现类型。
 *
 * @file[en] IGroup
 * @brief[en] Render group marker interface (three.interfaces standalone interface package)
 * @explain[en] Three.js Material.onBeforeRender callback parameter group is of Group type (objects package).
 * Cangjie materials package importing objects directly would cause circular dependency,
 * so "render group" is abstracted as a marker interface: implementors (objects package Group) implement this interface;
 * consumers (materials package Material callback) hold render group reference via interface only, not depending on implementation type.
 */
package three.scene.interfaces

/**
 * @brief[zh-cn] 渲染组标记接口：Material.onBeforeRender 回调的 group 参数类型
 *
 * @brief[en] Render group marker interface: group parameter type for Material.onBeforeRender callback
 */
public interface IGroup {
}
