/**
 * @file[zh-cn] PhysicsBinding Physics 模块对象绑定便捷 API
 * @brief[zh-cn] 提供 Object3D 与物理刚体之间的绑定便捷 API（类内静态方法）
 * @explain[zh-cn] 提供绑定便捷 API（全部收拢为类内静态方法，避免顶层散函数）：
 * 支持 PhysicsBinding.bind 通用绑定，以及从 Box/Sphere/Capsule/Cylinder
 * 几何体自动派生形状的 meshBox/meshSphere/meshCapsule/meshCylinder，
 * 还有静态地面 ground 与解除绑定 unbind。
 * 设计要点：
 * - PhysicsWorld 已在 createBody + bindObject 内完成"创建刚体+绑定 Mesh"的桥接，
 * 本类仅是便捷封装，减少用户模板代码。
 * - 物理形状由调用方显式传入（与渲染几何体形状对齐，避免自动推断误差）。
 * - autoSync=true 时 world.update 每帧把刚体 transform 写回 Mesh.position/quaternion，
 * 渲染线程只需在 renderer.render 前不再覆盖 Mesh.position 即可。
 *
 * @file[en] PhysicsBinding Convenient object-binding API for the Physics module
 * @brief[en] Provides convenient bindings between Object3D and physics rigid bodies (static methods)
 * @explain[en] Provides convenient binding APIs collected as static methods on the class
 * (avoids scattered top-level functions). Includes the generic PhysicsBinding.bind,
 * shape-deriving helpers meshBox/meshSphere/meshCapsule/meshCylinder built from
 * Box/Sphere/Capsule/Cylinder geometries, the static ground helper, and unbind.
 * Design notes:
 * - PhysicsWorld already bridges "create body + bind mesh" through createBody and
 * bindObject; this class is only a convenience wrapper reducing user boilerplate.
 * - The physics shape is explicitly passed by the caller (aligned with the render
 * geometry to avoid inference errors).
 * - With autoSync=true, world.update writes the body transform back to
 * Mesh.position/quaternion every frame; the render thread only needs to stop
 * overwriting Mesh.position before renderer.render.
 */
package three.physics.binding

import three.core.math.*
import three.physics.interfaces.*
import three.physics.world.*
import three.physics.body.*
import three.scene.objects.*
import three.scene.entity.*
import three.rendering.geometry.*
import std.collection.*

// =============================================================================
// 绑定便捷 API（类内静态方法）
// =============================================================================

/**
 * @brief[zh-cn] Object3D 与物理刚体的绑定便捷 API（静态方法集合，无实例状态）
 * @explain[zh-cn] 典型用法（先摆 mesh，再加物理）：
 * let mesh = Mesh(BoxGeometry(1.0, 1.0, 1.0), mat)
 * mesh.position.set(0.0, 10.0, 0.0)
 * scene.add(mesh)
 * let body = PhysicsBinding.bind(world, mesh,
 * PhysicsShape.box(1.0, 1.0, 1.0), PhysicsMotionType.Dynamic)
 * // world.update(dt) 后 mesh.position 自动跟随物理下落
 *
 * @brief[en] Convenient binding API between Object3D and physics rigid bodies (static methods, no instance state)
 * @explain[en] Typical usage (place the mesh first, then add physics):
 * let mesh = Mesh(BoxGeometry(1.0, 1.0, 1.0), mat)
 * mesh.position.set(0.0, 10.0, 0.0)
 * scene.add(mesh)
 * let body = PhysicsBinding.bind(world, mesh,
 * PhysicsShape.box(1.0, 1.0, 1.0), PhysicsMotionType.Dynamic)
 * // After world.update(dt), mesh.position follows the physics fall automatically
 */
public class PhysicsBinding {
    /**
     * @brief[zh-cn] 创建物理刚体并绑定到渲染对象
     * @param[zh-cn] world 物理世界实例
     * object3d 需要绑定物理的渲染对象
     * shape 物理形状
     * motionType 运动类型（Dynamic/Kinematic/Static），默认 Dynamic
     * friction 摩擦系数，默认 0.2
     * restitution 恢复系数，默认 0.0
     * syncToObj 是否每帧把刚体 transform 同步回对象，默认 true
     * isSensor 是否作为传感器（穿透不产生碰撞），默认 false
     * @return[zh-cn] 返回创建的 RigidBody 实例（用于运行时控制）
     *
     * @brief[en] Creates a physics rigid body and binds it to a render object
     * @param[en] world The physics world instance
     * object3d The render object to bind physics to
     * shape The physics shape
     * motionType Motion type (Dynamic/Kinematic/Static), defaults to Dynamic
     * friction Friction coefficient, defaults to 0.2
     * restitution Restitution coefficient, defaults to 0.0
     * syncToObj Whether to sync the body transform back to the object every frame, defaults to true
     * isSensor Whether to act as a sensor (pass-through, no collision), defaults to false
     * @return[en] Returns the created RigidBody instance (for runtime control)
     */
    public static func bind(world: PhysicsWorld, object3d: Object3D,
                            shape: PhysicsShape,
                            motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                            friction!: Float64 = 0.2,
                            restitution!: Float64 = 0.0,
                            syncToObj!: Bool = true,
                            isSensor!: Bool = false): RigidBody {
        let body = RigidBody(world: world, shape: shape)
        // 设置运动类型（setDynamic/setKinematic/setStatic）
        match (motionType) {
            case PhysicsMotionType.Dynamic => body.setDynamic()
            case PhysicsMotionType.Kinematic => body.setKinematic()
            case PhysicsMotionType.Static => body.setStatic()
        }
        body.setFriction(friction)
        body.setRestitution(restitution)
        if (isSensor) {
            body.setSensor(true)
        }
        return body.attach(object3d, syncToObj: syncToObj)
    }

    /**
     * @brief[zh-cn] 为 Mesh 添加物理（从 BoxGeometry 自动派生 Box 形状）
     * @param[zh-cn] world 物理世界实例
     * mesh 目标 Mesh（将从其几何体派生形状）
     * motionType 运动类型，默认 Dynamic
     * friction 摩擦系数，默认 0.2
     * restitution 恢复系数，默认 0.0
     * @return[zh-cn] 返回创建的 RigidBody 实例
     *
     * @brief[en] Adds physics to a Mesh (derives a Box shape from BoxGeometry automatically)
     * @param[en] world The physics world instance
     * mesh Target Mesh (its geometry is used to derive the shape)
     * motionType Motion type, defaults to Dynamic
     * friction Friction coefficient, defaults to 0.2
     * restitution Restitution coefficient, defaults to 0.0
     * @return[en] Returns the created RigidBody instance
     */
    public static func meshBox(world: PhysicsWorld, mesh: Mesh,
                               motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                               friction!: Float64 = 0.2,
                               restitution!: Float64 = 0.0): RigidBody {
        // 尝试从 BoxGeometry 读取尺寸；否则用 boundingBox 推断
        var w: Float64 = 1.0; var h: Float64 = 1.0; var d: Float64 = 1.0
        match (mesh.geometry) {
            case bg: BoxGeometry =>
                w = _anyToFloat64(bg.parameters.get("width"), 1.0)
                h = _anyToFloat64(bg.parameters.get("height"), 1.0)
                d = _anyToFloat64(bg.parameters.get("depth"), 1.0)
            case _ =>
                // 兜底：用 boundingBox 尺寸
                match (mesh.geometry.boundingBox) {
                    case Some(box) =>
                        w = box.max.x - box.min.x
                        h = box.max.y - box.min.y
                        d = box.max.z - box.min.z
                    case None => ()
                }
        }
        let shape = PhysicsShape.box(w, h, d)
        return PhysicsBinding.bind(world, mesh, shape,
            motionType: motionType, friction: friction, restitution: restitution)
    }

    /**
     * @brief[zh-cn] 为 Mesh 添加物理（从 SphereGeometry 自动派生 Sphere 形状）
     * @param[zh-cn] world 物理世界实例
     * mesh 目标 Mesh（将从其几何体派生形状）
     * motionType 运动类型，默认 Dynamic
     * friction 摩擦系数，默认 0.2
     * restitution 恢复系数，默认 0.0
     * @return[zh-cn] 返回创建的 RigidBody 实例
     *
     * @brief[en] Adds physics to a Mesh (derives a Sphere shape from SphereGeometry automatically)
     * @param[en] world The physics world instance
     * mesh Target Mesh (its geometry is used to derive the shape)
     * motionType Motion type, defaults to Dynamic
     * friction Friction coefficient, defaults to 0.2
     * restitution Restitution coefficient, defaults to 0.0
     * @return[en] Returns the created RigidBody instance
     */
    public static func meshSphere(world: PhysicsWorld, mesh: Mesh,
                                  motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                                  friction!: Float64 = 0.2,
                                  restitution!: Float64 = 0.0): RigidBody {
        var r: Float64 = 0.5
        match (mesh.geometry) {
            case sg: SphereGeometry =>
                r = _anyToFloat64(sg.parameters.get("radius"), 0.5)
            case _ =>
                // 兜底：用 boundingSphere 半径
                match (mesh.geometry.boundingSphere) {
                    case Some(sph) => r = sph.radius
                    case None => ()
                }
        }
        let shape = PhysicsShape.sphere(r)
        return PhysicsBinding.bind(world, mesh, shape,
            motionType: motionType, friction: friction, restitution: restitution)
    }

    /**
     * @brief[zh-cn] 为 Mesh 添加物理（从 CapsuleGeometry 自动派生 Capsule 形状）
     * @param[zh-cn] world 物理世界实例
     * mesh 目标 Mesh（将从其几何体派生形状）
     * motionType 运动类型，默认 Dynamic
     * friction 摩擦系数，默认 0.2
     * restitution 恢复系数，默认 0.0
     * @return[zh-cn] 返回创建的 RigidBody 实例
     *
     * @brief[en] Adds physics to a Mesh (derives a Capsule shape from CapsuleGeometry automatically)
     * @param[en] world The physics world instance
     * mesh Target Mesh (its geometry is used to derive the shape)
     * motionType Motion type, defaults to Dynamic
     * friction Friction coefficient, defaults to 0.2
     * restitution Restitution coefficient, defaults to 0.0
     * @return[en] Returns the created RigidBody instance
     *
     * @note[zh-cn] CapsuleGeometry(radius, length) 的 length 含半球帽总高，
     * halfHeight = (length - 2 * radius) / 2。
     * @note[en] CapsuleGeometry(radius, length): length includes the total height of
     * both hemispherical caps; halfHeight = (length - 2 * radius) / 2.
     */
    public static func meshCapsule(world: PhysicsWorld, mesh: Mesh,
                                   motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                                   friction!: Float64 = 0.2,
                                   restitution!: Float64 = 0.0): RigidBody {
        var r: Float64 = 0.5; var length: Float64 = 1.0
        match (mesh.geometry) {
            case cg: CapsuleGeometry =>
                r = _anyToFloat64(cg.parameters.get("radius"), 0.5)
                length = _anyToFloat64(cg.parameters.get("length"), 1.0)
            case _ => ()
        }
        let halfH = (length - 2.0 * r) / 2.0
        let shape = PhysicsShape.capsule(if (halfH > 0.0) { halfH } else { 0.0 }, r)
        return PhysicsBinding.bind(world, mesh, shape,
            motionType: motionType, friction: friction, restitution: restitution)
    }

    /**
     * @brief[zh-cn] 为 Mesh 添加物理（从 CylinderGeometry 自动派生 Cylinder 形状）
     * @param[zh-cn] world 物理世界实例
     * mesh 目标 Mesh（将从其几何体派生形状）
     * motionType 运动类型，默认 Dynamic
     * friction 摩擦系数，默认 0.2
     * restitution 恢复系数，默认 0.0
     * @return[zh-cn] 返回创建的 RigidBody 实例
     *
     * @brief[en] Adds physics to a Mesh (derives a Cylinder shape from CylinderGeometry automatically)
     * @param[en] world The physics world instance
     * mesh Target Mesh (its geometry is used to derive the shape)
     * motionType Motion type, defaults to Dynamic
     * friction Friction coefficient, defaults to 0.2
     * restitution Restitution coefficient, defaults to 0.0
     * @return[en] Returns the created RigidBody instance
     *
     * @note[zh-cn] CylinderGeometry(radiusTop, radiusBottom, height) 的 height 是总高，
     * halfHeight = height / 2。
     * @note[en] For CylinderGeometry(radiusTop, radiusBottom, height), height is the
     * full height; halfHeight = height / 2.
     */
    public static func meshCylinder(world: PhysicsWorld, mesh: Mesh,
                                    motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                                    friction!: Float64 = 0.2,
                                    restitution!: Float64 = 0.0): RigidBody {
        var r: Float64 = 0.5; var height: Float64 = 1.0
        match (mesh.geometry) {
            case cg: CylinderGeometry =>
                r = _anyToFloat64(cg.parameters.get("radiusTop"), 0.5)
                height = _anyToFloat64(cg.parameters.get("height"), 1.0)
            case _ => ()
        }
        let shape = PhysicsShape.cylinder(height / 2.0, r)
        return PhysicsBinding.bind(world, mesh, shape,
            motionType: motionType, friction: friction, restitution: restitution)
    }

    /**
     * @brief[zh-cn] 创建静态地面（大平面）并绑定
     * @param[zh-cn] world 物理世界实例
     * mesh 用作地面外观的 Mesh
     * yPosition 地面 y 坐标，默认 0
     * @return[zh-cn] 返回创建的静态 RigidBody 实例
     *
     * @brief[en] Creates and binds a static ground (large plane)
     * @param[en] world The physics world instance
     * mesh The Mesh used as the ground's visual representation
     * yPosition The ground y coordinate, defaults to 0
     * @return[en] Returns the created static RigidBody instance
     *
     * @note[zh-cn] Plane 形状在后端用大盒子近似。
     * @note[en] The plane shape is approximated by a large box in the backend.
     */
    public static func ground(world: PhysicsWorld, mesh: Mesh,
                              yPosition!: Float64 = 0.0): RigidBody {
        mesh.position.set(0.0, yPosition, 0.0)
        // Plane 形状在后端用大盒子近似
        let shape = PhysicsShape.plane()
        return PhysicsBinding.bind(world, mesh, shape,
            motionType: PhysicsMotionType.Static,
            friction: 0.5, restitution: 0.2, syncToObj: false)
    }

    /**
     * @brief[zh-cn] 解除 Mesh 的物理绑定（不销毁刚体）
     * @param[zh-cn] world 物理世界实例
     * object3d 需要解除绑定的渲染对象
     *
     * @brief[en] Removes the physics binding of a Mesh (does not destroy the body)
     * @param[en] world The physics world instance
     * object3d The render object to unbind
     */
    public static func unbind(world: PhysicsWorld, object3d: Object3D): Unit {
        world.unbindObject(object3d)
    }
}

// =============================================================================
// 内部辅助：Any → Float64（parameters HashMap 值类型为 Any）
// =============================================================================

/// 从 parameters HashMap 中读取数值，Any 可能是 Float64/Int64/Float32 等数值类型。
/// 常见情况：BoxGeometry.parameters["width"] 是 Float64；CapsuleGeometry 的 radius 是 Float64。
internal func _anyToFloat64(opt: Option<Any>, default: Float64): Float64 {
    match (opt) {
        case Some(v) =>
            match (v) {
                case f: Float64 => return f
                case f: Float32 => return Float64(f)
                case i: Int64 => return Float64(i)
                case i: Int32 => return Float64(i)
                case i: Int16 => return Float64(i)
                case _ => return default
            }
        case None => return default
    }
}
