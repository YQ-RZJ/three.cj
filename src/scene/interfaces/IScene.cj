/**
 * @file[zh-cn] IScene
 * @brief[zh-cn] 场景标记接口（three.interfaces 独立接口包）
 * @explain[zh-cn] Three.js 的 CubeCamera.update(renderer, scene) / PMREMGenerator.fromScene(scene)
 * 参数是 Scene 类型（scenes 包）。仓颉侧 cameras/extras 包若直接 import scenes 会形成循环依赖，
 * 因此将"场景"抽象为本标记接口：实现方（scenes 包 Scene）实现本接口；
 * 使用方（cameras 包 CubeCamera、extras 包 PMREMGenerator）仅以接口持有场景引用。
 *
 * @file[en] IScene
 * @brief[en] Scene marker interface (three.interfaces standalone interface package)
 * @explain[en] Three.js CubeCamera.update(renderer, scene) / PMREMGenerator.fromScene(scene)
 * parameter is of Scene type (scenes package). Cangjie cameras/extras package importing scenes directly would cause circular dependency,
 * so "scene" is abstracted as this marker interface: implementors (scenes package Scene) implement this interface;
 * consumers (cameras package CubeCamera, extras package PMREMGenerator) hold scene reference via interface only.
 */
package three.scene.interfaces

/**
 * @brief[zh-cn] 场景标记接口：CubeCamera.update / PMREMGenerator.fromScene 的 scene 参数类型
 *
 * @brief[en] Scene marker interface: scene parameter type for CubeCamera.update / PMREMGenerator.fromScene
 */
public interface IScene {
}
