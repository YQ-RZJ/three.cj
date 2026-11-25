/**
 * @file jolt4cj.jolt CFFI 函数声明
 * @brief joltc（JoltPhysics C API 包装层，joltc.h）的 foreign 函数声明
 * @explain 本文件包含 joltc.h 中核心函数的 foreign 声明，覆盖 HelloWorld
 *         标准流程：全局初始化 -> 作业系统 -> 层过滤 -> 物理系统 -> 形状
 *         -> 刚体 -> 步进 -> 射线查询。
 *         物理系统/形状/刚体接口等为不透明句柄，使用 CPointer<Unit> 表示；
 *         刚体以 UInt32 BodyID 标识。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的
 *       `_cj` 后缀公共包装。
 * @see cxx/joltc/include/joltc.h
 */
protected package three._vendor.jolt4cj.jolt

// =============================================================================
// 生命周期：全局初始化 / 卸载（进程内只调用一次）
// =============================================================================

/** @brief 初始化 Jolt 全局状态（注册分配器/工厂/物理类型），返回 true 成功 */
@FastNative
foreign func JPH_Init(): UInt8

/** @brief 卸载 Jolt 全局状态（释放工厂并注销物理类型） */
@FastNative
foreign func JPH_Shutdown(): Unit

// =============================================================================
// 作业系统（JobSystem）
// =============================================================================

/**
 * @brief 创建线程池作业系统（Jolt 用多线程执行物理作业）
 * @param config 配置（可传空指针使用默认：2048 作业 / 8 屏障 / 全核数-1 线程）
 * @return 作业系统句柄；失败返回空指针
 */
foreign func JPH_JobSystemThreadPool_Create(config: CPointer<JobSystemThreadPoolConfig>): CPointer<Unit>

/** @brief 销毁作业系统 */
foreign func JPH_JobSystem_Destroy(jobSystem: CPointer<Unit>): Unit

// =============================================================================
// 层过滤（对象层 / BroadPhase 层）
// =============================================================================

/**
 * @brief 创建对象层两两碰撞过滤表
 * @param numObjectLayers 对象层数量（如 2：NonMoving / Moving）
 * @return 过滤表句柄；失败返回空指针
 */
@FastNative
foreign func JPH_ObjectLayerPairFilterTable_Create(numObjectLayers: UInt32): CPointer<Unit>

/** @brief 允许 layer1 与 layer2 碰撞 */
@FastNative
foreign func JPH_ObjectLayerPairFilterTable_EnableCollision(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): Unit

/** @brief 禁止 layer1 与 layer2 碰撞 */
@FastNative
foreign func JPH_ObjectLayerPairFilterTable_DisableCollision(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): Unit

/** @brief 查询 layer1 与 layer2 是否允许碰撞 */
@FastNative
foreign func JPH_ObjectLayerPairFilterTable_ShouldCollide(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): UInt8

/** @brief 销毁对象层过滤表 */
@FastNative
foreign func JPH_ObjectLayerPairFilter_Destroy(filter: CPointer<Unit>): Unit

/**
 * @brief 创建对象层 -> BroadPhase 层映射表（1 对 1 或 N 对 1 映射）
 * @param numObjectLayers 对象层数量
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @return 映射接口句柄；失败返回空指针
 */
@FastNative
foreign func JPH_BroadPhaseLayerInterfaceTable_Create(
    numObjectLayers: UInt32, numBroadPhaseLayers: UInt32
): CPointer<Unit>

/** @brief 将对象层映射到 BroadPhase 层 */
@FastNative
foreign func JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(
    bpInterface: CPointer<Unit>, objectLayer: UInt32, broadPhaseLayer: UInt8
): Unit

/** @brief 销毁对象层 -> BroadPhase 层映射接口 */
@FastNative
foreign func JPH_BroadPhaseLayerInterface_Destroy(bpInterface: CPointer<Unit>): Unit

/**
 * @brief 创建对象层 vs BroadPhase 层碰撞过滤表
 * @param broadPhaseLayerInterface 层映射接口（上述 Table 创建）
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @param objectLayerPairFilter 对象层过滤表
 * @param numObjectLayers 对象层数量
 * @return 过滤表句柄；失败返回空指针
 */
@FastNative
foreign func JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
    broadPhaseLayerInterface: CPointer<Unit>,
    numBroadPhaseLayers: UInt32,
    objectLayerPairFilter: CPointer<Unit>,
    numObjectLayers: UInt32
): CPointer<Unit>

/** @brief 销毁对象层 vs BroadPhase 层过滤表 */
@FastNative
foreign func JPH_ObjectVsBroadPhaseLayerFilter_Destroy(filter: CPointer<Unit>): Unit

// =============================================================================
// 物理系统（PhysicsSystem）
// =============================================================================

/**
 * @brief 创建物理系统（含世界、BroadPhase/NarrowPhase、刚体管理器）
 * @param settings 系统设置（容量上限 + 层过滤对象，见 JPHPhysicsSystemSettings）
 * @return 系统句柄；失败返回空指针
 * @note 需先调用 JPH_Init()；settings 引用的层过滤对象须在系统销毁后销毁。
 */
@FastNative
foreign func JPH_PhysicsSystem_Create(settings: CPointer<JPHPhysicsSystemSettings>): CPointer<Unit>

/** @brief 销毁物理系统并释放其全部资源 */
@FastNative
foreign func JPH_PhysicsSystem_Destroy(system: CPointer<Unit>): Unit

/**
 * @brief 步进物理世界一帧
 * @param system 系统句柄
 * @param deltaTime 时间步长（秒），典型 1/60
 * @param collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1，更大步长需向上取整）
 * @param jobSystem 作业系统句柄（JPH_JobSystemThreadPool_Create 创建）
 * @return 更新错误标志（PhysicsUpdateError 位掩码，0 = 完整完成）
 */
foreign func JPH_PhysicsSystem_Update(
    system: CPointer<Unit>, deltaTime: Float32, collisionSteps: Int32,
    jobSystem: CPointer<Unit>
): UInt32

/** @brief 优化 BroadPhase 包围盒树（批量插入刚体后调用一次，勿每帧调用） */
foreign func JPH_PhysicsSystem_OptimizeBroadPhase(system: CPointer<Unit>): Unit

/** @brief 设置全局重力（value 为 JPHVec3 指针，如 (0, -9.81, 0)） */
@FastNative
foreign func JPH_PhysicsSystem_SetGravity(system: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取刚体接口（BodyInterface，用于创建/操作刚体） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodyInterface(system: CPointer<Unit>): CPointer<Unit>

/** @brief 获取窄相查询接口（NarrowPhaseQuery，用于射线/形状碰撞查询） */
@FastNative
foreign func JPH_PhysicsSystem_GetNarrowPhaseQuery(system: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// 形状（Shape）
// =============================================================================

/**
 * @brief 创建长方体形状
 * @param halfExtent 半边长（JPHVec3 指针，实际尺寸 = 2×半边长）
 * @param convexRadius 凸半径（角部圆角；<=0 用 JPH_DEFAULT_CONVEX_RADIUS）
 * @return 形状句柄；失败返回空指针
 */
@FastNative
foreign func JPH_BoxShape_Create(halfExtent: CPointer<JPHVec3>, convexRadius: Float32): CPointer<Unit>

/** @brief 创建球体形状（radius 半径），返回形状句柄或空指针 */
@FastNative
foreign func JPH_SphereShape_Create(radius: Float32): CPointer<Unit>

/** @brief 创建胶囊体形状（halfHeightOfCylinder 圆柱段半高，radius 半径） */
@FastNative
foreign func JPH_CapsuleShape_Create(halfHeightOfCylinder: Float32, radius: Float32): CPointer<Unit>

/** @brief 创建圆柱体形状（halfHeight 半高，radius 半径） */
@FastNative
foreign func JPH_CylinderShape_Create(halfHeight: Float32, radius: Float32): CPointer<Unit>

/** @brief 销毁形状并释放其引用 */
@FastNative
foreign func JPH_Shape_Destroy(shape: CPointer<Unit>): Unit

// =============================================================================
// 刚体创建设置（BodyCreationSettings）
// =============================================================================

/**
 * @brief 创建刚体创建设置（指定形状/位置/旋转/运动类型/对象层）
 * @param shape 形状句柄
 * @param position 初始位置（JPHVec3 指针，世界坐标）
 * @param rotation 初始旋转（JPHQuat 指针，可传空指针 = 单位四元数）
 * @param motionType 运动类型（MotionType 枚举值）
 * @param objectLayer 对象层（如 0=NonMoving / 1=Moving）
 * @return 设置句柄；失败返回空指针
 */
@FastNative
foreign func JPH_BodyCreationSettings_Create3(
    shape: CPointer<Unit>,
    position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>,
    motionType: UInt32,
    objectLayer: UInt32
): CPointer<Unit>

/** @brief 销毁刚体创建设置 */
@FastNative
foreign func JPH_BodyCreationSettings_Destroy(settings: CPointer<Unit>): Unit

// =============================================================================
// 刚体接口（BodyInterface）
// =============================================================================

/**
 * @brief 创建并添加刚体到世界（一步完成）
 * @param bodyInterface 刚体接口（JPH_PhysicsSystem_GetBodyInterface 获取）
 * @param settings 刚体创建设置
 * @param activationMode 激活策略（Activation 枚举值）
 * @return 刚体 BodyID；失败返回 0（无效 BodyID）
 */
@FastNative
foreign func JPH_BodyInterface_CreateAndAddBody(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>, activationMode: UInt32
): UInt32

/** @brief 将已创建的刚体添加到世界 */
@FastNative
foreign func JPH_BodyInterface_AddBody(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, activationMode: UInt32
): Unit

/** @brief 从世界移除刚体（保留其状态，可重新 AddBody） */
@FastNative
foreign func JPH_BodyInterface_RemoveBody(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit

/** @brief 移除并销毁刚体（一步完成，ID 立即失效） */
@FastNative
foreign func JPH_BodyInterface_RemoveAndDestroyBody(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit

/** @brief 销毁刚体（需先 RemoveBody） */
@FastNative
foreign func JPH_BodyInterface_DestroyBody(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit

/** @brief 查询刚体是否处于活动（模拟）状态，返回 true 活动 */
@FastNative
foreign func JPH_BodyInterface_IsActive(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt8

/** @brief 设置刚体线速度（世界空间，velocity 为 JPHVec3 指针，米/秒） */
@FastNative
foreign func JPH_BodyInterface_SetLinearVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, velocity: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体线速度（velocity 为输出 JPHVec3 指针） */
@FastNative
foreign func JPH_BodyInterface_GetLinearVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, velocity: CPointer<JPHVec3>
): Unit

/** @brief 设置刚体角速度（世界空间，弧度/秒） */
@FastNative
foreign func JPH_BodyInterface_SetAngularVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体角速度（世界空间，弧度/秒） */
@FastNative
foreign func JPH_BodyInterface_GetAngularVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 设置刚体位置（世界坐标，激活策略影响是否唤醒） */
@FastNative
foreign func JPH_BodyInterface_SetPosition(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, activationMode: UInt32
): Unit

/** @brief 获取刚体位置（世界坐标；质心位置请用 GetCenterOfMassPosition） */
@FastNative
foreign func JPH_BodyInterface_GetPosition(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体质心位置（世界坐标） */
@FastNative
foreign func JPH_BodyInterface_GetCenterOfMassPosition(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHVec3>
): Unit

/** @brief 设置刚体旋转（四元数，激活策略影响是否唤醒） */
@FastNative
foreign func JPH_BodyInterface_SetRotation(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit

/** @brief 获取刚体旋转（四元数） */
@FastNative
foreign func JPH_BodyInterface_GetRotation(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHQuat>
): Unit

/** @brief 设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic） */
@FastNative
foreign func JPH_BodyInterface_SetMotionType(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, motionType: UInt32, activationMode: UInt32
): Unit

/** @brief 获取刚体运动类型（MotionType 枚举值） */
@FastNative
foreign func JPH_BodyInterface_GetMotionType(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt32

/** @brief 设置刚体摩擦系数（0~1，默认 0.2） */
@FastNative
foreign func JPH_BodyInterface_SetFriction(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, friction: Float32
): Unit

/** @brief 获取刚体摩擦系数 */
@FastNative
foreign func JPH_BodyInterface_GetFriction(bodyInterface: CPointer<Unit>, bodyID: UInt32): Float32

/** @brief 设置刚体弹性系数（0~1，默认 0） */
@FastNative
foreign func JPH_BodyInterface_SetRestitution(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, restitution: Float32
): Unit

/** @brief 获取刚体弹性系数 */
@FastNative
foreign func JPH_BodyInterface_GetRestitution(bodyInterface: CPointer<Unit>, bodyID: UInt32): Float32

/** @brief 设置刚体对象层（运行时改变碰撞分组） */
@FastNative
foreign func JPH_BodyInterface_SetObjectLayer(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, layer: UInt32
): Unit

/** @brief 获取刚体对象层 */
@FastNative
foreign func JPH_BodyInterface_GetObjectLayer(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt32

// =============================================================================
// 窄相查询（NarrowPhaseQuery）：射线检测
// =============================================================================

/**
 * @brief 世界射线检测（最近命中）
 * @param query 窄相查询接口（JPH_PhysicsSystem_GetNarrowPhaseQuery 获取）
 * @param origin 射线起点（JPHVec3 指针，世界坐标）
 * @param direction 射线方向（长度即最大检测距离）
 * @param hit 命中结果输出（JPHRayCastResult 指针，命中时有效）
 * @param broadPhaseLayerFilter / objectLayerFilter / bodyFilter 过滤参数，可传空指针（全部接受）
 * @return true 命中；false 未命中
 */
@FastNative
foreign func JPH_NarrowPhaseQuery_CastRay(
    query: CPointer<Unit>,
    origin: CPointer<JPHVec3>,
    direction: CPointer<JPHVec3>,
    hit: CPointer<JPHRayCastResult>,
    broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>
): UInt8

// =============================================================================
// 生命周期扩展：回调注册 / 结构体释放
// =============================================================================

/**
 * @brief 设置全局 Trace 回调（日志输出）
 * @param handler 回调函数指针（JPH_TraceFunc），可传空指针恢复默认
 */
@FastNative
foreign func JPH_SetTraceHandler(handler: CPointer<Unit>): Unit

/**
 * @brief 设置全局断言失败回调
 * @param handler 回调函数指针（JPH_AssertFailureFunc），返回 true 继续执行
 */
@FastNative
foreign func JPH_SetAssertFailureHandler(handler: CPointer<Unit>): Unit

/** @brief 释放 CollideShapeResult 内部动态分配的面数组 */
@FastNative
foreign func JPH_CollideShapeResult_FreeMembers(result: CPointer<JPHCollideShapeResult>): Unit

/** @brief 释放 CollisionEstimationResult 内部动态分配的接触冲量数组 */
@FastNative
foreign func JPH_CollisionEstimationResult_FreeMembers(result: CPointer<JPHCollisionEstimationResult>): Unit

// =============================================================================
// 层过滤扩展：Mask 系列（组 + 掩码）
// =============================================================================

/**
 * @brief 创建 Mask 式 BroadPhase 层映射接口（按组/掩码判定碰撞）
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @return 映射接口句柄；失败返回空指针
 */
@FastNative
foreign func JPH_BroadPhaseLayerInterfaceMask_Create(numBroadPhaseLayers: UInt32): CPointer<Unit>

/**
 * @brief 配置 Mask 层的包含/排除组
 * @param broadPhaseLayer BroadPhase 层
 * @param groupsToInclude 应碰撞的组掩码
 * @param groupsToExclude 应排除的组掩码
 */
@FastNative
foreign func JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer(
    bpInterface: CPointer<Unit>, broadPhaseLayer: UInt8,
    groupsToInclude: UInt32, groupsToExclude: UInt32
): Unit

/** @brief 创建 Mask 式对象层过滤表（不碰撞任何层，需配置） */
@FastNative
foreign func JPH_ObjectLayerPairFilterMask_Create(): CPointer<Unit>

/**
 * @brief 从组与掩码计算对象层（组与掩码打包为对象层值）
 * @param group 组 ID（0-15）
 * @param mask 掩码（0-15）
 * @return 打包后的对象层
 */
@FastNative
foreign func JPH_ObjectLayerPairFilterMask_GetObjectLayer(group: UInt32, mask: UInt32): UInt32

/** @brief 从对象层解出组 ID */
@FastNative
foreign func JPH_ObjectLayerPairFilterMask_GetGroup(layer: UInt32): UInt32

/** @brief 从对象层解出掩码 */
@FastNative
foreign func JPH_ObjectLayerPairFilterMask_GetMask(layer: UInt32): UInt32

/**
 * @brief 创建 Mask 式对象层 vs BroadPhase 层过滤表
 * @param broadPhaseLayerInterface BroadPhase 层映射接口
 * @return 过滤表句柄；失败返回空指针
 */
@FastNative
foreign func JPH_ObjectVsBroadPhaseLayerFilterMask_Create(
    broadPhaseLayerInterface: CPointer<Unit>
): CPointer<Unit>

/** @brief 用默认值初始化绘制设置（JPH_DrawSettings_InitDefault） */
foreign func JPH_DrawSettings_InitDefault(settings: CPointer<JPHDrawSettings>): Unit

// =============================================================================
// 物理系统扩展（PhysicsSystem）
// =============================================================================

/**
 * @brief 设置物理求解器参数（迭代步数/容差/休眠阈值等）
 * @param settings 物理参数（JPHPhysicsSettings 指针）
 */
@FastNative
foreign func JPH_PhysicsSystem_SetPhysicsSettings(
    system: CPointer<Unit>, settings: CPointer<JPHPhysicsSettings>
): Unit

/** @brief 获取物理求解器参数 */
@FastNative
foreign func JPH_PhysicsSystem_GetPhysicsSettings(
    system: CPointer<Unit>, result: CPointer<JPHPhysicsSettings>
): Unit

/** @brief 获取刚体接口（无锁版本，须自行保证线程安全） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodyInterfaceNoLock(system: CPointer<Unit>): CPointer<Unit>

/** @brief 获取刚体锁接口（线程安全访问刚体数据） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodyLockInterface(system: CPointer<Unit>): CPointer<Unit>

/** @brief 获取刚体锁接口（无锁版本） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodyLockInterfaceNoLock(system: CPointer<Unit>): CPointer<Unit>

/** @brief 获取宽相位查询接口（BroadPhaseQuery，仅包围盒级查询） */
@FastNative
foreign func JPH_PhysicsSystem_GetBroadPhaseQuery(system: CPointer<Unit>): CPointer<Unit>

/** @brief 获取窄相查询接口（无锁版本） */
@FastNative
foreign func JPH_PhysicsSystem_GetNarrowPhaseQueryNoLock(system: CPointer<Unit>): CPointer<Unit>

/** @brief 设置接触监听器（碰撞开始/持续/结束回调） */
@FastNative
foreign func JPH_PhysicsSystem_SetContactListener(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit

/** @brief 设置刚体激活监听器（激活/休眠回调） */
@FastNative
foreign func JPH_PhysicsSystem_SetBodyActivationListener(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit

/** @brief 设置模拟形状过滤（模拟中的碰撞过滤） */
@FastNative
foreign func JPH_PhysicsSystem_SetSimShapeFilter(
    system: CPointer<Unit>, filter: CPointer<Unit>
): Unit

/**
 * @brief 查询两个刚体当前是否接触
 * @param body1 刚体 1 的 BodyID
 * @param body2 刚体 2 的 BodyID
 * @return 非 0 表示接触
 */
@FastNative
foreign func JPH_PhysicsSystem_WereBodiesInContact(
    system: CPointer<Unit>, body1: UInt32, body2: UInt32
): UInt8

/** @brief 获取世界中刚体总数 */
@FastNative
foreign func JPH_PhysicsSystem_GetNumBodies(system: CPointer<Unit>): UInt32

/** @brief 获取世界中活动刚体数（按刚体类型） */
@FastNative
foreign func JPH_PhysicsSystem_GetNumActiveBodies(system: CPointer<Unit>, bodyType: UInt32): UInt32

/** @brief 获取世界中刚体容量上限 */
@FastNative
foreign func JPH_PhysicsSystem_GetMaxBodies(system: CPointer<Unit>): UInt32

/** @brief 获取世界中约束总数 */
@FastNative
foreign func JPH_PhysicsSystem_GetNumConstraints(system: CPointer<Unit>): UInt32

/** @brief 获取当前重力（value 为 JPHVec3 指针） */
@FastNative
foreign func JPH_PhysicsSystem_GetGravity(system: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 添加约束到世界 */
@FastNative
foreign func JPH_PhysicsSystem_AddConstraint(
    system: CPointer<Unit>, constraint: CPointer<Unit>
): Unit

/** @brief 从世界移除约束 */
@FastNative
foreign func JPH_PhysicsSystem_RemoveConstraint(
    system: CPointer<Unit>, constraint: CPointer<Unit>
): Unit

/** @brief 批量添加约束（constraints 为 JPH_Constraint* 数组指针） */
@FastNative
foreign func JPH_PhysicsSystem_AddConstraints(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit

/** @brief 批量移除约束 */
@FastNative
foreign func JPH_PhysicsSystem_RemoveConstraints(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit

/** @brief 添加步进监听器（每次物理步进前回调） */
@FastNative
foreign func JPH_PhysicsSystem_AddStepListener(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit

/** @brief 移除步进监听器 */
@FastNative
foreign func JPH_PhysicsSystem_RemoveStepListener(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit

/** @brief 获取全部刚体 ID（ids 为 JPH_BodyID 数组指针） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodies(
    system: CPointer<Unit>, ids: CPointer<UInt32>, count: UInt32
): Unit

/** @brief 获取全部活动刚体 ID */
@FastNative
foreign func JPH_PhysicsSystem_GetActiveBodies(
    system: CPointer<Unit>, bodyType: UInt32, ids: CPointer<UInt32>, count: UInt32
): Unit

/** @brief 获取活动刚体 ID 数组指针（系统持有，只读） */
@FastNative
foreign func JPH_PhysicsSystem_GetActiveBodiesUnsafe(
    system: CPointer<Unit>, bodyType: UInt32
): CPointer<UInt32>

/** @brief 获取全部约束（constraints 为 JPH_Constraint* 数组指针） */
@FastNative
foreign func JPH_PhysicsSystem_GetConstraints(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit

/** @brief 激活 AABB 范围内、指定对象层的刚体 */
@FastNative
foreign func JPH_PhysicsSystem_ActivateBodiesInAABox(
    system: CPointer<Unit>, box: CPointer<JPHAABox>, layer: UInt32
): Unit

/** @brief 调试绘制全部刚体形状 */
foreign func JPH_PhysicsSystem_DrawBodies(
    system: CPointer<Unit>, settings: CPointer<JPHDrawSettings>,
    renderer: CPointer<Unit>, bodyFilter: CPointer<Unit>
): Unit

/** @brief 调试绘制全部约束 */
foreign func JPH_PhysicsSystem_DrawConstraints(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit

/** @brief 调试绘制全部约束限位 */
foreign func JPH_PhysicsSystem_DrawConstraintLimits(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit

/** @brief 调试绘制全部约束参考系 */
@FastNative
foreign func JPH_PhysicsSystem_DrawConstraintReferenceFrame(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit

// =============================================================================
// 步进监听器（PhysicsStepListener）
// =============================================================================

/** @brief 设置步进监听器回调表 */
foreign func JPH_PhysicsStepListener_SetProcs(procs: CPointer<JPHPhysicsStepListenerProcs>): Unit

/** @brief 创建步进监听器实例 */
@FastNative
foreign func JPH_PhysicsStepListener_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁步进监听器 */
@FastNative
foreign func JPH_PhysicsStepListener_Destroy(listener: CPointer<Unit>): Unit

// =============================================================================
// 数学工具（Math / Quat / Vec3 / Mat4）
// =============================================================================

/** @brief 正弦 */
@FastNative
foreign func JPH_Math_Sin(value: Float32): Float32

/** @brief 余弦 */
@FastNative
foreign func JPH_Math_Cos(value: Float32): Float32

/** @brief 构造从 from 到 to 的旋转四元数（输出 quat） */
@FastNative
foreign func JPH_Quat_FromTo(from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, quat: CPointer<JPHQuat>): Unit

/** @brief 获取四元数的轴角表示（输出 outAxis / outAngle） */
@FastNative
foreign func JPH_Quat_GetAxisAngle(quat: CPointer<JPHQuat>, outAxis: CPointer<JPHVec3>, outAngle: CPointer<Float32>): Unit

/** @brief 获取四元数的欧拉角（XYZ 顺序，输出 result） */
@FastNative
foreign func JPH_Quat_GetEulerAngles(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit

/** @brief 四元数旋转 X 轴（输出 result） */
@FastNative
foreign func JPH_Quat_RotateAxisX(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit

/** @brief 四元数旋转 Y 轴（输出 result） */
@FastNative
foreign func JPH_Quat_RotateAxisY(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit

/** @brief 四元数旋转 Z 轴（输出 result） */
@FastNative
foreign func JPH_Quat_RotateAxisZ(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit

/** @brief 四元数求逆（输出 result） */
@FastNative
foreign func JPH_Quat_Inversed(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 获取四元数垂直方向四元数（输出 result） */
@FastNative
foreign func JPH_Quat_GetPerpendicular(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 获取绕指定轴的旋转角 */
@FastNative
foreign func JPH_Quat_GetRotationAngle(quat: CPointer<JPHQuat>, axis: CPointer<JPHVec3>): Float32

/** @brief 从欧拉角构造四元数（angles 为 JPHVec3 指针，输出 result） */
@FastNative
foreign func JPH_Quat_FromEulerAngles(angles: CPointer<JPHVec3>, result: CPointer<JPHQuat>): Unit

/** @brief 四元数加法 q1 + q2 */
@FastNative
foreign func JPH_Quat_Add(q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 四元数减法 q1 - q2 */
@FastNative
foreign func JPH_Quat_Subtract(q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 四元数乘法 q1 * q2（组合旋转） */
@FastNative
foreign func JPH_Quat_Multiply(q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 四元数数乘 q * scalar */
@FastNative
foreign func JPH_Quat_MultiplyScalar(q: CPointer<JPHQuat>, scalar: Float32, result: CPointer<JPHQuat>): Unit

/** @brief 四元数数除 q / scalar */
@FastNative
foreign func JPH_Quat_DivideScalar(q: CPointer<JPHQuat>, scalar: Float32, result: CPointer<JPHQuat>): Unit

/** @brief 四元数点积 q1 · q2（输出 result） */
@FastNative
foreign func JPH_Quat_Dot(q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<Float32>): Unit

/** @brief 四元数共轭（输出 result） */
@FastNative
foreign func JPH_Quat_Conjugated(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit

/** @brief 提取绕指定轴的扭转分量（输出 result） */
@FastNative
foreign func JPH_Quat_GetTwist(quat: CPointer<JPHQuat>, axis: CPointer<JPHVec3>, result: CPointer<JPHQuat>): Unit

/** @brief 分解为摆动与扭转四元数（输出 outSwing / outTwist） */
@FastNative
foreign func JPH_Quat_GetSwingTwist(quat: CPointer<JPHQuat>, outSwing: CPointer<JPHQuat>, outTwist: CPointer<JPHQuat>): Unit

/** @brief 四元数线性插值（输出 result） */
@FastNative
foreign func JPH_Quat_Lerp(from: CPointer<JPHQuat>, to: CPointer<JPHQuat>, fraction: Float32, result: CPointer<JPHQuat>): Unit

/** @brief 四元数球面插值（输出 result） */
@FastNative
foreign func JPH_Quat_Slerp(from: CPointer<JPHQuat>, to: CPointer<JPHQuat>, fraction: Float32, result: CPointer<JPHQuat>): Unit

/** @brief 用四元数旋转向量（输出 result） */
@FastNative
foreign func JPH_Quat_Rotate(quat: CPointer<JPHQuat>, vec: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 用四元数逆旋转向量（输出 result） */
@FastNative
foreign func JPH_Quat_InverseRotate(quat: CPointer<JPHQuat>, vec: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 获取 X 轴单位向量（输出 result） */
@FastNative
foreign func JPH_Vec3_AxisX(result: CPointer<JPHVec3>): Unit

/** @brief 获取 Y 轴单位向量（输出 result） */
@FastNative
foreign func JPH_Vec3_AxisY(result: CPointer<JPHVec3>): Unit

/** @brief 获取 Z 轴单位向量（输出 result） */
@FastNative
foreign func JPH_Vec3_AxisZ(result: CPointer<JPHVec3>): Unit

/** @brief 判断 v1 与 v2 是否接近（距离平方 <= maxDistSq） */
@FastNative
foreign func JPH_Vec3_IsClose(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, maxDistSq: Float32): UInt8

/** @brief 判断向量是否接近零（长度平方 <= maxDistSq） */
@FastNative
foreign func JPH_Vec3_IsNearZero(v: CPointer<JPHVec3>, maxDistSq: Float32): UInt8

/** @brief 判断向量是否已归一化（误差 <= tolerance） */
@FastNative
foreign func JPH_Vec3_IsNormalized(v: CPointer<JPHVec3>, tolerance: Float32): UInt8

/** @brief 判断向量是否含 NaN */
@FastNative
foreign func JPH_Vec3_IsNaN(v: CPointer<JPHVec3>): UInt8

/** @brief 向量取反（输出 result） */
@FastNative
foreign func JPH_Vec3_Negate(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量归一化（输出 result） */
@FastNative
foreign func JPH_Vec3_Normalized(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量叉积 v1 × v2（输出 result） */
@FastNative
foreign func JPH_Vec3_Cross(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量各分量取绝对值（输出 result） */
@FastNative
foreign func JPH_Vec3_Abs(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量长度 */
@FastNative
foreign func JPH_Vec3_Length(v: CPointer<JPHVec3>): Float32

/** @brief 向量长度平方 */
@FastNative
foreign func JPH_Vec3_LengthSquared(v: CPointer<JPHVec3>): Float32

/** @brief 向量点积 v1 · v2（输出 result） */
@FastNative
foreign func JPH_Vec3_DotProduct(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<Float32>): Unit

/** @brief 向量原地归一化（输出 result） */
@FastNative
foreign func JPH_Vec3_Normalize(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量加法 v1 + v2 */
@FastNative
foreign func JPH_Vec3_Add(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量减法 v1 - v2 */
@FastNative
foreign func JPH_Vec3_Subtract(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量逐分量乘法 v1 * v2 */
@FastNative
foreign func JPH_Vec3_Multiply(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量数乘 v * scalar */
@FastNative
foreign func JPH_Vec3_MultiplyScalar(v: CPointer<JPHVec3>, scalar: Float32, result: CPointer<JPHVec3>): Unit

/** @brief 矩阵乘向量 left * right（输出 result） */
@FastNative
foreign func JPH_Vec3_MultiplyMatrix(left: CPointer<JPHMat4>, right: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量逐分量除法 v1 / v2 */
@FastNative
foreign func JPH_Vec3_Divide(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 向量数除 v / scalar */
@FastNative
foreign func JPH_Vec3_DivideScalar(v: CPointer<JPHVec3>, scalar: Float32, result: CPointer<JPHVec3>): Unit

/** @brief 获取垂直方向的归一化向量（输出 result） */
@FastNative
foreign func JPH_Vec3_GetNormalizedPerpendicular(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 矩阵加法 m1 + m2 */
@FastNative
foreign func JPH_Mat4_Add(m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit

/** @brief 矩阵减法 m1 - m2 */
@FastNative
foreign func JPH_Mat4_Subtract(m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit

/** @brief 矩阵乘法 m1 * m2 */
@FastNative
foreign func JPH_Mat4_Multiply(m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit

/** @brief 矩阵数乘 m * scalar */
@FastNative
foreign func JPH_Mat4_MultiplyScalar(m: CPointer<JPHMat4>, scalar: Float32, result: CPointer<JPHMat4>): Unit

/** @brief 零矩阵（输出 result） */
@FastNative
foreign func JPH_Mat4_Zero(result: CPointer<JPHMat4>): Unit

/** @brief 单位矩阵（输出 result） */
@FastNative
foreign func JPH_Mat4_Identity(result: CPointer<JPHMat4>): Unit

/** @brief 旋转矩阵（由四元数，输出 result） */
@FastNative
foreign func JPH_Mat4_Rotation(result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>): Unit

/** @brief 绕轴旋转矩阵（axis + angle 弧度，输出 result） */
@FastNative
foreign func JPH_Mat4_Rotation2(result: CPointer<JPHMat4>, axis: CPointer<JPHVec3>, angle: Float32): Unit

/** @brief 平移矩阵（输出 result） */
@FastNative
foreign func JPH_Mat4_Translation(result: CPointer<JPHMat4>, translation: CPointer<JPHVec3>): Unit

/** @brief 旋转 + 平移矩阵（输出 result） */
@FastNative
foreign func JPH_Mat4_RotationTranslation(result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>, translation: CPointer<JPHVec3>): Unit

/** @brief 旋转 + 平移矩阵的逆（输出 result） */
@FastNative
foreign func JPH_Mat4_InverseRotationTranslation(result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>, translation: CPointer<JPHVec3>): Unit

/** @brief 缩放矩阵（输出 result） */
@FastNative
foreign func JPH_Mat4_Scale(result: CPointer<JPHMat4>, scale: CPointer<JPHVec3>): Unit

/** @brief 矩阵转置（输出 result） */
@FastNative
foreign func JPH_Mat4_Transposed(m: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit

/** @brief 矩阵求逆（输出 result） */
@FastNative
foreign func JPH_Mat4_Inversed(matrix: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit

/** @brief 取矩阵 X 轴（输出 result） */
@FastNative
foreign func JPH_Mat4_GetAxisX(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit

/** @brief 取矩阵 Y 轴（输出 result） */
@FastNative
foreign func JPH_Mat4_GetAxisY(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit

/** @brief 取矩阵 Z 轴（输出 result） */
@FastNative
foreign func JPH_Mat4_GetAxisZ(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit

/** @brief 取矩阵平移分量（输出 result） */
@FastNative
foreign func JPH_Mat4_GetTranslation(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit

/** @brief 取矩阵旋转四元数（输出 result） */
@FastNative
foreign func JPH_Mat4_GetQuaternion(matrix: CPointer<JPHMat4>, result: CPointer<JPHQuat>): Unit

// =============================================================================
// 物理材质（PhysicsMaterial）
// =============================================================================

/**
 * @brief 创建物理材质
 * @param name 材质名称（C 字符串）
 * @param color 调试颜色（RGBA）
 * @return 材质句柄；失败返回空指针
 */
@FastNative
foreign func JPH_PhysicsMaterial_Create(name: CPointer<UInt8>, color: UInt32): CPointer<Unit>

/** @brief 销毁物理材质 */
@FastNative
foreign func JPH_PhysicsMaterial_Destroy(material: CPointer<Unit>): Unit

/** @brief 获取材质调试名称（C 字符串指针） */
@FastNative
foreign func JPH_PhysicsMaterial_GetDebugName(material: CPointer<Unit>): CPointer<UInt8>

/** @brief 获取材质调试颜色 */
@FastNative
foreign func JPH_PhysicsMaterial_GetDebugColor(material: CPointer<Unit>): UInt32

// =============================================================================
// 组过滤（GroupFilter / GroupFilterTable）
// =============================================================================

/** @brief 销毁组过滤对象 */
@FastNative
foreign func JPH_GroupFilter_Destroy(groupFilter: CPointer<Unit>): Unit

/** @brief 判断两组是否允许碰撞 */
@FastNative
foreign func JPH_GroupFilter_CanCollide(
    groupFilter: CPointer<Unit>,
    group1: CPointer<JPHCollisionGroup>,
    group2: CPointer<JPHCollisionGroup>
): UInt8

/**
 * @brief 创建组过滤表（按子组 ID 判定碰撞）
 * @param numSubGroups 子组数量（默认 0 = 使用默认值）
 * @return 过滤表句柄；失败返回空指针
 */
@FastNative
foreign func JPH_GroupFilterTable_Create(numSubGroups: UInt32): CPointer<Unit>

/** @brief 禁止两个子组碰撞 */
@FastNative
foreign func JPH_GroupFilterTable_DisableCollision(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): Unit

/** @brief 允许两个子组碰撞 */
@FastNative
foreign func JPH_GroupFilterTable_EnableCollision(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): Unit

/** @brief 查询两个子组是否允许碰撞 */
@FastNative
foreign func JPH_GroupFilterTable_IsCollisionEnabled(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): UInt8

// =============================================================================
// 形状设置（ShapeSettings）与形状基类（Shape）
// =============================================================================

/** @brief 销毁形状设置 */
@FastNative
foreign func JPH_ShapeSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取形状设置的用户数据 */
@FastNative
foreign func JPH_ShapeSettings_GetUserData(settings: CPointer<Unit>): UInt64

/** @brief 设置形状设置的用户数据 */
@FastNative
foreign func JPH_ShapeSettings_SetUserData(settings: CPointer<Unit>, userData: UInt64): Unit

/**
 * @brief 调试绘制形状
 * @param renderer 调试渲染器句柄
 * @param centerOfMassTransform 质心变换矩阵
 * @param scale 缩放
 * @param color 颜色
 * @param useMaterialColors 是否用材质颜色
 * @param drawWireframe 是否线框
 */
@FastNative
foreign func JPH_Shape_Draw(
    shape: CPointer<Unit>, renderer: CPointer<Unit>,
    centerOfMassTransform: CPointer<JPHMat4>, scale: CPointer<JPHVec3>,
    color: UInt32, useMaterialColors: UInt8, drawWireframe: UInt8
): Unit

/** @brief 获取形状大类（ShapeType 枚举值） */
@FastNative
foreign func JPH_Shape_GetType(shape: CPointer<Unit>): UInt32

/** @brief 获取形状子类型（ShapeSubType 枚举值） */
@FastNative
foreign func JPH_Shape_GetSubType(shape: CPointer<Unit>): UInt32

/** @brief 获取形状用户数据 */
@FastNative
foreign func JPH_Shape_GetUserData(shape: CPointer<Unit>): UInt64

/** @brief 设置形状用户数据 */
@FastNative
foreign func JPH_Shape_SetUserData(shape: CPointer<Unit>, userData: UInt64): Unit

/** @brief 形状是否必须为静态（非 0 = 必须静态，如网格/高度场） */
@FastNative
foreign func JPH_Shape_MustBeStatic(shape: CPointer<Unit>): UInt8

/** @brief 获取形状质心（输出 result） */
@FastNative
foreign func JPH_Shape_GetCenterOfMass(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取形状局部包围盒（输出 result） */
@FastNative
foreign func JPH_Shape_GetLocalBounds(shape: CPointer<Unit>, result: CPointer<JPHAABox>): Unit

/** @brief 获取子形状 ID 的递归位数 */
@FastNative
foreign func JPH_Shape_GetSubShapeIDBitsRecursive(shape: CPointer<Unit>): UInt32

/** @brief 获取形状世界空间包围盒 */
@FastNative
foreign func JPH_Shape_GetWorldSpaceBounds(
    shape: CPointer<Unit>, centerOfMassTransform: CPointer<JPHMat4>,
    scale: CPointer<JPHVec3>, result: CPointer<JPHAABox>
): Unit

/** @brief 获取形状内半径 */
@FastNative
foreign func JPH_Shape_GetInnerRadius(shape: CPointer<Unit>): Float32

/** @brief 获取形状质量属性（输出 result） */
@FastNative
foreign func JPH_Shape_GetMassProperties(shape: CPointer<Unit>, result: CPointer<JPHMassProperties>): Unit

/** @brief 获取叶子形状（复合/装饰形状递归到叶子） */
@FastNative
foreign func JPH_Shape_GetLeafShape(
    shape: CPointer<Unit>, subShapeID: UInt32, remainder: CPointer<UInt32>
): CPointer<Unit>

/** @brief 获取子形状材质（按子形状 ID） */
@FastNative
foreign func JPH_Shape_GetMaterial(shape: CPointer<Unit>, subShapeID: UInt32): CPointer<Unit>

/** @brief 获取形状表面法线（按子形状 ID + 局部位置） */
@FastNative
foreign func JPH_Shape_GetSurfaceNormal(
    shape: CPointer<Unit>, subShapeID: UInt32,
    localPosition: CPointer<JPHVec3>, normal: CPointer<JPHVec3>
): Unit

/** @brief 获取支撑面（碰撞接触面） */
@FastNative
foreign func JPH_Shape_GetSupportingFace(
    shape: CPointer<Unit>, subShapeID: UInt32, direction: CPointer<JPHVec3>,
    scale: CPointer<JPHVec3>, centerOfMassTransform: CPointer<JPHMat4>,
    outVertices: CPointer<JPHSupportingFace>
): Unit

/** @brief 获取形状体积 */
@FastNative
foreign func JPH_Shape_GetVolume(shape: CPointer<Unit>): Float32

/** @brief 缩放是否有效 */
@FastNative
foreign func JPH_Shape_IsValidScale(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): UInt8

/** @brief 将缩放修正为有效值（输出 result） */
@FastNative
foreign func JPH_Shape_MakeScaleValid(shape: CPointer<Unit>, scale: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 创建缩放后的形状副本 */
@FastNative
foreign func JPH_Shape_ScaleShape(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit>

/** @brief 形状自身射线检测（返回是否命中，hit 输出） */
@FastNative
foreign func JPH_Shape_CastRay(
    shape: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    hit: CPointer<JPHRayCastResult>
): UInt8

/** @brief 形状自身射线检测（带收集器回调的完整版本） */
@FastNative
foreign func JPH_Shape_CastRay2(
    shape: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>, collectorType: UInt32,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 形状自身点碰撞检测 */
@FastNative
foreign func JPH_Shape_CollidePoint(
    shape: CPointer<Unit>, point: CPointer<JPHVec3>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 形状自身点碰撞检测（带收集器回调的完整版本） */
@FastNative
foreign func JPH_Shape_CollidePoint2(
    shape: CPointer<Unit>, point: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 获取凸形状设置的密度 */
@FastNative
foreign func JPH_ConvexShapeSettings_GetDensity(shape: CPointer<Unit>): Float32

/** @brief 设置凸形状设置的密度 */
@FastNative
foreign func JPH_ConvexShapeSettings_SetDensity(shape: CPointer<Unit>, value: Float32): Unit

/** @brief 获取凸形状密度 */
@FastNative
foreign func JPH_ConvexShape_GetDensity(shape: CPointer<Unit>): Float32

/** @brief 设置凸形状密度 */
@FastNative
foreign func JPH_ConvexShape_SetDensity(shape: CPointer<Unit>, inDensity: Float32): Unit

// =============================================================================
// 形状族：Box / Sphere / Plane / Triangle / Capsule / Cylinder
// =============================================================================

/** @brief 创建长方体形状设置（halfExtent 半边长，convexRadius 凸半径） */
@FastNative
foreign func JPH_BoxShapeSettings_Create(halfExtent: CPointer<JPHVec3>, convexRadius: Float32): CPointer<Unit>

/** @brief 从设置创建长方体形状 */
@FastNative
foreign func JPH_BoxShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取长方体半边长（输出 halfExtent） */
@FastNative
foreign func JPH_BoxShape_GetHalfExtent(shape: CPointer<Unit>, halfExtent: CPointer<JPHVec3>): Unit

/** @brief 获取长方体凸半径 */
@FastNative
foreign func JPH_BoxShape_GetConvexRadius(shape: CPointer<Unit>): Float32

/** @brief 创建球体形状设置（radius 半径） */
@FastNative
foreign func JPH_SphereShapeSettings_Create(radius: Float32): CPointer<Unit>

/** @brief 从设置创建球体形状 */
@FastNative
foreign func JPH_SphereShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取球体形状设置的半径 */
@FastNative
foreign func JPH_SphereShapeSettings_GetRadius(settings: CPointer<Unit>): Float32

/** @brief 设置球体形状设置的半径 */
@FastNative
foreign func JPH_SphereShapeSettings_SetRadius(settings: CPointer<Unit>, radius: Float32): Unit

/** @brief 获取球体形状半径 */
@FastNative
foreign func JPH_SphereShape_GetRadius(shape: CPointer<Unit>): Float32

/** @brief 创建平面形状设置（plane 平面，material 材质，halfExtent 半尺寸） */
@FastNative
foreign func JPH_PlaneShapeSettings_Create(
    plane: CPointer<JPHPlane>, material: CPointer<Unit>, halfExtent: Float32
): CPointer<Unit>

/** @brief 从设置创建平面形状 */
@FastNative
foreign func JPH_PlaneShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建平面形状 */
@FastNative
foreign func JPH_PlaneShape_Create(
    plane: CPointer<JPHPlane>, material: CPointer<Unit>, halfExtent: Float32
): CPointer<Unit>

/** @brief 获取平面形状的平面（输出 result） */
@FastNative
foreign func JPH_PlaneShape_GetPlane(shape: CPointer<Unit>, result: CPointer<JPHPlane>): Unit

/** @brief 获取平面形状半尺寸 */
@FastNative
foreign func JPH_PlaneShape_GetHalfExtent(shape: CPointer<Unit>): Float32

/** @brief 创建三角形形状设置 */
@FastNative
foreign func JPH_TriangleShapeSettings_Create(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, v3: CPointer<JPHVec3>, convexRadius: Float32
): CPointer<Unit>

/** @brief 从设置创建三角形形状 */
@FastNative
foreign func JPH_TriangleShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建三角形形状 */
@FastNative
foreign func JPH_TriangleShape_Create(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, v3: CPointer<JPHVec3>, convexRadius: Float32
): CPointer<Unit>

/** @brief 获取三角形形状凸半径 */
@FastNative
foreign func JPH_TriangleShape_GetConvexRadius(shape: CPointer<Unit>): Float32

/** @brief 获取三角形顶点 1（输出 result） */
@FastNative
foreign func JPH_TriangleShape_GetVertex1(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取三角形顶点 2（输出 result） */
@FastNative
foreign func JPH_TriangleShape_GetVertex2(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取三角形顶点 3（输出 result） */
@FastNative
foreign func JPH_TriangleShape_GetVertex3(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 创建胶囊体形状设置（halfHeightOfCylinder 圆柱段半高，radius 半径） */
@FastNative
foreign func JPH_CapsuleShapeSettings_Create(halfHeightOfCylinder: Float32, radius: Float32): CPointer<Unit>

/** @brief 从设置创建胶囊体形状 */
@FastNative
foreign func JPH_CapsuleShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取胶囊体半径 */
@FastNative
foreign func JPH_CapsuleShape_GetRadius(shape: CPointer<Unit>): Float32

/** @brief 获取胶囊体圆柱段半高 */
@FastNative
foreign func JPH_CapsuleShape_GetHalfHeightOfCylinder(shape: CPointer<Unit>): Float32

/** @brief 创建圆柱体形状设置 */
@FastNative
foreign func JPH_CylinderShapeSettings_Create(halfHeight: Float32, radius: Float32, convexRadius: Float32): CPointer<Unit>

/** @brief 从设置创建圆柱体形状 */
@FastNative
foreign func JPH_CylinderShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取圆柱体半径 */
@FastNative
foreign func JPH_CylinderShape_GetRadius(shape: CPointer<Unit>): Float32

/** @brief 获取圆柱体半高 */
@FastNative
foreign func JPH_CylinderShape_GetHalfHeight(shape: CPointer<Unit>): Float32

/** @brief 创建锥台圆柱体形状设置 */
@FastNative
foreign func JPH_TaperedCylinderShapeSettings_Create(
    halfHeightOfTaperedCylinder: Float32, topRadius: Float32, bottomRadius: Float32,
    convexRadius: Float32, material: CPointer<Unit>
): CPointer<Unit>

/** @brief 从设置创建锥台圆柱体形状 */
@FastNative
foreign func JPH_TaperedCylinderShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取锥台圆柱体顶半径 */
@FastNative
foreign func JPH_TaperedCylinderShape_GetTopRadius(shape: CPointer<Unit>): Float32

/** @brief 获取锥台圆柱体底半径 */
@FastNative
foreign func JPH_TaperedCylinderShape_GetBottomRadius(shape: CPointer<Unit>): Float32

/** @brief 获取锥台圆柱体凸半径 */
@FastNative
foreign func JPH_TaperedCylinderShape_GetConvexRadius(shape: CPointer<Unit>): Float32

/** @brief 获取锥台圆柱体半高 */
@FastNative
foreign func JPH_TaperedCylinderShape_GetHalfHeight(shape: CPointer<Unit>): Float32

// =============================================================================
// 形状族：ConvexHull / Mesh / HeightField / TaperedCapsule
// =============================================================================

/** @brief 创建凸包形状设置（points 顶点数组，pointsCount 数量，maxConvexRadius 最大凸半径） */
@FastNative
foreign func JPH_ConvexHullShapeSettings_Create(
    points: CPointer<JPHVec3>, pointsCount: UInt32, maxConvexRadius: Float32
): CPointer<Unit>

/** @brief 从设置创建凸包形状 */
@FastNative
foreign func JPH_ConvexHullShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取凸包顶点数量 */
@FastNative
foreign func JPH_ConvexHullShape_GetNumPoints(shape: CPointer<Unit>): UInt32

/** @brief 获取凸包指定顶点（输出 result） */
@FastNative
foreign func JPH_ConvexHullShape_GetPoint(shape: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>): Unit

/** @brief 获取凸包面数量 */
@FastNative
foreign func JPH_ConvexHullShape_GetNumFaces(shape: CPointer<Unit>): UInt32

/** @brief 获取凸包指定面的顶点数 */
@FastNative
foreign func JPH_ConvexHullShape_GetNumVerticesInFace(shape: CPointer<Unit>, faceIndex: UInt32): UInt32

/** @brief 获取凸包指定面的顶点索引（vertices 输出数组） */
@FastNative
foreign func JPH_ConvexHullShape_GetFaceVertices(
    shape: CPointer<Unit>, faceIndex: UInt32, maxVertices: UInt32, vertices: CPointer<UInt32>
): UInt32

/** @brief 创建网格形状设置（triangles 三角形数组，triangleCount 数量） */
@FastNative
foreign func JPH_MeshShapeSettings_Create(
    triangles: CPointer<JPHTriangle>, triangleCount: UInt32
): CPointer<Unit>

/** @brief 创建网格形状设置（顶点 + 索引三角形形式） */
@FastNative
foreign func JPH_MeshShapeSettings_Create2(
    vertices: CPointer<JPHVec3>, verticesCount: UInt32,
    triangles: CPointer<JPHIndexedTriangle>, triangleCount: UInt32
): CPointer<Unit>

/** @brief 获取网格设置每叶最大三角形数 */
@FastNative
foreign func JPH_MeshShapeSettings_GetMaxTrianglesPerLeaf(settings: CPointer<Unit>): UInt32

/** @brief 设置网格设置每叶最大三角形数 */
@FastNative
foreign func JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取网格设置活动边阈值角余弦 */
@FastNative
foreign func JPH_MeshShapeSettings_GetActiveEdgeCosThresholdAngle(settings: CPointer<Unit>): Float32

/** @brief 设置网格设置活动边阈值角余弦 */
@FastNative
foreign func JPH_MeshShapeSettings_SetActiveEdgeCosThresholdAngle(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取网格设置是否按三角形存用户数据 */
@FastNative
foreign func JPH_MeshShapeSettings_GetPerTriangleUserData(settings: CPointer<Unit>): UInt8

/** @brief 设置网格设置是否按三角形存用户数据 */
@FastNative
foreign func JPH_MeshShapeSettings_SetPerTriangleUserData(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取网格设置构建质量（MeshShapeBuildQuality 枚举值） */
@FastNative
foreign func JPH_MeshShapeSettings_GetBuildQuality(settings: CPointer<Unit>): UInt32

/** @brief 设置网格设置构建质量 */
@FastNative
foreign func JPH_MeshShapeSettings_SetBuildQuality(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 修正网格设置（移除退化三角形等） */
@FastNative
foreign func JPH_MeshShapeSettings_Sanitize(settings: CPointer<Unit>): Unit

/** @brief 从设置创建网格形状 */
@FastNative
foreign func JPH_MeshShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取网格指定三角形的用户数据 */
@FastNative
foreign func JPH_MeshShape_GetTriangleUserData(shape: CPointer<Unit>, id: UInt32): UInt32

/** @brief 创建高度场形状设置（samples 高度采样数组，offset 偏移，scale 缩放，sampleCount 采样数，materialIndices 材质索引） */
@FastNative
foreign func JPH_HeightFieldShapeSettings_Create(
    samples: CPointer<Float32>, offset: CPointer<JPHVec3>, scale: CPointer<JPHVec3>,
    sampleCount: UInt32, materialIndices: CPointer<UInt8>
): CPointer<Unit>

/** @brief 计算高度场采样最小/最大值与量化比例 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_DetermineMinAndMaxSample(
    settings: CPointer<Unit>, pOutMinValue: CPointer<Float32>,
    pOutMaxValue: CPointer<Float32>, pOutQuantizationScale: CPointer<Float32>
): Unit

/** @brief 计算指定误差下的每采样位数 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_CalculateBitsPerSampleForError(
    settings: CPointer<Unit>, maxError: Float32
): UInt32

/** @brief 获取高度场偏移（输出 result） */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetOffset(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置高度场偏移 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetOffset(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取高度场缩放（输出 result） */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetScale(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置高度场缩放 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetScale(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取高度场采样数 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetSampleCount(settings: CPointer<Unit>): UInt32

/** @brief 设置高度场采样数 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetSampleCount(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取高度场最小高度 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetMinHeightValue(settings: CPointer<Unit>): Float32

/** @brief 设置高度场最小高度 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetMinHeightValue(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取高度场最大高度 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetMaxHeightValue(settings: CPointer<Unit>): Float32

/** @brief 设置高度场最大高度 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetMaxHeightValue(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取高度场块大小 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetBlockSize(settings: CPointer<Unit>): UInt32

/** @brief 设置高度场块大小 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetBlockSize(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取高度场每采样位数 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetBitsPerSample(settings: CPointer<Unit>): UInt32

/** @brief 设置高度场每采样位数 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetBitsPerSample(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取高度场活动边阈值角余弦 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle(settings: CPointer<Unit>): Float32

/** @brief 设置高度场活动边阈值角余弦 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 从设置创建高度场形状 */
@FastNative
foreign func JPH_HeightFieldShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取高度场采样数 */
@FastNative
foreign func JPH_HeightFieldShape_GetSampleCount(shape: CPointer<Unit>): UInt32

/** @brief 获取高度场块大小 */
@FastNative
foreign func JPH_HeightFieldShape_GetBlockSize(shape: CPointer<Unit>): UInt32

/** @brief 获取高度场指定格材质（x/y 格坐标） */
@FastNative
foreign func JPH_HeightFieldShape_GetMaterial(shape: CPointer<Unit>, x: UInt32, y: UInt32): CPointer<Unit>

/** @brief 获取高度场指定格位置（输出 result） */
@FastNative
foreign func JPH_HeightFieldShape_GetPosition(shape: CPointer<Unit>, x: UInt32, y: UInt32, result: CPointer<JPHVec3>): Unit

/** @brief 高度场指定格是否无碰撞 */
@FastNative
foreign func JPH_HeightFieldShape_IsNoCollision(shape: CPointer<Unit>, x: UInt32, y: UInt32): UInt8

/** @brief 将局部位置投影到高度场表面 */
@FastNative
foreign func JPH_HeightFieldShape_ProjectOntoSurface(
    shape: CPointer<Unit>, localPosition: CPointer<JPHVec3>,
    outSurfacePosition: CPointer<JPHVec3>, outSubShapeID: CPointer<UInt32>
): UInt8

/** @brief 获取高度场最小高度 */
@FastNative
foreign func JPH_HeightFieldShape_GetMinHeightValue(shape: CPointer<Unit>): Float32

/** @brief 获取高度场最大高度 */
@FastNative
foreign func JPH_HeightFieldShape_GetMaxHeightValue(shape: CPointer<Unit>): Float32

/** @brief 创建锥台胶囊体形状设置 */
@FastNative
foreign func JPH_TaperedCapsuleShapeSettings_Create(
    halfHeightOfTaperedCylinder: Float32, topRadius: Float32, bottomRadius: Float32
): CPointer<Unit>

/** @brief 从设置创建锥台胶囊体形状 */
@FastNative
foreign func JPH_TaperedCapsuleShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取锥台胶囊体顶半径 */
@FastNative
foreign func JPH_TaperedCapsuleShape_GetTopRadius(shape: CPointer<Unit>): Float32

/** @brief 获取锥台胶囊体底半径 */
@FastNative
foreign func JPH_TaperedCapsuleShape_GetBottomRadius(shape: CPointer<Unit>): Float32

/** @brief 获取锥台胶囊体半高 */
@FastNative
foreign func JPH_TaperedCapsuleShape_GetHalfHeight(shape: CPointer<Unit>): Float32

// =============================================================================
// 形状族：Compound / StaticCompound / MutableCompound / Decorated
// =============================================================================

/** @brief 向复合形状设置添加子形状（shapeSettings 形式） */
@FastNative
foreign func JPH_CompoundShapeSettings_AddShape(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    shapeSettings: CPointer<Unit>, userData: UInt32
): Unit

/** @brief 向复合形状设置添加子形状（已创建 shape 形式） */
@FastNative
foreign func JPH_CompoundShapeSettings_AddShape2(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    shape: CPointer<Unit>, userData: UInt32
): Unit

/** @brief 获取复合形状子形状数量 */
@FastNative
foreign func JPH_CompoundShape_GetNumSubShapes(shape: CPointer<Unit>): UInt32

/** @brief 获取复合形状指定子形状（输出子形状句柄/质心位置/旋转/用户数据） */
@FastNative
foreign func JPH_CompoundShape_GetSubShape(
    shape: CPointer<Unit>, index: UInt32,
    subShape: CPointer<CPointer<Unit>>, positionCOM: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: CPointer<UInt32>
): Unit

/** @brief 从子形状 ID 获取子形状索引 */
@FastNative
foreign func JPH_CompoundShape_GetSubShapeIndexFromID(
    shape: CPointer<Unit>, id: UInt32, remainder: CPointer<UInt32>
): UInt32

/** @brief 创建静态复合形状设置 */
@FastNative
foreign func JPH_StaticCompoundShapeSettings_Create(): CPointer<Unit>

/** @brief 从设置创建静态复合形状 */
@FastNative
foreign func JPH_StaticCompoundShape_Create(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建可变复合形状设置 */
@FastNative
foreign func JPH_MutableCompoundShapeSettings_Create(): CPointer<Unit>

/** @brief 从设置创建可变复合形状 */
@FastNative
foreign func JPH_MutableCompoundShape_Create(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 向可变复合形状添加子形状（返回子形状索引） */
@FastNative
foreign func JPH_MutableCompoundShape_AddShape(
    shape: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    child: CPointer<Unit>, userData: UInt32, index: UInt32
): UInt32

/** @brief 从可变复合形状移除子形状 */
@FastNative
foreign func JPH_MutableCompoundShape_RemoveShape(shape: CPointer<Unit>, index: UInt32): Unit

/** @brief 修改可变复合形状子形状位置/旋转 */
@FastNative
foreign func JPH_MutableCompoundShape_ModifyShape(
    shape: CPointer<Unit>, index: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit

/** @brief 修改可变复合形状子形状（含替换子形状） */
@FastNative
foreign func JPH_MutableCompoundShape_ModifyShape2(
    shape: CPointer<Unit>, index: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, newShape: CPointer<Unit>
): Unit

/** @brief 调整可变复合形状质心 */
@FastNative
foreign func JPH_MutableCompoundShape_AdjustCenterOfMass(shape: CPointer<Unit>): Unit

/** @brief 获取装饰形状的内部形状 */
@FastNative
foreign func JPH_DecoratedShape_GetInnerShape(shape: CPointer<Unit>): CPointer<Unit>

/** @brief 创建平移旋转形状设置（shapeSettings 形式） */
@FastNative
foreign func JPH_RotatedTranslatedShapeSettings_Create(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shapeSettings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建平移旋转形状设置（已创建 shape 形式） */
@FastNative
foreign func JPH_RotatedTranslatedShapeSettings_Create2(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shape: CPointer<Unit>
): CPointer<Unit>

/** @brief 从设置创建平移旋转形状 */
@FastNative
foreign func JPH_RotatedTranslatedShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建平移旋转形状 */
@FastNative
foreign func JPH_RotatedTranslatedShape_Create(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shape: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取平移旋转形状的平移（输出 position） */
@FastNative
foreign func JPH_RotatedTranslatedShape_GetPosition(shape: CPointer<Unit>, position: CPointer<JPHVec3>): Unit

/** @brief 获取平移旋转形状的旋转（输出 rotation） */
@FastNative
foreign func JPH_RotatedTranslatedShape_GetRotation(shape: CPointer<Unit>, rotation: CPointer<JPHQuat>): Unit

/** @brief 创建缩放形状设置（shapeSettings 形式） */
@FastNative
foreign func JPH_ScaledShapeSettings_Create(
    shapeSettings: CPointer<Unit>, scale: CPointer<JPHVec3>
): CPointer<Unit>

/** @brief 创建缩放形状设置（已创建 shape 形式） */
@FastNative
foreign func JPH_ScaledShapeSettings_Create2(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit>

/** @brief 从设置创建缩放形状 */
@FastNative
foreign func JPH_ScaledShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建缩放形状 */
@FastNative
foreign func JPH_ScaledShape_Create(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit>

/** @brief 获取缩放形状的缩放（输出 result） */
@FastNative
foreign func JPH_ScaledShape_GetScale(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 创建质心偏移形状设置（shapeSettings 形式） */
@FastNative
foreign func JPH_OffsetCenterOfMassShapeSettings_Create(
    offset: CPointer<JPHVec3>, shapeSettings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建质心偏移形状设置（已创建 shape 形式） */
@FastNative
foreign func JPH_OffsetCenterOfMassShapeSettings_Create2(
    offset: CPointer<JPHVec3>, shape: CPointer<Unit>
): CPointer<Unit>

/** @brief 从设置创建质心偏移形状 */
@FastNative
foreign func JPH_OffsetCenterOfMassShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 创建质心偏移形状 */
@FastNative
foreign func JPH_OffsetCenterOfMassShape_Create(offset: CPointer<JPHVec3>, shape: CPointer<Unit>): CPointer<Unit>

/** @brief 获取质心偏移形状的偏移（输出 result） */
@FastNative
foreign func JPH_OffsetCenterOfMassShape_GetOffset(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 创建空形状设置（centerOfMass 质心） */
@FastNative
foreign func JPH_EmptyShapeSettings_Create(centerOfMass: CPointer<JPHVec3>): CPointer<Unit>

/** @brief 从设置创建空形状 */
@FastNative
foreign func JPH_EmptyShapeSettings_CreateShape(settings: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// 刚体创建设置（BodyCreationSettings）完整
// =============================================================================

/** @brief 创建空刚体创建设置 */
@FastNative
foreign func JPH_BodyCreationSettings_Create(): CPointer<Unit>

/** @brief 创建刚体创建设置（形状设置形式） */
@FastNative
foreign func JPH_BodyCreationSettings_Create2(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    motionType: UInt32, objectLayer: UInt32
): CPointer<Unit>

/** @brief 获取初始位置（输出 result） */
@FastNative
foreign func JPH_BodyCreationSettings_GetPosition(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置初始位置 */
@FastNative
foreign func JPH_BodyCreationSettings_SetPosition(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取初始旋转（输出 result） */
@FastNative
foreign func JPH_BodyCreationSettings_GetRotation(settings: CPointer<Unit>, result: CPointer<JPHQuat>): Unit

/** @brief 设置初始旋转 */
@FastNative
foreign func JPH_BodyCreationSettings_SetRotation(settings: CPointer<Unit>, value: CPointer<JPHQuat>): Unit

/** @brief 获取初始线速度（输出 velocity） */
@FastNative
foreign func JPH_BodyCreationSettings_GetLinearVelocity(settings: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 设置初始线速度 */
@FastNative
foreign func JPH_BodyCreationSettings_SetLinearVelocity(settings: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 获取初始角速度（输出 velocity） */
@FastNative
foreign func JPH_BodyCreationSettings_GetAngularVelocity(settings: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 设置初始角速度 */
@FastNative
foreign func JPH_BodyCreationSettings_SetAngularVelocity(settings: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 获取用户数据 */
@FastNative
foreign func JPH_BodyCreationSettings_GetUserData(settings: CPointer<Unit>): UInt64

/** @brief 设置用户数据 */
@FastNative
foreign func JPH_BodyCreationSettings_SetUserData(settings: CPointer<Unit>, value: UInt64): Unit

/** @brief 获取对象层 */
@FastNative
foreign func JPH_BodyCreationSettings_GetObjectLayer(settings: CPointer<Unit>): UInt32

/** @brief 设置对象层 */
@FastNative
foreign func JPH_BodyCreationSettings_SetObjectLayer(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取碰撞组（输出 result） */
@FastNative
foreign func JPH_BodyCreationSettings_GetCollisionGroup(settings: CPointer<Unit>, result: CPointer<JPHCollisionGroup>): Unit

/** @brief 设置碰撞组 */
@FastNative
foreign func JPH_BodyCreationSettings_SetCollisionGroup(settings: CPointer<Unit>, value: CPointer<JPHCollisionGroup>): Unit

/** @brief 获取运动类型（MotionType 枚举值） */
@FastNative
foreign func JPH_BodyCreationSettings_GetMotionType(settings: CPointer<Unit>): UInt32

/** @brief 设置运动类型 */
@FastNative
foreign func JPH_BodyCreationSettings_SetMotionType(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取允许自由度（AllowedDOFs 位掩码） */
@FastNative
foreign func JPH_BodyCreationSettings_GetAllowedDOFs(settings: CPointer<Unit>): UInt32

/** @brief 设置允许自由度 */
@FastNative
foreign func JPH_BodyCreationSettings_SetAllowedDOFs(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 是否允许动态/运动学切换（非 0 = 允许） */
@FastNative
foreign func JPH_BodyCreationSettings_GetAllowDynamicOrKinematic(settings: CPointer<Unit>): UInt8

/** @brief 设置是否允许动态/运动学切换 */
@FastNative
foreign func JPH_BodyCreationSettings_SetAllowDynamicOrKinematic(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 是否传感器（非 0 = 传感器） */
@FastNative
foreign func JPH_BodyCreationSettings_GetIsSensor(settings: CPointer<Unit>): UInt8

/** @brief 设置是否传感器 */
@FastNative
foreign func JPH_BodyCreationSettings_SetIsSensor(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取是否允许休眠 */
@FastNative
foreign func JPH_BodyCreationSettings_GetAllowSleeping(settings: CPointer<Unit>): UInt8

/** @brief 设置是否允许休眠 */
@FastNative
foreign func JPH_BodyCreationSettings_SetAllowSleeping(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取摩擦系数 */
@FastNative
foreign func JPH_BodyCreationSettings_GetFriction(settings: CPointer<Unit>): Float32

/** @brief 设置摩擦系数 */
@FastNative
foreign func JPH_BodyCreationSettings_SetFriction(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取弹性系数 */
@FastNative
foreign func JPH_BodyCreationSettings_GetRestitution(settings: CPointer<Unit>): Float32

/** @brief 设置弹性系数 */
@FastNative
foreign func JPH_BodyCreationSettings_SetRestitution(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取线阻尼 */
@FastNative
foreign func JPH_BodyCreationSettings_GetLinearDamping(settings: CPointer<Unit>): Float32

/** @brief 设置线阻尼 */
@FastNative
foreign func JPH_BodyCreationSettings_SetLinearDamping(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取角阻尼 */
@FastNative
foreign func JPH_BodyCreationSettings_GetAngularDamping(settings: CPointer<Unit>): Float32

/** @brief 设置角阻尼 */
@FastNative
foreign func JPH_BodyCreationSettings_SetAngularDamping(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取最大线速度 */
@FastNative
foreign func JPH_BodyCreationSettings_GetMaxLinearVelocity(settings: CPointer<Unit>): Float32

/** @brief 设置最大线速度 */
@FastNative
foreign func JPH_BodyCreationSettings_SetMaxLinearVelocity(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取最大角速度 */
@FastNative
foreign func JPH_BodyCreationSettings_GetMaxAngularVelocity(settings: CPointer<Unit>): Float32

/** @brief 设置最大角速度 */
@FastNative
foreign func JPH_BodyCreationSettings_SetMaxAngularVelocity(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取重力因子 */
@FastNative
foreign func JPH_BodyCreationSettings_GetGravityFactor(settings: CPointer<Unit>): Float32

/** @brief 设置重力因子 */
@FastNative
foreign func JPH_BodyCreationSettings_SetGravityFactor(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取是否应用陀螺力 */
@FastNative
foreign func JPH_BodyCreationSettings_GetApplyGyroscopicForce(settings: CPointer<Unit>): UInt8

/** @brief 设置是否应用陀螺力 */
@FastNative
foreign func JPH_BodyCreationSettings_SetApplyGyroscopicForce(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取惯量乘数 */
@FastNative
foreign func JPH_BodyCreationSettings_GetInertiaMultiplier(settings: CPointer<Unit>): Float32

/** @brief 设置惯量乘数 */
@FastNative
foreign func JPH_BodyCreationSettings_SetInertiaMultiplier(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取质量属性覆盖方式（OverrideMassProperties 枚举值） */
@FastNative
foreign func JPH_BodyCreationSettings_GetOverrideMassProperties(settings: CPointer<Unit>): UInt32

/** @brief 设置质量属性覆盖方式 */
@FastNative
foreign func JPH_BodyCreationSettings_SetOverrideMassProperties(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取质量属性覆盖值（输出 result） */
@FastNative
foreign func JPH_BodyCreationSettings_GetMassPropertiesOverride(settings: CPointer<Unit>, result: CPointer<JPHMassProperties>): Unit

/** @brief 设置质量属性覆盖值 */
@FastNative
foreign func JPH_BodyCreationSettings_SetMassPropertiesOverride(settings: CPointer<Unit>, value: CPointer<JPHMassProperties>): Unit

/** @brief 获取运动质量（MotionQuality 枚举值） */
@FastNative
foreign func JPH_BodyCreationSettings_GetMotionQuality(settings: CPointer<Unit>): UInt32

/** @brief 设置运动质量 */
@FastNative
foreign func JPH_BodyCreationSettings_SetMotionQuality(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取增强内部边移除 */
@FastNative
foreign func JPH_BodyCreationSettings_GetEnhancedInternalEdgeRemoval(settings: CPointer<Unit>): UInt8

/** @brief 设置增强内部边移除 */
@FastNative
foreign func JPH_BodyCreationSettings_SetEnhancedInternalEdgeRemoval(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取运动学 vs 非动态碰撞 */
@FastNative
foreign func JPH_BodyCreationSettings_GetCollideKinematicVsNonDynamic(settings: CPointer<Unit>): UInt8

/** @brief 设置运动学 vs 非动态碰撞 */
@FastNative
foreign func JPH_BodyCreationSettings_SetCollideKinematicVsNonDynamic(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取使用流形简化 */
@FastNative
foreign func JPH_BodyCreationSettings_GetUseManifoldReduction(settings: CPointer<Unit>): UInt8

/** @brief 设置使用流形简化 */
@FastNative
foreign func JPH_BodyCreationSettings_SetUseManifoldReduction(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取速度迭代步数覆盖 */
@FastNative
foreign func JPH_BodyCreationSettings_GetNumVelocityStepsOverride(settings: CPointer<Unit>): UInt32

/** @brief 设置速度迭代步数覆盖 */
@FastNative
foreign func JPH_BodyCreationSettings_SetNumVelocityStepsOverride(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取位置迭代步数覆盖 */
@FastNative
foreign func JPH_BodyCreationSettings_GetNumPositionStepsOverride(settings: CPointer<Unit>): UInt32

/** @brief 设置位置迭代步数覆盖 */
@FastNative
foreign func JPH_BodyCreationSettings_SetNumPositionStepsOverride(settings: CPointer<Unit>, value: UInt32): Unit

// =============================================================================
// 刚体接口（BodyInterface）完整：创建/生命周期
// =============================================================================

/** @brief 创建刚体但不加入世界（需 AddBody） */
@FastNative
foreign func JPH_BodyInterface_CreateBody(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建刚体并分配指定 ID（需先激活 bodyID） */
@FastNative
foreign func JPH_BodyInterface_CreateBodyWithID(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建刚体（无 ID 版本，需 AssignBodyID） */
@FastNative
foreign func JPH_BodyInterface_CreateBodyWithoutID(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 销毁刚体（不要求先移除） */
@FastNative
foreign func JPH_BodyInterface_DestroyBodyWithoutID(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>
): Unit

/** @brief 为无 ID 刚体分配 BodyID */
@FastNative
foreign func JPH_BodyInterface_AssignBodyID(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>
): UInt8

/** @brief 为无 ID 刚体分配指定 BodyID */
@FastNative
foreign func JPH_BodyInterface_AssignBodyID2(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>, bodyID: UInt32
): UInt8

/** @brief 解除刚体的 BodyID 分配（转为无 ID 刚体） */
@FastNative
foreign func JPH_BodyInterface_UnassignBodyID(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): CPointer<Unit>

// =============================================================================
// 刚体接口（BodyInterface）：激活 / 查询
// =============================================================================

/** @brief 激活刚体 */
@FastNative
foreign func JPH_BodyInterface_ActivateBody(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit

/** @brief 休眠刚体 */
@FastNative
foreign func JPH_BodyInterface_DeactivateBody(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit

/** @brief 批量激活刚体（bodyIDs 数组） */
@FastNative
foreign func JPH_BodyInterface_ActivateBodies(
    bodyInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): Unit

/** @brief 批量休眠刚体 */
@FastNative
foreign func JPH_BodyInterface_DeactivateBodies(
    bodyInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): Unit

/** @brief 激活 AABB 范围内、指定层的刚体 */
@FastNative
foreign func JPH_BodyInterface_ActivateBodiesInAABox(
    bodyInterface: CPointer<Unit>, box: CPointer<JPHAABox>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): Unit

/** @brief 重置刚体休眠计时器 */
@FastNative
foreign func JPH_BodyInterface_ResetSleepTimer(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit

/** @brief 刚体是否已加入世界 */
@FastNative
foreign func JPH_BodyInterface_IsAdded(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8

/** @brief 获取刚体类型（BodyType 枚举值） */
@FastNative
foreign func JPH_BodyInterface_GetBodyType(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt32

/** @brief 获取刚体形状句柄 */
@FastNative
foreign func JPH_BodyInterface_GetShape(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): CPointer<Unit>

/** @brief 设置刚体形状（NotifyShapeChanged 的简化版） */
@FastNative
foreign func JPH_BodyInterface_SetShape(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, shape: CPointer<Unit>,
    updateMassProperties: UInt8, activationMode: UInt32
): Unit

/** @brief 通知形状已改变（更新质量/包围盒） */
@FastNative
foreign func JPH_BodyInterface_NotifyShapeChanged(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, previousCenterOfMass: CPointer<JPHVec3>,
    updateMassProperties: UInt8, activationMode: UInt32
): Unit

/** @brief 获取刚体材质句柄 */
@FastNative
foreign func JPH_BodyInterface_GetMaterial(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, subShapeID: UInt32
): CPointer<Unit>

/** @brief 获取质心位置（输出 result） */
@FastNative
foreign func JPH_BodyInterface_GetCenterOfMassTransform(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit

/** @brief 获取世界变换矩阵（输出 result） */
@FastNative
foreign func JPH_BodyInterface_GetWorldTransform(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit

/** @brief 获取位置与旋转（一次性输出） */
@FastNative
foreign func JPH_BodyInterface_GetPositionAndRotation(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    outPosition: CPointer<JPHVec3>, outRotation: CPointer<JPHQuat>
): Unit

/** @brief 设置位置与旋转（一次调用） */
@FastNative
foreign func JPH_BodyInterface_SetPositionAndRotation(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit

/** @brief 仅当位置/旋转变化时设置（用于每帧同步） */
@FastNative
foreign func JPH_BodyInterface_SetPositionAndRotationWhenChanged(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit

/** @brief 设置位置、旋转与速度（一次调用） */
@FastNative
foreign func JPH_BodyInterface_SetPositionRotationAndVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit

// =============================================================================
// 刚体接口（BodyInterface）：力 / 力矩 / 冲量
// =============================================================================

/** @brief 在质心施加力（牛顿） */
@FastNative
foreign func JPH_BodyInterface_AddForce(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, force: CPointer<JPHVec3>
): Unit

/** @brief 在指定点施加力（force 力，point 作用点） */
@FastNative
foreign func JPH_BodyInterface_AddForce2(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    force: CPointer<JPHVec3>, point: CPointer<JPHVec3>
): Unit

/** @brief 施加力矩（牛顿·米） */
@FastNative
foreign func JPH_BodyInterface_AddTorque(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, torque: CPointer<JPHVec3>
): Unit

/** @brief 同时施加力与力矩 */
@FastNative
foreign func JPH_BodyInterface_AddForceAndTorque(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    force: CPointer<JPHVec3>, torque: CPointer<JPHVec3>
): Unit

/** @brief 在质心施加冲量（冲量 = 力 × 时间） */
@FastNative
foreign func JPH_BodyInterface_AddImpulse(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, impulse: CPointer<JPHVec3>
): Unit

/** @brief 在指定点施加冲量 */
@FastNative
foreign func JPH_BodyInterface_AddImpulse2(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    impulse: CPointer<JPHVec3>, point: CPointer<JPHVec3>
): Unit

/** @brief 施加角冲量（冲量矩） */
@FastNative
foreign func JPH_BodyInterface_AddAngularImpulse(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularImpulse: CPointer<JPHVec3>
): Unit

/** @brief 增加线速度（直接修改速度） */
@FastNative
foreign func JPH_BodyInterface_AddLinearVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, linearVelocity: CPointer<JPHVec3>
): Unit

/** @brief 同时增加线速度与角速度 */
@FastNative
foreign func JPH_BodyInterface_AddLinearAndAngularVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 获取线速度与角速度（一次性输出） */
@FastNative
foreign func JPH_BodyInterface_GetLinearAndAngularVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    outLinearVelocity: CPointer<JPHVec3>, outAngularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 设置线速度与角速度（一次调用） */
@FastNative
foreign func JPH_BodyInterface_SetLinearAndAngularVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体上指定点的速度（点速度 = 线速度 + ω × r） */
@FastNative
foreign func JPH_BodyInterface_GetPointVelocity(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit

/** @brief 应用浮力冲量（软体用） */
@FastNative
foreign func JPH_BodyInterface_ApplyBuoyancyImpulse(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    surfacePosition: CPointer<JPHVec3>, surfaceNormal: CPointer<JPHVec3>,
    buoyancy: Float32, linearDrag: Float32, angularDrag: Float32,
    fluidVelocity: CPointer<JPHVec3>, gravity: CPointer<JPHVec3>, deltaTime: Float32
): UInt8

// =============================================================================
// 刚体接口（BodyInterface）：属性读写
// =============================================================================

/** @brief 获取运动质量（MotionQuality 枚举值） */
@FastNative
foreign func JPH_BodyInterface_GetMotionQuality(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt32

/** @brief 设置运动质量 */
@FastNative
foreign func JPH_BodyInterface_SetMotionQuality(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: UInt32
): Unit

/** @brief 获取是否传感器 */
@FastNative
foreign func JPH_BodyInterface_IsSensor(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8

/** @brief 设置是否传感器 */
@FastNative
foreign func JPH_BodyInterface_SetIsSensor(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, isSensor: UInt8
): Unit

/** @brief 获取碰撞组（输出 result） */
@FastNative
foreign func JPH_BodyInterface_GetCollisionGroup(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHCollisionGroup>
): Unit

/** @brief 设置碰撞组 */
@FastNative
foreign func JPH_BodyInterface_SetCollisionGroup(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: CPointer<JPHCollisionGroup>
): Unit

/** @brief 获取用户数据 */
@FastNative
foreign func JPH_BodyInterface_GetUserData(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt64

/** @brief 设置用户数据 */
@FastNative
foreign func JPH_BodyInterface_SetUserData(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, userData: UInt64
): Unit

/** @brief 获取重力因子 */
@FastNative
foreign func JPH_BodyInterface_GetGravityFactor(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Float32

/** @brief 设置重力因子 */
@FastNative
foreign func JPH_BodyInterface_SetGravityFactor(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, gravityFactor: Float32
): Unit

/** @brief 获取是否使用流形简化 */
@FastNative
foreign func JPH_BodyInterface_GetUseManifoldReduction(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8

/** @brief 设置是否使用流形简化 */
@FastNative
foreign func JPH_BodyInterface_SetUseManifoldReduction(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: UInt8
): Unit

/** @brief 获取逆惯量（输出 result） */
@FastNative
foreign func JPH_BodyInterface_GetInverseInertia(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit

/** @brief 运动学刚体移动到指定位置/旋转（每帧调用） */
@FastNative
foreign func JPH_BodyInterface_MoveKinematic(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    targetPosition: CPointer<JPHVec3>, targetRotation: CPointer<JPHQuat>, deltaTime: Float32
): Unit

/** @brief 使接触缓存失效（形状/变换改变后调用） */
@FastNative
foreign func JPH_BodyInterface_InvalidateContactCache(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit

// =============================================================================
// 刚体接口（BodyInterface）：软体
// =============================================================================

/** @brief 创建软体（不加入世界） */
@FastNative
foreign func JPH_BodyInterface_CreateSoftBody(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建软体并分配指定 ID */
@FastNative
foreign func JPH_BodyInterface_CreateSoftBodyWithID(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建软体（无 ID 版本） */
@FastNative
foreign func JPH_BodyInterface_CreateSoftBodyWithoutID(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 创建并添加软体到世界（一步完成） */
@FastNative
foreign func JPH_BodyInterface_CreateAndAddSoftBody(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>, activationMode: UInt32
): UInt32

// =============================================================================
// 刚体锁接口（BodyLockInterface）
// =============================================================================

/** @brief 获取刚体只读锁（锁内刚体数据只读安全） */
@FastNative
foreign func JPH_BodyLockInterface_LockRead(
    lockInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHBodyLockRead>
): Unit

/** @brief 获取刚体写锁（锁内刚体数据可读写） */
@FastNative
foreign func JPH_BodyLockInterface_LockWrite(
    lockInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHBodyLockWrite>
): Unit

/** @brief 批量获取只读锁 */
@FastNative
foreign func JPH_BodyLockInterface_LockMultiRead(
    lockInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): CPointer<Unit>

/** @brief 批量获取写锁 */
@FastNative
foreign func JPH_BodyLockInterface_LockMultiWrite(
    lockInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): CPointer<Unit>

/** @brief 释放只读锁 */
@FastNative
foreign func JPH_BodyLockInterface_UnlockRead(
    lockInterface: CPointer<Unit>, ioLock: CPointer<Unit>
): Unit

/** @brief 释放写锁 */
@FastNative
foreign func JPH_BodyLockInterface_UnlockWrite(
    lockInterface: CPointer<Unit>, ioLock: CPointer<Unit>
): Unit

/** @brief 销毁批量只读锁 */
@FastNative
foreign func JPH_BodyLockMultiRead_Destroy(multiLock: CPointer<Unit>): Unit

/** @brief 获取批量只读锁中的刚体（输出 body 句柄） */
@FastNative
foreign func JPH_BodyLockMultiRead_GetBody(
    multiLock: CPointer<Unit>, bodyIndex: UInt32
): CPointer<Unit>

/** @brief 销毁批量写锁 */
@FastNative
foreign func JPH_BodyLockMultiWrite_Destroy(multiLock: CPointer<Unit>): Unit

/** @brief 获取批量写锁中的刚体（输出 body 句柄） */
@FastNative
foreign func JPH_BodyLockMultiWrite_GetBody(
    multiLock: CPointer<Unit>, bodyIndex: UInt32
): CPointer<Unit>

// =============================================================================
// 宽相位查询（BroadPhaseQuery）
// =============================================================================

/** @brief 宽相位射线检测（返回命中，hit 输出） */
@FastNative
foreign func JPH_BroadPhaseQuery_CastRay(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8

/** @brief 宽相位射线检测（带收集器回调版本） */
@FastNative
foreign func JPH_BroadPhaseQuery_CastRay2(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    collectorType: UInt32, callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8

/** @brief 宽相位 AABB 碰撞查询（box 与刚体包围盒相交检测） */
@FastNative
foreign func JPH_BroadPhaseQuery_CollideAABox(
    query: CPointer<Unit>, box: CPointer<JPHAABox>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8

/** @brief 宽相位点碰撞查询 */
@FastNative
foreign func JPH_BroadPhaseQuery_CollidePoint(
    query: CPointer<Unit>, point: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8

/** @brief 宽相位球碰撞查询（球与刚体包围盒相交检测） */
@FastNative
foreign func JPH_BroadPhaseQuery_CollideSphere(
    query: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8

// =============================================================================
// 窄相查询扩展（NarrowPhaseQuery）：完整碰撞查询
// =============================================================================

/** @brief 窄相射线检测（带收集器回调版本，对应 joltc.h JPH_NarrowPhaseQuery_CastRay2） */
@FastNative
foreign func JPH_NarrowPhaseQuery_CastRay2(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 窄相点碰撞查询（带收集器回调版本，对应 joltc.h JPH_NarrowPhaseQuery_CollidePoint） */
@FastNative
foreign func JPH_NarrowPhaseQuery_CollidePoint(
    query: CPointer<Unit>, point: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 窄相形状碰撞查询（带收集器回调版本，对应 joltc.h JPH_NarrowPhaseQuery_CollideShape） */
@FastNative
foreign func JPH_NarrowPhaseQuery_CollideShape(
    query: CPointer<Unit>, shape: CPointer<Unit>, shapeScale: CPointer<JPHVec3>,
    centerOfMassTransform: CPointer<JPHMat4>, collideShapeSettings: CPointer<JPHCollideShapeSettings>,
    baseOffset: CPointer<JPHVec3>, callback: CPointer<Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>,
    shapeFilter: CPointer<Unit>
): UInt8

/** @brief 窄相形状投射（带收集器回调版本，对应 joltc.h JPH_NarrowPhaseQuery_CastShape） */
@FastNative
foreign func JPH_NarrowPhaseQuery_CastShape(
    query: CPointer<Unit>, shape: CPointer<Unit>,
    worldTransform: CPointer<JPHMat4>, direction: CPointer<JPHVec3>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>, baseOffset: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

// =============================================================================
// 约束基类（Constraint / TwoBodyConstraint）
// =============================================================================

/** @brief 销毁约束 */
@FastNative
foreign func JPH_Constraint_Destroy(constraint: CPointer<Unit>): Unit

/** @brief 获取约束类型（ConstraintType 枚举值） */
@FastNative
foreign func JPH_Constraint_GetType(constraint: CPointer<Unit>): UInt32

/** @brief 获取约束子类型（ConstraintSubType 枚举值） */
@FastNative
foreign func JPH_Constraint_GetSubType(constraint: CPointer<Unit>): UInt32

/** @brief 获取约束优先级 */
@FastNative
foreign func JPH_Constraint_GetConstraintPriority(constraint: CPointer<Unit>): UInt32

/** @brief 设置约束优先级 */
@FastNative
foreign func JPH_Constraint_SetConstraintPriority(constraint: CPointer<Unit>, priority: UInt32): Unit

/** @brief 获取速度迭代步数覆盖 */
@FastNative
foreign func JPH_Constraint_GetNumVelocityStepsOverride(constraint: CPointer<Unit>): UInt32

/** @brief 设置速度迭代步数覆盖 */
@FastNative
foreign func JPH_Constraint_SetNumVelocityStepsOverride(constraint: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取位置迭代步数覆盖 */
@FastNative
foreign func JPH_Constraint_GetNumPositionStepsOverride(constraint: CPointer<Unit>): UInt32

/** @brief 设置位置迭代步数覆盖 */
@FastNative
foreign func JPH_Constraint_SetNumPositionStepsOverride(constraint: CPointer<Unit>, value: UInt32): Unit

/** @brief 约束是否启用（非 0 = 启用） */
@FastNative
foreign func JPH_Constraint_GetEnabled(constraint: CPointer<Unit>): UInt8

/** @brief 设置约束是否启用 */
@FastNative
foreign func JPH_Constraint_SetEnabled(constraint: CPointer<Unit>, enabled: UInt8): Unit

/** @brief 获取约束用户数据 */
@FastNative
foreign func JPH_Constraint_GetUserData(constraint: CPointer<Unit>): UInt64

/** @brief 设置约束用户数据 */
@FastNative
foreign func JPH_Constraint_SetUserData(constraint: CPointer<Unit>, userData: UInt64): Unit

/** @brief 通知约束关联刚体形状已改变 */
@FastNative
foreign func JPH_Constraint_NotifyShapeChanged(
    constraint: CPointer<Unit>, bodyID: UInt32, deltaCOM: CPointer<JPHVec3>
): Unit

/** @brief 重置约束热启动缓存 */
@FastNative
foreign func JPH_Constraint_ResetWarmStart(constraint: CPointer<Unit>): Unit

/** @brief 约束是否活动（非 0 = 活动） */
@FastNative
foreign func JPH_Constraint_IsActive(constraint: CPointer<Unit>): UInt8

/** @brief 建立速度约束（求解内部使用） */
@FastNative
foreign func JPH_Constraint_SetupVelocityConstraint(constraint: CPointer<Unit>, deltaTime: Float32): Unit

/** @brief 热启动速度约束（求解内部使用） */
@FastNative
foreign func JPH_Constraint_WarmStartVelocityConstraint(
    constraint: CPointer<Unit>, warmStartImpulseRatio: Float32
): Unit

/** @brief 求解速度约束（返回是否收敛） */
@FastNative
foreign func JPH_Constraint_SolveVelocityConstraint(constraint: CPointer<Unit>, deltaTime: Float32): UInt8

/** @brief 求解位置约束（返回是否收敛） */
@FastNative
foreign func JPH_Constraint_SolvePositionConstraint(
    constraint: CPointer<Unit>, deltaTime: Float32, baumgarte: Float32
): UInt8

/** @brief 获取双刚体约束的刚体 1 */
@FastNative
foreign func JPH_TwoBodyConstraint_GetBody1(constraint: CPointer<Unit>): CPointer<Unit>

/** @brief 获取双刚体约束的刚体 2 */
@FastNative
foreign func JPH_TwoBodyConstraint_GetBody2(constraint: CPointer<Unit>): CPointer<Unit>

/** @brief 获取约束到刚体 1 的变换矩阵 */
@FastNative
foreign func JPH_TwoBodyConstraint_GetConstraintToBody1Matrix(
    constraint: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit

/** @brief 获取约束到刚体 2 的变换矩阵 */
@FastNative
foreign func JPH_TwoBodyConstraint_GetConstraintToBody2Matrix(
    constraint: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit

// =============================================================================
// 固定约束（FixedConstraint）
// =============================================================================

/** @brief 初始化固定约束设置 */
@FastNative
foreign func JPH_FixedConstraintSettings_Init(settings: CPointer<JPHFixedConstraintSettings>): Unit

/** @brief 创建固定约束（焊接 body1 与 body2） */
@FastNative
foreign func JPH_FixedConstraint_Create(
    settings: CPointer<JPHFixedConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取固定约束设置 */
@FastNative
foreign func JPH_FixedConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHFixedConstraintSettings>
): Unit

/** @brief 获取固定约束位置 lambda（求解冲量） */
@FastNative
foreign func JPH_FixedConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取固定约束旋转 lambda */
@FastNative
foreign func JPH_FixedConstraint_GetTotalLambdaRotation(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

// =============================================================================
// 距离约束（DistanceConstraint）
// =============================================================================

/** @brief 初始化距离约束设置 */
@FastNative
foreign func JPH_DistanceConstraintSettings_Init(settings: CPointer<JPHDistanceConstraintSettings>): Unit

/** @brief 创建距离约束 */
@FastNative
foreign func JPH_DistanceConstraint_Create(
    settings: CPointer<JPHDistanceConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取距离约束设置 */
@FastNative
foreign func JPH_DistanceConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHDistanceConstraintSettings>
): Unit

/** @brief 设置距离约束的距离范围 */
@FastNative
foreign func JPH_DistanceConstraint_SetDistance(
    constraint: CPointer<Unit>, minDistance: Float32, maxDistance: Float32
): Unit

/** @brief 获取最小距离 */
@FastNative
foreign func JPH_DistanceConstraint_GetMinDistance(constraint: CPointer<Unit>): Float32

/** @brief 获取最大距离 */
@FastNative
foreign func JPH_DistanceConstraint_GetMaxDistance(constraint: CPointer<Unit>): Float32

/** @brief 获取限位弹簧设置 */
@FastNative
foreign func JPH_DistanceConstraint_GetLimitsSpringSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit

/** @brief 设置限位弹簧设置 */
@FastNative
foreign func JPH_DistanceConstraint_SetLimitsSpringSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit

/** @brief 获取位置 lambda */
@FastNative
foreign func JPH_DistanceConstraint_GetTotalLambdaPosition(constraint: CPointer<Unit>): Float32

// =============================================================================
// 点约束（PointConstraint）
// =============================================================================

/** @brief 初始化点约束设置 */
@FastNative
foreign func JPH_PointConstraintSettings_Init(settings: CPointer<JPHPointConstraintSettings>): Unit

/** @brief 创建点约束（球关节） */
@FastNative
foreign func JPH_PointConstraint_Create(
    settings: CPointer<JPHPointConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取点约束设置 */
@FastNative
foreign func JPH_PointConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHPointConstraintSettings>
): Unit

/** @brief 设置刚体 1 上的锚点（space 指定空间） */
@FastNative
foreign func JPH_PointConstraint_SetPoint1(
    constraint: CPointer<Unit>, space: UInt32, value: CPointer<JPHVec3>
): Unit

/** @brief 设置刚体 2 上的锚点 */
@FastNative
foreign func JPH_PointConstraint_SetPoint2(
    constraint: CPointer<Unit>, space: UInt32, value: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 1 局部空间锚点 */
@FastNative
foreign func JPH_PointConstraint_GetLocalSpacePoint1(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 2 局部空间锚点 */
@FastNative
foreign func JPH_PointConstraint_GetLocalSpacePoint2(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取位置 lambda */
@FastNative
foreign func JPH_PointConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

// =============================================================================
// 铰链约束（HingeConstraint）
// =============================================================================

/** @brief 初始化铰链约束设置 */
@FastNative
foreign func JPH_HingeConstraintSettings_Init(settings: CPointer<JPHHingeConstraintSettings>): Unit

/** @brief 创建铰链约束 */
@FastNative
foreign func JPH_HingeConstraint_Create(
    settings: CPointer<JPHHingeConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取铰链约束设置 */
@FastNative
foreign func JPH_HingeConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHHingeConstraintSettings>
): Unit

/** @brief 获取刚体 1 局部空间锚点 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpacePoint1(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 2 局部空间锚点 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpacePoint2(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 1 局部空间铰链轴 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpaceHingeAxis1(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 2 局部空间铰链轴 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpaceHingeAxis2(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 1 局部空间法线轴 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpaceNormalAxis1(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 2 局部空间法线轴 */
@FastNative
foreign func JPH_HingeConstraint_GetLocalSpaceNormalAxis2(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取当前旋转角（弧度） */
@FastNative
foreign func JPH_HingeConstraint_GetCurrentAngle(constraint: CPointer<Unit>): Float32

/** @brief 设置最大摩擦扭矩 */
@FastNative
foreign func JPH_HingeConstraint_SetMaxFrictionTorque(
    constraint: CPointer<Unit>, frictionTorque: Float32
): Unit

/** @brief 获取最大摩擦扭矩 */
@FastNative
foreign func JPH_HingeConstraint_GetMaxFrictionTorque(constraint: CPointer<Unit>): Float32

/** @brief 设置电机设置 */
@FastNative
foreign func JPH_HingeConstraint_SetMotorSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHMotorSettings>
): Unit

/** @brief 获取电机设置 */
@FastNative
foreign func JPH_HingeConstraint_GetMotorSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHMotorSettings>
): Unit

/** @brief 设置电机状态（Off/Velocity/Position） */
@FastNative
foreign func JPH_HingeConstraint_SetMotorState(constraint: CPointer<Unit>, state: UInt32): Unit

/** @brief 获取电机状态 */
@FastNative
foreign func JPH_HingeConstraint_GetMotorState(constraint: CPointer<Unit>): UInt32

/** @brief 设置目标角速度（速度电机） */
@FastNative
foreign func JPH_HingeConstraint_SetTargetAngularVelocity(
    constraint: CPointer<Unit>, angularVelocity: Float32
): Unit

/** @brief 获取目标角速度 */
@FastNative
foreign func JPH_HingeConstraint_GetTargetAngularVelocity(constraint: CPointer<Unit>): Float32

/** @brief 设置目标角度（位置电机） */
@FastNative
foreign func JPH_HingeConstraint_SetTargetAngle(constraint: CPointer<Unit>, angle: Float32): Unit

/** @brief 获取目标角度 */
@FastNative
foreign func JPH_HingeConstraint_GetTargetAngle(constraint: CPointer<Unit>): Float32

/** @brief 设置旋转角度限位 */
@FastNative
foreign func JPH_HingeConstraint_SetLimits(
    constraint: CPointer<Unit>, inLimitsMin: Float32, inLimitsMax: Float32
): Unit

/** @brief 获取最小角度限位 */
@FastNative
foreign func JPH_HingeConstraint_GetLimitsMin(constraint: CPointer<Unit>): Float32

/** @brief 获取最大角度限位 */
@FastNative
foreign func JPH_HingeConstraint_GetLimitsMax(constraint: CPointer<Unit>): Float32

/** @brief 是否有角度限位 */
@FastNative
foreign func JPH_HingeConstraint_HasLimits(constraint: CPointer<Unit>): UInt8

/** @brief 获取限位弹簧设置 */
@FastNative
foreign func JPH_HingeConstraint_GetLimitsSpringSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit

/** @brief 设置限位弹簧设置 */
@FastNative
foreign func JPH_HingeConstraint_SetLimitsSpringSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit

/** @brief 获取位置 lambda */
@FastNative
foreign func JPH_HingeConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转 lambda（rotation 为 2 元素数组指针） */
@FastNative
foreign func JPH_HingeConstraint_GetTotalLambdaRotation(
    constraint: CPointer<Unit>, rotation: CPointer<Float32>
): Unit

/** @brief 获取旋转限位 lambda */
@FastNative
foreign func JPH_HingeConstraint_GetTotalLambdaRotationLimits(constraint: CPointer<Unit>): Float32

/** @brief 获取电机 lambda */
@FastNative
foreign func JPH_HingeConstraint_GetTotalLambdaMotor(constraint: CPointer<Unit>): Float32

// =============================================================================
// 滑块约束（SliderConstraint）
// =============================================================================

/** @brief 初始化滑块约束设置 */
@FastNative
foreign func JPH_SliderConstraintSettings_Init(settings: CPointer<JPHSliderConstraintSettings>): Unit

/** @brief 设置滑块约束的滑动轴 */
@FastNative
foreign func JPH_SliderConstraintSettings_SetSliderAxis(
    settings: CPointer<JPHSliderConstraintSettings>, axis: CPointer<JPHVec3>
): Unit

/** @brief 创建滑块约束 */
@FastNative
foreign func JPH_SliderConstraint_Create(
    settings: CPointer<JPHSliderConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取滑块约束设置 */
@FastNative
foreign func JPH_SliderConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSliderConstraintSettings>
): Unit

/** @brief 获取当前位置 */
@FastNative
foreign func JPH_SliderConstraint_GetCurrentPosition(constraint: CPointer<Unit>): Float32

/** @brief 设置最大摩擦力 */
@FastNative
foreign func JPH_SliderConstraint_SetMaxFrictionForce(
    constraint: CPointer<Unit>, frictionForce: Float32
): Unit

/** @brief 获取最大摩擦力 */
@FastNative
foreign func JPH_SliderConstraint_GetMaxFrictionForce(constraint: CPointer<Unit>): Float32

/** @brief 设置电机设置 */
@FastNative
foreign func JPH_SliderConstraint_SetMotorSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHMotorSettings>
): Unit

/** @brief 获取电机设置 */
@FastNative
foreign func JPH_SliderConstraint_GetMotorSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHMotorSettings>
): Unit

/** @brief 设置电机状态 */
@FastNative
foreign func JPH_SliderConstraint_SetMotorState(constraint: CPointer<Unit>, state: UInt32): Unit

/** @brief 获取电机状态 */
@FastNative
foreign func JPH_SliderConstraint_GetMotorState(constraint: CPointer<Unit>): UInt32

/** @brief 设置目标速度（速度电机） */
@FastNative
foreign func JPH_SliderConstraint_SetTargetVelocity(constraint: CPointer<Unit>, velocity: Float32): Unit

/** @brief 获取目标速度 */
@FastNative
foreign func JPH_SliderConstraint_GetTargetVelocity(constraint: CPointer<Unit>): Float32

/** @brief 设置目标位置（位置电机） */
@FastNative
foreign func JPH_SliderConstraint_SetTargetPosition(constraint: CPointer<Unit>, position: Float32): Unit

/** @brief 获取目标位置 */
@FastNative
foreign func JPH_SliderConstraint_GetTargetPosition(constraint: CPointer<Unit>): Float32

/** @brief 设置位置限位 */
@FastNative
foreign func JPH_SliderConstraint_SetLimits(
    constraint: CPointer<Unit>, inLimitsMin: Float32, inLimitsMax: Float32
): Unit

/** @brief 获取最小位置限位 */
@FastNative
foreign func JPH_SliderConstraint_GetLimitsMin(constraint: CPointer<Unit>): Float32

/** @brief 获取最大位置限位 */
@FastNative
foreign func JPH_SliderConstraint_GetLimitsMax(constraint: CPointer<Unit>): Float32

/** @brief 是否有位置限位 */
@FastNative
foreign func JPH_SliderConstraint_HasLimits(constraint: CPointer<Unit>): UInt8

/** @brief 获取限位弹簧设置 */
@FastNative
foreign func JPH_SliderConstraint_GetLimitsSpringSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit

/** @brief 设置限位弹簧设置 */
@FastNative
foreign func JPH_SliderConstraint_SetLimitsSpringSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit

/** @brief 获取位置 lambda（position 为 2 元素数组指针） */
@FastNative
foreign func JPH_SliderConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, position: CPointer<Float32>
): Unit

/** @brief 获取位置限位 lambda */
@FastNative
foreign func JPH_SliderConstraint_GetTotalLambdaPositionLimits(constraint: CPointer<Unit>): Float32

/** @brief 获取旋转 lambda */
@FastNative
foreign func JPH_SliderConstraint_GetTotalLambdaRotation(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取电机 lambda */
@FastNative
foreign func JPH_SliderConstraint_GetTotalLambdaMotor(constraint: CPointer<Unit>): Float32

// =============================================================================
// 锥约束（ConeConstraint）
// =============================================================================

/** @brief 初始化锥约束设置 */
@FastNative
foreign func JPH_ConeConstraintSettings_Init(settings: CPointer<JPHConeConstraintSettings>): Unit

/** @brief 创建锥约束 */
@FastNative
foreign func JPH_ConeConstraint_Create(
    settings: CPointer<JPHConeConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取锥约束设置 */
@FastNative
foreign func JPH_ConeConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHConeConstraintSettings>
): Unit

/** @brief 设置半锥角（弧度） */
@FastNative
foreign func JPH_ConeConstraint_SetHalfConeAngle(constraint: CPointer<Unit>, halfConeAngle: Float32): Unit

/** @brief 获取半锥角余弦值 */
@FastNative
foreign func JPH_ConeConstraint_GetCosHalfConeAngle(constraint: CPointer<Unit>): Float32

/** @brief 获取位置 lambda */
@FastNative
foreign func JPH_ConeConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转 lambda */
@FastNative
foreign func JPH_ConeConstraint_GetTotalLambdaRotation(constraint: CPointer<Unit>): Float32

// =============================================================================
// 摆动-扭转约束（SwingTwistConstraint）
// =============================================================================

/** @brief 初始化摆动-扭转约束设置 */
@FastNative
foreign func JPH_SwingTwistConstraintSettings_Init(settings: CPointer<JPHSwingTwistConstraintSettings>): Unit

/** @brief 创建摆动-扭转约束 */
@FastNative
foreign func JPH_SwingTwistConstraint_Create(
    settings: CPointer<JPHSwingTwistConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取摆动-扭转约束设置 */
@FastNative
foreign func JPH_SwingTwistConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSwingTwistConstraintSettings>
): Unit

/** @brief 获取法线方向半锥角 */
@FastNative
foreign func JPH_SwingTwistConstraint_GetNormalHalfConeAngle(constraint: CPointer<Unit>): Float32

/** @brief 获取位置 lambda */
@FastNative
foreign func JPH_SwingTwistConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取扭转 lambda */
@FastNative
foreign func JPH_SwingTwistConstraint_GetTotalLambdaTwist(constraint: CPointer<Unit>): Float32

/** @brief 获取 Y 轴摆动 lambda */
@FastNative
foreign func JPH_SwingTwistConstraint_GetTotalLambdaSwingY(constraint: CPointer<Unit>): Float32

/** @brief 获取 Z 轴摆动 lambda */
@FastNative
foreign func JPH_SwingTwistConstraint_GetTotalLambdaSwingZ(constraint: CPointer<Unit>): Float32

/** @brief 获取电机 lambda */
@FastNative
foreign func JPH_SwingTwistConstraint_GetTotalLambdaMotor(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

// =============================================================================
// 六自由度约束（SixDOFConstraint）
// =============================================================================

/** @brief 初始化六自由度约束设置 */
@FastNative
foreign func JPH_SixDOFConstraintSettings_Init(settings: CPointer<JPHSixDOFConstraintSettings>): Unit

/** @brief 将指定轴设为自由（不约束） */
@FastNative
foreign func JPH_SixDOFConstraintSettings_MakeFreeAxis(settings: CPointer<Unit>, axis: UInt32): Unit

/** @brief 指定轴是否自由 */
@FastNative
foreign func JPH_SixDOFConstraintSettings_IsFreeAxis(settings: CPointer<Unit>, axis: UInt32): UInt8

/** @brief 将指定轴设为固定（锁定） */
@FastNative
foreign func JPH_SixDOFConstraintSettings_MakeFixedAxis(settings: CPointer<Unit>, axis: UInt32): Unit

/** @brief 指定轴是否固定 */
@FastNative
foreign func JPH_SixDOFConstraintSettings_IsFixedAxis(settings: CPointer<Unit>, axis: UInt32): UInt8

/** @brief 将指定轴设为受限（min/max 限位） */
@FastNative
foreign func JPH_SixDOFConstraintSettings_SetLimitedAxis(
    settings: CPointer<Unit>, axis: UInt32, min: Float32, max: Float32
): Unit

/** @brief 创建六自由度约束 */
@FastNative
foreign func JPH_SixDOFConstraint_Create(
    settings: CPointer<JPHSixDOFConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取六自由度约束设置 */
@FastNative
foreign func JPH_SixDOFConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSixDOFConstraintSettings>
): Unit

/** @brief 获取指定轴最小限位 */
@FastNative
foreign func JPH_SixDOFConstraint_GetLimitsMin(constraint: CPointer<Unit>, axis: UInt32): Float32

/** @brief 获取指定轴最大限位 */
@FastNative
foreign func JPH_SixDOFConstraint_GetLimitsMax(constraint: CPointer<Unit>, axis: UInt32): Float32

/** @brief 获取平移 lambda */
@FastNative
foreign func JPH_SixDOFConstraint_GetTotalLambdaPosition(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转 lambda */
@FastNative
foreign func JPH_SixDOFConstraint_GetTotalLambdaRotation(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取平移电机 lambda */
@FastNative
foreign func JPH_SixDOFConstraint_GetTotalLambdaMotorTranslation(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转电机 lambda */
@FastNative
foreign func JPH_SixDOFConstraint_GetTotalLambdaMotorRotation(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取平移限位最小值 */
@FastNative
foreign func JPH_SixDOFConstraint_GetTranslationLimitsMin(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取平移限位最大值 */
@FastNative
foreign func JPH_SixDOFConstraint_GetTranslationLimitsMax(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转限位最小值 */
@FastNative
foreign func JPH_SixDOFConstraint_GetRotationLimitsMin(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取旋转限位最大值 */
@FastNative
foreign func JPH_SixDOFConstraint_GetRotationLimitsMax(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 指定轴是否固定 */
@FastNative
foreign func JPH_SixDOFConstraint_IsFixedAxis(constraint: CPointer<Unit>, axis: UInt32): UInt8

/** @brief 指定轴是否自由 */
@FastNative
foreign func JPH_SixDOFConstraint_IsFreeAxis(constraint: CPointer<Unit>, axis: UInt32): UInt8

/** @brief 获取指定轴限位弹簧设置 */
@FastNative
foreign func JPH_SixDOFConstraint_GetLimitsSpringSettings(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>, axis: UInt32
): Unit

/** @brief 设置指定轴限位弹簧设置 */
@FastNative
foreign func JPH_SixDOFConstraint_SetLimitsSpringSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>, axis: UInt32
): Unit

/** @brief 设置指定轴最大摩擦 */
@FastNative
foreign func JPH_SixDOFConstraint_SetMaxFriction(
    constraint: CPointer<Unit>, axis: UInt32, inFriction: Float32
): Unit

/** @brief 获取指定轴最大摩擦 */
@FastNative
foreign func JPH_SixDOFConstraint_GetMaxFriction(constraint: CPointer<Unit>, axis: UInt32): Float32

/** @brief 获取约束空间内的旋转 */
@FastNative
foreign func JPH_SixDOFConstraint_GetRotationInConstraintSpace(
    constraint: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit

/** @brief 获取指定轴电机设置 */
@FastNative
foreign func JPH_SixDOFConstraint_GetMotorSettings(
    constraint: CPointer<Unit>, axis: UInt32, settings: CPointer<JPHMotorSettings>
): Unit

/** @brief 设置指定轴电机状态 */
@FastNative
foreign func JPH_SixDOFConstraint_SetMotorState(
    constraint: CPointer<Unit>, axis: UInt32, state: UInt32
): Unit

/** @brief 获取指定轴电机状态 */
@FastNative
foreign func JPH_SixDOFConstraint_GetMotorState(constraint: CPointer<Unit>, axis: UInt32): UInt32

/** @brief 设置目标线速度（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_SetTargetVelocityCS(
    constraint: CPointer<Unit>, inVelocity: CPointer<JPHVec3>
): Unit

/** @brief 获取目标线速度（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_GetTargetVelocityCS(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 设置目标角速度（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_SetTargetAngularVelocityCS(
    constraint: CPointer<Unit>, inAngularVelocity: CPointer<JPHVec3>
): Unit

/** @brief 获取目标角速度（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_GetTargetAngularVelocityCS(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 设置目标位置（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_SetTargetPositionCS(
    constraint: CPointer<Unit>, inPosition: CPointer<JPHVec3>
): Unit

/** @brief 获取目标位置（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_GetTargetPositionCS(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 设置目标朝向（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_SetTargetOrientationCS(
    constraint: CPointer<Unit>, inOrientation: CPointer<JPHQuat>
): Unit

/** @brief 获取目标朝向（约束空间） */
@FastNative
foreign func JPH_SixDOFConstraint_GetTargetOrientationCS(
    constraint: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit

/** @brief 设置目标朝向（刚体 1 空间） */
@FastNative
foreign func JPH_SixDOFConstraint_SetTargetOrientationBS(
    constraint: CPointer<Unit>, inOrientation: CPointer<JPHQuat>
): Unit

// =============================================================================
// 齿轮约束（GearConstraint）
// =============================================================================

/** @brief 初始化齿轮约束设置 */
@FastNative
foreign func JPH_GearConstraintSettings_Init(settings: CPointer<JPHGearConstraintSettings>): Unit

/** @brief 创建齿轮约束 */
@FastNative
foreign func JPH_GearConstraint_Create(
    settings: CPointer<JPHGearConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取齿轮约束设置 */
@FastNative
foreign func JPH_GearConstraint_GetSettings(
    constraint: CPointer<Unit>, settings: CPointer<JPHGearConstraintSettings>
): Unit

/** @brief 设置齿轮耦合的两个约束 */
@FastNative
foreign func JPH_GearConstraint_SetConstraints(
    constraint: CPointer<Unit>, gear1: CPointer<Unit>, gear2: CPointer<Unit>
): Unit

/** @brief 获取 lambda */
@FastNative
foreign func JPH_GearConstraint_GetTotalLambda(constraint: CPointer<Unit>): Float32

// =============================================================================
// 角色基类（CharacterBase）
// =============================================================================

/** @brief 销毁角色 */
@FastNative
foreign func JPH_CharacterBase_Destroy(character: CPointer<Unit>): Unit

/** @brief 获取最大坡度角余弦值 */
@FastNative
foreign func JPH_CharacterBase_GetCosMaxSlopeAngle(character: CPointer<Unit>): Float32

/** @brief 设置最大坡度角（弧度） */
@FastNative
foreign func JPH_CharacterBase_SetMaxSlopeAngle(character: CPointer<Unit>, maxSlopeAngle: Float32): Unit

/** @brief 获取角色上方向（输出 result） */
@FastNative
foreign func JPH_CharacterBase_GetUp(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置角色上方向 */
@FastNative
foreign func JPH_CharacterBase_SetUp(character: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 判断坡度是否过陡（value 为表面法线） */
@FastNative
foreign func JPH_CharacterBase_IsSlopeTooSteep(character: CPointer<Unit>, value: CPointer<JPHVec3>): UInt8

/** @brief 获取角色形状句柄 */
@FastNative
foreign func JPH_CharacterBase_GetShape(character: CPointer<Unit>): CPointer<Unit>

/** @brief 获取地面状态（GroundState 枚举值） */
@FastNative
foreign func JPH_CharacterBase_GetGroundState(character: CPointer<Unit>): UInt32

/** @brief 角色是否受支撑（非 0 = 有支撑） */
@FastNative
foreign func JPH_CharacterBase_IsSupported(character: CPointer<Unit>): UInt8

/** @brief 获取地面位置（输出 position） */
@FastNative
foreign func JPH_CharacterBase_GetGroundPosition(character: CPointer<Unit>, position: CPointer<JPHVec3>): Unit

/** @brief 获取地面法线（输出 normal） */
@FastNative
foreign func JPH_CharacterBase_GetGroundNormal(character: CPointer<Unit>, normal: CPointer<JPHVec3>): Unit

/** @brief 获取地面速度（输出 velocity） */
@FastNative
foreign func JPH_CharacterBase_GetGroundVelocity(character: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 获取地面材质句柄 */
@FastNative
foreign func JPH_CharacterBase_GetGroundMaterial(character: CPointer<Unit>): CPointer<Unit>

/** @brief 获取地面刚体 BodyID */
@FastNative
foreign func JPH_CharacterBase_GetGroundBodyId(character: CPointer<Unit>): UInt32

/** @brief 获取地面子形状 ID */
@FastNative
foreign func JPH_CharacterBase_GetGroundSubShapeId(character: CPointer<Unit>): UInt32

/** @brief 获取地面用户数据 */
@FastNative
foreign func JPH_CharacterBase_GetGroundUserData(character: CPointer<Unit>): UInt64

// =============================================================================
// 角色（Character，非虚拟）
// =============================================================================

/** @brief 初始化角色设置 */
@FastNative
foreign func JPH_CharacterSettings_Init(settings: CPointer<JPHCharacterSettings>): Unit

/** @brief 创建角色（position/rotation 初始变换，userData 用户数据，system 物理系统） */
@FastNative
foreign func JPH_Character_Create(
    settings: CPointer<JPHCharacterSettings>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: UInt64, system: CPointer<Unit>
): CPointer<Unit>

/** @brief 将角色添加到物理系统（activationMode 激活策略） */
@FastNative
foreign func JPH_Character_AddToPhysicsSystem(
    character: CPointer<Unit>, activationMode: UInt32, lockBodies: UInt8
): Unit

/** @brief 从物理系统移除角色 */
@FastNative
foreign func JPH_Character_RemoveFromPhysicsSystem(character: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 激活角色（唤醒刚体） */
@FastNative
foreign func JPH_Character_Activate(character: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 模拟后处理（检测地面接触） */
@FastNative
foreign func JPH_Character_PostSimulation(
    character: CPointer<Unit>, maxSeparationDistance: Float32, lockBodies: UInt8
): Unit

/** @brief 设置角色线速度与角速度 */
@FastNative
foreign func JPH_Character_SetLinearAndAngularVelocity(
    character: CPointer<Unit>, linearVelocity: CPointer<JPHVec3>,
    angularVelocity: CPointer<JPHVec3>, lockBodies: UInt8
): Unit

/** @brief 获取角色线速度（输出 result） */
@FastNative
foreign func JPH_Character_GetLinearVelocity(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置角色线速度 */
@FastNative
foreign func JPH_Character_SetLinearVelocity(character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8): Unit

/** @brief 增加角色线速度 */
@FastNative
foreign func JPH_Character_AddLinearVelocity(character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8): Unit

/** @brief 给角色施加冲量 */
@FastNative
foreign func JPH_Character_AddImpulse(character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8): Unit

/** @brief 获取角色刚体 BodyID */
@FastNative
foreign func JPH_Character_GetBodyID(character: CPointer<Unit>): UInt32

/** @brief 获取角色位置与旋转 */
@FastNative
foreign func JPH_Character_GetPositionAndRotation(
    character: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, lockBodies: UInt8
): Unit

/** @brief 设置角色位置与旋转 */
@FastNative
foreign func JPH_Character_SetPositionAndRotation(
    character: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, activationMode: UInt32, lockBodies: UInt8
): Unit

/** @brief 获取角色位置（输出 position） */
@FastNative
foreign func JPH_Character_GetPosition(character: CPointer<Unit>, position: CPointer<JPHVec3>, lockBodies: UInt8): Unit

/** @brief 设置角色位置 */
@FastNative
foreign func JPH_Character_SetPosition(
    character: CPointer<Unit>, position: CPointer<JPHVec3>, activationMode: UInt32, lockBodies: UInt8
): Unit

/** @brief 获取角色旋转（输出 rotation） */
@FastNative
foreign func JPH_Character_GetRotation(character: CPointer<Unit>, rotation: CPointer<JPHQuat>, lockBodies: UInt8): Unit

/** @brief 设置角色旋转 */
@FastNative
foreign func JPH_Character_SetRotation(
    character: CPointer<Unit>, rotation: CPointer<JPHQuat>, activationMode: UInt32, lockBodies: UInt8
): Unit

/** @brief 获取角色质心位置（输出 result） */
@FastNative
foreign func JPH_Character_GetCenterOfMassPosition(character: CPointer<Unit>, result: CPointer<JPHVec3>, lockBodies: UInt8): Unit

/** @brief 获取角色世界变换矩阵（输出 result） */
@FastNative
foreign func JPH_Character_GetWorldTransform(character: CPointer<Unit>, result: CPointer<JPHMat4>, lockBodies: UInt8): Unit

/** @brief 获取角色对象层 */
@FastNative
foreign func JPH_Character_GetLayer(character: CPointer<Unit>): UInt32

/** @brief 设置角色对象层 */
@FastNative
foreign func JPH_Character_SetLayer(character: CPointer<Unit>, value: UInt32, lockBodies: UInt8): Unit

/** @brief 设置角色形状 */
@FastNative
foreign func JPH_Character_SetShape(
    character: CPointer<Unit>, shape: CPointer<Unit>, maxPenetrationDepth: Float32, lockBodies: UInt8
): Unit

// =============================================================================
// 虚拟角色（CharacterVirtual）
// =============================================================================

/** @brief 初始化虚拟角色设置 */
@FastNative
foreign func JPH_CharacterVirtualSettings_Init(settings: CPointer<JPHCharacterVirtualSettings>): Unit

/** @brief 创建虚拟角色（position/rotation 初始变换，userData 用户数据，system 物理系统） */
@FastNative
foreign func JPH_CharacterVirtual_Create(
    settings: CPointer<JPHCharacterVirtualSettings>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: UInt64, system: CPointer<Unit>
): CPointer<Unit>

/** @brief 获取虚拟角色 ID */
@FastNative
foreign func JPH_CharacterVirtual_GetID(character: CPointer<Unit>): UInt32

/** @brief 设置虚拟角色接触监听器 */
@FastNative
foreign func JPH_CharacterVirtual_SetListener(character: CPointer<Unit>, listener: CPointer<Unit>): Unit

/** @brief 设置虚拟角色间碰撞处理 */
@FastNative
foreign func JPH_CharacterVirtual_SetCharacterVsCharacterCollision(
    character: CPointer<Unit>, characterVsCharacterCollision: CPointer<Unit>
): Unit

/** @brief 获取虚拟角色线速度（输出 velocity） */
@FastNative
foreign func JPH_CharacterVirtual_GetLinearVelocity(character: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 设置虚拟角色线速度 */
@FastNative
foreign func JPH_CharacterVirtual_SetLinearVelocity(character: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 获取虚拟角色位置（输出 position） */
@FastNative
foreign func JPH_CharacterVirtual_GetPosition(character: CPointer<Unit>, position: CPointer<JPHVec3>): Unit

/** @brief 设置虚拟角色位置 */
@FastNative
foreign func JPH_CharacterVirtual_SetPosition(character: CPointer<Unit>, position: CPointer<JPHVec3>): Unit

/** @brief 获取虚拟角色旋转（输出 rotation） */
@FastNative
foreign func JPH_CharacterVirtual_GetRotation(character: CPointer<Unit>, rotation: CPointer<JPHQuat>): Unit

/** @brief 设置虚拟角色旋转 */
@FastNative
foreign func JPH_CharacterVirtual_SetRotation(character: CPointer<Unit>, rotation: CPointer<JPHQuat>): Unit

/** @brief 获取虚拟角色世界变换矩阵（输出 result） */
@FastNative
foreign func JPH_CharacterVirtual_GetWorldTransform(character: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取虚拟角色质心变换矩阵（输出 result） */
@FastNative
foreign func JPH_CharacterVirtual_GetCenterOfMassTransform(character: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取虚拟角色质量 */
@FastNative
foreign func JPH_CharacterVirtual_GetMass(character: CPointer<Unit>): Float32

/** @brief 设置虚拟角色质量 */
@FastNative
foreign func JPH_CharacterVirtual_SetMass(character: CPointer<Unit>, value: Float32): Unit

/** @brief 获取虚拟角色最大推力 */
@FastNative
foreign func JPH_CharacterVirtual_GetMaxStrength(character: CPointer<Unit>): Float32

/** @brief 设置虚拟角色最大推力 */
@FastNative
foreign func JPH_CharacterVirtual_SetMaxStrength(character: CPointer<Unit>, value: Float32): Unit

/** @brief 获取穿透恢复速度 */
@FastNative
foreign func JPH_CharacterVirtual_GetPenetrationRecoverySpeed(character: CPointer<Unit>): Float32

/** @brief 设置穿透恢复速度 */
@FastNative
foreign func JPH_CharacterVirtual_SetPenetrationRecoverySpeed(character: CPointer<Unit>, value: Float32): Unit

/** @brief 获取增强内部边移除 */
@FastNative
foreign func JPH_CharacterVirtual_GetEnhancedInternalEdgeRemoval(character: CPointer<Unit>): UInt8

/** @brief 设置增强内部边移除 */
@FastNative
foreign func JPH_CharacterVirtual_SetEnhancedInternalEdgeRemoval(character: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取角色填充 */
@FastNative
foreign func JPH_CharacterVirtual_GetCharacterPadding(character: CPointer<Unit>): Float32

/** @brief 获取最大命中数 */
@FastNative
foreign func JPH_CharacterVirtual_GetMaxNumHits(character: CPointer<Unit>): UInt32

/** @brief 设置最大命中数 */
@FastNative
foreign func JPH_CharacterVirtual_SetMaxNumHits(character: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取命中约简最大角余弦 */
@FastNative
foreign func JPH_CharacterVirtual_GetHitReductionCosMaxAngle(character: CPointer<Unit>): Float32

/** @brief 设置命中约简最大角余弦 */
@FastNative
foreign func JPH_CharacterVirtual_SetHitReductionCosMaxAngle(character: CPointer<Unit>, value: Float32): Unit

/** @brief 最大命中数是否已超限 */
@FastNative
foreign func JPH_CharacterVirtual_GetMaxHitsExceeded(character: CPointer<Unit>): UInt8

/** @brief 获取形状偏移（输出 result） */
@FastNative
foreign func JPH_CharacterVirtual_GetShapeOffset(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置形状偏移 */
@FastNative
foreign func JPH_CharacterVirtual_SetShapeOffset(character: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取虚拟角色用户数据 */
@FastNative
foreign func JPH_CharacterVirtual_GetUserData(character: CPointer<Unit>): UInt64

/** @brief 设置虚拟角色用户数据 */
@FastNative
foreign func JPH_CharacterVirtual_SetUserData(character: CPointer<Unit>, value: UInt64): Unit

/** @brief 获取内部刚体 BodyID */
@FastNative
foreign func JPH_CharacterVirtual_GetInnerBodyID(character: CPointer<Unit>): UInt32

/** @brief 取消朝陡坡方向的速度分量 */
@FastNative
foreign func JPH_CharacterVirtual_CancelVelocityTowardsSteepSlopes(
    character: CPointer<Unit>, desiredVelocity: CPointer<JPHVec3>, velocity: CPointer<JPHVec3>
): Unit

/** @brief 开始跟踪接触变化 */
@FastNative
foreign func JPH_CharacterVirtual_StartTrackingContactChanges(character: CPointer<Unit>): Unit

/** @brief 结束跟踪接触变化 */
@FastNative
foreign func JPH_CharacterVirtual_FinishTrackingContactChanges(character: CPointer<Unit>): Unit

/** @brief 更新虚拟角色（标准更新） */
@FastNative
foreign func JPH_CharacterVirtual_Update(
    character: CPointer<Unit>, deltaTime: Float32, layer: UInt32, system: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit

/** @brief 扩展更新虚拟角色（贴地/上台阶/下台阶） */
@FastNative
foreign func JPH_CharacterVirtual_ExtendedUpdate(
    character: CPointer<Unit>, deltaTime: Float32, settings: CPointer<JPHExtendedUpdateSettings>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit

/** @brief 刷新虚拟角色接触 */
@FastNative
foreign func JPH_CharacterVirtual_RefreshContacts(
    character: CPointer<Unit>, layer: UInt32, system: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit

/** @brief 判断能否上台阶 */
@FastNative
foreign func JPH_CharacterVirtual_CanWalkStairs(
    character: CPointer<Unit>, linearVelocity: CPointer<JPHVec3>
): UInt8

/** @brief 尝试上台阶（返回是否成功） */
@FastNative
foreign func JPH_CharacterVirtual_WalkStairs(
    character: CPointer<Unit>, deltaTime: Float32,
    stepUp: CPointer<JPHVec3>, stepForward: CPointer<JPHVec3>,
    stepForwardTest: CPointer<JPHVec3>, stepDownExtra: CPointer<JPHVec3>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 尝试贴地（返回是否成功） */
@FastNative
foreign func JPH_CharacterVirtual_StickToFloor(
    character: CPointer<Unit>, stepDown: CPointer<JPHVec3>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 更新地面速度 */
@FastNative
foreign func JPH_CharacterVirtual_UpdateGroundVelocity(character: CPointer<Unit>): Unit

/** @brief 设置虚拟角色形状（返回是否成功） */
@FastNative
foreign func JPH_CharacterVirtual_SetShape(
    character: CPointer<Unit>, shape: CPointer<Unit>, maxPenetrationDepth: Float32,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 设置内部刚体形状 */
@FastNative
foreign func JPH_CharacterVirtual_SetInnerBodyShape(
    character: CPointer<Unit>, shape: CPointer<Unit>
): Unit

/** @brief 获取活动接触数量 */
@FastNative
foreign func JPH_CharacterVirtual_GetNumActiveContacts(character: CPointer<Unit>): UInt32

/** @brief 获取指定活动接触（输出 result） */
@FastNative
foreign func JPH_CharacterVirtual_GetActiveContact(
    character: CPointer<Unit>, index: UInt32, result: CPointer<JPHCharacterContact>
): Unit

/** @brief 是否与指定刚体碰撞过 */
@FastNative
foreign func JPH_CharacterVirtual_HasCollidedWithBody(character: CPointer<Unit>, body: UInt32): UInt8

/** @brief 是否与指定角色 ID 碰撞过 */
@FastNative
foreign func JPH_CharacterVirtual_HasCollidedWith(character: CPointer<Unit>, other: UInt32): UInt8

/** @brief 是否与指定虚拟角色碰撞过 */
@FastNative
foreign func JPH_CharacterVirtual_HasCollidedWithCharacter(
    character: CPointer<Unit>, other: CPointer<Unit>
): UInt8

// =============================================================================
// 骨骼（Skeleton）
// =============================================================================

/** @brief 创建骨骼 */
@FastNative
foreign func JPH_Skeleton_Create(): CPointer<Unit>

/** @brief 销毁骨骼 */
@FastNative
foreign func JPH_Skeleton_Destroy(skeleton: CPointer<Unit>): Unit

/** @brief 添加关节（name 关节名），返回关节索引 */
@FastNative
foreign func JPH_Skeleton_AddJoint(skeleton: CPointer<Unit>, name: CPointer<UInt8>): UInt32

/** @brief 添加关节（指定父关节索引） */
@FastNative
foreign func JPH_Skeleton_AddJoint2(skeleton: CPointer<Unit>, name: CPointer<UInt8>, parentIndex: Int32): UInt32

/** @brief 添加关节（指定父关节名） */
@FastNative
foreign func JPH_Skeleton_AddJoint3(skeleton: CPointer<Unit>, name: CPointer<UInt8>, parentName: CPointer<UInt8>): UInt32

/** @brief 获取关节数量 */
@FastNative
foreign func JPH_Skeleton_GetJointCount(skeleton: CPointer<Unit>): Int32

/** @brief 获取指定关节（输出 joint） */
@FastNative
foreign func JPH_Skeleton_GetJoint(skeleton: CPointer<Unit>, index: Int32, joint: CPointer<JPHSkeletonJoint>): Unit

/** @brief 按名称获取关节索引（找不到返回 -1） */
@FastNative
foreign func JPH_Skeleton_GetJointIndex(skeleton: CPointer<Unit>, name: CPointer<UInt8>): Int32

/** @brief 计算父关节索引 */
@FastNative
foreign func JPH_Skeleton_CalculateParentJointIndices(skeleton: CPointer<Unit>): Unit

/** @brief 关节顺序是否正确（子关节在父关节之后） */
@FastNative
foreign func JPH_Skeleton_AreJointsCorrectlyOrdered(skeleton: CPointer<Unit>): UInt8

// =============================================================================
// 骨骼姿态（SkeletonPose）
// =============================================================================

/** @brief 创建骨骼姿态 */
@FastNative
foreign func JPH_SkeletonPose_Create(): CPointer<Unit>

/** @brief 销毁骨骼姿态 */
@FastNative
foreign func JPH_SkeletonPose_Destroy(pose: CPointer<Unit>): Unit

/** @brief 设置骨骼姿态关联的骨骼 */
@FastNative
foreign func JPH_SkeletonPose_SetSkeleton(pose: CPointer<Unit>, skeleton: CPointer<Unit>): Unit

/** @brief 获取骨骼姿态关联的骨骼 */
@FastNative
foreign func JPH_SkeletonPose_GetSkeleton(pose: CPointer<Unit>): CPointer<Unit>

/** @brief 设置根偏移 */
@FastNative
foreign func JPH_SkeletonPose_SetRootOffset(pose: CPointer<Unit>, offset: CPointer<JPHVec3>): Unit

/** @brief 获取根偏移（输出 result） */
@FastNative
foreign func JPH_SkeletonPose_GetRootOffset(pose: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取关节数量 */
@FastNative
foreign func JPH_SkeletonPose_GetJointCount(pose: CPointer<Unit>): Int32

/** @brief 获取指定关节状态（平移 + 旋转） */
@FastNative
foreign func JPH_SkeletonPose_GetJointState(
    pose: CPointer<Unit>, index: Int32, outTranslation: CPointer<JPHVec3>, outRotation: CPointer<JPHQuat>
): Unit

/** @brief 设置指定关节状态 */
@FastNative
foreign func JPH_SkeletonPose_SetJointState(
    pose: CPointer<Unit>, index: Int32, translation: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit

/** @brief 获取指定关节矩阵 */
@FastNative
foreign func JPH_SkeletonPose_GetJointMatrix(pose: CPointer<Unit>, index: Int32, result: CPointer<JPHMat4>): Unit

/** @brief 设置指定关节矩阵 */
@FastNative
foreign func JPH_SkeletonPose_SetJointMatrix(pose: CPointer<Unit>, index: Int32, matrix: CPointer<JPHMat4>): Unit

/** @brief 获取全部关节矩阵（outMatrices 数组） */
@FastNative
foreign func JPH_SkeletonPose_GetJointMatrices(
    pose: CPointer<Unit>, outMatrices: CPointer<JPHMat4>, count: Int32
): Unit

/** @brief 设置全部关节矩阵 */
@FastNative
foreign func JPH_SkeletonPose_SetJointMatrices(
    pose: CPointer<Unit>, matrices: CPointer<JPHMat4>, count: Int32
): Unit

/** @brief 计算关节矩阵（从关节状态） */
@FastNative
foreign func JPH_SkeletonPose_CalculateJointMatrices(pose: CPointer<Unit>): Unit

/** @brief 计算关节状态（从关节矩阵） */
@FastNative
foreign func JPH_SkeletonPose_CalculateJointStates(pose: CPointer<Unit>): Unit

/** @brief 计算局部空间关节矩阵 */
@FastNative
foreign func JPH_SkeletonPose_CalculateLocalSpaceJointMatrices(
    pose: CPointer<Unit>, outMatrices: CPointer<JPHMat4>
): Unit

// =============================================================================
// 骨骼动画（SkeletalAnimation）
// =============================================================================

/** @brief 创建骨骼动画 */
@FastNative
foreign func JPH_SkeletalAnimation_Create(): CPointer<Unit>

/** @brief 销毁骨骼动画 */
@FastNative
foreign func JPH_SkeletalAnimation_Destroy(animation: CPointer<Unit>): Unit

/** @brief 获取动画时长（秒） */
@FastNative
foreign func JPH_SkeletalAnimation_GetDuration(animation: CPointer<Unit>): Float32

/** @brief 是否循环播放 */
@FastNative
foreign func JPH_SkeletalAnimation_IsLooping(animation: CPointer<Unit>): UInt8

/** @brief 设置是否循环播放 */
@FastNative
foreign func JPH_SkeletalAnimation_SetIsLooping(animation: CPointer<Unit>, looping: UInt8): Unit

/** @brief 缩放关节（比例因子） */
@FastNative
foreign func JPH_SkeletalAnimation_ScaleJoints(animation: CPointer<Unit>, scale: Float32): Unit

/** @brief 在指定时间采样动画到姿态 */
@FastNative
foreign func JPH_SkeletalAnimation_Sample(
    animation: CPointer<Unit>, time: Float32, pose: CPointer<Unit>
): Unit

/** @brief 获取动画关节数量 */
@FastNative
foreign func JPH_SkeletalAnimation_GetAnimatedJointCount(animation: CPointer<Unit>): Int32

/** @brief 添加动画关节（按关节名） */
@FastNative
foreign func JPH_SkeletalAnimation_AddAnimatedJoint(
    animation: CPointer<Unit>, jointName: CPointer<UInt8>
): Unit

/** @brief 添加关键帧（jointIndex 关节索引，time 时间，平移 + 旋转） */
@FastNative
foreign func JPH_SkeletalAnimation_AddKeyframe(
    animation: CPointer<Unit>, jointIndex: Int32, time: Float32,
    translation: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit

// =============================================================================
// 骨骼映射（SkeletonMapper）
// =============================================================================

/** @brief 创建骨骼映射器 */
@FastNative
foreign func JPH_SkeletonMapper_Create(): CPointer<Unit>

/** @brief 销毁骨骼映射器 */
@FastNative
foreign func JPH_SkeletonMapper_Destroy(mapper: CPointer<Unit>): Unit

/** @brief 初始化映射器（两个骨骼 + 中性姿态矩阵） */
@FastNative
foreign func JPH_SkeletonMapper_Initialize(
    mapper: CPointer<Unit>, skeleton1: CPointer<Unit>, neutralPose1: CPointer<JPHMat4>,
    skeleton2: CPointer<Unit>, neutralPose2: CPointer<JPHMat4>
): Unit

/** @brief 锁定全部平移自由度（映射目标骨骼） */
@FastNative
foreign func JPH_SkeletonMapper_LockAllTranslations(
    mapper: CPointer<Unit>, skeleton2: CPointer<Unit>, neutralPose2: CPointer<JPHMat4>
): Unit

/** @brief 锁定指定平移自由度 */
@FastNative
foreign func JPH_SkeletonMapper_LockTranslations(
    mapper: CPointer<Unit>, skeleton2: CPointer<Unit>,
    lockedTranslations: CPointer<UInt8>, neutralPose2: CPointer<JPHMat4>
): Unit

/** @brief 正向映射（pose1 模型空间 -> pose2 模型空间） */
@FastNative
foreign func JPH_SkeletonMapper_Map(
    mapper: CPointer<Unit>, pose1ModelSpace: CPointer<JPHMat4>,
    pose2LocalSpace: CPointer<JPHMat4>, outPose2ModelSpace: CPointer<JPHMat4>
): Unit

/** @brief 反向映射 */
@FastNative
foreign func JPH_SkeletonMapper_MapReverse(
    mapper: CPointer<Unit>, pose2ModelSpace: CPointer<JPHMat4>, outPose1ModelSpace: CPointer<JPHMat4>
): Unit

/** @brief 获取映射后的关节索引（未映射返回 -1） */
@FastNative
foreign func JPH_SkeletonMapper_GetMappedJointIndex(mapper: CPointer<Unit>, joint1Index: Int32): Int32

/** @brief 指定关节平移是否被锁定 */
@FastNative
foreign func JPH_SkeletonMapper_IsJointTranslationLocked(mapper: CPointer<Unit>, joint2Index: Int32): UInt8

// =============================================================================
// 布娃娃设置（RagdollSettings）
// =============================================================================

/** @brief 创建布娃娃设置 */
@FastNative
foreign func JPH_RagdollSettings_Create(): CPointer<Unit>

/** @brief 销毁布娃娃设置 */
@FastNative
foreign func JPH_RagdollSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取布娃娃设置的骨骼 */
@FastNative
foreign func JPH_RagdollSettings_GetSkeleton(character: CPointer<Unit>): CPointer<Unit>

/** @brief 设置布娃娃设置的骨骼 */
@FastNative
foreign func JPH_RagdollSettings_SetSkeleton(character: CPointer<Unit>, skeleton: CPointer<Unit>): Unit

/** @brief 稳定布娃娃（调整质心避免初始抖动） */
@FastNative
foreign func JPH_RagdollSettings_Stabilize(settings: CPointer<Unit>): UInt8

/** @brief 禁用父子碰撞（避免相邻部件相互碰撞） */
@FastNative
foreign func JPH_RagdollSettings_DisableParentChildCollisions(
    settings: CPointer<Unit>, jointMatrices: CPointer<JPHMat4>, minSeparationDistance: Float32
): Unit

/** @brief 计算刚体索引到约束索引的映射 */
@FastNative
foreign func JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex(settings: CPointer<Unit>): Unit

/** @brief 获取刚体索引对应的约束索引 */
@FastNative
foreign func JPH_RagdollSettings_GetConstraintIndexForBodyIndex(settings: CPointer<Unit>, bodyIndex: Int32): Int32

/** @brief 计算约束索引到刚体对索引的映射 */
@FastNative
foreign func JPH_RagdollSettings_CalculateConstraintIndexToBodyIdxPair(settings: CPointer<Unit>): Unit

/** @brief 调整部件数量 */
@FastNative
foreign func JPH_RagdollSettings_ResizeParts(settings: CPointer<Unit>, count: Int32): Unit

/** @brief 获取部件数量 */
@FastNative
foreign func JPH_RagdollSettings_GetPartCount(settings: CPointer<Unit>): Int32

/** @brief 设置部件形状 */
@FastNative
foreign func JPH_RagdollSettings_SetPartShape(
    settings: CPointer<Unit>, partIndex: Int32, shape: CPointer<Unit>
): Unit

/** @brief 设置部件位置 */
@FastNative
foreign func JPH_RagdollSettings_SetPartPosition(
    settings: CPointer<Unit>, partIndex: Int32, position: CPointer<JPHVec3>
): Unit

/** @brief 设置部件旋转 */
@FastNative
foreign func JPH_RagdollSettings_SetPartRotation(
    settings: CPointer<Unit>, partIndex: Int32, rotation: CPointer<JPHQuat>
): Unit

/** @brief 设置部件运动类型 */
@FastNative
foreign func JPH_RagdollSettings_SetPartMotionType(
    settings: CPointer<Unit>, partIndex: Int32, motionType: UInt32
): Unit

/** @brief 设置部件到父部件的约束 */
@FastNative
foreign func JPH_RagdollSettings_SetPartToParent(
    settings: CPointer<Unit>, partIndex: Int32, constraintSettings: CPointer<Unit>
): Unit

// =============================================================================
// 布娃娃（Ragdoll）
// =============================================================================

/** @brief 销毁布娃娃 */
@FastNative
foreign func JPH_Ragdoll_Destroy(ragdoll: CPointer<Unit>): Unit

/** @brief 添加布娃娃到物理系统 */
@FastNative
foreign func JPH_Ragdoll_AddToPhysicsSystem(
    ragdoll: CPointer<Unit>, activationMode: UInt32, lockBodies: UInt8
): Unit

/** @brief 从物理系统移除布娃娃 */
@FastNative
foreign func JPH_Ragdoll_RemoveFromPhysicsSystem(ragdoll: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 激活布娃娃 */
@FastNative
foreign func JPH_Ragdoll_Activate(ragdoll: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 布娃娃是否活动 */
@FastNative
foreign func JPH_Ragdoll_IsActive(ragdoll: CPointer<Unit>, lockBodies: UInt8): UInt8

/** @brief 重置布娃娃热启动缓存 */
@FastNative
foreign func JPH_Ragdoll_ResetWarmStart(ragdoll: CPointer<Unit>): Unit

/** @brief 按骨骼姿态设置布娃娃姿态 */
@FastNative
foreign func JPH_Ragdoll_SetPose(ragdoll: CPointer<Unit>, pose: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 按根偏移 + 关节矩阵设置布娃娃姿态 */
@FastNative
foreign func JPH_Ragdoll_SetPose2(
    ragdoll: CPointer<Unit>, rootOffset: CPointer<JPHVec3>,
    jointMatrices: CPointer<JPHMat4>, lockBodies: UInt8
): Unit

/** @brief 获取布娃娃姿态（输出 outPose） */
@FastNative
foreign func JPH_Ragdoll_GetPose(ragdoll: CPointer<Unit>, outPose: CPointer<Unit>, lockBodies: UInt8): Unit

/** @brief 获取布娃娃姿态（根偏移 + 关节矩阵） */
@FastNative
foreign func JPH_Ragdoll_GetPose2(
    ragdoll: CPointer<Unit>, outRootOffset: CPointer<JPHVec3>,
    outJointMatrices: CPointer<JPHMat4>, lockBodies: UInt8
): Unit

/** @brief 用电机驱动布娃娃到指定姿态 */
@FastNative
foreign func JPH_Ragdoll_DriveToPoseUsingMotors(
    ragdoll: CPointer<Unit>, pose: CPointer<Unit>
): Unit

/** @brief 用运动学驱动布娃娃到指定姿态 */
@FastNative
foreign func JPH_Ragdoll_DriveToPoseUsingKinematics(
    ragdoll: CPointer<Unit>, pose: CPointer<Unit>, deltaTime: Float32, lockBodies: UInt8
): Unit

/** @brief 获取布娃娃刚体数量 */
@FastNative
foreign func JPH_Ragdoll_GetBodyCount(ragdoll: CPointer<Unit>): Int32

/** @brief 获取指定刚体的 BodyID */
@FastNative
foreign func JPH_Ragdoll_GetBodyID(ragdoll: CPointer<Unit>, bodyIndex: Int32): UInt32

/** @brief 获取布娃娃约束数量 */
@FastNative
foreign func JPH_Ragdoll_GetConstraintCount(ragdoll: CPointer<Unit>): Int32

/** @brief 获取指定约束（双刚体约束句柄） */
@FastNative
foreign func JPH_Ragdoll_GetConstraint(ragdoll: CPointer<Unit>, constraintIndex: Int32): CPointer<Unit>

/** @brief 获取布娃娃根变换 */
@FastNative
foreign func JPH_Ragdoll_GetRootTransform(
    ragdoll: CPointer<Unit>, outPosition: CPointer<JPHVec3>,
    outRotation: CPointer<JPHQuat>, lockBodies: UInt8
): Unit

/** @brief 获取布娃娃设置 */
@FastNative
foreign func JPH_Ragdoll_GetRagdollSettings(ragdoll: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// 软体共享设置（SoftBodySharedSettings）
// =============================================================================

/** @brief 创建软体共享设置 */
@FastNative
foreign func JPH_SoftBodySharedSettings_Create(): CPointer<Unit>

/** @brief 销毁软体共享设置 */
@FastNative
foreign func JPH_SoftBodySharedSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 添加软体顶点 */
@FastNative
foreign func JPH_SoftBodySharedSettings_AddVertex(
    settings: CPointer<Unit>, vertex: CPointer<JPHSoftVertex>
): Unit

/** @brief 批量添加软体顶点 */
@FastNative
foreign func JPH_SoftBodySharedSettings_AddVertices(
    settings: CPointer<Unit>, vertices: CPointer<JPHSoftVertex>, count: UInt32
): Unit

/** @brief 移除软体顶点（返回是否成功） */
@FastNative
foreign func JPH_SoftBodySharedSettings_RemoveVertex(settings: CPointer<Unit>, index: UInt32): UInt8

/** @brief 获取软体顶点数量 */
@FastNative
foreign func JPH_SoftBodySharedSettings_GetVertexCount(settings: CPointer<Unit>): UInt32

/** @brief 获取指定软体顶点（输出 outVertex） */
@FastNative
foreign func JPH_SoftBodySharedSettings_GetVertex(
    settings: CPointer<Unit>, index: UInt32, outVertex: CPointer<JPHSoftVertex>
): UInt8

/** @brief 添加软体面 */
@FastNative
foreign func JPH_SoftBodySharedSettings_AddFace(
    settings: CPointer<Unit>, face: CPointer<JPHSoftFace>
): Unit

/** @brief 批量添加软体面 */
@FastNative
foreign func JPH_SoftBodySharedSettings_AddFaces(
    settings: CPointer<Unit>, faces: CPointer<JPHSoftFace>, count: UInt32
): Unit

/** @brief 移除软体面（返回是否成功） */
@FastNative
foreign func JPH_SoftBodySharedSettings_RemoveFace(settings: CPointer<Unit>, index: UInt32): UInt8

/** @brief 获取软体面数量 */
@FastNative
foreign func JPH_SoftBodySharedSettings_GetFaceCount(settings: CPointer<Unit>): UInt32

/** @brief 获取指定软体面（输出 outFace） */
@FastNative
foreign func JPH_SoftBodySharedSettings_GetFace(
    settings: CPointer<Unit>, index: UInt32, outFace: CPointer<JPHSoftFace>
): UInt8

/** @brief 创建软体约束（compliance 柔度，bendType 弯曲类型） */
@FastNative
foreign func JPH_SoftBodySharedSettings_CreateConstraints(
    settings: CPointer<Unit>, compliance: Float32, bendType: UInt32
): Unit

/** @brief 优化软体（合并顶点等） */
foreign func JPH_SoftBodySharedSettings_Optimize(settings: CPointer<Unit>): Unit

// =============================================================================
// 软体创建设置（SoftBodyCreationSettings）
// =============================================================================

/** @brief 创建软体创建设置 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_Create(): CPointer<Unit>

/** @brief 创建软体创建设置（共享设置 + 初始变换 + 对象层） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_Create2(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, objectLayer: UInt32
): CPointer<Unit>

/** @brief 销毁软体创建设置 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取共享设置句柄 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetSettings(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 设置共享设置 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetSettings(
    settings: CPointer<Unit>, sharedSettings: CPointer<Unit>
): Unit

/** @brief 获取初始位置（输出 result） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetPosition(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置初始位置 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetPosition(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取初始旋转（输出 result） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetRotation(settings: CPointer<Unit>, result: CPointer<JPHQuat>): Unit

/** @brief 设置初始旋转 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetRotation(settings: CPointer<Unit>, value: CPointer<JPHQuat>): Unit

/** @brief 获取用户数据 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetUserData(settings: CPointer<Unit>): UInt64

/** @brief 设置用户数据 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetUserData(settings: CPointer<Unit>, userData: UInt64): Unit

/** @brief 获取对象层 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetObjectLayer(settings: CPointer<Unit>): UInt32

/** @brief 设置对象层 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetObjectLayer(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取碰撞组（输出 result） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetCollisionGroup(
    settings: CPointer<Unit>, result: CPointer<JPHCollisionGroup>
): Unit

/** @brief 设置碰撞组 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetCollisionGroup(
    settings: CPointer<Unit>, group: CPointer<JPHCollisionGroup>
): Unit

/** @brief 获取迭代次数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetNumIterations(settings: CPointer<Unit>): UInt32

/** @brief 设置迭代次数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetNumIterations(settings: CPointer<Unit>, iterations: UInt32): Unit

/** @brief 获取线阻尼 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetLinearDamping(settings: CPointer<Unit>): Float32

/** @brief 设置线阻尼 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetLinearDamping(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取最大线速度 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetMaxLinearVelocity(settings: CPointer<Unit>): Float32

/** @brief 设置最大线速度 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetMaxLinearVelocity(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取弹性系数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetRestitution(settings: CPointer<Unit>): Float32

/** @brief 设置弹性系数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetRestitution(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取摩擦系数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetFriction(settings: CPointer<Unit>): Float32

/** @brief 设置摩擦系数 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetFriction(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取内部压力 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetPressure(settings: CPointer<Unit>): Float32

/** @brief 设置内部压力 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetPressure(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取重力因子 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetGravityFactor(settings: CPointer<Unit>): Float32

/** @brief 设置重力因子 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetGravityFactor(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取顶点半径 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetVertexRadius(settings: CPointer<Unit>): Float32

/** @brief 设置顶点半径 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetVertexRadius(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 是否更新位置（非 0 = 更新） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetUpdatePosition(settings: CPointer<Unit>): UInt8

/** @brief 设置是否更新位置 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetUpdatePosition(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 是否将旋转归为恒等（非 0 = 归为恒等） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetMakeRotationIdentity(settings: CPointer<Unit>): UInt8

/** @brief 设置是否将旋转归为恒等 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetMakeRotationIdentity(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 是否允许休眠 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetAllowSleeping(settings: CPointer<Unit>): UInt8

/** @brief 设置是否允许休眠 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetAllowSleeping(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 面是否双面（非 0 = 双面） */
@FastNative
foreign func JPH_SoftBodyCreationSettings_GetFacesDoubleSided(settings: CPointer<Unit>): UInt8

/** @brief 设置面是否双面 */
@FastNative
foreign func JPH_SoftBodyCreationSettings_SetFacesDoubleSided(settings: CPointer<Unit>, value: UInt8): Unit

// =============================================================================
// 刚体直接操作（Body，从 BodyLock 获取后操作）
// =============================================================================

/** @brief 获取刚体 ID */
@FastNative
foreign func JPH_Body_GetID(body: CPointer<Unit>): UInt32

/** @brief 获取刚体类型（BodyType 枚举值） */
@FastNative
foreign func JPH_Body_GetBodyType(body: CPointer<Unit>): UInt32

/** @brief 获取刚体形状句柄 */
@FastNative
foreign func JPH_Body_GetShape(body: CPointer<Unit>): CPointer<Unit>

/** @brief 获取刚体位置（输出 result） */
@FastNative
foreign func JPH_Body_GetPosition(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取刚体旋转（输出 result） */
@FastNative
foreign func JPH_Body_GetRotation(body: CPointer<Unit>, result: CPointer<JPHQuat>): Unit

/** @brief 获取质心位置（输出 result） */
@FastNative
foreign func JPH_Body_GetCenterOfMassPosition(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取世界变换矩阵（输出 result） */
@FastNative
foreign func JPH_Body_GetWorldTransform(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取质心变换矩阵（输出 result） */
@FastNative
foreign func JPH_Body_GetCenterOfMassTransform(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取逆质心变换矩阵（输出 result） */
@FastNative
foreign func JPH_Body_GetInverseCenterOfMassTransform(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取线速度（输出 result） */
@FastNative
foreign func JPH_Body_GetLinearVelocity(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置线速度 */
@FastNative
foreign func JPH_Body_SetLinearVelocity(body: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit

/** @brief 获取角速度（输出 result） */
@FastNative
foreign func JPH_Body_GetAngularVelocity(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置角速度 */
@FastNative
foreign func JPH_Body_SetAngularVelocity(body: CPointer<Unit>, angularVelocity: CPointer<JPHVec3>): Unit

/** @brief 获取指定点的速度（输出 result） */
@FastNative
foreign func JPH_Body_GetPointVelocity(body: CPointer<Unit>, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 获取质心点速度（输出 result） */
@FastNative
foreign func JPH_Body_GetPointVelocityCOM(body: CPointer<Unit>, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit

/** @brief 获取累积力（输出 result） */
@FastNative
foreign func JPH_Body_GetAccumulatedForce(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取累积力矩（输出 result） */
@FastNative
foreign func JPH_Body_GetAccumulatedTorque(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 施加力（质心） */
@FastNative
foreign func JPH_Body_AddForce(body: CPointer<Unit>, force: CPointer<JPHVec3>): Unit

/** @brief 在指定位置施加力 */
@FastNative
foreign func JPH_Body_AddForceAtPosition(body: CPointer<Unit>, force: CPointer<JPHVec3>, position: CPointer<JPHVec3>): Unit

/** @brief 施加力矩 */
@FastNative
foreign func JPH_Body_AddTorque(body: CPointer<Unit>, torque: CPointer<JPHVec3>): Unit

/** @brief 施加冲量（质心） */
@FastNative
foreign func JPH_Body_AddImpulse(body: CPointer<Unit>, impulse: CPointer<JPHVec3>): Unit

/** @brief 在指定位置施加冲量 */
@FastNative
foreign func JPH_Body_AddImpulseAtPosition(body: CPointer<Unit>, impulse: CPointer<JPHVec3>, position: CPointer<JPHVec3>): Unit

/** @brief 施加角冲量 */
@FastNative
foreign func JPH_Body_AddAngularImpulse(body: CPointer<Unit>, angularImpulse: CPointer<JPHVec3>): Unit

/** @brief 应用浮力冲量 */
@FastNative
foreign func JPH_Body_ApplyBuoyancyImpulse(
    body: CPointer<Unit>, surfacePosition: CPointer<JPHVec3>, surfaceNormal: CPointer<JPHVec3>,
    buoyancy: Float32, linearDrag: Float32, angularDrag: Float32,
    fluidVelocity: CPointer<JPHVec3>, gravity: CPointer<JPHVec3>, deltaTime: Float32
): UInt8

/** @brief 重置累积力 */
@FastNative
foreign func JPH_Body_ResetForce(body: CPointer<Unit>): Unit

/** @brief 重置累积力矩 */
@FastNative
foreign func JPH_Body_ResetTorque(body: CPointer<Unit>): Unit

/** @brief 重置运动（速度归零） */
@FastNative
foreign func JPH_Body_ResetMotion(body: CPointer<Unit>): Unit

/** @brief 获取摩擦系数 */
@FastNative
foreign func JPH_Body_GetFriction(body: CPointer<Unit>): Float32

/** @brief 设置摩擦系数 */
@FastNative
foreign func JPH_Body_SetFriction(body: CPointer<Unit>, friction: Float32): Unit

/** @brief 获取弹性系数 */
@FastNative
foreign func JPH_Body_GetRestitution(body: CPointer<Unit>): Float32

/** @brief 设置弹性系数 */
@FastNative
foreign func JPH_Body_SetRestitution(body: CPointer<Unit>, restitution: Float32): Unit

/** @brief 获取运动类型（MotionType 枚举值） */
@FastNative
foreign func JPH_Body_GetMotionType(body: CPointer<Unit>): UInt32

/** @brief 设置运动类型 */
@FastNative
foreign func JPH_Body_SetMotionType(body: CPointer<Unit>, motionType: UInt32): Unit

/** @brief 刚体是否活动 */
@FastNative
foreign func JPH_Body_IsActive(body: CPointer<Unit>): UInt8

/** @brief 刚体是否静态 */
@FastNative
foreign func JPH_Body_IsStatic(body: CPointer<Unit>): UInt8

/** @brief 刚体是否运动学 */
@FastNative
foreign func JPH_Body_IsKinematic(body: CPointer<Unit>): UInt8

/** @brief 刚体是否动态 */
@FastNative
foreign func JPH_Body_IsDynamic(body: CPointer<Unit>): UInt8

/** @brief 刚体是否刚体类型（非软体） */
@FastNative
foreign func JPH_Body_IsRigidBody(body: CPointer<Unit>): UInt8

/** @brief 刚体是否软体 */
@FastNative
foreign func JPH_Body_IsSoftBody(body: CPointer<Unit>): UInt8

/** @brief 刚体是否传感器 */
@FastNative
foreign func JPH_Body_IsSensor(body: CPointer<Unit>): UInt8

/** @brief 设置刚体是否传感器 */
@FastNative
foreign func JPH_Body_SetIsSensor(body: CPointer<Unit>, isSensor: UInt8): Unit

/** @brief 获取用户数据 */
@FastNative
foreign func JPH_Body_GetUserData(body: CPointer<Unit>): UInt64

/** @brief 设置用户数据 */
@FastNative
foreign func JPH_Body_SetUserData(body: CPointer<Unit>, userData: UInt64): Unit

/** @brief 获取对象层 */
@FastNative
foreign func JPH_Body_GetObjectLayer(body: CPointer<Unit>): UInt32

/** @brief 获取 BroadPhase 层 */
@FastNative
foreign func JPH_Body_GetBroadPhaseLayer(body: CPointer<Unit>): UInt8

/** @brief 获取碰撞组（输出 result） */
@FastNative
foreign func JPH_Body_GetCollisionGroup(body: CPointer<Unit>, result: CPointer<JPHCollisionGroup>): Unit

/** @brief 设置碰撞组 */
@FastNative
foreign func JPH_Body_SetCollisionGroup(body: CPointer<Unit>, value: CPointer<JPHCollisionGroup>): Unit

/** @brief 运动学移动到指定位置/旋转 */
@FastNative
foreign func JPH_Body_MoveKinematic(
    body: CPointer<Unit>, targetPosition: CPointer<JPHVec3>,
    targetRotation: CPointer<JPHQuat>, deltaTime: Float32
): Unit

/** @brief 重置休眠计时器 */
@FastNative
foreign func JPH_Body_ResetSleepTimer(body: CPointer<Unit>): Unit

/** @brief 获取世界空间包围盒（输出 result） */
@FastNative
foreign func JPH_Body_GetWorldSpaceBounds(body: CPointer<Unit>, result: CPointer<JPHAABox>): Unit

/** @brief 获取世界空间表面法线（输出 result） */
@FastNative
foreign func JPH_Body_GetWorldSpaceSurfaceNormal(
    body: CPointer<Unit>, subShapeID: UInt32, worldPosition: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取运动属性句柄 */
@FastNative
foreign func JPH_Body_GetMotionProperties(body: CPointer<Unit>): CPointer<Unit>

/** @brief 获取运动属性句柄（未检查版本） */
@FastNative
foreign func JPH_Body_GetMotionPropertiesUnchecked(body: CPointer<Unit>): CPointer<Unit>

/** @brief 获取逆惯量（输出 result） */
@FastNative
foreign func JPH_Body_GetInverseInertia(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit

/** @brief 获取是否允许休眠 */
@FastNative
foreign func JPH_Body_GetAllowSleeping(body: CPointer<Unit>): UInt8

/** @brief 设置是否允许休眠 */
@FastNative
foreign func JPH_Body_SetAllowSleeping(body: CPointer<Unit>, allowSleeping: UInt8): Unit

/** @brief 获取是否应用陀螺力 */
@FastNative
foreign func JPH_Body_GetApplyGyroscopicForce(body: CPointer<Unit>): UInt8

/** @brief 设置是否应用陀螺力 */
@FastNative
foreign func JPH_Body_SetApplyGyroscopicForce(body: CPointer<Unit>, applyGyroscopicForce: UInt8): Unit

/** @brief 获取运动学 vs 非动态碰撞 */
@FastNative
foreign func JPH_Body_GetCollideKinematicVsNonDynamic(body: CPointer<Unit>): UInt8

/** @brief 设置运动学 vs 非动态碰撞 */
@FastNative
foreign func JPH_Body_SetCollideKinematicVsNonDynamic(body: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取增强内部边移除 */
@FastNative
foreign func JPH_Body_GetEnhancedInternalEdgeRemoval(body: CPointer<Unit>): UInt8

/** @brief 设置增强内部边移除 */
@FastNative
foreign func JPH_Body_SetEnhancedInternalEdgeRemoval(body: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取使用流形简化 */
@FastNative
foreign func JPH_Body_GetUseManifoldReduction(body: CPointer<Unit>): UInt8

/** @brief 设置使用流形简化 */
@FastNative
foreign func JPH_Body_SetUseManifoldReduction(body: CPointer<Unit>, value: UInt8): Unit

/** @brief 接触缓存是否失效 */
@FastNative
foreign func JPH_Body_IsCollisionCacheInvalid(body: CPointer<Unit>): UInt8

/** @brief 是否可切换运动学/动态 */
@FastNative
foreign func JPH_Body_CanBeKinematicOrDynamic(body: CPointer<Unit>): UInt8

/** @brief 获取固定到世界的刚体（静态刚体返回自身） */
@FastNative
foreign func JPH_Body_GetFixedToWorldBody(): CPointer<Unit>

/** @brief 获取软体顶点数量 */
@FastNative
foreign func JPH_Body_GetSoftBodyVertexCount(body: CPointer<Unit>): UInt32

/** @brief 获取软体顶点位置（输出 position） */
@FastNative
foreign func JPH_Body_GetSoftBodyVertexPosition(body: CPointer<Unit>, vertexIndex: UInt32, position: CPointer<JPHVec3>): Unit

/** @brief 批量获取软体顶点位置（positions 数组） */
@FastNative
foreign func JPH_Body_GetSoftBodyVertexPositions(
    body: CPointer<Unit>, outPositions: CPointer<JPHVec3>, capacity: UInt32, outCount: CPointer<UInt32>
): Unit

// =============================================================================
// 运动属性（MotionProperties）
// =============================================================================

/** @brief 获取允许自由度（AllowedDOFs 位掩码） */
@FastNative
foreign func JPH_MotionProperties_GetAllowedDOFs(properties: CPointer<Unit>): UInt32

/** @brief 设置线阻尼 */
@FastNative
foreign func JPH_MotionProperties_SetLinearDamping(properties: CPointer<Unit>, damping: Float32): Unit

/** @brief 获取线阻尼 */
@FastNative
foreign func JPH_MotionProperties_GetLinearDamping(properties: CPointer<Unit>): Float32

/** @brief 设置角阻尼 */
@FastNative
foreign func JPH_MotionProperties_SetAngularDamping(properties: CPointer<Unit>, damping: Float32): Unit

/** @brief 获取角阻尼 */
@FastNative
foreign func JPH_MotionProperties_GetAngularDamping(properties: CPointer<Unit>): Float32

/** @brief 设置质量属性（allowedDOFs + massProperties） */
@FastNative
foreign func JPH_MotionProperties_SetMassProperties(
    properties: CPointer<Unit>, allowedDOFs: UInt32, massProperties: CPointer<JPHMassProperties>
): Unit

/** @brief 获取逆质量（未检查版本） */
@FastNative
foreign func JPH_MotionProperties_GetInverseMassUnchecked(properties: CPointer<Unit>): Float32

/** @brief 设置逆质量 */
@FastNative
foreign func JPH_MotionProperties_SetInverseMass(properties: CPointer<Unit>, inverseMass: Float32): Unit

/** @brief 获取逆惯量对角线（输出 result） */
@FastNative
foreign func JPH_MotionProperties_GetInverseInertiaDiagonal(
    properties: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取惯量旋转（输出 result） */
@FastNative
foreign func JPH_MotionProperties_GetInertiaRotation(
    properties: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit

/** @brief 设置逆惯量（对角线 + 旋转） */
@FastNative
foreign func JPH_MotionProperties_SetInverseInertia(
    properties: CPointer<Unit>, diagonal: CPointer<JPHVec3>, rot: CPointer<JPHQuat>
): Unit

/** @brief 缩放到指定质量 */
@FastNative
foreign func JPH_MotionProperties_ScaleToMass(properties: CPointer<Unit>, mass: Float32): Unit

// =============================================================================
// 车辆约束（VehicleConstraint）
// =============================================================================

/** @brief 初始化车辆约束设置 */
@FastNative
foreign func JPH_VehicleConstraintSettings_Init(settings: CPointer<JPHVehicleConstraintSettings>): Unit

/** @brief 创建车辆约束（body 车辆刚体，settings 设置） */
@FastNative
foreign func JPH_VehicleConstraint_Create(
    body: CPointer<Unit>, settings: CPointer<JPHVehicleConstraintSettings>
): CPointer<Unit>

/** @brief 车辆约束转为步进监听器句柄 */
@FastNative
foreign func JPH_VehicleConstraint_AsPhysicsStepListener(constraint: CPointer<Unit>): CPointer<Unit>

/** @brief 设置最大俯仰/横滚角 */
@FastNative
foreign func JPH_VehicleConstraint_SetMaxPitchRollAngle(
    constraint: CPointer<Unit>, maxPitchRollAngle: Float32
): Unit

/** @brief 设置车辆碰撞测试器 */
@FastNative
foreign func JPH_VehicleConstraint_SetVehicleCollisionTester(
    constraint: CPointer<Unit>, tester: CPointer<Unit>
): Unit

/** @brief 覆盖重力 */
@FastNative
foreign func JPH_VehicleConstraint_OverrideGravity(
    constraint: CPointer<Unit>, value: CPointer<JPHVec3>
): Unit

/** @brief 重力是否被覆盖 */
@FastNative
foreign func JPH_VehicleConstraint_IsGravityOverridden(constraint: CPointer<Unit>): UInt8

/** @brief 获取重力覆盖值（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetGravityOverride(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 重置重力覆盖 */
@FastNative
foreign func JPH_VehicleConstraint_ResetGravityOverride(constraint: CPointer<Unit>): Unit

/** @brief 获取局部前进方向（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetLocalForward(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取局部上方向（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetLocalUp(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取世界空间上方向（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetWorldUp(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取车辆刚体句柄 */
@FastNative
foreign func JPH_VehicleConstraint_GetVehicleBody(constraint: CPointer<Unit>): CPointer<Unit>

/** @brief 获取车辆控制器句柄 */
@FastNative
foreign func JPH_VehicleConstraint_GetController(constraint: CPointer<Unit>): CPointer<Unit>

/** @brief 获取车轮数量 */
@FastNative
foreign func JPH_VehicleConstraint_GetWheelsCount(constraint: CPointer<Unit>): UInt32

/** @brief 获取指定车轮句柄 */
@FastNative
foreign func JPH_VehicleConstraint_GetWheel(constraint: CPointer<Unit>, index: UInt32): CPointer<Unit>

/** @brief 获取车轮局部基向量（输出 outForward/outUp/outRight） */
@FastNative
foreign func JPH_VehicleConstraint_GetWheelLocalBasis(
    constraint: CPointer<Unit>, wheel: CPointer<Unit>,
    outForward: CPointer<JPHVec3>, outUp: CPointer<JPHVec3>, outRight: CPointer<JPHVec3>
): Unit

/** @brief 获取车轮局部变换矩阵（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetWheelLocalTransform(
    constraint: CPointer<Unit>, wheelIndex: UInt32,
    wheelRight: CPointer<JPHVec3>, wheelUp: CPointer<JPHVec3>, result: CPointer<JPHMat4>
): Unit

/** @brief 获取车轮世界变换矩阵（输出 result） */
@FastNative
foreign func JPH_VehicleConstraint_GetWheelWorldTransform(
    constraint: CPointer<Unit>, wheelIndex: UInt32,
    wheelRight: CPointer<JPHVec3>, wheelUp: CPointer<JPHVec3>, result: CPointer<JPHMat4>
): Unit

// =============================================================================
// 车辆车轮设置（WheelSettings）与车轮（Wheel）
// =============================================================================

/** @brief 创建车轮设置 */
@FastNative
foreign func JPH_WheelSettings_Create(): CPointer<Unit>

/** @brief 销毁车轮设置 */
@FastNative
foreign func JPH_WheelSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取车轮位置（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetPosition(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置车轮位置 */
@FastNative
foreign func JPH_WheelSettings_SetPosition(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取悬挂力作用点（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionForcePoint(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置悬挂力作用点 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionForcePoint(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取悬挂方向（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionDirection(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置悬挂方向 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionDirection(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取转向轴（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetSteeringAxis(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置转向轴 */
@FastNative
foreign func JPH_WheelSettings_SetSteeringAxis(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取轮轴上方向（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetWheelUp(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置轮轴上方向 */
@FastNative
foreign func JPH_WheelSettings_SetWheelUp(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取轮轴前进方向（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetWheelForward(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 设置轮轴前进方向 */
@FastNative
foreign func JPH_WheelSettings_SetWheelForward(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit

/** @brief 获取悬挂最小长度 */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionMinLength(settings: CPointer<Unit>): Float32

/** @brief 设置悬挂最小长度 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionMinLength(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取悬挂最大长度 */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionMaxLength(settings: CPointer<Unit>): Float32

/** @brief 设置悬挂最大长度 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionMaxLength(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取悬挂预载长度 */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionPreloadLength(settings: CPointer<Unit>): Float32

/** @brief 设置悬挂预载长度 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionPreloadLength(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取悬挂弹簧设置（输出 result） */
@FastNative
foreign func JPH_WheelSettings_GetSuspensionSpring(settings: CPointer<Unit>, result: CPointer<JPHSpringSettings>): Unit

/** @brief 设置悬挂弹簧设置 */
@FastNative
foreign func JPH_WheelSettings_SetSuspensionSpring(settings: CPointer<Unit>, springSettings: CPointer<JPHSpringSettings>): Unit

/** @brief 获取车轮半径 */
@FastNative
foreign func JPH_WheelSettings_GetRadius(settings: CPointer<Unit>): Float32

/** @brief 设置车轮半径 */
@FastNative
foreign func JPH_WheelSettings_SetRadius(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取车轮宽度 */
@FastNative
foreign func JPH_WheelSettings_GetWidth(settings: CPointer<Unit>): Float32

/** @brief 设置车轮宽度 */
@FastNative
foreign func JPH_WheelSettings_SetWidth(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 是否启用悬挂力作用点 */
@FastNative
foreign func JPH_WheelSettings_GetEnableSuspensionForcePoint(settings: CPointer<Unit>): UInt8

/** @brief 设置是否启用悬挂力作用点 */
@FastNative
foreign func JPH_WheelSettings_SetEnableSuspensionForcePoint(settings: CPointer<Unit>, value: UInt8): Unit

/** @brief 创建车轮 */
@FastNative
foreign func JPH_Wheel_Create(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁车轮 */
@FastNative
foreign func JPH_Wheel_Destroy(wheel: CPointer<Unit>): Unit

/** @brief 获取车轮设置句柄 */
@FastNative
foreign func JPH_Wheel_GetSettings(wheel: CPointer<Unit>): CPointer<Unit>

/** @brief 获取车轮角速度 */
@FastNative
foreign func JPH_Wheel_GetAngularVelocity(wheel: CPointer<Unit>): Float32

/** @brief 设置车轮角速度 */
@FastNative
foreign func JPH_Wheel_SetAngularVelocity(wheel: CPointer<Unit>, value: Float32): Unit

/** @brief 获取车轮旋转角 */
@FastNative
foreign func JPH_Wheel_GetRotationAngle(wheel: CPointer<Unit>): Float32

/** @brief 设置车轮旋转角 */
@FastNative
foreign func JPH_Wheel_SetRotationAngle(wheel: CPointer<Unit>, value: Float32): Unit

/** @brief 获取车轮转向角 */
@FastNative
foreign func JPH_Wheel_GetSteerAngle(wheel: CPointer<Unit>): Float32

/** @brief 设置车轮转向角 */
@FastNative
foreign func JPH_Wheel_SetSteerAngle(wheel: CPointer<Unit>, value: Float32): Unit

/** @brief 车轮是否有接触 */
@FastNative
foreign func JPH_Wheel_HasContact(wheel: CPointer<Unit>): UInt8

/** @brief 获取接触刚体 BodyID */
@FastNative
foreign func JPH_Wheel_GetContactBodyID(wheel: CPointer<Unit>): UInt32

/** @brief 获取接触子形状 ID */
@FastNative
foreign func JPH_Wheel_GetContactSubShapeID(wheel: CPointer<Unit>): UInt32

/** @brief 获取接触位置（输出 result） */
@FastNative
foreign func JPH_Wheel_GetContactPosition(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取接触点速度（输出 result） */
@FastNative
foreign func JPH_Wheel_GetContactPointVelocity(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取接触法线（输出 result） */
@FastNative
foreign func JPH_Wheel_GetContactNormal(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取接触纵向方向（输出 result） */
@FastNative
foreign func JPH_Wheel_GetContactLongitudinal(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取接触横向方向（输出 result） */
@FastNative
foreign func JPH_Wheel_GetContactLateral(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit

/** @brief 获取悬挂长度 */
@FastNative
foreign func JPH_Wheel_GetSuspensionLength(wheel: CPointer<Unit>): Float32

/** @brief 获取悬挂 lambda */
@FastNative
foreign func JPH_Wheel_GetSuspensionLambda(wheel: CPointer<Unit>): Float32

/** @brief 获取纵向 lambda */
@FastNative
foreign func JPH_Wheel_GetLongitudinalLambda(wheel: CPointer<Unit>): Float32

/** @brief 获取横向 lambda */
@FastNative
foreign func JPH_Wheel_GetLateralLambda(wheel: CPointer<Unit>): Float32

/** @brief 是否已撞到硬点 */
@FastNative
foreign func JPH_Wheel_HasHitHardPoint(wheel: CPointer<Unit>): UInt8

// =============================================================================
// 车辆：防倾杆 / 引擎 / 差速器 / 变速箱
// =============================================================================

/** @brief 初始化防倾杆设置 */
@FastNative
foreign func JPH_VehicleAntiRollBar_Init(antiRollBar: CPointer<JPHVehicleAntiRollBar>): Unit

/** @brief 初始化引擎设置 */
@FastNative
foreign func JPH_VehicleEngineSettings_Init(settings: CPointer<JPHVehicleEngineSettings>): Unit

/** @brief 钳制 RPM 到合理范围 */
@FastNative
foreign func JPH_VehicleEngine_ClampRPM(engine: CPointer<Unit>): Unit

/** @brief 获取当前 RPM */
@FastNative
foreign func JPH_VehicleEngine_GetCurrentRPM(engine: CPointer<Unit>): Float32

/** @brief 设置当前 RPM */
@FastNative
foreign func JPH_VehicleEngine_SetCurrentRPM(engine: CPointer<Unit>, rpm: Float32): Unit

/** @brief 获取引擎角速度 */
@FastNative
foreign func JPH_VehicleEngine_GetAngularVelocity(engine: CPointer<Unit>): Float32

/** @brief 获取引擎扭矩（acceleration 油门 0~1） */
@FastNative
foreign func JPH_VehicleEngine_GetTorque(engine: CPointer<Unit>, acceleration: Float32): Float32

/** @brief 应用扭矩（deltaTime 步长） */
@FastNative
foreign func JPH_VehicleEngine_ApplyTorque(engine: CPointer<Unit>, torque: Float32, deltaTime: Float32): Unit

/** @brief 应用阻尼（deltaTime 步长） */
@FastNative
foreign func JPH_VehicleEngine_ApplyDamping(engine: CPointer<Unit>, deltaTime: Float32): Unit

/** @brief 引擎是否允许休眠 */
@FastNative
foreign func JPH_VehicleEngine_AllowSleep(engine: CPointer<Unit>): UInt8

/** @brief 初始化差速器设置 */
@FastNative
foreign func JPH_VehicleDifferentialSettings_Init(settings: CPointer<JPHVehicleDifferentialSettings>): Unit

/** @brief 创建变速箱设置 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_Create(): CPointer<Unit>

/** @brief 销毁变速箱设置 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取变速箱模式（TransmissionMode 枚举值） */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetMode(settings: CPointer<Unit>): UInt32

/** @brief 设置变速箱模式 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetMode(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取档位比数量 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetGearRatioCount(settings: CPointer<Unit>): UInt32

/** @brief 获取指定档位比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetGearRatio(settings: CPointer<Unit>, index: UInt32): Float32

/** @brief 设置指定档位比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetGearRatio(settings: CPointer<Unit>, index: UInt32, value: Float32): Unit

/** @brief 获取档位比数组指针 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetGearRatios(settings: CPointer<Unit>): CPointer<Float32>

/** @brief 批量设置档位比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetGearRatios(
    settings: CPointer<Unit>, values: CPointer<Float32>, count: UInt32
): Unit

/** @brief 获取倒档比数量 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetReverseGearRatioCount(settings: CPointer<Unit>): UInt32

/** @brief 获取指定倒档比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetReverseGearRatio(settings: CPointer<Unit>, index: UInt32): Float32

/** @brief 设置指定倒档比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetReverseGearRatio(settings: CPointer<Unit>, index: UInt32, value: Float32): Unit

/** @brief 获取倒档比数组指针 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetReverseGearRatios(settings: CPointer<Unit>): CPointer<Float32>

/** @brief 批量设置倒档比 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetReverseGearRatios(
    settings: CPointer<Unit>, values: CPointer<Float32>, count: UInt32
): Unit

/** @brief 获取升档 RPM */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetShiftUpRPM(settings: CPointer<Unit>): Float32

/** @brief 设置升档 RPM */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetShiftUpRPM(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取降档 RPM */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetShiftDownRPM(settings: CPointer<Unit>): Float32

/** @brief 设置降档 RPM */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetShiftDownRPM(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取换挡延迟（秒） */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetSwitchLatency(settings: CPointer<Unit>): Float32

/** @brief 设置换挡延迟 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetSwitchLatency(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取换挡时间 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetSwitchTime(settings: CPointer<Unit>): Float32

/** @brief 设置换挡时间 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetSwitchTime(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取离合器强度 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetClutchStrength(settings: CPointer<Unit>): Float32

/** @brief 设置离合器强度 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetClutchStrength(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取离合器释放时间 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_GetClutchReleaseTime(settings: CPointer<Unit>): Float32

/** @brief 设置离合器释放时间 */
@FastNative
foreign func JPH_VehicleTransmissionSettings_SetClutchReleaseTime(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 变速箱是否允许休眠 */
@FastNative
foreign func JPH_VehicleTransmission_AllowSleep(transmission: CPointer<Unit>): UInt8

/** @brief 获取离合器摩擦力 */
@FastNative
foreign func JPH_VehicleTransmission_GetClutchFriction(transmission: CPointer<Unit>): Float32

/** @brief 获取当前档位 */
@FastNative
foreign func JPH_VehicleTransmission_GetCurrentGear(transmission: CPointer<Unit>): Int32

/** @brief 获取当前传动比 */
@FastNative
foreign func JPH_VehicleTransmission_GetCurrentRatio(transmission: CPointer<Unit>): Float32

/** @brief 是否正在换挡 */
@FastNative
foreign func JPH_VehicleTransmission_IsSwitchingGear(transmission: CPointer<Unit>): UInt8

/** @brief 设置变速箱状态 */
@FastNative
foreign func JPH_VehicleTransmission_Set(transmission: CPointer<Unit>, currentGear: Int32, clutchFriction: Float32): Unit

/** @brief 设置变速箱模式 */
@FastNative
foreign func JPH_VehicleTransmission_SetMode(transmission: CPointer<Unit>, mode: UInt32): Unit

/** @brief 更新变速箱 */
@FastNative
foreign func JPH_VehicleTransmission_Update(transmission: CPointer<Unit>, deltaTime: Float32, currentRPM: Float32, forwardInput: Float32, canShiftUp: UInt8): Unit

// =============================================================================
// 车辆：碰撞测试器 / 线性曲线
// =============================================================================

/** @brief 销毁车辆碰撞测试器 */
@FastNative
foreign func JPH_VehicleCollisionTester_Destroy(tester: CPointer<Unit>): Unit

/** @brief 获取碰撞测试器对象层 */
@FastNative
foreign func JPH_VehicleCollisionTester_GetObjectLayer(tester: CPointer<Unit>): UInt32

/** @brief 设置碰撞测试器对象层 */
@FastNative
foreign func JPH_VehicleCollisionTester_SetObjectLayer(tester: CPointer<Unit>, value: UInt32): Unit

/** @brief 创建射线碰撞测试器（layer 层，up 上方向，maxSlopeAngle 最大坡度角） */
@FastNative
foreign func JPH_VehicleCollisionTesterRay_Create(
    layer: UInt32, up: CPointer<JPHVec3>, maxSlopeAngle: Float32
): CPointer<Unit>

/** @brief 创建球投射碰撞测试器 */
@FastNative
foreign func JPH_VehicleCollisionTesterCastSphere_Create(
    layer: UInt32, radius: Float32, up: CPointer<JPHVec3>, maxSlopeAngle: Float32
): CPointer<Unit>

/** @brief 创建圆柱投射碰撞测试器 */
@FastNative
foreign func JPH_VehicleCollisionTesterCastCylinder_Create(
    layer: UInt32, convexRadiusFraction: Float32
): CPointer<Unit>

/** @brief 创建线性曲线 */
@FastNative
foreign func JPH_LinearCurve_Create(): CPointer<Unit>

/** @brief 销毁线性曲线 */
@FastNative
foreign func JPH_LinearCurve_Destroy(curve: CPointer<Unit>): Unit

/** @brief 清空线性曲线 */
@FastNative
foreign func JPH_LinearCurve_Clear(curve: CPointer<Unit>): Unit

/** @brief 预留曲线点数 */
@FastNative
foreign func JPH_LinearCurve_Reserve(curve: CPointer<Unit>, numPoints: UInt32): Unit

/** @brief 添加曲线点 */
@FastNative
foreign func JPH_LinearCurve_AddPoint(curve: CPointer<Unit>, x: Float32, y: Float32): Unit

/** @brief 排序曲线点 */
@FastNative
foreign func JPH_LinearCurve_Sort(curve: CPointer<Unit>): Unit

/** @brief 获取最小 X */
@FastNative
foreign func JPH_LinearCurve_GetMinX(curve: CPointer<Unit>): Float32

/** @brief 获取最大 X */
@FastNative
foreign func JPH_LinearCurve_GetMaxX(curve: CPointer<Unit>): Float32

/** @brief 获取指定 X 处的插值 */
@FastNative
foreign func JPH_LinearCurve_GetValue(curve: CPointer<Unit>, x: Float32): Float32

// =============================================================================
// 车辆：轮式控制器
// =============================================================================

/** @brief 创建轮式车辆控制器设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_Create(): CPointer<Unit>

/** @brief 获取引擎设置（输出 result） */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_GetEngine(
    settings: CPointer<Unit>, result: CPointer<JPHVehicleEngineSettings>
): Unit

/** @brief 设置引擎设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetEngine(
    settings: CPointer<Unit>, value: CPointer<JPHVehicleEngineSettings>
): Unit

/** @brief 获取指定差速器设置（输出 result） */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_GetDifferential(
    settings: CPointer<Unit>, index: UInt32, result: CPointer<JPHVehicleDifferentialSettings>
): Unit

/** @brief 设置指定差速器设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetDifferential(
    settings: CPointer<Unit>, index: UInt32, value: CPointer<JPHVehicleDifferentialSettings>
): Unit

/** @brief 批量设置差速器设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetDifferentials(
    settings: CPointer<Unit>, values: CPointer<JPHVehicleDifferentialSettings>, count: UInt32
): Unit

/** @brief 获取差速器数量 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_GetDifferentialsCount(settings: CPointer<Unit>): UInt32

/** @brief 设置差速器数量 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetDifferentialsCount(settings: CPointer<Unit>, value: UInt32): Unit

/** @brief 获取差速器限滑比 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio(settings: CPointer<Unit>): Float32

/** @brief 设置差速器限滑比 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取引擎句柄 */
@FastNative
foreign func JPH_WheeledVehicleController_GetEngine(controller: CPointer<Unit>): CPointer<Unit>

/** @brief 获取变速箱句柄 */
@FastNative
foreign func JPH_WheeledVehicleController_GetTransmission(controller: CPointer<Unit>): CPointer<Unit>

/** @brief 获取前进输入（0~1） */
@FastNative
foreign func JPH_WheeledVehicleController_GetForwardInput(controller: CPointer<Unit>): Float32

/** @brief 设置前进输入（0~1，负值倒车） */
@FastNative
foreign func JPH_WheeledVehicleController_SetForwardInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取右转输入（-1~1） */
@FastNative
foreign func JPH_WheeledVehicleController_GetRightInput(controller: CPointer<Unit>): Float32

/** @brief 设置右转输入（-1~1） */
@FastNative
foreign func JPH_WheeledVehicleController_SetRightInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取刹车输入（0~1） */
@FastNative
foreign func JPH_WheeledVehicleController_GetBrakeInput(controller: CPointer<Unit>): Float32

/** @brief 设置刹车输入（0~1） */
@FastNative
foreign func JPH_WheeledVehicleController_SetBrakeInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取手刹输入（0~1） */
@FastNative
foreign func JPH_WheeledVehicleController_GetHandBrakeInput(controller: CPointer<Unit>): Float32

/** @brief 设置手刹输入（0~1） */
@FastNative
foreign func JPH_WheeledVehicleController_SetHandBrakeInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 设置驾驶输入（前进 + 转向 + 刹车 + 手刹一次设置） */
@FastNative
foreign func JPH_WheeledVehicleController_SetDriverInput(
    controller: CPointer<Unit>, forward: Float32, right: Float32, brake: Float32, handBrake: Float32
): Unit

/** @brief 获取离合器处轮速 */
@FastNative
foreign func JPH_WheeledVehicleController_GetWheelSpeedAtClutch(controller: CPointer<Unit>): Float32

/** @brief 设置轮胎最大冲量回调 */
@FastNative
foreign func JPH_WheeledVehicleController_SetTireMaxImpulseCallback(
    controller: CPointer<Unit>, callback: CPointer<Unit>, userData: CPointer<Unit>
): Unit

// =============================================================================
// 车辆：摩托车控制器 / 履带控制器
// =============================================================================

/** @brief 创建摩托车控制器设置 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_Create(): CPointer<Unit>

/** @brief 获取最大倾斜角 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetMaxLeanAngle(settings: CPointer<Unit>): Float32

/** @brief 设置最大倾斜角 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetMaxLeanAngle(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜平滑因子 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetLeanSmoothingFactor(settings: CPointer<Unit>): Float32

/** @brief 设置倾斜平滑因子 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetLeanSmoothingFactor(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧常数 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetLeanSpringConstant(settings: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧常数 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetLeanSpringConstant(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧阻尼 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetLeanSpringDamping(settings: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧阻尼 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetLeanSpringDamping(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧积分系数 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient(settings: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧积分系数 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧积分系数衰减 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay(settings: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧积分系数衰减 */
@FastNative
foreign func JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 是否启用倾斜控制器 */
@FastNative
foreign func JPH_MotorcycleController_IsLeanControllerEnabled(controller: CPointer<Unit>): UInt8

/** @brief 启用/禁用倾斜控制器 */
@FastNative
foreign func JPH_MotorcycleController_EnableLeanController(controller: CPointer<Unit>, value: UInt8): Unit

/** @brief 是否启用转向倾斜限位 */
@FastNative
foreign func JPH_MotorcycleController_IsLeanSteeringLimitEnabled(controller: CPointer<Unit>): UInt8

/** @brief 启用/禁用转向倾斜限位 */
@FastNative
foreign func JPH_MotorcycleController_EnableLeanSteeringLimit(controller: CPointer<Unit>, value: UInt8): Unit

/** @brief 获取倾斜平滑因子 */
@FastNative
foreign func JPH_MotorcycleController_GetLeanSmoothingFactor(controller: CPointer<Unit>): Float32

/** @brief 设置倾斜平滑因子 */
@FastNative
foreign func JPH_MotorcycleController_SetLeanSmoothingFactor(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧常数 */
@FastNative
foreign func JPH_MotorcycleController_GetLeanSpringConstant(controller: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧常数 */
@FastNative
foreign func JPH_MotorcycleController_SetLeanSpringConstant(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧阻尼 */
@FastNative
foreign func JPH_MotorcycleController_GetLeanSpringDamping(controller: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧阻尼 */
@FastNative
foreign func JPH_MotorcycleController_SetLeanSpringDamping(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧积分系数 */
@FastNative
foreign func JPH_MotorcycleController_GetLeanSpringIntegrationCoefficient(controller: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧积分系数 */
@FastNative
foreign func JPH_MotorcycleController_SetLeanSpringIntegrationCoefficient(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取倾斜弹簧积分系数衰减 */
@FastNative
foreign func JPH_MotorcycleController_GetLeanSpringIntegrationCoefficientDecay(controller: CPointer<Unit>): Float32

/** @brief 设置倾斜弹簧积分系数衰减 */
@FastNative
foreign func JPH_MotorcycleController_SetLeanSpringIntegrationCoefficientDecay(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取轴距 */
@FastNative
foreign func JPH_MotorcycleController_GetWheelBase(controller: CPointer<Unit>): Float32

/** @brief 初始化履带设置 */
@FastNative
foreign func JPH_VehicleTrackSettings_Init(settings: CPointer<JPHVehicleTrackSettings>): Unit

/** @brief 获取履带角速度 */
@FastNative
foreign func JPH_VehicleTrack_GetAngularVelocity(track: CPointer<Unit>): Float32

/** @brief 设置履带角速度 */
@FastNative
foreign func JPH_VehicleTrack_SetAngularVelocity(track: CPointer<Unit>, velocity: Float32): Unit

/** @brief 获取驱动轮索引 */
@FastNative
foreign func JPH_VehicleTrack_GetDrivenWheel(track: CPointer<Unit>): UInt32

/** @brief 获取履带转动惯量 */
@FastNative
foreign func JPH_VehicleTrack_GetInertia(track: CPointer<Unit>): Float32

/** @brief 获取履带角阻尼 */
@FastNative
foreign func JPH_VehicleTrack_GetAngularDamping(track: CPointer<Unit>): Float32

/** @brief 获取履带最大制动力矩 */
@FastNative
foreign func JPH_VehicleTrack_GetMaxBrakeTorque(track: CPointer<Unit>): Float32

/** @brief 获取履带差速比 */
@FastNative
foreign func JPH_VehicleTrack_GetDifferentialRatio(track: CPointer<Unit>): Float32

/** @brief 创建履带车辆控制器设置 */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_Create(): CPointer<Unit>

/** @brief 获取履带车辆引擎设置（输出 result） */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_GetEngine(
    settings: CPointer<Unit>, result: CPointer<JPHVehicleEngineSettings>
): Unit

/** @brief 设置履带车辆引擎设置 */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_SetEngine(
    settings: CPointer<Unit>, value: CPointer<JPHVehicleEngineSettings>
): Unit

/** @brief 设置指定履带设置 */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_SetTrack(
    settings: CPointer<Unit>, index: UInt32, track: CPointer<JPHVehicleTrackSettings>
): Unit

/** @brief 获取指定侧履带（按 TrackSide） */
@FastNative
foreign func JPH_TrackedVehicleController_GetTrack(controller: CPointer<Unit>, side: UInt32): CPointer<Unit>

/** @brief 获取履带车辆引擎句柄 */
@FastNative
foreign func JPH_TrackedVehicleController_GetEngine(controller: CPointer<Unit>): CPointer<Unit>

/** @brief 获取履带车辆变速箱句柄 */
@FastNative
foreign func JPH_TrackedVehicleController_GetTransmission(controller: CPointer<Unit>): CPointer<Unit>

/** @brief 获取前进输入 */
@FastNative
foreign func JPH_TrackedVehicleController_GetForwardInput(controller: CPointer<Unit>): Float32

/** @brief 设置前进输入 */
@FastNative
foreign func JPH_TrackedVehicleController_SetForwardInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取左履带比例 */
@FastNative
foreign func JPH_TrackedVehicleController_GetLeftRatio(controller: CPointer<Unit>): Float32

/** @brief 设置左履带比例 */
@FastNative
foreign func JPH_TrackedVehicleController_SetLeftRatio(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取右履带比例 */
@FastNative
foreign func JPH_TrackedVehicleController_GetRightRatio(controller: CPointer<Unit>): Float32

/** @brief 设置右履带比例 */
@FastNative
foreign func JPH_TrackedVehicleController_SetRightRatio(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 获取刹车输入 */
@FastNative
foreign func JPH_TrackedVehicleController_GetBrakeInput(controller: CPointer<Unit>): Float32

/** @brief 设置刹车输入 */
@FastNative
foreign func JPH_TrackedVehicleController_SetBrakeInput(controller: CPointer<Unit>, value: Float32): Unit

/** @brief 设置驾驶输入（前进 + 左右履带比例 + 刹车） */
@FastNative
foreign func JPH_TrackedVehicleController_SetDriverInput(
    controller: CPointer<Unit>, forward: Float32, leftRatio: Float32, rightRatio: Float32, brake: Float32
): Unit

/** @brief 销毁车辆控制器设置 */
@FastNative
foreign func JPH_VehicleControllerSettings_Destroy(settings: CPointer<Unit>): Unit

/** @brief 获取控制器所属约束 */
@FastNative
foreign func JPH_VehicleController_GetConstraint(controller: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// 临时分配器（TempAllocator）
// =============================================================================

/** @brief 创建临时分配器（size 字节数） */
@FastNative
foreign func JPH_TempAllocator_Create(size: UInt32): CPointer<Unit>

/** @brief 创建 malloc 式临时分配器（自动增长） */
@FastNative
foreign func JPH_TempAllocatorMalloc_Create(): CPointer<Unit>

/** @brief 销毁临时分配器 */
@FastNative
foreign func JPH_TempAllocator_Destroy(allocator: CPointer<Unit>): Unit

/** @brief 步进物理世界一帧（带临时分配器版本） */
foreign func JPH_PhysicsSystem_Update2(
    system: CPointer<Unit>, deltaTime: Float32, collisionSteps: Int32,
    tempAllocator: CPointer<Unit>, jobSystem: CPointer<Unit>
): UInt32

/** @brief 创建回调作业系统（自定义线程池） */
foreign func JPH_JobSystemCallback_Create(config: CPointer<JPHJobSystemConfig>): CPointer<Unit>

// =============================================================================
// 过滤器 / 监听器（SetProcs + Create + Destroy）
// =============================================================================

/** @brief 设置宽相位层过滤器回调表 */
foreign func JPH_BroadPhaseLayerFilter_SetProcs(procs: CPointer<JPHBroadPhaseLayerFilterProcs>): Unit

/** @brief 创建宽相位层过滤器实例 */
@FastNative
foreign func JPH_BroadPhaseLayerFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁宽相位层过滤器 */
@FastNative
foreign func JPH_BroadPhaseLayerFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 设置对象层过滤器回调表 */
foreign func JPH_ObjectLayerFilter_SetProcs(procs: CPointer<JPHObjectLayerFilterProcs>): Unit

/** @brief 创建对象层过滤器实例 */
@FastNative
foreign func JPH_ObjectLayerFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁对象层过滤器 */
@FastNative
foreign func JPH_ObjectLayerFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 设置刚体过滤器回调表 */
foreign func JPH_BodyFilter_SetProcs(procs: CPointer<JPHBodyFilterProcs>): Unit

/** @brief 创建刚体过滤器实例 */
@FastNative
foreign func JPH_BodyFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁刚体过滤器 */
@FastNative
foreign func JPH_BodyFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 设置形状过滤器回调表 */
foreign func JPH_ShapeFilter_SetProcs(procs: CPointer<JPHShapeFilterProcs>): Unit

/** @brief 创建形状过滤器实例 */
@FastNative
foreign func JPH_ShapeFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁形状过滤器 */
@FastNative
foreign func JPH_ShapeFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 获取形状过滤器的 BodyID2 */
@FastNative
foreign func JPH_ShapeFilter_GetBodyID2(filter: CPointer<Unit>): UInt32

/** @brief 设置形状过滤器的 BodyID2 */
@FastNative
foreign func JPH_ShapeFilter_SetBodyID2(filter: CPointer<Unit>, id: UInt32): Unit

/** @brief 设置模拟形状过滤器回调表 */
foreign func JPH_SimShapeFilter_SetProcs(procs: CPointer<JPHSimShapeFilterProcs>): Unit

/** @brief 创建模拟形状过滤器实例 */
@FastNative
foreign func JPH_SimShapeFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁模拟形状过滤器 */
@FastNative
foreign func JPH_SimShapeFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 设置接触监听器回调表 */
foreign func JPH_ContactListener_SetProcs(procs: CPointer<JPHContactListenerProcs>): Unit

/** @brief 创建接触监听器实例 */
@FastNative
foreign func JPH_ContactListener_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁接触监听器 */
@FastNative
foreign func JPH_ContactListener_Destroy(listener: CPointer<Unit>): Unit

/** @brief 设置刚体激活监听器回调表 */
foreign func JPH_BodyActivationListener_SetProcs(procs: CPointer<JPHBodyActivationListenerProcs>): Unit

/** @brief 创建刚体激活监听器实例 */
@FastNative
foreign func JPH_BodyActivationListener_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁刚体激活监听器 */
@FastNative
foreign func JPH_BodyActivationListener_Destroy(listener: CPointer<Unit>): Unit

/** @brief 设置刚体绘制过滤器回调表 */
foreign func JPH_BodyDrawFilter_SetProcs(procs: CPointer<JPHBodyDrawFilterProcs>): Unit

/** @brief 创建刚体绘制过滤器实例 */
@FastNative
foreign func JPH_BodyDrawFilter_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁刚体绘制过滤器 */
@FastNative
foreign func JPH_BodyDrawFilter_Destroy(filter: CPointer<Unit>): Unit

/** @brief 设置角色接触监听器回调表 */
@FastNative
foreign func JPH_CharacterContactListener_SetProcs(procs: CPointer<JPHCharacterContactListenerProcs>): Unit

/** @brief 创建角色接触监听器实例 */
@FastNative
foreign func JPH_CharacterContactListener_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁角色接触监听器 */
@FastNative
foreign func JPH_CharacterContactListener_Destroy(listener: CPointer<Unit>): Unit

/** @brief 设置角色间碰撞回调表 */
@FastNative
foreign func JPH_CharacterVsCharacterCollision_SetProcs(procs: CPointer<JPHCharacterVsCharacterCollisionProcs>): Unit

/** @brief 创建角色间碰撞处理实例 */
@FastNative
foreign func JPH_CharacterVsCharacterCollision_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 创建角色间碰撞处理（简单版） */
@FastNative
foreign func JPH_CharacterVsCharacterCollision_CreateSimple(): CPointer<Unit>

/** @brief 向简单角色间碰撞处理添加角色 */
@FastNative
foreign func JPH_CharacterVsCharacterCollisionSimple_AddCharacter(
    characterVsCharacter: CPointer<Unit>, character: CPointer<Unit>
): Unit

/** @brief 从简单角色间碰撞处理移除角色 */
@FastNative
foreign func JPH_CharacterVsCharacterCollisionSimple_RemoveCharacter(
    characterVsCharacter: CPointer<Unit>, character: CPointer<Unit>
): Unit

/** @brief 销毁角色间碰撞处理 */
@FastNative
foreign func JPH_CharacterVsCharacterCollision_Destroy(listener: CPointer<Unit>): Unit

/** @brief 设置调试渲染器回调表 */
foreign func JPH_DebugRenderer_SetProcs(procs: CPointer<JPHDebugRendererProcs>): Unit

/** @brief 创建调试渲染器实例 */
@FastNative
foreign func JPH_DebugRenderer_Create(userData: CPointer<Unit>): CPointer<Unit>

/** @brief 销毁调试渲染器 */
@FastNative
foreign func JPH_DebugRenderer_Destroy(renderer: CPointer<Unit>): Unit

/** @brief 调试渲染器下一帧 */
@FastNative
foreign func JPH_DebugRenderer_NextFrame(renderer: CPointer<Unit>): Unit

/** @brief 设置相机位置 */
@FastNative
foreign func JPH_DebugRenderer_SetCameraPos(renderer: CPointer<Unit>, position: CPointer<JPHVec3>): Unit

/** @brief 绘制线段 */
@FastNative
foreign func JPH_DebugRenderer_DrawLine(
    renderer: CPointer<Unit>, from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, color: UInt32
): Unit

/** @brief 绘制线框包围盒 */
@FastNative
foreign func JPH_DebugRenderer_DrawWireBox(
    renderer: CPointer<Unit>, box: CPointer<JPHAABox>, color: UInt32
): Unit

/** @brief 绘制线框包围盒（带变换矩阵） */
@FastNative
foreign func JPH_DebugRenderer_DrawWireBox2(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, box: CPointer<JPHAABox>, color: UInt32
): Unit

/** @brief 绘制标记点 */
@FastNative
foreign func JPH_DebugRenderer_DrawMarker(
    renderer: CPointer<Unit>, position: CPointer<JPHVec3>, color: UInt32, size: Float32
): Unit

/** @brief 绘制箭头 */
@FastNative
foreign func JPH_DebugRenderer_DrawArrow(
    renderer: CPointer<Unit>, from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, color: UInt32, size: Float32
): Unit

/** @brief 绘制坐标系 */
@FastNative
foreign func JPH_DebugRenderer_DrawCoordinateSystem(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, size: Float32
): Unit

/** @brief 绘制平面 */
@FastNative
foreign func JPH_DebugRenderer_DrawPlane(
    renderer: CPointer<Unit>, point: CPointer<JPHVec3>, normal: CPointer<JPHVec3>,
    color: UInt32, size: Float32
): Unit

/** @brief 绘制线框三角形 */
@FastNative
foreign func JPH_DebugRenderer_DrawWireTriangle(
    renderer: CPointer<Unit>, v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>,
    v3: CPointer<JPHVec3>, color: UInt32
): Unit

/** @brief 绘制线框球体 */
@FastNative
foreign func JPH_DebugRenderer_DrawWireSphere(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, color: UInt32, level: Int32
): Unit

/** @brief 绘制线框单位球体 */
@FastNative
foreign func JPH_DebugRenderer_DrawWireUnitSphere(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, color: UInt32, level: Int32
): Unit

/** @brief 绘制三角形 */
@FastNative
foreign func JPH_DebugRenderer_DrawTriangle(
    renderer: CPointer<Unit>, v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>,
    v3: CPointer<JPHVec3>, color: UInt32, castShadow: UInt32
): Unit

/** @brief 绘制包围盒（实体） */
@FastNative
foreign func JPH_DebugRenderer_DrawBox(
    renderer: CPointer<Unit>, box: CPointer<JPHAABox>, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制包围盒（带变换矩阵） */
@FastNative
foreign func JPH_DebugRenderer_DrawBox2(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, box: CPointer<JPHAABox>, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制球体 */
@FastNative
foreign func JPH_DebugRenderer_DrawSphere(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制单位球体 */
@FastNative
foreign func JPH_DebugRenderer_DrawUnitSphere(
    renderer: CPointer<Unit>, matrix: JPHMat4, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制胶囊体 */
@FastNative
foreign func JPH_DebugRenderer_DrawCapsule(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, halfHeightOfCylinder: Float32, radius: Float32,
    color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制圆柱体 */
@FastNative
foreign func JPH_DebugRenderer_DrawCylinder(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, halfHeight: Float32, radius: Float32,
    color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制开放锥体 */
@FastNative
foreign func JPH_DebugRenderer_DrawOpenCone(
    renderer: CPointer<Unit>, top: CPointer<JPHVec3>, axis: CPointer<JPHVec3>,
    perpendicular: CPointer<JPHVec3>, halfAngle: Float32, length: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制摆动锥限位 */
@FastNative
foreign func JPH_DebugRenderer_DrawSwingConeLimits(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, swingYHalfAngle: Float32,
    swingZHalfAngle: Float32, edgeLength: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制摆动金字塔限位 */
@FastNative
foreign func JPH_DebugRenderer_DrawSwingPyramidLimits(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, minSwingYAngle: Float32,
    maxSwingYAngle: Float32, minSwingZAngle: Float32, maxSwingZAngle: Float32,
    edgeLength: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制饼图（角度扇形） */
@FastNative
foreign func JPH_DebugRenderer_DrawPie(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, normal: CPointer<JPHVec3>,
    axis: CPointer<JPHVec3>, minAngle: Float32, maxAngle: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit

/** @brief 绘制锥台圆柱体 */
@FastNative
foreign func JPH_DebugRenderer_DrawTaperedCylinder(
    renderer: CPointer<Unit>, inMatrix: CPointer<JPHMat4>, top: Float32, bottom: Float32,
    topRadius: Float32, bottomRadius: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit

// =============================================================================
// 补充：Body 附加方法 / Settings 初始化 / 碰撞分发 / 接触流形
// =============================================================================

/** @brief 判断两刚体是否使用流形简化（body + other） */
@FastNative
foreign func JPH_Body_GetUseManifoldReductionWithBody(
    body: CPointer<Unit>, other: CPointer<Unit>
): UInt8

/** @brief 判断两刚体是否启用增强内部边移除（body + other） */
@FastNative
foreign func JPH_Body_GetEnhancedInternalEdgeRemovalWithBody(
    body: CPointer<Unit>, other: CPointer<Unit>
): UInt8

/** @brief 设置线速度（钳制到最大速度） */
@FastNative
foreign func JPH_Body_SetLinearVelocityClamped(
    body: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit

/** @brief 设置角速度（钳制到最大速度） */
@FastNative
foreign func JPH_Body_SetAngularVelocityClamped(
    body: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit

/** @brief 刚体是否已在宽相位中 */
@FastNative
foreign func JPH_Body_IsInBroadPhase(body: CPointer<Unit>): UInt8

/** @brief 初始化形状碰撞设置 */
@FastNative
foreign func JPH_CollideShapeSettings_Init(settings: CPointer<JPHCollideShapeSettings>): Unit

/** @brief 初始化形状投射设置 */
@FastNative
foreign func JPH_ShapeCastSettings_Init(settings: CPointer<JPHShapeCastSettings>): Unit

/** @brief 射线命中点计算：result = origin + direction * fraction */
@FastNative
foreign func JPH_RayCast_GetPointOnRay(
    origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>, fraction: Float32, result: CPointer<JPHVec3>
): Unit

/** @brief 双精度射线命中点计算（双精度构建下有效） */
@FastNative
foreign func JPH_RRayCast_GetPointOnRay(
    origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>, fraction: Float32, result: CPointer<JPHVec3>
): Unit

/** @brief 分解惯量主轴（输出 rotation 旋转矩阵 + diagonal 主惯量） */
@FastNative
foreign func JPH_MassProperties_DecomposePrincipalMomentsOfInertia(
    properties: CPointer<JPHMassProperties>, rotation: CPointer<JPHMat4>, diagonal: CPointer<JPHVec3>
): Unit

/** @brief 质量属性缩放到指定质量 */
@FastNative
foreign func JPH_MassProperties_ScaleToMass(properties: CPointer<JPHMassProperties>, mass: Float32): Unit

/** @brief 计算等效实心盒尺寸（mass 质量 + inertiaDiagonal 惯量对角线） */
@FastNative
foreign func JPH_MassProperties_GetEquivalentSolidBoxSize(
    mass: Float32, inertiaDiagonal: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit

// =============================================================================
// 接触流形（ContactManifold）
// =============================================================================

/** @brief 获取接触流形世界空间法线（输出 result） */
@FastNative
foreign func JPH_ContactManifold_GetWorldSpaceNormal(
    manifold: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit

/** @brief 获取接触流形穿透深度 */
@FastNative
foreign func JPH_ContactManifold_GetPenetrationDepth(manifold: CPointer<Unit>): Float32

/** @brief 获取刚体 1 的子形状 ID */
@FastNative
foreign func JPH_ContactManifold_GetSubShapeID1(manifold: CPointer<Unit>): UInt32

/** @brief 获取刚体 2 的子形状 ID */
@FastNative
foreign func JPH_ContactManifold_GetSubShapeID2(manifold: CPointer<Unit>): UInt32

/** @brief 获取接触流形接触点数量 */
@FastNative
foreign func JPH_ContactManifold_GetPointCount(manifold: CPointer<Unit>): UInt32

/** @brief 获取刚体 1 上指定接触点（输出 result） */
@FastNative
foreign func JPH_ContactManifold_GetWorldSpaceContactPointOn1(
    manifold: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>
): Unit

/** @brief 获取刚体 2 上指定接触点（输出 result） */
@FastNative
foreign func JPH_ContactManifold_GetWorldSpaceContactPointOn2(
    manifold: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>
): Unit

// =============================================================================
// 碰撞分发（CollisionDispatch）
// =============================================================================

/** @brief 形状 vs 形状碰撞检测（直接分发） */
@FastNative
foreign func JPH_CollisionDispatch_CollideShapeVsShape(
    shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1: CPointer<JPHVec3>, scale2: CPointer<JPHVec3>,
    centerOfMassTransform1: CPointer<JPHMat4>, centerOfMassTransform2: CPointer<JPHMat4>,
    collideShapeSettings: CPointer<JPHCollideShapeSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 形状投射 vs 形状（形状 2 局部空间） */
@FastNative
foreign func JPH_CollisionDispatch_CastShapeVsShapeLocalSpace(
    direction: CPointer<JPHVec3>, shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1InShape2LocalSpace: CPointer<JPHVec3>, scale2: CPointer<JPHVec3>,
    centerOfMassTransform1InShape2LocalSpace: CPointer<JPHMat4>,
    centerOfMassWorldTransform2: CPointer<JPHMat4>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 形状投射 vs 形状（世界空间） */
@FastNative
foreign func JPH_CollisionDispatch_CastShapeVsShapeWorldSpace(
    direction: CPointer<JPHVec3>, shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1: CPointer<JPHVec3>, inScale2: CPointer<JPHVec3>,
    centerOfMassWorldTransform1: CPointer<JPHMat4>, centerOfMassWorldTransform2: CPointer<JPHMat4>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/** @brief 估计碰撞响应（冲量/速度估计） */
@FastNative
foreign func JPH_EstimateCollisionResponse(
    body1: CPointer<Unit>, body2: CPointer<Unit>, manifold: CPointer<Unit>,
    combinedFriction: Float32, combinedRestitution: Float32, minVelocityForRestitution: Float32,
    numIterations: UInt32, result: CPointer<JPHCollisionEstimationResult>
): Unit

// =============================================================================
// 补充：PhysicsSystem 获取刚体指针 / RagdollSettings 附加 / 线性曲线点访问
// =============================================================================

/** @brief 获取刚体指针（按 BodyID，只读） */
@FastNative
foreign func JPH_PhysicsSystem_GetBodyPtr(system: CPointer<Unit>, bodyID: UInt32): CPointer<Unit>

/** @brief 设置部件对象层 */
@FastNative
foreign func JPH_RagdollSettings_SetPartObjectLayer(
    settings: CPointer<Unit>, partIndex: Int32, layer: UInt32
): Unit

/** @brief 设置部件质量属性（质量） */
@FastNative
foreign func JPH_RagdollSettings_SetPartMassProperties(
    settings: CPointer<Unit>, partIndex: Int32, mass: Float32
): Unit

/** @brief 创建布娃娃实例（从设置 + 物理系统） */
@FastNative
foreign func JPH_RagdollSettings_CreateRagdoll(
    settings: CPointer<Unit>, system: CPointer<Unit>, collisionGroup: UInt32, userData: UInt64
): CPointer<Unit>

/** @brief 获取线性曲线点数 */
@FastNative
foreign func JPH_LinearCurve_GetPointCount(curve: CPointer<Unit>): UInt32

/** @brief 获取指定曲线点（输出 x/y） */
@FastNative
foreign func JPH_LinearCurve_GetPoint(curve: CPointer<Unit>, index: UInt32, result: CPointer<JPHPoint>): Unit

/** @brief 获取曲线点数组指针（x/y 交错数组） */
@FastNative
foreign func JPH_LinearCurve_GetPoints(curve: CPointer<Unit>, points: CPointer<JPHPoint>, count: CPointer<UInt32>): Unit

// =============================================================================
// 补充：变速箱设置（履带车辆控制器）
// =============================================================================

/** @brief 获取履带车辆控制器变速箱设置（输出 result） */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_GetTransmission(
    settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 设置履带车辆控制器变速箱设置 */
@FastNative
foreign func JPH_TrackedVehicleControllerSettings_SetTransmission(
    settings: CPointer<Unit>, value: CPointer<Unit>
): Unit

// =============================================================================
// 补充：轮式车辆控制器变速箱 / 差速器添加
// =============================================================================

/** @brief 添加差速器设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_AddDifferential(
    settings: CPointer<Unit>, leftWheel: Int32, rightWheel: Int32
): Unit

/** @brief 获取轮式车辆控制器变速箱设置（输出 result） */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_GetTransmission(
    settings: CPointer<Unit>
): CPointer<Unit>

/** @brief 设置轮式车辆控制器变速箱设置 */
@FastNative
foreign func JPH_WheeledVehicleControllerSettings_SetTransmission(
    settings: CPointer<Unit>, value: CPointer<Unit>
): Unit

// =============================================================================
// 补充：履带车辆车轮设置 / 车轮
// =============================================================================

/** @brief 创建履带车辆车轮设置 */
@FastNative
foreign func JPH_WheelSettingsTV_Create(): CPointer<Unit>

/** @brief 获取纵向摩擦力 */
@FastNative
foreign func JPH_WheelSettingsTV_GetLongitudinalFriction(settings: CPointer<Unit>): Float32

/** @brief 设置纵向摩擦力 */
@FastNative
foreign func JPH_WheelSettingsTV_SetLongitudinalFriction(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取横向摩擦力 */
@FastNative
foreign func JPH_WheelSettingsTV_GetLateralFriction(settings: CPointer<Unit>): Float32

/** @brief 设置横向摩擦力 */
@FastNative
foreign func JPH_WheelSettingsTV_SetLateralFriction(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 创建履带车辆车轮 */
@FastNative
foreign func JPH_WheelTV_Create(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取履带车辆车轮设置 */
@FastNative
foreign func JPH_WheelTV_GetSettings(wheel: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// 补充：轮式车辆车轮设置 / 车轮
// =============================================================================

/** @brief 创建轮式车辆车轮设置 */
@FastNative
foreign func JPH_WheelSettingsWV_Create(): CPointer<Unit>

/** @brief 获取转动惯量 */
@FastNative
foreign func JPH_WheelSettingsWV_GetInertia(settings: CPointer<Unit>): Float32

/** @brief 设置转动惯量 */
@FastNative
foreign func JPH_WheelSettingsWV_SetInertia(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取角阻尼 */
@FastNative
foreign func JPH_WheelSettingsWV_GetAngularDamping(settings: CPointer<Unit>): Float32

/** @brief 设置角阻尼 */
@FastNative
foreign func JPH_WheelSettingsWV_SetAngularDamping(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取最大转向角 */
@FastNative
foreign func JPH_WheelSettingsWV_GetMaxSteerAngle(settings: CPointer<Unit>): Float32

/** @brief 设置最大转向角 */
@FastNative
foreign func JPH_WheelSettingsWV_SetMaxSteerAngle(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取纵向摩擦力曲线 */
@FastNative
foreign func JPH_WheelSettingsWV_GetLongitudinalFriction(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 设置纵向摩擦力曲线 */
@FastNative
foreign func JPH_WheelSettingsWV_SetLongitudinalFriction(settings: CPointer<Unit>, value: CPointer<Unit>): Unit

/** @brief 获取横向摩擦力曲线 */
@FastNative
foreign func JPH_WheelSettingsWV_GetLateralFriction(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 设置横向摩擦力曲线 */
@FastNative
foreign func JPH_WheelSettingsWV_SetLateralFriction(settings: CPointer<Unit>, value: CPointer<Unit>): Unit

/** @brief 获取最大制动力矩 */
@FastNative
foreign func JPH_WheelSettingsWV_GetMaxBrakeTorque(settings: CPointer<Unit>): Float32

/** @brief 设置最大制动力矩 */
@FastNative
foreign func JPH_WheelSettingsWV_SetMaxBrakeTorque(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 获取最大手刹力矩 */
@FastNative
foreign func JPH_WheelSettingsWV_GetMaxHandBrakeTorque(settings: CPointer<Unit>): Float32

/** @brief 设置最大手刹力矩 */
@FastNative
foreign func JPH_WheelSettingsWV_SetMaxHandBrakeTorque(settings: CPointer<Unit>, value: Float32): Unit

/** @brief 创建轮式车辆车轮 */
@FastNative
foreign func JPH_WheelWV_Create(settings: CPointer<Unit>): CPointer<Unit>

/** @brief 获取轮式车辆车轮设置 */
@FastNative
foreign func JPH_WheelWV_GetSettings(wheel: CPointer<Unit>): CPointer<Unit>

/** @brief 对车轮施加扭矩（deltaTime 步长） */
@FastNative
foreign func JPH_WheelWV_ApplyTorque(wheel: CPointer<Unit>, torque: Float32, deltaTime: Float32): Unit

// =============================================================================
// 窄相查询补充：带收集器类型参数 + shapeFilter 的完整版本
// =============================================================================

/**
 * @brief 窄相射线检测（完整版：收集器类型 + shapeFilter）
 * @param rayCastSettings 射线投射设置
 * @param collectorType 收集器类型（CollisionCollectorType 枚举值）
 * @param callback 收集器回调（JPH_CastRayResultCallback，签名 (context, const JPH_RayCastResult*)）
 * @param shapeFilter 形状过滤（可传空指针）
 */
foreign func JPH_NarrowPhaseQuery_CastRay3(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHRayCastResult>) -> Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/**
 * @brief 窄相点碰撞检测（完整版：收集器类型 + shapeFilter）
 * @param point 世界空间检测点
 * @param collectorType 收集器类型
 * @param callback 收集器回调（JPH_CollidePointResultCallback，签名 (context, const JPH_CollidePointResult*)）
 */
foreign func JPH_NarrowPhaseQuery_CollidePoint2(
    query: CPointer<Unit>, point: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHCollidePointResult>) -> Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/**
 * @brief 窄相形状碰撞检测（完整版：收集器类型 + shapeFilter）
 * @param shape 查询形状
 * @param scale 查询形状缩放
 * @param centerOfMassTransform 查询形状质心变换
 * @param settings 碰撞设置
 * @param baseOffset 基准偏移（用于降低大坐标精度损失）
 * @param collectorType 收集器类型
 * @param callback 收集器回调（JPH_CollideShapeResultCallback，签名 (context, const JPH_CollideShapeResult*)）
 */
foreign func JPH_NarrowPhaseQuery_CollideShape2(
    query: CPointer<Unit>, shape: CPointer<Unit>, scale: CPointer<JPHVec3>,
    centerOfMassTransform: CPointer<JPHMat4>, settings: CPointer<JPHCollideShapeSettings>,
    baseOffset: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHCollideShapeResult>) -> Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8

/**
 * @brief 窄相形状投射（完整版：收集器类型 + shapeFilter）
 * @param shape 投射形状
 * @param worldTransform 形状世界变换
 * @param direction 投射方向（长度即最大投射距离）
 * @param settings 投射设置
 * @param baseOffset 基准偏移
 * @param collectorType 收集器类型
 * @param callback 收集器回调（JPH_CastShapeResultCallback，签名 (context, const JPH_ShapeCastResult*)）
 */
foreign func JPH_NarrowPhaseQuery_CastShape2(
    query: CPointer<Unit>, shape: CPointer<Unit>,
    worldTransform: CPointer<JPHMat4>, direction: CPointer<JPHVec3>,
    settings: CPointer<JPHShapeCastSettings>, baseOffset: CPointer<JPHVec3>,
    collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHShapeCastResult>) -> Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8
