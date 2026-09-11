/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
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
