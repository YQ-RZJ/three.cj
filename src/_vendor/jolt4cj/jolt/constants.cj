/**
 * @file jolt4cj.jolt 常量定义
 * @brief joltc（JoltPhysics C API 包装层，cxx/joltc/include/joltc.h）的常量
 * @explain 本文件包含 joltc.h 中核心 #define 常量的仓颉版本。
 * @see cxx/joltc/include/joltc.h
 */
protected package three._vendor.jolt4cj.jolt

// =============================================================================
// 默认物理参数
// =============================================================================

/** @brief 默认碰撞容差（JPH_DEFAULT_COLLISION_TOLERANCE = 1.0e-4f） */
public const JPH_DEFAULT_COLLISION_TOLERANCE: Float32 = 1.0e-4f32
/** @brief 默认穿透容差（JPH_DEFAULT_PENETRATION_TOLERANCE = 1.0e-4f） */
public const JPH_DEFAULT_PENETRATION_TOLERANCE: Float32 = 1.0e-4f32
/** @brief 默认凸半径（JPH_DEFAULT_CONVEX_RADIUS = 0.05f），形状创建时凸半径 <=0 用此值 */
public const JPH_DEFAULT_CONVEX_RADIUS: Float32 = 0.05f32
/** @brief 胶囊投影斜率（JPH_CAPSULE_PROJECTION_SLOP = 0.02f） */
public const JPH_CAPSULE_PROJECTION_SLOP: Float32 = 0.02f32

// =============================================================================
// 作业系统上限（JobSystemThreadPool 默认配置参考值）
// =============================================================================

/** @brief 最大物理作业数（JPH_MAX_PHYSICS_JOBS = 2048） */
public const JPH_MAX_PHYSICS_JOBS: UInt32 = 2048
/** @brief 最大物理屏障数（JPH_MAX_PHYSICS_BARRIERS = 8） */
public const JPH_MAX_PHYSICS_BARRIERS: UInt32 = 8

// =============================================================================
// 碰撞组
// =============================================================================

/** @brief 无效碰撞组 ID（JPH_INVALID_COLLISION_GROUP_ID = ~0U） */
public const JPH_INVALID_COLLISION_GROUP_ID: UInt32 = 0xFFFFFFFF
/** @brief 无效碰撞子组 ID（JPH_INVALID_COLLISION_SUBGROUP_ID = ~0U） */
public const JPH_INVALID_COLLISION_SUBGROUP_ID: UInt32 = 0xFFFFFFFF

// =============================================================================
// 刚体 ID
// =============================================================================

/**
 * @brief 无效 BodyID（= 0xFFFFFFFF）
 * @explain 对应 Jolt 的 BodyID::cInvalidBodyID。JPH_BodyInterface_CreateAndAddBody_cj
 *         等创建接口失败时返回此值（而非 0），判断创建失败必须与它比较。
 */
public const JPH_BODY_ID_INVALID: UInt32 = 0xFFFFFFFF

// =============================================================================
// 数学常量
// =============================================================================

/** @brief 圆周率（JPH_M_PI = 3.14159265358979323846f） */
public const JPH_M_PI: Float32 = 3.14159265358979323846f32
