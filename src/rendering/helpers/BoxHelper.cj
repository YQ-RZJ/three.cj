/**
 * @file[zh-cn] 包围盒辅助对象
 * @brief[zh-cn] 包围盒辅助对象，用于可视化 Object3D 的轴对齐包围盒
 * @explain[zh-cn] 
 * 对应 Three.js helpers/BoxHelper.js。以线框绘制对象及其子对象的包围盒，
 * 调用 update() 可刷新包围盒。
 *
 * @file[en] Box Helper
 * @brief[en] Box helper for visualizing the axis-aligned bounding box of an Object3D
 * @explain[en] 
 * Corresponds to Three.js helpers/BoxHelper.js. Draws the bounding box of an object
 * and its children as wireframe, call update() to refresh the bounding box.
 */
package three.rendering.helpers
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] 包围盒辅助对象，用于可视化 Object3D 的轴对齐包围盒
 * @explain[zh-cn] 
 * 以线框绘制对象及其子对象的包围盒，调用 update() 可刷新包围盒。
 *
 * @brief[en] Box helper for visualizing the axis-aligned bounding box of an Object3D
 * @explain[en] 
 * Draws the bounding box of an object and its children as wireframe,
 * call update() to refresh the bounding box.
 */
public class BoxHelper <: LineSegments {
    /**
     * @brief[zh-cn] 請监视的对象
     *
     * @brief[en] The object being monitored
     */
    public var object: Object3D

    /**
     * @brief[zh-cn] 构造包围盒辅助对象
     * @param[zh-cn] object 要监视的对象
     * color 线框颜色，默认黄色 0xffff00
     *
     * @brief[en] Construct a box helper
     * @param[en] object The object to monitor
     * color Wireframe color, default yellow 0xffff00
     */
    public init(object: Object3D, color!: UInt32 = 0xffff00) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.kind = "BoxHelper"
        this.object = object
        let indices = Array<Float64>(24, { i => Float64([0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 4, 1, 5, 2, 6, 3, 7][i]) })
        let positions = Array<Float64>(8 * 3, { _ => 0.0 })
        this.geometry.setIndex(BufferAttribute(indices, 1))
        this.geometry.setAttribute("position", BufferAttribute(positions, 3))
        this.matrixAutoUpdate = false
        this.update()
    }

    /**
     * @brief[zh-cn] 更新包围盒顶点数据
     *
     * @brief[en] Update bounding box vertex data
     */
    public func update(): Unit {
        
        // 此前用 `box.set(box.min, box.max)`（空盒自设）导致 box 恒为空 → 顶点永不更新 → BoxHelper 不可见
        let box = Box3()
        this.expandByObject(box, this.object)
        if (box.isEmpty()) { return }
        let min = box.min; let max = box.max
        let position = this.geometry.getAttribute("position")
        match (position) {
            case Some(attr) =>
                let array = attr.array
                array[0] = max.x; array[1] = max.y; array[2] = max.z
                array[3] = min.x; array[4] = max.y; array[5] = max.z
                array[6] = min.x; array[7] = min.y; array[8] = max.z
                array[9] = max.x; array[10] = min.y; array[11] = max.z
                array[12] = max.x; array[13] = max.y; array[14] = min.z
                array[15] = min.x; array[16] = max.y; array[17] = min.z
                array[18] = min.x; array[19] = min.y; array[20] = min.z
                array[21] = max.x; array[22] = min.y; array[23] = min.z
                attr.version += 1
            case None => ()
        }
        this.geometry.computeBoundingSphere()
    }

    /**
     * @brief[zh-cn] 递归收集 object 及其子对象几何体的世界包围盒
     * @param[zh-cn] box 累加目标的包围盒
     * object 当前遍历的对象
     *
     * @brief[en] Recursively collect world bounding box of object and its children
     * @param[en] box Accumulating target bounding box
     * object Current traversed object
     */
    private func expandByObject(box: Box3, object: Object3D): Unit {
        object.updateWorldMatrix(false, false, false)
        // Object3D 无 geometry 字段，按子类取几何体（Mesh/Line/Points 具有 geometry）
        var geomOpt: Option<BufferGeometry> = None
        match (object) {
            case m: Mesh => geomOpt = Some(m.geometry)
            case l: Line => geomOpt = Some(l.geometry)
            case _ => ()
        }
        match (geomOpt) {
            case Some(geom) =>
                geom.computeBoundingBox()
                match (geom.boundingBox) {
                    case Some(bb) =>
                        
                        let worldBox = Box3().copy(bb).applyMatrix4(object.matrixWorld)
                        box.union(worldBox)
                    case None => ()
                }
            case None => ()
        }
        for (i in 0..object.children.size) {
            this.expandByObject(box, object.children[i])
        }
    }

    /**
     * @brief[zh-cn] 更换监视的对象并刷新包围盒
     * @param[zh-cn] object 新的监视对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Change the monitored object and refresh the bounding box
     * @param[en] object New monitored object
     * @return[en] Self reference
     */
    public func setFromObject(object: Object3D): BoxHelper {
        this.object = object
        this.update()
        return this
    }

    /**
     * @brief[zh-cn] 复制另一个包围盒辅助对象
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Copy from another box helper
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Self reference
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: BoxHelper => this.object = s.object
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.geometry.dispose()
        this.material.dispose()
    }
}
