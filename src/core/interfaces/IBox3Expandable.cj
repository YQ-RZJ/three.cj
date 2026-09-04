/**
 * @file[zh-cn] IBox3Expandable
 * @brief[zh-cn] 包围盒展开只读接口
 * @explain[zh-cn] three.js 的 Box3.setFromObject / expandByObject 直接接收 Object3D（core 包），遍历对象及其子对象的几何体包围盒并 union。cj 侧若让 math 依赖 core 会形成循环（core 依赖 math），因此将展开所需访问契约提取为本接口。实现方（Object3D 及子类）负责暴露世界矩阵更新、世界包围盒与子对象；使用方（Box3，math 包）仅读取数据并累加，不依赖实现类型。
 *
 * @file[en] IBox3Expandable
 * @brief[en] Read-only interface for bounding box expansion
 * @explain[en] In three.js, Box3.setFromObject / expandByObject directly receives Object3D (core package) and traverses its and children's geometry bounding boxes with union. In Cangjie, if math depends on core it would form a cycle (core depends on math), so the expansion access contract is extracted into this interface. The implementer (Object3D and subclasses) exposes world matrix updates, world bounding boxes, and children; the consumer (Box3, math package) only reads data and accumulates without depending on implementation types. JS reference: Box3.expandByObject (conservative path: geometry boundingBox × matrixWorld).
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 包围盒展开只读接口：供 Box3.setFromObject / expandByObject 遍历使用
 * @explain[zh-cn] 供 Box3 遍历对象及其子对象的几何体数据，避免 math 与 core 包的循环依赖
 *
 * @brief[en] Read-only interface for bounding box expansion: used by Box3.setFromObject / expandByObject for traversal
 * @explain[en] Allows Box3 to traverse object and its children's geometry data, avoiding circular dependency between math and core packages
 */
public interface IBox3Expandable {
    /**
     * @brief[zh-cn] 更新对象的世界矩阵
     * @param[zh-cn] updateParents 是否更新父级
     * updateChildren 是否更新子级
     * force 是否强制更新
     *
     * @brief[en] Update the object's world matrix
     * @param[en] updateParents Whether to update parents
     * updateChildren Whether to update children
     * force Whether to force update
     */
    func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit

    /**
     * @brief[zh-cn] 计算对象自身（不含子对象）的世界空间包围盒
     * @return[zh-cn] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) 或 None（无几何体）
     *
     * @brief[en] Compute the object's own (excluding children) world-space bounding box
     * @return[en] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) or None (no geometry)
     */
    func getWorldBoundingBox(): Option<(Array<Float64>, Array<Float64>)>

    /**
     * @brief[zh-cn] 获取子对象数量
     * @return[zh-cn] 子对象数量
     *
     * @brief[en] Get the number of child objects
     * @return[en] Number of child objects
     */
    func getChildCount(): Int64

    /**
     * @brief[zh-cn] 获取第 i 个子对象
     * @param[zh-cn] i 子对象索引
     * @return[zh-cn] 子对象（同样实现 IBox3Expandable）
     *
     * @brief[en] Get the i-th child object
     * @param[en] i Child object index
     * @return[en] Child object (also implements IBox3Expandable)
     */
    func getChildAt(i: Int64): IBox3Expandable

    /**
     * @brief[zh-cn] 获取精确模式逐顶点遍历的顶点数
     * @explain[zh-cn] 返回 position 属性顶点数；无几何体/无 position 属性/InstancedMesh 返回 0
     * @return[zh-cn] 顶点数（0 表示不支持精确遍历，调用方应回退保守路径）
     *
     * @brief[en] Get the vertex count for precise per-vertex traversal
     * @explain[en] Returns the position attribute vertex count; returns 0 for no geometry/no position attribute/InstancedMesh
     * @return[en] Vertex count (0 means precise traversal not supported, caller should fall back to conservative path)
     */
    func getPreciseVertexCount(): Int64

    /**
     * @brief[zh-cn] 获取第 i 个顶点的世界空间位置
     * @param[zh-cn] i 顶点索引
     * @return[zh-cn] 世界空间坐标 [x, y, z]
     *
     * @brief[en] Get the world-space position of the i-th vertex
     * @param[en] i Vertex index
     * @return[en] World-space coordinates [x, y, z]
     */
    func getPreciseVertexPosition(i: Int64): Array<Float64>
}
