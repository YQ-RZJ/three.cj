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
 * @file[zh-cn] IMesh
 * @brief[zh-cn] 网格标记接口（three.interfaces 独立接口包）
 * @explain[zh-cn] Three.js 的 MaterialOverrideScope.pushOverride 参数是 Mesh 类型（objects 包）。
 * 仓颉侧 utils 包若直接 import objects 会形成循环依赖，
 * 因此将"网格"抽象为本标记接口：实现方（objects 包 Mesh）实现本接口；
 * 使用方（utils 包 MaterialOverrideScope）仅以接口持有网格引用，不依赖实现类型。
 *
 * @file[en] IMesh
 * @brief[en] Mesh marker interface (three.interfaces standalone interface package)
 * @explain[en] Three.js MaterialOverrideScope.pushOverride parameter is of Mesh type (objects package).
 * Cangjie utils package importing objects directly would cause circular dependency,
 * so "mesh" is abstracted as this marker interface: implementors (objects package Mesh) implement this interface;
 * consumers (utils package MaterialOverrideScope) hold mesh reference via interface only, not depending on implementation type.
 */
package three.scene.interfaces

/**
 * @brief[zh-cn] 网格标记接口：MaterialOverrideScope.pushOverride 的 mesh 参数类型
 *
 * @brief[en] Mesh marker interface: mesh parameter type for MaterialOverrideScope.pushOverride
 */
public interface IMesh {
}
