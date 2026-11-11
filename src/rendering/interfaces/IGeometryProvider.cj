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
 * @file[zh-cn] IGeometryProvider 几何体能力接口
 * @brief[zh-cn] 几何体能力接口，解耦 scene.objects 与 rendering.geometry 的包级循环依赖
 * @explain[zh-cn] Object3D（scene.objects）的裁剪/包围盒计算需要访问几何体
 * （computeBoundingSphere/computeBoundingBox/boundingSphere/boundingBox/position 属性），
 * 而 BufferGeometry（rendering.geometry）的 lookAt 辅助又需引用 Object3D。
 * 拆分后两个子包互相引用形成循环，故抽象本接口：
 * - 实现方（rendering.geometry 的 BufferGeometry 等）实现本接口；
 * - 使用方（scene.objects 的 Object3D 及其子类）以接口引用几何体，不依赖 geometry 包。
 * 接口返回类型刻意使用基础包类型（core.math 的 Sphere/Box3、core.interfaces 的 AttributeReader），
 * 保证 geometry.interfaces 自身不依赖 geometry 包实现。
 *
 * @file[en] IGeometryProvider Geometry capability interface
 * @brief[en] Geometry capability interface, decoupling circular dependency between scene.objects and rendering.geometry
 * @explain[en] Object3D (scene.objects) needs access to geometry for clipping/bounding box computation
 * (computeBoundingSphere/computeBoundingBox/boundingSphere/boundingBox/position properties),
 * while BufferGeometry (rendering.geometry) lookAt helpers need Object3D.
 * This creates a circular dependency, so this interface abstracts the geometry capability:
 * - Implementor (BufferGeometry in rendering.geometry) implements this interface;
 * - Consumer (Object3D in scene.objects) references geometry via this interface without depending on the geometry package.
 * Return types intentionally use base package types (core.math Sphere/Box3, core.interfaces AttributeReader)
 * to ensure the interface itself doesn't depend on the geometry package implementation.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

import three.core.math.Box3
import three.core.math.Sphere
import three.core.interfaces.AttributeReader

/**
 * @brief[zh-cn] 几何体能力接口：供裁剪/包围盒/精确遍历访问几何体数据
 *
 * @brief[en] Geometry capability interface: for clipping/bounding box/precise traversal to access geometry data
 */
public interface IGeometryProvider {
    /**
     * @brief[zh-cn] 计算包围球（实现方更新自身 boundingSphere）
     *
     * @brief[en] Computes bounding sphere (implementor updates its own boundingSphere)
     */
    func computeBoundingSphere(): Unit

    /**
     * @brief[zh-cn] 获取包围球（None 表示无几何体数据）
     *
     * @brief[en] Gets the bounding sphere (None if no geometry data)
     */
    func getBoundingSphere(): Option<Sphere>

    /**
     * @brief[zh-cn] 计算包围盒（实现方更新自身 boundingBox）
     *
     * @brief[en] Computes bounding box (implementor updates its own boundingBox)
     */
    func computeBoundingBox(): Unit

    /**
     * @brief[zh-cn] 获取包围盒（None 表示无几何体数据）
     *
     * @brief[en] Gets the bounding box (None if no geometry data)
     */
    func getBoundingBox(): Option<Box3>

    /**
     * @brief[zh-cn] 按名称获取顶点属性（AttributeReader 只读接口，position/normal/uv 等）
     *
     * @brief[en] Gets vertex attribute by name (AttributeReader read-only interface, position/normal/uv etc.)
     */
    func getAttributeReader(name: String): Option<AttributeReader>
}
