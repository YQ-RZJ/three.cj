/**
 * @file[zh-cn] 实例化缓冲几何体
 * @brief[zh-cn] 继承 BufferGeometry，支持实例化渲染
 * @explain[zh-cn] 
 * 在 bgfx 渲染后端中，实例化缓冲几何体对应 bgfx 的实例化渲染管线。
 * 对应 Three.js InstancedBufferGeometry.js。
 *
 * @file[en] Instanced Buffer Geometry
 * @brief[en] Extends BufferGeometry, supporting instanced rendering
 * @explain[en] 
 * In the bgfx rendering backend, instanced buffer geometry corresponds to bgfx's instanced rendering pipeline.
 * Corresponds to Three.js InstancedBufferGeometry.js.
 */
package three.rendering.geometry
import three.core.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * 实例化缓冲几何体类
 *
 * 实例化缓冲几何体是 {@link BufferGeometry} 的实例化版本，
 * 用于实例化渲染（instanced rendering），可以在一次绘制调用中渲染多个实例。
 *
 * 使用示例：
 * ```
 * let geom = InstancedBufferGeometry()
 * geom.instanceCount = 100  // 渲染 100 个实例
 * geom.setAttribute("position", BufferAttribute(positionData, 3))
 * geom.setAttribute("instanceMatrix", InstancedBufferAttribute(matrixData, 16))
 * ```
 */
@JsonAdapter[withSuperClass = BufferGeometry]
public class InstancedBufferGeometry <: BufferGeometry {
    /**
     * 实例数量
     * @default Infinity
     */
    public var instanceCount: Float64

    /**
     * 构造新的实例化缓冲几何体
     */
    public init() {
        super()
        this.kind = "InstancedBufferGeometry"
        this.instanceCount = Float64.Inf
    }

    /**
     * @param[zh-cn] source 源实例化缓冲几何体
     * @return[zh-cn] 当前实例的引用
     *
     * 从另一个实例化缓冲几何体复制数据到当前实例
     *
     * @param[en] source Source instanced buffer geometry
     * @return[en] Reference to the current instance
     *
     * Copy data from another instanced buffer geometry to the current instance
     */
    public func copy(source: InstancedBufferGeometry): InstancedBufferGeometry {
        super.copy(source)
        this.instanceCount = source.instanceCount
        return this
    }
}
