/**
 * @file jolt4cj.jolt 类型定义
 * @brief joltc（JoltPhysics C API 包装层）的枚举与结构体类型
 * @explain 本文件包含 cxx/joltc/include/joltc.h 中核心枚举与结构体定义的仓颉版本：
 *         - 枚举为引用类型，不满足 CType 约束，不能直接作为 foreign 函数
 *           参数/返回值；foreign 函数使用 UInt32/Int32（底层 C 枚举表示），
 *           调用方通过 `枚举.value()` 与 `枚举.fromValue(u32)` 转换；
 *         - JPHVec3 / JPHQuat / JPHRayCastResult / JPHPhysicsSystemSettings /
 *           JobSystemThreadPoolConfig 为 @C 结构体，与 C 布局完全一致，
 *           用于 foreign 函数的参数/输出（配合 LibC.malloc 分配、p.read() 读取）。
 * @note joltc.h 中 JPH_RVec3 默认就是 JPH_Vec3（单精度），故位置/质心
 *       查询统一使用 JPHVec3。
 * @see cxx/joltc/include/joltc.h
 */
protected package three._vendor.jolt4cj.jolt

// =============================================================================
// 枚举：刚体类型
// =============================================================================

/**
 * @brief 刚体类型（对应 JPH_BodyType）
 * @explain 区分刚体（Rigid，传统刚体物理）与软体（Soft，可变形体）。
 */
public enum BodyType {
    /** @brief 刚体（标准刚体物理对象） */
    | Rigid
    /** @brief 软体（可变形体，需软体约束） */
    | Soft

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Rigid => 0
            case Soft => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Rigid） */
    public static func fromValue(v: UInt32): BodyType {
        match (v) {
            case 0 => Rigid
            case 1 => Soft
            case _ => Rigid
        }
    }
}

// =============================================================================
// 枚举：刚体运动类型
// =============================================================================

/**
 * @brief 刚体运动类型（对应 JPH_MotionType）
 * @explain 决定刚体受物理模拟影响的方式：
 *         - Static：完全不动，不受力不移动，用于地面/墙壁；
 *         - Kinematic：由用户控制位置/速度，不参与动力学求解；
 *         - Dynamic：受重力/碰撞/力驱动，标准物理模拟对象。
 */
public enum MotionType {
    /** @brief 静态刚体：不受力、不移动（地面/墙壁） */
    | Static
    /** @brief 运动学刚体：由用户设定速度驱动，不参与动力学求解 */
    | Kinematic
    /** @brief 动态刚体：受重力与碰撞作用，标准物理模拟对象 */
    | Dynamic

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Static => 0
            case Kinematic => 1
            case Dynamic => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Static） */
    public static func fromValue(v: UInt32): MotionType {
        match (v) {
            case 0 => Static
            case 1 => Kinematic
            case 2 => Dynamic
            case _ => Static
        }
    }
}

// =============================================================================
// 枚举：激活策略
// =============================================================================

/**
 * @brief 激活策略（对应 JPH_Activation）
 * @explain 添加刚体到世界时是否立即唤醒：Activate 立即开始模拟，
 *         DontActivate 保持休眠（适合预摆放大量静止物体）。
 */
public enum Activation {
    /** @brief 立即激活（开始模拟） */
    | Activate
    /** @brief 不激活（保持休眠） */
    | DontActivate

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Activate => 0
            case DontActivate => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Activate） */
    public static func fromValue(v: UInt32): Activation {
        match (v) {
            case 0 => Activate
            case 1 => DontActivate
            case _ => Activate
        }
    }
}

// =============================================================================
// 枚举：运动质量
// =============================================================================

/**
 * @brief 运动质量（对应 JPH_MotionQuality）
 * @explain 决定动态刚体是否做线性投射防穿透：
 *         - Discrete：离散检测，开销小，高速物体可能穿透薄墙；
 *         - LinearCast：线性投射，高速物体不会穿透，但开销较大。
 */
public enum MotionQuality {
    /** @brief 离散检测：开销小，高速可能穿透 */
    | Discrete
    /** @brief 线性投射：防止高速穿透，开销较大 */
    | LinearCast

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Discrete => 0
            case LinearCast => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Discrete） */
    public static func fromValue(v: UInt32): MotionQuality {
        match (v) {
            case 0 => Discrete
            case 1 => LinearCast
            case _ => Discrete
        }
    }
}

// =============================================================================
// 枚举：物理更新错误
// =============================================================================

/**
 * @brief 物理更新错误标志（对应 JPH_PhysicsUpdateError，位掩码）
 * @explain JPH_PhysicsSystem_Update 的返回值，非 0 表示更新不完整，
 *         多个位可同时置位（如缓存满导致部分接触被丢弃）。
 */
public enum PhysicsUpdateError {
    /** @brief 无错误，更新完整完成 */
    | None
    /** @brief 流形缓存已满（部分接触点被丢弃） */
    | ManifoldCacheFull
    /** @brief 刚体对缓存已满（BroadPhase 排队溢出） */
    | BodyPairCacheFull
    /** @brief 接触约束缓存已满（物体会开始穿透） */
    | ContactConstraintsFull

    /** @brief 将枚举值转换为 UInt32（C ABI 位掩码值） */
    public func value(): UInt32 {
        match (this) {
            case None => 0
            case ManifoldCacheFull => 1
            case BodyPairCacheFull => 2
            case ContactConstraintsFull => 4
        }
    }

    /** @brief 从 UInt32 位掩码判断是否包含某错误位 */
    public func isSet(mask: UInt32): Bool {
        (mask & value()) != 0
    }
}

// =============================================================================
// 枚举：接触验证结果
// =============================================================================

/**
 * @brief 接触验证结果（对应 JPH_ValidateResult）
 * @explain 由接触监听器的 OnContactValidate 回调返回，决定接触是否被接受。
 */
public enum ValidateResult {
    /** @brief 接受该刚体对的所有接触（不逐个验证） */
    | AcceptAllContactsForThisBodyPair
    /** @brief 接受当前接触 */
    | AcceptContact
    /** @brief 拒绝当前接触 */
    | RejectContact
    /** @brief 拒绝该刚体对的所有接触 */
    | RejectAllContactsForThisBodyPair

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case AcceptAllContactsForThisBodyPair => 0
            case AcceptContact => 1
            case RejectContact => 2
            case RejectAllContactsForThisBodyPair => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 RejectAllContactsForThisBodyPair） */
    public static func fromValue(v: UInt32): ValidateResult {
        match (v) {
            case 0 => AcceptAllContactsForThisBodyPair
            case 1 => AcceptContact
            case 2 => RejectContact
            case _ => RejectAllContactsForThisBodyPair
        }
    }
}

// =============================================================================
// 枚举：形状类型 / 形状子类型
// =============================================================================

/**
 * @brief 形状大类（对应 JPH_ShapeType）
 * @explain 区分凸形状、复合形状、装饰形状（平移/旋转/缩放包装）、网格、
 *         高度场与软体形状。
 */
public enum ShapeType {
    /** @brief 凸形状（球/盒/胶囊/圆柱/凸包等） */
    | Convex
    /** @brief 复合形状（由多个子形状组合） */
    | Compound
    /** @brief 装饰形状（RotatedTranslated/Scaled/OffsetCenterOfMass 包装） */
    | Decorated
    /** @brief 网格形状（三角形网格） */
    | Mesh
    /** @brief 高度场形状（地形） */
    | HeightField
    /** @brief 软体形状（可变形体） */
    | SoftBody
    /** @brief 用户自定义形状 1 */
    | User1
    /** @brief 用户自定义形状 2 */
    | User2
    /** @brief 用户自定义形状 3 */
    | User3
    /** @brief 用户自定义形状 4 */
    | User4

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Convex => 0
            case Compound => 1
            case Decorated => 2
            case Mesh => 3
            case HeightField => 4
            case SoftBody => 5
            case User1 => 6
            case User2 => 7
            case User3 => 8
            case User4 => 9
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 User4） */
    public static func fromValue(v: UInt32): ShapeType {
        match (v) {
            case 0 => Convex
            case 1 => Compound
            case 2 => Decorated
            case 3 => Mesh
            case 4 => HeightField
            case 5 => SoftBody
            case 6 => User1
            case 7 => User2
            case 8 => User3
            case _ => User4
        }
    }
}

/**
 * @brief 形状子类型（对应 JPH_ShapeSubType）
 * @explain 在 ShapeType 大类下的具体形状类型，JPH_Shape_GetSubType 的返回值。
 */
public enum ShapeSubType {
    /** @brief 球体 */
    | Sphere
    /** @brief 长方体 */
    | Box
    /** @brief 三角形 */
    | Triangle
    /** @brief 胶囊体 */
    | Capsule
    /** @brief 锥台胶囊体（上下半径不同） */
    | TaperedCapsule
    /** @brief 圆柱体 */
    | Cylinder
    /** @brief 凸包 */
    | ConvexHull
    /** @brief 静态复合形状 */
    | StaticCompound
    /** @brief 可变复合形状 */
    | MutableCompound
    /** @brief 平移旋转装饰形状 */
    | RotatedTranslated
    /** @brief 缩放装饰形状 */
    | Scaled
    /** @brief 质心偏移装饰形状 */
    | OffsetCenterOfMass
    /** @brief 网格形状 */
    | MeshSub
    /** @brief 高度场形状 */
    | HeightFieldSub
    /** @brief 软体形状 */
    | SoftBodySub

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Sphere => 0
            case Box => 1
            case Triangle => 2
            case Capsule => 3
            case TaperedCapsule => 4
            case Cylinder => 5
            case ConvexHull => 6
            case StaticCompound => 7
            case MutableCompound => 8
            case RotatedTranslated => 9
            case Scaled => 10
            case OffsetCenterOfMass => 11
            case MeshSub => 12
            case HeightFieldSub => 13
            case SoftBodySub => 14
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 SoftBodySub） */
    public static func fromValue(v: UInt32): ShapeSubType {
        match (v) {
            case 0 => Sphere
            case 1 => Box
            case 2 => Triangle
            case 3 => Capsule
            case 4 => TaperedCapsule
            case 5 => Cylinder
            case 6 => ConvexHull
            case 7 => StaticCompound
            case 8 => MutableCompound
            case 9 => RotatedTranslated
            case 10 => Scaled
            case 11 => OffsetCenterOfMass
            case 12 => MeshSub
            case 13 => HeightFieldSub
            case _ => SoftBodySub
        }
    }
}

// =============================================================================
// 枚举：约束类型 / 约束子类型 / 约束空间
// =============================================================================

/**
 * @brief 约束大类（对应 JPH_ConstraintType）
 */
public enum ConstraintType {
    /** @brief 单刚体约束 */
    | Constraint
    /** @brief 双刚体约束（连接两个刚体） */
    | TwoBodyConstraint

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Constraint => 0
            case TwoBodyConstraint => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Constraint） */
    public static func fromValue(v: UInt32): ConstraintType {
        match (v) {
            case 0 => Constraint
            case _ => TwoBodyConstraint
        }
    }
}

/**
 * @brief 约束子类型（对应 JPH_ConstraintSubType）
 * @explain 具体约束类型，JPH_Constraint_GetSubType 的返回值。
 */
public enum ConstraintSubType {
    /** @brief 固定约束（焊接两刚体，无相对运动） */
    | Fixed
    /** @brief 点约束（球关节，共享一个锚点） */
    | Point
    /** @brief 铰链约束（绕单轴旋转，可限位/带电机） */
    | Hinge
    /** @brief 滑块约束（沿单轴平移，可限位/带电机） */
    | Slider
    /** @brief 距离约束（保持两刚体固定距离，可带弹簧） */
    | Distance
    /** @brief 锥约束（锥角限制的球关节） */
    | Cone
    /** @brief 摆动-扭转约束（肩/髋关节） */
    | SwingTwist
    /** @brief 六自由度约束（每轴可 Free/Limited/Locked + Motor） */
    | SixDOF
    /** @brief 路径约束（沿样条路径运动） */
    | Path
    /** @brief 车辆约束（车轮/悬挂系统） */
    | Vehicle
    /** @brief 齿轮齿条约束 */
    | RackAndPinion
    /** @brief 齿轮约束（比例耦合两铰链旋转） */
    | Gear
    /** @brief 滑轮约束 */
    | Pulley
    /** @brief 用户自定义约束 1 */
    | User1
    /** @brief 用户自定义约束 2 */
    | User2
    /** @brief 用户自定义约束 3 */
    | User3
    /** @brief 用户自定义约束 4 */
    | User4

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Fixed => 0
            case Point => 1
            case Hinge => 2
            case Slider => 3
            case Distance => 4
            case Cone => 5
            case SwingTwist => 6
            case SixDOF => 7
            case Path => 8
            case Vehicle => 9
            case RackAndPinion => 10
            case Gear => 11
            case Pulley => 12
            case User1 => 13
            case User2 => 14
            case User3 => 15
            case User4 => 16
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 User4） */
    public static func fromValue(v: UInt32): ConstraintSubType {
        match (v) {
            case 0 => Fixed
            case 1 => Point
            case 2 => Hinge
            case 3 => Slider
            case 4 => Distance
            case 5 => Cone
            case 6 => SwingTwist
            case 7 => SixDOF
            case 8 => Path
            case 9 => Vehicle
            case 10 => RackAndPinion
            case 11 => Gear
            case 12 => Pulley
            case 13 => User1
            case 14 => User2
            case 15 => User3
            case _ => User4
        }
    }
}

/**
 * @brief 约束空间（对应 JPH_ConstraintSpace）
 * @explain 决定约束锚点/轴的定义空间：
 *         - LocalToBodyCOM：锚点/轴定义在刚体质心局部坐标系；
 *         - WorldSpace：锚点/轴定义在世界坐标系。
 */
public enum ConstraintSpace {
    /** @brief 局部到质心空间（锚点相对质心） */
    | LocalToBodyCOM
    /** @brief 世界空间（锚点为世界坐标） */
    | WorldSpace

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case LocalToBodyCOM => 0
            case WorldSpace => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 LocalToBodyCOM） */
    public static func fromValue(v: UInt32): ConstraintSpace {
        match (v) {
            case 0 => LocalToBodyCOM
            case _ => WorldSpace
        }
    }
}

// =============================================================================
// 枚举：质量覆盖方式 / 允许自由度 / 地面状态
// =============================================================================

/**
 * @brief 质量属性覆盖方式（对应 JPH_OverrideMassProperties）
 * @explain 决定刚体创建时质量/惯量如何确定。
 */
public enum OverrideMassProperties {
    /** @brief 由形状计算质量与惯量 */
    | CalculateMassAndInertia
    /** @brief 由形状计算惯量，质量用 massPropertiesOverride.mass */
    | CalculateInertia
    /** @brief 质量与惯量均由 massPropertiesOverride 提供 */
    | MassAndInertiaProvided

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case CalculateMassAndInertia => 0
            case CalculateInertia => 1
            case MassAndInertiaProvided => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 CalculateMassAndInertia） */
    public static func fromValue(v: UInt32): OverrideMassProperties {
        match (v) {
            case 0 => CalculateMassAndInertia
            case 1 => CalculateInertia
            case _ => MassAndInertiaProvided
        }
    }
}

/**
 * @brief 允许的自由度（对应 JPH_AllowedDOFs，位掩码）
 * @explain 控制刚体可参与模拟的自由度组合，位可组合。
 */
public enum AllowedDOFs {
    /** @brief 全部自由度（平移 + 旋转） */
    | All
    /** @brief X 轴平移 */
    | TranslationX
    /** @brief Y 轴平移 */
    | TranslationY
    /** @brief Z 轴平移 */
    | TranslationZ
    /** @brief X 轴旋转 */
    | RotationX
    /** @brief Y 轴旋转 */
    | RotationY
    /** @brief Z 轴旋转 */
    | RotationZ
    /** @brief 2D 平面运动（XY 平移 + Z 旋转） */
    | Plane2D

    /** @brief 将枚举值转换为 UInt32（C ABI 位掩码值） */
    public func value(): UInt32 {
        match (this) {
            case All => 0b111111
            case TranslationX => 0b000001
            case TranslationY => 0b000010
            case TranslationZ => 0b000100
            case RotationX => 0b001000
            case RotationY => 0b010000
            case RotationZ => 0b100000
            case Plane2D => 0b100111  // TranslationX | TranslationY | RotationZ
        }
    }

    /** @brief 从 UInt32 位掩码判断是否包含该自由度 */
    public func isSet(mask: UInt32): Bool {
        (mask & value()) != 0
    }
}

/**
 * @brief 角色地面状态（对应 JPH_GroundState）
 */
public enum GroundState {
    /** @brief 在地面上 */
    | OnGround
    /** @brief 在陡坡上（超过最大坡度角） */
    | OnSteepGround
    /** @brief 不受支撑（悬空但有接触体） */
    | NotSupported
    /** @brief 在空中（无接触） */
    | InAir

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case OnGround => 0
            case OnSteepGround => 1
            case NotSupported => 2
            case InAir => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 InAir） */
    public static func fromValue(v: UInt32): GroundState {
        match (v) {
            case 0 => OnGround
            case 1 => OnSteepGround
            case 2 => NotSupported
            case _ => InAir
        }
    }
}

// =============================================================================
// 枚举：背面模式 / 活动边模式 / 面收集模式
// =============================================================================

/**
 * @brief 背面面处理模式（对应 JPH_BackFaceMode）
 * @explain 决定三角形网格/高度场的背面是否参与碰撞。
 */
public enum BackFaceMode {
    /** @brief 忽略背面（默认，避免从内部碰撞） */
    | IgnoreBackFaces
    /** @brief 背面也参与碰撞 */
    | CollideWithBackFaces

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case IgnoreBackFaces => 0
            case CollideWithBackFaces => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 IgnoreBackFaces） */
    public static func fromValue(v: UInt32): BackFaceMode {
        match (v) {
            case 0 => IgnoreBackFaces
            case _ => CollideWithBackFaces
        }
    }
}

/**
 * @brief 活动边模式（对应 JPH_ActiveEdgeMode）
 * @explain 决定移动物体是否只与活动边碰撞（活动边 = 移动物体应撞击的边）。
 */
public enum ActiveEdgeMode {
    /** @brief 只与活动边碰撞（默认） */
    | CollideOnlyWithActive
    /** @brief 与所有边碰撞 */
    | CollideWithAll

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case CollideOnlyWithActive => 0
            case CollideWithAll => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 CollideOnlyWithActive） */
    public static func fromValue(v: UInt32): ActiveEdgeMode {
        match (v) {
            case 0 => CollideOnlyWithActive
            case _ => CollideWithAll
        }
    }
}

/**
 * @brief 面收集模式（对应 JPH_CollectFacesMode）
 * @explain 决定碰撞查询是否收集接触面（用于计算接触流形）。
 */
public enum CollectFacesMode {
    /** @brief 收集接触面（用于流形构建） */
    | CollectFaces
    /** @brief 不收集面（仅碰撞点，更快） */
    | NoFaces

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case CollectFaces => 0
            case NoFaces => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 NoFaces） */
    public static func fromValue(v: UInt32): CollectFacesMode {
        match (v) {
            case 0 => CollectFaces
            case _ => NoFaces
        }
    }
}

// =============================================================================
// 枚举：电机状态 / 碰撞收集器类型 / 摆动类型
// =============================================================================

/**
 * @brief 电机状态（对应 JPH_MotorState）
 * @explain 约束电机的控制模式。
 */
public enum MotorState {
    /** @brief 电机关闭 */
    | Off
    /** @brief 速度控制（维持指定速度） */
    | Velocity
    /** @brief 位置控制（驱动到指定位置/角度） */
    | Position

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Off => 0
            case Velocity => 1
            case Position => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Off） */
    public static func fromValue(v: UInt32): MotorState {
        match (v) {
            case 0 => Off
            case 1 => Velocity
            case _ => Position
        }
    }
}

/**
 * @brief 碰撞收集器类型（对应 JPH_CollisionCollectorType）
 * @explain 决定碰撞查询收集结果的策略。
 */
public enum CollisionCollectorType {
    /** @brief 收集全部命中（未排序） */
    | AllHit
    /** @brief 收集全部命中并按距离排序 */
    | AllHitSorted
    /** @brief 收集最近命中 */
    | ClosestHit
    /** @brief 任意命中即返回 */
    | AnyHit

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case AllHit => 0
            case AllHitSorted => 1
            case ClosestHit => 2
            case AnyHit => 3
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 AllHit） */
    public static func fromValue(v: UInt32): CollisionCollectorType {
        match (v) {
            case 0 => AllHit
            case 1 => AllHitSorted
            case 2 => ClosestHit
            case _ => AnyHit
        }
    }
}

/**
 * @brief 摆动类型（对应 JPH_SwingType）
 * @explain SwingTwist/SixDOF 约束的摆动限位形状。
 */
public enum SwingType {
    /** @brief 锥形限位（圆锥摆动范围） */
    | Cone
    /** @brief 金字塔形限位（两轴独立限位） */
    | Pyramid

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Cone => 0
            case Pyramid => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Cone） */
    public static func fromValue(v: UInt32): SwingType {
        match (v) {
            case 0 => Cone
            case _ => Pyramid
        }
    }
}

// =============================================================================
// 枚举：六自由度约束轴 / 弹簧模式
// =============================================================================

/**
 * @brief 六自由度约束轴（对应 JPH_SixDOFConstraintAxis）
 */
public enum SixDOFConstraintAxis {
    /** @brief X 轴平移 */
    | TranslationX
    /** @brief Y 轴平移 */
    | TranslationY
    /** @brief Z 轴平移 */
    | TranslationZ
    /** @brief X 轴旋转 */
    | RotationX
    /** @brief Y 轴旋转 */
    | RotationY
    /** @brief Z 轴旋转 */
    | RotationZ

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case TranslationX => 0
            case TranslationY => 1
            case TranslationZ => 2
            case RotationX => 3
            case RotationY => 4
            case RotationZ => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 RotationZ） */
    public static func fromValue(v: UInt32): SixDOFConstraintAxis {
        match (v) {
            case 0 => TranslationX
            case 1 => TranslationY
            case 2 => TranslationZ
            case 3 => RotationX
            case 4 => RotationY
            case _ => RotationZ
        }
    }
}

/**
 * @brief 弹簧模式（对应 JPH_SpringMode）
 * @explain 决定弹簧参数解释方式：
 *         - FrequencyAndDamping：频率(Hz) + 阻尼比；
 *         - StiffnessAndDamping：刚度(N/m) + 阻尼系数。
 */
public enum SpringMode {
    /** @brief 频率 + 阻尼比模式 */
    | FrequencyAndDamping
    /** @brief 刚度 + 阻尼系数模式 */
    | StiffnessAndDamping

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case FrequencyAndDamping => 0
            case StiffnessAndDamping => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 FrequencyAndDamping） */
    public static func fromValue(v: UInt32): SpringMode {
        match (v) {
            case 0 => FrequencyAndDamping
            case _ => StiffnessAndDamping
        }
    }
}

// =============================================================================
// 枚举：软体约束颜色 / 软体弯曲类型
// =============================================================================

/**
 * @brief 软体约束着色方案（对应 JPH_SoftBodyConstraintColor，调试用）
 */
public enum SoftBodyConstraintColor {
    /** @brief 不同类型约束不同颜色 */
    | ConstraintType
    /** @brief 同组约束同色，非平行组为红色 */
    | ConstraintGroup
    /** @brief 同组约束同色，组内顺序用渐变表示 */
    | ConstraintOrder

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case ConstraintType => 0
            case ConstraintGroup => 1
            case ConstraintOrder => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 ConstraintOrder） */
    public static func fromValue(v: UInt32): SoftBodyConstraintColor {
        match (v) {
            case 0 => ConstraintType
            case 1 => ConstraintGroup
            case _ => ConstraintOrder
        }
    }
}

/**
 * @brief 软体弯曲约束类型（对应 JPH_SoftBodyBendType）
 */
public enum SoftBodyBendType {
    /** @brief 无弯曲约束 */
    | None
    /** @brief 距离式弯曲约束 */
    | Distance
    /** @brief 二面角式弯曲约束 */
    | Dihedral

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case None => 0
            case Distance => 1
            case Dihedral => 2
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Dihedral） */
    public static func fromValue(v: UInt32): SoftBodyBendType {
        match (v) {
            case 0 => None
            case 1 => Distance
            case _ => Dihedral
        }
    }
}

// =============================================================================
// 枚举：刚体管理器着色 / 调试渲染器
// =============================================================================

/**
 * @brief 刚体管理器形状着色方案（对应 JPH_BodyManager_ShapeColor，调试用）
 */
public enum BodyManagerShapeColor {
    /** @brief 每个实例随机颜色 */
    | InstanceColor
    /** @brief 按形状类型着色（凸=绿/缩放=黄/复合=橙/网格=红） */
    | ShapeTypeColor
    /** @brief 按运动类型着色（静态=灰/运动学=绿/动态=随机） */
    | MotionTypeColor
    /** @brief 按休眠状态着色（静态=灰/运动学=绿/动态=黄/休眠=红） */
    | SleepColor
    /** @brief 按岛着色（静态=灰/活动=随机/休眠=浅灰） */
    | IslandColor
    /** @brief 按物理材质颜色着色 */
    | MaterialColor

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case InstanceColor => 0
            case ShapeTypeColor => 1
            case MotionTypeColor => 2
            case SleepColor => 3
            case IslandColor => 4
            case MaterialColor => 5
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 MaterialColor） */
    public static func fromValue(v: UInt32): BodyManagerShapeColor {
        match (v) {
            case 0 => InstanceColor
            case 1 => ShapeTypeColor
            case 2 => MotionTypeColor
            case 3 => SleepColor
            case 4 => IslandColor
            case _ => MaterialColor
        }
    }
}

/**
 * @brief 调试渲染投影模式（对应 JPH_DebugRenderer_CastShadow）
 */
public enum DebugRendererCastShadow {
    /** @brief 投射阴影 */
    | On
    /** @brief 不投射阴影 */
    | Off

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case On => 0
            case Off => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 On） */
    public static func fromValue(v: UInt32): DebugRendererCastShadow {
        match (v) {
            case 0 => On
            case _ => Off
        }
    }
}

/**
 * @brief 调试渲染绘制模式（对应 JPH_DebugRenderer_DrawMode）
 */
public enum DebugRendererDrawMode {
    /** @brief 实体绘制 */
    | Solid
    /** @brief 线框绘制 */
    | Wireframe

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Solid => 0
            case Wireframe => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Solid） */
    public static func fromValue(v: UInt32): DebugRendererDrawMode {
        match (v) {
            case 0 => Solid
            case _ => Wireframe
        }
    }
}

// =============================================================================
// 枚举：网格构建质量 / 变速箱模式 / 履带侧
// =============================================================================

/**
 * @brief 网格形状构建质量（对应 JPH_Mesh_Shape_BuildQuality）
 */
public enum MeshShapeBuildQuality {
    /** @brief 优先运行时性能（构建慢但查询快） */
    | FavorRuntimePerformance
    /** @brief 优先构建速度（构建快但查询稍慢） */
    | FavorBuildSpeed

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case FavorRuntimePerformance => 0
            case FavorBuildSpeed => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 FavorRuntimePerformance） */
    public static func fromValue(v: UInt32): MeshShapeBuildQuality {
        match (v) {
            case 0 => FavorRuntimePerformance
            case _ => FavorBuildSpeed
        }
    }
}

/**
 * @brief 变速箱模式（对应 JPH_TransmissionMode）
 */
public enum TransmissionMode {
    /** @brief 自动挡（根据转速自动换挡） */
    | Auto
    /** @brief 手动挡（用户控制换挡） */
    | Manual

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Auto => 0
            case Manual => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Auto） */
    public static func fromValue(v: UInt32): TransmissionMode {
        match (v) {
            case 0 => Auto
            case _ => Manual
        }
    }
}

/**
 * @brief 履带侧（对应 JPH_TrackSide，用于履带车辆）
 */
public enum TrackSide {
    /** @brief 左侧履带 */
    | Left
    /** @brief 右侧履带 */
    | Right

    /** @brief 将枚举值转换为 UInt32（C ABI 兼容值） */
    public func value(): UInt32 {
        match (this) {
            case Left => 0
            case Right => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值（未知值归为 Left） */
    public static func fromValue(v: UInt32): TrackSide {
        match (v) {
            case 0 => Left
            case _ => Right
        }
    }
}

// =============================================================================
// @C 结构体：向量 / 四元数
// =============================================================================

/**
 * @brief 三维向量（对应 JPH_Vec3，浮点单精度）
 * @explain 与 C 布局一致（3 个 float），用于位置、速度、方向等参数。
 * @note joltc.h 中 JPH_RVec3（双精度世界坐标）在默认构建下就是 JPH_Vec3。
 */
@C
public struct JPHVec3 {
    /** @brief X 分量 */
    public var x: Float32 = 0.0f32
    /** @brief Y 分量 */
    public var y: Float32 = 0.0f32
    /** @brief Z 分量 */
    public var z: Float32 = 0.0f32

    public init() {}

    /**
     * @brief 用三个分量构造向量
     * @param x X 分量
     * @param y Y 分量
     * @param z Z 分量
     */
    public init(x!: Float32, y!: Float32, z!: Float32) {
        this.x = x
        this.y = y
        this.z = z
    }
}

/**
 * @brief 四元数（对应 JPH_Quat，浮点单精度）
 * @explain 与 C 布局一致（4 个 float：x, y, z, w），用于旋转。
 *         单位四元数 (0, 0, 0, 1) 表示无旋转。
 */
@C
public struct JPHQuat {
    /** @brief X 分量 */
    public var x: Float32 = 0.0f32
    /** @brief Y 分量 */
    public var y: Float32 = 0.0f32
    /** @brief Z 分量 */
    public var z: Float32 = 0.0f32
    /** @brief W 分量（实部） */
    public var w: Float32 = 1.0f32

    public init() {}

    /**
     * @brief 用四个分量构造四元数
     * @param x X 分量
     * @param y Y 分量
     * @param z Z 分量
     * @param w W 分量（实部）
     */
    public init(x!: Float32, y!: Float32, z!: Float32, w!: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }
}

// =============================================================================
// @C 结构体：射线命中结果
// =============================================================================

/**
 * @brief C 布局射线命中结果（对应 JPH_RayCastResult）
 * @explain 用于 JPH_NarrowPhaseQuery_CastRay 的输出参数：配合 LibC.malloc
 *         分配 CPointer<JPHRayCastResult> 传入 foreign 函数，命中后通过
 *         `ptr.read()` 读取。字段布局与 C 侧完全一致，请勿改动顺序。
 * @note 命中点位置 = origin + direction * fraction，法线需另行查询。
 */
@C
public struct JPHRayCastResult {
    /** @brief 被命中刚体的 BodyID */
    public var bodyID: UInt32 = 0
    /** @brief 命中比例 0..1（沿射线方向） */
    public var fraction: Float32 = 0.0f32
    /** @brief 命中的子形状 ID（复合形状内部标识） */
    public var subShapeID2: UInt32 = 0

    public init() {}
}

// =============================================================================
// @C 结构体：作业系统线程池配置
// =============================================================================

/**
 * @brief 作业系统线程池配置（对应 JobSystemThreadPoolConfig）
 * @explain 用于 JPH_JobSystemThreadPool_Create 的参数：maxJobs 最大作业数
 *         （参考 JPH_MAX_PHYSICS_JOBS）、maxBarriers 最大屏障数（参考
 *         JPH_MAX_PHYSICS_BARRIERS）、numThreads 线程数（0 = 单线程，
 *         -1 = 全核数减一）。
 */
@C
public struct JobSystemThreadPoolConfig {
    /** @brief 最大作业数（参考 JPH_MAX_PHYSICS_JOBS = 2048） */
    public var maxJobs: UInt32 = 2048
    /** @brief 最大屏障数（参考 JPH_MAX_PHYSICS_BARRIERS = 8） */
    public var maxBarriers: UInt32 = 8
    /** @brief 线程数（0 = 单线程；-1 = 硬件并发数 - 1） */
    public var numThreads: Int32 = -1

    public init() {}

    /**
     * @brief 显式配置作业系统线程池
     * @param maxJobs 最大作业数
     * @param maxBarriers 最大屏障数
     * @param numThreads 线程数
     */
    public init(maxJobs!: UInt32, maxBarriers!: UInt32, numThreads!: Int32) {
        this.maxJobs = maxJobs
        this.maxBarriers = maxBarriers
        this.numThreads = numThreads
    }
}

// =============================================================================
// @C 结构体：物理系统设置
// =============================================================================

/**
 * @brief 物理系统设置（对应 JPH_PhysicsSystemSettings）
 * @explain 用于 JPH_PhysicsSystem_Create 的参数：指定容量上限与层过滤对象。
 *         层过滤对象（broadPhaseLayerInterface / objectLayerPairFilter /
 *         objectVsBroadPhaseLayerFilter）由相应 Table 系列函数创建，
 *         系统持有其引用，须在系统销毁后销毁。
 * @note _padding 字段保持与 C 结构体 4 字节对齐一致，勿改动。
 */
@C
public struct JPHPhysicsSystemSettings {
    /** @brief 世界最多刚体数（如 65536） */
    public var maxBodies: UInt32 = 65536
    /** @brief 刚体并发访问互斥锁数量（0 = 使用默认值） */
    public var numBodyMutexes: UInt32 = 0
    /** @brief BroadPhase 排队的最多刚体对数（如 65536） */
    public var maxBodyPairs: UInt32 = 65536
    /** @brief 最多同时接触约束数（如 10240，太小物体会穿透） */
    public var maxContactConstraints: UInt32 = 10240
    /** @brief 对齐填充（勿修改） */
    public var _padding: UInt32 = 0
    /** @brief 对象层 -> BroadPhase 层映射接口（JPH_BroadPhaseLayerInterfaceTable_Create 创建） */
    public var broadPhaseLayerInterface: CPointer<Unit> = CPointer<Unit>()
    /** @brief 对象层两两碰撞过滤（JPH_ObjectLayerPairFilterTable_Create 创建） */
    public var objectLayerPairFilter: CPointer<Unit> = CPointer<Unit>()
    /** @brief 对象层 vs BroadPhase 层碰撞过滤（JPH_ObjectVsBroadPhaseLayerFilterTable_Create 创建） */
    public var objectVsBroadPhaseLayerFilter: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

// =============================================================================
// @C 结构体：向量 / 矩阵 / 平面（数学基础）
// =============================================================================

/**
 * @brief 四维向量（对应 JPH_Vec4）
 */
@C
public struct JPHVec4 {
    /** @brief X 分量 */
    public var x: Float32 = 0.0f32
    /** @brief Y 分量 */
    public var y: Float32 = 0.0f32
    /** @brief Z 分量 */
    public var z: Float32 = 0.0f32
    /** @brief W 分量 */
    public var w: Float32 = 0.0f32

    public init() {}

    /**
     * @brief 用四个分量构造向量
     */
    public init(x!: Float32, y!: Float32, z!: Float32, w!: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }
}

/**
 * @brief 平面（对应 JPH_Plane，法线 + 距离）
 */
@C
public struct JPHPlane {
    /** @brief 平面法线（单位向量） */
    public var normal: JPHVec3 = JPHVec3()
    /** @brief 平面到原点的距离 */
    public var distance: Float32 = 0.0f32

    public init() {}

    /**
     * @brief 用法线和距离构造平面
     */
    public init(normal!: JPHVec3, distance!: Float32) {
        this.normal = normal
        this.distance = distance
    }
}

/**
 * @brief 4x4 矩阵（对应 JPH_Mat4，按列存储）
 */
@C
public struct JPHMat4 {
    /** @brief 4 个列向量 */
    public var column = VArray<JPHVec4, $4>(repeat: JPHVec4())

    public init() {}

    /**
     * @brief 用 4 个列向量构造矩阵
     */
    public init(c0!: JPHVec4, c1!: JPHVec4, c2!: JPHVec4, c3!: JPHVec4) {
        this.column = VArray<JPHVec4, $4>(repeat: JPHVec4())
        this.column[0] = c0
        this.column[1] = c1
        this.column[2] = c2
        this.column[3] = c3
    }
}

/**
 * @brief 2D 点（对应 JPH_Point）
 */
@C
public struct JPHPoint {
    /** @brief X 分量 */
    public var x: Float32 = 0.0f32
    /** @brief Y 分量 */
    public var y: Float32 = 0.0f32

    public init() {}

    public init(x!: Float32, y!: Float32) {
        this.x = x
        this.y = y
    }
}

/**
 * @brief 轴对齐包围盒（对应 JPH_AABox）
 */
@C
public struct JPHAABox {
    /** @brief 最小角点 */
    public var min: JPHVec3 = JPHVec3()
    /** @brief 最大角点 */
    public var max: JPHVec3 = JPHVec3()

    public init() {}

    public init(min!: JPHVec3, max!: JPHVec3) {
        this.min = min
        this.max = max
    }
}

/**
 * @brief 三角形（对应 JPH_Triangle）
 */
@C
public struct JPHTriangle {
    /** @brief 顶点 1 */
    public var v1: JPHVec3 = JPHVec3()
    /** @brief 顶点 2 */
    public var v2: JPHVec3 = JPHVec3()
    /** @brief 顶点 3 */
    public var v3: JPHVec3 = JPHVec3()
    /** @brief 材质索引 */
    public var materialIndex: UInt32 = 0

    public init() {}

    public init(v1!: JPHVec3, v2!: JPHVec3, v3!: JPHVec3, materialIndex!: UInt32) {
        this.v1 = v1
        this.v2 = v2
        this.v3 = v3
        this.materialIndex = materialIndex
    }
}

/**
 * @brief 无材质索引三角形（对应 JPH_IndexedTriangleNoMaterial）
 */
@C
public struct JPHIndexedTriangleNoMaterial {
    /** @brief 顶点索引 1 */
    public var i1: UInt32 = 0
    /** @brief 顶点索引 2 */
    public var i2: UInt32 = 0
    /** @brief 顶点索引 3 */
    public var i3: UInt32 = 0

    public init() {}

    public init(i1!: UInt32, i2!: UInt32, i3!: UInt32) {
        this.i1 = i1
        this.i2 = i2
        this.i3 = i3
    }
}

/**
 * @brief 带材质索引的三角形（对应 JPH_IndexedTriangle）
 */
@C
public struct JPHIndexedTriangle {
    /** @brief 顶点索引 1 */
    public var i1: UInt32 = 0
    /** @brief 顶点索引 2 */
    public var i2: UInt32 = 0
    /** @brief 顶点索引 3 */
    public var i3: UInt32 = 0
    /** @brief 材质索引 */
    public var materialIndex: UInt32 = 0
    /** @brief 用户数据 */
    public var userData: UInt32 = 0

    public init() {}

    public init(i1!: UInt32, i2!: UInt32, i3!: UInt32,
                materialIndex!: UInt32, userData!: UInt32) {
        this.i1 = i1
        this.i2 = i2
        this.i3 = i3
        this.materialIndex = materialIndex
        this.userData = userData
    }
}

/**
 * @brief 质量属性（对应 JPH_MassProperties）
 */
@C
public struct JPHMassProperties {
    /** @brief 质量（千克） */
    public var mass: Float32 = 0.0f32
    /** @brief 惯性张量（3x3 矩阵，存于 4x4 左上角） */
    public var inertia: JPHMat4 = JPHMat4()

    public init() {}

    public init(mass!: Float32, inertia!: JPHMat4) {
        this.mass = mass
        this.inertia = inertia
    }
}

/**
 * @brief 软体顶点（对应 JPH_SoftVertex）
 */
@C
public struct JPHSoftVertex {
    /** @brief 位置 */
    public var position: JPHVec3 = JPHVec3()
    /** @brief 速度 */
    public var velocity: JPHVec3 = JPHVec3()
    /** @brief 逆质量（1/mass，0 = 固定点） */
    public var invMass: Float32 = 0.0f32

    public init() {}

    public init(position!: JPHVec3, velocity!: JPHVec3, invMass!: Float32) {
        this.position = position
        this.velocity = velocity
        this.invMass = invMass
    }
}

/**
 * @brief 软体面（对应 JPH_SoftFace）
 * @explain 软体网格由顶点与面组成，面引用 3 个顶点索引。
 */
@C
public struct JPHSoftFace {
    /** @brief 顶点 1 索引 */
    public var vertex1: UInt32 = 0
    /** @brief 顶点 2 索引 */
    public var vertex2: UInt32 = 0
    /** @brief 顶点 3 索引 */
    public var vertex3: UInt32 = 0
    /** @brief 材质索引 */
    public var materialIndex: UInt32 = 0

    public init() {}

    public init(vertex1!: UInt32, vertex2!: UInt32, vertex3!: UInt32,
                materialIndex!: UInt32) {
        this.vertex1 = vertex1
        this.vertex2 = vertex2
        this.vertex3 = vertex3
        this.materialIndex = materialIndex
    }
}

/**
 * @brief 接触设置（对应 JPH_ContactSettings）
 * @explain 接触监听器 OnContactAdded/Persisted 回调中修改的接触参数。
 */
@C
public struct JPHContactSettings {
    /** @brief 组合摩擦系数（两刚体摩擦的组合值） */
    public var combinedFriction: Float32 = 0.0f32
    /** @brief 组合弹性系数 */
    public var combinedRestitution: Float32 = 0.0f32
    /** @brief 刚体 1 的逆质量缩放（1 = 正常，0 = 不可推动） */
    public var invMassScale1: Float32 = 1.0f32
    /** @brief 刚体 1 的逆惯量缩放 */
    public var invInertiaScale1: Float32 = 1.0f32
    /** @brief 刚体 2 的逆质量缩放 */
    public var invMassScale2: Float32 = 1.0f32
    /** @brief 刚体 2 的逆惯量缩放 */
    public var invInertiaScale2: Float32 = 1.0f32
    /** @brief 是否传感器（JPH_Bool，非 0 = 传感器） */
    public var isSensor: UInt32 = 0
    /** @brief 接触面相对线性表面速度 */
    public var relativeLinearSurfaceVelocity: JPHVec3 = JPHVec3()
    /** @brief 接触面相对角速度 */
    public var relativeAngularSurfaceVelocity: JPHVec3 = JPHVec3()

    public init() {}
}

// =============================================================================
// @C 结构体：碰撞设置基类 / 派生
// =============================================================================

/**
 * @brief 碰撞设置基类（对应 JPH_CollideSettingsBase）
 * @explain CollideShapeSettings / ShapeCastSettings 的公共基类。
 */
@C
public struct JPHCollideSettingsBase {
    /** @brief 活动边模式（ActiveEdgeMode 枚举值） */
    public var activeEdgeMode: UInt32 = 0
    /** @brief 面收集模式（CollectFacesMode 枚举值） */
    public var collectFacesMode: UInt32 = 1
    /** @brief 碰撞容差（默认 JPH_DEFAULT_COLLISION_TOLERANCE，米） */
    public var collisionTolerance: Float32 = 1.0e-4f32
    /** @brief 穿透深度计算精度容差 */
    public var penetrationTolerance: Float32 = 1.0e-4f32
    /** @brief 活动边模式下的移动方向 */
    public var activeEdgeMovementDirection: JPHVec3 = JPHVec3()

    public init() {}
}

/**
 * @brief 形状碰撞设置（对应 JPH_CollideShapeSettings）
 */
@C
public struct JPHCollideShapeSettings {
    /** @brief 基类字段 */
    public var base: JPHCollideSettingsBase = JPHCollideSettingsBase()
    /** @brief 最大分离距离（>0 时收集附近接触，米） */
    public var maxSeparationDistance: Float32 = 0.0f32
    /** @brief 背面面处理模式（BackFaceMode 枚举值） */
    public var backFaceMode: UInt32 = 0

    public init() {}
}

/**
 * @brief 形状投射设置（对应 JPH_ShapeCastSettings）
 */
@C
public struct JPHShapeCastSettings {
    /** @brief 基类字段 */
    public var base: JPHCollideSettingsBase = JPHCollideSettingsBase()
    /** @brief 三角形背面处理模式（BackFaceMode 枚举值） */
    public var backFaceModeTriangles: UInt32 = 0
    /** @brief 凸形状背面处理模式 */
    public var backFaceModeConvex: UInt32 = 0
    /** @brief 是否用收缩形状 + 凸半径（更快、更圆润） */
    public var useShrunkenShapeAndConvexRadius: Bool = false
    /** @brief 起始即相交时是否计算最深穿透点（更慢） */
    public var returnDeepestPoint: Bool = false

    public init() {}
}

/**
 * @brief 射线投射设置（对应 JPH_RayCastSettings）
 */
@C
public struct JPHRayCastSettings {
    /** @brief 三角形背面处理模式（BackFaceMode 枚举值） */
    public var backFaceModeTriangles: UInt32 = 0
    /** @brief 凸形状背面处理模式 */
    public var backFaceModeConvex: UInt32 = 0
    /** @brief 凸形状是否视为实心（内部起点的射线在 fraction=0 处命中） */
    public var treatConvexAsSolid: Bool = true

    public init() {}
}

/**
 * @brief 弹簧设置（对应 JPH_SpringSettings）
 * @explain 由 SpringMode 决定参数解释：频率+阻尼比 或 刚度+阻尼系数。
 */
@C
public struct JPHSpringSettings {
    /** @brief 弹簧模式（SpringMode 枚举值） */
    public var mode: UInt32 = 0
    /** @brief 频率（Hz）或刚度（N/m） */
    public var frequencyOrStiffness: Float32 = 0.0f32
    /** @brief 阻尼比（0~1）或阻尼系数 */
    public var damping: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 电机设置（对应 JPH_MotorSettings）
 */
@C
public struct JPHMotorSettings {
    /** @brief 电机弹簧参数 */
    public var springSettings: JPHSpringSettings = JPHSpringSettings()
    /** @brief 最小力限制（牛顿） */
    public var minForceLimit: Float32 = -1.0e30f32
    /** @brief 最大力限制（牛顿） */
    public var maxForceLimit: Float32 = 1.0e30f32
    /** @brief 最小扭矩限制（牛顿·米） */
    public var minTorqueLimit: Float32 = -1.0e30f32
    /** @brief 最大扭矩限制（牛顿·米） */
    public var maxTorqueLimit: Float32 = 1.0e30f32

    public init() {}
}

// =============================================================================
// @C 结构体：碰撞查询结果
// =============================================================================

/**
 * @brief 子形状 ID 对（对应 JPH_SubShapeIDPair）
 */
@C
public struct JPHSubShapeIDPair {
    /** @brief 刚体 1 的 BodyID */
    public var body1ID: UInt32 = 0
    /** @brief 刚体 1 的子形状 ID */
    public var subShapeID1: UInt32 = 0
    /** @brief 刚体 2 的 BodyID */
    public var body2ID: UInt32 = 0
    /** @brief 刚体 2 的子形状 ID */
    public var subShapeID2: UInt32 = 0

    public init() {}
}

/**
 * @brief 宽相位投射结果（对应 JPH_BroadPhaseCastResult）
 */
@C
public struct JPHBroadPhaseCastResult {
    /** @brief 被命中刚体的 BodyID */
    public var bodyID: UInt32 = 0
    /** @brief 命中比例 0..1 */
    public var fraction: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 碰撞点查询结果（对应 JPH_CollidePointResult）
 */
@C
public struct JPHCollidePointResult {
    /** @brief 被命中刚体的 BodyID */
    public var bodyID: UInt32 = 0
    /** @brief 命中的子形状 ID */
    public var subShapeID2: UInt32 = 0

    public init() {}
}

/**
 * @brief 形状碰撞结果（对应 JPH_CollideShapeResult）
 */
@C
public struct JPHCollideShapeResult {
    /** @brief 查询形状上的接触点（世界空间） */
    public var contactPointOn1: JPHVec3 = JPHVec3()
    /** @brief 被撞形状上的接触点（世界空间） */
    public var contactPointOn2: JPHVec3 = JPHVec3()
    /** @brief 穿透轴方向（从形状 2 指向形状 1） */
    public var penetrationAxis: JPHVec3 = JPHVec3()
    /** @brief 穿透深度（米） */
    public var penetrationDepth: Float32 = 0.0f32
    /** @brief 查询形状的子形状 ID */
    public var subShapeID1: UInt32 = 0
    /** @brief 被撞形状的子形状 ID */
    public var subShapeID2: UInt32 = 0
    /** @brief 被撞刚体的 BodyID */
    public var bodyID2: UInt32 = 0
    /** @brief 形状 1 的接触面数量 */
    public var shape1FaceCount: UInt32 = 0
    /** @brief 形状 1 的接触面顶点指针（LibC.malloc 分配） */
    public var shape1Faces: CPointer<JPHVec3> = CPointer<JPHVec3>()
    /** @brief 形状 2 的接触面数量 */
    public var shape2FaceCount: UInt32 = 0
    /** @brief 形状 2 的接触面顶点指针（LibC.malloc 分配） */
    public var shape2Faces: CPointer<JPHVec3> = CPointer<JPHVec3>()

    public init() {}
}

/**
 * @brief 形状投射结果（对应 JPH_ShapeCastResult）
 */
@C
public struct JPHShapeCastResult {
    /** @brief 查询形状上的接触点 */
    public var contactPointOn1: JPHVec3 = JPHVec3()
    /** @brief 被撞形状上的接触点 */
    public var contactPointOn2: JPHVec3 = JPHVec3()
    /** @brief 穿透轴方向 */
    public var penetrationAxis: JPHVec3 = JPHVec3()
    /** @brief 穿透深度 */
    public var penetrationDepth: Float32 = 0.0f32
    /** @brief 查询形状的子形状 ID */
    public var subShapeID1: UInt32 = 0
    /** @brief 被撞形状的子形状 ID */
    public var subShapeID2: UInt32 = 0
    /** @brief 被撞刚体的 BodyID */
    public var bodyID2: UInt32 = 0
    /** @brief 投射比例 0..1 */
    public var fraction: Float32 = 0.0f32
    /** @brief 是否为背面命中 */
    public var isBackFaceHit: Bool = false

    public init() {}
}

/**
 * @brief 支撑面（对应 JPH_SupportingFace）
 */
@C
public struct JPHSupportingFace {
    /** @brief 顶点数量（最多 32） */
    public var count: UInt32 = 0
    /** @brief 支撑面顶点数组 */
    public var vertices = VArray<JPHVec3, $32>(repeat: JPHVec3())

    public init() {}
}

/**
 * @brief 碰撞组（对应 JPH_CollisionGroup）
 * @explain 用于组过滤（GroupFilter）的碰撞分组信息。
 */
@C
public struct JPHCollisionGroup {
    /** @brief 组过滤对象句柄（JPH_GroupFilterTable_Create 创建） */
    public var groupFilter: CPointer<Unit> = CPointer<Unit>()
    /** @brief 组 ID */
    public var groupID: UInt32 = 0
    /** @brief 子组 ID */
    public var subGroupID: UInt32 = 0

    public init() {}
}

/**
 * @brief 碰撞估计结果（对应 JPH_CollisionEstimationResult）
 * @explain 描述两个刚体碰撞时的冲量/速度估计，用于接触求解分析。
 */
@C
public struct JPHCollisionEstimationResult {
    /** @brief 刚体 1 的线速度估计 */
    public var linearVelocity1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的角速度估计 */
    public var angularVelocity1: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的线速度估计 */
    public var linearVelocity2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的角速度估计 */
    public var angularVelocity2: JPHVec3 = JPHVec3()
    /** @brief 摩擦点 */
    public var frictionPoint: JPHVec3 = JPHVec3()
    /** @brief 切向 1 */
    public var tangent1: JPHVec3 = JPHVec3()
    /** @brief 切向 2 */
    public var tangent2: JPHVec3 = JPHVec3()
    /** @brief 摩擦冲量 1 */
    public var frictionImpulse1: Float32 = 0.0f32
    /** @brief 摩擦冲量 2 */
    public var frictionImpulse2: Float32 = 0.0f32
    /** @brief 角摩擦冲量 */
    public var angularFrictionImpulse: Float32 = 0.0f32
    /** @brief 接触冲量数量 */
    public var contactImpulseCount: UInt32 = 0
    /** @brief 接触冲量数组指针 */
    public var contactImpulses: CPointer<Float32> = CPointer<Float32>()

    public init() {}
}

// =============================================================================
// @C 结构体：约束设置
// =============================================================================

/**
 * @brief 约束设置基类（对应 JPH_ConstraintSettings）
 * @explain 所有约束 Settings 的公共基类字段。
 */
@C
public struct JPHConstraintSettings {
    /** @brief 约束是否启用 */
    public var enabled: Bool = true
    /** @brief 约束优先级（影响求解顺序） */
    public var constraintPriority: UInt32 = 0
    /** @brief 速度迭代步数覆盖（0 = 使用全局默认） */
    public var numVelocityStepsOverride: UInt32 = 0
    /** @brief 位置迭代步数覆盖（0 = 使用全局默认） */
    public var numPositionStepsOverride: UInt32 = 0
    /** @brief 调试绘制约束尺寸 */
    public var drawConstraintSize: Float32 = 0.0f32
    /** @brief 用户数据 */
    public var userData: UInt64 = 0

    public init() {}
}

/**
 * @brief 固定约束设置（对应 JPH_FixedConstraintSettings）
 * @explain 将两个刚体焊接在一起，无相对运动。
 */
@C
public struct JPHFixedConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 自动检测锚点（基于两刚体质心） */
    public var autoDetectPoint: Bool = false
    /** @brief 刚体 1 上的锚点（世界/局部坐标，依 space） */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的 X 轴 */
    public var axisX1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 1 的 Y 轴 */
    public var axisY1: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的 X 轴 */
    public var axisX2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 的 Y 轴 */
    public var axisY2: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)

    public init() {}
}

/**
 * @brief 距离约束设置（对应 JPH_DistanceConstraintSettings）
 * @explain 保持两刚体锚点间距离在 [minDistance, maxDistance] 内，可带弹簧。
 */
@C
public struct JPHDistanceConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()
    /** @brief 最小距离（米） */
    public var minDistance: Float32 = 0.0f32
    /** @brief 最大距离（米） */
    public var maxDistance: Float32 = 0.0f32
    /** @brief 限位弹簧设置 */
    public var limitsSpringSettings: JPHSpringSettings = JPHSpringSettings()

    public init() {}
}

/**
 * @brief 点约束设置（对应 JPH_PointConstraintSettings）
 * @explain 球关节：两刚体共享一个锚点，可自由旋转。
 */
@C
public struct JPHPointConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()

    public init() {}
}

/**
 * @brief 铰链约束设置（对应 JPH_HingeConstraintSettings）
 * @explain 合页：绕单轴旋转，可设角度限位、弹簧、摩擦扭矩与电机。
 */
@C
public struct JPHHingeConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的铰链轴 */
    public var hingeAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 1 的法线轴 */
    public var normalAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的铰链轴 */
    public var hingeAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 的法线轴 */
    public var normalAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 最小旋转角度限位（弧度） */
    public var limitsMin: Float32 = 0.0f32
    /** @brief 最大旋转角度限位（弧度） */
    public var limitsMax: Float32 = 0.0f32
    /** @brief 限位弹簧设置 */
    public var limitsSpringSettings: JPHSpringSettings = JPHSpringSettings()
    /** @brief 最大摩擦扭矩（牛顿·米） */
    public var maxFrictionTorque: Float32 = 0.0f32
    /** @brief 电机设置 */
    public var motorSettings: JPHMotorSettings = JPHMotorSettings()

    public init() {}
}

/**
 * @brief 滑块约束设置（对应 JPH_SliderConstraintSettings）
 * @explain 滑轨：沿单轴平移，可设位置限位、弹簧、摩擦与电机。
 */
@C
public struct JPHSliderConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 自动检测锚点 */
    public var autoDetectPoint: Bool = false
    /** @brief 刚体 1 上的锚点 */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的滑动轴 */
    public var sliderAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 1 的法线轴 */
    public var normalAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的滑动轴 */
    public var sliderAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 的法线轴 */
    public var normalAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 最小位置限位（米） */
    public var limitsMin: Float32 = 0.0f32
    /** @brief 最大位置限位（米） */
    public var limitsMax: Float32 = 0.0f32
    /** @brief 限位弹簧设置 */
    public var limitsSpringSettings: JPHSpringSettings = JPHSpringSettings()
    /** @brief 最大摩擦力（牛顿） */
    public var maxFrictionForce: Float32 = 0.0f32
    /** @brief 电机设置 */
    public var motorSettings: JPHMotorSettings = JPHMotorSettings()

    public init() {}
}

/**
 * @brief 锥约束设置（对应 JPH_ConeConstraintSettings）
 * @explain 锥角限制的球关节：绕 twist 轴自由旋转，但偏离轴的角度受限。
 */
@C
public struct JPHConeConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var point1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的扭转轴 */
    public var twistAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var point2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的扭转轴 */
    public var twistAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 半锥角（弧度，0 = 无摆动） */
    public var halfConeAngle: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 摆动-扭转约束设置（对应 JPH_SwingTwistConstraintSettings）
 * @explain 肩/髋关节：摆动（锥形）+ 扭转（绕轴旋转）均可限位，可带电机。
 */
@C
public struct JPHSwingTwistConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var position1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的扭转轴 */
    public var twistAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 1 的平面轴 */
    public var planeAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var position2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的扭转轴 */
    public var twistAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 的平面轴 */
    public var planeAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 摆动类型（SwingType 枚举值） */
    public var swingType: UInt32 = 0
    /** @brief 法线方向半锥角（弧度） */
    public var normalHalfConeAngle: Float32 = 0.0f32
    /** @brief 平面方向半锥角（弧度） */
    public var planeHalfConeAngle: Float32 = 0.0f32
    /** @brief 最小扭转角（弧度） */
    public var twistMinAngle: Float32 = 0.0f32
    /** @brief 最大扭转角（弧度） */
    public var twistMaxAngle: Float32 = 0.0f32
    /** @brief 最大摩擦扭矩 */
    public var maxFrictionTorque: Float32 = 0.0f32
    /** @brief 摆动电机设置 */
    public var swingMotorSettings: JPHMotorSettings = JPHMotorSettings()
    /** @brief 扭转电机设置 */
    public var twistMotorSettings: JPHMotorSettings = JPHMotorSettings()

    public init() {}
}

/**
 * @brief 六自由度约束设置（对应 JPH_SixDOFConstraintSettings）
 * @explain 最通用的约束：6 个轴（3 平移 + 3 旋转）各自可 Free/Limited/Locked，
 *         每轴可带限位弹簧与电机。
 */
@C
public struct JPHSixDOFConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 上的锚点 */
    public var position1: JPHVec3 = JPHVec3()
    /** @brief 刚体 1 的 X 轴 */
    public var axisX1: JPHVec3 = JPHVec3(x: 1.0f32, y: 0.0f32, z: 0.0f32)
    /** @brief 刚体 1 的 Y 轴 */
    public var axisY1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 上的锚点 */
    public var position2: JPHVec3 = JPHVec3()
    /** @brief 刚体 2 的 X 轴 */
    public var axisX2: JPHVec3 = JPHVec3(x: 1.0f32, y: 0.0f32, z: 0.0f32)
    /** @brief 刚体 2 的 Y 轴 */
    public var axisY2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 各轴最大摩擦（6 轴） */
    public var maxFriction = VArray<Float32, $6>(repeat: 0.0f32)
    /** @brief 摆动类型（SwingType 枚举值） */
    public var swingType: UInt32 = 0
    /** @brief 各轴最小限位（6 轴，弧度或米） */
    public var limitMin = VArray<Float32, $6>(repeat: 0.0f32)
    /** @brief 各轴最大限位（6 轴，弧度或米） */
    public var limitMax = VArray<Float32, $6>(repeat: 0.0f32)
    /** @brief 平移轴限位弹簧设置（3 轴） */
    public var limitsSpringSettings = VArray<JPHSpringSettings, $3>(repeat: JPHSpringSettings())
    /** @brief 各轴电机设置（6 轴） */
    public var motorSettings = VArray<JPHMotorSettings, $6>(repeat: JPHMotorSettings())

    public init() {}
}

/**
 * @brief 齿轮约束设置（对应 JPH_GearConstraintSettings）
 * @explain 以固定比例耦合两个铰链的旋转（如齿轮传动）。
 */
@C
public struct JPHGearConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 约束空间（ConstraintSpace 枚举值） */
    public var space: UInt32 = 0
    /** @brief 刚体 1 的铰链轴 */
    public var hingeAxis1: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 刚体 2 的铰链轴 */
    public var hingeAxis2: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 齿轮比例（旋转角之比） */
    public var ratio: Float32 = 1.0f32

    public init() {}
}

// =============================================================================
// @C 结构体：刚体锁 / 物理设置 / 步进监听器
// =============================================================================

/**
 * @brief 刚体只读锁（对应 JPH_BodyLockRead）
 * @explain 从 BodyLockInterface 获取，锁定期间刚体数据只读安全。
 */
@C
public struct JPHBodyLockRead {
    /** @brief 锁接口句柄 */
    public var lockInterface: CPointer<Unit> = CPointer<Unit>()
    /** @brief 共享互斥锁句柄 */
    public var mutex: CPointer<Unit> = CPointer<Unit>()
    /** @brief 被锁刚体句柄（空 = 锁失败/刚体不存在） */
    public var body: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

/**
 * @brief 刚体写锁（对应 JPH_BodyLockWrite）
 * @explain 从 BodyLockInterface 获取，锁定期间刚体数据可读写安全。
 */
@C
public struct JPHBodyLockWrite {
    /** @brief 锁接口句柄 */
    public var lockInterface: CPointer<Unit> = CPointer<Unit>()
    /** @brief 共享互斥锁句柄 */
    public var mutex: CPointer<Unit> = CPointer<Unit>()
    /** @brief 被锁刚体句柄（空 = 锁失败/刚体不存在） */
    public var body: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

/**
 * @brief 物理系统设置（对应 JPH_PhysicsSettings）
 * @explain 物理模拟求解器参数，通过 JPH_PhysicsSystem_SetPhysicsSettings 应用。
 */
@C
public struct JPHPhysicsSettings {
    /** @brief 在飞刚体对的最大数量 */
    public var maxInFlightBodyPairs: Int32 = 16384
    /** @brief 步进监听器批量大小 */
    public var stepListenersBatchSize: Int32 = 1000
    /** @brief 每作业的步进监听器批次数 */
    public var stepListenerBatchesPerJob: Int32 = 10
    /** @brief 位置误差修正系数（baumgarte 稳定化） */
    public var baumgarte: Float32 = 0.2f32
    /** @brief 推测接触距离（米） */
    public var speculativeContactDistance: Float32 = 0.05f32
    /** @brief 穿透坡度（米） */
    public var penetrationSlop: Float32 = 0.02f32
    /** @brief 线性投射阈值 */
    public var linearCastThreshold: Float32 = 0.8f32
    /** @brief 线性投射最大穿透 */
    public var linearCastMaxPenetration: Float32 = 0.25f32
    /** @brief 流形容差 */
    public var manifoldTolerance: Float32 = 0.01f32
    /** @brief 最大穿透距离 */
    public var maxPenetrationDistance: Float32 = 0.02f32
    /** @brief 刚体对缓存最大位置增量平方 */
    public var bodyPairCacheMaxDeltaPositionSq: Float32 = 0.001f32
    /** @brief 刚体对缓存最大旋转增量余弦/2 */
    public var bodyPairCacheCosMaxDeltaRotationDiv2: Float32 = 0.99984769515639123916f32
    /** @brief 接触法线最大旋转增量余弦 */
    public var contactNormalCosMaxDeltaRotation: Float32 = 0.99984769515639123916f32
    /** @brief 接触点保 lambda 最大距离平方 */
    public var contactPointPreserveLambdaMaxDistSq: Float32 = 0.001f32
    /** @brief 速度迭代步数 */
    public var numVelocitySteps: UInt32 = 10
    /** @brief 位置迭代步数 */
    public var numPositionSteps: UInt32 = 2
    /** @brief 弹性所需最小速度 */
    public var minVelocityForRestitution: Float32 = 1.0f32
    /** @brief 休眠前时间（秒） */
    public var timeBeforeSleep: Float32 = 0.5f32
    /** @brief 点速度休眠阈值 */
    public var pointVelocitySleepThreshold: Float32 = 0.15f32
    /** @brief 确定性模拟 */
    public var deterministicSimulation: Bool = true
    /** @brief 约束热启动 */
    public var constraintWarmStart: Bool = true
    /** @brief 使用刚体对接触缓存 */
    public var useBodyPairContactCache: Bool = true
    /** @brief 使用流形简化 */
    public var useManifoldReduction: Bool = true
    /** @brief 使用大岛分裂器 */
    public var useLargeIslandSplitter: Bool = true
    /** @brief 允许休眠 */
    public var allowSleeping: Bool = true
    /** @brief 检查活动边 */
    public var checkActiveEdges: Bool = true

    public init() {}
}

/**
 * @brief 步进监听器上下文（对应 JPH_PhysicsStepListenerContext）
 * @explain 每次物理步进前回调 OnStep 时传入的上下文。
 */
@C
public struct JPHPhysicsStepListenerContext {
    /** @brief 本步时间增量（秒） */
    public var deltaTime: Float32 = 0.0f32
    /** @brief 是否第一步（JPH_Bool） */
    public var isFirstStep: UInt32 = 0
    /** @brief 是否最后一步（JPH_Bool） */
    public var isLastStep: UInt32 = 0
    /** @brief 物理系统句柄 */
    public var physicsSystem: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

// =============================================================================
// @C 结构体：角色控制器设置
// =============================================================================

/**
 * @brief 角色基类设置（对应 JPH_CharacterBaseSettings）
 */
@C
public struct JPHCharacterBaseSettings {
    /** @brief 角色上方向（世界空间） */
    public var up: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 支撑体平面（判定站立用） */
    public var supportingVolume: JPHPlane = JPHPlane()
    /** @brief 最大可站立坡度角（弧度，默认 45°） */
    public var maxSlopeAngle: Float32 = 0.78539816339744830962f32
    /** @brief 增强内部边移除 */
    public var enhancedInternalEdgeRemoval: Bool = false
    /** @brief 角色碰撞形状句柄 */
    public var shape: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

/**
 * @brief 角色设置（对应 JPH_CharacterSettings，非虚拟角色）
 */
@C
public struct JPHCharacterSettings {
    /** @brief 基类字段 */
    public var base: JPHCharacterBaseSettings = JPHCharacterBaseSettings()
    /** @brief 对象层 */
    public var layer: UInt32 = 0
    /** @brief 质量（千克） */
    public var mass: Float32 = 80.0f32
    /** @brief 摩擦系数 */
    public var friction: Float32 = 0.2f32
    /** @brief 重力因子（1 = 正常重力） */
    public var gravityFactor: Float32 = 1.0f32
    /** @brief 允许自由度（AllowedDOFs 位掩码） */
    public var allowedDOFs: UInt32 = 0b111111

    public init() {}
}

/**
 * @brief 虚拟角色设置（对应 JPH_CharacterVirtualSettings）
 * @explain 推荐用于角色控制器：不直接受力，由用户控制移动。
 */
@C
public struct JPHCharacterVirtualSettings {
    /** @brief 基类字段 */
    public var base: JPHCharacterBaseSettings = JPHCharacterBaseSettings()
    /** @brief 角色 ID */
    public var id: UInt32 = 0
    /** @brief 质量（千克，用于冲量计算） */
    public var mass: Float32 = 70.0f32
    /** @brief 最大推力（牛顿） */
    public var maxStrength: Float32 = 100.0f32
    /** @brief 形状偏移 */
    public var shapeOffset: JPHVec3 = JPHVec3()
    /** @brief 背面面处理模式（BackFaceMode 枚举值） */
    public var backFaceMode: UInt32 = 0
    /** @brief 预测接触距离（米） */
    public var predictiveContactDistance: Float32 = 0.1f32
    /** @brief 最大碰撞迭代次数 */
    public var maxCollisionIterations: UInt32 = 5
    /** @brief 最大约束迭代次数 */
    public var maxConstraintIterations: UInt32 = 15
    /** @brief 最小剩余时间 */
    public var minTimeRemaining: Float32 = 1.0e-5f32
    /** @brief 碰撞容差 */
    public var collisionTolerance: Float32 = 1.0e-3f32
    /** @brief 角色填充（米，防视觉穿插） */
    public var characterPadding: Float32 = 0.02f32
    /** @brief 最大命中数 */
    public var maxNumHits: UInt32 = 256
    /** @brief 命中约简最大角余弦 */
    public var hitReductionCosMaxAngle: Float32 = 0.99f32
    /** @brief 穿透恢复速度 */
    public var penetrationRecoverySpeed: Float32 = 1.0f32
    /** @brief 内部刚体形状句柄 */
    public var innerBodyShape: CPointer<Unit> = CPointer<Unit>()
    /** @brief 内部刚体 BodyID 覆盖 */
    public var innerBodyIDOverride: UInt32 = 0xFFFFFFFF
    /** @brief 内部刚体对象层 */
    public var innerBodyLayer: UInt32 = 0

    public init() {}
}

/**
 * @brief 角色接触设置（对应 JPH_CharacterContactSettings）
 */
@C
public struct JPHCharacterContactSettings {
    /** @brief 接触体是否可推动角色 */
    public var canPushCharacter: Bool = true
    /** @brief 角色是否可接收冲量 */
    public var canReceiveImpulses: Bool = true

    public init() {}
}

/**
 * @brief 角色接触信息（对应 JPH_CharacterContact）
 * @explain 虚拟角色接触回调中描述一次接触。
 */
@C
public struct JPHCharacterContact {
    /** @brief 接触哈希 */
    public var hash: UInt64 = 0
    /** @brief 接触刚体 BodyID */
    public var bodyB: UInt32 = 0
    /** @brief 接触角色 ID */
    public var characterIDB: UInt32 = 0
    /** @brief 接触子形状 ID */
    public var subShapeIDB: UInt32 = 0
    /** @brief 接触位置（世界坐标） */
    public var position: JPHVec3 = JPHVec3()
    /** @brief 接触点线速度 */
    public var linearVelocity: JPHVec3 = JPHVec3()
    /** @brief 接触法线 */
    public var contactNormal: JPHVec3 = JPHVec3()
    /** @brief 表面法线 */
    public var surfaceNormal: JPHVec3 = JPHVec3()
    /** @brief 接触距离（<0 穿透） */
    public var distance: Float32 = 0.0f32
    /** @brief 接触比例 */
    public var fraction: Float32 = 0.0f32
    /** @brief 接触刚体运动类型（MotionType 枚举值） */
    public var motionTypeB: UInt32 = 0
    /** @brief 接触刚体是否传感器 */
    public var isSensorB: Bool = false
    /** @brief 接触角色句柄（角色间接触时有效） */
    public var characterB: CPointer<Unit> = CPointer<Unit>()
    /** @brief 用户数据 */
    public var userData: UInt64 = 0
    /** @brief 接触材质句柄 */
    public var material: CPointer<Unit> = CPointer<Unit>()
    /** @brief 是否发生碰撞 */
    public var hadCollision: Bool = false
    /** @brief 是否被丢弃 */
    public var wasDiscarded: Bool = false
    /** @brief 是否可推动角色 */
    public var canPushCharacter: Bool = true
    /** @brief 是否为背面接触 */
    public var isBackFacingContact: Bool = false

    public init() {}
}

/**
 * @brief 角色扩展更新设置（对应 JPH_ExtendedUpdateSettings）
 * @explain 虚拟角色 ExtendedUpdate 的额外参数（贴地/上楼/下楼）。
 */
@C
public struct JPHExtendedUpdateSettings {
    /** @brief 贴地下降步长 */
    public var stickToFloorStepDown: JPHVec3 = JPHVec3()
    /** @brief 上台阶步长 */
    public var walkStairsStepUp: JPHVec3 = JPHVec3()
    /** @brief 上台阶最小前进距离 */
    public var walkStairsMinStepForward: Float32 = 0.0f32
    /** @brief 上台阶前进测试距离 */
    public var walkStairsStepForwardTest: Float32 = 0.0f32
    /** @brief 上台阶前进接触最大角度余弦 */
    public var walkStairsCosAngleForwardContact: Float32 = 0.0f32
    /** @brief 下台阶额外步长 */
    public var walkStairsStepDownExtra: JPHVec3 = JPHVec3()

    public init() {}
}

// =============================================================================
// @C 结构体：骨骼关节 / 车辆
// =============================================================================

/**
 * @brief 骨骼关节（对应 JPH_SkeletonJoint）
 */
@C
public struct JPHSkeletonJoint {
    /** @brief 关节名称（C 字符串指针） */
    public var name: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 父关节名称（C 字符串指针，根关节为空） */
    public var parentName: CPointer<UInt8> = CPointer<UInt8>()
    /** @brief 父关节索引（-1 = 根关节） */
    public var parentJointIndex: Int32 = -1

    public init() {}
}

/**
 * @brief 车辆防倾杆（对应 JPH_VehicleAntiRollBar）
 */
@C
public struct JPHVehicleAntiRollBar {
    /** @brief 左轮索引 */
    public var leftWheel: Int32 = -1
    /** @brief 右轮索引 */
    public var rightWheel: Int32 = -1
    /** @brief 刚度 */
    public var stiffness: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 车辆约束设置（对应 JPH_VehicleConstraintSettings）
 */
@C
public struct JPHVehicleConstraintSettings {
    /** @brief 基类字段 */
    public var base: JPHConstraintSettings = JPHConstraintSettings()
    /** @brief 车辆上方向（世界空间） */
    public var up: JPHVec3 = JPHVec3(x: 0.0f32, y: 1.0f32, z: 0.0f32)
    /** @brief 车辆前进方向（世界空间） */
    public var forward: JPHVec3 = JPHVec3(x: 0.0f32, y: 0.0f32, z: 1.0f32)
    /** @brief 最大俯仰/横滚角（弧度） */
    public var maxPitchRollAngle: Float32 = 0.0f32
    /** @brief 车轮数量 */
    public var wheelsCount: UInt32 = 0
    /** @brief 车轮设置指针数组（JPH_WheelSettings**） */
    public var wheels: CPointer<Unit> = CPointer<Unit>()
    /** @brief 防倾杆数量 */
    public var antiRollBarsCount: UInt32 = 0
    /** @brief 防倾杆数组指针 */
    public var antiRollBars: CPointer<JPHVehicleAntiRollBar> = CPointer<JPHVehicleAntiRollBar>()
    /** @brief 控制器设置句柄 */
    public var controller: CPointer<Unit> = CPointer<Unit>()

    public init() {}
}

/**
 * @brief 车辆引擎设置（对应 JPH_VehicleEngineSettings）
 */
@C
public struct JPHVehicleEngineSettings {
    /** @brief 最大扭矩（牛顿·米） */
    public var maxTorque: Float32 = 0.0f32
    /** @brief 最小 RPM */
    public var minRPM: Float32 = 0.0f32
    /** @brief 最大 RPM */
    public var maxRPM: Float32 = 0.0f32
    /** @brief 归一化扭矩曲线句柄（JPH_LinearCurve） */
    public var normalizedTorque: CPointer<Unit> = CPointer<Unit>()
    /** @brief 转动惯量 */
    public var inertia: Float32 = 0.0f32
    /** @brief 角阻尼 */
    public var angularDamping: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 车辆差速器设置（对应 JPH_VehicleDifferentialSettings）
 */
@C
public struct JPHVehicleDifferentialSettings {
    /** @brief 左轮索引 */
    public var leftWheel: Int32 = -1
    /** @brief 右轮索引 */
    public var rightWheel: Int32 = -1
    /** @brief 差速比 */
    public var differentialRatio: Float32 = 0.0f32
    /** @brief 左右分配比（0.5 = 平均） */
    public var leftRightSplit: Float32 = 0.5f32
    /** @brief 限滑比 */
    public var limitedSlipRatio: Float32 = 0.0f32
    /** @brief 引擎扭矩比 */
    public var engineTorqueRatio: Float32 = 0.0f32

    public init() {}
}

/**
 * @brief 车辆履带设置（对应 JPH_VehicleTrackSettings）
 */
@C
public struct JPHVehicleTrackSettings {
    /** @brief 驱动轮索引 */
    public var drivenWheel: UInt32 = 0
    /** @brief 履带车轮索引数组指针 */
    public var wheels: CPointer<UInt32> = CPointer<UInt32>()
    /** @brief 履带车轮数量 */
    public var wheelsCount: UInt32 = 0
    /** @brief 转动惯量 */
    public var inertia: Float32 = 0.0f32
    /** @brief 角阻尼 */
    public var angularDamping: Float32 = 0.0f32
    /** @brief 最大制动力矩 */
    public var maxBrakeTorque: Float32 = 0.0f32
    /** @brief 差速比 */
    public var differentialRatio: Float32 = 0.0f32

    public init() {}
}

// =============================================================================
// @C 结构体：调试绘制设置 / 作业系统配置
// =============================================================================

/**
 * @brief 调试绘制设置（对应 JPH_DrawSettings）
 * @explain JPH_PhysicsSystem_DrawBodies 的绘制选项。
 */
@C
public struct JPHDrawSettings {
    /** @brief 绘制 GetSupport 函数（凸碰撞检测用） */
    public var drawGetSupportFunction: Bool = false
    /** @brief 绘制支撑方向 */
    public var drawSupportDirection: Bool = false
    /** @brief 绘制碰撞检测找到的面 */
    public var drawGetSupportingFace: Bool = false
    /** @brief 绘制所有刚体的形状 */
    public var drawShape: Bool = false
    /** @brief 线框绘制形状（需 drawShape=true） */
    public var drawShapeWireframe: Bool = false
    /** @brief 形状着色方案（BodyManagerShapeColor 枚举值） */
    public var drawShapeColor: UInt32 = 0
    /** @brief 每个刚体绘制包围盒 */
    public var drawBoundingBox: Bool = false
    /** @brief 每个刚体绘制质心 */
    public var drawCenterOfMassTransform: Bool = false
    /** @brief 绘制世界变换（可能不同于质心变换） */
    public var drawWorldTransform: Bool = false
    /** @brief 绘制速度向量 */
    public var drawVelocity: Bool = false
    /** @brief 绘制质量与惯量（等效盒） */
    public var drawMassAndInertia: Bool = false
    /** @brief 绘制休眠统计 */
    public var drawSleepStats: Bool = false
    /** @brief 绘制软体顶点 */
    public var drawSoftBodyVertices: Bool = false
    /** @brief 绘制软体顶点速度 */
    public var drawSoftBodyVertexVelocities: Bool = false
    /** @brief 绘制软体边约束 */
    public var drawSoftBodyEdgeConstraints: Bool = false
    /** @brief 绘制软体弯曲约束 */
    public var drawSoftBodyBendConstraints: Bool = false
    /** @brief 绘制软体体积约束 */
    public var drawSoftBodyVolumeConstraints: Bool = false
    /** @brief 绘制软体蒙皮约束 */
    public var drawSoftBodySkinConstraints: Bool = false
    /** @brief 绘制软体 LRA 约束 */
    public var drawSoftBodyLRAConstraints: Bool = false
    /** @brief 绘制软体预测边界 */
    public var drawSoftBodyPredictedBounds: Bool = false
    /** @brief 软体约束着色方案（SoftBodyConstraintColor 枚举值） */
    public var drawSoftBodyConstraintColor: UInt32 = 0

    public init() {}
}

/**
 * @brief 作业系统配置（对应 JPH_JobSystemConfig）
 * @explain 自定义作业系统：通过回调把作业排队到用户的线程池。
 */
@C
public struct JPHJobSystemConfig {
    /** @brief 用户上下文 */
    public var context: CPointer<Unit> = CPointer<Unit>()
    /** @brief 单个作业排队回调 queueJob(context, job, arg) */
    public var queueJob: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>) -> Unit>(CPointer<Unit>())
    /** @brief 批量作业排队回调 queueJobs(context, job, args, count) */
    public var queueJobs: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, UInt32) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, UInt32) -> Unit>(CPointer<Unit>())
    /** @brief 最大并发作业数 */
    public var maxConcurrency: UInt32 = 0
    /** @brief 最大屏障数 */
    public var maxBarriers: UInt32 = 0

    public init() {}
}

// =============================================================================
// @C 结构体：监听器回调表（_Procs）
// =============================================================================

/**
 * @brief 步进监听器回调表（对应 JPH_PhysicsStepListener_Procs）
 * @explain 物理系统每步进一次调用 OnStep。
 */
@C
public struct JPHPhysicsStepListenerProcs {
    /** @brief 步进回调 OnStep(userData, context) */
    public var onStep: CFunc<(CPointer<Unit>, CPointer<JPHPhysicsStepListenerContext>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<JPHPhysicsStepListenerContext>) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 宽相位层过滤回调表（对应 JPH_BroadPhaseLayerFilter_Procs）
 */
@C
public struct JPHBroadPhaseLayerFilterProcs {
    /** @brief 层碰撞判定 ShouldCollide(userData, layer) -> bool */
    public var shouldCollide: CFunc<(CPointer<Unit>, UInt8) -> Bool> =
        CFunc<(CPointer<Unit>, UInt8) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 对象层过滤回调表（对应 JPH_ObjectLayerFilter_Procs）
 */
@C
public struct JPHObjectLayerFilterProcs {
    /** @brief 层碰撞判定 ShouldCollide(userData, layer) -> bool */
    public var shouldCollide: CFunc<(CPointer<Unit>, UInt32) -> Bool> =
        CFunc<(CPointer<Unit>, UInt32) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 刚体过滤回调表（对应 JPH_BodyFilter_Procs）
 */
@C
public struct JPHBodyFilterProcs {
    /** @brief 刚体碰撞判定 ShouldCollide(userData, bodyID) -> bool */
    public var shouldCollide: CFunc<(CPointer<Unit>, UInt32) -> Bool> =
        CFunc<(CPointer<Unit>, UInt32) -> Bool>(CPointer<Unit>())
    /** @brief 锁定刚体碰撞判定 ShouldCollideLocked(userData, body) -> bool */
    public var shouldCollideLocked: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 形状过滤回调表（对应 JPH_ShapeFilter_Procs）
 */
@C
public struct JPHShapeFilterProcs {
    /** @brief 双形状碰撞判定 ShouldCollide(userData, shape2, subShapeID2) -> bool */
    public var shouldCollide: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>) -> Bool>(CPointer<Unit>())
    /** @brief 双形状双子ID碰撞判定 ShouldCollide2(userData, shape1, subShapeID1, shape2, subShapeID2) -> bool */
    public var shouldCollide2: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>, CPointer<Unit>, CPointer<UInt32>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>, CPointer<Unit>, CPointer<UInt32>) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 模拟形状过滤回调表（对应 JPH_SimShapeFilter_Procs）
 */
@C
public struct JPHSimShapeFilterProcs {
    /** @brief 双刚体形状碰撞判定 ShouldCollide(userData, body1, shape1, subShapeID1, body2, shape2, subShapeID2) -> bool */
    public var shouldCollide: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>, CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>, CPointer<Unit>, CPointer<Unit>, CPointer<UInt32>) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 接触监听器回调表（对应 JPH_ContactListener_Procs）
 */
@C
public struct JPHContactListenerProcs {
    /** @brief 接触验证回调 OnContactValidate(userData, body1, body2, baseOffset, collisionResult) -> ValidateResult */
    public var onContactValidate: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHCollideShapeResult>) -> UInt32> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHCollideShapeResult>) -> UInt32>(CPointer<Unit>())
    /** @brief 接触建立回调 OnContactAdded(userData, body1, body2, manifold, settings) */
    public var onContactAdded: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHContactSettings>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHContactSettings>) -> Unit>(CPointer<Unit>())
    /** @brief 接触持续回调 OnContactPersisted(userData, body1, body2, manifold, settings) */
    public var onContactPersisted: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHContactSettings>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHContactSettings>) -> Unit>(CPointer<Unit>())
    /** @brief 接触移除回调 OnContactRemoved(userData, subShapePair) */
    public var onContactRemoved: CFunc<(CPointer<Unit>, CPointer<JPHSubShapeIDPair>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<JPHSubShapeIDPair>) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 刚体激活监听器回调表（对应 JPH_BodyActivationListener_Procs）
 */
@C
public struct JPHBodyActivationListenerProcs {
    /** @brief 刚体激活回调 OnBodyActivated(userData, bodyID, bodyUserData) */
    public var onBodyActivated: CFunc<(CPointer<Unit>, UInt32, UInt64) -> Unit> =
        CFunc<(CPointer<Unit>, UInt32, UInt64) -> Unit>(CPointer<Unit>())
    /** @brief 刚体休眠回调 OnBodyDeactivated(userData, bodyID, bodyUserData) */
    public var onBodyDeactivated: CFunc<(CPointer<Unit>, UInt32, UInt64) -> Unit> =
        CFunc<(CPointer<Unit>, UInt32, UInt64) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 刚体绘制过滤回调表（对应 JPH_BodyDrawFilter_Procs）
 */
@C
public struct JPHBodyDrawFilterProcs {
    /** @brief 刚体绘制判定 ShouldDraw(userData, body) -> bool */
    public var shouldDraw: CFunc<(CPointer<Unit>, CPointer<Unit>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>) -> Bool>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 角色接触监听器回调表（对应 JPH_CharacterContactListener_Procs）
 */
@C
public struct JPHCharacterContactListenerProcs {
    /** @brief 调整刚体速度回调 OnAdjustBodyVelocity(userData, character, body2, ioLinearVelocity, ioAngularVelocity) */
    public var onAdjustBodyVelocity: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>) -> Unit>(CPointer<Unit>())
    /** @brief 接触验证回调 OnContactValidate(userData, character, contact) -> bool */
    public var onContactValidate: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>) -> Bool> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>) -> Bool>(CPointer<Unit>())
    /** @brief 接触建立回调 OnContactAdded(userData, character, contact, ioSettings) */
    public var onContactAdded: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>, CPointer<JPHCharacterContactSettings>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>, CPointer<JPHCharacterContactSettings>) -> Unit>(CPointer<Unit>())
    /** @brief 接触持续回调 OnContactPersisted(userData, character, contact, ioSettings) */
    public var onContactPersisted: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>, CPointer<JPHCharacterContactSettings>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<JPHCharacterContact>, CPointer<JPHCharacterContactSettings>) -> Unit>(CPointer<Unit>())
    /** @brief 接触移除回调 OnContactRemoved(userData, character, bodyID2, subShapeID2) */
    public var onContactRemoved: CFunc<(CPointer<Unit>, CPointer<Unit>, UInt32, UInt32) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, UInt32, UInt32) -> Unit>(CPointer<Unit>())
    /** @brief 角色接触求解回调 OnContactSolve(userData, character, bodyID2, subShapeID2, contactPosition, contactNormal, contactVelocity, contactMaterial, characterVelocity, newCharacterVelocity) */
    public var onContactSolve: CFunc<(CPointer<Unit>, CPointer<Unit>, UInt32, UInt32, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, UInt32, UInt32, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 角色间碰撞回调表（对应 JPH_CharacterVsCharacterCollision_Procs）
 */
@C
public struct JPHCharacterVsCharacterCollisionProcs {
    /** @brief 角色碰撞回调 CollideCharacter(userData, character, centerOfMassTransform, collideShapeSettings, baseOffset) */
    public var collideCharacter: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHCollideShapeSettings>, CPointer<JPHVec3>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHCollideShapeSettings>, CPointer<JPHVec3>) -> Unit>(CPointer<Unit>())
    /** @brief 角色投射回调 CastCharacter(userData, character, centerOfMassTransform, direction, shapeCastSettings, baseOffset) */
    public var castCharacter: CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHShapeCastSettings>, CPointer<JPHVec3>) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<Unit>, CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHShapeCastSettings>, CPointer<JPHVec3>) -> Unit>(CPointer<Unit>())

    public init() {}
}

/**
 * @brief 调试渲染器回调表（对应 JPH_DebugRenderer_Procs）
 */
@C
public struct JPHDebugRendererProcs {
    /** @brief 绘制线段回调 DrawLine(userData, from, to, color) */
    public var drawLine: CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>, UInt32) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>, UInt32) -> Unit>(CPointer<Unit>())
    /** @brief 绘制三角形回调 DrawTriangle(userData, v1, v2, v3, color, castShadow) */
    public var drawTriangle: CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<JPHVec3>, UInt32, UInt32) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<JPHVec3>, CPointer<JPHVec3>, UInt32, UInt32) -> Unit>(CPointer<Unit>())
    /** @brief 绘制 3D 文本回调 DrawText3D(userData, position, str, color, height) */
    public var drawText3D: CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<UInt8>, UInt32, Float32) -> Unit> =
        CFunc<(CPointer<Unit>, CPointer<JPHVec3>, CPointer<UInt8>, UInt32, Float32) -> Unit>(CPointer<Unit>())

    public init() {}
}
