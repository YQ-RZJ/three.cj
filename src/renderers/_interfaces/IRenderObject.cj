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
 * @file[zh-cn] IRenderObject 渲染对象接口（自 three.renderers.common 迁入本接口包）
 * @brief[zh-cn] 即时命令模型 draw 的入参契约：提供矩阵/几何体/材质/对象 ID 等查询方法
 * @explain[zh-cn] 按 C9 约定收纳于 renderers/interfaces（protected 包），经实现包重导出为
 * three.renderers.common.IRenderObject。实现方为 RenderObject（render list 渲染项）。
 * 原接口中的 getNodeChain（返回 ArrayList<Object3D>，零调用方）已按 C1 移除——
 * 该签名引用 scene 包具体类型，是迁入本包的循环依赖来源。
 *
 * @file[en] IRenderObject  Render object interface (moved from three.renderers.common into this interface package)
 * @brief[en] The input contract of the immediate-command-model draw: matrix/geometry/material/object ID query methods
 * @explain[en] Collected into renderers/interfaces per C9 (protected package), re-exported by the implementation package as three.renderers.common.IRenderObject. Implemented by RenderObject (render-list item). The original getNodeChain (ArrayList<Object3>, zero callers) was removed per C1 — its scene-package parameter type was the cycle source for this migration.
 */
protected package three.renderers._interfaces

/**
 * @brief[zh-cn] 渲染对象接口，提供矩阵/几何体/材质/对象 ID 等查询方法
 * @explain[zh-cn] 即时命令模型 draw 的入参契约：draw(renderObject) 从中取矩阵/
 * 几何体/材质信息。实现方为 RenderObject（render list 渲染项）。
 *
 * @brief[en] Render object interface, providing matrix/geometry/material/object ID query methods
 * @explain[en] The input contract of the immediate-command-model draw: draw(renderObject)
 * reads matrix/geometry/material info from it. Implemented by RenderObject (render-list item).
 */
public interface IRenderObject {
    /**
     * @brief[zh-cn] 返回 world matrix（16 个 Float64 列主序）
     *
     * @brief[en] Returns world matrix (16 Float64 column-major)
     */
    func getMatrix(): Array<Float64>
    /**
     * @brief[zh-cn] 返回几何体 ID
     *
     * @brief[en] Returns geometry ID
     */
    func getGeometryId(): Int64
    /**
     * @brief[zh-cn] 返回材质 ID
     *
     * @brief[en] Returns material ID
     */
    func getMaterialId(): Int64
    /**
     * @brief[zh-cn] 返回对象 ID
     *
     * @brief[en] Returns object ID
     */
    func getObjectId(): Int64
    /**
     * @brief[zh-cn] 返回渲染组索引
     *
     * @brief[en] Returns render group order
     */
    func getGroupOrder(): Float64
    /**
     * @brief[zh-cn] 返回渲染顺序
     *
     * @brief[en] Returns render order
     */
    func getRenderOrder(): Float64
}
