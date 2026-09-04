/**
 * @file[zh-cn] RigidBody 辅助对象
 * @brief[zh-cn] 物理刚体可视化辅助对象
 * @explain[zh-cn]
 * 可视化 RigidBody 的碰撞形状、质心、线速度与角速度，便于调试物理模拟：
 * - 碰撞形状线框（Box / Sphere / Capsule / Cylinder / Plane）
 * - 线速度箭头
 * - 角速度箭头（方向为旋转轴，长度表示角速度大小）
 * 调用 update() 同步刚体最新状态。
 *
 * @note[zh-cn] Three.cj 使用左手坐标系、CCW 点序；本 helper 在左手系内绘制，
 * 与 RigidBody 绑定对象的世界变换保持一致。
 */
package three.rendering.helpers

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.physics.body.RigidBody
import three.physics.interfaces.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 物理刚体辅助对象
 * @explain[zh-cn]
 * 用线框表示碰撞形状，用箭头表示线速度与角速度。
 */
public class RigidBodyHelper <: Object3D {
    /// 被可视化的物理刚体
    public var body: RigidBody

    /// 当前显示用的碰撞形状（构造时传入，默认 Box）
    public var shape: PhysicsShape

    /// 形状线框
    public var shapeLines: LineSegments

    /// 线速度箭头
    public var velocityArrow: ArrowHelper

    /// 角速度箭头
    public var angularVelocityArrow: ArrowHelper

    /// 辅助对象颜色
    public var color: UInt32

    /**
     * @brief[zh-cn] 构造 RigidBody 辅助对象
     * @param[zh-cn] body 要可视化的 RigidBody
     * shape 要显示的碰撞形状（默认 Box(1,1,1)）
     * color 线框颜色，默认 0x00ff00
     */
    public init(body: RigidBody, shape!: PhysicsShape = PhysicsShape.box(1.0, 1.0, 1.0),
                color!: UInt32 = 0x00ff00) {
        super()
        this.body = body
        this.shape = shape
        this.color = color
        this.kind = "RigidBodyHelper"
        this.matrixAutoUpdate = false

        let shapeGeom = _buildShapeGeometry(shape)
        let shapeMat = LineBasicMaterial()
        shapeMat.color.copy(Color(color))
        this.shapeLines = LineSegments(geometry: shapeGeom, material: shapeMat)
        this.children.add(this.shapeLines)

        this.velocityArrow = ArrowHelper(dir: Vector3(0.0, 1.0, 0.0),
                                         origin: Vector3(0.0, 0.0, 0.0),
                                         length: 1.0, color: 0x4444ff)
        this.children.add(this.velocityArrow)

        this.angularVelocityArrow = ArrowHelper(dir: Vector3(0.0, 1.0, 0.0),
                                                origin: Vector3(0.0, 0.0, 0.0),
                                                length: 1.0, color: 0xff44ff)
        this.children.add(this.angularVelocityArrow)

        this.update()
    }

    /**
     * @brief[zh-cn] 更换要显示的碰撞形状
     * @param[zh-cn] shape 新的碰撞形状
     * @return[zh-cn] 自身引用
     */
    public func setShape(shape: PhysicsShape): RigidBodyHelper {
        this.shape = shape
        this.shapeLines.geometry.dispose()
        this.shapeLines.geometry = _buildShapeGeometry(shape)
        return this
    }

    /**
     * @brief[zh-cn] 同步刚体状态并更新可视化
     */
    public func update(): Unit {
        let pos = this.body.getPosition()
        let rot = this.body.getRotation()

        this.position.copy(pos)
        this.quaternion.copy(rot)
        this.matrixWorldNeedsUpdate = true

        let linVel = this.body.getLinearVelocity()
        let llen = linVel.length()
        if (llen > 0.0001) {
            let dir = linVel.clone().normalize()
            let len = min(llen, 5.0)
            this.velocityArrow.setDirection(dir)
            this.velocityArrow.setLength(len, len * 0.2, len * 0.04)
            this.velocityArrow.visible = true
        } else {
            this.velocityArrow.visible = false
        }

        let angVel = this.body.getAngularVelocity()
        let alen = angVel.length()
        if (alen > 0.0001) {
            let dir = angVel.clone().normalize()
            let len = min(alen, 5.0)
            this.angularVelocityArrow.setDirection(dir)
            this.angularVelocityArrow.setLength(len, len * 0.2, len * 0.04)
            this.angularVelocityArrow.visible = true
        } else {
            this.angularVelocityArrow.visible = false
        }
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     */
    public func dispose(): Unit {
        this.shapeLines.geometry.dispose()
        this.shapeLines.material.dispose()
        this.velocityArrow.dispose()
        this.angularVelocityArrow.dispose()
    }

    /// 根据 PhysicsShape 构建对应的线框几何
    private static func _buildShapeGeometry(shape: PhysicsShape): BufferGeometry {
        match (shape.shapeType) {
            case PhysicsShapeType.Box => return _buildBoxWireframe(shape)
            case PhysicsShapeType.Sphere => return _buildSphereWireframe(shape)
            case PhysicsShapeType.Capsule => return _buildCapsuleWireframe(shape)
            case PhysicsShapeType.Cylinder => return _buildCylinderWireframe(shape)
            case PhysicsShapeType.Plane => return _buildPlaneWireframe(shape)
            case _ => return _buildBoxWireframe(shape)
        }
    }

    private static func _buildBoxWireframe(shape: PhysicsShape): BufferGeometry {
        let he = shape.halfExtent
        let positions = Array<Float64>(24, { i =>
            [ he.x,  he.y,  he.z, -he.x,  he.y,  he.z,
             -he.x, -he.y,  he.z,  he.x, -he.y,  he.z,
              he.x,  he.y, -he.z, -he.x,  he.y, -he.z,
             -he.x, -he.y, -he.z,  he.x, -he.y, -he.z][i]
        })
        let indices = Array<Float64>(24, { i => Float64([0,1,1,2,2,3,3,0,4,5,5,6,6,7,7,4,0,4,1,5,2,6,3,7][i]) })
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions, 3))
        geometry.setIndex(BufferAttribute(indices, 1))
        return geometry
    }

    private static func _buildSphereWireframe(shape: PhysicsShape): BufferGeometry {
        let r = shape.radius
        let positions = ArrayList<Float64>()
        let segments: Int64 = 16
        for (ring in 0..3) {
            let y = (Float64(ring) - 1.0) * r * 0.7
            let rr = sqrt(max(0.0, r * r - y * y))
            for (i in 0..segments) {
                let a1 = Float64(i) / Float64(segments) * PI * 2.0
                let a2 = Float64(i + 1) / Float64(segments) * PI * 2.0
                positions.add(cos(a1) * rr); positions.add(y); positions.add(sin(a1) * rr)
                positions.add(cos(a2) * rr); positions.add(y); positions.add(sin(a2) * rr)
            }
        }
        // 经线
        for (i in 0..8) {
            let a = Float64(i) / 8.0 * PI * 2.0
            positions.add(cos(a) * r); positions.add(0.0); positions.add(sin(a) * r)
            positions.add(-cos(a) * r); positions.add(0.0); positions.add(-sin(a) * r)
        }
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions.toArray(), 3))
        return geometry
    }

    private static func _buildCapsuleWireframe(shape: PhysicsShape): BufferGeometry {
        let hh = shape.halfHeight
        let r = shape.radius
        let positions = ArrayList<Float64>()
        let segments: Int64 = 16
        // 圆柱段上下圆 + 侧边
        for (y in [-hh, hh]) {
            for (i in 0..segments) {
                let a1 = Float64(i) / Float64(segments) * PI * 2.0
                let a2 = Float64(i + 1) / Float64(segments) * PI * 2.0
                positions.add(cos(a1) * r); positions.add(y); positions.add(sin(a1) * r)
                positions.add(cos(a2) * r); positions.add(y); positions.add(sin(a2) * r)
            }
        }
        for (i in 0..4) {
            let a = Float64(i) / 4.0 * PI * 2.0
            let x = cos(a) * r
            let z = sin(a) * r
            positions.add(x); positions.add(-hh); positions.add(z)
            positions.add(x); positions.add(hh); positions.add(z)
        }
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions.toArray(), 3))
        return geometry
    }

    private static func _buildCylinderWireframe(shape: PhysicsShape): BufferGeometry {
        let hh = shape.halfHeight
        let r = shape.radius
        let positions = ArrayList<Float64>()
        let segments: Int64 = 16
        for (y in [-hh, hh]) {
            for (i in 0..segments) {
                let a1 = Float64(i) / Float64(segments) * PI * 2.0
                let a2 = Float64(i + 1) / Float64(segments) * PI * 2.0
                positions.add(cos(a1) * r); positions.add(y); positions.add(sin(a1) * r)
                positions.add(cos(a2) * r); positions.add(y); positions.add(sin(a2) * r)
            }
        }
        for (i in 0..4) {
            let a = Float64(i) / 4.0 * PI * 2.0
            let x = cos(a) * r
            let z = sin(a) * r
            positions.add(x); positions.add(-hh); positions.add(z)
            positions.add(x); positions.add(hh); positions.add(z)
        }
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions.toArray(), 3))
        return geometry
    }

    private static func _buildPlaneWireframe(shape: PhysicsShape): BufferGeometry {
        let s = 5.0
        let positions = Array<Float64>(24, { i =>
            [ s, 0.0,  s, -s, 0.0,  s,
             -s, 0.0, -s,  s, 0.0, -s,
              s, 0.0,  s, -s, 0.0,  s,
             -s, 0.0, -s,  s, 0.0, -s][i]
        })
        let indices = Array<Float64>(24, { i => Float64([0,1,1,2,2,3,3,0,4,6,6,7,7,5,5,4,0,4,1,5,2,6,3,7][i]) })
        let geometry = BufferGeometry()
        geometry.setAttribute("position", BufferAttribute(positions, 3))
        geometry.setIndex(BufferAttribute(indices, 1))
        return geometry
    }
}
