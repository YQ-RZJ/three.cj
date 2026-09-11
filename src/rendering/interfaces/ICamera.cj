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
 * @file[zh-cn] ICamera 相机标记接口
 * @brief[zh-cn] 相机标记接口，用于解耦 cameras 包与 interfaces 包的循环依赖
 * @explain[zh-cn] Three.js 的 IRenderer.render(scene, camera) 中 camera 是 Camera 类型（cameras 包）。
 * interfaces 接口包保持零依赖（仅 std），若直接引用 cameras 包具体类型会破坏该约束，
 * 因此将"相机"抽象为标记接口：
 * - 实现方（cameras 包 Camera）实现本接口；
 * - 使用方（interfaces 包 IRenderer.render 参数）以接口持有相机引用。
 *
 * @file[en] ICamera Camera marker interface
 * @brief[en] Camera marker interface, used to decouple circular dependency between cameras and interfaces packages
 * @explain[en] In Three.js, IRenderer.render(scene, camera) expects a Camera type (cameras package).
 * The interfaces package maintains zero dependency (only std); directly importing cameras package
 * concrete types would break this constraint, so "camera" is abstracted as a marker interface:
 * - Implementor (Camera in cameras package) implements this interface;
 * - Consumer (IRenderer.render parameter in interfaces package) holds camera reference by interface.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

/**
 * @brief[zh-cn] 相机标记接口：IRenderer.render 的 camera 参数类型
 *
 * @brief[en] Camera marker interface: camera parameter type for IRenderer.render
 */
public interface ICamera {
}
