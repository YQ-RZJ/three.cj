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
 * @file[zh-cn] IMaterial
 * @brief[zh-cn] 材质标记接口
 * @explain[zh-cn] three.js 的 Object3D.customDepthMaterial/customDistanceMaterial 是 Material 类型（materials 包）。cj 侧 core 包若直接 import materials 会形成循环（materials 依赖 core），因此将"材质"抽象为本标记接口。实现方（materials 包 Material）实现本接口；使用方（core 包 Object3D）仅以接口持有材质引用，不依赖实现类型。
 *
 * @file[en] IMaterial
 * @brief[en] Material marker interface
 * @explain[en] In three.js, Object3D.customDepthMaterial/customDistanceMaterial is of type Material (materials package). In Cangjie, if core package directly imports materials, it would form a cycle (materials depends on core), so "material" is abstracted as this marker interface. The implementer (materials package Material) implements this interface; the consumer (core package Object3D) holds material references via the interface without depending on implementation types. JS reference: Material (aggregate type for custom depth/distance material fields).
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 材质标记接口：Object3D.customDepthMaterial/customDistanceMaterial 的元素类型
 * @explain[zh-cn] 消除 core 与 materials 包的循环依赖，让 Object3D 仅以接口持有材质引用
 *
 * @brief[en] Material marker interface: element type of Object3D.customDepthMaterial/customDistanceMaterial
 * @explain[en] Eliminates circular dependency between core and materials packages, allowing Object3D to hold material references via interface only
 */
public interface IMaterial {
}
