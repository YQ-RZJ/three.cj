/**
 * @file[zh-cn] IPhysicsBackend 可插拔物理后端抽象接口
 * @brief[zh-cn] 定义后端无关的物理抽象类型与后端接口
 * @explain[zh-cn] 设计目标：three.physics 上层（PhysicsWorld/RigidBody/Binding）只依赖本接口与
 * PhysicsShape/PhysicsBodyDesc/PhysicsQueryResult 等抽象类型，不直接依赖任何具体
 * 物理库。替换底层物理计算库（JoltPhysics/PhysX/Bullet/…）只需新写一个实现本接口
 * 的 backend 包，PhysicsWorld.setBackend 切换即可。
 * 命名约定：后端实现以 XxxBackend 命名；所有抽象类型冠 Physics 前缀以与
 * 渲染侧 Geometry/Shape 区分。后端实例由具体 backend 包构造，由 PhysicsWorld 持有。
 * 线程约定：本接口所有方法均在 PhysicsWorld 的专用物理线程内被调用（由
 * PhysicsWorld._execPhysics 序列化），实现内部无需额外加锁；但实现持有的底层
 * 句柄在物理线程外不可触碰。
 * 能力覆盖：Collision/RigidBody/Character/Constraint 所需能力均由本接口方法集表达。
 *
 * @file[en] IPhysicsBackend Pluggable physics backend abstraction interface
 * @brief[en] Defines backend-agnostic physics abstractions and the backend interface
 * @explain[en] Design goal: the upper three.physics layers (PhysicsWorld/RigidBody/Binding)
 * depend only on this interface and the abstract types such as PhysicsShape,
 * PhysicsBodyDesc and the query results, never on any concrete physics library.
 * Swapping the underlying engine (JoltPhysics/PhysX/Bullet/…) only requires a new
 * backend package implementing this interface and a PhysicsWorld.setBackend call.
 * Naming: backend implementations are named XxxBackend; all abstract types carry
 * the Physics prefix to distinguish them from rendering-side Geometry/Shape.
 * Backend instances are constructed by the concrete backend package and owned by
 * PhysicsWorld.
 * Threading: every method here is invoked on PhysicsWorld's dedicated physics
 * thread (serialized via PhysicsWorld._execPhysics), so implementations need no
 * internal locking; however their underlying handles must not be touched outside
 * that thread.
 * Capabilities: everything needed by Collision/RigidBody/Character/Constraint is
 * expressed by the method set of this interface.
 */
package three.physics.interfaces

import three.core.math.*
import std.collection.*

// =============================================================================
// 枚举：刚体运动类型 / 激活策略 / 物理层
// =============================================================================

/**
 * @brief[zh-cn] 刚体运动类型（后端无关抽象，对应 JPH_MotionType）
 * @explain[zh-cn] - Static   : 完全不动，不受力不移动（地面/墙壁）
 * - Kinematic : 由用户控制位置/速度，不参与动力学求解
 * - Dynamic   : 受重力/碰撞/力驱动，标准物理模拟对象
 *
 * @brief[en] Rigid-body motion type (backend-agnostic abstraction, corresponds to JPH_MotionType)
 * @explain[en] - Static   : completely static, not affected by forces (grounds/walls)
 * - Kinematic : position/velocity controlled by the user, excluded from dynamics
 * - Dynamic   : driven by gravity/collisions/forces, standard simulated object
 */
public enum PhysicsMotionType {
    /**
     * @brief[zh-cn] 完全不动（地面/墙壁等静态物体）
     *
     * @brief[en] Completely static (static objects such as grounds/walls)
     */
    | Static
    /**
     * @brief[zh-cn] 由用户控制位置/速度（不参与动力学求解）
     *
     * @brief[en] Position/velocity controlled by the user (excluded from dynamics)
     */
    | Kinematic
    /**
     * @brief[zh-cn] 受重力/碰撞/力驱动（标准物理模拟对象）
     *
     * @brief[en] Driven by gravity/collisions/forces (standard simulated object)
     */
    | Dynamic
}

/**
 * @brief[zh-cn] 激活策略（添加刚体到世界时是否立即唤醒）
 * @explain[zh-cn] - Activate    : 立即激活（开始模拟）
 * - DontActivate: 不激活（保持休眠，适合预摆放大量静止物体）
 *
 * @brief[en] Activation strategy (whether the body is woken immediately when added to the world)
 * @explain[en] - Activate    : activate immediately (start simulating)
 * - DontActivate: do not activate (stay asleep; good for pre-placing many static objects)
 */
public enum PhysicsActivation {
    /**
     * @brief[zh-cn] 立即激活（开始模拟）
     *
     * @brief[en] Activate immediately (start simulating)
     */
    | Activate
    /**
     * @brief[zh-cn] 不激活（保持休眠）
     *
     * @brief[en] Do not activate (stay asleep)
     */
    | DontActivate
}

/**
 * @brief[zh-cn] 物理层（碰撞分组）
 * @explain[zh-cn] NonMoving/Moving 两层模型是默认配置；后端实现可扩展更多层。
 * 层间碰撞过滤由后端按 layerSelf/layerOther 决定。
 *
 * @brief[en] Physics layer (collision grouping)
 * @explain[en] The two-layer NonMoving/Moving model is the default configuration; a backend
 * implementation may add more layers. Inter-layer collision filtering is decided by
 * the backend from layerSelf/layerOther.
 */
public enum PhysicsLayer {
    /**
     * @brief[zh-cn] 静态/运动学物体（地面、墙壁、平台），0
     *
     * @brief[en] Static/kinematic objects (grounds, walls, platforms), 0
     */
    | NonMoving
    /**
     * @brief[zh-cn] 动态物体（球、箱子、角色胶囊），1
     *
     * @brief[en] Dynamic objects (balls, boxes, character capsules), 1
     */
    | Moving
}

// =============================================================================
// 抽象类型：形状描述 / 刚体描述 / 查询结果
// =============================================================================

/**
 * @brief[zh-cn] 形状类型枚举（不带参数，参数由 PhysicsShape 结构体持有）
 * @explain[zh-cn] 覆盖 Box/Sphere/Capsule/Cylinder/Plane 基本形状，
 * 并扩展 Mesh（三角网格）/ConvexHull（凸包）/Compound（复合）以完整呈现
 * Jolt 底层形状能力（JPH_MeshShape / JPH_ConvexHullShape / JPH_CompoundShape）。
 *
 * @brief[en] Shape-type enum (no parameters; parameters are held by the PhysicsShape struct)
 * @explain[en] Covers the basic Box/Sphere/Capsule/Cylinder/Plane shapes and extends them
 * with Mesh (triangle mesh) / ConvexHull / Compound to fully expose the underlying
 * Jolt shape capabilities (JPH_MeshShape / JPH_ConvexHullShape / JPH_CompoundShape).
 */
public enum PhysicsShapeType {
    /**
     * @brief[zh-cn] 盒体
     *
     * @brief[en] Box
     */
    | Box
    /**
     * @brief[zh-cn] 球体
     *
     * @brief[en] Sphere
     */
    | Sphere
    /**
     * @brief[zh-cn] 胶囊体
     *
     * @brief[en] Capsule
     */
    | Capsule
    /**
     * @brief[zh-cn] 圆柱体
     *
     * @brief[en] Cylinder
     */
    | Cylinder
    /**
     * @brief[zh-cn] 无限平面（后端近似）
     *
     * @brief[en] Infinite plane (approximated by the backend)
     */
    | Plane
    /**
     * @brief[zh-cn] 三角网格形状（顶点 + 索引三角形，JPH_MeshShape）
     *
     * @brief[en] Triangle-mesh shape (vertices + indexed triangles, JPH_MeshShape)
     */
    | Mesh
    /**
     * @brief[zh-cn] 凸包形状（顶点列表，JPH_ConvexHullShape）
     *
     * @brief[en] Convex-hull shape (vertex list, JPH_ConvexHullShape)
     */
    | ConvexHull
    /**
     * @brief[zh-cn] 复合形状（多个子形状 + 相对变换，JPH_CompoundShape）
     *
     * @brief[en] Compound shape (multiple sub-shapes + relative transforms, JPH_CompoundShape)
     */
    | Compound
}

/**
 * @brief[zh-cn] 复合形状子部件（Compound 用）
 * @explain[zh-cn] 每个子部件 = 一个子形状 + 相对父级质心的位置/旋转。
 *
 * @brief[en] Sub-part of a compound shape (used by Compound)
 * @explain[en] Each sub-part is one sub-shape plus its position/rotation relative to the parent's center of mass.
 */
public struct PhysicsCompoundPart {
    /**
     * @brief[zh-cn] 子形状
     *
     * @brief[en] The sub-shape
     */
    public let shape: PhysicsShape
    /**
     * @brief[zh-cn] 相对父级质心的位置
     *
     * @brief[en] Position relative to the parent's center of mass
     */
    public let position: Vector3
    /**
     * @brief[zh-cn] 相对父级质心的旋转
     *
     * @brief[en] Rotation relative to the parent's center of mass
     */
    public let rotation: Quaternion

    /**
     * @brief[zh-cn] 创建复合子部件
     * @param[zh-cn] shape 子形状
     * position 相对父级质心的位置（默认原点）
     * rotation 相对父级质心的旋转（默认单位四元数）
     *
     * @brief[en] Creates a compound sub-part
     * @param[en] shape The sub-shape
     * position Position relative to the parent's center of mass (origin by default)
     * rotation Rotation relative to the parent's center of mass (identity by default)
     */
    public init(shape!: PhysicsShape, position!: Vector3 = Vector3(),
                rotation!: Quaternion = Quaternion()) {
        this.shape = shape
        this.position = position
        this.rotation = rotation
    }
}

/**
 * @brief[zh-cn] 物理形状描述（后端无关）
 * @explain[zh-cn] 后端据此创建底层碰撞形状。覆盖 Box/Sphere/Capsule/Cylinder/Plane
 * 基本形状及 Mesh/ConvexHull/Compound。
 * 注意：所有尺寸均使用世界单位（米），与渲染侧 Geometry 参数一致，
 * 但 PhysicsShape 描述的是碰撞体尺寸（通常略小于可视网格以避免视觉穿插）。
 * 字段含义随 shapeType 不同而变化：
 * - Box      : halfExtent = 半边长（xyz 各分量），实际尺寸 = 2×半边长
 * - Sphere   : radius     = 半径
 * - Capsule  : halfHeight = 圆柱段半高（不含两个半球帽），radius = 半径
 * - Cylinder : halfHeight = 半高，radius = 半径
 * - Plane    : 字段忽略；后端用大盒子近似无限平面
 * - Mesh     : vertices = 顶点数组，triangles = 三角形索引（每 3 个一组）
 * - ConvexHull: vertices = 凸包顶点列表（自动求凸包）
 * - Compound : parts = 子形状部件数组（含相对变换）
 *
 * @brief[en] Physics shape description (backend-agnostic)
 * @explain[en] The backend creates the underlying collision shape from this description.
 * Covers the basic Box/Sphere/Capsule/Cylinder/Plane shapes plus Mesh/ConvexHull/Compound.
 * Note: all dimensions are in world units (meters), matching the rendering-side
 * Geometry parameters, but PhysicsShape describes the collider size (usually
 * slightly smaller than the visual mesh to avoid z-fighting).
 * Field meaning depends on shapeType:
 * - Box      : halfExtent = half extents (per-axis); full size = 2 x half extent
 * - Sphere   : radius     = radius
 * - Capsule  : halfHeight = half height of the cylindrical segment (excluding the
 * two hemisphere caps), radius = radius
 * - Cylinder : halfHeight = half height, radius = radius
 * - Plane    : fields ignored; the backend approximates an infinite plane with a big box
 * - Mesh     : vertices = vertex array, triangles = triangle indices (triplets)
 * - ConvexHull: vertices = convex-hull vertex list (convex hull computed automatically)
 * - Compound : parts = array of sub-shape parts (with relative transforms)
 */
public struct PhysicsShape {
    /**
     * @brief[zh-cn] 形状类型
     *
     * @brief[en] The shape type
     */
    public let shapeType: PhysicsShapeType
    /**
     * @brief[zh-cn] 半边长（Box）/ 半径（Sphere/Capsule/Cylinder）
     *
     * @brief[en] Half extents (Box) / radius (Sphere/Capsule/Cylinder)
     */
    public let halfExtent: Vector3
    /**
     * @brief[zh-cn] 胶囊/圆柱段半高
     *
     * @brief[en] Half height of the capsule/cylinder segment
     */
    public let halfHeight: Float64
    /**
     * @brief[zh-cn] 球/胶囊/圆柱半径
     *
     * @brief[en] Sphere/capsule/cylinder radius
     */
    public let radius: Float64
    /**
     * @brief[zh-cn] 顶点数组（Mesh/ConvexHull 用）
     *
     * @brief[en] Vertex array (used by Mesh/ConvexHull)
     */
    public let vertices: Array<Vector3>
    /**
     * @brief[zh-cn] 三角形索引（Mesh 用，每 3 个一组，顶点索引）
     *
     * @brief[en] Triangle indices (used by Mesh, triplets of vertex indices)
     */
    public let triangles: Array<UInt32>
    /**
     * @brief[zh-cn] 复合形状子部件（Compound 用）
     *
     * @brief[en] Compound sub-parts (used by Compound)
     */
    public let parts: Array<PhysicsCompoundPart>

    /**
     * @brief[zh-cn] 创建形状描述（按 shapeType 填写相应字段，其余保持默认）
     * @param[zh-cn] shapeType 形状类型
     * halfExtent 半边长（Box），默认零向量
     * halfHeight 胶囊/圆柱段半高，默认 0
     * radius 球/胶囊/圆柱半径，默认 0
     * vertices 顶点数组（Mesh/ConvexHull 用），默认空
     * triangles 三角形索引（Mesh 用），默认空
     * parts 复合子部件（Compound 用），默认空
     *
     * @brief[en] Creates a shape description (fill in the fields relevant to shapeType, leave the rest default)
     * @param[en] shapeType The shape type
     * halfExtent Half extents (Box); zero vector by default
     * halfHeight Capsule/cylinder segment half height; 0 by default
     * radius Sphere/capsule/cylinder radius; 0 by default
     * vertices Vertex array (Mesh/ConvexHull); empty by default
     * triangles Triangle indices (Mesh); empty by default
     * parts Compound sub-parts (Compound); empty by default
     */
    public init(shapeType!: PhysicsShapeType,
                halfExtent!: Vector3 = Vector3(),
                halfHeight!: Float64 = 0.0,
                radius!: Float64 = 0.0,
                vertices!: Array<Vector3> = [],
                triangles!: Array<UInt32> = [],
                parts!: Array<PhysicsCompoundPart> = []) {
        this.shapeType = shapeType
        this.halfExtent = halfExtent
        this.halfHeight = halfHeight
        this.radius = radius
        this.vertices = vertices
        this.triangles = triangles
        this.parts = parts
    }

    // =========================================================================
    // 静态工厂方法（与 three.rendering.geometry 参数对齐，一键生成碰撞体）
    // 用法：PhysicsShape.box(1.0, 1.0, 1.0) / PhysicsShape.sphere(0.5) / ...
    // =========================================================================

    /**
     * @brief[zh-cn] 创建 Box 形状（全尺寸 width/height/depth，内部转半边长）
     * @param[zh-cn] width 宽度
     * height 高度
     * depth 深度
     * @return[zh-cn] Box 形状描述
     *
     * @brief[en] Creates a Box shape (full width/height/depth, converted to half extents internally)
     * @param[en] width The width
     * height The height
     * depth The depth
     * @return[en] The Box shape description
     */
    public static func box(width: Float64, height: Float64, depth: Float64): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.Box,
            halfExtent: Vector3(width / 2.0, height / 2.0, depth / 2.0))
    }

    /**
     * @brief[zh-cn] 创建 Sphere 形状（半径）
     * @param[zh-cn] radius 半径
     * @return[zh-cn] Sphere 形状描述
     *
     * @brief[en] Creates a Sphere shape (radius)
     * @param[en] radius The radius
     * @return[en] The Sphere shape description
     */
    public static func sphere(radius: Float64): PhysicsShape {
        return PhysicsShape(shapeType: PhysicsShapeType.Sphere, radius: radius)
    }

    /**
     * @brief[zh-cn] 创建 Capsule 形状（halfHeight = 圆柱段半高，不含半球帽）
     * @param[zh-cn] halfHeight 圆柱段半高
     * radius 半径
     * @return[zh-cn] Capsule 形状描述
     *
     * @brief[en] Creates a Capsule shape (halfHeight = half height of the cylindrical segment, excluding the hemisphere caps)
     * @param[en] halfHeight The half height of the cylindrical segment
     * radius The radius
     * @return[en] The Capsule shape description
     */
    public static func capsule(halfHeight: Float64, radius: Float64): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.Capsule,
            halfHeight: halfHeight, radius: radius)
    }

    /**
     * @brief[zh-cn] 创建 Cylinder 形状（halfHeight = 半高）
     * @param[zh-cn] halfHeight 半高
     * radius 半径
     * @return[zh-cn] Cylinder 形状描述
     *
     * @brief[en] Creates a Cylinder shape (halfHeight = half height)
     * @param[en] halfHeight The half height
     * radius The radius
     * @return[en] The Cylinder shape description
     */
    public static func cylinder(halfHeight: Float64, radius: Float64): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.Cylinder,
            halfHeight: halfHeight, radius: radius)
    }

    /**
     * @brief[zh-cn] 创建 Plane 形状（后端用大盒子近似无限平面）
     * @return[zh-cn] Plane 形状描述
     *
     * @brief[en] Creates a Plane shape (the backend approximates an infinite plane with a big box)
     * @return[en] The Plane shape description
     */
    public static func plane(): PhysicsShape {
        return PhysicsShape(shapeType: PhysicsShapeType.Plane)
    }

    /**
     * @brief[zh-cn] 创建 Mesh 三角网格形状（顶点 + 索引三角形）
     * @param[zh-cn] vertices 顶点数组（世界坐标）
     * triangles 三角形索引（每 3 个一组）
     * @return[zh-cn] Mesh 形状描述
     *
     * @brief[en] Creates a Mesh triangle-mesh shape (vertices + indexed triangles)
     * @param[en] vertices The vertex array (world coordinates)
     * triangles The triangle indices (triplets)
     * @return[en] The Mesh shape description
     */
    public static func mesh(vertices: Array<Vector3>,
                            triangles: Array<UInt32>): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.Mesh,
            vertices: vertices, triangles: triangles)
    }

    /**
     * @brief[zh-cn] 创建 ConvexHull 凸包形状（顶点列表，自动求凸包）
     * @param[zh-cn] points 凸包顶点列表
     * @return[zh-cn] ConvexHull 形状描述
     *
     * @brief[en] Creates a ConvexHull shape (vertex list, convex hull computed automatically)
     * @param[en] points The convex-hull vertex list
     * @return[en] The ConvexHull shape description
     */
    public static func convexHull(points: Array<Vector3>): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.ConvexHull,
            vertices: points)
    }

    /**
     * @brief[zh-cn] 创建 Compound 复合形状（多个子形状 + 相对质心的变换）
     * @param[zh-cn] parts 子形状部件数组
     * @return[zh-cn] Compound 形状描述
     *
     * @brief[en] Creates a Compound shape (multiple sub-shapes + transforms relative to the center of mass)
     * @param[en] parts The array of sub-shape parts
     * @return[en] The Compound shape description
     */
    public static func compound(parts: Array<PhysicsCompoundPart>): PhysicsShape {
        return PhysicsShape(
            shapeType: PhysicsShapeType.Compound,
            parts: parts)
    }
}

/**
 * @brief[zh-cn] 刚体创建描述（后端无关）
 * @explain[zh-cn] 后端据此创建底层刚体并加入物理世界。所有字段均提供默认值，
 * 通常只需设置 shape 与 position 即可。
 *
 * @brief[en] Rigid-body creation description (backend-agnostic)
 * @explain[en] The backend creates the underlying rigid body and adds it to the physics
 * world from this description. Every field has a default; usually only shape and
 * position need to be set.
 */
public class PhysicsBodyDesc {
    /**
     * @brief[zh-cn] 碰撞形状
     *
     * @brief[en] The collision shape
     */
    public var shape: PhysicsShape
    /**
     * @brief[zh-cn] 初始位置（世界坐标）
     *
     * @brief[en] The initial position (world coordinates)
     */
    public var position: Vector3
    /**
     * @brief[zh-cn] 初始旋转（四元数，单位四元数 = 无旋转）
     *
     * @brief[en] The initial rotation (quaternion; identity = no rotation)
     */
    public var rotation: Quaternion
    /**
     * @brief[zh-cn] 运动类型
     *
     * @brief[en] The motion type
     */
    public var motionType: PhysicsMotionType
    /**
     * @brief[zh-cn] 物理层（碰撞分组）
     *
     * @brief[en] The physics layer (collision grouping)
     */
    public var layer: PhysicsLayer
    /**
     * @brief[zh-cn] 激活策略
     *
     * @brief[en] The activation strategy
     */
    public var activation: PhysicsActivation
    /**
     * @brief[zh-cn] 摩擦系数（0~1，默认 0.2）
     *
     * @brief[en] Friction coefficient (0~1, default 0.2)
     */
    public var friction: Float64
    /**
     * @brief[zh-cn] 弹性系数（0~1，默认 0）
     *
     * @brief[en] Restitution coefficient (0~1, default 0)
     */
    public var restitution: Float64
    /**
     * @brief[zh-cn] 是否自动同步 transform 到绑定的 Object3D
     *
     * @brief[en] Whether to auto-sync the transform to the bound Object3D
     */
    public var autoSync: Bool
    /**
     * @brief[zh-cn] 质量（千克，<=0 时由后端从形状自动计算，默认 -1 = 自动）
     *
     * @brief[en] Mass (kilograms; <= 0 lets the backend compute it from the shape, default -1 = automatic)
     */
    public var mass: Float64
    /**
     * @brief[zh-cn] 重力因子（1 = 正常重力，0 = 无重力，默认 1）
     *
     * @brief[en] Gravity factor (1 = normal gravity, 0 = no gravity, default 1)
     */
    public var gravityFactor: Float64
    /**
     * @brief[zh-cn] 线阻尼（默认 0.05）
     *
     * @brief[en] Linear damping (default 0.05)
     */
    public var linearDamping: Float64
    /**
     * @brief[zh-cn] 角阻尼（默认 0.05）
     *
     * @brief[en] Angular damping (default 0.05)
     */
    public var angularDamping: Float64
    /**
     * @brief[zh-cn] 是否为传感器刚体（只检测碰撞不产生物理响应，默认 false）
     *
     * @brief[en] Whether this is a sensor body (collision-only, no physical response; default false)
     */
    public var isSensor: Bool

    /**
     * @brief[zh-cn] 创建刚体描述
     * @param[zh-cn] shape 碰撞形状
     * position 初始位置，默认原点
     * rotation 初始旋转，默认单位四元数
     * motionType 运动类型，默认 Dynamic
     * layer 物理层，默认 Moving
     * activation 激活策略，默认 Activate
     * friction 摩擦系数，默认 0.2
     * restitution 弹性系数，默认 0
     * autoSync 是否自动同步 transform，默认 true
     * mass 质量，默认 -1（自动计算）
     * gravityFactor 重力因子，默认 1
     * linearDamping 线阻尼，默认 0.05
     * angularDamping 角阻尼，默认 0.05
     * isSensor 是否为传感器，默认 false
     *
     * @brief[en] Creates a rigid-body description
     * @param[en] shape The collision shape
     * position The initial position; origin by default
     * rotation The initial rotation; identity by default
     * motionType The motion type; Dynamic by default
     * layer The physics layer; Moving by default
     * activation The activation strategy; Activate by default
     * friction The friction coefficient; 0.2 by default
     * restitution The restitution coefficient; 0 by default
     * autoSync Whether to auto-sync the transform; true by default
     * mass The mass; -1 by default (computed automatically)
     * gravityFactor The gravity factor; 1 by default
     * linearDamping The linear damping; 0.05 by default
     * angularDamping The angular damping; 0.05 by default
     * isSensor Whether this is a sensor; false by default
     */
    public init(shape!: PhysicsShape, position!: Vector3 = Vector3(),
                rotation!: Quaternion = Quaternion(),
                motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic,
                layer!: PhysicsLayer = PhysicsLayer.Moving,
                activation!: PhysicsActivation = PhysicsActivation.Activate,
                friction!: Float64 = 0.2, restitution!: Float64 = 0.0,
                autoSync!: Bool = true, mass!: Float64 = -1.0,
                gravityFactor!: Float64 = 1.0,
                linearDamping!: Float64 = 0.05,
                angularDamping!: Float64 = 0.05,
                isSensor!: Bool = false) {
        this.shape = shape
        this.position = position
        this.rotation = rotation
        this.motionType = motionType
        this.layer = layer
        this.activation = activation
        this.friction = friction
        this.restitution = restitution
        this.isSensor = isSensor
        this.autoSync = autoSync
        this.mass = mass
        this.gravityFactor = gravityFactor
        this.linearDamping = linearDamping
        this.angularDamping = angularDamping
    }
}

/**
 * @brief[zh-cn] 约束类型枚举（后端无关，对应 JPH_ConstraintSubType）
 * @explain[zh-cn] 覆盖 Fixed/Point/Hinge/Slider/Distance/Cone/SwingTwist/SixDOF/Gear。
 *
 * @brief[en] Constraint-type enum (backend-agnostic, corresponds to JPH_ConstraintSubType)
 * @explain[en] Covers Fixed/Point/Hinge/Slider/Distance/Cone/SwingTwist/SixDOF/Gear.
 */
public enum PhysicsConstraintType {
    /**
     * @brief[zh-cn] 固定约束（焊接两刚体，无相对运动）
     *
     * @brief[en] Fixed constraint (welds two bodies with no relative motion)
     */
    | Fixed
    /**
     * @brief[zh-cn] 点约束（球关节，共享一个锚点）
     *
     * @brief[en] Point constraint (ball joint, shared anchor point)
     */
    | Point
    /**
     * @brief[zh-cn] 铰链约束（绕单轴旋转，可限位/带电机）
     *
     * @brief[en] Hinge constraint (rotation about a single axis, limitable/motorized)
     */
    | Hinge
    /**
     * @brief[zh-cn] 滑块约束（沿单轴平移，可限位/带电机）
     *
     * @brief[en] Slider constraint (translation along a single axis, limitable/motorized)
     */
    | Slider
    /**
     * @brief[zh-cn] 距离约束（保持两刚体锚点间距离，可带弹簧）
     *
     * @brief[en] Distance constraint (keeps the distance between two anchors, spring-capable)
     */
    | Distance
    /**
     * @brief[zh-cn] 锥约束（锥角限制的球关节）
     *
     * @brief[en] Cone constraint (ball joint limited by a cone angle)
     */
    | Cone
    /**
     * @brief[zh-cn] 摆动-扭转约束（肩/髋关节）
     *
     * @brief[en] Swing-twist constraint (shoulder/hip joint)
     */
    | SwingTwist
    /**
     * @brief[zh-cn] 六自由度约束（每轴可 Free/Limited/Locked + 电机）
     *
     * @brief[en] Six-DOF constraint (each axis Free/Limited/Locked + motor)
     */
    | SixDOF
    /**
     * @brief[zh-cn] 齿轮约束（比例耦合两铰链旋转）
     *
     * @brief[en] Gear constraint (couples two hinge rotations at a ratio)
     */
    | Gear
}

/**
 * @brief[zh-cn] 约束空间（对应 JPH_ConstraintSpace）
 * @explain[zh-cn] - LocalToBodyCOM：锚点/轴定义在刚体质心局部坐标系
 * - WorldSpace：锚点/轴定义在世界坐标系
 *
 * @brief[en] Constraint space (corresponds to JPH_ConstraintSpace)
 * @explain[en] - LocalToBodyCOM: anchor/axis defined in the body's local center-of-mass frame
 * - WorldSpace: anchor/axis defined in world space
 */
public enum PhysicsConstraintSpace {
    /**
     * @brief[zh-cn] 锚点/轴定义在刚体质心局部坐标系
     *
     * @brief[en] Anchor/axis defined in the body's local center-of-mass frame
     */
    | LocalToBodyCOM
    /**
     * @brief[zh-cn] 锚点/轴定义在世界坐标系
     *
     * @brief[en] Anchor/axis defined in world space
     */
    | WorldSpace
}

/**
 * @brief[zh-cn] 约束创建描述（后端无关）
 * @explain[zh-cn] 后端据此创建底层约束并返回句柄。字段含义随 constraintType 不同而变化：
 * - Fixed    : 两刚体在 initial 位置焊接；anchor1/anchor2 可设
 * - Point    : anchor1/anchor2 = 两刚体上的共享锚点（空间依 space）
 * - Hinge    : anchor1/anchor2 = 锚点；axis1/axis2 = 铰链轴；
 * limitMin/limitMax = 旋转角度限位（弧度）
 * - Slider   : anchor1/anchor2 = 锚点；axis1/axis2 = 滑动轴；
 * limitMin/limitMax = 位置限位（米）
 * - Distance : anchor1/anchor2 = 锚点；limitMin/limitMax = 距离范围（米）
 * - Cone     : anchor1/anchor2 = 锚点；axis1/axis2 = 扭转轴；
 * limitMin = 半锥角（弧度）
 * - SwingTwist: anchor1/anchor2 = 锚点；axis1/axis2 = 扭转轴；
 * limitMin/limitMax = 扭转角限位；planeAxis 控制摆动
 * - SixDOF   : 各轴限位经 setAxisLimit/limitAxis 配置（默认全 Free）
 * - Gear     : axis1/axis2 = 两铰链轴；limitMin = 齿轮比
 *
 * @brief[en] Constraint creation description (backend-agnostic)
 * @explain[en] The backend creates the underlying constraint from this description and returns
 * a handle. Field meaning depends on constraintType:
 * - Fixed    : welds the two bodies at their initial positions; anchor1/anchor2 optional
 * - Point    : anchor1/anchor2 = the shared anchor on both bodies (space depends on space)
 * - Hinge    : anchor1/anchor2 = anchors; axis1/axis2 = hinge axis;
 * limitMin/limitMax = rotation limits (radians)
 * - Slider   : anchor1/anchor2 = anchors; axis1/axis2 = sliding axis;
 * limitMin/limitMax = position limits (meters)
 * - Distance : anchor1/anchor2 = anchors; limitMin/limitMax = distance range (meters)
 * - Cone     : anchor1/anchor2 = anchors; axis1/axis2 = twist axis;
 * limitMin = half-cone angle (radians)
 * - SwingTwist: anchor1/anchor2 = anchors; axis1/axis2 = twist axis;
 * limitMin/limitMax = twist limits; planeAxis controls the swing
 * - SixDOF   : per-axis limits configured via setAxisLimit/limitAxis (all Free by default)
 * - Gear     : axis1/axis2 = the two hinge axes; limitMin = gear ratio
 */
public class PhysicsConstraintDesc {
    /**
     * @brief[zh-cn] 约束类型
     *
     * @brief[en] The constraint type
     */
    public var constraintType: PhysicsConstraintType
    /**
     * @brief[zh-cn] 约束空间（LocalToBodyCOM / WorldSpace）
     *
     * @brief[en] The constraint space (LocalToBodyCOM / WorldSpace)
     */
    public var space: PhysicsConstraintSpace
    /**
     * @brief[zh-cn] 刚体 1 锚点（世界坐标或局部坐标，依 space）
     *
     * @brief[en] Body-1 anchor (world or local coordinates, depending on space)
     */
    public var anchor1: Vector3
    /**
     * @brief[zh-cn] 刚体 2 锚点（世界坐标或局部坐标，依 space）
     *
     * @brief[en] Body-2 anchor (world or local coordinates, depending on space)
     */
    public var anchor2: Vector3
    /**
     * @brief[zh-cn] 刚体 1 轴（铰链/滑块/扭转/齿轮轴）
     *
     * @brief[en] Body-1 axis (hinge/slider/twist/gear axis)
     */
    public var axis1: Vector3
    /**
     * @brief[zh-cn] 刚体 2 轴（铰链/滑块/扭转/齿轮轴）
     *
     * @brief[en] Body-2 axis (hinge/slider/twist/gear axis)
     */
    public var axis2: Vector3
    /**
     * @brief[zh-cn] 平面轴（SwingTwist 摆动方向参考，局部或世界）
     *
     * @brief[en] Plane axis (SwingTwist swing-direction reference, local or world)
     */
    public var planeAxis: Vector3
    /**
     * @brief[zh-cn] 限位最小值（角度弧度或距离米，依约束类型）
     *
     * @brief[en] Minimum limit (angle in radians or distance in meters, depending on type)
     */
    public var limitMin: Float64
    /**
     * @brief[zh-cn] 限位最大值（角度弧度或距离米，依约束类型）
     *
     * @brief[en] Maximum limit (angle in radians or distance in meters, depending on type)
     */
    public var limitMax: Float64
    /**
     * @brief[zh-cn] 约束是否启用
     *
     * @brief[en] Whether the constraint is enabled
     */
    public var enabled: Bool
    /**
     * @brief[zh-cn] 用户数据
     *
     * @brief[en] User data
     */
    public var userData: UInt64

    /**
     * @brief[zh-cn] 创建约束描述
     * @param[zh-cn] constraintType 约束类型
     * space 约束空间，默认 WorldSpace
     * anchor1 刚体 1 锚点，默认原点
     * anchor2 刚体 2 锚点，默认原点
     * axis1 刚体 1 轴，默认 (0,1,0)
     * axis2 刚体 2 轴，默认 (0,1,0)
     * planeAxis 平面轴（SwingTwist），默认 (1,0,0)
     * limitMin 限位最小值，默认 0
     * limitMax 限位最大值，默认 0
     * enabled 是否启用，默认 true
     * userData 用户数据，默认 0
     *
     * @brief[en] Creates a constraint description
     * @param[en] constraintType The constraint type
     * space The constraint space; WorldSpace by default
     * anchor1 The body-1 anchor; origin by default
     * anchor2 The body-2 anchor; origin by default
     * axis1 The body-1 axis; (0,1,0) by default
     * axis2 The body-2 axis; (0,1,0) by default
     * planeAxis The plane axis (SwingTwist); (1,0,0) by default
     * limitMin The minimum limit; 0 by default
     * limitMax The maximum limit; 0 by default
     * enabled Whether the constraint is enabled; true by default
     * userData User data; 0 by default
     */
    public init(constraintType!: PhysicsConstraintType,
                space!: PhysicsConstraintSpace = PhysicsConstraintSpace.WorldSpace,
                anchor1!: Vector3 = Vector3(), anchor2!: Vector3 = Vector3(),
                axis1!: Vector3 = Vector3(0.0, 1.0, 0.0),
                axis2!: Vector3 = Vector3(0.0, 1.0, 0.0),
                planeAxis!: Vector3 = Vector3(1.0, 0.0, 0.0),
                limitMin!: Float64 = 0.0, limitMax!: Float64 = 0.0,
                enabled!: Bool = true, userData!: UInt64 = 0) {
        this.constraintType = constraintType
        this.space = space
        this.anchor1 = anchor1
        this.anchor2 = anchor2
        this.axis1 = axis1
        this.axis2 = axis2
        this.planeAxis = planeAxis
        this.limitMin = limitMin
        this.limitMax = limitMax
        this.enabled = enabled
        this.userData = userData
    }
}

/**
 * @brief[zh-cn] 约束句柄（后端无关）
 * @explain[zh-cn] 后端创建约束后返回此句柄，上层通过句柄操作约束。
 * constraintID 为 0xFFFFFFFF 表示无效句柄。
 *
 * @brief[en] Constraint handle (backend-agnostic)
 * @explain[en] Returned by the backend after creating a constraint; upper layers operate
 * on the constraint through this handle. A constraintID of 0xFFFFFFFF means invalid.
 */
public struct PhysicsConstraintHandle {
    /**
     * @brief[zh-cn] 约束 ID
     *
     * @brief[en] The constraint ID
     */
    public let constraintID: UInt32

    /**
     * @brief[zh-cn] 创建约束句柄
     * @param[zh-cn] constraintID 后端分配的约束 ID
     *
     * @brief[en] Creates a constraint handle
     * @param[en] constraintID The backend-assigned constraint ID
     */
    public init(constraintID!: UInt32) { this.constraintID = constraintID }

    /**
     * @brief[zh-cn] 无效句柄
     *
     * @brief[en] The invalid handle
     */
    public static let INVALID: PhysicsConstraintHandle = PhysicsConstraintHandle(constraintID: 0xFFFFFFFF)

    /**
     * @brief[zh-cn] 是否有效
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the handle is valid
     * @return[en] true if valid
     */
    public func isValid(): Bool { return this.constraintID != 0xFFFFFFFF }
}

/**
 * @brief[zh-cn] 射线查询结果（后端无关）
 * @explain[zh-cn] 后端命中后填充本结构返回。
 *
 * @brief[en] Ray-cast query result (backend-agnostic)
 * @explain[en] Filled in and returned by the backend when a hit occurs.
 */
public class PhysicsRayHit {
    /**
     * @brief[zh-cn] 被命中刚体的 BodyID（后端私有句柄的整型表示，0 = 无效）
     *
     * @brief[en] The hit body's BodyID (integer form of the backend's private handle; 0 = invalid)
     */
    public var bodyID: UInt32 = 0
    /**
     * @brief[zh-cn] 命中比例 0..1（沿射线方向）
     *
     * @brief[en] Hit fraction 0..1 (along the ray direction)
     */
    public var fraction: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 命中点世界坐标
     *
     * @brief[en] The hit point in world coordinates
     */
    public var point: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 命中面法线（世界空间）
     *
     * @brief[en] The hit-surface normal (world space)
     */
    public var normal: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 创建空的射线命中结果
     *
     * @brief[en] Creates an empty ray-hit result
     */
    public init() {}
}

/**
 * @brief[zh-cn] 点碰撞查询结果（collidePoint，后端无关）
 * @explain[zh-cn] 覆盖 Jolt 的 JPH_CollidePointResult（bodyID + subShapeID2）。
 *
 * @brief[en] Point-collision query result (collidePoint, backend-agnostic)
 * @explain[en] Mirrors Jolt's JPH_CollidePointResult (bodyID + subShapeID2).
 */
public class PhysicsPointHit {
    /**
     * @brief[zh-cn] 被命中刚体的 BodyID（0 = 无效）
     *
     * @brief[en] The hit body's BodyID (0 = invalid)
     */
    public var bodyID: UInt32 = 0
    /**
     * @brief[zh-cn] 被命中形状的子形状 ID
     *
     * @brief[en] The sub-shape ID of the hit shape
     */
    public var subShapeID: UInt32 = 0

    /**
     * @brief[zh-cn] 创建空的点碰撞命中结果
     *
     * @brief[en] Creates an empty point-hit result
     */
    public init() {}
}

/**
 * @brief[zh-cn] 形状碰撞/投射查询结果（collideShape/castShape，后端无关）
 * @explain[zh-cn] 覆盖 Jolt 的 JPH_CollideShapeResult / JPH_ShapeCastResult 核心字段。
 *
 * @brief[en] Shape-collision/cast query result (collideShape/castShape, backend-agnostic)
 * @explain[en] Mirrors the core fields of Jolt's JPH_CollideShapeResult / JPH_ShapeCastResult.
 */
public class PhysicsShapeHit {
    /**
     * @brief[zh-cn] 被命中刚体的 BodyID（0 = 无效）
     *
     * @brief[en] The hit body's BodyID (0 = invalid)
     */
    public var bodyID: UInt32 = 0
    /**
     * @brief[zh-cn] 命中比例 0..1（仅 castShape 有效；collideShape 为 0）
     *
     * @brief[en] Hit fraction 0..1 (castShape only; 0 for collideShape)
     */
    public var fraction: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 接触点（查询形状表面，世界坐标）
     *
     * @brief[en] Contact point (on the query shape's surface, world coordinates)
     */
    public var point: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 穿透轴方向（从被撞体指向查询形状）
     *
     * @brief[en] Penetration-axis direction (from the hit body toward the query shape)
     */
    public var normal: Vector3 = Vector3()
    /**
     * @brief[zh-cn] 穿透深度（collideShape 有效）
     *
     * @brief[en] Penetration depth (valid for collideShape)
     */
    public var penetrationDepth: Float32 = 0.0f32
    /**
     * @brief[zh-cn] 查询形状子形状 ID
     *
     * @brief[en] The query shape's sub-shape ID
     */
    public var subShapeID1: UInt32 = 0
    /**
     * @brief[zh-cn] 被命中形状子形状 ID
     *
     * @brief[en] The hit shape's sub-shape ID
     */
    public var subShapeID2: UInt32 = 0
    /**
     * @brief[zh-cn] 是否为背面命中（castShape 有效）
     *
     * @brief[en] Whether the hit is on the back face (castShape only)
     */
    public var isBackFaceHit: Bool = false

    /**
     * @brief[zh-cn] 创建空的形状命中结果
     *
     * @brief[en] Creates an empty shape-hit result
     */
    public init() {}
}

/**
 * @brief[zh-cn] 碰撞回调事件类型（ContactListener）
 * @explain[zh-cn] 覆盖 Jolt 的 OnContactAdded/OnContactPersisted/OnContactRemoved。
 *
 * @brief[en] Collision callback event type (ContactListener)
 * @explain[en] Mirrors Jolt's OnContactAdded/OnContactPersisted/OnContactRemoved.
 */
public enum PhysicsContactEvent {
    /**
     * @brief[zh-cn] 接触建立（两刚体开始接触）
     *
     * @brief[en] Contact established (two bodies start touching)
     */
    | Added
    /**
     * @brief[zh-cn] 接触持续（每帧仍在接触）
     *
     * @brief[en] Contact persists (still touching each frame)
     */
    | Persisted
    /**
     * @brief[zh-cn] 接触移除（两刚体分离）
     *
     * @brief[en] Contact removed (two bodies separate)
     */
    | Removed
}

/**
 * @brief[zh-cn] 传感器回调（后端无关）
 * @explain[zh-cn] 覆盖 Jolt 的 ContactListener / BodyActivationListener。
 * 由后端在物理线程内调用（回调内禁止调用走 _execPhysics 的方法，防死锁）。
 * 注意：传感器回调依赖底层库的回调机制（joltc 的 Procs 表），
 * 接入方法随后端实现而定；JoltBackend 通过 setContactListener 等注册。
 *
 * @brief[en] Sensor callbacks (backend-agnostic)
 * @explain[en] Mirrors Jolt's ContactListener / BodyActivationListener.
 * Called by the backend on the physics thread (do not call methods that go through
 * _execPhysics from inside a callback, to avoid deadlock).
 * Note: these callbacks rely on the underlying library's callback mechanism
 * (joltc's Procs table); wiring them up depends on the backend implementation, e.g.
 * JoltBackend registers via setContactListener.
 */
public interface IPhysicsSensorListener {
    /**
     * @brief[zh-cn] 接触事件回调（Added/Persisted/Removed）
     * @param[zh-cn] bodyID1 刚体 1 的 BodyID
     * bodyID2 刚体 2 的 BodyID
     * event 接触事件类型
     *
     * @brief[en] Contact event callback (Added/Persisted/Removed)
     * @param[en] bodyID1 The BodyID of body 1
     * bodyID2 The BodyID of body 2
     * event The contact event type
     */
    func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit
    /**
     * @brief[zh-cn] 刚体被激活（开始模拟）
     * @param[zh-cn] bodyID 被激活刚体的 BodyID
     *
     * @brief[en] A body was activated (starts simulating)
     * @param[en] bodyID The activated body's BodyID
     */
    func onBodyActivated(bodyID: UInt32): Unit
    /**
     * @brief[zh-cn] 刚体休眠（停止模拟）
     * @param[zh-cn] bodyID 休眠刚体的 BodyID
     *
     * @brief[en] A body went to sleep (stops simulating)
     * @param[en] bodyID The sleeping body's BodyID
     */
    func onBodyDeactivated(bodyID: UInt32): Unit
}

// =============================================================================
// 后端句柄类型
// =============================================================================

/**
 * @brief[zh-cn] 物理刚体句柄（后端无关）
 * @explain[zh-cn] 后端创建刚体后返回此句柄，上层通过句柄操作刚体。
 * bodyID 为 0 表示无效句柄。
 *
 * @brief[en] Physics body handle (backend-agnostic)
 * @explain[en] Returned by the backend after creating a body; upper layers operate
 * on the body through this handle. A bodyID of 0 means invalid.
 *
 * @note[zh-cn] bodyID 选用 UInt32 与 Jolt BodyID 兼容；其他后端可自行映射内部 ID 到 UInt32。
 * @note[en] bodyID uses UInt32 for compatibility with the Jolt BodyID; other backends
 * may map their internal IDs to UInt32.
 */
public struct PhysicsBodyHandle {
    /**
     * @brief[zh-cn] 刚体 ID
     *
     * @brief[en] The body ID
     */
    public let bodyID: UInt32
    /**
     * @brief[zh-cn] 创建刚体句柄
     * @param[zh-cn] bodyID 后端分配的刚体 ID
     *
     * @brief[en] Creates a body handle
     * @param[en] bodyID The backend-assigned body ID
     */
    public init(bodyID!: UInt32) { this.bodyID = bodyID }
    /**
     * @brief[zh-cn] 无效句柄
     *
     * @brief[en] The invalid handle
     */
    public static let INVALID: PhysicsBodyHandle = PhysicsBodyHandle(bodyID: 0xFFFFFFFF)
    /**
     * @brief[zh-cn] 是否有效
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the handle is valid
     * @return[en] true if valid
     */
    public func isValid(): Bool { return this.bodyID != 0xFFFFFFFF && this.bodyID != 0 }
}

// =============================================================================
// 可插拔后端接口
// =============================================================================

/**
 * @brief[zh-cn] 可插拔物理后端接口
 * @explain[zh-cn] 实现方职责：
 * - 管理底层物理库的全局初始化/卸载（JPH_Init/JPH_Shutdown 等）；
 * - 创建/销毁物理系统（含作业系统、层过滤）；
 * - 创建/销毁碰撞形状与刚体；
 * - 步进物理世界（update）；
 * - 读写刚体 transform/速度/摩擦/弹性/运动类型/对象层；
 * - 射线与碰撞查询。
 * 调用方（PhysicsWorld）职责：
 * - 在专用物理线程内调用本接口所有方法；
 * - 维护 Object3D ↔ PhysicsBodyHandle 绑定映射；
 * - 步进后读回刚体 transform 同步到绑定的 Object3D。
 * 线程安全：实现不需要线程安全（单线程物理线程内调用）；
 * 但实现的底层句柄在物理线程外不可访问。
 *
 * @brief[en] Pluggable physics backend interface
 * @explain[en] Implementer responsibilities:
 * - manage the underlying library's global init/shutdown (JPH_Init/JPH_Shutdown, etc.);
 * - create/destroy the physics system (including the job system and layer filter);
 * - create/destroy collision shapes and bodies;
 * - step the physics world (update);
 * - read/write body transform/velocity/friction/restitution/motion type/object layer;
 * - ray and collision queries.
 * Caller (PhysicsWorld) responsibilities:
 * - call every method of this interface on a dedicated physics thread;
 * - maintain the Object3D ↔ PhysicsBodyHandle binding map;
 * - read back body transforms after stepping to sync the bound Object3D.
 * Thread safety: the implementation need not be thread-safe (all calls happen on a
 * single physics thread); however, the implementation's underlying handles must not
 * be accessed outside that thread.
 */
public interface IPhysicsBackend {
    // ===== 生命周期 =====

    /**
     * @brief[zh-cn] 初始化后端（全局初始化 + 创建物理系统/作业系统/层过滤）
     * @param[zh-cn] maxBodies 世界最多刚体数
     * gravity 全局重力向量（如 (0, -9.81, 0)）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Initializes the backend (global init + creates the physics system/job system/layer filter)
     * @param[en] maxBodies Maximum number of bodies in the world
     * gravity The global gravity vector (e.g. (0, -9.81, 0))
     * @return[en] true on success
     */
    func initialize(maxBodies: UInt32, gravity: Vector3): Bool

    /**
     * @brief[zh-cn] 关闭后端（销毁物理系统 + 全局卸载）
     *
     * @brief[en] Shuts down the backend (destroys the physics system + global teardown)
     *
     * @note[zh-cn] 调用后本实例不可再用。
     * @note[en] The instance must not be used again after this call.
     */
    func shutdown(): Unit

    /**
     * @brief[zh-cn] 是否已初始化
     * @return[zh-cn] 已初始化返回 true
     *
     * @brief[en] Whether the backend is initialized
     * @return[en] true if initialized
     */
    func isInitialized(): Bool

    // ===== 世界设置 =====

    /**
     * @brief[zh-cn] 设置全局重力
     * @param[zh-cn] gravity 重力向量（如 (0, -9.81, 0)）
     *
     * @brief[en] Sets the global gravity
     * @param[en] gravity The gravity vector (e.g. (0, -9.81, 0))
     */
    func setGravity(gravity: Vector3): Unit

    /**
     * @brief[zh-cn] 优化 BroadPhase 包围盒树
     *
     * @brief[en] Optimizes the BroadPhase bounding-volume tree
     *
     * @note[zh-cn] 在批量插入刚体后、正式模拟前调用一次。
     * @note[en] Call once after bulk-inserting bodies and before the main simulation.
     */
    func optimizeBroadPhase(): Unit

    // ===== 形状/刚体 =====

    /**
     * @brief[zh-cn] 创建刚体并加入物理世界（一步完成）
     * @param[zh-cn] desc 刚体创建描述
     * @return[zh-cn] 刚体句柄；失败返回 INVALID
     *
     * @brief[en] Creates a body and adds it to the physics world (single step)
     * @param[en] desc The body creation description
     * @return[en] The body handle, or INVALID on failure
     */
    func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle

    /**
     * @brief[zh-cn] 移除并销毁刚体（一步完成，句柄立即失效）
     * @param[zh-cn] handle 刚体句柄
     *
     * @brief[en] Removes and destroys a body (single step; the handle becomes invalid immediately)
     * @param[en] handle The body handle
     */
    func destroyBody(handle: PhysicsBodyHandle): Unit

    /**
     * @brief[zh-cn] 查询刚体是否处于活动（模拟）状态
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 活动返回 true
     *
     * @brief[en] Queries whether a body is in the active (simulating) state
     * @param[en] handle The body handle
     * @return[en] true if active
     */
    func isBodyActive(handle: PhysicsBodyHandle): Bool

    /**
     * @brief[zh-cn] 设置刚体是否为传感器
     * @param[zh-cn] handle 刚体句柄
     * isSensor 是否传感器（只检测碰撞、不产生物理响应）
     *
     * @brief[en] Sets whether a body is a sensor
     * @param[en] handle The body handle
     * isSensor Whether the body is a sensor (collision-only, no physical response)
     */
    func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit

    // ===== Transform 读写 =====

    /**
     * @brief[zh-cn] 设置刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * position 新位置
     * activation 激活策略
     *
     * @brief[en] Sets the body position (world coordinates)
     * @param[en] handle The body handle
     * position The new position
     * activation The activation strategy
     */
    func setPosition(handle: PhysicsBodyHandle, position: Vector3,
                     activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前位置
     *
     * @brief[en] Gets the body position (world coordinates)
     * @param[en] handle The body handle
     * @return[en] The body's current position
     */
    func getPosition(handle: PhysicsBodyHandle): Vector3

    /**
     * @brief[zh-cn] 设置刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * rotation 新旋转
     * activation 激活策略
     *
     * @brief[en] Sets the body rotation (quaternion)
     * @param[en] handle The body handle
     * rotation The new rotation
     * activation The activation strategy
     */
    func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion,
                     activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前旋转
     *
     * @brief[en] Gets the body rotation (quaternion)
     * @param[en] handle The body handle
     * @return[en] The body's current rotation
     */
    func getRotation(handle: PhysicsBodyHandle): Quaternion

    // ===== 速度读写 =====

    /**
     * @brief[zh-cn] 设置刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * velocity 线速度
     *
     * @brief[en] Sets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * velocity The linear velocity
     */
    func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit

    /**
     * @brief[zh-cn] 获取刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前线速度
     *
     * @brief[en] Gets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * @return[en] The body's current linear velocity
     */
    func getLinearVelocity(handle: PhysicsBodyHandle): Vector3

    /**
     * @brief[zh-cn] 设置刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * angularVelocity 角速度
     *
     * @brief[en] Sets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * angularVelocity The angular velocity
     */
    func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit

    /**
     * @brief[zh-cn] 获取刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前角速度
     *
     * @brief[en] Gets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * @return[en] The body's current angular velocity
     */
    func getAngularVelocity(handle: PhysicsBodyHandle): Vector3

    // ===== 物理 material 读写 =====

    /**
     * @brief[zh-cn] 设置刚体摩擦系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * friction 摩擦系数
     *
     * @brief[en] Sets the body friction coefficient (0~1)
     * @param[en] handle The body handle
     * friction The friction coefficient
     */
    func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前摩擦系数
     *
     * @brief[en] Gets the body friction coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current friction coefficient
     */
    func getFriction(handle: PhysicsBodyHandle): Float64

    /**
     * @brief[zh-cn] 设置刚体弹性系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * restitution 弹性系数
     *
     * @brief[en] Sets the body restitution coefficient (0~1)
     * @param[en] handle The body handle
     * restitution The restitution coefficient
     */
    func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体弹性系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前弹性系数
     *
     * @brief[en] Gets the body restitution coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current restitution coefficient
     */
    func getRestitution(handle: PhysicsBodyHandle): Float64

    // ===== 运动属性 =====

    /**
     * @brief[zh-cn] 设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）
     * @param[zh-cn] handle 刚体句柄
     * motionType 目标运动类型
     * activation 激活策略
     *
     * @brief[en] Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)
     * @param[en] handle The body handle
     * motionType The target motion type
     * activation The activation strategy
     */
    func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType,
                       activation: PhysicsActivation): Unit

    /**
     * @brief[zh-cn] 获取刚体运动类型
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前运动类型
     *
     * @brief[en] Gets the body motion type
     * @param[en] handle The body handle
     * @return[en] The body's current motion type
     */
    func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType

    /**
     * @brief[zh-cn] 设置刚体对象层（运行时改变碰撞分组）
     * @param[zh-cn] handle 刚体句柄
     * layer 目标对象层
     *
     * @brief[en] Sets the body object layer (changes the collision grouping at runtime)
     * @param[en] handle The body handle
     * layer The target object layer
     */
    func setObjectLayer(handle: PhysicsBodyHandle, layer: PhysicsLayer): Unit

    /**
     * @brief[zh-cn] 获取刚体对象层
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前对象层
     *
     * @brief[en] Gets the body object layer
     * @param[en] handle The body handle
     * @return[en] The body's current object layer
     */
    func getObjectLayer(handle: PhysicsBodyHandle): PhysicsLayer

    // ===== 力 / 力矩 / 冲量 =====

    /**
     * @brief[zh-cn] 在刚体质心施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     *
     * @brief[en] Applies a force at the body's center of mass (newtons)
     * @param[en] handle The body handle
     * force The force vector
     */
    func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit

    /**
     * @brief[zh-cn] 在刚体指定世界位置施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     * point 作用点（世界坐标）
     *
     * @brief[en] Applies a force at a specified world position on the body (newtons)
     * @param[en] handle The body handle
     * force The force vector
     * point The point of application (world coordinates)
     */
    func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit

    /**
     * @brief[zh-cn] 施加力矩（牛顿·米）
     * @param[zh-cn] handle 刚体句柄
     * torque 力矩向量
     *
     * @brief[en] Applies a torque (newton-meters)
     * @param[en] handle The body handle
     * torque The torque vector
     */
    func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit

    /**
     * @brief[zh-cn] 在刚体质心施加冲量（冲量 = 力 × 时间）
     * @param[zh-cn] handle 刚体句柄
     * impulse 冲量向量
     *
     * @brief[en] Applies an impulse at the body's center of mass (impulse = force × time)
     * @param[en] handle The body handle
     * impulse The impulse vector
     */
    func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit

    /**
     * @brief[zh-cn] 施加角冲量
     * @param[zh-cn] handle 刚体句柄
     * angularImpulse 角冲量向量
     *
     * @brief[en] Applies an angular impulse
     * @param[en] handle The body handle
     * angularImpulse The angular impulse vector
     */
    func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit

    // ===== 质量 / 惯量 =====

    /**
     * @brief[zh-cn] 获取刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前质量
     *
     * @brief[en] Gets the body mass (kilograms)
     * @param[en] handle The body handle
     * @return[en] The body's current mass
     */
    func getMass(handle: PhysicsBodyHandle): Float64

    /**
     * @brief[zh-cn] 设置刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * mass 目标质量
     *
     * @brief[en] Sets the body mass (kilograms)
     * @param[en] handle The body handle
     * mass The target mass
     */
    func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体逆惯量（3x3，输出 4x4 矩阵左上角）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前逆惯量矩阵
     *
     * @brief[en] Gets the body inverse inertia (3x3, in the top-left of the returned 4x4)
     * @param[en] handle The body handle
     * @return[en] The body's current inverse-inertia matrix
     */
    func getInverseInertia(handle: PhysicsBodyHandle): Matrix4

    /**
     * @brief[zh-cn] 设置刚体重力因子（1 = 正常重力，0 = 无重力）
     * @param[zh-cn] handle 刚体句柄
     * gravityFactor 重力因子
     *
     * @brief[en] Sets the body gravity factor (1 = normal gravity, 0 = no gravity)
     * @param[en] handle The body handle
     * gravityFactor The gravity factor
     */
    func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit

    /**
     * @brief[zh-cn] 获取刚体重力因子
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前重力因子
     *
     * @brief[en] Gets the body gravity factor
     * @param[en] handle The body handle
     * @return[en] The body's current gravity factor
     */
    func getGravityFactor(handle: PhysicsBodyHandle): Float64

    // ===== 运动学 =====

    /**
     * @brief[zh-cn] 运动学刚体移动到指定位置/旋转
     * @param[zh-cn] handle 刚体句柄
     * position 目标位置（世界坐标）
     * rotation 目标旋转
     * deltaTime 时间步长（秒）
     *
     * @brief[en] Moves a kinematic body to the given position/rotation
     * @param[en] handle The body handle
     * position The target position (world coordinates)
     * rotation The target rotation
     * deltaTime The time step (seconds)
     *
     * @note[zh-cn] 每帧调用，由 deltaTime 步长驱动。
     * @note[en] Call every frame; driven by the deltaTime step.
     */
    func moveKinematic(handle: PhysicsBodyHandle, position: Vector3,
                       rotation: Quaternion, deltaTime: Float32): Unit

    // ===== 约束 =====

    /**
     * @brief[zh-cn] 创建约束并加入世界（连接两个刚体）
     * @param[zh-cn] desc 约束创建描述
     * bodyA 约束刚体 1
     * bodyB 约束刚体 2
     * @return[zh-cn] 约束句柄；失败返回 INVALID
     *
     * @brief[en] Creates a constraint and adds it to the world (connecting two bodies)
     * @param[en] desc The constraint creation description
     * bodyA The first constrained body
     * bodyB The second constrained body
     * @return[en] The constraint handle, or INVALID on failure
     */
    func createConstraint(desc: PhysicsConstraintDesc,
                          bodyA: PhysicsBodyHandle,
                          bodyB: PhysicsBodyHandle): PhysicsConstraintHandle

    /**
     * @brief[zh-cn] 销毁约束并从世界移除（句柄立即失效）
     * @param[zh-cn] handle 约束句柄
     *
     * @brief[en] Destroys a constraint and removes it from the world (the handle becomes invalid immediately)
     * @param[en] handle The constraint handle
     */
    func destroyConstraint(handle: PhysicsConstraintHandle): Unit

    /**
     * @brief[zh-cn] 约束是否启用
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Whether the constraint is enabled
     * @param[en] handle The constraint handle
     * @return[en] true if enabled
     */
    func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool

    /**
     * @brief[zh-cn] 设置约束是否启用
     * @param[zh-cn] handle 约束句柄
     * enabled 是否启用
     *
     * @brief[en] Sets whether the constraint is enabled
     * @param[en] handle The constraint handle
     * enabled Whether the constraint is enabled
     */
    func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit

    // ===== 步进 =====

    /**
     * @brief[zh-cn] 步进物理世界一帧
     * @param[zh-cn] deltaTime 时间步长（秒），典型 1/60
     * collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）
     * @return[zh-cn] 更新错误标志（0 = 完整完成）
     *
     * @brief[en] Steps the physics world by one frame
     * @param[en] deltaTime The time step (seconds), typically 1/60
     * collisionSteps The number of collision substeps per step (1 for a 1/60s step)
     * @return[en] The update error flags (0 = completed fully)
     */
    func update(deltaTime: Float32, collisionSteps: Int32): UInt32

    // ===== 射线查询 =====

    /**
     * @brief[zh-cn] 世界射线检测（最近命中）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * hit 命中结果输出（命中时有效）
     * @return[zh-cn] 是否命中
     *
     * @brief[en] World ray cast (closest hit)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * hit The hit-result output (valid when a hit occurs)
     * @return[en] true if anything was hit
     */
    func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool

    // ===== 碰撞查询（完整能力） =====

    /**
     * @brief[zh-cn] 世界射线批量检测（收集所有命中，按距离升序）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * hits 命中结果输出（调用方传入空列表，后端按距离升序填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] World ray batch cast (collects all hits, sorted by distance ascending)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * hits The hit-result output (pass an empty list; the backend fills it sorted by distance)
     * @return[en] The number of hits
     */
    func raycastAll(origin: Vector3, direction: Vector3,
                    hits: ArrayList<PhysicsRayHit>): Int64

    /**
     * @brief[zh-cn] 世界点碰撞检测（检测点位于哪些形状内部/表面）
     * @param[zh-cn] point 世界坐标检测点
     * hits 命中结果输出（后端填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] World point collision test (which shapes contain or touch the point)
     * @param[en] point The test point in world coordinates
     * hits The hit-result output (filled by the backend)
     * @return[en] The number of hits
     */
    func collidePoint(point: Vector3, hits: ArrayList<PhysicsPointHit>): Int64

    /**
     * @brief[zh-cn] 形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）
     * @param[zh-cn] shape 查询形状描述
     * position 查询形状位置（世界坐标）
     * rotation 查询形状旋转
     * hits 命中结果输出（后端填充）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)
     * @param[en] shape The query shape description
     * position The query shape position (world coordinates)
     * rotation The query shape rotation
     * hits The hit-result output (filled by the backend)
     * @return[en] The number of hits
     */
    func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion,
                      hits: ArrayList<PhysicsShapeHit>): Int64

    /**
     * @brief[zh-cn] 形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）
     * @param[zh-cn] shape 投射形状描述
     * position 投射起点位置（世界坐标）
     * rotation 投射形状旋转
     * direction 投射方向（长度即最大扫掠距离）
     * hits 命中结果输出（按 fraction 升序）
     * @return[zh-cn] 命中数量
     *
     * @brief[en] Shape cast (sweeps shape along direction, detecting the first/all blockers)
     * @param[en] shape The cast shape description
     * position The cast start position (world coordinates)
     * rotation The cast shape rotation
     * direction The cast direction (its length is the max sweep distance)
     * hits The hit-result output (sorted by fraction ascending)
     * @return[en] The number of hits
     */
    func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion,
                   direction: Vector3, hits: ArrayList<PhysicsShapeHit>): Int64

    // ===== 接触监听（ContactListener） =====

    /**
     * @brief[zh-cn] 注册碰撞事件监听器（接触回调 + 激活/休眠回调）
     * @param[zh-cn] listener 监听器；None 注销
     *
     * @brief[en] Registers a collision event listener (contact + activation/sleep callbacks)
     * @param[en] listener The listener, or None to unregister
     */
    func setContactListener(listener: Option<IPhysicsSensorListener>): Unit

    // ===== 后端标识 =====

    /**
     * @brief[zh-cn] 后端名称（如 "JoltPhysics"），用于日志/调试
     * @return[zh-cn] 后端名称字符串
     *
     * @brief[en] The backend name (e.g. "JoltPhysics"), for logging/debugging
     * @return[en] The backend name string
     */
    func backendName(): String
}
