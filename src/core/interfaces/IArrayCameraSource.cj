/**
 * @file[zh-cn] IArrayCameraSource
 * @brief[zh-cn] 数组相机只读接口
 * @explain[zh-cn] three.js 的 FrustumArray.setFromArrayCamera 直接接收 ArrayCamera（cameras 包），遍历其子相机并用 projectionMatrix × matrixWorldInverse 逐个构造 Frustum。cj 侧若让 math 依赖 cameras 会形成循环（cameras 依赖 core，core 依赖 math），因此将子相机矩阵数据访问契约提取为本接口。实现方（ArrayCamera）负责暴露子相机数量与矩阵元素；使用方（FrustumArray，math 包）仅读取数据并自行组装 Matrix4。
 *
 * @file[en] IArrayCameraSource
 * @brief[en] Read-only interface for array camera
 * @explain[en] In three.js, FrustumArray.setFromArrayCamera directly receives ArrayCamera (cameras package) and iterates its sub-cameras to construct Frustums using projectionMatrix × matrixWorldInverse. In Cangjie, if math depends on cameras, it would form a cycle (cameras depends on core, core depends on math), so the sub-camera matrix data access contract is extracted into this interface. The implementer (ArrayCamera) exposes sub-camera count and matrix elements; the consumer (FrustumArray, math package) only reads data and assembles Matrix4. JS reference: FrustumArray.setFromArrayCamera cameras iteration.
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 数组相机只读接口：提供子相机投影/视图逆矩阵数据
 * @explain[zh-cn] 供 FrustumArray 从 ArrayCamera 获取子相机矩阵数据，避免 math 与 cameras 包的循环依赖
 *
 * @brief[en] Read-only interface for array camera: provides sub-camera projection/inverse view matrix data
 * @explain[en] Allows FrustumArray to obtain sub-camera matrix data from ArrayCamera, avoiding circular dependency between math and cameras packages
 */
public interface IArrayCameraSource {
    /**
     * @brief[zh-cn] 获取子相机数量
     * @return[zh-cn] 子相机数量
     *
     * @brief[en] Get the number of sub-cameras
     * @return[en] Number of sub-cameras
     */
    func getCameraCount(): Int64

    /**
     * @brief[zh-cn] 获取第 i 个子相机的投影矩阵元素（16 个，列主序）
     * @param[zh-cn] i 子相机索引
     * @return[zh-cn] 投影矩阵元素数组
     *
     * @brief[en] Get the projection matrix elements of the i-th sub-camera (16 elements, column-major)
     * @param[en] i Sub-camera index
     * @return[en] Projection matrix element array
     */
    func getCameraProjectionElements(i: Int64): Array<Float64>

    /**
     * @brief[zh-cn] 获取第 i 个子相机的视图矩阵逆元素（16 个，列主序）
     * @param[zh-cn] i 子相机索引
     * @return[zh-cn] 视图矩阵逆元素数组
     *
     * @brief[en] Get the inverse view matrix elements of the i-th sub-camera (16 elements, column-major)
     * @param[en] i Sub-camera index
     * @return[en] Inverse view matrix element array
     */
    func getCameraMatrixWorldInverseElements(i: Int64): Array<Float64>
}
