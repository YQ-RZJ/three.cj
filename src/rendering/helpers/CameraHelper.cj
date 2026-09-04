/**
 * @file[zh-cn] 相机辅助对象
 * @brief[zh-cn] 相机视锥体辅助对象，用于可视化相机的视锥体
 * @explain[zh-cn] 
 * 对应 Three.js helpers/CameraHelper.js。显示相机的近平面、远平面以及视锥体轮廓线，
 * 帮助调试相机参数。支持自定义视锥、锥体、上方向、目标和十字线的颜色。
 *
 * @file[en] Camera Helper
 * @brief[en] Camera frustum helper for visualizing camera frustums
 * @explain[en] 
 * Corresponds to Three.js helpers/CameraHelper.js. Displays camera near/far planes and
 * frustum outline lines for debugging camera parameters. Supports custom colors for
 * frustum, cone, up, target and cross lines.
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
import three.rendering.cameras.*
import three.utils.constants.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 相机视锥体辅助对象，用于可视化相机的视锥体
 * @explain[zh-cn] 
 * 显示相机的近平面、远平面以及视锥体轮廓线，帮助调试相机参数。
 *
 * @brief[en] Camera frustum helper for visualizing camera frustums
 * @explain[en] 
 * Displays camera near/far planes and frustum outline lines for debugging camera parameters.
 */
public class CameraHelper <: LineSegments {
    /**
     * @brief[zh-cn] 被可视化的相机
     *
     * @brief[en] The camera being visualized
     */
    public var camera: Camera

    /**
     * @brief[zh-cn] 顶点映射表：点名称到几何体中的顶点索引数组
     *
     * @brief[en] Vertex mapping: point name to array of geometry vertex indices
     */
    public var pointMap: HashMap<String, ArrayList<Int64>>

    // 内部临时相机投影矩阵逆，避免修改原相机
    private static let _vector: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 构造相机辅助对象
     * @param[zh-cn] camera 要可视化的相机
     *
     * @brief[en] Construct a camera helper
     * @param[en] camera The camera to visualize
     */
    public init(camera: Camera) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.camera = camera
        this.kind = "CameraHelper"
        this.matrix = camera.matrixWorld
        this.matrixAutoUpdate = false
        this.pointMap = HashMap<String, ArrayList<Int64>>()
        
        if (camera is PerspectiveCamera) {
            let pcOpt = camera as PerspectiveCamera
            if (let Some(pc) <- pcOpt) { pc.updateProjectionMatrix() }
        } else if (camera is OrthographicCamera) {
            let ocOpt = camera as OrthographicCamera
            if (let Some(oc) <- ocOpt) { oc.updateProjectionMatrix() }
        }
        this.buildLines()
        
        this.material.vertexColors = true
        this.update()
        // 对照 JS 构造末尾的 setColors 默认色：视锥橙/锥红/上蓝/目标白/十字深灰
        this.setColors(
            Color(0xffaa00), // frustum
            Color(0xff0000), // cone
            Color(0x00aaff), // up
            Color(0xffffff), // target
            Color(0x333333)  // cross
        )
    }

    /**
     * @brief[zh-cn] 设置辅助对象各分段的颜色
     * @param[zh-cn] frustum 视锥线颜色
     * cone 锥体线颜色
     * up 上方向线颜色
     * target 目标线颜色
     * cross 十字线颜色
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set colors for each section of the helper
     * @param[en] frustum Frustum line color
     * cone Cone line color
     * up Up direction line color
     * target Target line color
     * cross Cross line color
     * @return[en] Self reference
     */
    public func setColors(frustum: Color, cone: Color, up: Color, target: Color, cross: Color): CameraHelper {
        let geometry = this.geometry
        let colorAttribute = geometry.getAttribute("color")
        match (colorAttribute) {
            case Some(attr) =>
                // 前 24 个顶点（near4+far4+sides4 共 12 条线 × 2）为视锥
                for (i in 0..24) {
                    attr.setXYZ(i, frustum.r, frustum.g, frustum.b)
                }
                // cone: 顶点 24-31（p,n1..n4 四条线）
                for (i in 24..32) {
                    attr.setXYZ(i, cone.r, cone.g, cone.b)
                }
                // up: 顶点 32-37（u1,u2,u3 三角）
                for (i in 32..38) {
                    attr.setXYZ(i, up.r, up.g, up.b)
                }
                // target: 顶点 38-39（c,t 线）与 40-41（p,c 线，JS 实际用 cross 色）
                attr.setXYZ(38, target.r, target.g, target.b)
                attr.setXYZ(39, target.r, target.g, target.b)
                attr.setXYZ(40, cross.r, cross.g, cross.b)
                attr.setXYZ(41, cross.r, cross.g, cross.b)
                // cross: 顶点 42-49（cn1..cn4, cf1..cf4）
                for (i in 42..50) {
                    attr.setXYZ(i, cross.r, cross.g, cross.b)
                }
                attr.version += 1
            case None => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 构造线段几何
     * @explain[zh-cn] 
     * 按 JS CameraHelper constructor 中 14 组 addLine 调用，
     * 生成 vertices/colors 数组并填充 pointMap。
     *
     * @brief[en] Build line geometry
     * @explain[en] 
     * Generates vertices/colors arrays and fills pointMap according to
     * the 14 addLine calls in the JS CameraHelper constructor.
     */
    private func buildLines(): Unit {
        let geometry = this.geometry
        let vertices = ArrayList<Float64>()
        let colors = ArrayList<Float64>()

        func addPoint(id: String): Unit {
            vertices.add(0.0); vertices.add(0.0); vertices.add(0.0)
            colors.add(0.0); colors.add(0.0); colors.add(0.0)
            match (this.pointMap.get(id)) {
                case Some(arr) => arr.add((vertices.size / 3) - 1)
                case None =>
                    let arr = ArrayList<Int64>()
                    arr.add((vertices.size / 3) - 1)
                    this.pointMap.add(id, arr)
            }
        }

        func addLine(a: String, b: String): Unit {
            addPoint(a)
            addPoint(b)
        }

        // near
        addLine("n1", "n2"); addLine("n2", "n4"); addLine("n4", "n3"); addLine("n3", "n1")
        // far
        addLine("f1", "f2"); addLine("f2", "f4"); addLine("f4", "f3"); addLine("f3", "f1")
        // sides
        addLine("n1", "f1"); addLine("n2", "f2"); addLine("n3", "f3"); addLine("n4", "f4")
        // cone
        addLine("p", "n1"); addLine("p", "n2"); addLine("p", "n3"); addLine("p", "n4")
        // up
        addLine("u1", "u2"); addLine("u2", "u3"); addLine("u3", "u1")
        // target
        addLine("c", "t"); addLine("p", "c")
        // cross
        addLine("cn1", "cn2"); addLine("cn3", "cn4")
        addLine("cf1", "cf2"); addLine("cf3", "cf4")

        geometry.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        geometry.setAttribute("color", BufferAttribute(colors.toArray(), 3))
    }

    /**
     * @brief[zh-cn] 设置点位置，将 (x,y,z) 反投影到世界空间
     * @param[zh-cn] point 点名称
     * x NDC x 坐标
     * y NDC y 坐标
     * z NDC z 坐标
     *
     * @brief[en] Set point position by unprojecting (x,y,z) to world space
     * @param[en] point Point name
     * x NDC x coordinate
     * y NDC y coordinate
     * z NDC z coordinate
     */
    private func setPoint(point: String, x: Float64, y: Float64, z: Float64): Unit {
        CameraHelper._vector.set(x, y, z).unproject(this.camera.projectionMatrixInverse)
        match (this.pointMap.get(point)) {
            case Some(points) =>
                match (this.geometry.getAttribute("position")) {
                    case Some(position) =>
                        for (i in 0..points.size) {
                            position.setXYZ(points[i], CameraHelper._vector.x, CameraHelper._vector.y, CameraHelper._vector.z)
                        }
                    case None => ()
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 更新相机视锥体线框
     * @explain[zh-cn] 
     * 根据相机投影矩阵逆 unproject 8 个视锥顶点 + 14 条连线。
     *
     * @brief[en] Update camera frustum wireframe
     * @explain[en] 
     * Unprojects 8 frustum vertices and 14 connecting lines using the inverse projection matrix.
     */
    public func update(): Unit {
        let w = 1.0
        let h = 1.0
        var nearZ: Float64 = 0.0
        var farZ: Float64 = 0.0
        if (this.camera.reversedDepth) {
            nearZ = 1.0
            farZ = 0.0
        } else if (this.camera.coordinateSystem == WebGPUCoordinateSystem) {
            nearZ = 0.0
            farZ = 1.0
        } else {
            nearZ = -1.0
            farZ = 1.0
        }
        // center / target
        setPoint("c", 0.0, 0.0, nearZ)
        setPoint("t", 0.0, 0.0, farZ)
        // near
        setPoint("n1", -w, -h, nearZ)
        setPoint("n2", w, -h, nearZ)
        setPoint("n3", -w, h, nearZ)
        setPoint("n4", w, h, nearZ)
        // far
        setPoint("f1", -w, -h, farZ)
        setPoint("f2", w, -h, farZ)
        setPoint("f3", -w, h, farZ)
        setPoint("f4", w, h, farZ)
        // up
        setPoint("u1", w * 0.7, h * 1.1, nearZ)
        setPoint("u2", -w * 0.7, h * 1.1, nearZ)
        setPoint("u3", 0.0, h * 2.0, nearZ)
        // cross (far)
        setPoint("cf1", -w, 0.0, farZ)
        setPoint("cf2", w, 0.0, farZ)
        setPoint("cf3", 0.0, -h, farZ)
        setPoint("cf4", 0.0, h, farZ)
        // cross (near)
        setPoint("cn1", -w, 0.0, nearZ)
        setPoint("cn2", w, 0.0, nearZ)
        setPoint("cn3", 0.0, -h, nearZ)
        setPoint("cn4", 0.0, h, nearZ)
        // 标记 position 属性需更新
        match (this.geometry.getAttribute("position")) {
            case Some(position) => position.markNeedsUpdate()
            case None => ()
        }
        this.geometry.computeBoundingSphere()
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
