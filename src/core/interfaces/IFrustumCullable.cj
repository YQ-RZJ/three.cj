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
 * @file[zh-cn] IFrustumCullable
 * @brief[zh-cn] 视锥体裁剪只读接口
 * @explain[zh-cn] 本包只存放接口声明，不依赖 three 内任何其他包；其他包（math/core 等）单向依赖本包，从而避免包间循环依赖。three.js 的 Frustum.intersectsObject / intersectsSprite 直接接收 Object3D / Sprite（core/objects 包）。cj 侧若让 math 依赖 core 会形成循环（core 依赖 math），因此将"世界包围球"访问契约提取为本接口。实现方（Object3D / Sprite）负责根据自身几何体计算世界包围球；使用方（Frustum，math 包）仅读取返回的数据，不依赖实现类型。
 *
 * @file[en] IFrustumCullable
 * @brief[en] Read-only interface for frustum culling
 * @explain[en] This package only contains interface declarations with no dependency on any other three packages; other packages (math/core etc.) depend on this package unidirectionally, avoiding circular dependencies. In three.js, Frustum.intersectsObject / intersectsSprite directly receives Object3D / Sprite (core/objects package). In Cangjie, if math depends on core it would form a cycle (core depends on math), so the "world bounding sphere" access contract is extracted into this interface. The implementer (Object3D / Sprite) computes the world bounding sphere based on its geometry; the consumer (Frustum, math package) only reads the returned data without depending on implementation types. JS reference: Frustum.intersectsObject / intersectsSprite internal bounding sphere computation.
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 视锥体裁剪只读接口：提供对象的世界空间包围球
 * @explain[zh-cn] 返回 Option：Some([cx, cy, cz, radius]) 表示可裁剪；None 表示无法计算包围球（无几何体等），使用方应按"可见"处理（不裁剪）
 *
 * @brief[en] Read-only interface for frustum culling: provides object's world-space bounding sphere
 * @explain[en] Returns Option: Some([cx, cy, cz, radius]) means cullable; None means unable to compute bounding sphere (no geometry etc.), consumer should treat as "visible" (no culling)
 */
public interface IFrustumCullable {
    /**
     * @brief[zh-cn] 计算对象的世界空间包围球
     * @return[zh-cn] Some([cx, cy, cz, radius]) 或 None（无几何体）
     *
     * @brief[en] Compute the object's world-space bounding sphere
     * @return[en] Some([cx, cy, cz, radius]) or None (no geometry)
     */
    func getWorldBoundingSphere(): Option<Array<Float64>>
}
