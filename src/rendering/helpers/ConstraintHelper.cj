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
 * @file[zh-cn] Constraint 辅助对象
 * @brief[zh-cn] 物理约束/关节可视化辅助对象
 * @explain[zh-cn]
 * 可视化 PhysicsConstraint 的锚点、连接线与约束轴：
 * - 两个锚点标记（bodyA / bodyB）
 * - 锚点之间的连线
 * - 铰链/滑块/锥约束的约束轴箭头
 * 调用 update() 同步两端刚体最新状态。
 *
 * @note[zh-cn] Three.cj 使用左手坐标系、CCW 点序；本 helper 在左手系内绘制，
 * 与 RigidBody 绑定对象的世界变换保持一致。
 *
 * @file[en] Constraint Helper
 * @brief[en] Physics constraint/joint visualization helper object
 * @explain[en]
 * Visualizes the anchors, connecting line and constraint axes of a PhysicsConstraint:
 * - Two anchor markers (bodyA / bodyB)
 * - A line between the anchors
 * - Constraint axis arrows for hinge/slider/cone constraints
 * Call update() to sync the latest state of both rigid bodies.
 *
 * @note[en] Three.cj uses a left-handed coordinate system with CCW winding; this helper
 * draws within the left-handed system and stays consistent with the world transform of the
 * RigidBody-bound objects.
 */
package three.rendering.helpers

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.lights.*
import three.physics.constraint.*
import three.physics.body.RigidBody
import three.physics.interfaces.*
import three.physics.world.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 物理约束辅助对象
 * @explain[zh-cn]
 * 用锚点标记 + 连线 + 约束轴箭头可视化物理约束。
 *
 * @brief[en] Physics constraint helper object
 * @explain[en]
 * Visualizes a physics constraint with anchor markers, a connecting line and constraint axis arrows.
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Object3D]
public class ConstraintHelper <: Object3D {
    /// 所属物理世界
    @JsonIgnore
    public var world: PhysicsWorld

    /// 约束创建描述
    @JsonIgnore
    public var desc: PhysicsConstraintDesc

    /// 刚体 A
    @JsonIgnore
    public var bodyA: RigidBody

    /// 刚体 B
    @JsonIgnore
    public var bodyB: RigidBody

    /// 锚点 A 标记
    @JsonIgnore
    public var anchorA: PointLightHelper

    /// 锚点 B 标记
    @JsonIgnore
    public var anchorB: PointLightHelper

    /// 两锚点连线
    @JsonIgnore
    public var connection: Line

    /// 约束轴箭头
    @JsonIgnore
    public var axisArrow: ArrowHelper

    /// 辅助对象颜色
    @JsonIgnore
    public var color: UInt32

    /**
     * @brief[zh-cn] 构造 Constraint 辅助对象
     * @param[zh-cn] world 所属物理世界
     * desc 约束描述（用于获取锚点、轴、类型）
     * bodyA 刚体 A 便捷封装
     * bodyB 刚体 B 便捷封装
     * color 颜色，默认 0xffaa00
     *
     * @brief[en] Constructs a Constraint helper
     * @param[en] world The physics world the constraint belongs to
     * desc Constraint description (used to obtain anchors, axes and type)
     * bodyA Convenience wrapper for rigid body A
     * bodyB Convenience wrapper for rigid body B
     * color Color, default 0xffaa00
     */
    public init() {
        super()
        this.world = PhysicsWorld()
        this.desc = PhysicsConstraintDesc(constraintType: PhysicsConstraintType.Fixed)
        this.bodyA = RigidBody(world: this.world)
        this.bodyB = RigidBody(world: this.world)
        this.color = 0xffaa00
        this.matrixAutoUpdate = false
        this.anchorA = PointLightHelper()
        this.anchorB = PointLightHelper()
        this.connection = Line()
        this.axisArrow = ArrowHelper()
    }
    public init(world: PhysicsWorld, desc: PhysicsConstraintDesc,
                bodyA: RigidBody, bodyB: RigidBody,
                color!: UInt32 = 0xffaa00) {
        super()
        this.world = world
        this.desc = desc
        this.bodyA = bodyA
        this.bodyB = bodyB
        this.color = color
        this.matrixAutoUpdate = false

        this.anchorA = PointLightHelper(PointLight(color: Color(color), intensity: 1.0), sphereSize: 0.1)
        this.anchorA.material.color.copy(Color(color))
        this.children.add(this.anchorA)

        this.anchorB = PointLightHelper(PointLight(color: Color(color), intensity: 1.0), sphereSize: 0.1)
        this.anchorB.material.color.copy(Color(color))
        this.children.add(this.anchorB)

        let lineGeom = BufferGeometry()
        lineGeom.setAttribute("position", BufferAttribute(Array<Float64>(6, { _ => 0.0 }), 3))
        let lineMat = LineBasicMaterial()
        lineMat.color.copy(Color(color))
        this.connection = Line(geometry: lineGeom, material: lineMat)
        this.children.add(this.connection)

        this.axisArrow = ArrowHelper(dir: Vector3(0.0, 1.0, 0.0),
                                     origin: Vector3(0.0, 0.0, 0.0),
                                     length: 1.0, color: color)
        this.children.add(this.axisArrow)

        this.update()
    }

    /**
     * @brief[zh-cn] 同步两端刚体状态并更新可视化
     *
     * @brief[en] Syncs both rigid bodies' state and updates the visualization
     */
    public func update(): Unit {
        let posA = this.bodyA.getPosition()
        let rotA = this.bodyA.getRotation()
        let posB = this.bodyB.getPosition()
        let rotB = this.bodyB.getRotation()

        let worldA = _toWorldPoint(this.desc.anchor1, posA, rotA, this.desc.space)
        let worldB = _toWorldPoint(this.desc.anchor2, posB, rotB, this.desc.space)

        this.anchorA.position.copy(worldA)
        this.anchorB.position.copy(worldB)

        let positions = this.connection.geometry.getAttribute("position")
        match (positions) {
            case Some(attr) =>
                let arr = attr.array
                arr[0] = worldA.x; arr[1] = worldA.y; arr[2] = worldA.z
                arr[3] = worldB.x; arr[4] = worldB.y; arr[5] = worldB.z
                attr.version += 1
            case None => ()
        }
        this.connection.geometry.computeBoundingSphere()

        let axis = this.desc.axis1.clone().normalize()
        if (axis.length() > 0.0001) {
            match (this.desc.space) {
                case PhysicsConstraintSpace.LocalToBodyCOM => axis.applyQuaternion(rotA)
                case _ => ()
            }
            this.axisArrow.setDirection(axis)
            this.axisArrow.setLength(1.0, 0.2, 0.04)
            this.axisArrow.position.copy(worldA)
            this.axisArrow.visible = true
        } else {
            this.axisArrow.visible = false
        }

        this.matrixWorldNeedsUpdate = true
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Releases GPU resources
     */
    public func dispose(): Unit {
        this.anchorA.dispose()
        this.anchorB.dispose()
        this.connection.geometry.dispose()
        this.connection.material.dispose()
        this.axisArrow.dispose()
    }

    /// 将锚点转换到世界坐标
    private static func _toWorldPoint(local: Vector3, bodyPos: Vector3,
                                      bodyRot: Quaternion,
                                      space: PhysicsConstraintSpace): Vector3 {
        match (space) {
            case PhysicsConstraintSpace.WorldSpace => return local.clone()
            case PhysicsConstraintSpace.LocalToBodyCOM =>
                let p = local.clone().applyQuaternion(bodyRot).add(bodyPos)
                return p
        }
    }
}
