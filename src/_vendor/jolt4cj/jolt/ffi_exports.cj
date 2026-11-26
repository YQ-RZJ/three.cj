/**
 * @file jolt4cj.jolt 公共函数包装（joltc.h 一对一映射）
 * @brief joltc（JoltPhysics C API 包装层，joltc.h）的仓颉安全包装函数
 * @explain 本文件与 cxx/joltc/include/joltc.h 的函数一一对应：每个 C API
 *         对应一个同名 + `_cj` 后缀的公共包装，签名与 C 完全镜像
 *         （参数/返回值类型一一映射），仅将 foreign 调用包裹在 unsafe
 *         块中以满足仓颉 FFI 要求。不包含任何组合、自动分配/释放或
 *         高级封装逻辑——内存与对象生命周期由调用方按 C 语义管理。
 * @note 句柄与指针参数直接透传（CPointer<Unit> / CPointer<JPHVec3> 等），
 *       输出参数需调用方自行用 LibC.malloc 分配缓冲区、用 p.read() 读取。
 * @see cxx/joltc/include/joltc.h
 */
protected package three._vendor.jolt4cj.jolt

// =============================================================================
// 生命周期：全局初始化 / 卸载（进程内只调用一次）
// =============================================================================

/**
 * @brief 初始化 Jolt 全局状态（对应 JPH_Init）
 * @explain 注册默认内存分配器、创建类型工厂并注册全部物理类型。
 *          必须在任何其他 Jolt 函数之前调用。
 * @return 非 0 成功；0 失败（重复调用或内部错误）
 */
public func JPH_Init_cj(): UInt8 {
    unsafe {
        JPH_Init()
    }
}

/**
 * @brief 卸载 Jolt 全局状态（对应 JPH_Shutdown）
 * @explain 释放类型工厂并注销全部物理类型。必须在所有系统/形状销毁后调用。
 */
public func JPH_Shutdown_cj(): Unit {
    unsafe {
        JPH_Shutdown()
    }
}

// =============================================================================
// 作业系统（JobSystem）
// =============================================================================

/**
 * @brief 创建线程池作业系统（对应 JPH_JobSystemThreadPool_Create）
 * @param config 配置指针（JobSystemThreadPoolConfig），可传空指针使用默认值
 * @return 作业系统句柄；失败返回空指针
 */
public func JPH_JobSystemThreadPool_Create_cj(config: CPointer<JobSystemThreadPoolConfig>): CPointer<Unit> {
    unsafe {
        JPH_JobSystemThreadPool_Create(config)
    }
}

/**
 * @brief 销毁作业系统（对应 JPH_JobSystem_Destroy）
 * @param jobSystem 作业系统句柄（空指针安全）
 */
public func JPH_JobSystem_Destroy_cj(jobSystem: CPointer<Unit>): Unit {
    unsafe {
        JPH_JobSystem_Destroy(jobSystem)
    }
}

// =============================================================================
// 层过滤（对象层 / BroadPhase 层）
// =============================================================================

/**
 * @brief 创建对象层两两碰撞过滤表（对应 JPH_ObjectLayerPairFilterTable_Create）
 * @param numObjectLayers 对象层数量（如 2：NonMoving / Moving）
 * @return 过滤表句柄；失败返回空指针
 */
public func JPH_ObjectLayerPairFilterTable_Create_cj(numObjectLayers: UInt32): CPointer<Unit> {
    unsafe {
        JPH_ObjectLayerPairFilterTable_Create(numObjectLayers)
    }
}

/**
 * @brief 允许 layer1 与 layer2 碰撞（对应 JPH_ObjectLayerPairFilterTable_EnableCollision）
 * @param objectFilter 过滤表句柄
 * @param layer1 对象层 1
 * @param layer2 对象层 2
 */
public func JPH_ObjectLayerPairFilterTable_EnableCollision_cj(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): Unit {
    unsafe {
        JPH_ObjectLayerPairFilterTable_EnableCollision(objectFilter, layer1, layer2)
    }
}

/**
 * @brief 禁止 layer1 与 layer2 碰撞（对应 JPH_ObjectLayerPairFilterTable_DisableCollision）
 * @param objectFilter 过滤表句柄
 * @param layer1 对象层 1
 * @param layer2 对象层 2
 */
public func JPH_ObjectLayerPairFilterTable_DisableCollision_cj(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): Unit {
    unsafe {
        JPH_ObjectLayerPairFilterTable_DisableCollision(objectFilter, layer1, layer2)
    }
}

/**
 * @brief 查询 layer1 与 layer2 是否允许碰撞（对应 JPH_ObjectLayerPairFilterTable_ShouldCollide）
 * @param objectFilter 过滤表句柄
 * @param layer1 对象层 1
 * @param layer2 对象层 2
 * @return 非 0 允许碰撞
 */
public func JPH_ObjectLayerPairFilterTable_ShouldCollide_cj(
    objectFilter: CPointer<Unit>, layer1: UInt32, layer2: UInt32
): UInt8 {
    unsafe {
        JPH_ObjectLayerPairFilterTable_ShouldCollide(objectFilter, layer1, layer2)
    }
}

/**
 * @brief 销毁对象层过滤表（对应 JPH_ObjectLayerPairFilter_Destroy）
 * @param filter 过滤表句柄（空指针安全）
 */
public func JPH_ObjectLayerPairFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_ObjectLayerPairFilter_Destroy(filter)
    }
}

/**
 * @brief 创建对象层 -> BroadPhase 层映射表（对应 JPH_BroadPhaseLayerInterfaceTable_Create）
 * @param numObjectLayers 对象层数量
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @return 映射接口句柄；失败返回空指针
 */
public func JPH_BroadPhaseLayerInterfaceTable_Create_cj(
    numObjectLayers: UInt32, numBroadPhaseLayers: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BroadPhaseLayerInterfaceTable_Create(numObjectLayers, numBroadPhaseLayers)
    }
}

/**
 * @brief 将对象层映射到 BroadPhase 层（对应 JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer）
 * @param bpInterface 映射接口句柄
 * @param objectLayer 对象层
 * @param broadPhaseLayer BroadPhase 层
 */
public func JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer_cj(
    bpInterface: CPointer<Unit>, objectLayer: UInt32, broadPhaseLayer: UInt8
): Unit {
    unsafe {
        JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(bpInterface, objectLayer, broadPhaseLayer)
    }
}

/**
 * @brief 销毁对象层 -> BroadPhase 层映射接口（对应 JPH_BroadPhaseLayerInterface_Destroy）
 * @param bpInterface 映射接口句柄（空指针安全）
 */
public func JPH_BroadPhaseLayerInterface_Destroy_cj(bpInterface: CPointer<Unit>): Unit {
    unsafe {
        JPH_BroadPhaseLayerInterface_Destroy(bpInterface)
    }
}

/**
 * @brief 创建对象层 vs BroadPhase 层碰撞过滤表（对应 JPH_ObjectVsBroadPhaseLayerFilterTable_Create）
 * @param broadPhaseLayerInterface 层映射接口
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @param objectLayerPairFilter 对象层过滤表
 * @param numObjectLayers 对象层数量
 * @return 过滤表句柄；失败返回空指针
 */
public func JPH_ObjectVsBroadPhaseLayerFilterTable_Create_cj(
    broadPhaseLayerInterface: CPointer<Unit>,
    numBroadPhaseLayers: UInt32,
    objectLayerPairFilter: CPointer<Unit>,
    numObjectLayers: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
            broadPhaseLayerInterface, numBroadPhaseLayers,
            objectLayerPairFilter, numObjectLayers)
    }
}

/**
 * @brief 销毁对象层 vs BroadPhase 层过滤表（对应 JPH_ObjectVsBroadPhaseLayerFilter_Destroy）
 * @param filter 过滤表句柄（空指针安全）
 */
public func JPH_ObjectVsBroadPhaseLayerFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_ObjectVsBroadPhaseLayerFilter_Destroy(filter)
    }
}

// =============================================================================
// 物理系统（PhysicsSystem）
// =============================================================================

/**
 * @brief 创建物理系统（对应 JPH_PhysicsSystem_Create）
 * @param settings 系统设置指针（JPHPhysicsSystemSettings，含容量上限与层过滤对象）
 * @return 系统句柄；失败返回空指针
 * @note 需先调用 JPH_Init_cj()；settings 引用的层过滤对象须在系统销毁后销毁。
 */
public func JPH_PhysicsSystem_Create_cj(settings: CPointer<JPHPhysicsSystemSettings>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_Create(settings)
    }
}

/**
 * @brief 销毁物理系统并释放其全部资源（对应 JPH_PhysicsSystem_Destroy）
 * @param system 系统句柄（空指针安全）
 */
public func JPH_PhysicsSystem_Destroy_cj(system: CPointer<Unit>): Unit {
    unsafe {
        JPH_PhysicsSystem_Destroy(system)
    }
}

/**
 * @brief 步进物理世界一帧（对应 JPH_PhysicsSystem_Update）
 * @param system 系统句柄
 * @param deltaTime 时间步长（秒），典型 1/60
 * @param collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1，更大步长需向上取整）
 * @param jobSystem 作业系统句柄（JPH_JobSystemThreadPool_Create_cj 创建）
 * @return 更新错误标志（PhysicsUpdateError 位掩码，0 = 完整完成）
 */
public func JPH_PhysicsSystem_Update_cj(
    system: CPointer<Unit>, deltaTime: Float32, collisionSteps: Int32,
    jobSystem: CPointer<Unit>
): UInt32 {
    unsafe {
        JPH_PhysicsSystem_Update(system, deltaTime, collisionSteps, jobSystem)
    }
}

/**
 * @brief 优化 BroadPhase 包围盒树（对应 JPH_PhysicsSystem_OptimizeBroadPhase）
 * @explain 应在批量插入刚体后、正式模拟前调用一次；不要每帧调用。
 * @param system 系统句柄
 */
public func JPH_PhysicsSystem_OptimizeBroadPhase_cj(system: CPointer<Unit>): Unit {
    unsafe {
        JPH_PhysicsSystem_OptimizeBroadPhase(system)
    }
}

/**
 * @brief 设置全局重力（对应 JPH_PhysicsSystem_SetGravity）
 * @param system 系统句柄
 * @param value 重力向量指针（JPHVec3，如 (0, -9.81, 0)）
 */
public func JPH_PhysicsSystem_SetGravity_cj(system: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_PhysicsSystem_SetGravity(system, value)
    }
}

/**
 * @brief 获取刚体接口（对应 JPH_PhysicsSystem_GetBodyInterface）
 * @param system 系统句柄
 * @return 刚体接口句柄（由系统持有，无需释放）
 */
public func JPH_PhysicsSystem_GetBodyInterface_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBodyInterface(system)
    }
}

/**
 * @brief 获取窄相查询接口（对应 JPH_PhysicsSystem_GetNarrowPhaseQuery）
 * @param system 系统句柄
 * @return 查询接口句柄（由系统持有，无需释放）
 */
public func JPH_PhysicsSystem_GetNarrowPhaseQuery_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetNarrowPhaseQuery(system)
    }
}

// =============================================================================
// 形状（Shape）
// =============================================================================

/**
 * @brief 创建长方体形状（对应 JPH_BoxShape_Create）
 * @param halfExtent 半边长指针（JPHVec3，实际尺寸 = 2×半边长）
 * @param convexRadius 凸半径（角部圆角；<=0 用 JPH_DEFAULT_CONVEX_RADIUS）
 * @return 形状句柄；失败返回空指针
 */
public func JPH_BoxShape_Create_cj(halfExtent: CPointer<JPHVec3>, convexRadius: Float32): CPointer<Unit> {
    unsafe {
        JPH_BoxShape_Create(halfExtent, convexRadius)
    }
}

/**
 * @brief 创建球体形状（对应 JPH_SphereShape_Create）
 * @param radius 半径
 * @return 形状句柄；失败返回空指针
 */
public func JPH_SphereShape_Create_cj(radius: Float32): CPointer<Unit> {
    unsafe {
        JPH_SphereShape_Create(radius)
    }
}

/**
 * @brief 创建胶囊体形状（对应 JPH_CapsuleShape_Create）
 * @param halfHeightOfCylinder 圆柱段半高（不含帽）
 * @param radius 半径
 * @return 形状句柄；失败返回空指针
 */
public func JPH_CapsuleShape_Create_cj(halfHeightOfCylinder: Float32, radius: Float32): CPointer<Unit> {
    unsafe {
        JPH_CapsuleShape_Create(halfHeightOfCylinder, radius)
    }
}

/**
 * @brief 创建圆柱体形状（对应 JPH_CylinderShape_Create）
 * @param halfHeight 半高
 * @param radius 半径
 * @return 形状句柄；失败返回空指针
 */
public func JPH_CylinderShape_Create_cj(halfHeight: Float32, radius: Float32): CPointer<Unit> {
    unsafe {
        JPH_CylinderShape_Create(halfHeight, radius)
    }
}

/**
 * @brief 销毁形状并释放其引用（对应 JPH_Shape_Destroy）
 * @param shape 形状句柄（空指针安全）
 */
public func JPH_Shape_Destroy_cj(shape: CPointer<Unit>): Unit {
    unsafe {
        JPH_Shape_Destroy(shape)
    }
}

// =============================================================================
// 刚体创建设置（BodyCreationSettings）
// =============================================================================

/**
 * @brief 创建刚体创建设置（对应 JPH_BodyCreationSettings_Create3）
 * @param shape 形状句柄
 * @param position 初始位置指针（JPHVec3，世界坐标）
 * @param rotation 初始旋转指针（JPHQuat，可传空指针 = 单位四元数）
 * @param motionType 运动类型（MotionType 枚举值）
 * @param objectLayer 对象层（如 0=NonMoving / 1=Moving）
 * @return 设置句柄；失败返回空指针
 */
public func JPH_BodyCreationSettings_Create3_cj(
    shape: CPointer<Unit>,
    position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>,
    motionType: UInt32,
    objectLayer: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyCreationSettings_Create3(shape, position, rotation, motionType, objectLayer)
    }
}

/**
 * @brief 销毁刚体创建设置（对应 JPH_BodyCreationSettings_Destroy）
 * @param settings 设置句柄（空指针安全）
 */
public func JPH_BodyCreationSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyCreationSettings_Destroy(settings)
    }
}

// =============================================================================
// 刚体接口（BodyInterface）
// =============================================================================

/**
 * @brief 创建并添加刚体到世界（对应 JPH_BodyInterface_CreateAndAddBody）
 * @param bodyInterface 刚体接口句柄（JPH_PhysicsSystem_GetBodyInterface_cj 获取）
 * @param settings 刚体创建设置句柄
 * @param activationMode 激活策略（Activation 枚举值）
 * @return 刚体 BodyID；失败返回 0（无效 BodyID）
 */
public func JPH_BodyInterface_CreateAndAddBody_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>, activationMode: UInt32
): UInt32 {
    unsafe {
        JPH_BodyInterface_CreateAndAddBody(bodyInterface, settings, activationMode)
    }
}

/**
 * @brief 将已创建的刚体添加到世界（对应 JPH_BodyInterface_AddBody）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param activationMode 激活策略（Activation 枚举值）
 */
public func JPH_BodyInterface_AddBody_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_AddBody(bodyInterface, bodyID, activationMode)
    }
}

/**
 * @brief 从世界移除刚体（对应 JPH_BodyInterface_RemoveBody，保留其状态，可重新 AddBody）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 */
public func JPH_BodyInterface_RemoveBody_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit {
    unsafe {
        JPH_BodyInterface_RemoveBody(bodyInterface, bodyID)
    }
}

/**
 * @brief 移除并销毁刚体（对应 JPH_BodyInterface_RemoveAndDestroyBody，一步完成，ID 立即失效）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 */
public func JPH_BodyInterface_RemoveAndDestroyBody_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit {
    unsafe {
        JPH_BodyInterface_RemoveAndDestroyBody(bodyInterface, bodyID)
    }
}

/**
 * @brief 销毁刚体（对应 JPH_BodyInterface_DestroyBody，需先 RemoveBody）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 */
public func JPH_BodyInterface_DestroyBody_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): Unit {
    unsafe {
        JPH_BodyInterface_DestroyBody(bodyInterface, bodyID)
    }
}

/**
 * @brief 查询刚体是否处于活动状态（对应 JPH_BodyInterface_IsActive）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @return 非 0 活动；0 休眠/无效
 */
public func JPH_BodyInterface_IsActive_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt8 {
    unsafe {
        JPH_BodyInterface_IsActive(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置刚体线速度（对应 JPH_BodyInterface_SetLinearVelocity，世界空间）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param velocity 速度向量指针（JPHVec3，米/秒）
 */
public func JPH_BodyInterface_SetLinearVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_SetLinearVelocity(bodyInterface, bodyID, velocity)
    }
}

/**
 * @brief 获取刚体线速度（对应 JPH_BodyInterface_GetLinearVelocity，世界空间）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param velocity 输出向量指针（JPHVec3，米/秒）
 */
public func JPH_BodyInterface_GetLinearVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)
    }
}

/**
 * @brief 设置刚体角速度（对应 JPH_BodyInterface_SetAngularVelocity，世界空间，弧度/秒）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param angularVelocity 角速度向量指针（JPHVec3）
 */
public func JPH_BodyInterface_SetAngularVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_SetAngularVelocity(bodyInterface, bodyID, angularVelocity)
    }
}

/**
 * @brief 获取刚体角速度（对应 JPH_BodyInterface_GetAngularVelocity，世界空间，弧度/秒）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param angularVelocity 输出向量指针（JPHVec3）
 */
public func JPH_BodyInterface_GetAngularVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetAngularVelocity(bodyInterface, bodyID, angularVelocity)
    }
}

/**
 * @brief 设置刚体位置（对应 JPH_BodyInterface_SetPosition，世界坐标）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param position 位置向量指针（JPHVec3）
 * @param activationMode 激活策略（Activation 枚举值）
 */
public func JPH_BodyInterface_SetPosition_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetPosition(bodyInterface, bodyID, position, activationMode)
    }
}

/**
 * @brief 获取刚体位置（对应 JPH_BodyInterface_GetPosition，世界坐标）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param result 输出位置向量指针（JPHVec3）
 * @note 质心位置请用 JPH_BodyInterface_GetCenterOfMassPosition_cj
 */
public func JPH_BodyInterface_GetPosition_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetPosition(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 获取刚体质心位置（对应 JPH_BodyInterface_GetCenterOfMassPosition，世界坐标）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param result 输出位置向量指针（JPHVec3）
 */
public func JPH_BodyInterface_GetCenterOfMassPosition_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetCenterOfMassPosition(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 设置刚体旋转（对应 JPH_BodyInterface_SetRotation，四元数）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param rotation 旋转四元数指针（JPHQuat）
 * @param activationMode 激活策略（Activation 枚举值）
 */
public func JPH_BodyInterface_SetRotation_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetRotation(bodyInterface, bodyID, rotation, activationMode)
    }
}

/**
 * @brief 获取刚体旋转（对应 JPH_BodyInterface_GetRotation，四元数）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param result 输出旋转四元数指针（JPHQuat）
 */
public func JPH_BodyInterface_GetRotation_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_BodyInterface_GetRotation(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 设置刚体运动类型（对应 JPH_BodyInterface_SetMotionType）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param motionType 运动类型（MotionType 枚举值）
 * @param activationMode 激活策略（Activation 枚举值）
 */
public func JPH_BodyInterface_SetMotionType_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    motionType: UInt32, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetMotionType(bodyInterface, bodyID, motionType, activationMode)
    }
}

/**
 * @brief 获取刚体运动类型（对应 JPH_BodyInterface_GetMotionType）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @return 运动类型（MotionType 枚举值）
 */
public func JPH_BodyInterface_GetMotionType_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt32 {
    unsafe {
        JPH_BodyInterface_GetMotionType(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置刚体摩擦系数（对应 JPH_BodyInterface_SetFriction）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param friction 摩擦系数（0~1，默认 0.2）
 */
public func JPH_BodyInterface_SetFriction_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, friction: Float32
): Unit {
    unsafe {
        JPH_BodyInterface_SetFriction(bodyInterface, bodyID, friction)
    }
}

/**
 * @brief 获取刚体摩擦系数（对应 JPH_BodyInterface_GetFriction）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @return 摩擦系数
 */
public func JPH_BodyInterface_GetFriction_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): Float32 {
    unsafe {
        JPH_BodyInterface_GetFriction(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置刚体弹性系数（对应 JPH_BodyInterface_SetRestitution）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param restitution 弹性系数（0~1，默认 0）
 */
public func JPH_BodyInterface_SetRestitution_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, restitution: Float32
): Unit {
    unsafe {
        JPH_BodyInterface_SetRestitution(bodyInterface, bodyID, restitution)
    }
}

/**
 * @brief 获取刚体弹性系数（对应 JPH_BodyInterface_GetRestitution）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @return 弹性系数
 */
public func JPH_BodyInterface_GetRestitution_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): Float32 {
    unsafe {
        JPH_BodyInterface_GetRestitution(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置刚体对象层（对应 JPH_BodyInterface_SetObjectLayer，运行时改变碰撞分组）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @param layer 对象层（如 0=NonMoving / 1=Moving）
 */
public func JPH_BodyInterface_SetObjectLayer_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, layer: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetObjectLayer(bodyInterface, bodyID, layer)
    }
}

/**
 * @brief 获取刚体对象层（对应 JPH_BodyInterface_GetObjectLayer）
 * @param bodyInterface 刚体接口句柄
 * @param bodyID 刚体 BodyID
 * @return 对象层值
 */
public func JPH_BodyInterface_GetObjectLayer_cj(bodyInterface: CPointer<Unit>, bodyID: UInt32): UInt32 {
    unsafe {
        JPH_BodyInterface_GetObjectLayer(bodyInterface, bodyID)
    }
}

// =============================================================================
// 窄相查询（NarrowPhaseQuery）：射线检测
// =============================================================================

/**
 * @brief 世界射线检测（对应 JPH_NarrowPhaseQuery_CastRay，最近命中）
 * @param query 窄相查询接口句柄（JPH_PhysicsSystem_GetNarrowPhaseQuery_cj 获取）
 * @param origin 射线起点指针（JPHVec3，世界坐标）
 * @param direction 射线方向指针（长度即最大检测距离）
 * @param hit 命中结果输出指针（JPHRayCastResult，命中时有效）
 * @param broadPhaseLayerFilter / objectLayerFilter / bodyFilter 过滤参数，
 *        可传空指针（全部接受）
 * @return 非 0 命中；0 未命中
 */
public func JPH_NarrowPhaseQuery_CastRay_cj(
    query: CPointer<Unit>,
    origin: CPointer<JPHVec3>,
    direction: CPointer<JPHVec3>,
    hit: CPointer<JPHRayCastResult>,
    broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CastRay(
            query, origin, direction, hit,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter)
    }
}

// =============================================================================
// 生命周期扩展：回调注册 / 结构体释放
// =============================================================================

/**
 * @brief 设置全局 Trace 回调（对应 JPH_SetTraceHandler）
 * @param handler 回调函数指针（JPH_TraceFunc），可传空指针恢复默认
 */
public func JPH_SetTraceHandler_cj(handler: CPointer<Unit>): Unit {
    unsafe {
        JPH_SetTraceHandler(handler)
    }
}

/**
 * @brief 设置全局断言失败回调（对应 JPH_SetAssertFailureHandler）
 * @param handler 回调函数指针（JPH_AssertFailureFunc），返回 true 继续执行
 */
public func JPH_SetAssertFailureHandler_cj(handler: CPointer<Unit>): Unit {
    unsafe {
        JPH_SetAssertFailureHandler(handler)
    }
}

/**
 * @brief 释放 CollideShapeResult 内部动态分配的面数组（对应 JPH_CollideShapeResult_FreeMembers）
 */
public func JPH_CollideShapeResult_FreeMembers_cj(result: CPointer<JPHCollideShapeResult>): Unit {
    unsafe {
        JPH_CollideShapeResult_FreeMembers(result)
    }
}

/**
 * @brief 释放 CollisionEstimationResult 内部动态分配的接触冲量数组（对应 JPH_CollisionEstimationResult_FreeMembers）
 */
public func JPH_CollisionEstimationResult_FreeMembers_cj(result: CPointer<JPHCollisionEstimationResult>): Unit {
    unsafe {
        JPH_CollisionEstimationResult_FreeMembers(result)
    }
}

// =============================================================================
// 层过滤扩展：Mask 系列（组 + 掩码）
// =============================================================================

/**
 * @brief 创建 Mask 式 BroadPhase 层映射接口（对应 JPH_BroadPhaseLayerInterfaceMask_Create）
 * @param numBroadPhaseLayers BroadPhase 层数量
 * @return 映射接口句柄；失败返回空指针
 */
public func JPH_BroadPhaseLayerInterfaceMask_Create_cj(numBroadPhaseLayers: UInt32): CPointer<Unit> {
    unsafe {
        JPH_BroadPhaseLayerInterfaceMask_Create(numBroadPhaseLayers)
    }
}

/**
 * @brief 配置 Mask 层的包含/排除组（对应 JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer）
 */
public func JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer_cj(
    bpInterface: CPointer<Unit>, broadPhaseLayer: UInt8,
    groupsToInclude: UInt32, groupsToExclude: UInt32
): Unit {
    unsafe {
        JPH_BroadPhaseLayerInterfaceMask_ConfigureLayer(
            bpInterface, broadPhaseLayer, groupsToInclude, groupsToExclude)
    }
}

/**
 * @brief 创建 Mask 式对象层过滤表（对应 JPH_ObjectLayerPairFilterMask_Create）
 * @return 过滤表句柄；失败返回空指针
 */
public func JPH_ObjectLayerPairFilterMask_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_ObjectLayerPairFilterMask_Create()
    }
}

/**
 * @brief 从组与掩码计算对象层（对应 JPH_ObjectLayerPairFilterMask_GetObjectLayer）
 */
public func JPH_ObjectLayerPairFilterMask_GetObjectLayer_cj(group: UInt32, mask: UInt32): UInt32 {
    unsafe {
        JPH_ObjectLayerPairFilterMask_GetObjectLayer(group, mask)
    }
}

/**
 * @brief 从对象层解出组 ID（对应 JPH_ObjectLayerPairFilterMask_GetGroup）
 */
public func JPH_ObjectLayerPairFilterMask_GetGroup_cj(layer: UInt32): UInt32 {
    unsafe {
        JPH_ObjectLayerPairFilterMask_GetGroup(layer)
    }
}

/**
 * @brief 从对象层解出掩码（对应 JPH_ObjectLayerPairFilterMask_GetMask）
 */
public func JPH_ObjectLayerPairFilterMask_GetMask_cj(layer: UInt32): UInt32 {
    unsafe {
        JPH_ObjectLayerPairFilterMask_GetMask(layer)
    }
}

/**
 * @brief 创建 Mask 式对象层 vs BroadPhase 层过滤表（对应 JPH_ObjectVsBroadPhaseLayerFilterMask_Create）
 */
public func JPH_ObjectVsBroadPhaseLayerFilterMask_Create_cj(
    broadPhaseLayerInterface: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_ObjectVsBroadPhaseLayerFilterMask_Create(broadPhaseLayerInterface)
    }
}

/**
 * @brief 用默认值初始化绘制设置（对应 JPH_DrawSettings_InitDefault）
 */
public func JPH_DrawSettings_InitDefault_cj(settings: CPointer<JPHDrawSettings>): Unit {
    unsafe {
        JPH_DrawSettings_InitDefault(settings)
    }
}

// =============================================================================
// 物理系统扩展（PhysicsSystem）
// =============================================================================

/**
 * @brief 设置物理求解器参数（对应 JPH_PhysicsSystem_SetPhysicsSettings）
 */
public func JPH_PhysicsSystem_SetPhysicsSettings_cj(
    system: CPointer<Unit>, settings: CPointer<JPHPhysicsSettings>
): Unit {
    unsafe {
        JPH_PhysicsSystem_SetPhysicsSettings(system, settings)
    }
}

/**
 * @brief 获取物理求解器参数（对应 JPH_PhysicsSystem_GetPhysicsSettings）
 */
public func JPH_PhysicsSystem_GetPhysicsSettings_cj(
    system: CPointer<Unit>, result: CPointer<JPHPhysicsSettings>
): Unit {
    unsafe {
        JPH_PhysicsSystem_GetPhysicsSettings(system, result)
    }
}

/**
 * @brief 获取刚体接口（无锁版本，对应 JPH_PhysicsSystem_GetBodyInterfaceNoLock）
 */
public func JPH_PhysicsSystem_GetBodyInterfaceNoLock_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBodyInterfaceNoLock(system)
    }
}

/**
 * @brief 获取刚体锁接口（对应 JPH_PhysicsSystem_GetBodyLockInterface）
 */
public func JPH_PhysicsSystem_GetBodyLockInterface_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBodyLockInterface(system)
    }
}

/**
 * @brief 获取刚体锁接口（无锁版本，对应 JPH_PhysicsSystem_GetBodyLockInterfaceNoLock）
 */
public func JPH_PhysicsSystem_GetBodyLockInterfaceNoLock_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBodyLockInterfaceNoLock(system)
    }
}

/**
 * @brief 获取宽相位查询接口（对应 JPH_PhysicsSystem_GetBroadPhaseQuery）
 */
public func JPH_PhysicsSystem_GetBroadPhaseQuery_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBroadPhaseQuery(system)
    }
}

/**
 * @brief 获取窄相查询接口（无锁版本，对应 JPH_PhysicsSystem_GetNarrowPhaseQueryNoLock）
 */
public func JPH_PhysicsSystem_GetNarrowPhaseQueryNoLock_cj(system: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetNarrowPhaseQueryNoLock(system)
    }
}

/**
 * @brief 设置接触监听器（对应 JPH_PhysicsSystem_SetContactListener）
 */
public func JPH_PhysicsSystem_SetContactListener_cj(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_SetContactListener(system, listener)
    }
}

/**
 * @brief 设置刚体激活监听器（对应 JPH_PhysicsSystem_SetBodyActivationListener）
 */
public func JPH_PhysicsSystem_SetBodyActivationListener_cj(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_SetBodyActivationListener(system, listener)
    }
}

/**
 * @brief 设置模拟形状过滤（对应 JPH_PhysicsSystem_SetSimShapeFilter）
 */
public func JPH_PhysicsSystem_SetSimShapeFilter_cj(
    system: CPointer<Unit>, filter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_SetSimShapeFilter(system, filter)
    }
}

/**
 * @brief 查询两个刚体当前是否接触（对应 JPH_PhysicsSystem_WereBodiesInContact）
 */
public func JPH_PhysicsSystem_WereBodiesInContact_cj(
    system: CPointer<Unit>, body1: UInt32, body2: UInt32
): UInt8 {
    unsafe {
        JPH_PhysicsSystem_WereBodiesInContact(system, body1, body2)
    }
}

/**
 * @brief 获取世界中刚体总数（对应 JPH_PhysicsSystem_GetNumBodies）
 */
public func JPH_PhysicsSystem_GetNumBodies_cj(system: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_PhysicsSystem_GetNumBodies(system)
    }
}

/**
 * @brief 获取世界中活动刚体数（对应 JPH_PhysicsSystem_GetNumActiveBodies）
 */
public func JPH_PhysicsSystem_GetNumActiveBodies_cj(system: CPointer<Unit>, bodyType: UInt32): UInt32 {
    unsafe {
        JPH_PhysicsSystem_GetNumActiveBodies(system, bodyType)
    }
}

/**
 * @brief 获取世界中刚体容量上限（对应 JPH_PhysicsSystem_GetMaxBodies）
 */
public func JPH_PhysicsSystem_GetMaxBodies_cj(system: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_PhysicsSystem_GetMaxBodies(system)
    }
}

/**
 * @brief 获取世界中约束总数（对应 JPH_PhysicsSystem_GetNumConstraints）
 */
public func JPH_PhysicsSystem_GetNumConstraints_cj(system: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_PhysicsSystem_GetNumConstraints(system)
    }
}

/**
 * @brief 获取当前重力（对应 JPH_PhysicsSystem_GetGravity）
 */
public func JPH_PhysicsSystem_GetGravity_cj(system: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_PhysicsSystem_GetGravity(system, result)
    }
}

/**
 * @brief 添加约束到世界（对应 JPH_PhysicsSystem_AddConstraint）
 */
public func JPH_PhysicsSystem_AddConstraint_cj(
    system: CPointer<Unit>, constraint: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_AddConstraint(system, constraint)
    }
}

/**
 * @brief 从世界移除约束（对应 JPH_PhysicsSystem_RemoveConstraint）
 */
public func JPH_PhysicsSystem_RemoveConstraint_cj(
    system: CPointer<Unit>, constraint: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_RemoveConstraint(system, constraint)
    }
}

/**
 * @brief 批量添加约束（对应 JPH_PhysicsSystem_AddConstraints）
 */
public func JPH_PhysicsSystem_AddConstraints_cj(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_AddConstraints(system, constraints, count)
    }
}

/**
 * @brief 批量移除约束（对应 JPH_PhysicsSystem_RemoveConstraints）
 */
public func JPH_PhysicsSystem_RemoveConstraints_cj(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_RemoveConstraints(system, constraints, count)
    }
}

/**
 * @brief 添加步进监听器（对应 JPH_PhysicsSystem_AddStepListener）
 */
public func JPH_PhysicsSystem_AddStepListener_cj(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_AddStepListener(system, listener)
    }
}

/**
 * @brief 移除步进监听器（对应 JPH_PhysicsSystem_RemoveStepListener）
 */
public func JPH_PhysicsSystem_RemoveStepListener_cj(
    system: CPointer<Unit>, listener: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_RemoveStepListener(system, listener)
    }
}

/**
 * @brief 获取全部刚体 ID（对应 JPH_PhysicsSystem_GetBodies）
 */
public func JPH_PhysicsSystem_GetBodies_cj(
    system: CPointer<Unit>, ids: CPointer<UInt32>, count: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_GetBodies(system, ids, count)
    }
}

/**
 * @brief 获取全部活动刚体 ID（对应 JPH_PhysicsSystem_GetActiveBodies）
 */
public func JPH_PhysicsSystem_GetActiveBodies_cj(
    system: CPointer<Unit>, bodyType: UInt32, ids: CPointer<UInt32>, count: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_GetActiveBodies(system, bodyType, ids, count)
    }
}

/**
 * @brief 获取活动刚体 ID 数组指针（对应 JPH_PhysicsSystem_GetActiveBodiesUnsafe）
 */
public func JPH_PhysicsSystem_GetActiveBodiesUnsafe_cj(
    system: CPointer<Unit>, bodyType: UInt32
): CPointer<UInt32> {
    unsafe {
        JPH_PhysicsSystem_GetActiveBodiesUnsafe(system, bodyType)
    }
}

/**
 * @brief 获取全部约束（对应 JPH_PhysicsSystem_GetConstraints）
 */
public func JPH_PhysicsSystem_GetConstraints_cj(
    system: CPointer<Unit>, constraints: CPointer<Unit>, count: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_GetConstraints(system, constraints, count)
    }
}

/**
 * @brief 激活 AABB 范围内、指定对象层的刚体（对应 JPH_PhysicsSystem_ActivateBodiesInAABox）
 */
public func JPH_PhysicsSystem_ActivateBodiesInAABox_cj(
    system: CPointer<Unit>, box: CPointer<JPHAABox>, layer: UInt32
): Unit {
    unsafe {
        JPH_PhysicsSystem_ActivateBodiesInAABox(system, box, layer)
    }
}

/**
 * @brief 调试绘制全部刚体形状（对应 JPH_PhysicsSystem_DrawBodies）
 */
public func JPH_PhysicsSystem_DrawBodies_cj(
    system: CPointer<Unit>, settings: CPointer<JPHDrawSettings>,
    renderer: CPointer<Unit>, bodyFilter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_DrawBodies(system, settings, renderer, bodyFilter)
    }
}

/**
 * @brief 调试绘制全部约束（对应 JPH_PhysicsSystem_DrawConstraints）
 */
public func JPH_PhysicsSystem_DrawConstraints_cj(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_DrawConstraints(system, renderer)
    }
}

/**
 * @brief 调试绘制全部约束限位（对应 JPH_PhysicsSystem_DrawConstraintLimits）
 */
public func JPH_PhysicsSystem_DrawConstraintLimits_cj(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_DrawConstraintLimits(system, renderer)
    }
}

/**
 * @brief 调试绘制全部约束参考系（对应 JPH_PhysicsSystem_DrawConstraintReferenceFrame）
 */
public func JPH_PhysicsSystem_DrawConstraintReferenceFrame_cj(
    system: CPointer<Unit>, renderer: CPointer<Unit>
): Unit {
    unsafe {
        JPH_PhysicsSystem_DrawConstraintReferenceFrame(system, renderer)
    }
}

// =============================================================================
// 步进监听器（PhysicsStepListener）
// =============================================================================

/**
 * @brief 设置步进监听器回调表（对应 JPH_PhysicsStepListener_SetProcs）
 */
public func JPH_PhysicsStepListener_SetProcs_cj(procs: CPointer<JPHPhysicsStepListenerProcs>): Unit {
    unsafe {
        JPH_PhysicsStepListener_SetProcs(procs)
    }
}

/**
 * @brief 创建步进监听器实例（对应 JPH_PhysicsStepListener_Create）
 */
public func JPH_PhysicsStepListener_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PhysicsStepListener_Create(userData)
    }
}

/**
 * @brief 销毁步进监听器（对应 JPH_PhysicsStepListener_Destroy）
 */
public func JPH_PhysicsStepListener_Destroy_cj(listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_PhysicsStepListener_Destroy(listener)
    }
}

// =============================================================================
// 数学工具（Math / Quat / Vec3 / Mat4）
// =============================================================================

/**
 * @brief 正弦（对应 JPH_Math_Sin）
 */
public func JPH_Math_Sin_cj(value: Float32): Float32 {
    unsafe {
        JPH_Math_Sin(value)
    }
}

/**
 * @brief 余弦（对应 JPH_Math_Cos）
 */
public func JPH_Math_Cos_cj(value: Float32): Float32 {
    unsafe {
        JPH_Math_Cos(value)
    }
}

/**
 * @brief 构造从 from 到 to 的旋转四元数（对应 JPH_Quat_FromTo）
 */
public func JPH_Quat_FromTo_cj(
    from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, quat: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_FromTo(from, to, quat)
    }
}

/**
 * @brief 获取四元数的轴角表示（对应 JPH_Quat_GetAxisAngle）
 */
public func JPH_Quat_GetAxisAngle_cj(
    quat: CPointer<JPHQuat>, outAxis: CPointer<JPHVec3>, outAngle: CPointer<Float32>
): Unit {
    unsafe {
        JPH_Quat_GetAxisAngle(quat, outAxis, outAngle)
    }
}

/**
 * @brief 获取四元数的欧拉角（对应 JPH_Quat_GetEulerAngles）
 */
public func JPH_Quat_GetEulerAngles_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_GetEulerAngles(quat, result)
    }
}

/**
 * @brief 四元数旋转 X 轴（对应 JPH_Quat_RotateAxisX）
 */
public func JPH_Quat_RotateAxisX_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_RotateAxisX(quat, result)
    }
}

/**
 * @brief 四元数旋转 Y 轴（对应 JPH_Quat_RotateAxisY）
 */
public func JPH_Quat_RotateAxisY_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_RotateAxisY(quat, result)
    }
}

/**
 * @brief 四元数旋转 Z 轴（对应 JPH_Quat_RotateAxisZ）
 */
public func JPH_Quat_RotateAxisZ_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_RotateAxisZ(quat, result)
    }
}

/**
 * @brief 四元数求逆（对应 JPH_Quat_Inversed）
 */
public func JPH_Quat_Inversed_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_Inversed(quat, result)
    }
}

/**
 * @brief 获取四元数垂直方向四元数（对应 JPH_Quat_GetPerpendicular）
 */
public func JPH_Quat_GetPerpendicular_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_GetPerpendicular(quat, result)
    }
}

/**
 * @brief 获取绕指定轴的旋转角（对应 JPH_Quat_GetRotationAngle）
 */
public func JPH_Quat_GetRotationAngle_cj(quat: CPointer<JPHQuat>, axis: CPointer<JPHVec3>): Float32 {
    unsafe {
        JPH_Quat_GetRotationAngle(quat, axis)
    }
}

/**
 * @brief 从欧拉角构造四元数（对应 JPH_Quat_FromEulerAngles）
 */
public func JPH_Quat_FromEulerAngles_cj(angles: CPointer<JPHVec3>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_FromEulerAngles(angles, result)
    }
}

/**
 * @brief 四元数加法 q1 + q2（对应 JPH_Quat_Add）
 */
public func JPH_Quat_Add_cj(
    q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_Add(q1, q2, result)
    }
}

/**
 * @brief 四元数减法 q1 - q2（对应 JPH_Quat_Subtract）
 */
public func JPH_Quat_Subtract_cj(
    q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_Subtract(q1, q2, result)
    }
}

/**
 * @brief 四元数乘法 q1 * q2（对应 JPH_Quat_Multiply）
 */
public func JPH_Quat_Multiply_cj(
    q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_Multiply(q1, q2, result)
    }
}

/**
 * @brief 四元数数乘 q * scalar（对应 JPH_Quat_MultiplyScalar）
 */
public func JPH_Quat_MultiplyScalar_cj(q: CPointer<JPHQuat>, scalar: Float32, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_MultiplyScalar(q, scalar, result)
    }
}

/**
 * @brief 四元数数除 q / scalar（对应 JPH_Quat_DivideScalar）
 */
public func JPH_Quat_DivideScalar_cj(q: CPointer<JPHQuat>, scalar: Float32, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_DivideScalar(q, scalar, result)
    }
}

/**
 * @brief 四元数点积 q1 · q2（对应 JPH_Quat_Dot）
 */
public func JPH_Quat_Dot_cj(
    q1: CPointer<JPHQuat>, q2: CPointer<JPHQuat>, result: CPointer<Float32>
): Unit {
    unsafe {
        JPH_Quat_Dot(q1, q2, result)
    }
}

/**
 * @brief 四元数共轭（对应 JPH_Quat_Conjugated）
 */
public func JPH_Quat_Conjugated_cj(quat: CPointer<JPHQuat>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_Conjugated(quat, result)
    }
}

/**
 * @brief 提取绕指定轴的扭转分量（对应 JPH_Quat_GetTwist）
 */
public func JPH_Quat_GetTwist_cj(quat: CPointer<JPHQuat>, axis: CPointer<JPHVec3>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Quat_GetTwist(quat, axis, result)
    }
}

/**
 * @brief 分解为摆动与扭转四元数（对应 JPH_Quat_GetSwingTwist）
 */
public func JPH_Quat_GetSwingTwist_cj(
    quat: CPointer<JPHQuat>, outSwing: CPointer<JPHQuat>, outTwist: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_GetSwingTwist(quat, outSwing, outTwist)
    }
}

/**
 * @brief 四元数线性插值（对应 JPH_Quat_Lerp）
 */
public func JPH_Quat_Lerp_cj(
    from: CPointer<JPHQuat>, to: CPointer<JPHQuat>, fraction: Float32, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_Lerp(from, to, fraction, result)
    }
}

/**
 * @brief 四元数球面插值（对应 JPH_Quat_Slerp）
 */
public func JPH_Quat_Slerp_cj(
    from: CPointer<JPHQuat>, to: CPointer<JPHQuat>, fraction: Float32, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_Quat_Slerp(from, to, fraction, result)
    }
}

/**
 * @brief 用四元数旋转向量（对应 JPH_Quat_Rotate）
 */
public func JPH_Quat_Rotate_cj(quat: CPointer<JPHQuat>, vec: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_Rotate(quat, vec, result)
    }
}

/**
 * @brief 用四元数逆旋转向量（对应 JPH_Quat_InverseRotate）
 */
public func JPH_Quat_InverseRotate_cj(quat: CPointer<JPHQuat>, vec: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Quat_InverseRotate(quat, vec, result)
    }
}

/**
 * @brief 获取 X 轴单位向量（对应 JPH_Vec3_AxisX）
 */
public func JPH_Vec3_AxisX_cj(result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_AxisX(result)
    }
}

/**
 * @brief 获取 Y 轴单位向量（对应 JPH_Vec3_AxisY）
 */
public func JPH_Vec3_AxisY_cj(result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_AxisY(result)
    }
}

/**
 * @brief 获取 Z 轴单位向量（对应 JPH_Vec3_AxisZ）
 */
public func JPH_Vec3_AxisZ_cj(result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_AxisZ(result)
    }
}

/**
 * @brief 判断 v1 与 v2 是否接近（对应 JPH_Vec3_IsClose）
 */
public func JPH_Vec3_IsClose_cj(v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, maxDistSq: Float32): UInt8 {
    unsafe {
        JPH_Vec3_IsClose(v1, v2, maxDistSq)
    }
}

/**
 * @brief 判断向量是否接近零（对应 JPH_Vec3_IsNearZero）
 */
public func JPH_Vec3_IsNearZero_cj(v: CPointer<JPHVec3>, maxDistSq: Float32): UInt8 {
    unsafe {
        JPH_Vec3_IsNearZero(v, maxDistSq)
    }
}

/**
 * @brief 判断向量是否已归一化（对应 JPH_Vec3_IsNormalized）
 */
public func JPH_Vec3_IsNormalized_cj(v: CPointer<JPHVec3>, tolerance: Float32): UInt8 {
    unsafe {
        JPH_Vec3_IsNormalized(v, tolerance)
    }
}

/**
 * @brief 判断向量是否含 NaN（对应 JPH_Vec3_IsNaN）
 */
public func JPH_Vec3_IsNaN_cj(v: CPointer<JPHVec3>): UInt8 {
    unsafe {
        JPH_Vec3_IsNaN(v)
    }
}

/**
 * @brief 向量取反（对应 JPH_Vec3_Negate）
 */
public func JPH_Vec3_Negate_cj(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_Negate(v, result)
    }
}

/**
 * @brief 向量归一化（对应 JPH_Vec3_Normalized）
 */
public func JPH_Vec3_Normalized_cj(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_Normalized(v, result)
    }
}

/**
 * @brief 向量叉积 v1 × v2（对应 JPH_Vec3_Cross）
 */
public func JPH_Vec3_Cross_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_Cross(v1, v2, result)
    }
}

/**
 * @brief 向量各分量取绝对值（对应 JPH_Vec3_Abs）
 */
public func JPH_Vec3_Abs_cj(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_Abs(v, result)
    }
}

/**
 * @brief 向量长度（对应 JPH_Vec3_Length）
 */
public func JPH_Vec3_Length_cj(v: CPointer<JPHVec3>): Float32 {
    unsafe {
        JPH_Vec3_Length(v)
    }
}

/**
 * @brief 向量长度平方（对应 JPH_Vec3_LengthSquared）
 */
public func JPH_Vec3_LengthSquared_cj(v: CPointer<JPHVec3>): Float32 {
    unsafe {
        JPH_Vec3_LengthSquared(v)
    }
}

/**
 * @brief 向量点积 v1 · v2（对应 JPH_Vec3_DotProduct）
 */
public func JPH_Vec3_DotProduct_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<Float32>
): Unit {
    unsafe {
        JPH_Vec3_DotProduct(v1, v2, result)
    }
}

/**
 * @brief 向量原地归一化（对应 JPH_Vec3_Normalize）
 */
public func JPH_Vec3_Normalize_cj(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_Normalize(v, result)
    }
}

/**
 * @brief 向量加法 v1 + v2（对应 JPH_Vec3_Add）
 */
public func JPH_Vec3_Add_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_Add(v1, v2, result)
    }
}

/**
 * @brief 向量减法 v1 - v2（对应 JPH_Vec3_Subtract）
 */
public func JPH_Vec3_Subtract_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_Subtract(v1, v2, result)
    }
}

/**
 * @brief 向量逐分量乘法 v1 * v2（对应 JPH_Vec3_Multiply）
 */
public func JPH_Vec3_Multiply_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_Multiply(v1, v2, result)
    }
}

/**
 * @brief 向量数乘 v * scalar（对应 JPH_Vec3_MultiplyScalar）
 */
public func JPH_Vec3_MultiplyScalar_cj(v: CPointer<JPHVec3>, scalar: Float32, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_MultiplyScalar(v, scalar, result)
    }
}

/**
 * @brief 矩阵乘向量 left * right（对应 JPH_Vec3_MultiplyMatrix）
 */
public func JPH_Vec3_MultiplyMatrix_cj(
    left: CPointer<JPHMat4>, right: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_MultiplyMatrix(left, right, result)
    }
}

/**
 * @brief 向量逐分量除法 v1 / v2（对应 JPH_Vec3_Divide）
 */
public func JPH_Vec3_Divide_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Vec3_Divide(v1, v2, result)
    }
}

/**
 * @brief 向量数除 v / scalar（对应 JPH_Vec3_DivideScalar）
 */
public func JPH_Vec3_DivideScalar_cj(v: CPointer<JPHVec3>, scalar: Float32, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_DivideScalar(v, scalar, result)
    }
}

/**
 * @brief 获取垂直方向的归一化向量（对应 JPH_Vec3_GetNormalizedPerpendicular）
 */
public func JPH_Vec3_GetNormalizedPerpendicular_cj(v: CPointer<JPHVec3>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Vec3_GetNormalizedPerpendicular(v, result)
    }
}

/**
 * @brief 矩阵加法 m1 + m2（对应 JPH_Mat4_Add）
 */
public func JPH_Mat4_Add_cj(
    m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_Mat4_Add(m1, m2, result)
    }
}

/**
 * @brief 矩阵减法 m1 - m2（对应 JPH_Mat4_Subtract）
 */
public func JPH_Mat4_Subtract_cj(
    m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_Mat4_Subtract(m1, m2, result)
    }
}

/**
 * @brief 矩阵乘法 m1 * m2（对应 JPH_Mat4_Multiply）
 */
public func JPH_Mat4_Multiply_cj(
    m1: CPointer<JPHMat4>, m2: CPointer<JPHMat4>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_Mat4_Multiply(m1, m2, result)
    }
}

/**
 * @brief 矩阵数乘 m * scalar（对应 JPH_Mat4_MultiplyScalar）
 */
public func JPH_Mat4_MultiplyScalar_cj(m: CPointer<JPHMat4>, scalar: Float32, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Mat4_MultiplyScalar(m, scalar, result)
    }
}

/**
 * @brief 零矩阵（对应 JPH_Mat4_Zero）
 */
public func JPH_Mat4_Zero_cj(result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Mat4_Zero(result)
    }
}

/**
 * @brief 单位矩阵（对应 JPH_Mat4_Identity）
 */
public func JPH_Mat4_Identity_cj(result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Mat4_Identity(result)
    }
}

/**
 * @brief 旋转矩阵（由四元数，对应 JPH_Mat4_Rotation）
 */
public func JPH_Mat4_Rotation_cj(result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Mat4_Rotation(result, rotation)
    }
}

/**
 * @brief 绕轴旋转矩阵（对应 JPH_Mat4_Rotation2）
 */
public func JPH_Mat4_Rotation2_cj(result: CPointer<JPHMat4>, axis: CPointer<JPHVec3>, angle: Float32): Unit {
    unsafe {
        JPH_Mat4_Rotation2(result, axis, angle)
    }
}

/**
 * @brief 平移矩阵（对应 JPH_Mat4_Translation）
 */
public func JPH_Mat4_Translation_cj(result: CPointer<JPHMat4>, translation: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_Translation(result, translation)
    }
}

/**
 * @brief 旋转 + 平移矩阵（对应 JPH_Mat4_RotationTranslation）
 */
public func JPH_Mat4_RotationTranslation_cj(
    result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>, translation: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Mat4_RotationTranslation(result, rotation, translation)
    }
}

/**
 * @brief 旋转 + 平移矩阵的逆（对应 JPH_Mat4_InverseRotationTranslation）
 */
public func JPH_Mat4_InverseRotationTranslation_cj(
    result: CPointer<JPHMat4>, rotation: CPointer<JPHQuat>, translation: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Mat4_InverseRotationTranslation(result, rotation, translation)
    }
}

/**
 * @brief 缩放矩阵（对应 JPH_Mat4_Scale）
 */
public func JPH_Mat4_Scale_cj(result: CPointer<JPHMat4>, scale: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_Scale(result, scale)
    }
}

/**
 * @brief 矩阵转置（对应 JPH_Mat4_Transposed）
 */
public func JPH_Mat4_Transposed_cj(m: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Mat4_Transposed(m, result)
    }
}

/**
 * @brief 矩阵求逆（对应 JPH_Mat4_Inversed）
 */
public func JPH_Mat4_Inversed_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Mat4_Inversed(matrix, result)
    }
}

/**
 * @brief 取矩阵 X 轴（对应 JPH_Mat4_GetAxisX）
 */
public func JPH_Mat4_GetAxisX_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_GetAxisX(matrix, result)
    }
}

/**
 * @brief 取矩阵 Y 轴（对应 JPH_Mat4_GetAxisY）
 */
public func JPH_Mat4_GetAxisY_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_GetAxisY(matrix, result)
    }
}

/**
 * @brief 取矩阵 Z 轴（对应 JPH_Mat4_GetAxisZ）
 */
public func JPH_Mat4_GetAxisZ_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_GetAxisZ(matrix, result)
    }
}

/**
 * @brief 取矩阵平移分量（对应 JPH_Mat4_GetTranslation）
 */
public func JPH_Mat4_GetTranslation_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Mat4_GetTranslation(matrix, result)
    }
}

/**
 * @brief 取矩阵旋转四元数（对应 JPH_Mat4_GetQuaternion）
 */
public func JPH_Mat4_GetQuaternion_cj(matrix: CPointer<JPHMat4>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Mat4_GetQuaternion(matrix, result)
    }
}

// =============================================================================
// 物理材质（PhysicsMaterial）
// =============================================================================

/**
 * @brief 创建物理材质（对应 JPH_PhysicsMaterial_Create）
 * @param name 材质名称（C 字符串）
 * @param color 调试颜色（RGBA）
 * @return 材质句柄；失败返回空指针
 */
public func JPH_PhysicsMaterial_Create_cj(name: CPointer<UInt8>, color: UInt32): CPointer<Unit> {
    unsafe {
        JPH_PhysicsMaterial_Create(name, color)
    }
}

/**
 * @brief 销毁物理材质（对应 JPH_PhysicsMaterial_Destroy）
 */
public func JPH_PhysicsMaterial_Destroy_cj(material: CPointer<Unit>): Unit {
    unsafe {
        JPH_PhysicsMaterial_Destroy(material)
    }
}

/**
 * @brief 获取材质调试名称（对应 JPH_PhysicsMaterial_GetDebugName）
 */
public func JPH_PhysicsMaterial_GetDebugName_cj(material: CPointer<Unit>): CPointer<UInt8> {
    unsafe {
        JPH_PhysicsMaterial_GetDebugName(material)
    }
}

/**
 * @brief 获取材质调试颜色（对应 JPH_PhysicsMaterial_GetDebugColor）
 */
public func JPH_PhysicsMaterial_GetDebugColor_cj(material: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_PhysicsMaterial_GetDebugColor(material)
    }
}

// =============================================================================
// 组过滤（GroupFilter / GroupFilterTable）
// =============================================================================

/**
 * @brief 销毁组过滤对象（对应 JPH_GroupFilter_Destroy）
 */
public func JPH_GroupFilter_Destroy_cj(groupFilter: CPointer<Unit>): Unit {
    unsafe {
        JPH_GroupFilter_Destroy(groupFilter)
    }
}

/**
 * @brief 判断两组是否允许碰撞（对应 JPH_GroupFilter_CanCollide）
 */
public func JPH_GroupFilter_CanCollide_cj(
    groupFilter: CPointer<Unit>,
    group1: CPointer<JPHCollisionGroup>,
    group2: CPointer<JPHCollisionGroup>
): UInt8 {
    unsafe {
        JPH_GroupFilter_CanCollide(groupFilter, group1, group2)
    }
}

/**
 * @brief 创建组过滤表（对应 JPH_GroupFilterTable_Create）
 */
public func JPH_GroupFilterTable_Create_cj(numSubGroups: UInt32): CPointer<Unit> {
    unsafe {
        JPH_GroupFilterTable_Create(numSubGroups)
    }
}

/**
 * @brief 禁止两个子组碰撞（对应 JPH_GroupFilterTable_DisableCollision）
 */
public func JPH_GroupFilterTable_DisableCollision_cj(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): Unit {
    unsafe {
        JPH_GroupFilterTable_DisableCollision(table, subGroup1, subGroup2)
    }
}

/**
 * @brief 允许两个子组碰撞（对应 JPH_GroupFilterTable_EnableCollision）
 */
public func JPH_GroupFilterTable_EnableCollision_cj(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): Unit {
    unsafe {
        JPH_GroupFilterTable_EnableCollision(table, subGroup1, subGroup2)
    }
}

/**
 * @brief 查询两个子组是否允许碰撞（对应 JPH_GroupFilterTable_IsCollisionEnabled）
 */
public func JPH_GroupFilterTable_IsCollisionEnabled_cj(
    table: CPointer<Unit>, subGroup1: UInt32, subGroup2: UInt32
): UInt8 {
    unsafe {
        JPH_GroupFilterTable_IsCollisionEnabled(table, subGroup1, subGroup2)
    }
}

// =============================================================================
// 形状设置（ShapeSettings）与形状基类（Shape）
// =============================================================================

/**
 * @brief 销毁形状设置（对应 JPH_ShapeSettings_Destroy）
 */
public func JPH_ShapeSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_ShapeSettings_Destroy(settings)
    }
}

/**
 * @brief 获取形状设置的用户数据（对应 JPH_ShapeSettings_GetUserData）
 */
public func JPH_ShapeSettings_GetUserData_cj(settings: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_ShapeSettings_GetUserData(settings)
    }
}

/**
 * @brief 设置形状设置的用户数据（对应 JPH_ShapeSettings_SetUserData）
 */
public func JPH_ShapeSettings_SetUserData_cj(settings: CPointer<Unit>, userData: UInt64): Unit {
    unsafe {
        JPH_ShapeSettings_SetUserData(settings, userData)
    }
}

/**
 * @brief 调试绘制形状（对应 JPH_Shape_Draw）
 */
public func JPH_Shape_Draw_cj(
    shape: CPointer<Unit>, renderer: CPointer<Unit>,
    centerOfMassTransform: CPointer<JPHMat4>, scale: CPointer<JPHVec3>,
    color: UInt32, useMaterialColors: UInt8, drawWireframe: UInt8
): Unit {
    unsafe {
        JPH_Shape_Draw(
            shape, renderer, centerOfMassTransform, scale,
            color, useMaterialColors, drawWireframe)
    }
}

/**
 * @brief 获取形状大类（对应 JPH_Shape_GetType）
 */
public func JPH_Shape_GetType_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Shape_GetType(shape)
    }
}

/**
 * @brief 获取形状子类型（对应 JPH_Shape_GetSubType）
 */
public func JPH_Shape_GetSubType_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Shape_GetSubType(shape)
    }
}

/**
 * @brief 获取形状用户数据（对应 JPH_Shape_GetUserData）
 */
public func JPH_Shape_GetUserData_cj(shape: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_Shape_GetUserData(shape)
    }
}

/**
 * @brief 设置形状用户数据（对应 JPH_Shape_SetUserData）
 */
public func JPH_Shape_SetUserData_cj(shape: CPointer<Unit>, userData: UInt64): Unit {
    unsafe {
        JPH_Shape_SetUserData(shape, userData)
    }
}

/**
 * @brief 形状是否必须为静态（对应 JPH_Shape_MustBeStatic）
 */
public func JPH_Shape_MustBeStatic_cj(shape: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Shape_MustBeStatic(shape)
    }
}

/**
 * @brief 获取形状质心（对应 JPH_Shape_GetCenterOfMass）
 */
public func JPH_Shape_GetCenterOfMass_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Shape_GetCenterOfMass(shape, result)
    }
}

/**
 * @brief 获取形状局部包围盒（对应 JPH_Shape_GetLocalBounds）
 */
public func JPH_Shape_GetLocalBounds_cj(shape: CPointer<Unit>, result: CPointer<JPHAABox>): Unit {
    unsafe {
        JPH_Shape_GetLocalBounds(shape, result)
    }
}

/**
 * @brief 获取子形状 ID 的递归位数（对应 JPH_Shape_GetSubShapeIDBitsRecursive）
 */
public func JPH_Shape_GetSubShapeIDBitsRecursive_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Shape_GetSubShapeIDBitsRecursive(shape)
    }
}

/**
 * @brief 获取形状世界空间包围盒（对应 JPH_Shape_GetWorldSpaceBounds）
 */
public func JPH_Shape_GetWorldSpaceBounds_cj(
    shape: CPointer<Unit>, centerOfMassTransform: CPointer<JPHMat4>,
    scale: CPointer<JPHVec3>, result: CPointer<JPHAABox>
): Unit {
    unsafe {
        JPH_Shape_GetWorldSpaceBounds(shape, centerOfMassTransform, scale, result)
    }
}

/**
 * @brief 获取形状内半径（对应 JPH_Shape_GetInnerRadius）
 */
public func JPH_Shape_GetInnerRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Shape_GetInnerRadius(shape)
    }
}

/**
 * @brief 获取形状质量属性（对应 JPH_Shape_GetMassProperties）
 */
public func JPH_Shape_GetMassProperties_cj(shape: CPointer<Unit>, result: CPointer<JPHMassProperties>): Unit {
    unsafe {
        JPH_Shape_GetMassProperties(shape, result)
    }
}

/**
 * @brief 获取叶子形状（对应 JPH_Shape_GetLeafShape）
 */
public func JPH_Shape_GetLeafShape_cj(
    shape: CPointer<Unit>, subShapeID: UInt32, remainder: CPointer<UInt32>
): CPointer<Unit> {
    unsafe {
        JPH_Shape_GetLeafShape(shape, subShapeID, remainder)
    }
}

/**
 * @brief 获取子形状材质（对应 JPH_Shape_GetMaterial）
 */
public func JPH_Shape_GetMaterial_cj(shape: CPointer<Unit>, subShapeID: UInt32): CPointer<Unit> {
    unsafe {
        JPH_Shape_GetMaterial(shape, subShapeID)
    }
}

/**
 * @brief 获取形状表面法线（对应 JPH_Shape_GetSurfaceNormal）
 */
public func JPH_Shape_GetSurfaceNormal_cj(
    shape: CPointer<Unit>, subShapeID: UInt32,
    localPosition: CPointer<JPHVec3>, normal: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Shape_GetSurfaceNormal(shape, subShapeID, localPosition, normal)
    }
}

/**
 * @brief 获取支撑面（对应 JPH_Shape_GetSupportingFace）
 */
public func JPH_Shape_GetSupportingFace_cj(
    shape: CPointer<Unit>, subShapeID: UInt32, direction: CPointer<JPHVec3>,
    scale: CPointer<JPHVec3>, centerOfMassTransform: CPointer<JPHMat4>,
    outVertices: CPointer<JPHSupportingFace>
): Unit {
    unsafe {
        JPH_Shape_GetSupportingFace(
            shape, subShapeID, direction, scale, centerOfMassTransform, outVertices)
    }
}

/**
 * @brief 获取形状体积（对应 JPH_Shape_GetVolume）
 */
public func JPH_Shape_GetVolume_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Shape_GetVolume(shape)
    }
}

/**
 * @brief 缩放是否有效（对应 JPH_Shape_IsValidScale）
 */
public func JPH_Shape_IsValidScale_cj(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): UInt8 {
    unsafe {
        JPH_Shape_IsValidScale(shape, scale)
    }
}

/**
 * @brief 将缩放修正为有效值（对应 JPH_Shape_MakeScaleValid）
 */
public func JPH_Shape_MakeScaleValid_cj(
    shape: CPointer<Unit>, scale: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Shape_MakeScaleValid(shape, scale, result)
    }
}

/**
 * @brief 创建缩放后的形状副本（对应 JPH_Shape_ScaleShape）
 */
public func JPH_Shape_ScaleShape_cj(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit> {
    unsafe {
        JPH_Shape_ScaleShape(shape, scale)
    }
}

/**
 * @brief 形状自身射线检测（对应 JPH_Shape_CastRay）
 */
public func JPH_Shape_CastRay_cj(
    shape: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    hit: CPointer<JPHRayCastResult>
): UInt8 {
    unsafe {
        JPH_Shape_CastRay(shape, origin, direction, hit)
    }
}

/**
 * @brief 形状自身射线检测（带收集器回调，对应 JPH_Shape_CastRay2）
 */
public func JPH_Shape_CastRay2_cj(
    shape: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>, collectorType: UInt32,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_Shape_CastRay2(
            shape, origin, direction, rayCastSettings,
            collectorType, callback, userData, shapeFilter)
    }
}

/**
 * @brief 形状自身点碰撞检测（对应 JPH_Shape_CollidePoint）
 */
public func JPH_Shape_CollidePoint_cj(
    shape: CPointer<Unit>, point: CPointer<JPHVec3>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_Shape_CollidePoint(shape, point, shapeFilter)
    }
}

/**
 * @brief 形状自身点碰撞检测（带收集器回调，对应 JPH_Shape_CollidePoint2）
 */
public func JPH_Shape_CollidePoint2_cj(
    shape: CPointer<Unit>, point: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_Shape_CollidePoint2(shape, point, collectorType, callback, userData, shapeFilter)
    }
}

/**
 * @brief 获取凸形状设置的密度（对应 JPH_ConvexShapeSettings_GetDensity）
 */
public func JPH_ConvexShapeSettings_GetDensity_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_ConvexShapeSettings_GetDensity(shape)
    }
}

/**
 * @brief 设置凸形状设置的密度（对应 JPH_ConvexShapeSettings_SetDensity）
 */
public func JPH_ConvexShapeSettings_SetDensity_cj(shape: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_ConvexShapeSettings_SetDensity(shape, value)
    }
}

/**
 * @brief 获取凸形状密度（对应 JPH_ConvexShape_GetDensity）
 */
public func JPH_ConvexShape_GetDensity_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_ConvexShape_GetDensity(shape)
    }
}

/**
 * @brief 设置凸形状密度（对应 JPH_ConvexShape_SetDensity）
 */
public func JPH_ConvexShape_SetDensity_cj(shape: CPointer<Unit>, inDensity: Float32): Unit {
    unsafe {
        JPH_ConvexShape_SetDensity(shape, inDensity)
    }
}

// =============================================================================
// 形状族：Box / Sphere / Plane / Triangle / Capsule / Cylinder
// =============================================================================

/**
 * @brief 创建长方体形状设置（对应 JPH_BoxShapeSettings_Create）
 */
public func JPH_BoxShapeSettings_Create_cj(halfExtent: CPointer<JPHVec3>, convexRadius: Float32): CPointer<Unit> {
    unsafe {
        JPH_BoxShapeSettings_Create(halfExtent, convexRadius)
    }
}

/**
 * @brief 从设置创建长方体形状（对应 JPH_BoxShapeSettings_CreateShape）
 */
public func JPH_BoxShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_BoxShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取长方体半边长（对应 JPH_BoxShape_GetHalfExtent）
 */
public func JPH_BoxShape_GetHalfExtent_cj(shape: CPointer<Unit>, halfExtent: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_BoxShape_GetHalfExtent(shape, halfExtent)
    }
}

/**
 * @brief 获取长方体凸半径（对应 JPH_BoxShape_GetConvexRadius）
 */
public func JPH_BoxShape_GetConvexRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BoxShape_GetConvexRadius(shape)
    }
}

/**
 * @brief 创建球体形状设置（对应 JPH_SphereShapeSettings_Create）
 */
public func JPH_SphereShapeSettings_Create_cj(radius: Float32): CPointer<Unit> {
    unsafe {
        JPH_SphereShapeSettings_Create(radius)
    }
}

/**
 * @brief 从设置创建球体形状（对应 JPH_SphereShapeSettings_CreateShape）
 */
public func JPH_SphereShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_SphereShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取球体形状设置的半径（对应 JPH_SphereShapeSettings_GetRadius）
 */
public func JPH_SphereShapeSettings_GetRadius_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SphereShapeSettings_GetRadius(settings)
    }
}

/**
 * @brief 设置球体形状设置的半径（对应 JPH_SphereShapeSettings_SetRadius）
 */
public func JPH_SphereShapeSettings_SetRadius_cj(settings: CPointer<Unit>, radius: Float32): Unit {
    unsafe {
        JPH_SphereShapeSettings_SetRadius(settings, radius)
    }
}

/**
 * @brief 获取球体形状半径（对应 JPH_SphereShape_GetRadius）
 */
public func JPH_SphereShape_GetRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SphereShape_GetRadius(shape)
    }
}

/**
 * @brief 创建平面形状设置（对应 JPH_PlaneShapeSettings_Create）
 */
public func JPH_PlaneShapeSettings_Create_cj(
    plane: CPointer<JPHPlane>, material: CPointer<Unit>, halfExtent: Float32
): CPointer<Unit> {
    unsafe {
        JPH_PlaneShapeSettings_Create(plane, material, halfExtent)
    }
}

/**
 * @brief 从设置创建平面形状（对应 JPH_PlaneShapeSettings_CreateShape）
 */
public func JPH_PlaneShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_PlaneShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 创建平面形状（对应 JPH_PlaneShape_Create）
 */
public func JPH_PlaneShape_Create_cj(
    plane: CPointer<JPHPlane>, material: CPointer<Unit>, halfExtent: Float32
): CPointer<Unit> {
    unsafe {
        JPH_PlaneShape_Create(plane, material, halfExtent)
    }
}

/**
 * @brief 获取平面形状的平面（对应 JPH_PlaneShape_GetPlane）
 */
public func JPH_PlaneShape_GetPlane_cj(shape: CPointer<Unit>, result: CPointer<JPHPlane>): Unit {
    unsafe {
        JPH_PlaneShape_GetPlane(shape, result)
    }
}

/**
 * @brief 获取平面形状半尺寸（对应 JPH_PlaneShape_GetHalfExtent）
 */
public func JPH_PlaneShape_GetHalfExtent_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_PlaneShape_GetHalfExtent(shape)
    }
}

/**
 * @brief 创建三角形形状设置（对应 JPH_TriangleShapeSettings_Create）
 */
public func JPH_TriangleShapeSettings_Create_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, v3: CPointer<JPHVec3>, convexRadius: Float32
): CPointer<Unit> {
    unsafe {
        JPH_TriangleShapeSettings_Create(v1, v2, v3, convexRadius)
    }
}

/**
 * @brief 从设置创建三角形形状（对应 JPH_TriangleShapeSettings_CreateShape）
 */
public func JPH_TriangleShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TriangleShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 创建三角形形状（对应 JPH_TriangleShape_Create）
 */
public func JPH_TriangleShape_Create_cj(
    v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>, v3: CPointer<JPHVec3>, convexRadius: Float32
): CPointer<Unit> {
    unsafe {
        JPH_TriangleShape_Create(v1, v2, v3, convexRadius)
    }
}

/**
 * @brief 获取三角形形状凸半径（对应 JPH_TriangleShape_GetConvexRadius）
 */
public func JPH_TriangleShape_GetConvexRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TriangleShape_GetConvexRadius(shape)
    }
}

/**
 * @brief 获取三角形顶点 1（对应 JPH_TriangleShape_GetVertex1）
 */
public func JPH_TriangleShape_GetVertex1_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_TriangleShape_GetVertex1(shape, result)
    }
}

/**
 * @brief 获取三角形顶点 2（对应 JPH_TriangleShape_GetVertex2）
 */
public func JPH_TriangleShape_GetVertex2_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_TriangleShape_GetVertex2(shape, result)
    }
}

/**
 * @brief 获取三角形顶点 3（对应 JPH_TriangleShape_GetVertex3）
 */
public func JPH_TriangleShape_GetVertex3_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_TriangleShape_GetVertex3(shape, result)
    }
}

/**
 * @brief 创建胶囊体形状设置（对应 JPH_CapsuleShapeSettings_Create）
 */
public func JPH_CapsuleShapeSettings_Create_cj(halfHeightOfCylinder: Float32, radius: Float32): CPointer<Unit> {
    unsafe {
        JPH_CapsuleShapeSettings_Create(halfHeightOfCylinder, radius)
    }
}

/**
 * @brief 从设置创建胶囊体形状（对应 JPH_CapsuleShapeSettings_CreateShape）
 */
public func JPH_CapsuleShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CapsuleShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取胶囊体半径（对应 JPH_CapsuleShape_GetRadius）
 */
public func JPH_CapsuleShape_GetRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CapsuleShape_GetRadius(shape)
    }
}

/**
 * @brief 获取胶囊体圆柱段半高（对应 JPH_CapsuleShape_GetHalfHeightOfCylinder）
 */
public func JPH_CapsuleShape_GetHalfHeightOfCylinder_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CapsuleShape_GetHalfHeightOfCylinder(shape)
    }
}

/**
 * @brief 创建圆柱体形状设置（对应 JPH_CylinderShapeSettings_Create）
 */
public func JPH_CylinderShapeSettings_Create_cj(
    halfHeight: Float32, radius: Float32, convexRadius: Float32
): CPointer<Unit> {
    unsafe {
        JPH_CylinderShapeSettings_Create(halfHeight, radius, convexRadius)
    }
}

/**
 * @brief 从设置创建圆柱体形状（对应 JPH_CylinderShapeSettings_CreateShape）
 */
public func JPH_CylinderShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CylinderShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取圆柱体半径（对应 JPH_CylinderShape_GetRadius）
 */
public func JPH_CylinderShape_GetRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CylinderShape_GetRadius(shape)
    }
}

/**
 * @brief 获取圆柱体半高（对应 JPH_CylinderShape_GetHalfHeight）
 */
public func JPH_CylinderShape_GetHalfHeight_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CylinderShape_GetHalfHeight(shape)
    }
}

/**
 * @brief 创建锥台圆柱体形状设置（对应 JPH_TaperedCylinderShapeSettings_Create）
 */
public func JPH_TaperedCylinderShapeSettings_Create_cj(
    halfHeightOfTaperedCylinder: Float32, topRadius: Float32, bottomRadius: Float32,
    convexRadius: Float32, material: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_TaperedCylinderShapeSettings_Create(
            halfHeightOfTaperedCylinder, topRadius, bottomRadius, convexRadius, material)
    }
}

/**
 * @brief 从设置创建锥台圆柱体形状（对应 JPH_TaperedCylinderShapeSettings_CreateShape）
 */
public func JPH_TaperedCylinderShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TaperedCylinderShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取锥台圆柱体顶半径（对应 JPH_TaperedCylinderShape_GetTopRadius）
 */
public func JPH_TaperedCylinderShape_GetTopRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCylinderShape_GetTopRadius(shape)
    }
}

/**
 * @brief 获取锥台圆柱体底半径（对应 JPH_TaperedCylinderShape_GetBottomRadius）
 */
public func JPH_TaperedCylinderShape_GetBottomRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCylinderShape_GetBottomRadius(shape)
    }
}

/**
 * @brief 获取锥台圆柱体凸半径（对应 JPH_TaperedCylinderShape_GetConvexRadius）
 */
public func JPH_TaperedCylinderShape_GetConvexRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCylinderShape_GetConvexRadius(shape)
    }
}

/**
 * @brief 获取锥台圆柱体半高（对应 JPH_TaperedCylinderShape_GetHalfHeight）
 */
public func JPH_TaperedCylinderShape_GetHalfHeight_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCylinderShape_GetHalfHeight(shape)
    }
}

// =============================================================================
// 形状族：ConvexHull / Mesh / HeightField / TaperedCapsule
// =============================================================================

/**
 * @brief 创建凸包形状设置（对应 JPH_ConvexHullShapeSettings_Create）
 */
public func JPH_ConvexHullShapeSettings_Create_cj(
    points: CPointer<JPHVec3>, pointsCount: UInt32, maxConvexRadius: Float32
): CPointer<Unit> {
    unsafe {
        JPH_ConvexHullShapeSettings_Create(points, pointsCount, maxConvexRadius)
    }
}

/**
 * @brief 从设置创建凸包形状（对应 JPH_ConvexHullShapeSettings_CreateShape）
 */
public func JPH_ConvexHullShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_ConvexHullShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取凸包顶点数量（对应 JPH_ConvexHullShape_GetNumPoints）
 */
public func JPH_ConvexHullShape_GetNumPoints_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ConvexHullShape_GetNumPoints(shape)
    }
}

/**
 * @brief 获取凸包指定顶点（对应 JPH_ConvexHullShape_GetPoint）
 */
public func JPH_ConvexHullShape_GetPoint_cj(shape: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_ConvexHullShape_GetPoint(shape, index, result)
    }
}

/**
 * @brief 获取凸包面数量（对应 JPH_ConvexHullShape_GetNumFaces）
 */
public func JPH_ConvexHullShape_GetNumFaces_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ConvexHullShape_GetNumFaces(shape)
    }
}

/**
 * @brief 获取凸包指定面的顶点数（对应 JPH_ConvexHullShape_GetNumVerticesInFace）
 */
public func JPH_ConvexHullShape_GetNumVerticesInFace_cj(shape: CPointer<Unit>, faceIndex: UInt32): UInt32 {
    unsafe {
        JPH_ConvexHullShape_GetNumVerticesInFace(shape, faceIndex)
    }
}

/**
 * @brief 获取凸包指定面的顶点索引（对应 JPH_ConvexHullShape_GetFaceVertices）
 */
public func JPH_ConvexHullShape_GetFaceVertices_cj(
    shape: CPointer<Unit>, faceIndex: UInt32, maxVertices: UInt32, vertices: CPointer<UInt32>
): UInt32 {
    unsafe {
        JPH_ConvexHullShape_GetFaceVertices(shape, faceIndex, maxVertices, vertices)
    }
}

/**
 * @brief 创建网格形状设置（对应 JPH_MeshShapeSettings_Create）
 */
public func JPH_MeshShapeSettings_Create_cj(
    triangles: CPointer<JPHTriangle>, triangleCount: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_MeshShapeSettings_Create(triangles, triangleCount)
    }
}

/**
 * @brief 创建网格形状设置（顶点 + 索引三角形，对应 JPH_MeshShapeSettings_Create2）
 */
public func JPH_MeshShapeSettings_Create2_cj(
    vertices: CPointer<JPHVec3>, verticesCount: UInt32,
    triangles: CPointer<JPHIndexedTriangle>, triangleCount: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_MeshShapeSettings_Create2(vertices, verticesCount, triangles, triangleCount)
    }
}

/**
 * @brief 获取网格设置每叶最大三角形数（对应 JPH_MeshShapeSettings_GetMaxTrianglesPerLeaf）
 */
public func JPH_MeshShapeSettings_GetMaxTrianglesPerLeaf_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_MeshShapeSettings_GetMaxTrianglesPerLeaf(settings)
    }
}

/**
 * @brief 设置网格设置每叶最大三角形数（对应 JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf）
 */
public func JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_MeshShapeSettings_SetMaxTrianglesPerLeaf(settings, value)
    }
}

/**
 * @brief 获取网格设置活动边阈值角余弦（对应 JPH_MeshShapeSettings_GetActiveEdgeCosThresholdAngle）
 */
public func JPH_MeshShapeSettings_GetActiveEdgeCosThresholdAngle_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MeshShapeSettings_GetActiveEdgeCosThresholdAngle(settings)
    }
}

/**
 * @brief 设置网格设置活动边阈值角余弦（对应 JPH_MeshShapeSettings_SetActiveEdgeCosThresholdAngle）
 */
public func JPH_MeshShapeSettings_SetActiveEdgeCosThresholdAngle_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MeshShapeSettings_SetActiveEdgeCosThresholdAngle(settings, value)
    }
}

/**
 * @brief 获取网格设置是否按三角形存用户数据（对应 JPH_MeshShapeSettings_GetPerTriangleUserData）
 */
public func JPH_MeshShapeSettings_GetPerTriangleUserData_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_MeshShapeSettings_GetPerTriangleUserData(settings)
    }
}

/**
 * @brief 设置网格设置是否按三角形存用户数据（对应 JPH_MeshShapeSettings_SetPerTriangleUserData）
 */
public func JPH_MeshShapeSettings_SetPerTriangleUserData_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_MeshShapeSettings_SetPerTriangleUserData(settings, value)
    }
}

/**
 * @brief 获取网格设置构建质量（对应 JPH_MeshShapeSettings_GetBuildQuality）
 */
public func JPH_MeshShapeSettings_GetBuildQuality_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_MeshShapeSettings_GetBuildQuality(settings)
    }
}

/**
 * @brief 设置网格设置构建质量（对应 JPH_MeshShapeSettings_SetBuildQuality）
 */
public func JPH_MeshShapeSettings_SetBuildQuality_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_MeshShapeSettings_SetBuildQuality(settings, value)
    }
}

/**
 * @brief 修正网格设置（对应 JPH_MeshShapeSettings_Sanitize）
 */
public func JPH_MeshShapeSettings_Sanitize_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_MeshShapeSettings_Sanitize(settings)
    }
}

/**
 * @brief 从设置创建网格形状（对应 JPH_MeshShapeSettings_CreateShape）
 */
public func JPH_MeshShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_MeshShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取网格指定三角形的用户数据（对应 JPH_MeshShape_GetTriangleUserData）
 */
public func JPH_MeshShape_GetTriangleUserData_cj(shape: CPointer<Unit>, id: UInt32): UInt32 {
    unsafe {
        JPH_MeshShape_GetTriangleUserData(shape, id)
    }
}

/**
 * @brief 创建高度场形状设置（对应 JPH_HeightFieldShapeSettings_Create）
 */
public func JPH_HeightFieldShapeSettings_Create_cj(
    samples: CPointer<Float32>, offset: CPointer<JPHVec3>, scale: CPointer<JPHVec3>,
    sampleCount: UInt32, materialIndices: CPointer<UInt8>
): CPointer<Unit> {
    unsafe {
        JPH_HeightFieldShapeSettings_Create(samples, offset, scale, sampleCount, materialIndices)
    }
}

/**
 * @brief 计算高度场采样最小/最大值与量化比例（对应 JPH_HeightFieldShapeSettings_DetermineMinAndMaxSample）
 */
public func JPH_HeightFieldShapeSettings_DetermineMinAndMaxSample_cj(
    settings: CPointer<Unit>, pOutMinValue: CPointer<Float32>,
    pOutMaxValue: CPointer<Float32>, pOutQuantizationScale: CPointer<Float32>
): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_DetermineMinAndMaxSample(
            settings, pOutMinValue, pOutMaxValue, pOutQuantizationScale)
    }
}

/**
 * @brief 计算指定误差下的每采样位数（对应 JPH_HeightFieldShapeSettings_CalculateBitsPerSampleForError）
 */
public func JPH_HeightFieldShapeSettings_CalculateBitsPerSampleForError_cj(
    settings: CPointer<Unit>, maxError: Float32
): UInt32 {
    unsafe {
        JPH_HeightFieldShapeSettings_CalculateBitsPerSampleForError(settings, maxError)
    }
}

/**
 * @brief 获取高度场偏移（对应 JPH_HeightFieldShapeSettings_GetOffset）
 */
public func JPH_HeightFieldShapeSettings_GetOffset_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_GetOffset(shape, result)
    }
}

/**
 * @brief 设置高度场偏移（对应 JPH_HeightFieldShapeSettings_SetOffset）
 */
public func JPH_HeightFieldShapeSettings_SetOffset_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetOffset(settings, value)
    }
}

/**
 * @brief 获取高度场缩放（对应 JPH_HeightFieldShapeSettings_GetScale）
 */
public func JPH_HeightFieldShapeSettings_GetScale_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_GetScale(shape, result)
    }
}

/**
 * @brief 设置高度场缩放（对应 JPH_HeightFieldShapeSettings_SetScale）
 */
public func JPH_HeightFieldShapeSettings_SetScale_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetScale(settings, value)
    }
}

/**
 * @brief 获取高度场采样数（对应 JPH_HeightFieldShapeSettings_GetSampleCount）
 */
public func JPH_HeightFieldShapeSettings_GetSampleCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetSampleCount(settings)
    }
}

/**
 * @brief 设置高度场采样数（对应 JPH_HeightFieldShapeSettings_SetSampleCount）
 */
public func JPH_HeightFieldShapeSettings_SetSampleCount_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetSampleCount(settings, value)
    }
}

/**
 * @brief 获取高度场最小高度（对应 JPH_HeightFieldShapeSettings_GetMinHeightValue）
 */
public func JPH_HeightFieldShapeSettings_GetMinHeightValue_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetMinHeightValue(settings)
    }
}

/**
 * @brief 设置高度场最小高度（对应 JPH_HeightFieldShapeSettings_SetMinHeightValue）
 */
public func JPH_HeightFieldShapeSettings_SetMinHeightValue_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetMinHeightValue(settings, value)
    }
}

/**
 * @brief 获取高度场最大高度（对应 JPH_HeightFieldShapeSettings_GetMaxHeightValue）
 */
public func JPH_HeightFieldShapeSettings_GetMaxHeightValue_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetMaxHeightValue(settings)
    }
}

/**
 * @brief 设置高度场最大高度（对应 JPH_HeightFieldShapeSettings_SetMaxHeightValue）
 */
public func JPH_HeightFieldShapeSettings_SetMaxHeightValue_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetMaxHeightValue(settings, value)
    }
}

/**
 * @brief 获取高度场块大小（对应 JPH_HeightFieldShapeSettings_GetBlockSize）
 */
public func JPH_HeightFieldShapeSettings_GetBlockSize_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetBlockSize(settings)
    }
}

/**
 * @brief 设置高度场块大小（对应 JPH_HeightFieldShapeSettings_SetBlockSize）
 */
public func JPH_HeightFieldShapeSettings_SetBlockSize_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetBlockSize(settings, value)
    }
}

/**
 * @brief 获取高度场每采样位数（对应 JPH_HeightFieldShapeSettings_GetBitsPerSample）
 */
public func JPH_HeightFieldShapeSettings_GetBitsPerSample_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetBitsPerSample(settings)
    }
}

/**
 * @brief 设置高度场每采样位数（对应 JPH_HeightFieldShapeSettings_SetBitsPerSample）
 */
public func JPH_HeightFieldShapeSettings_SetBitsPerSample_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetBitsPerSample(settings, value)
    }
}

/**
 * @brief 获取高度场活动边阈值角余弦（对应 JPH_HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle）
 */
public func JPH_HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HeightFieldShapeSettings_GetActiveEdgeCosThresholdAngle(settings)
    }
}

/**
 * @brief 设置高度场活动边阈值角余弦（对应 JPH_HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle）
 */
public func JPH_HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_HeightFieldShapeSettings_SetActiveEdgeCosThresholdAngle(settings, value)
    }
}

/**
 * @brief 从设置创建高度场形状（对应 JPH_HeightFieldShapeSettings_CreateShape）
 */
public func JPH_HeightFieldShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_HeightFieldShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取高度场采样数（对应 JPH_HeightFieldShape_GetSampleCount）
 */
public func JPH_HeightFieldShape_GetSampleCount_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HeightFieldShape_GetSampleCount(shape)
    }
}

/**
 * @brief 获取高度场块大小（对应 JPH_HeightFieldShape_GetBlockSize）
 */
public func JPH_HeightFieldShape_GetBlockSize_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HeightFieldShape_GetBlockSize(shape)
    }
}

/**
 * @brief 获取高度场指定格材质（对应 JPH_HeightFieldShape_GetMaterial）
 */
public func JPH_HeightFieldShape_GetMaterial_cj(shape: CPointer<Unit>, x: UInt32, y: UInt32): CPointer<Unit> {
    unsafe {
        JPH_HeightFieldShape_GetMaterial(shape, x, y)
    }
}

/**
 * @brief 获取高度场指定格位置（对应 JPH_HeightFieldShape_GetPosition）
 */
public func JPH_HeightFieldShape_GetPosition_cj(
    shape: CPointer<Unit>, x: UInt32, y: UInt32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HeightFieldShape_GetPosition(shape, x, y, result)
    }
}

/**
 * @brief 高度场指定格是否无碰撞（对应 JPH_HeightFieldShape_IsNoCollision）
 */
public func JPH_HeightFieldShape_IsNoCollision_cj(shape: CPointer<Unit>, x: UInt32, y: UInt32): UInt8 {
    unsafe {
        JPH_HeightFieldShape_IsNoCollision(shape, x, y)
    }
}

/**
 * @brief 将局部位置投影到高度场表面（对应 JPH_HeightFieldShape_ProjectOntoSurface）
 */
public func JPH_HeightFieldShape_ProjectOntoSurface_cj(
    shape: CPointer<Unit>, localPosition: CPointer<JPHVec3>,
    outSurfacePosition: CPointer<JPHVec3>, outSubShapeID: CPointer<UInt32>
): UInt8 {
    unsafe {
        JPH_HeightFieldShape_ProjectOntoSurface(shape, localPosition, outSurfacePosition, outSubShapeID)
    }
}

/**
 * @brief 获取高度场最小高度（对应 JPH_HeightFieldShape_GetMinHeightValue）
 */
public func JPH_HeightFieldShape_GetMinHeightValue_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HeightFieldShape_GetMinHeightValue(shape)
    }
}

/**
 * @brief 获取高度场最大高度（对应 JPH_HeightFieldShape_GetMaxHeightValue）
 */
public func JPH_HeightFieldShape_GetMaxHeightValue_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HeightFieldShape_GetMaxHeightValue(shape)
    }
}

/**
 * @brief 创建锥台胶囊体形状设置（对应 JPH_TaperedCapsuleShapeSettings_Create）
 */
public func JPH_TaperedCapsuleShapeSettings_Create_cj(
    halfHeightOfTaperedCylinder: Float32, topRadius: Float32, bottomRadius: Float32
): CPointer<Unit> {
    unsafe {
        JPH_TaperedCapsuleShapeSettings_Create(halfHeightOfTaperedCylinder, topRadius, bottomRadius)
    }
}

/**
 * @brief 从设置创建锥台胶囊体形状（对应 JPH_TaperedCapsuleShapeSettings_CreateShape）
 */
public func JPH_TaperedCapsuleShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TaperedCapsuleShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 获取锥台胶囊体顶半径（对应 JPH_TaperedCapsuleShape_GetTopRadius）
 */
public func JPH_TaperedCapsuleShape_GetTopRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCapsuleShape_GetTopRadius(shape)
    }
}

/**
 * @brief 获取锥台胶囊体底半径（对应 JPH_TaperedCapsuleShape_GetBottomRadius）
 */
public func JPH_TaperedCapsuleShape_GetBottomRadius_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCapsuleShape_GetBottomRadius(shape)
    }
}

/**
 * @brief 获取锥台胶囊体半高（对应 JPH_TaperedCapsuleShape_GetHalfHeight）
 */
public func JPH_TaperedCapsuleShape_GetHalfHeight_cj(shape: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TaperedCapsuleShape_GetHalfHeight(shape)
    }
}

// =============================================================================
// 形状族：Compound / StaticCompound / MutableCompound / Decorated
// =============================================================================

/**
 * @brief 向复合形状设置添加子形状（对应 JPH_CompoundShapeSettings_AddShape）
 */
public func JPH_CompoundShapeSettings_AddShape_cj(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    shapeSettings: CPointer<Unit>, userData: UInt32
): Unit {
    unsafe {
        JPH_CompoundShapeSettings_AddShape(settings, position, rotation, shapeSettings, userData)
    }
}

/**
 * @brief 向复合形状设置添加子形状（已创建 shape 形式，对应 JPH_CompoundShapeSettings_AddShape2）
 */
public func JPH_CompoundShapeSettings_AddShape2_cj(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    shape: CPointer<Unit>, userData: UInt32
): Unit {
    unsafe {
        JPH_CompoundShapeSettings_AddShape2(settings, position, rotation, shape, userData)
    }
}

/**
 * @brief 获取复合形状子形状数量（对应 JPH_CompoundShape_GetNumSubShapes）
 */
public func JPH_CompoundShape_GetNumSubShapes_cj(shape: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CompoundShape_GetNumSubShapes(shape)
    }
}

/**
 * @brief 获取复合形状指定子形状（对应 JPH_CompoundShape_GetSubShape）
 */
public func JPH_CompoundShape_GetSubShape_cj(
    shape: CPointer<Unit>, index: UInt32,
    subShape: CPointer<CPointer<Unit>>, positionCOM: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: CPointer<UInt32>
): Unit {
    unsafe {
        JPH_CompoundShape_GetSubShape(shape, index, subShape, positionCOM, rotation, userData)
    }
}

/**
 * @brief 从子形状 ID 获取子形状索引（对应 JPH_CompoundShape_GetSubShapeIndexFromID）
 */
public func JPH_CompoundShape_GetSubShapeIndexFromID_cj(
    shape: CPointer<Unit>, id: UInt32, remainder: CPointer<UInt32>
): UInt32 {
    unsafe {
        JPH_CompoundShape_GetSubShapeIndexFromID(shape, id, remainder)
    }
}

/**
 * @brief 创建静态复合形状设置（对应 JPH_StaticCompoundShapeSettings_Create）
 */
public func JPH_StaticCompoundShapeSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_StaticCompoundShapeSettings_Create()
    }
}

/**
 * @brief 从设置创建静态复合形状（对应 JPH_StaticCompoundShape_Create）
 */
public func JPH_StaticCompoundShape_Create_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_StaticCompoundShape_Create(settings)
    }
}

/**
 * @brief 创建可变复合形状设置（对应 JPH_MutableCompoundShapeSettings_Create）
 */
public func JPH_MutableCompoundShapeSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_MutableCompoundShapeSettings_Create()
    }
}

/**
 * @brief 从设置创建可变复合形状（对应 JPH_MutableCompoundShape_Create）
 */
public func JPH_MutableCompoundShape_Create_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_MutableCompoundShape_Create(settings)
    }
}

/**
 * @brief 向可变复合形状添加子形状（对应 JPH_MutableCompoundShape_AddShape）
 */
public func JPH_MutableCompoundShape_AddShape_cj(
    shape: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    child: CPointer<Unit>, userData: UInt32, index: UInt32
): UInt32 {
    unsafe {
        JPH_MutableCompoundShape_AddShape(shape, position, rotation, child, userData, index)
    }
}

/**
 * @brief 从可变复合形状移除子形状（对应 JPH_MutableCompoundShape_RemoveShape）
 */
public func JPH_MutableCompoundShape_RemoveShape_cj(shape: CPointer<Unit>, index: UInt32): Unit {
    unsafe {
        JPH_MutableCompoundShape_RemoveShape(shape, index)
    }
}

/**
 * @brief 修改可变复合形状子形状位置/旋转（对应 JPH_MutableCompoundShape_ModifyShape）
 */
public func JPH_MutableCompoundShape_ModifyShape_cj(
    shape: CPointer<Unit>, index: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_MutableCompoundShape_ModifyShape(shape, index, position, rotation)
    }
}

/**
 * @brief 修改可变复合形状子形状（含替换，对应 JPH_MutableCompoundShape_ModifyShape2）
 */
public func JPH_MutableCompoundShape_ModifyShape2_cj(
    shape: CPointer<Unit>, index: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, newShape: CPointer<Unit>
): Unit {
    unsafe {
        JPH_MutableCompoundShape_ModifyShape2(shape, index, position, rotation, newShape)
    }
}

/**
 * @brief 调整可变复合形状质心（对应 JPH_MutableCompoundShape_AdjustCenterOfMass）
 */
public func JPH_MutableCompoundShape_AdjustCenterOfMass_cj(shape: CPointer<Unit>): Unit {
    unsafe {
        JPH_MutableCompoundShape_AdjustCenterOfMass(shape)
    }
}

/**
 * @brief 获取装饰形状的内部形状（对应 JPH_DecoratedShape_GetInnerShape）
 */
public func JPH_DecoratedShape_GetInnerShape_cj(shape: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_DecoratedShape_GetInnerShape(shape)
    }
}

/**
 * @brief 创建平移旋转形状设置（对应 JPH_RotatedTranslatedShapeSettings_Create）
 */
public func JPH_RotatedTranslatedShapeSettings_Create_cj(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shapeSettings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_RotatedTranslatedShapeSettings_Create(position, rotation, shapeSettings)
    }
}

/**
 * @brief 创建平移旋转形状设置（已创建 shape 形式，对应 JPH_RotatedTranslatedShapeSettings_Create2）
 */
public func JPH_RotatedTranslatedShapeSettings_Create2_cj(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shape: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_RotatedTranslatedShapeSettings_Create2(position, rotation, shape)
    }
}

/**
 * @brief 从设置创建平移旋转形状（对应 JPH_RotatedTranslatedShapeSettings_CreateShape）
 */
public func JPH_RotatedTranslatedShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_RotatedTranslatedShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 创建平移旋转形状（对应 JPH_RotatedTranslatedShape_Create）
 */
public func JPH_RotatedTranslatedShape_Create_cj(
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, shape: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_RotatedTranslatedShape_Create(position, rotation, shape)
    }
}

/**
 * @brief 获取平移旋转形状的平移（对应 JPH_RotatedTranslatedShape_GetPosition）
 */
public func JPH_RotatedTranslatedShape_GetPosition_cj(shape: CPointer<Unit>, position: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_RotatedTranslatedShape_GetPosition(shape, position)
    }
}

/**
 * @brief 获取平移旋转形状的旋转（对应 JPH_RotatedTranslatedShape_GetRotation）
 */
public func JPH_RotatedTranslatedShape_GetRotation_cj(shape: CPointer<Unit>, rotation: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_RotatedTranslatedShape_GetRotation(shape, rotation)
    }
}

/**
 * @brief 创建缩放形状设置（对应 JPH_ScaledShapeSettings_Create）
 */
public func JPH_ScaledShapeSettings_Create_cj(
    shapeSettings: CPointer<Unit>, scale: CPointer<JPHVec3>
): CPointer<Unit> {
    unsafe {
        JPH_ScaledShapeSettings_Create(shapeSettings, scale)
    }
}

/**
 * @brief 创建缩放形状设置（已创建 shape 形式，对应 JPH_ScaledShapeSettings_Create2）
 */
public func JPH_ScaledShapeSettings_Create2_cj(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit> {
    unsafe {
        JPH_ScaledShapeSettings_Create2(shape, scale)
    }
}

/**
 * @brief 从设置创建缩放形状（对应 JPH_ScaledShapeSettings_CreateShape）
 */
public func JPH_ScaledShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_ScaledShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 创建缩放形状（对应 JPH_ScaledShape_Create）
 */
public func JPH_ScaledShape_Create_cj(shape: CPointer<Unit>, scale: CPointer<JPHVec3>): CPointer<Unit> {
    unsafe {
        JPH_ScaledShape_Create(shape, scale)
    }
}

/**
 * @brief 获取缩放形状的缩放（对应 JPH_ScaledShape_GetScale）
 */
public func JPH_ScaledShape_GetScale_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_ScaledShape_GetScale(shape, result)
    }
}

/**
 * @brief 创建质心偏移形状设置（对应 JPH_OffsetCenterOfMassShapeSettings_Create）
 */
public func JPH_OffsetCenterOfMassShapeSettings_Create_cj(
    offset: CPointer<JPHVec3>, shapeSettings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_OffsetCenterOfMassShapeSettings_Create(offset, shapeSettings)
    }
}

/**
 * @brief 创建质心偏移形状设置（已创建 shape 形式，对应 JPH_OffsetCenterOfMassShapeSettings_Create2）
 */
public func JPH_OffsetCenterOfMassShapeSettings_Create2_cj(
    offset: CPointer<JPHVec3>, shape: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_OffsetCenterOfMassShapeSettings_Create2(offset, shape)
    }
}

/**
 * @brief 从设置创建质心偏移形状（对应 JPH_OffsetCenterOfMassShapeSettings_CreateShape）
 */
public func JPH_OffsetCenterOfMassShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_OffsetCenterOfMassShapeSettings_CreateShape(settings)
    }
}

/**
 * @brief 创建质心偏移形状（对应 JPH_OffsetCenterOfMassShape_Create）
 */
public func JPH_OffsetCenterOfMassShape_Create_cj(offset: CPointer<JPHVec3>, shape: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_OffsetCenterOfMassShape_Create(offset, shape)
    }
}

/**
 * @brief 获取质心偏移形状的偏移（对应 JPH_OffsetCenterOfMassShape_GetOffset）
 */
public func JPH_OffsetCenterOfMassShape_GetOffset_cj(shape: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_OffsetCenterOfMassShape_GetOffset(shape, result)
    }
}

/**
 * @brief 创建空形状设置（对应 JPH_EmptyShapeSettings_Create）
 */
public func JPH_EmptyShapeSettings_Create_cj(centerOfMass: CPointer<JPHVec3>): CPointer<Unit> {
    unsafe {
        JPH_EmptyShapeSettings_Create(centerOfMass)
    }
}

/**
 * @brief 从设置创建空形状（对应 JPH_EmptyShapeSettings_CreateShape）
 */
public func JPH_EmptyShapeSettings_CreateShape_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_EmptyShapeSettings_CreateShape(settings)
    }
}

// =============================================================================
// 刚体创建设置（BodyCreationSettings）完整
// =============================================================================

/**
 * @brief 创建空刚体创建设置（对应 JPH_BodyCreationSettings_Create）
 */
public func JPH_BodyCreationSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_BodyCreationSettings_Create()
    }
}

/**
 * @brief 创建刚体创建设置（形状设置形式，对应 JPH_BodyCreationSettings_Create2）
 */
public func JPH_BodyCreationSettings_Create2_cj(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    motionType: UInt32, objectLayer: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyCreationSettings_Create2(settings, position, rotation, motionType, objectLayer)
    }
}

/**
 * @brief 获取初始位置（对应 JPH_BodyCreationSettings_GetPosition）
 */
public func JPH_BodyCreationSettings_GetPosition_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetPosition(settings, result)
    }
}

/**
 * @brief 设置初始位置（对应 JPH_BodyCreationSettings_SetPosition）
 */
public func JPH_BodyCreationSettings_SetPosition_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetPosition(settings, value)
    }
}

/**
 * @brief 获取初始旋转（对应 JPH_BodyCreationSettings_GetRotation）
 */
public func JPH_BodyCreationSettings_GetRotation_cj(settings: CPointer<Unit>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetRotation(settings, result)
    }
}

/**
 * @brief 设置初始旋转（对应 JPH_BodyCreationSettings_SetRotation）
 */
public func JPH_BodyCreationSettings_SetRotation_cj(settings: CPointer<Unit>, value: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetRotation(settings, value)
    }
}

/**
 * @brief 获取初始线速度（对应 JPH_BodyCreationSettings_GetLinearVelocity）
 */
public func JPH_BodyCreationSettings_GetLinearVelocity_cj(
    settings: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetLinearVelocity(settings, velocity)
    }
}

/**
 * @brief 设置初始线速度（对应 JPH_BodyCreationSettings_SetLinearVelocity）
 */
public func JPH_BodyCreationSettings_SetLinearVelocity_cj(
    settings: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetLinearVelocity(settings, velocity)
    }
}

/**
 * @brief 获取初始角速度（对应 JPH_BodyCreationSettings_GetAngularVelocity）
 */
public func JPH_BodyCreationSettings_GetAngularVelocity_cj(
    settings: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetAngularVelocity(settings, velocity)
    }
}

/**
 * @brief 设置初始角速度（对应 JPH_BodyCreationSettings_SetAngularVelocity）
 */
public func JPH_BodyCreationSettings_SetAngularVelocity_cj(
    settings: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetAngularVelocity(settings, velocity)
    }
}

/**
 * @brief 获取用户数据（对应 JPH_BodyCreationSettings_GetUserData）
 */
public func JPH_BodyCreationSettings_GetUserData_cj(settings: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_BodyCreationSettings_GetUserData(settings)
    }
}

/**
 * @brief 设置用户数据（对应 JPH_BodyCreationSettings_SetUserData）
 */
public func JPH_BodyCreationSettings_SetUserData_cj(settings: CPointer<Unit>, value: UInt64): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetUserData(settings, value)
    }
}

/**
 * @brief 获取对象层（对应 JPH_BodyCreationSettings_GetObjectLayer）
 */
public func JPH_BodyCreationSettings_GetObjectLayer_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetObjectLayer(settings)
    }
}

/**
 * @brief 设置对象层（对应 JPH_BodyCreationSettings_SetObjectLayer）
 */
public func JPH_BodyCreationSettings_SetObjectLayer_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetObjectLayer(settings, value)
    }
}

/**
 * @brief 获取碰撞组（对应 JPH_BodyCreationSettings_GetCollisionGroup）
 */
public func JPH_BodyCreationSettings_GetCollisionGroup_cj(
    settings: CPointer<Unit>, result: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetCollisionGroup(settings, result)
    }
}

/**
 * @brief 设置碰撞组（对应 JPH_BodyCreationSettings_SetCollisionGroup）
 */
public func JPH_BodyCreationSettings_SetCollisionGroup_cj(
    settings: CPointer<Unit>, value: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetCollisionGroup(settings, value)
    }
}

/**
 * @brief 获取运动类型（对应 JPH_BodyCreationSettings_GetMotionType）
 */
public func JPH_BodyCreationSettings_GetMotionType_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetMotionType(settings)
    }
}

/**
 * @brief 设置运动类型（对应 JPH_BodyCreationSettings_SetMotionType）
 */
public func JPH_BodyCreationSettings_SetMotionType_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetMotionType(settings, value)
    }
}

/**
 * @brief 获取允许自由度（对应 JPH_BodyCreationSettings_GetAllowedDOFs）
 */
public func JPH_BodyCreationSettings_GetAllowedDOFs_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetAllowedDOFs(settings)
    }
}

/**
 * @brief 设置允许自由度（对应 JPH_BodyCreationSettings_SetAllowedDOFs）
 */
public func JPH_BodyCreationSettings_SetAllowedDOFs_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetAllowedDOFs(settings, value)
    }
}

/**
 * @brief 是否允许动态/运动学切换（对应 JPH_BodyCreationSettings_GetAllowDynamicOrKinematic）
 */
public func JPH_BodyCreationSettings_GetAllowDynamicOrKinematic_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetAllowDynamicOrKinematic(settings)
    }
}

/**
 * @brief 设置是否允许动态/运动学切换（对应 JPH_BodyCreationSettings_SetAllowDynamicOrKinematic）
 */
public func JPH_BodyCreationSettings_SetAllowDynamicOrKinematic_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetAllowDynamicOrKinematic(settings, value)
    }
}

/**
 * @brief 是否传感器（对应 JPH_BodyCreationSettings_GetIsSensor）
 */
public func JPH_BodyCreationSettings_GetIsSensor_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetIsSensor(settings)
    }
}

/**
 * @brief 设置是否传感器（对应 JPH_BodyCreationSettings_SetIsSensor）
 */
public func JPH_BodyCreationSettings_SetIsSensor_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetIsSensor(settings, value)
    }
}

/**
 * @brief 获取是否允许休眠（对应 JPH_BodyCreationSettings_GetAllowSleeping）
 */
public func JPH_BodyCreationSettings_GetAllowSleeping_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetAllowSleeping(settings)
    }
}

/**
 * @brief 设置是否允许休眠（对应 JPH_BodyCreationSettings_SetAllowSleeping）
 */
public func JPH_BodyCreationSettings_SetAllowSleeping_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetAllowSleeping(settings, value)
    }
}

/**
 * @brief 获取摩擦系数（对应 JPH_BodyCreationSettings_GetFriction）
 */
public func JPH_BodyCreationSettings_GetFriction_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetFriction(settings)
    }
}

/**
 * @brief 设置摩擦系数（对应 JPH_BodyCreationSettings_SetFriction）
 */
public func JPH_BodyCreationSettings_SetFriction_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetFriction(settings, value)
    }
}

/**
 * @brief 获取弹性系数（对应 JPH_BodyCreationSettings_GetRestitution）
 */
public func JPH_BodyCreationSettings_GetRestitution_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetRestitution(settings)
    }
}

/**
 * @brief 设置弹性系数（对应 JPH_BodyCreationSettings_SetRestitution）
 */
public func JPH_BodyCreationSettings_SetRestitution_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetRestitution(settings, value)
    }
}

/**
 * @brief 获取线阻尼（对应 JPH_BodyCreationSettings_GetLinearDamping）
 */
public func JPH_BodyCreationSettings_GetLinearDamping_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetLinearDamping(settings)
    }
}

/**
 * @brief 设置线阻尼（对应 JPH_BodyCreationSettings_SetLinearDamping）
 */
public func JPH_BodyCreationSettings_SetLinearDamping_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetLinearDamping(settings, value)
    }
}

/**
 * @brief 获取角阻尼（对应 JPH_BodyCreationSettings_GetAngularDamping）
 */
public func JPH_BodyCreationSettings_GetAngularDamping_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetAngularDamping(settings)
    }
}

/**
 * @brief 设置角阻尼（对应 JPH_BodyCreationSettings_SetAngularDamping）
 */
public func JPH_BodyCreationSettings_SetAngularDamping_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetAngularDamping(settings, value)
    }
}

/**
 * @brief 获取最大线速度（对应 JPH_BodyCreationSettings_GetMaxLinearVelocity）
 */
public func JPH_BodyCreationSettings_GetMaxLinearVelocity_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetMaxLinearVelocity(settings)
    }
}

/**
 * @brief 设置最大线速度（对应 JPH_BodyCreationSettings_SetMaxLinearVelocity）
 */
public func JPH_BodyCreationSettings_SetMaxLinearVelocity_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetMaxLinearVelocity(settings, value)
    }
}

/**
 * @brief 获取最大角速度（对应 JPH_BodyCreationSettings_GetMaxAngularVelocity）
 */
public func JPH_BodyCreationSettings_GetMaxAngularVelocity_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetMaxAngularVelocity(settings)
    }
}

/**
 * @brief 设置最大角速度（对应 JPH_BodyCreationSettings_SetMaxAngularVelocity）
 */
public func JPH_BodyCreationSettings_SetMaxAngularVelocity_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetMaxAngularVelocity(settings, value)
    }
}

/**
 * @brief 获取重力因子（对应 JPH_BodyCreationSettings_GetGravityFactor）
 */
public func JPH_BodyCreationSettings_GetGravityFactor_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetGravityFactor(settings)
    }
}

/**
 * @brief 设置重力因子（对应 JPH_BodyCreationSettings_SetGravityFactor）
 */
public func JPH_BodyCreationSettings_SetGravityFactor_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetGravityFactor(settings, value)
    }
}

/**
 * @brief 获取是否应用陀螺力（对应 JPH_BodyCreationSettings_GetApplyGyroscopicForce）
 */
public func JPH_BodyCreationSettings_GetApplyGyroscopicForce_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetApplyGyroscopicForce(settings)
    }
}

/**
 * @brief 设置是否应用陀螺力（对应 JPH_BodyCreationSettings_SetApplyGyroscopicForce）
 */
public func JPH_BodyCreationSettings_SetApplyGyroscopicForce_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetApplyGyroscopicForce(settings, value)
    }
}

/**
 * @brief 获取惯量乘数（对应 JPH_BodyCreationSettings_GetInertiaMultiplier）
 */
public func JPH_BodyCreationSettings_GetInertiaMultiplier_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_BodyCreationSettings_GetInertiaMultiplier(settings)
    }
}

/**
 * @brief 设置惯量乘数（对应 JPH_BodyCreationSettings_SetInertiaMultiplier）
 */
public func JPH_BodyCreationSettings_SetInertiaMultiplier_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetInertiaMultiplier(settings, value)
    }
}

/**
 * @brief 获取质量属性覆盖方式（对应 JPH_BodyCreationSettings_GetOverrideMassProperties）
 */
public func JPH_BodyCreationSettings_GetOverrideMassProperties_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetOverrideMassProperties(settings)
    }
}

/**
 * @brief 设置质量属性覆盖方式（对应 JPH_BodyCreationSettings_SetOverrideMassProperties）
 */
public func JPH_BodyCreationSettings_SetOverrideMassProperties_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetOverrideMassProperties(settings, value)
    }
}

/**
 * @brief 获取质量属性覆盖值（对应 JPH_BodyCreationSettings_GetMassPropertiesOverride）
 */
public func JPH_BodyCreationSettings_GetMassPropertiesOverride_cj(
    settings: CPointer<Unit>, result: CPointer<JPHMassProperties>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_GetMassPropertiesOverride(settings, result)
    }
}

/**
 * @brief 设置质量属性覆盖值（对应 JPH_BodyCreationSettings_SetMassPropertiesOverride）
 */
public func JPH_BodyCreationSettings_SetMassPropertiesOverride_cj(
    settings: CPointer<Unit>, value: CPointer<JPHMassProperties>
): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetMassPropertiesOverride(settings, value)
    }
}

/**
 * @brief 获取运动质量（对应 JPH_BodyCreationSettings_GetMotionQuality）
 */
public func JPH_BodyCreationSettings_GetMotionQuality_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetMotionQuality(settings)
    }
}

/**
 * @brief 设置运动质量（对应 JPH_BodyCreationSettings_SetMotionQuality）
 */
public func JPH_BodyCreationSettings_SetMotionQuality_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetMotionQuality(settings, value)
    }
}

/**
 * @brief 获取增强内部边移除（对应 JPH_BodyCreationSettings_GetEnhancedInternalEdgeRemoval）
 */
public func JPH_BodyCreationSettings_GetEnhancedInternalEdgeRemoval_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetEnhancedInternalEdgeRemoval(settings)
    }
}

/**
 * @brief 设置增强内部边移除（对应 JPH_BodyCreationSettings_SetEnhancedInternalEdgeRemoval）
 */
public func JPH_BodyCreationSettings_SetEnhancedInternalEdgeRemoval_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetEnhancedInternalEdgeRemoval(settings, value)
    }
}

/**
 * @brief 获取运动学 vs 非动态碰撞（对应 JPH_BodyCreationSettings_GetCollideKinematicVsNonDynamic）
 */
public func JPH_BodyCreationSettings_GetCollideKinematicVsNonDynamic_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetCollideKinematicVsNonDynamic(settings)
    }
}

/**
 * @brief 设置运动学 vs 非动态碰撞（对应 JPH_BodyCreationSettings_SetCollideKinematicVsNonDynamic）
 */
public func JPH_BodyCreationSettings_SetCollideKinematicVsNonDynamic_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetCollideKinematicVsNonDynamic(settings, value)
    }
}

/**
 * @brief 获取使用流形简化（对应 JPH_BodyCreationSettings_GetUseManifoldReduction）
 */
public func JPH_BodyCreationSettings_GetUseManifoldReduction_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_BodyCreationSettings_GetUseManifoldReduction(settings)
    }
}

/**
 * @brief 设置使用流形简化（对应 JPH_BodyCreationSettings_SetUseManifoldReduction）
 */
public func JPH_BodyCreationSettings_SetUseManifoldReduction_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetUseManifoldReduction(settings, value)
    }
}

/**
 * @brief 获取速度迭代步数覆盖（对应 JPH_BodyCreationSettings_GetNumVelocityStepsOverride）
 */
public func JPH_BodyCreationSettings_GetNumVelocityStepsOverride_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetNumVelocityStepsOverride(settings)
    }
}

/**
 * @brief 设置速度迭代步数覆盖（对应 JPH_BodyCreationSettings_SetNumVelocityStepsOverride）
 */
public func JPH_BodyCreationSettings_SetNumVelocityStepsOverride_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetNumVelocityStepsOverride(settings, value)
    }
}

/**
 * @brief 获取位置迭代步数覆盖（对应 JPH_BodyCreationSettings_GetNumPositionStepsOverride）
 */
public func JPH_BodyCreationSettings_GetNumPositionStepsOverride_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_BodyCreationSettings_GetNumPositionStepsOverride(settings)
    }
}

/**
 * @brief 设置位置迭代步数覆盖（对应 JPH_BodyCreationSettings_SetNumPositionStepsOverride）
 */
public func JPH_BodyCreationSettings_SetNumPositionStepsOverride_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_BodyCreationSettings_SetNumPositionStepsOverride(settings, value)
    }
}

// =============================================================================
// 刚体接口（BodyInterface）：创建 / 生命周期
// =============================================================================

/**
 * @brief 创建刚体但不加入世界（对应 JPH_BodyInterface_CreateBody）
 */
public func JPH_BodyInterface_CreateBody_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateBody(bodyInterface, settings)
    }
}

/**
 * @brief 创建刚体并分配指定 ID（对应 JPH_BodyInterface_CreateBodyWithID）
 */
public func JPH_BodyInterface_CreateBodyWithID_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateBodyWithID(bodyInterface, bodyID, settings)
    }
}

/**
 * @brief 创建刚体（无 ID 版本，对应 JPH_BodyInterface_CreateBodyWithoutID）
 */
public func JPH_BodyInterface_CreateBodyWithoutID_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateBodyWithoutID(bodyInterface, settings)
    }
}

/**
 * @brief 销毁刚体（不要求先移除，对应 JPH_BodyInterface_DestroyBodyWithoutID）
 */
public func JPH_BodyInterface_DestroyBodyWithoutID_cj(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>
): Unit {
    unsafe {
        JPH_BodyInterface_DestroyBodyWithoutID(bodyInterface, body)
    }
}

/**
 * @brief 为无 ID 刚体分配 BodyID（对应 JPH_BodyInterface_AssignBodyID）
 */
public func JPH_BodyInterface_AssignBodyID_cj(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BodyInterface_AssignBodyID(bodyInterface, body)
    }
}

/**
 * @brief 为无 ID 刚体分配指定 BodyID（对应 JPH_BodyInterface_AssignBodyID2）
 */
public func JPH_BodyInterface_AssignBodyID2_cj(
    bodyInterface: CPointer<Unit>, body: CPointer<Unit>, bodyID: UInt32
): UInt8 {
    unsafe {
        JPH_BodyInterface_AssignBodyID2(bodyInterface, body, bodyID)
    }
}

/**
 * @brief 解除刚体的 BodyID 分配（对应 JPH_BodyInterface_UnassignBodyID）
 */
public func JPH_BodyInterface_UnassignBodyID_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_UnassignBodyID(bodyInterface, bodyID)
    }
}

// =============================================================================
// 刚体接口（BodyInterface）：激活 / 查询
// =============================================================================

/**
 * @brief 激活刚体（对应 JPH_BodyInterface_ActivateBody）
 */
public func JPH_BodyInterface_ActivateBody_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)
    }
}

/**
 * @brief 休眠刚体（对应 JPH_BodyInterface_DeactivateBody）
 */
public func JPH_BodyInterface_DeactivateBody_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_DeactivateBody(bodyInterface, bodyID)
    }
}

/**
 * @brief 批量激活刚体（对应 JPH_BodyInterface_ActivateBodies）
 */
public func JPH_BodyInterface_ActivateBodies_cj(
    bodyInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_ActivateBodies(bodyInterface, bodyIDs, count)
    }
}

/**
 * @brief 批量休眠刚体（对应 JPH_BodyInterface_DeactivateBodies）
 */
public func JPH_BodyInterface_DeactivateBodies_cj(
    bodyInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_DeactivateBodies(bodyInterface, bodyIDs, count)
    }
}

/**
 * @brief 激活 AABB 范围内、指定层的刚体（对应 JPH_BodyInterface_ActivateBodiesInAABox）
 */
public func JPH_BodyInterface_ActivateBodiesInAABox_cj(
    bodyInterface: CPointer<Unit>, box: CPointer<JPHAABox>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_BodyInterface_ActivateBodiesInAABox(bodyInterface, box, broadPhaseLayerFilter, objectLayerFilter)
    }
}

/**
 * @brief 重置刚体休眠计时器（对应 JPH_BodyInterface_ResetSleepTimer）
 */
public func JPH_BodyInterface_ResetSleepTimer_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_ResetSleepTimer(bodyInterface, bodyID)
    }
}

/**
 * @brief 刚体是否已加入世界（对应 JPH_BodyInterface_IsAdded）
 */
public func JPH_BodyInterface_IsAdded_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8 {
    unsafe {
        JPH_BodyInterface_IsAdded(bodyInterface, bodyID)
    }
}

/**
 * @brief 获取刚体类型（对应 JPH_BodyInterface_GetBodyType）
 */
public func JPH_BodyInterface_GetBodyType_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt32 {
    unsafe {
        JPH_BodyInterface_GetBodyType(bodyInterface, bodyID)
    }
}

/**
 * @brief 获取刚体形状句柄（对应 JPH_BodyInterface_GetShape）
 */
public func JPH_BodyInterface_GetShape_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_GetShape(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置刚体形状（对应 JPH_BodyInterface_SetShape）
 */
public func JPH_BodyInterface_SetShape_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, shape: CPointer<Unit>,
    updateMassProperties: UInt8, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetShape(bodyInterface, bodyID, shape, updateMassProperties, activationMode)
    }
}

/**
 * @brief 通知形状已改变（对应 JPH_BodyInterface_NotifyShapeChanged）
 */
public func JPH_BodyInterface_NotifyShapeChanged_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, previousCenterOfMass: CPointer<JPHVec3>,
    updateMassProperties: UInt8, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_NotifyShapeChanged(
            bodyInterface, bodyID, previousCenterOfMass, updateMassProperties, activationMode)
    }
}

/**
 * @brief 获取刚体材质句柄（对应 JPH_BodyInterface_GetMaterial）
 */
public func JPH_BodyInterface_GetMaterial_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, subShapeID: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_GetMaterial(bodyInterface, bodyID, subShapeID)
    }
}

/**
 * @brief 获取质心变换矩阵（对应 JPH_BodyInterface_GetCenterOfMassTransform）
 */
public func JPH_BodyInterface_GetCenterOfMassTransform_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_BodyInterface_GetCenterOfMassTransform(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 获取世界变换矩阵（对应 JPH_BodyInterface_GetWorldTransform）
 */
public func JPH_BodyInterface_GetWorldTransform_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_BodyInterface_GetWorldTransform(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 获取位置与旋转（对应 JPH_BodyInterface_GetPositionAndRotation）
 */
public func JPH_BodyInterface_GetPositionAndRotation_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    outPosition: CPointer<JPHVec3>, outRotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_BodyInterface_GetPositionAndRotation(bodyInterface, bodyID, outPosition, outRotation)
    }
}

/**
 * @brief 设置位置与旋转（对应 JPH_BodyInterface_SetPositionAndRotation）
 */
public func JPH_BodyInterface_SetPositionAndRotation_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetPositionAndRotation(bodyInterface, bodyID, position, rotation, activationMode)
    }
}

/**
 * @brief 仅当位置/旋转变化时设置（对应 JPH_BodyInterface_SetPositionAndRotationWhenChanged）
 */
public func JPH_BodyInterface_SetPositionAndRotationWhenChanged_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>, activationMode: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetPositionAndRotationWhenChanged(
            bodyInterface, bodyID, position, rotation, activationMode)
    }
}

/**
 * @brief 设置位置、旋转与速度（对应 JPH_BodyInterface_SetPositionRotationAndVelocity）
 */
public func JPH_BodyInterface_SetPositionRotationAndVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    position: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_SetPositionRotationAndVelocity(
            bodyInterface, bodyID, position, rotation,
            linearVelocity, angularVelocity)
    }
}

// =============================================================================
// 刚体接口（BodyInterface）：力 / 力矩 / 冲量
// =============================================================================

/**
 * @brief 在质心施加力（对应 JPH_BodyInterface_AddForce）
 */
public func JPH_BodyInterface_AddForce_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, force: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddForce(bodyInterface, bodyID, force)
    }
}

/**
 * @brief 在指定点施加力（对应 JPH_BodyInterface_AddForce2）
 */
public func JPH_BodyInterface_AddForce2_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    force: CPointer<JPHVec3>, point: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddForce2(bodyInterface, bodyID, force, point)
    }
}

/**
 * @brief 施加力矩（对应 JPH_BodyInterface_AddTorque）
 */
public func JPH_BodyInterface_AddTorque_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, torque: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddTorque(bodyInterface, bodyID, torque)
    }
}

/**
 * @brief 同时施加力与力矩（对应 JPH_BodyInterface_AddForceAndTorque）
 */
public func JPH_BodyInterface_AddForceAndTorque_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    force: CPointer<JPHVec3>, torque: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddForceAndTorque(bodyInterface, bodyID, force, torque)
    }
}

/**
 * @brief 在质心施加冲量（对应 JPH_BodyInterface_AddImpulse）
 */
public func JPH_BodyInterface_AddImpulse_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, impulse: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddImpulse(bodyInterface, bodyID, impulse)
    }
}

/**
 * @brief 在指定点施加冲量（对应 JPH_BodyInterface_AddImpulse2）
 */
public func JPH_BodyInterface_AddImpulse2_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    impulse: CPointer<JPHVec3>, point: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddImpulse2(bodyInterface, bodyID, impulse, point)
    }
}

/**
 * @brief 施加角冲量（对应 JPH_BodyInterface_AddAngularImpulse）
 */
public func JPH_BodyInterface_AddAngularImpulse_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, angularImpulse: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddAngularImpulse(bodyInterface, bodyID, angularImpulse)
    }
}

/**
 * @brief 增加线速度（对应 JPH_BodyInterface_AddLinearVelocity）
 */
public func JPH_BodyInterface_AddLinearVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, linearVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddLinearVelocity(bodyInterface, bodyID, linearVelocity)
    }
}

/**
 * @brief 同时增加线速度与角速度（对应 JPH_BodyInterface_AddLinearAndAngularVelocity）
 */
public func JPH_BodyInterface_AddLinearAndAngularVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_AddLinearAndAngularVelocity(bodyInterface, bodyID, linearVelocity, angularVelocity)
    }
}

/**
 * @brief 获取线速度与角速度（对应 JPH_BodyInterface_GetLinearAndAngularVelocity）
 */
public func JPH_BodyInterface_GetLinearAndAngularVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    outLinearVelocity: CPointer<JPHVec3>, outAngularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetLinearAndAngularVelocity(bodyInterface, bodyID, outLinearVelocity, outAngularVelocity)
    }
}

/**
 * @brief 设置线速度与角速度（对应 JPH_BodyInterface_SetLinearAndAngularVelocity）
 */
public func JPH_BodyInterface_SetLinearAndAngularVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    linearVelocity: CPointer<JPHVec3>, angularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_SetLinearAndAngularVelocity(bodyInterface, bodyID, linearVelocity, angularVelocity)
    }
}

/**
 * @brief 获取刚体上指定点的速度（对应 JPH_BodyInterface_GetPointVelocity）
 */
public func JPH_BodyInterface_GetPointVelocity_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_BodyInterface_GetPointVelocity(bodyInterface, bodyID, point, result)
    }
}

/**
 * @brief 应用浮力冲量（对应 JPH_BodyInterface_ApplyBuoyancyImpulse）
 */
public func JPH_BodyInterface_ApplyBuoyancyImpulse_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    surfacePosition: CPointer<JPHVec3>, surfaceNormal: CPointer<JPHVec3>,
    buoyancy: Float32, linearDrag: Float32, angularDrag: Float32,
    fluidVelocity: CPointer<JPHVec3>, gravity: CPointer<JPHVec3>, deltaTime: Float32
): UInt8 {
    unsafe {
        JPH_BodyInterface_ApplyBuoyancyImpulse(
            bodyInterface, bodyID, surfacePosition, surfaceNormal,
            buoyancy, linearDrag, angularDrag, fluidVelocity, gravity, deltaTime)
    }
}

/**
 * @brief 获取运动质量（对应 JPH_BodyInterface_GetMotionQuality）
 */
public func JPH_BodyInterface_GetMotionQuality_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt32 {
    unsafe {
        JPH_BodyInterface_GetMotionQuality(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置运动质量（对应 JPH_BodyInterface_SetMotionQuality）
 */
public func JPH_BodyInterface_SetMotionQuality_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_SetMotionQuality(bodyInterface, bodyID, value)
    }
}

/**
 * @brief 是否传感器（对应 JPH_BodyInterface_IsSensor）
 */
public func JPH_BodyInterface_IsSensor_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8 {
    unsafe {
        JPH_BodyInterface_IsSensor(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置是否传感器（对应 JPH_BodyInterface_SetIsSensor）
 */
public func JPH_BodyInterface_SetIsSensor_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, isSensor: UInt8
): Unit {
    unsafe {
        JPH_BodyInterface_SetIsSensor(bodyInterface, bodyID, isSensor)
    }
}

/**
 * @brief 获取碰撞组（对应 JPH_BodyInterface_GetCollisionGroup）
 */
public func JPH_BodyInterface_GetCollisionGroup_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_BodyInterface_GetCollisionGroup(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 设置碰撞组（对应 JPH_BodyInterface_SetCollisionGroup）
 */
public func JPH_BodyInterface_SetCollisionGroup_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_BodyInterface_SetCollisionGroup(bodyInterface, bodyID, value)
    }
}

/**
 * @brief 获取用户数据（对应 JPH_BodyInterface_GetUserData）
 */
public func JPH_BodyInterface_GetUserData_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt64 {
    unsafe {
        JPH_BodyInterface_GetUserData(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置用户数据（对应 JPH_BodyInterface_SetUserData）
 */
public func JPH_BodyInterface_SetUserData_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, userData: UInt64
): Unit {
    unsafe {
        JPH_BodyInterface_SetUserData(bodyInterface, bodyID, userData)
    }
}

/**
 * @brief 获取重力因子（对应 JPH_BodyInterface_GetGravityFactor）
 */
public func JPH_BodyInterface_GetGravityFactor_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Float32 {
    unsafe {
        JPH_BodyInterface_GetGravityFactor(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置重力因子（对应 JPH_BodyInterface_SetGravityFactor）
 */
public func JPH_BodyInterface_SetGravityFactor_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, gravityFactor: Float32
): Unit {
    unsafe {
        JPH_BodyInterface_SetGravityFactor(bodyInterface, bodyID, gravityFactor)
    }
}

/**
 * @brief 获取是否使用流形简化（对应 JPH_BodyInterface_GetUseManifoldReduction）
 */
public func JPH_BodyInterface_GetUseManifoldReduction_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): UInt8 {
    unsafe {
        JPH_BodyInterface_GetUseManifoldReduction(bodyInterface, bodyID)
    }
}

/**
 * @brief 设置是否使用流形简化（对应 JPH_BodyInterface_SetUseManifoldReduction）
 */
public func JPH_BodyInterface_SetUseManifoldReduction_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, value: UInt8
): Unit {
    unsafe {
        JPH_BodyInterface_SetUseManifoldReduction(bodyInterface, bodyID, value)
    }
}

/**
 * @brief 获取逆惯量（对应 JPH_BodyInterface_GetInverseInertia）
 */
public func JPH_BodyInterface_GetInverseInertia_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_BodyInterface_GetInverseInertia(bodyInterface, bodyID, result)
    }
}

/**
 * @brief 运动学刚体移动到指定位置/旋转（对应 JPH_BodyInterface_MoveKinematic）
 */
public func JPH_BodyInterface_MoveKinematic_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32,
    targetPosition: CPointer<JPHVec3>, targetRotation: CPointer<JPHQuat>, deltaTime: Float32
): Unit {
    unsafe {
        JPH_BodyInterface_MoveKinematic(bodyInterface, bodyID, targetPosition, targetRotation, deltaTime)
    }
}

/**
 * @brief 使接触缓存失效（对应 JPH_BodyInterface_InvalidateContactCache）
 */
public func JPH_BodyInterface_InvalidateContactCache_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32
): Unit {
    unsafe {
        JPH_BodyInterface_InvalidateContactCache(bodyInterface, bodyID)
    }
}

// =============================================================================
// 刚体接口（BodyInterface）：软体
// =============================================================================

/**
 * @brief 创建软体（不加入世界，对应 JPH_BodyInterface_CreateSoftBody）
 */
public func JPH_BodyInterface_CreateSoftBody_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateSoftBody(bodyInterface, settings)
    }
}

/**
 * @brief 创建软体并分配指定 ID（对应 JPH_BodyInterface_CreateSoftBodyWithID）
 */
public func JPH_BodyInterface_CreateSoftBodyWithID_cj(
    bodyInterface: CPointer<Unit>, bodyID: UInt32, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateSoftBodyWithID(bodyInterface, bodyID, settings)
    }
}

/**
 * @brief 创建软体（无 ID 版本，对应 JPH_BodyInterface_CreateSoftBodyWithoutID）
 */
public func JPH_BodyInterface_CreateSoftBodyWithoutID_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_BodyInterface_CreateSoftBodyWithoutID(bodyInterface, settings)
    }
}

/**
 * @brief 创建并添加软体到世界（对应 JPH_BodyInterface_CreateAndAddSoftBody）
 */
public func JPH_BodyInterface_CreateAndAddSoftBody_cj(
    bodyInterface: CPointer<Unit>, settings: CPointer<Unit>, activationMode: UInt32
): UInt32 {
    unsafe {
        JPH_BodyInterface_CreateAndAddSoftBody(bodyInterface, settings, activationMode)
    }
}

// =============================================================================
// 刚体锁接口（BodyLockInterface）
// =============================================================================

/**
 * @brief 获取刚体只读锁（对应 JPH_BodyLockInterface_LockRead）
 */
public func JPH_BodyLockInterface_LockRead_cj(
    lockInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHBodyLockRead>
): Unit {
    unsafe {
        JPH_BodyLockInterface_LockRead(lockInterface, bodyID, result)
    }
}

/**
 * @brief 获取刚体写锁（对应 JPH_BodyLockInterface_LockWrite）
 */
public func JPH_BodyLockInterface_LockWrite_cj(
    lockInterface: CPointer<Unit>, bodyID: UInt32, result: CPointer<JPHBodyLockWrite>
): Unit {
    unsafe {
        JPH_BodyLockInterface_LockWrite(lockInterface, bodyID, result)
    }
}

/**
 * @brief 批量获取只读锁（对应 JPH_BodyLockInterface_LockMultiRead）
 */
public func JPH_BodyLockInterface_LockMultiRead_cj(
    lockInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyLockInterface_LockMultiRead(lockInterface, bodyIDs, count)
    }
}

/**
 * @brief 批量获取写锁（对应 JPH_BodyLockInterface_LockMultiWrite）
 */
public func JPH_BodyLockInterface_LockMultiWrite_cj(
    lockInterface: CPointer<Unit>, bodyIDs: CPointer<UInt32>, count: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyLockInterface_LockMultiWrite(lockInterface, bodyIDs, count)
    }
}

/**
 * @brief 释放只读锁（对应 JPH_BodyLockInterface_UnlockRead）
 */
public func JPH_BodyLockInterface_UnlockRead_cj(
    lockInterface: CPointer<Unit>, ioLock: CPointer<Unit>
): Unit {
    unsafe {
        JPH_BodyLockInterface_UnlockRead(lockInterface, ioLock)
    }
}

/**
 * @brief 释放写锁（对应 JPH_BodyLockInterface_UnlockWrite）
 */
public func JPH_BodyLockInterface_UnlockWrite_cj(
    lockInterface: CPointer<Unit>, ioLock: CPointer<Unit>
): Unit {
    unsafe {
        JPH_BodyLockInterface_UnlockWrite(lockInterface, ioLock)
    }
}

/**
 * @brief 销毁批量只读锁（对应 JPH_BodyLockMultiRead_Destroy）
 */
public func JPH_BodyLockMultiRead_Destroy_cj(multiLock: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyLockMultiRead_Destroy(multiLock)
    }
}

/**
 * @brief 获取批量只读锁中的刚体（对应 JPH_BodyLockMultiRead_GetBody）
 */
public func JPH_BodyLockMultiRead_GetBody_cj(
    multiLock: CPointer<Unit>, bodyIndex: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyLockMultiRead_GetBody(multiLock, bodyIndex)
    }
}

/**
 * @brief 销毁批量写锁（对应 JPH_BodyLockMultiWrite_Destroy）
 */
public func JPH_BodyLockMultiWrite_Destroy_cj(multiLock: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyLockMultiWrite_Destroy(multiLock)
    }
}

/**
 * @brief 获取批量写锁中的刚体（对应 JPH_BodyLockMultiWrite_GetBody）
 */
public func JPH_BodyLockMultiWrite_GetBody_cj(
    multiLock: CPointer<Unit>, bodyIndex: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_BodyLockMultiWrite_GetBody(multiLock, bodyIndex)
    }
}

// =============================================================================
// 刚体直接操作（Body，从 BodyLock 获取后操作）
// =============================================================================

/**
 * @brief 获取刚体 ID（对应 JPH_Body_GetID）
 */
public func JPH_Body_GetID_cj(body: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Body_GetID(body)
    }
}

/**
 * @brief 获取刚体类型（对应 JPH_Body_GetBodyType）
 */
public func JPH_Body_GetBodyType_cj(body: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Body_GetBodyType(body)
    }
}

/**
 * @brief 获取刚体形状句柄（对应 JPH_Body_GetShape）
 */
public func JPH_Body_GetShape_cj(body: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Body_GetShape(body)
    }
}

/**
 * @brief 获取刚体位置（对应 JPH_Body_GetPosition）
 */
public func JPH_Body_GetPosition_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetPosition(body, result)
    }
}

/**
 * @brief 获取刚体旋转（对应 JPH_Body_GetRotation）
 */
public func JPH_Body_GetRotation_cj(body: CPointer<Unit>, result: CPointer<JPHQuat>): Unit {
    unsafe {
        JPH_Body_GetRotation(body, result)
    }
}

/**
 * @brief 获取质心位置（对应 JPH_Body_GetCenterOfMassPosition）
 */
public func JPH_Body_GetCenterOfMassPosition_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetCenterOfMassPosition(body, result)
    }
}

/**
 * @brief 获取世界变换矩阵（对应 JPH_Body_GetWorldTransform）
 */
public func JPH_Body_GetWorldTransform_cj(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Body_GetWorldTransform(body, result)
    }
}

/**
 * @brief 获取质心变换矩阵（对应 JPH_Body_GetCenterOfMassTransform）
 */
public func JPH_Body_GetCenterOfMassTransform_cj(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Body_GetCenterOfMassTransform(body, result)
    }
}

/**
 * @brief 获取逆质心变换矩阵（对应 JPH_Body_GetInverseCenterOfMassTransform）
 */
public func JPH_Body_GetInverseCenterOfMassTransform_cj(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Body_GetInverseCenterOfMassTransform(body, result)
    }
}

/**
 * @brief 获取线速度（对应 JPH_Body_GetLinearVelocity）
 */
public func JPH_Body_GetLinearVelocity_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetLinearVelocity(body, result)
    }
}

/**
 * @brief 设置线速度（对应 JPH_Body_SetLinearVelocity）
 */
public func JPH_Body_SetLinearVelocity_cj(body: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_SetLinearVelocity(body, velocity)
    }
}

/**
 * @brief 获取角速度（对应 JPH_Body_GetAngularVelocity）
 */
public func JPH_Body_GetAngularVelocity_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetAngularVelocity(body, result)
    }
}

/**
 * @brief 设置角速度（对应 JPH_Body_SetAngularVelocity）
 */
public func JPH_Body_SetAngularVelocity_cj(body: CPointer<Unit>, angularVelocity: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_SetAngularVelocity(body, angularVelocity)
    }
}

/**
 * @brief 获取指定点的速度（对应 JPH_Body_GetPointVelocity）
 */
public func JPH_Body_GetPointVelocity_cj(
    body: CPointer<Unit>, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_GetPointVelocity(body, point, result)
    }
}

/**
 * @brief 获取质心点速度（对应 JPH_Body_GetPointVelocityCOM）
 */
public func JPH_Body_GetPointVelocityCOM_cj(
    body: CPointer<Unit>, point: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_GetPointVelocityCOM(body, point, result)
    }
}

/**
 * @brief 获取累积力（对应 JPH_Body_GetAccumulatedForce）
 */
public func JPH_Body_GetAccumulatedForce_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetAccumulatedForce(body, result)
    }
}

/**
 * @brief 获取累积力矩（对应 JPH_Body_GetAccumulatedTorque）
 */
public func JPH_Body_GetAccumulatedTorque_cj(body: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_GetAccumulatedTorque(body, result)
    }
}

/**
 * @brief 施加力（质心，对应 JPH_Body_AddForce）
 */
public func JPH_Body_AddForce_cj(body: CPointer<Unit>, force: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_AddForce(body, force)
    }
}

/**
 * @brief 在指定位置施加力（对应 JPH_Body_AddForceAtPosition）
 */
public func JPH_Body_AddForceAtPosition_cj(
    body: CPointer<Unit>, force: CPointer<JPHVec3>, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_AddForceAtPosition(body, force, position)
    }
}

/**
 * @brief 施加力矩（对应 JPH_Body_AddTorque）
 */
public func JPH_Body_AddTorque_cj(body: CPointer<Unit>, torque: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_AddTorque(body, torque)
    }
}

/**
 * @brief 施加冲量（质心，对应 JPH_Body_AddImpulse）
 */
public func JPH_Body_AddImpulse_cj(body: CPointer<Unit>, impulse: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_AddImpulse(body, impulse)
    }
}

/**
 * @brief 在指定位置施加冲量（对应 JPH_Body_AddImpulseAtPosition）
 */
public func JPH_Body_AddImpulseAtPosition_cj(
    body: CPointer<Unit>, impulse: CPointer<JPHVec3>, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_AddImpulseAtPosition(body, impulse, position)
    }
}

/**
 * @brief 施加角冲量（对应 JPH_Body_AddAngularImpulse）
 */
public func JPH_Body_AddAngularImpulse_cj(body: CPointer<Unit>, angularImpulse: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Body_AddAngularImpulse(body, angularImpulse)
    }
}

/**
 * @brief 应用浮力冲量（对应 JPH_Body_ApplyBuoyancyImpulse）
 */
public func JPH_Body_ApplyBuoyancyImpulse_cj(
    body: CPointer<Unit>, surfacePosition: CPointer<JPHVec3>, surfaceNormal: CPointer<JPHVec3>,
    buoyancy: Float32, linearDrag: Float32, angularDrag: Float32,
    fluidVelocity: CPointer<JPHVec3>, gravity: CPointer<JPHVec3>, deltaTime: Float32
): UInt8 {
    unsafe {
        JPH_Body_ApplyBuoyancyImpulse(
            body, surfacePosition, surfaceNormal,
            buoyancy, linearDrag, angularDrag, fluidVelocity, gravity, deltaTime)
    }
}

/**
 * @brief 重置累积力（对应 JPH_Body_ResetForce）
 */
public func JPH_Body_ResetForce_cj(body: CPointer<Unit>): Unit {
    unsafe {
        JPH_Body_ResetForce(body)
    }
}

/**
 * @brief 重置累积力矩（对应 JPH_Body_ResetTorque）
 */
public func JPH_Body_ResetTorque_cj(body: CPointer<Unit>): Unit {
    unsafe {
        JPH_Body_ResetTorque(body)
    }
}

/**
 * @brief 重置运动（速度归零，对应 JPH_Body_ResetMotion）
 */
public func JPH_Body_ResetMotion_cj(body: CPointer<Unit>): Unit {
    unsafe {
        JPH_Body_ResetMotion(body)
    }
}

/**
 * @brief 获取摩擦系数（对应 JPH_Body_GetFriction）
 */
public func JPH_Body_GetFriction_cj(body: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Body_GetFriction(body)
    }
}

/**
 * @brief 设置摩擦系数（对应 JPH_Body_SetFriction）
 */
public func JPH_Body_SetFriction_cj(body: CPointer<Unit>, friction: Float32): Unit {
    unsafe {
        JPH_Body_SetFriction(body, friction)
    }
}

/**
 * @brief 获取弹性系数（对应 JPH_Body_GetRestitution）
 */
public func JPH_Body_GetRestitution_cj(body: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Body_GetRestitution(body)
    }
}

/**
 * @brief 设置弹性系数（对应 JPH_Body_SetRestitution）
 */
public func JPH_Body_SetRestitution_cj(body: CPointer<Unit>, restitution: Float32): Unit {
    unsafe {
        JPH_Body_SetRestitution(body, restitution)
    }
}

/**
 * @brief 获取运动类型（对应 JPH_Body_GetMotionType）
 */
public func JPH_Body_GetMotionType_cj(body: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Body_GetMotionType(body)
    }
}

/**
 * @brief 设置运动类型（对应 JPH_Body_SetMotionType）
 */
public func JPH_Body_SetMotionType_cj(body: CPointer<Unit>, motionType: UInt32): Unit {
    unsafe {
        JPH_Body_SetMotionType(body, motionType)
    }
}

/**
 * @brief 刚体是否活动（对应 JPH_Body_IsActive）
 */
public func JPH_Body_IsActive_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsActive(body)
    }
}

/**
 * @brief 刚体是否静态（对应 JPH_Body_IsStatic）
 */
public func JPH_Body_IsStatic_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsStatic(body)
    }
}

/**
 * @brief 刚体是否运动学（对应 JPH_Body_IsKinematic）
 */
public func JPH_Body_IsKinematic_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsKinematic(body)
    }
}

/**
 * @brief 刚体是否动态（对应 JPH_Body_IsDynamic）
 */
public func JPH_Body_IsDynamic_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsDynamic(body)
    }
}

/**
 * @brief 刚体是否刚体类型（对应 JPH_Body_IsRigidBody）
 */
public func JPH_Body_IsRigidBody_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsRigidBody(body)
    }
}

/**
 * @brief 刚体是否软体（对应 JPH_Body_IsSoftBody）
 */
public func JPH_Body_IsSoftBody_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsSoftBody(body)
    }
}

/**
 * @brief 刚体是否传感器（对应 JPH_Body_IsSensor）
 */
public func JPH_Body_IsSensor_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsSensor(body)
    }
}

/**
 * @brief 设置刚体是否传感器（对应 JPH_Body_SetIsSensor）
 */
public func JPH_Body_SetIsSensor_cj(body: CPointer<Unit>, isSensor: UInt8): Unit {
    unsafe {
        JPH_Body_SetIsSensor(body, isSensor)
    }
}

/**
 * @brief 获取用户数据（对应 JPH_Body_GetUserData）
 */
public func JPH_Body_GetUserData_cj(body: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_Body_GetUserData(body)
    }
}

/**
 * @brief 设置用户数据（对应 JPH_Body_SetUserData）
 */
public func JPH_Body_SetUserData_cj(body: CPointer<Unit>, userData: UInt64): Unit {
    unsafe {
        JPH_Body_SetUserData(body, userData)
    }
}

/**
 * @brief 获取对象层（对应 JPH_Body_GetObjectLayer）
 */
public func JPH_Body_GetObjectLayer_cj(body: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Body_GetObjectLayer(body)
    }
}

/**
 * @brief 获取 BroadPhase 层（对应 JPH_Body_GetBroadPhaseLayer）
 */
public func JPH_Body_GetBroadPhaseLayer_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetBroadPhaseLayer(body)
    }
}

/**
 * @brief 获取碰撞组（对应 JPH_Body_GetCollisionGroup）
 */
public func JPH_Body_GetCollisionGroup_cj(body: CPointer<Unit>, result: CPointer<JPHCollisionGroup>): Unit {
    unsafe {
        JPH_Body_GetCollisionGroup(body, result)
    }
}

/**
 * @brief 设置碰撞组（对应 JPH_Body_SetCollisionGroup）
 */
public func JPH_Body_SetCollisionGroup_cj(body: CPointer<Unit>, value: CPointer<JPHCollisionGroup>): Unit {
    unsafe {
        JPH_Body_SetCollisionGroup(body, value)
    }
}

/**
 * @brief 运动学移动到指定位置/旋转（对应 JPH_Body_MoveKinematic）
 */
public func JPH_Body_MoveKinematic_cj(
    body: CPointer<Unit>, targetPosition: CPointer<JPHVec3>,
    targetRotation: CPointer<JPHQuat>, deltaTime: Float32
): Unit {
    unsafe {
        JPH_Body_MoveKinematic(body, targetPosition, targetRotation, deltaTime)
    }
}

/**
 * @brief 重置休眠计时器（对应 JPH_Body_ResetSleepTimer）
 */
public func JPH_Body_ResetSleepTimer_cj(body: CPointer<Unit>): Unit {
    unsafe {
        JPH_Body_ResetSleepTimer(body)
    }
}

/**
 * @brief 获取世界空间包围盒（对应 JPH_Body_GetWorldSpaceBounds）
 */
public func JPH_Body_GetWorldSpaceBounds_cj(body: CPointer<Unit>, result: CPointer<JPHAABox>): Unit {
    unsafe {
        JPH_Body_GetWorldSpaceBounds(body, result)
    }
}

/**
 * @brief 获取世界空间表面法线（对应 JPH_Body_GetWorldSpaceSurfaceNormal）
 */
public func JPH_Body_GetWorldSpaceSurfaceNormal_cj(
    body: CPointer<Unit>, subShapeID: UInt32, worldPosition: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_GetWorldSpaceSurfaceNormal(body, subShapeID, worldPosition, result)
    }
}

/**
 * @brief 获取运动属性句柄（对应 JPH_Body_GetMotionProperties）
 */
public func JPH_Body_GetMotionProperties_cj(body: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Body_GetMotionProperties(body)
    }
}

/**
 * @brief 获取运动属性句柄（未检查版本，对应 JPH_Body_GetMotionPropertiesUnchecked）
 */
public func JPH_Body_GetMotionPropertiesUnchecked_cj(body: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Body_GetMotionPropertiesUnchecked(body)
    }
}

/**
 * @brief 获取逆惯量（对应 JPH_Body_GetInverseInertia）
 */
public func JPH_Body_GetInverseInertia_cj(body: CPointer<Unit>, result: CPointer<JPHMat4>): Unit {
    unsafe {
        JPH_Body_GetInverseInertia(body, result)
    }
}

/**
 * @brief 获取是否允许休眠（对应 JPH_Body_GetAllowSleeping）
 */
public func JPH_Body_GetAllowSleeping_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetAllowSleeping(body)
    }
}

/**
 * @brief 设置是否允许休眠（对应 JPH_Body_SetAllowSleeping）
 */
public func JPH_Body_SetAllowSleeping_cj(body: CPointer<Unit>, allowSleeping: UInt8): Unit {
    unsafe {
        JPH_Body_SetAllowSleeping(body, allowSleeping)
    }
}

/**
 * @brief 获取是否应用陀螺力（对应 JPH_Body_GetApplyGyroscopicForce）
 */
public func JPH_Body_GetApplyGyroscopicForce_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetApplyGyroscopicForce(body)
    }
}

/**
 * @brief 设置是否应用陀螺力（对应 JPH_Body_SetApplyGyroscopicForce）
 */
public func JPH_Body_SetApplyGyroscopicForce_cj(body: CPointer<Unit>, applyGyroscopicForce: UInt8): Unit {
    unsafe {
        JPH_Body_SetApplyGyroscopicForce(body, applyGyroscopicForce)
    }
}

/**
 * @brief 获取运动学 vs 非动态碰撞（对应 JPH_Body_GetCollideKinematicVsNonDynamic）
 */
public func JPH_Body_GetCollideKinematicVsNonDynamic_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetCollideKinematicVsNonDynamic(body)
    }
}

/**
 * @brief 设置运动学 vs 非动态碰撞（对应 JPH_Body_SetCollideKinematicVsNonDynamic）
 */
public func JPH_Body_SetCollideKinematicVsNonDynamic_cj(body: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_Body_SetCollideKinematicVsNonDynamic(body, value)
    }
}

/**
 * @brief 获取增强内部边移除（对应 JPH_Body_GetEnhancedInternalEdgeRemoval）
 */
public func JPH_Body_GetEnhancedInternalEdgeRemoval_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetEnhancedInternalEdgeRemoval(body)
    }
}

/**
 * @brief 设置增强内部边移除（对应 JPH_Body_SetEnhancedInternalEdgeRemoval）
 */
public func JPH_Body_SetEnhancedInternalEdgeRemoval_cj(body: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_Body_SetEnhancedInternalEdgeRemoval(body, value)
    }
}

/**
 * @brief 获取使用流形简化（对应 JPH_Body_GetUseManifoldReduction）
 */
public func JPH_Body_GetUseManifoldReduction_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_GetUseManifoldReduction(body)
    }
}

/**
 * @brief 设置使用流形简化（对应 JPH_Body_SetUseManifoldReduction）
 */
public func JPH_Body_SetUseManifoldReduction_cj(body: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_Body_SetUseManifoldReduction(body, value)
    }
}

/**
 * @brief 接触缓存是否失效（对应 JPH_Body_IsCollisionCacheInvalid）
 */
public func JPH_Body_IsCollisionCacheInvalid_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsCollisionCacheInvalid(body)
    }
}

/**
 * @brief 是否可切换运动学/动态（对应 JPH_Body_CanBeKinematicOrDynamic）
 */
public func JPH_Body_CanBeKinematicOrDynamic_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_CanBeKinematicOrDynamic(body)
    }
}

/**
 * @brief 获取固定到世界的刚体（对应 JPH_Body_GetFixedToWorldBody）
 */
public func JPH_Body_GetFixedToWorldBody_cj(): CPointer<Unit> {
    unsafe {
        JPH_Body_GetFixedToWorldBody()
    }
}

/**
 * @brief 获取软体顶点数量（对应 JPH_Body_GetSoftBodyVertexCount）
 */
public func JPH_Body_GetSoftBodyVertexCount_cj(body: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Body_GetSoftBodyVertexCount(body)
    }
}

/**
 * @brief 获取软体顶点位置（对应 JPH_Body_GetSoftBodyVertexPosition）
 */
public func JPH_Body_GetSoftBodyVertexPosition_cj(
    body: CPointer<Unit>, vertexIndex: UInt32, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_GetSoftBodyVertexPosition(body, vertexIndex, position)
    }
}

/**
 * @brief 批量获取软体顶点位置（对应 JPH_Body_GetSoftBodyVertexPositions）
 */
public func JPH_Body_GetSoftBodyVertexPositions_cj(
    body: CPointer<Unit>, outPositions: CPointer<JPHVec3>, capacity: UInt32, outCount: CPointer<UInt32>
): Unit {
    unsafe {
        JPH_Body_GetSoftBodyVertexPositions(body, outPositions, capacity, outCount)
    }
}

// =============================================================================
// 补充：Body 附加方法
// =============================================================================

/**
 * @brief 判断两刚体是否使用流形简化（对应 JPH_Body_GetUseManifoldReductionWithBody）
 */
public func JPH_Body_GetUseManifoldReductionWithBody_cj(
    body: CPointer<Unit>, other: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_Body_GetUseManifoldReductionWithBody(body, other)
    }
}

/**
 * @brief 判断两刚体是否启用增强内部边移除（对应 JPH_Body_GetEnhancedInternalEdgeRemovalWithBody）
 */
public func JPH_Body_GetEnhancedInternalEdgeRemovalWithBody_cj(
    body: CPointer<Unit>, other: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_Body_GetEnhancedInternalEdgeRemovalWithBody(body, other)
    }
}

/**
 * @brief 设置线速度（钳制到最大速度，对应 JPH_Body_SetLinearVelocityClamped）
 */
public func JPH_Body_SetLinearVelocityClamped_cj(
    body: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_SetLinearVelocityClamped(body, velocity)
    }
}

/**
 * @brief 设置角速度（钳制到最大速度，对应 JPH_Body_SetAngularVelocityClamped）
 */
public func JPH_Body_SetAngularVelocityClamped_cj(
    body: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Body_SetAngularVelocityClamped(body, velocity)
    }
}

/**
 * @brief 刚体是否已在宽相位中（对应 JPH_Body_IsInBroadPhase）
 */
public func JPH_Body_IsInBroadPhase_cj(body: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Body_IsInBroadPhase(body)
    }
}

// =============================================================================
// 过滤器 / 监听器（SetProcs + Create + Destroy）
// =============================================================================

/**
 * @brief 设置宽相位层过滤器回调表（对应 JPH_BroadPhaseLayerFilter_SetProcs）
 */
public func JPH_BroadPhaseLayerFilter_SetProcs_cj(procs: CPointer<JPHBroadPhaseLayerFilterProcs>): Unit {
    unsafe {
        JPH_BroadPhaseLayerFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建宽相位层过滤器实例（对应 JPH_BroadPhaseLayerFilter_Create）
 */
public func JPH_BroadPhaseLayerFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_BroadPhaseLayerFilter_Create(userData)
    }
}

/**
 * @brief 销毁宽相位层过滤器（对应 JPH_BroadPhaseLayerFilter_Destroy）
 */
public func JPH_BroadPhaseLayerFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_BroadPhaseLayerFilter_Destroy(filter)
    }
}

/**
 * @brief 设置对象层过滤器回调表（对应 JPH_ObjectLayerFilter_SetProcs）
 */
public func JPH_ObjectLayerFilter_SetProcs_cj(procs: CPointer<JPHObjectLayerFilterProcs>): Unit {
    unsafe {
        JPH_ObjectLayerFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建对象层过滤器实例（对应 JPH_ObjectLayerFilter_Create）
 */
public func JPH_ObjectLayerFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_ObjectLayerFilter_Create(userData)
    }
}

/**
 * @brief 销毁对象层过滤器（对应 JPH_ObjectLayerFilter_Destroy）
 */
public func JPH_ObjectLayerFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_ObjectLayerFilter_Destroy(filter)
    }
}

/**
 * @brief 设置刚体过滤器回调表（对应 JPH_BodyFilter_SetProcs）
 */
public func JPH_BodyFilter_SetProcs_cj(procs: CPointer<JPHBodyFilterProcs>): Unit {
    unsafe {
        JPH_BodyFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建刚体过滤器实例（对应 JPH_BodyFilter_Create）
 */
public func JPH_BodyFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_BodyFilter_Create(userData)
    }
}

/**
 * @brief 销毁刚体过滤器（对应 JPH_BodyFilter_Destroy）
 */
public func JPH_BodyFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyFilter_Destroy(filter)
    }
}

/**
 * @brief 设置形状过滤器回调表（对应 JPH_ShapeFilter_SetProcs）
 */
public func JPH_ShapeFilter_SetProcs_cj(procs: CPointer<JPHShapeFilterProcs>): Unit {
    unsafe {
        JPH_ShapeFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建形状过滤器实例（对应 JPH_ShapeFilter_Create）
 */
public func JPH_ShapeFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_ShapeFilter_Create(userData)
    }
}

/**
 * @brief 销毁形状过滤器（对应 JPH_ShapeFilter_Destroy）
 */
public func JPH_ShapeFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_ShapeFilter_Destroy(filter)
    }
}

/**
 * @brief 获取形状过滤器的 BodyID2（对应 JPH_ShapeFilter_GetBodyID2）
 */
public func JPH_ShapeFilter_GetBodyID2_cj(filter: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ShapeFilter_GetBodyID2(filter)
    }
}

/**
 * @brief 设置形状过滤器的 BodyID2（对应 JPH_ShapeFilter_SetBodyID2）
 */
public func JPH_ShapeFilter_SetBodyID2_cj(filter: CPointer<Unit>, id: UInt32): Unit {
    unsafe {
        JPH_ShapeFilter_SetBodyID2(filter, id)
    }
}

/**
 * @brief 设置模拟形状过滤器回调表（对应 JPH_SimShapeFilter_SetProcs）
 */
public func JPH_SimShapeFilter_SetProcs_cj(procs: CPointer<JPHSimShapeFilterProcs>): Unit {
    unsafe {
        JPH_SimShapeFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建模拟形状过滤器实例（对应 JPH_SimShapeFilter_Create）
 */
public func JPH_SimShapeFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_SimShapeFilter_Create(userData)
    }
}

/**
 * @brief 销毁模拟形状过滤器（对应 JPH_SimShapeFilter_Destroy）
 */
public func JPH_SimShapeFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_SimShapeFilter_Destroy(filter)
    }
}

/**
 * @brief 设置接触监听器回调表（对应 JPH_ContactListener_SetProcs）
 */
public func JPH_ContactListener_SetProcs_cj(procs: CPointer<JPHContactListenerProcs>): Unit {
    unsafe {
        JPH_ContactListener_SetProcs(procs)
    }
}

/**
 * @brief 创建接触监听器实例（对应 JPH_ContactListener_Create）
 */
public func JPH_ContactListener_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_ContactListener_Create(userData)
    }
}

/**
 * @brief 销毁接触监听器（对应 JPH_ContactListener_Destroy）
 */
public func JPH_ContactListener_Destroy_cj(listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_ContactListener_Destroy(listener)
    }
}

/**
 * @brief 设置刚体激活监听器回调表（对应 JPH_BodyActivationListener_SetProcs）
 */
public func JPH_BodyActivationListener_SetProcs_cj(procs: CPointer<JPHBodyActivationListenerProcs>): Unit {
    unsafe {
        JPH_BodyActivationListener_SetProcs(procs)
    }
}

/**
 * @brief 创建刚体激活监听器实例（对应 JPH_BodyActivationListener_Create）
 */
public func JPH_BodyActivationListener_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_BodyActivationListener_Create(userData)
    }
}

/**
 * @brief 销毁刚体激活监听器（对应 JPH_BodyActivationListener_Destroy）
 */
public func JPH_BodyActivationListener_Destroy_cj(listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyActivationListener_Destroy(listener)
    }
}

/**
 * @brief 设置刚体绘制过滤器回调表（对应 JPH_BodyDrawFilter_SetProcs）
 */
public func JPH_BodyDrawFilter_SetProcs_cj(procs: CPointer<JPHBodyDrawFilterProcs>): Unit {
    unsafe {
        JPH_BodyDrawFilter_SetProcs(procs)
    }
}

/**
 * @brief 创建刚体绘制过滤器实例（对应 JPH_BodyDrawFilter_Create）
 */
public func JPH_BodyDrawFilter_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_BodyDrawFilter_Create(userData)
    }
}

/**
 * @brief 销毁刚体绘制过滤器（对应 JPH_BodyDrawFilter_Destroy）
 */
public func JPH_BodyDrawFilter_Destroy_cj(filter: CPointer<Unit>): Unit {
    unsafe {
        JPH_BodyDrawFilter_Destroy(filter)
    }
}

/**
 * @brief 设置角色接触监听器回调表（对应 JPH_CharacterContactListener_SetProcs）
 */
public func JPH_CharacterContactListener_SetProcs_cj(procs: CPointer<JPHCharacterContactListenerProcs>): Unit {
    unsafe {
        JPH_CharacterContactListener_SetProcs(procs)
    }
}

/**
 * @brief 创建角色接触监听器实例（对应 JPH_CharacterContactListener_Create）
 */
public func JPH_CharacterContactListener_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CharacterContactListener_Create(userData)
    }
}

/**
 * @brief 销毁角色接触监听器（对应 JPH_CharacterContactListener_Destroy）
 */
public func JPH_CharacterContactListener_Destroy_cj(listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterContactListener_Destroy(listener)
    }
}

/**
 * @brief 设置角色间碰撞回调表（对应 JPH_CharacterVsCharacterCollision_SetProcs）
 */
public func JPH_CharacterVsCharacterCollision_SetProcs_cj(
    procs: CPointer<JPHCharacterVsCharacterCollisionProcs>
): Unit {
    unsafe {
        JPH_CharacterVsCharacterCollision_SetProcs(procs)
    }
}

/**
 * @brief 创建角色间碰撞处理实例（对应 JPH_CharacterVsCharacterCollision_Create）
 */
public func JPH_CharacterVsCharacterCollision_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CharacterVsCharacterCollision_Create(userData)
    }
}

/**
 * @brief 创建角色间碰撞处理（简单版，对应 JPH_CharacterVsCharacterCollision_CreateSimple）
 */
public func JPH_CharacterVsCharacterCollision_CreateSimple_cj(): CPointer<Unit> {
    unsafe {
        JPH_CharacterVsCharacterCollision_CreateSimple()
    }
}

/**
 * @brief 向简单角色间碰撞处理添加角色（对应 JPH_CharacterVsCharacterCollisionSimple_AddCharacter）
 */
public func JPH_CharacterVsCharacterCollisionSimple_AddCharacter_cj(
    characterVsCharacter: CPointer<Unit>, character: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVsCharacterCollisionSimple_AddCharacter(characterVsCharacter, character)
    }
}

/**
 * @brief 从简单角色间碰撞处理移除角色（对应 JPH_CharacterVsCharacterCollisionSimple_RemoveCharacter）
 */
public func JPH_CharacterVsCharacterCollisionSimple_RemoveCharacter_cj(
    characterVsCharacter: CPointer<Unit>, character: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVsCharacterCollisionSimple_RemoveCharacter(characterVsCharacter, character)
    }
}

/**
 * @brief 销毁角色间碰撞处理（对应 JPH_CharacterVsCharacterCollision_Destroy）
 */
public func JPH_CharacterVsCharacterCollision_Destroy_cj(listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterVsCharacterCollision_Destroy(listener)
    }
}

// =============================================================================
// 宽相位查询（BroadPhaseQuery）
// =============================================================================

/**
 * @brief 宽相位射线检测（对应 JPH_BroadPhaseQuery_CastRay）
 */
public func JPH_BroadPhaseQuery_CastRay_cj(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BroadPhaseQuery_CastRay(query, origin, direction, callback, userData, broadPhaseLayerFilter, objectLayerFilter)
    }
}

/**
 * @brief 宽相位射线检测（带收集器回调，对应 JPH_BroadPhaseQuery_CastRay2）
 */
public func JPH_BroadPhaseQuery_CastRay2_cj(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    collectorType: UInt32, callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BroadPhaseQuery_CastRay2(
            query, origin, direction, collectorType, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter)
    }
}

/**
 * @brief 宽相位 AABB 碰撞查询（对应 JPH_BroadPhaseQuery_CollideAABox）
 */
public func JPH_BroadPhaseQuery_CollideAABox_cj(
    query: CPointer<Unit>, box: CPointer<JPHAABox>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BroadPhaseQuery_CollideAABox(
            query, box, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter)
    }
}

/**
 * @brief 宽相位点碰撞查询（对应 JPH_BroadPhaseQuery_CollidePoint）
 */
public func JPH_BroadPhaseQuery_CollidePoint_cj(
    query: CPointer<Unit>, point: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BroadPhaseQuery_CollidePoint(
            query, point, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter)
    }
}

/**
 * @brief 宽相位球碰撞查询（对应 JPH_BroadPhaseQuery_CollideSphere）
 */
public func JPH_BroadPhaseQuery_CollideSphere_cj(
    query: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_BroadPhaseQuery_CollideSphere(
            query, center, radius, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter)
    }
}

// =============================================================================
// 角色基类（CharacterBase）
// =============================================================================

/**
 * @brief 销毁角色（对应 JPH_CharacterBase_Destroy）
 */
public func JPH_CharacterBase_Destroy_cj(character: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterBase_Destroy(character)
    }
}

/**
 * @brief 获取最大坡度角余弦值（对应 JPH_CharacterBase_GetCosMaxSlopeAngle）
 */
public func JPH_CharacterBase_GetCosMaxSlopeAngle_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterBase_GetCosMaxSlopeAngle(character)
    }
}

/**
 * @brief 设置最大坡度角（对应 JPH_CharacterBase_SetMaxSlopeAngle）
 */
public func JPH_CharacterBase_SetMaxSlopeAngle_cj(character: CPointer<Unit>, maxSlopeAngle: Float32): Unit {
    unsafe {
        JPH_CharacterBase_SetMaxSlopeAngle(character, maxSlopeAngle)
    }
}

/**
 * @brief 获取角色上方向（对应 JPH_CharacterBase_GetUp）
 */
public func JPH_CharacterBase_GetUp_cj(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterBase_GetUp(character, result)
    }
}

/**
 * @brief 设置角色上方向（对应 JPH_CharacterBase_SetUp）
 */
public func JPH_CharacterBase_SetUp_cj(character: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterBase_SetUp(character, value)
    }
}

/**
 * @brief 判断坡度是否过陡（对应 JPH_CharacterBase_IsSlopeTooSteep）
 */
public func JPH_CharacterBase_IsSlopeTooSteep_cj(character: CPointer<Unit>, value: CPointer<JPHVec3>): UInt8 {
    unsafe {
        JPH_CharacterBase_IsSlopeTooSteep(character, value)
    }
}

/**
 * @brief 获取角色形状句柄（对应 JPH_CharacterBase_GetShape）
 */
public func JPH_CharacterBase_GetShape_cj(character: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CharacterBase_GetShape(character)
    }
}

/**
 * @brief 获取地面状态（对应 JPH_CharacterBase_GetGroundState）
 */
public func JPH_CharacterBase_GetGroundState_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterBase_GetGroundState(character)
    }
}

/**
 * @brief 角色是否受支撑（对应 JPH_CharacterBase_IsSupported）
 */
public func JPH_CharacterBase_IsSupported_cj(character: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_CharacterBase_IsSupported(character)
    }
}

/**
 * @brief 获取地面位置（对应 JPH_CharacterBase_GetGroundPosition）
 */
public func JPH_CharacterBase_GetGroundPosition_cj(character: CPointer<Unit>, position: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterBase_GetGroundPosition(character, position)
    }
}

/**
 * @brief 获取地面法线（对应 JPH_CharacterBase_GetGroundNormal）
 */
public func JPH_CharacterBase_GetGroundNormal_cj(character: CPointer<Unit>, normal: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterBase_GetGroundNormal(character, normal)
    }
}

/**
 * @brief 获取地面速度（对应 JPH_CharacterBase_GetGroundVelocity）
 */
public func JPH_CharacterBase_GetGroundVelocity_cj(character: CPointer<Unit>, velocity: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterBase_GetGroundVelocity(character, velocity)
    }
}

/**
 * @brief 获取地面材质句柄（对应 JPH_CharacterBase_GetGroundMaterial）
 */
public func JPH_CharacterBase_GetGroundMaterial_cj(character: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_CharacterBase_GetGroundMaterial(character)
    }
}

/**
 * @brief 获取地面刚体 BodyID（对应 JPH_CharacterBase_GetGroundBodyId）
 */
public func JPH_CharacterBase_GetGroundBodyId_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterBase_GetGroundBodyId(character)
    }
}

/**
 * @brief 获取地面子形状 ID（对应 JPH_CharacterBase_GetGroundSubShapeId）
 */
public func JPH_CharacterBase_GetGroundSubShapeId_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterBase_GetGroundSubShapeId(character)
    }
}

/**
 * @brief 获取地面用户数据（对应 JPH_CharacterBase_GetGroundUserData）
 */
public func JPH_CharacterBase_GetGroundUserData_cj(character: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_CharacterBase_GetGroundUserData(character)
    }
}

// =============================================================================
// 角色（Character，非虚拟）
// =============================================================================

/**
 * @brief 初始化角色设置（对应 JPH_CharacterSettings_Init）
 */
public func JPH_CharacterSettings_Init_cj(settings: CPointer<JPHCharacterSettings>): Unit {
    unsafe {
        JPH_CharacterSettings_Init(settings)
    }
}

/**
 * @brief 创建角色（对应 JPH_Character_Create）
 */
public func JPH_Character_Create_cj(
    settings: CPointer<JPHCharacterSettings>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: UInt64, system: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_Character_Create(settings, position, rotation, userData, system)
    }
}

/**
 * @brief 将角色添加到物理系统（对应 JPH_Character_AddToPhysicsSystem）
 */
public func JPH_Character_AddToPhysicsSystem_cj(
    character: CPointer<Unit>, activationMode: UInt32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_AddToPhysicsSystem(character, activationMode, lockBodies)
    }
}

/**
 * @brief 从物理系统移除角色（对应 JPH_Character_RemoveFromPhysicsSystem）
 */
public func JPH_Character_RemoveFromPhysicsSystem_cj(character: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Character_RemoveFromPhysicsSystem(character, lockBodies)
    }
}

/**
 * @brief 激活角色（对应 JPH_Character_Activate）
 */
public func JPH_Character_Activate_cj(character: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Character_Activate(character, lockBodies)
    }
}

/**
 * @brief 模拟后处理（对应 JPH_Character_PostSimulation）
 */
public func JPH_Character_PostSimulation_cj(
    character: CPointer<Unit>, maxSeparationDistance: Float32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_PostSimulation(character, maxSeparationDistance, lockBodies)
    }
}

/**
 * @brief 设置角色线速度与角速度（对应 JPH_Character_SetLinearAndAngularVelocity）
 */
public func JPH_Character_SetLinearAndAngularVelocity_cj(
    character: CPointer<Unit>, linearVelocity: CPointer<JPHVec3>,
    angularVelocity: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetLinearAndAngularVelocity(character, linearVelocity, angularVelocity, lockBodies)
    }
}

/**
 * @brief 获取角色线速度（对应 JPH_Character_GetLinearVelocity）
 */
public func JPH_Character_GetLinearVelocity_cj(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Character_GetLinearVelocity(character, result)
    }
}

/**
 * @brief 设置角色线速度（对应 JPH_Character_SetLinearVelocity）
 */
public func JPH_Character_SetLinearVelocity_cj(
    character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetLinearVelocity(character, value, lockBodies)
    }
}

/**
 * @brief 增加角色线速度（对应 JPH_Character_AddLinearVelocity）
 */
public func JPH_Character_AddLinearVelocity_cj(
    character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_AddLinearVelocity(character, value, lockBodies)
    }
}

/**
 * @brief 给角色施加冲量（对应 JPH_Character_AddImpulse）
 */
public func JPH_Character_AddImpulse_cj(
    character: CPointer<Unit>, value: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_AddImpulse(character, value, lockBodies)
    }
}

/**
 * @brief 获取角色刚体 BodyID（对应 JPH_Character_GetBodyID）
 */
public func JPH_Character_GetBodyID_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Character_GetBodyID(character)
    }
}

/**
 * @brief 获取角色位置与旋转（对应 JPH_Character_GetPositionAndRotation）
 */
public func JPH_Character_GetPositionAndRotation_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_GetPositionAndRotation(character, position, rotation, lockBodies)
    }
}

/**
 * @brief 设置角色位置与旋转（对应 JPH_Character_SetPositionAndRotation）
 */
public func JPH_Character_SetPositionAndRotation_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, activationMode: UInt32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetPositionAndRotation(character, position, rotation, activationMode, lockBodies)
    }
}

/**
 * @brief 获取角色位置（对应 JPH_Character_GetPosition）
 */
public func JPH_Character_GetPosition_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_GetPosition(character, position, lockBodies)
    }
}

/**
 * @brief 设置角色位置（对应 JPH_Character_SetPosition）
 */
public func JPH_Character_SetPosition_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>, activationMode: UInt32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetPosition(character, position, activationMode, lockBodies)
    }
}

/**
 * @brief 获取角色旋转（对应 JPH_Character_GetRotation）
 */
public func JPH_Character_GetRotation_cj(
    character: CPointer<Unit>, rotation: CPointer<JPHQuat>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_GetRotation(character, rotation, lockBodies)
    }
}

/**
 * @brief 设置角色旋转（对应 JPH_Character_SetRotation）
 */
public func JPH_Character_SetRotation_cj(
    character: CPointer<Unit>, rotation: CPointer<JPHQuat>, activationMode: UInt32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetRotation(character, rotation, activationMode, lockBodies)
    }
}

/**
 * @brief 获取角色质心位置（对应 JPH_Character_GetCenterOfMassPosition）
 */
public func JPH_Character_GetCenterOfMassPosition_cj(
    character: CPointer<Unit>, result: CPointer<JPHVec3>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_GetCenterOfMassPosition(character, result, lockBodies)
    }
}

/**
 * @brief 获取角色世界变换矩阵（对应 JPH_Character_GetWorldTransform）
 */
public func JPH_Character_GetWorldTransform_cj(
    character: CPointer<Unit>, result: CPointer<JPHMat4>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_GetWorldTransform(character, result, lockBodies)
    }
}

/**
 * @brief 获取角色对象层（对应 JPH_Character_GetLayer）
 */
public func JPH_Character_GetLayer_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Character_GetLayer(character)
    }
}

/**
 * @brief 设置角色对象层（对应 JPH_Character_SetLayer）
 */
public func JPH_Character_SetLayer_cj(character: CPointer<Unit>, value: UInt32, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Character_SetLayer(character, value, lockBodies)
    }
}

/**
 * @brief 设置角色形状（对应 JPH_Character_SetShape）
 */
public func JPH_Character_SetShape_cj(
    character: CPointer<Unit>, shape: CPointer<Unit>, maxPenetrationDepth: Float32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Character_SetShape(character, shape, maxPenetrationDepth, lockBodies)
    }
}

// =============================================================================
// 虚拟角色（CharacterVirtual）
// =============================================================================

/**
 * @brief 初始化虚拟角色设置（对应 JPH_CharacterVirtualSettings_Init）
 */
public func JPH_CharacterVirtualSettings_Init_cj(settings: CPointer<JPHCharacterVirtualSettings>): Unit {
    unsafe {
        JPH_CharacterVirtualSettings_Init(settings)
    }
}

/**
 * @brief 创建虚拟角色（对应 JPH_CharacterVirtual_Create）
 */
public func JPH_CharacterVirtual_Create_cj(
    settings: CPointer<JPHCharacterVirtualSettings>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, userData: UInt64, system: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_CharacterVirtual_Create(settings, position, rotation, userData, system)
    }
}

/**
 * @brief 获取虚拟角色 ID（对应 JPH_CharacterVirtual_GetID）
 */
public func JPH_CharacterVirtual_GetID_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterVirtual_GetID(character)
    }
}

/**
 * @brief 设置虚拟角色接触监听器（对应 JPH_CharacterVirtual_SetListener）
 */
public func JPH_CharacterVirtual_SetListener_cj(character: CPointer<Unit>, listener: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterVirtual_SetListener(character, listener)
    }
}

/**
 * @brief 设置虚拟角色间碰撞处理（对应 JPH_CharacterVirtual_SetCharacterVsCharacterCollision）
 */
public func JPH_CharacterVirtual_SetCharacterVsCharacterCollision_cj(
    character: CPointer<Unit>, characterVsCharacterCollision: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVirtual_SetCharacterVsCharacterCollision(character, characterVsCharacterCollision)
    }
}

/**
 * @brief 获取虚拟角色线速度（对应 JPH_CharacterVirtual_GetLinearVelocity）
 */
public func JPH_CharacterVirtual_GetLinearVelocity_cj(
    character: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetLinearVelocity(character, velocity)
    }
}

/**
 * @brief 设置虚拟角色线速度（对应 JPH_CharacterVirtual_SetLinearVelocity）
 */
public func JPH_CharacterVirtual_SetLinearVelocity_cj(
    character: CPointer<Unit>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_CharacterVirtual_SetLinearVelocity(character, velocity)
    }
}

/**
 * @brief 获取虚拟角色位置（对应 JPH_CharacterVirtual_GetPosition）
 */
public func JPH_CharacterVirtual_GetPosition_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetPosition(character, position)
    }
}

/**
 * @brief 设置虚拟角色位置（对应 JPH_CharacterVirtual_SetPosition）
 */
public func JPH_CharacterVirtual_SetPosition_cj(
    character: CPointer<Unit>, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_CharacterVirtual_SetPosition(character, position)
    }
}

/**
 * @brief 获取虚拟角色旋转（对应 JPH_CharacterVirtual_GetRotation）
 */
public func JPH_CharacterVirtual_GetRotation_cj(
    character: CPointer<Unit>, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetRotation(character, rotation)
    }
}

/**
 * @brief 设置虚拟角色旋转（对应 JPH_CharacterVirtual_SetRotation）
 */
public func JPH_CharacterVirtual_SetRotation_cj(
    character: CPointer<Unit>, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_CharacterVirtual_SetRotation(character, rotation)
    }
}

/**
 * @brief 获取虚拟角色世界变换矩阵（对应 JPH_CharacterVirtual_GetWorldTransform）
 */
public func JPH_CharacterVirtual_GetWorldTransform_cj(
    character: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetWorldTransform(character, result)
    }
}

/**
 * @brief 获取虚拟角色质心变换矩阵（对应 JPH_CharacterVirtual_GetCenterOfMassTransform）
 */
public func JPH_CharacterVirtual_GetCenterOfMassTransform_cj(
    character: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetCenterOfMassTransform(character, result)
    }
}

/**
 * @brief 获取虚拟角色质量（对应 JPH_CharacterVirtual_GetMass）
 */
public func JPH_CharacterVirtual_GetMass_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterVirtual_GetMass(character)
    }
}

/**
 * @brief 设置虚拟角色质量（对应 JPH_CharacterVirtual_SetMass）
 */
public func JPH_CharacterVirtual_SetMass_cj(character: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_CharacterVirtual_SetMass(character, value)
    }
}

/**
 * @brief 获取虚拟角色最大推力（对应 JPH_CharacterVirtual_GetMaxStrength）
 */
public func JPH_CharacterVirtual_GetMaxStrength_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterVirtual_GetMaxStrength(character)
    }
}

/**
 * @brief 设置虚拟角色最大推力（对应 JPH_CharacterVirtual_SetMaxStrength）
 */
public func JPH_CharacterVirtual_SetMaxStrength_cj(character: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_CharacterVirtual_SetMaxStrength(character, value)
    }
}

/**
 * @brief 获取穿透恢复速度（对应 JPH_CharacterVirtual_GetPenetrationRecoverySpeed）
 */
public func JPH_CharacterVirtual_GetPenetrationRecoverySpeed_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterVirtual_GetPenetrationRecoverySpeed(character)
    }
}

/**
 * @brief 设置穿透恢复速度（对应 JPH_CharacterVirtual_SetPenetrationRecoverySpeed）
 */
public func JPH_CharacterVirtual_SetPenetrationRecoverySpeed_cj(character: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_CharacterVirtual_SetPenetrationRecoverySpeed(character, value)
    }
}

/**
 * @brief 获取增强内部边移除（对应 JPH_CharacterVirtual_GetEnhancedInternalEdgeRemoval）
 */
public func JPH_CharacterVirtual_GetEnhancedInternalEdgeRemoval_cj(character: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_CharacterVirtual_GetEnhancedInternalEdgeRemoval(character)
    }
}

/**
 * @brief 设置增强内部边移除（对应 JPH_CharacterVirtual_SetEnhancedInternalEdgeRemoval）
 */
public func JPH_CharacterVirtual_SetEnhancedInternalEdgeRemoval_cj(character: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_CharacterVirtual_SetEnhancedInternalEdgeRemoval(character, value)
    }
}

/**
 * @brief 获取角色填充（对应 JPH_CharacterVirtual_GetCharacterPadding）
 */
public func JPH_CharacterVirtual_GetCharacterPadding_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterVirtual_GetCharacterPadding(character)
    }
}

/**
 * @brief 获取最大命中数（对应 JPH_CharacterVirtual_GetMaxNumHits）
 */
public func JPH_CharacterVirtual_GetMaxNumHits_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterVirtual_GetMaxNumHits(character)
    }
}

/**
 * @brief 设置最大命中数（对应 JPH_CharacterVirtual_SetMaxNumHits）
 */
public func JPH_CharacterVirtual_SetMaxNumHits_cj(character: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_CharacterVirtual_SetMaxNumHits(character, value)
    }
}

/**
 * @brief 获取命中约简最大角余弦（对应 JPH_CharacterVirtual_GetHitReductionCosMaxAngle）
 */
public func JPH_CharacterVirtual_GetHitReductionCosMaxAngle_cj(character: CPointer<Unit>): Float32 {
    unsafe {
        JPH_CharacterVirtual_GetHitReductionCosMaxAngle(character)
    }
}

/**
 * @brief 设置命中约简最大角余弦（对应 JPH_CharacterVirtual_SetHitReductionCosMaxAngle）
 */
public func JPH_CharacterVirtual_SetHitReductionCosMaxAngle_cj(character: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_CharacterVirtual_SetHitReductionCosMaxAngle(character, value)
    }
}

/**
 * @brief 最大命中数是否已超限（对应 JPH_CharacterVirtual_GetMaxHitsExceeded）
 */
public func JPH_CharacterVirtual_GetMaxHitsExceeded_cj(character: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_CharacterVirtual_GetMaxHitsExceeded(character)
    }
}

/**
 * @brief 获取形状偏移（对应 JPH_CharacterVirtual_GetShapeOffset）
 */
public func JPH_CharacterVirtual_GetShapeOffset_cj(character: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterVirtual_GetShapeOffset(character, result)
    }
}

/**
 * @brief 设置形状偏移（对应 JPH_CharacterVirtual_SetShapeOffset）
 */
public func JPH_CharacterVirtual_SetShapeOffset_cj(character: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_CharacterVirtual_SetShapeOffset(character, value)
    }
}

/**
 * @brief 获取虚拟角色用户数据（对应 JPH_CharacterVirtual_GetUserData）
 */
public func JPH_CharacterVirtual_GetUserData_cj(character: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_CharacterVirtual_GetUserData(character)
    }
}

/**
 * @brief 设置虚拟角色用户数据（对应 JPH_CharacterVirtual_SetUserData）
 */
public func JPH_CharacterVirtual_SetUserData_cj(character: CPointer<Unit>, value: UInt64): Unit {
    unsafe {
        JPH_CharacterVirtual_SetUserData(character, value)
    }
}

/**
 * @brief 获取内部刚体 BodyID（对应 JPH_CharacterVirtual_GetInnerBodyID）
 */
public func JPH_CharacterVirtual_GetInnerBodyID_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterVirtual_GetInnerBodyID(character)
    }
}

/**
 * @brief 取消朝陡坡方向的速度分量（对应 JPH_CharacterVirtual_CancelVelocityTowardsSteepSlopes）
 */
public func JPH_CharacterVirtual_CancelVelocityTowardsSteepSlopes_cj(
    character: CPointer<Unit>, desiredVelocity: CPointer<JPHVec3>, velocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_CharacterVirtual_CancelVelocityTowardsSteepSlopes(character, desiredVelocity, velocity)
    }
}

/**
 * @brief 开始跟踪接触变化（对应 JPH_CharacterVirtual_StartTrackingContactChanges）
 */
public func JPH_CharacterVirtual_StartTrackingContactChanges_cj(character: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterVirtual_StartTrackingContactChanges(character)
    }
}

/**
 * @brief 结束跟踪接触变化（对应 JPH_CharacterVirtual_FinishTrackingContactChanges）
 */
public func JPH_CharacterVirtual_FinishTrackingContactChanges_cj(character: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterVirtual_FinishTrackingContactChanges(character)
    }
}

/**
 * @brief 更新虚拟角色（对应 JPH_CharacterVirtual_Update）
 */
public func JPH_CharacterVirtual_Update_cj(
    character: CPointer<Unit>, deltaTime: Float32, layer: UInt32, system: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVirtual_Update(character, deltaTime, layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 扩展更新虚拟角色（对应 JPH_CharacterVirtual_ExtendedUpdate）
 */
public func JPH_CharacterVirtual_ExtendedUpdate_cj(
    character: CPointer<Unit>, deltaTime: Float32, settings: CPointer<JPHExtendedUpdateSettings>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVirtual_ExtendedUpdate(
            character, deltaTime, settings, layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 刷新虚拟角色接触（对应 JPH_CharacterVirtual_RefreshContacts）
 */
public func JPH_CharacterVirtual_RefreshContacts_cj(
    character: CPointer<Unit>, layer: UInt32, system: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVirtual_RefreshContacts(character, layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 判断能否上台阶（对应 JPH_CharacterVirtual_CanWalkStairs）
 */
public func JPH_CharacterVirtual_CanWalkStairs_cj(
    character: CPointer<Unit>, linearVelocity: CPointer<JPHVec3>
): UInt8 {
    unsafe {
        JPH_CharacterVirtual_CanWalkStairs(character, linearVelocity)
    }
}

/**
 * @brief 尝试上台阶（对应 JPH_CharacterVirtual_WalkStairs）
 */
public func JPH_CharacterVirtual_WalkStairs_cj(
    character: CPointer<Unit>, deltaTime: Float32,
    stepUp: CPointer<JPHVec3>, stepForward: CPointer<JPHVec3>,
    stepForwardTest: CPointer<JPHVec3>, stepDownExtra: CPointer<JPHVec3>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CharacterVirtual_WalkStairs(
            character, deltaTime, stepUp, stepForward, stepForwardTest, stepDownExtra,
            layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 尝试贴地（对应 JPH_CharacterVirtual_StickToFloor）
 */
public func JPH_CharacterVirtual_StickToFloor_cj(
    character: CPointer<Unit>, stepDown: CPointer<JPHVec3>,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CharacterVirtual_StickToFloor(character, stepDown, layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 更新地面速度（对应 JPH_CharacterVirtual_UpdateGroundVelocity）
 */
public func JPH_CharacterVirtual_UpdateGroundVelocity_cj(character: CPointer<Unit>): Unit {
    unsafe {
        JPH_CharacterVirtual_UpdateGroundVelocity(character)
    }
}

/**
 * @brief 设置虚拟角色形状（对应 JPH_CharacterVirtual_SetShape）
 */
public func JPH_CharacterVirtual_SetShape_cj(
    character: CPointer<Unit>, shape: CPointer<Unit>, maxPenetrationDepth: Float32,
    layer: UInt32, system: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CharacterVirtual_SetShape(
            character, shape, maxPenetrationDepth, layer, system, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 设置内部刚体形状（对应 JPH_CharacterVirtual_SetInnerBodyShape）
 */
public func JPH_CharacterVirtual_SetInnerBodyShape_cj(
    character: CPointer<Unit>, shape: CPointer<Unit>
): Unit {
    unsafe {
        JPH_CharacterVirtual_SetInnerBodyShape(character, shape)
    }
}

/**
 * @brief 获取活动接触数量（对应 JPH_CharacterVirtual_GetNumActiveContacts）
 */
public func JPH_CharacterVirtual_GetNumActiveContacts_cj(character: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_CharacterVirtual_GetNumActiveContacts(character)
    }
}

/**
 * @brief 获取指定活动接触（对应 JPH_CharacterVirtual_GetActiveContact）
 */
public func JPH_CharacterVirtual_GetActiveContact_cj(
    character: CPointer<Unit>, index: UInt32, result: CPointer<JPHCharacterContact>
): Unit {
    unsafe {
        JPH_CharacterVirtual_GetActiveContact(character, index, result)
    }
}

/**
 * @brief 是否与指定刚体碰撞过（对应 JPH_CharacterVirtual_HasCollidedWithBody）
 */
public func JPH_CharacterVirtual_HasCollidedWithBody_cj(character: CPointer<Unit>, body: UInt32): UInt8 {
    unsafe {
        JPH_CharacterVirtual_HasCollidedWithBody(character, body)
    }
}

/**
 * @brief 是否与指定角色 ID 碰撞过（对应 JPH_CharacterVirtual_HasCollidedWith）
 */
public func JPH_CharacterVirtual_HasCollidedWith_cj(character: CPointer<Unit>, other: UInt32): UInt8 {
    unsafe {
        JPH_CharacterVirtual_HasCollidedWith(character, other)
    }
}

/**
 * @brief 是否与指定虚拟角色碰撞过（对应 JPH_CharacterVirtual_HasCollidedWithCharacter）
 */
public func JPH_CharacterVirtual_HasCollidedWithCharacter_cj(
    character: CPointer<Unit>, other: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CharacterVirtual_HasCollidedWithCharacter(character, other)
    }
}

// =============================================================================
// 补充：Settings 初始化 / 碰撞分发 / 接触流形 / 射线点计算 / 质量属性
// =============================================================================

/**
 * @brief 初始化形状碰撞设置（对应 JPH_CollideShapeSettings_Init）
 */
public func JPH_CollideShapeSettings_Init_cj(settings: CPointer<JPHCollideShapeSettings>): Unit {
    unsafe {
        JPH_CollideShapeSettings_Init(settings)
    }
}

/**
 * @brief 初始化形状投射设置（对应 JPH_ShapeCastSettings_Init）
 */
public func JPH_ShapeCastSettings_Init_cj(settings: CPointer<JPHShapeCastSettings>): Unit {
    unsafe {
        JPH_ShapeCastSettings_Init(settings)
    }
}

/**
 * @brief 射线命中点计算（对应 JPH_RayCast_GetPointOnRay）
 */
public func JPH_RayCast_GetPointOnRay_cj(
    origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>, fraction: Float32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_RayCast_GetPointOnRay(origin, direction, fraction, result)
    }
}

/**
 * @brief 双精度射线命中点计算（对应 JPH_RRayCast_GetPointOnRay）
 */
public func JPH_RRayCast_GetPointOnRay_cj(
    origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>, fraction: Float32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_RRayCast_GetPointOnRay(origin, direction, fraction, result)
    }
}

/**
 * @brief 分解惯量主轴（对应 JPH_MassProperties_DecomposePrincipalMomentsOfInertia）
 */
public func JPH_MassProperties_DecomposePrincipalMomentsOfInertia_cj(
    properties: CPointer<JPHMassProperties>, rotation: CPointer<JPHMat4>, diagonal: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_MassProperties_DecomposePrincipalMomentsOfInertia(properties, rotation, diagonal)
    }
}

/**
 * @brief 质量属性缩放到指定质量（对应 JPH_MassProperties_ScaleToMass）
 */
public func JPH_MassProperties_ScaleToMass_cj(properties: CPointer<JPHMassProperties>, mass: Float32): Unit {
    unsafe {
        JPH_MassProperties_ScaleToMass(properties, mass)
    }
}

/**
 * @brief 计算等效实心盒尺寸（对应 JPH_MassProperties_GetEquivalentSolidBoxSize）
 */
public func JPH_MassProperties_GetEquivalentSolidBoxSize_cj(
    mass: Float32, inertiaDiagonal: CPointer<JPHVec3>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_MassProperties_GetEquivalentSolidBoxSize(mass, inertiaDiagonal, result)
    }
}

/**
 * @brief 形状 vs 形状碰撞检测（对应 JPH_CollisionDispatch_CollideShapeVsShape）
 */
public func JPH_CollisionDispatch_CollideShapeVsShape_cj(
    shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1: CPointer<JPHVec3>, scale2: CPointer<JPHVec3>,
    centerOfMassTransform1: CPointer<JPHMat4>, centerOfMassTransform2: CPointer<JPHMat4>,
    collideShapeSettings: CPointer<JPHCollideShapeSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CollisionDispatch_CollideShapeVsShape(
            shape1, shape2, scale1, scale2,
            centerOfMassTransform1, centerOfMassTransform2,
            collideShapeSettings, callback, userData, shapeFilter)
    }
}

/**
 * @brief 形状投射 vs 形状（形状 2 局部空间，对应 JPH_CollisionDispatch_CastShapeVsShapeLocalSpace）
 */
public func JPH_CollisionDispatch_CastShapeVsShapeLocalSpace_cj(
    direction: CPointer<JPHVec3>, shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1InShape2LocalSpace: CPointer<JPHVec3>, scale2: CPointer<JPHVec3>,
    centerOfMassTransform1InShape2LocalSpace: CPointer<JPHMat4>,
    centerOfMassWorldTransform2: CPointer<JPHMat4>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CollisionDispatch_CastShapeVsShapeLocalSpace(
            direction, shape1, shape2, scale1InShape2LocalSpace, scale2,
            centerOfMassTransform1InShape2LocalSpace, centerOfMassWorldTransform2,
            shapeCastSettings, callback, userData, shapeFilter)
    }
}

/**
 * @brief 形状投射 vs 形状（世界空间，对应 JPH_CollisionDispatch_CastShapeVsShapeWorldSpace）
 */
public func JPH_CollisionDispatch_CastShapeVsShapeWorldSpace_cj(
    direction: CPointer<JPHVec3>, shape1: CPointer<Unit>, shape2: CPointer<Unit>,
    scale1: CPointer<JPHVec3>, inScale2: CPointer<JPHVec3>,
    centerOfMassWorldTransform1: CPointer<JPHMat4>, centerOfMassWorldTransform2: CPointer<JPHMat4>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_CollisionDispatch_CastShapeVsShapeWorldSpace(
            direction, shape1, shape2, scale1, inScale2,
            centerOfMassWorldTransform1, centerOfMassWorldTransform2,
            shapeCastSettings, callback, userData, shapeFilter)
    }
}

/**
 * @brief 估计碰撞响应（对应 JPH_EstimateCollisionResponse）
 */
public func JPH_EstimateCollisionResponse_cj(
    body1: CPointer<Unit>, body2: CPointer<Unit>, manifold: CPointer<Unit>,
    combinedFriction: Float32, combinedRestitution: Float32, minVelocityForRestitution: Float32,
    numIterations: UInt32, result: CPointer<JPHCollisionEstimationResult>
): Unit {
    unsafe {
        JPH_EstimateCollisionResponse(
            body1, body2, manifold, combinedFriction, combinedRestitution,
            minVelocityForRestitution, numIterations, result)
    }
}

// =============================================================================
// 接触流形（ContactManifold）
// =============================================================================

/**
 * @brief 获取接触流形世界空间法线（对应 JPH_ContactManifold_GetWorldSpaceNormal）
 */
public func JPH_ContactManifold_GetWorldSpaceNormal_cj(
    manifold: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_ContactManifold_GetWorldSpaceNormal(manifold, result)
    }
}

/**
 * @brief 获取接触流形穿透深度（对应 JPH_ContactManifold_GetPenetrationDepth）
 */
public func JPH_ContactManifold_GetPenetrationDepth_cj(manifold: CPointer<Unit>): Float32 {
    unsafe {
        JPH_ContactManifold_GetPenetrationDepth(manifold)
    }
}

/**
 * @brief 获取刚体 1 的子形状 ID（对应 JPH_ContactManifold_GetSubShapeID1）
 */
public func JPH_ContactManifold_GetSubShapeID1_cj(manifold: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ContactManifold_GetSubShapeID1(manifold)
    }
}

/**
 * @brief 获取刚体 2 的子形状 ID（对应 JPH_ContactManifold_GetSubShapeID2）
 */
public func JPH_ContactManifold_GetSubShapeID2_cj(manifold: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ContactManifold_GetSubShapeID2(manifold)
    }
}

/**
 * @brief 获取接触流形接触点数量（对应 JPH_ContactManifold_GetPointCount）
 */
public func JPH_ContactManifold_GetPointCount_cj(manifold: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_ContactManifold_GetPointCount(manifold)
    }
}

/**
 * @brief 获取刚体 1 上指定接触点（对应 JPH_ContactManifold_GetWorldSpaceContactPointOn1）
 */
public func JPH_ContactManifold_GetWorldSpaceContactPointOn1_cj(
    manifold: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_ContactManifold_GetWorldSpaceContactPointOn1(manifold, index, result)
    }
}

/**
 * @brief 获取刚体 2 上指定接触点（对应 JPH_ContactManifold_GetWorldSpaceContactPointOn2）
 */
public func JPH_ContactManifold_GetWorldSpaceContactPointOn2_cj(
    manifold: CPointer<Unit>, index: UInt32, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_ContactManifold_GetWorldSpaceContactPointOn2(manifold, index, result)
    }
}

// =============================================================================
// 约束基类（Constraint / TwoBodyConstraint）
// =============================================================================

/**
 * @brief 销毁约束（对应 JPH_Constraint_Destroy）
 */
public func JPH_Constraint_Destroy_cj(constraint: CPointer<Unit>): Unit {
    unsafe {
        JPH_Constraint_Destroy(constraint)
    }
}

/**
 * @brief 获取约束类型（对应 JPH_Constraint_GetType）
 */
public func JPH_Constraint_GetType_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Constraint_GetType(constraint)
    }
}

/**
 * @brief 获取约束子类型（对应 JPH_Constraint_GetSubType）
 */
public func JPH_Constraint_GetSubType_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Constraint_GetSubType(constraint)
    }
}

/**
 * @brief 获取约束优先级（对应 JPH_Constraint_GetConstraintPriority）
 */
public func JPH_Constraint_GetConstraintPriority_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Constraint_GetConstraintPriority(constraint)
    }
}

/**
 * @brief 设置约束优先级（对应 JPH_Constraint_SetConstraintPriority）
 */
public func JPH_Constraint_SetConstraintPriority_cj(constraint: CPointer<Unit>, priority: UInt32): Unit {
    unsafe {
        JPH_Constraint_SetConstraintPriority(constraint, priority)
    }
}

/**
 * @brief 获取速度迭代步数覆盖（对应 JPH_Constraint_GetNumVelocityStepsOverride）
 */
public func JPH_Constraint_GetNumVelocityStepsOverride_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Constraint_GetNumVelocityStepsOverride(constraint)
    }
}

/**
 * @brief 设置速度迭代步数覆盖（对应 JPH_Constraint_SetNumVelocityStepsOverride）
 */
public func JPH_Constraint_SetNumVelocityStepsOverride_cj(constraint: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_Constraint_SetNumVelocityStepsOverride(constraint, value)
    }
}

/**
 * @brief 获取位置迭代步数覆盖（对应 JPH_Constraint_GetNumPositionStepsOverride）
 */
public func JPH_Constraint_GetNumPositionStepsOverride_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Constraint_GetNumPositionStepsOverride(constraint)
    }
}

/**
 * @brief 设置位置迭代步数覆盖（对应 JPH_Constraint_SetNumPositionStepsOverride）
 */
public func JPH_Constraint_SetNumPositionStepsOverride_cj(constraint: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_Constraint_SetNumPositionStepsOverride(constraint, value)
    }
}

/**
 * @brief 约束是否启用（对应 JPH_Constraint_GetEnabled）
 */
public func JPH_Constraint_GetEnabled_cj(constraint: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Constraint_GetEnabled(constraint)
    }
}

/**
 * @brief 设置约束是否启用（对应 JPH_Constraint_SetEnabled）
 */
public func JPH_Constraint_SetEnabled_cj(constraint: CPointer<Unit>, enabled: UInt8): Unit {
    unsafe {
        JPH_Constraint_SetEnabled(constraint, enabled)
    }
}

/**
 * @brief 获取约束用户数据（对应 JPH_Constraint_GetUserData）
 */
public func JPH_Constraint_GetUserData_cj(constraint: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_Constraint_GetUserData(constraint)
    }
}

/**
 * @brief 设置约束用户数据（对应 JPH_Constraint_SetUserData）
 */
public func JPH_Constraint_SetUserData_cj(constraint: CPointer<Unit>, userData: UInt64): Unit {
    unsafe {
        JPH_Constraint_SetUserData(constraint, userData)
    }
}

/**
 * @brief 通知约束关联刚体形状已改变（对应 JPH_Constraint_NotifyShapeChanged）
 */
public func JPH_Constraint_NotifyShapeChanged_cj(
    constraint: CPointer<Unit>, bodyID: UInt32, deltaCOM: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_Constraint_NotifyShapeChanged(constraint, bodyID, deltaCOM)
    }
}

/**
 * @brief 重置约束热启动缓存（对应 JPH_Constraint_ResetWarmStart）
 */
public func JPH_Constraint_ResetWarmStart_cj(constraint: CPointer<Unit>): Unit {
    unsafe {
        JPH_Constraint_ResetWarmStart(constraint)
    }
}

/**
 * @brief 约束是否活动（对应 JPH_Constraint_IsActive）
 */
public func JPH_Constraint_IsActive_cj(constraint: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Constraint_IsActive(constraint)
    }
}

/**
 * @brief 建立速度约束（对应 JPH_Constraint_SetupVelocityConstraint）
 */
public func JPH_Constraint_SetupVelocityConstraint_cj(constraint: CPointer<Unit>, deltaTime: Float32): Unit {
    unsafe {
        JPH_Constraint_SetupVelocityConstraint(constraint, deltaTime)
    }
}

/**
 * @brief 热启动速度约束（对应 JPH_Constraint_WarmStartVelocityConstraint）
 */
public func JPH_Constraint_WarmStartVelocityConstraint_cj(
    constraint: CPointer<Unit>, warmStartImpulseRatio: Float32
): Unit {
    unsafe {
        JPH_Constraint_WarmStartVelocityConstraint(constraint, warmStartImpulseRatio)
    }
}

/**
 * @brief 求解速度约束（对应 JPH_Constraint_SolveVelocityConstraint）
 */
public func JPH_Constraint_SolveVelocityConstraint_cj(constraint: CPointer<Unit>, deltaTime: Float32): UInt8 {
    unsafe {
        JPH_Constraint_SolveVelocityConstraint(constraint, deltaTime)
    }
}

/**
 * @brief 求解位置约束（对应 JPH_Constraint_SolvePositionConstraint）
 */
public func JPH_Constraint_SolvePositionConstraint_cj(
    constraint: CPointer<Unit>, deltaTime: Float32, baumgarte: Float32
): UInt8 {
    unsafe {
        JPH_Constraint_SolvePositionConstraint(constraint, deltaTime, baumgarte)
    }
}

/**
 * @brief 获取双刚体约束的刚体 1（对应 JPH_TwoBodyConstraint_GetBody1）
 */
public func JPH_TwoBodyConstraint_GetBody1_cj(constraint: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TwoBodyConstraint_GetBody1(constraint)
    }
}

/**
 * @brief 获取双刚体约束的刚体 2（对应 JPH_TwoBodyConstraint_GetBody2）
 */
public func JPH_TwoBodyConstraint_GetBody2_cj(constraint: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TwoBodyConstraint_GetBody2(constraint)
    }
}

/**
 * @brief 获取约束到刚体 1 的变换矩阵（对应 JPH_TwoBodyConstraint_GetConstraintToBody1Matrix）
 */
public func JPH_TwoBodyConstraint_GetConstraintToBody1Matrix_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_TwoBodyConstraint_GetConstraintToBody1Matrix(constraint, result)
    }
}

/**
 * @brief 获取约束到刚体 2 的变换矩阵（对应 JPH_TwoBodyConstraint_GetConstraintToBody2Matrix）
 */
public func JPH_TwoBodyConstraint_GetConstraintToBody2Matrix_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_TwoBodyConstraint_GetConstraintToBody2Matrix(constraint, result)
    }
}

// =============================================================================
// 固定约束（FixedConstraint）
// =============================================================================

/**
 * @brief 初始化固定约束设置（对应 JPH_FixedConstraintSettings_Init）
 */
public func JPH_FixedConstraintSettings_Init_cj(settings: CPointer<JPHFixedConstraintSettings>): Unit {
    unsafe {
        JPH_FixedConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建固定约束（对应 JPH_FixedConstraint_Create）
 */
public func JPH_FixedConstraint_Create_cj(
    settings: CPointer<JPHFixedConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_FixedConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取固定约束设置（对应 JPH_FixedConstraint_GetSettings）
 */
public func JPH_FixedConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHFixedConstraintSettings>
): Unit {
    unsafe {
        JPH_FixedConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 获取固定约束位置 lambda（对应 JPH_FixedConstraint_GetTotalLambdaPosition）
 */
public func JPH_FixedConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_FixedConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

/**
 * @brief 获取固定约束旋转 lambda（对应 JPH_FixedConstraint_GetTotalLambdaRotation）
 */
public func JPH_FixedConstraint_GetTotalLambdaRotation_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_FixedConstraint_GetTotalLambdaRotation(constraint, result)
    }
}

// =============================================================================
// 距离约束（DistanceConstraint）
// =============================================================================

/**
 * @brief 初始化距离约束设置（对应 JPH_DistanceConstraintSettings_Init）
 */
public func JPH_DistanceConstraintSettings_Init_cj(settings: CPointer<JPHDistanceConstraintSettings>): Unit {
    unsafe {
        JPH_DistanceConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建距离约束（对应 JPH_DistanceConstraint_Create）
 */
public func JPH_DistanceConstraint_Create_cj(
    settings: CPointer<JPHDistanceConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_DistanceConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取距离约束设置（对应 JPH_DistanceConstraint_GetSettings）
 */
public func JPH_DistanceConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHDistanceConstraintSettings>
): Unit {
    unsafe {
        JPH_DistanceConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 设置距离约束的距离范围（对应 JPH_DistanceConstraint_SetDistance）
 */
public func JPH_DistanceConstraint_SetDistance_cj(
    constraint: CPointer<Unit>, minDistance: Float32, maxDistance: Float32
): Unit {
    unsafe {
        JPH_DistanceConstraint_SetDistance(constraint, minDistance, maxDistance)
    }
}

/**
 * @brief 获取最小距离（对应 JPH_DistanceConstraint_GetMinDistance）
 */
public func JPH_DistanceConstraint_GetMinDistance_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_DistanceConstraint_GetMinDistance(constraint)
    }
}

/**
 * @brief 获取最大距离（对应 JPH_DistanceConstraint_GetMaxDistance）
 */
public func JPH_DistanceConstraint_GetMaxDistance_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_DistanceConstraint_GetMaxDistance(constraint)
    }
}

/**
 * @brief 获取限位弹簧设置（对应 JPH_DistanceConstraint_GetLimitsSpringSettings）
 */
public func JPH_DistanceConstraint_GetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_DistanceConstraint_GetLimitsSpringSettings(constraint, result)
    }
}

/**
 * @brief 设置限位弹簧设置（对应 JPH_DistanceConstraint_SetLimitsSpringSettings）
 */
public func JPH_DistanceConstraint_SetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_DistanceConstraint_SetLimitsSpringSettings(constraint, settings)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_DistanceConstraint_GetTotalLambdaPosition）
 */
public func JPH_DistanceConstraint_GetTotalLambdaPosition_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_DistanceConstraint_GetTotalLambdaPosition(constraint)
    }
}

// =============================================================================
// 点约束（PointConstraint）
// =============================================================================

/**
 * @brief 初始化点约束设置（对应 JPH_PointConstraintSettings_Init）
 */
public func JPH_PointConstraintSettings_Init_cj(settings: CPointer<JPHPointConstraintSettings>): Unit {
    unsafe {
        JPH_PointConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建点约束（对应 JPH_PointConstraint_Create）
 */
public func JPH_PointConstraint_Create_cj(
    settings: CPointer<JPHPointConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_PointConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取点约束设置（对应 JPH_PointConstraint_GetSettings）
 */
public func JPH_PointConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHPointConstraintSettings>
): Unit {
    unsafe {
        JPH_PointConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 设置刚体 1 上的锚点（对应 JPH_PointConstraint_SetPoint1）
 */
public func JPH_PointConstraint_SetPoint1_cj(
    constraint: CPointer<Unit>, space: UInt32, value: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_PointConstraint_SetPoint1(constraint, space, value)
    }
}

/**
 * @brief 设置刚体 2 上的锚点（对应 JPH_PointConstraint_SetPoint2）
 */
public func JPH_PointConstraint_SetPoint2_cj(
    constraint: CPointer<Unit>, space: UInt32, value: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_PointConstraint_SetPoint2(constraint, space, value)
    }
}

/**
 * @brief 获取刚体 1 局部空间锚点（对应 JPH_PointConstraint_GetLocalSpacePoint1）
 */
public func JPH_PointConstraint_GetLocalSpacePoint1_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_PointConstraint_GetLocalSpacePoint1(constraint, result)
    }
}

/**
 * @brief 获取刚体 2 局部空间锚点（对应 JPH_PointConstraint_GetLocalSpacePoint2）
 */
public func JPH_PointConstraint_GetLocalSpacePoint2_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_PointConstraint_GetLocalSpacePoint2(constraint, result)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_PointConstraint_GetTotalLambdaPosition）
 */
public func JPH_PointConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_PointConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

// =============================================================================
// 锥约束（ConeConstraint）
// =============================================================================

/**
 * @brief 初始化锥约束设置（对应 JPH_ConeConstraintSettings_Init）
 */
public func JPH_ConeConstraintSettings_Init_cj(settings: CPointer<JPHConeConstraintSettings>): Unit {
    unsafe {
        JPH_ConeConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建锥约束（对应 JPH_ConeConstraint_Create）
 */
public func JPH_ConeConstraint_Create_cj(
    settings: CPointer<JPHConeConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_ConeConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取锥约束设置（对应 JPH_ConeConstraint_GetSettings）
 */
public func JPH_ConeConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHConeConstraintSettings>
): Unit {
    unsafe {
        JPH_ConeConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 设置半锥角（对应 JPH_ConeConstraint_SetHalfConeAngle）
 */
public func JPH_ConeConstraint_SetHalfConeAngle_cj(constraint: CPointer<Unit>, halfConeAngle: Float32): Unit {
    unsafe {
        JPH_ConeConstraint_SetHalfConeAngle(constraint, halfConeAngle)
    }
}

/**
 * @brief 获取半锥角余弦值（对应 JPH_ConeConstraint_GetCosHalfConeAngle）
 */
public func JPH_ConeConstraint_GetCosHalfConeAngle_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_ConeConstraint_GetCosHalfConeAngle(constraint)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_ConeConstraint_GetTotalLambdaPosition）
 */
public func JPH_ConeConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_ConeConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

/**
 * @brief 获取旋转 lambda（对应 JPH_ConeConstraint_GetTotalLambdaRotation）
 */
public func JPH_ConeConstraint_GetTotalLambdaRotation_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_ConeConstraint_GetTotalLambdaRotation(constraint)
    }
}

// =============================================================================
// 齿轮约束（GearConstraint）
// =============================================================================

/**
 * @brief 初始化齿轮约束设置（对应 JPH_GearConstraintSettings_Init）
 */
public func JPH_GearConstraintSettings_Init_cj(settings: CPointer<JPHGearConstraintSettings>): Unit {
    unsafe {
        JPH_GearConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建齿轮约束（对应 JPH_GearConstraint_Create）
 */
public func JPH_GearConstraint_Create_cj(
    settings: CPointer<JPHGearConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_GearConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取齿轮约束设置（对应 JPH_GearConstraint_GetSettings）
 */
public func JPH_GearConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHGearConstraintSettings>
): Unit {
    unsafe {
        JPH_GearConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 设置齿轮耦合的两个约束（对应 JPH_GearConstraint_SetConstraints）
 */
public func JPH_GearConstraint_SetConstraints_cj(
    constraint: CPointer<Unit>, gear1: CPointer<Unit>, gear2: CPointer<Unit>
): Unit {
    unsafe {
        JPH_GearConstraint_SetConstraints(constraint, gear1, gear2)
    }
}

/**
 * @brief 获取 lambda（对应 JPH_GearConstraint_GetTotalLambda）
 */
public func JPH_GearConstraint_GetTotalLambda_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_GearConstraint_GetTotalLambda(constraint)
    }
}

// =============================================================================
// 铰链约束（HingeConstraint）
// =============================================================================

/**
 * @brief 初始化铰链约束设置（对应 JPH_HingeConstraintSettings_Init）
 */
public func JPH_HingeConstraintSettings_Init_cj(settings: CPointer<JPHHingeConstraintSettings>): Unit {
    unsafe {
        JPH_HingeConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建铰链约束（对应 JPH_HingeConstraint_Create）
 */
public func JPH_HingeConstraint_Create_cj(
    settings: CPointer<JPHHingeConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_HingeConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取铰链约束设置（对应 JPH_HingeConstraint_GetSettings）
 */
public func JPH_HingeConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHHingeConstraintSettings>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 获取刚体 1 局部空间锚点（对应 JPH_HingeConstraint_GetLocalSpacePoint1）
 */
public func JPH_HingeConstraint_GetLocalSpacePoint1_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpacePoint1(constraint, result)
    }
}

/**
 * @brief 获取刚体 2 局部空间锚点（对应 JPH_HingeConstraint_GetLocalSpacePoint2）
 */
public func JPH_HingeConstraint_GetLocalSpacePoint2_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpacePoint2(constraint, result)
    }
}

/**
 * @brief 获取刚体 1 局部空间铰链轴（对应 JPH_HingeConstraint_GetLocalSpaceHingeAxis1）
 */
public func JPH_HingeConstraint_GetLocalSpaceHingeAxis1_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpaceHingeAxis1(constraint, result)
    }
}

/**
 * @brief 获取刚体 2 局部空间铰链轴（对应 JPH_HingeConstraint_GetLocalSpaceHingeAxis2）
 */
public func JPH_HingeConstraint_GetLocalSpaceHingeAxis2_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpaceHingeAxis2(constraint, result)
    }
}

/**
 * @brief 获取刚体 1 局部空间法线轴（对应 JPH_HingeConstraint_GetLocalSpaceNormalAxis1）
 */
public func JPH_HingeConstraint_GetLocalSpaceNormalAxis1_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpaceNormalAxis1(constraint, result)
    }
}

/**
 * @brief 获取刚体 2 局部空间法线轴（对应 JPH_HingeConstraint_GetLocalSpaceNormalAxis2）
 */
public func JPH_HingeConstraint_GetLocalSpaceNormalAxis2_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLocalSpaceNormalAxis2(constraint, result)
    }
}

/**
 * @brief 获取当前旋转角（对应 JPH_HingeConstraint_GetCurrentAngle）
 */
public func JPH_HingeConstraint_GetCurrentAngle_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetCurrentAngle(constraint)
    }
}

/**
 * @brief 设置最大摩擦扭矩（对应 JPH_HingeConstraint_SetMaxFrictionTorque）
 */
public func JPH_HingeConstraint_SetMaxFrictionTorque_cj(
    constraint: CPointer<Unit>, frictionTorque: Float32
): Unit {
    unsafe {
        JPH_HingeConstraint_SetMaxFrictionTorque(constraint, frictionTorque)
    }
}

/**
 * @brief 获取最大摩擦扭矩（对应 JPH_HingeConstraint_GetMaxFrictionTorque）
 */
public func JPH_HingeConstraint_GetMaxFrictionTorque_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetMaxFrictionTorque(constraint)
    }
}

/**
 * @brief 设置电机设置（对应 JPH_HingeConstraint_SetMotorSettings）
 */
public func JPH_HingeConstraint_SetMotorSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHMotorSettings>
): Unit {
    unsafe {
        JPH_HingeConstraint_SetMotorSettings(constraint, settings)
    }
}

/**
 * @brief 获取电机设置（对应 JPH_HingeConstraint_GetMotorSettings）
 */
public func JPH_HingeConstraint_GetMotorSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHMotorSettings>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetMotorSettings(constraint, result)
    }
}

/**
 * @brief 设置电机状态（对应 JPH_HingeConstraint_SetMotorState）
 */
public func JPH_HingeConstraint_SetMotorState_cj(constraint: CPointer<Unit>, state: UInt32): Unit {
    unsafe {
        JPH_HingeConstraint_SetMotorState(constraint, state)
    }
}

/**
 * @brief 获取电机状态（对应 JPH_HingeConstraint_GetMotorState）
 */
public func JPH_HingeConstraint_GetMotorState_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_HingeConstraint_GetMotorState(constraint)
    }
}

/**
 * @brief 设置目标角速度（对应 JPH_HingeConstraint_SetTargetAngularVelocity）
 */
public func JPH_HingeConstraint_SetTargetAngularVelocity_cj(
    constraint: CPointer<Unit>, angularVelocity: Float32
): Unit {
    unsafe {
        JPH_HingeConstraint_SetTargetAngularVelocity(constraint, angularVelocity)
    }
}

/**
 * @brief 获取目标角速度（对应 JPH_HingeConstraint_GetTargetAngularVelocity）
 */
public func JPH_HingeConstraint_GetTargetAngularVelocity_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetTargetAngularVelocity(constraint)
    }
}

/**
 * @brief 设置目标角度（对应 JPH_HingeConstraint_SetTargetAngle）
 */
public func JPH_HingeConstraint_SetTargetAngle_cj(constraint: CPointer<Unit>, angle: Float32): Unit {
    unsafe {
        JPH_HingeConstraint_SetTargetAngle(constraint, angle)
    }
}

/**
 * @brief 获取目标角度（对应 JPH_HingeConstraint_GetTargetAngle）
 */
public func JPH_HingeConstraint_GetTargetAngle_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetTargetAngle(constraint)
    }
}

/**
 * @brief 设置旋转角度限位（对应 JPH_HingeConstraint_SetLimits）
 */
public func JPH_HingeConstraint_SetLimits_cj(
    constraint: CPointer<Unit>, inLimitsMin: Float32, inLimitsMax: Float32
): Unit {
    unsafe {
        JPH_HingeConstraint_SetLimits(constraint, inLimitsMin, inLimitsMax)
    }
}

/**
 * @brief 获取最小角度限位（对应 JPH_HingeConstraint_GetLimitsMin）
 */
public func JPH_HingeConstraint_GetLimitsMin_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetLimitsMin(constraint)
    }
}

/**
 * @brief 获取最大角度限位（对应 JPH_HingeConstraint_GetLimitsMax）
 */
public func JPH_HingeConstraint_GetLimitsMax_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetLimitsMax(constraint)
    }
}

/**
 * @brief 是否有角度限位（对应 JPH_HingeConstraint_HasLimits）
 */
public func JPH_HingeConstraint_HasLimits_cj(constraint: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_HingeConstraint_HasLimits(constraint)
    }
}

/**
 * @brief 获取限位弹簧设置（对应 JPH_HingeConstraint_GetLimitsSpringSettings）
 */
public func JPH_HingeConstraint_GetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetLimitsSpringSettings(constraint, result)
    }
}

/**
 * @brief 设置限位弹簧设置（对应 JPH_HingeConstraint_SetLimitsSpringSettings）
 */
public func JPH_HingeConstraint_SetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_HingeConstraint_SetLimitsSpringSettings(constraint, settings)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_HingeConstraint_GetTotalLambdaPosition）
 */
public func JPH_HingeConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

/**
 * @brief 获取旋转 lambda（对应 JPH_HingeConstraint_GetTotalLambdaRotation）
 */
public func JPH_HingeConstraint_GetTotalLambdaRotation_cj(
    constraint: CPointer<Unit>, rotation: CPointer<Float32>
): Unit {
    unsafe {
        JPH_HingeConstraint_GetTotalLambdaRotation(constraint, rotation)
    }
}

/**
 * @brief 获取旋转限位 lambda（对应 JPH_HingeConstraint_GetTotalLambdaRotationLimits）
 */
public func JPH_HingeConstraint_GetTotalLambdaRotationLimits_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetTotalLambdaRotationLimits(constraint)
    }
}

/**
 * @brief 获取电机 lambda（对应 JPH_HingeConstraint_GetTotalLambdaMotor）
 */
public func JPH_HingeConstraint_GetTotalLambdaMotor_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_HingeConstraint_GetTotalLambdaMotor(constraint)
    }
}

// =============================================================================
// 调试渲染器（DebugRenderer）
// =============================================================================

/**
 * @brief 设置调试渲染器回调表（对应 JPH_DebugRenderer_SetProcs）
 */
public func JPH_DebugRenderer_SetProcs_cj(procs: CPointer<JPHDebugRendererProcs>): Unit {
    unsafe {
        JPH_DebugRenderer_SetProcs(procs)
    }
}

/**
 * @brief 创建调试渲染器实例（对应 JPH_DebugRenderer_Create）
 */
public func JPH_DebugRenderer_Create_cj(userData: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_DebugRenderer_Create(userData)
    }
}

/**
 * @brief 销毁调试渲染器（对应 JPH_DebugRenderer_Destroy）
 */
public func JPH_DebugRenderer_Destroy_cj(renderer: CPointer<Unit>): Unit {
    unsafe {
        JPH_DebugRenderer_Destroy(renderer)
    }
}

/**
 * @brief 调试渲染器下一帧（对应 JPH_DebugRenderer_NextFrame）
 */
public func JPH_DebugRenderer_NextFrame_cj(renderer: CPointer<Unit>): Unit {
    unsafe {
        JPH_DebugRenderer_NextFrame(renderer)
    }
}

/**
 * @brief 设置相机位置（对应 JPH_DebugRenderer_SetCameraPos）
 */
public func JPH_DebugRenderer_SetCameraPos_cj(renderer: CPointer<Unit>, position: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_DebugRenderer_SetCameraPos(renderer, position)
    }
}

/**
 * @brief 绘制线段（对应 JPH_DebugRenderer_DrawLine）
 */
public func JPH_DebugRenderer_DrawLine_cj(
    renderer: CPointer<Unit>, from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, color: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawLine(renderer, from, to, color)
    }
}

/**
 * @brief 绘制线框包围盒（对应 JPH_DebugRenderer_DrawWireBox）
 */
public func JPH_DebugRenderer_DrawWireBox_cj(
    renderer: CPointer<Unit>, box: CPointer<JPHAABox>, color: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawWireBox(renderer, box, color)
    }
}

/**
 * @brief 绘制线框包围盒（带变换矩阵，对应 JPH_DebugRenderer_DrawWireBox2）
 */
public func JPH_DebugRenderer_DrawWireBox2_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, box: CPointer<JPHAABox>, color: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawWireBox2(renderer, matrix, box, color)
    }
}

/**
 * @brief 绘制标记点（对应 JPH_DebugRenderer_DrawMarker）
 */
public func JPH_DebugRenderer_DrawMarker_cj(
    renderer: CPointer<Unit>, position: CPointer<JPHVec3>, color: UInt32, size: Float32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawMarker(renderer, position, color, size)
    }
}

/**
 * @brief 绘制箭头（对应 JPH_DebugRenderer_DrawArrow）
 */
public func JPH_DebugRenderer_DrawArrow_cj(
    renderer: CPointer<Unit>, from: CPointer<JPHVec3>, to: CPointer<JPHVec3>, color: UInt32, size: Float32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawArrow(renderer, from, to, color, size)
    }
}

/**
 * @brief 绘制坐标系（对应 JPH_DebugRenderer_DrawCoordinateSystem）
 */
public func JPH_DebugRenderer_DrawCoordinateSystem_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, size: Float32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawCoordinateSystem(renderer, matrix, size)
    }
}

/**
 * @brief 绘制平面（对应 JPH_DebugRenderer_DrawPlane）
 */
public func JPH_DebugRenderer_DrawPlane_cj(
    renderer: CPointer<Unit>, point: CPointer<JPHVec3>, normal: CPointer<JPHVec3>,
    color: UInt32, size: Float32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawPlane(renderer, point, normal, color, size)
    }
}

/**
 * @brief 绘制线框三角形（对应 JPH_DebugRenderer_DrawWireTriangle）
 */
public func JPH_DebugRenderer_DrawWireTriangle_cj(
    renderer: CPointer<Unit>, v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>,
    v3: CPointer<JPHVec3>, color: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawWireTriangle(renderer, v1, v2, v3, color)
    }
}

/**
 * @brief 绘制线框球体（对应 JPH_DebugRenderer_DrawWireSphere）
 */
public func JPH_DebugRenderer_DrawWireSphere_cj(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, color: UInt32, level: Int32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawWireSphere(renderer, center, radius, color, level)
    }
}

/**
 * @brief 绘制线框单位球体（对应 JPH_DebugRenderer_DrawWireUnitSphere）
 */
public func JPH_DebugRenderer_DrawWireUnitSphere_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, color: UInt32, level: Int32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawWireUnitSphere(renderer, matrix, color, level)
    }
}

/**
 * @brief 绘制三角形（对应 JPH_DebugRenderer_DrawTriangle）
 */
public func JPH_DebugRenderer_DrawTriangle_cj(
    renderer: CPointer<Unit>, v1: CPointer<JPHVec3>, v2: CPointer<JPHVec3>,
    v3: CPointer<JPHVec3>, color: UInt32, castShadow: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawTriangle(renderer, v1, v2, v3, color, castShadow)
    }
}

/**
 * @brief 绘制包围盒（对应 JPH_DebugRenderer_DrawBox）
 */
public func JPH_DebugRenderer_DrawBox_cj(
    renderer: CPointer<Unit>, box: CPointer<JPHAABox>, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawBox(renderer, box, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制包围盒（带变换矩阵，对应 JPH_DebugRenderer_DrawBox2）
 */
public func JPH_DebugRenderer_DrawBox2_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, box: CPointer<JPHAABox>, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawBox2(renderer, matrix, box, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制球体（对应 JPH_DebugRenderer_DrawSphere）
 */
public func JPH_DebugRenderer_DrawSphere_cj(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawSphere(renderer, center, radius, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制单位球体（对应 JPH_DebugRenderer_DrawUnitSphere）
 */
public func JPH_DebugRenderer_DrawUnitSphere_cj(
    renderer: CPointer<Unit>, matrix: JPHMat4, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawUnitSphere(renderer, matrix, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制胶囊体（对应 JPH_DebugRenderer_DrawCapsule）
 */
public func JPH_DebugRenderer_DrawCapsule_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, halfHeightOfCylinder: Float32, radius: Float32,
    color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawCapsule(
            renderer, matrix, halfHeightOfCylinder, radius, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制圆柱体（对应 JPH_DebugRenderer_DrawCylinder）
 */
public func JPH_DebugRenderer_DrawCylinder_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, halfHeight: Float32, radius: Float32,
    color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawCylinder(renderer, matrix, halfHeight, radius, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制开放锥体（对应 JPH_DebugRenderer_DrawOpenCone）
 */
public func JPH_DebugRenderer_DrawOpenCone_cj(
    renderer: CPointer<Unit>, top: CPointer<JPHVec3>, axis: CPointer<JPHVec3>,
    perpendicular: CPointer<JPHVec3>, halfAngle: Float32, length: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawOpenCone(
            renderer, top, axis, perpendicular, halfAngle, length, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制摆动锥限位（对应 JPH_DebugRenderer_DrawSwingConeLimits）
 */
public func JPH_DebugRenderer_DrawSwingConeLimits_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, swingYHalfAngle: Float32,
    swingZHalfAngle: Float32, edgeLength: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawSwingConeLimits(
            renderer, matrix, swingYHalfAngle, swingZHalfAngle, edgeLength, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制摆动金字塔限位（对应 JPH_DebugRenderer_DrawSwingPyramidLimits）
 */
public func JPH_DebugRenderer_DrawSwingPyramidLimits_cj(
    renderer: CPointer<Unit>, matrix: CPointer<JPHMat4>, minSwingYAngle: Float32,
    maxSwingYAngle: Float32, minSwingZAngle: Float32, maxSwingZAngle: Float32,
    edgeLength: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawSwingPyramidLimits(
            renderer, matrix, minSwingYAngle, maxSwingYAngle,
            minSwingZAngle, maxSwingZAngle, edgeLength, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制饼图（对应 JPH_DebugRenderer_DrawPie）
 */
public func JPH_DebugRenderer_DrawPie_cj(
    renderer: CPointer<Unit>, center: CPointer<JPHVec3>, radius: Float32, normal: CPointer<JPHVec3>,
    axis: CPointer<JPHVec3>, minAngle: Float32, maxAngle: Float32, color: UInt32,
    castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawPie(
            renderer, center, radius, normal, axis, minAngle, maxAngle, color, castShadow, drawMode)
    }
}

/**
 * @brief 绘制锥台圆柱体（对应 JPH_DebugRenderer_DrawTaperedCylinder）
 */
public func JPH_DebugRenderer_DrawTaperedCylinder_cj(
    renderer: CPointer<Unit>, inMatrix: CPointer<JPHMat4>, top: Float32, bottom: Float32,
    topRadius: Float32, bottomRadius: Float32, color: UInt32, castShadow: UInt32, drawMode: UInt32
): Unit {
    unsafe {
        JPH_DebugRenderer_DrawTaperedCylinder(
            renderer, inMatrix, top, bottom, topRadius, bottomRadius, color, castShadow, drawMode)
    }
}

// =============================================================================
// 线性曲线（LinearCurve）
// =============================================================================

/**
 * @brief 创建线性曲线（对应 JPH_LinearCurve_Create）
 */
public func JPH_LinearCurve_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_LinearCurve_Create()
    }
}

/**
 * @brief 销毁线性曲线（对应 JPH_LinearCurve_Destroy）
 */
public func JPH_LinearCurve_Destroy_cj(curve: CPointer<Unit>): Unit {
    unsafe {
        JPH_LinearCurve_Destroy(curve)
    }
}

/**
 * @brief 清空线性曲线（对应 JPH_LinearCurve_Clear）
 */
public func JPH_LinearCurve_Clear_cj(curve: CPointer<Unit>): Unit {
    unsafe {
        JPH_LinearCurve_Clear(curve)
    }
}

/**
 * @brief 预留曲线点数（对应 JPH_LinearCurve_Reserve）
 */
public func JPH_LinearCurve_Reserve_cj(curve: CPointer<Unit>, numPoints: UInt32): Unit {
    unsafe {
        JPH_LinearCurve_Reserve(curve, numPoints)
    }
}

/**
 * @brief 添加曲线点（对应 JPH_LinearCurve_AddPoint）
 */
public func JPH_LinearCurve_AddPoint_cj(curve: CPointer<Unit>, x: Float32, y: Float32): Unit {
    unsafe {
        JPH_LinearCurve_AddPoint(curve, x, y)
    }
}

/**
 * @brief 排序曲线点（对应 JPH_LinearCurve_Sort）
 */
public func JPH_LinearCurve_Sort_cj(curve: CPointer<Unit>): Unit {
    unsafe {
        JPH_LinearCurve_Sort(curve)
    }
}

/**
 * @brief 获取最小 X（对应 JPH_LinearCurve_GetMinX）
 */
public func JPH_LinearCurve_GetMinX_cj(curve: CPointer<Unit>): Float32 {
    unsafe {
        JPH_LinearCurve_GetMinX(curve)
    }
}

/**
 * @brief 获取最大 X（对应 JPH_LinearCurve_GetMaxX）
 */
public func JPH_LinearCurve_GetMaxX_cj(curve: CPointer<Unit>): Float32 {
    unsafe {
        JPH_LinearCurve_GetMaxX(curve)
    }
}

/**
 * @brief 获取指定 X 处的插值（对应 JPH_LinearCurve_GetValue）
 */
public func JPH_LinearCurve_GetValue_cj(curve: CPointer<Unit>, x: Float32): Float32 {
    unsafe {
        JPH_LinearCurve_GetValue(curve, x)
    }
}

/**
 * @brief 获取线性曲线点数（对应 JPH_LinearCurve_GetPointCount）
 */
public func JPH_LinearCurve_GetPointCount_cj(curve: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_LinearCurve_GetPointCount(curve)
    }
}

/**
 * @brief 获取指定曲线点（对应 JPH_LinearCurve_GetPoint）
 */
public func JPH_LinearCurve_GetPoint_cj(
    curve: CPointer<Unit>, index: UInt32, result: CPointer<JPHPoint>
): Unit {
    unsafe {
        JPH_LinearCurve_GetPoint(curve, index, result)
    }
}

/**
 * @brief 获取曲线点数组指针（对应 JPH_LinearCurve_GetPoints）
 */
public func JPH_LinearCurve_GetPoints_cj(curve: CPointer<Unit>, points: CPointer<JPHPoint>, count: CPointer<UInt32>): Unit {
    unsafe {
        JPH_LinearCurve_GetPoints(curve, points, count)
    }
}

// =============================================================================
// 运动属性（MotionProperties）
// =============================================================================

/**
 * @brief 获取允许自由度（对应 JPH_MotionProperties_GetAllowedDOFs）
 */
public func JPH_MotionProperties_GetAllowedDOFs_cj(properties: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_MotionProperties_GetAllowedDOFs(properties)
    }
}

/**
 * @brief 设置线阻尼（对应 JPH_MotionProperties_SetLinearDamping）
 */
public func JPH_MotionProperties_SetLinearDamping_cj(properties: CPointer<Unit>, damping: Float32): Unit {
    unsafe {
        JPH_MotionProperties_SetLinearDamping(properties, damping)
    }
}

/**
 * @brief 获取线阻尼（对应 JPH_MotionProperties_GetLinearDamping）
 */
public func JPH_MotionProperties_GetLinearDamping_cj(properties: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotionProperties_GetLinearDamping(properties)
    }
}

/**
 * @brief 设置角阻尼（对应 JPH_MotionProperties_SetAngularDamping）
 */
public func JPH_MotionProperties_SetAngularDamping_cj(properties: CPointer<Unit>, damping: Float32): Unit {
    unsafe {
        JPH_MotionProperties_SetAngularDamping(properties, damping)
    }
}

/**
 * @brief 获取角阻尼（对应 JPH_MotionProperties_GetAngularDamping）
 */
public func JPH_MotionProperties_GetAngularDamping_cj(properties: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotionProperties_GetAngularDamping(properties)
    }
}

/**
 * @brief 设置质量属性（对应 JPH_MotionProperties_SetMassProperties）
 */
public func JPH_MotionProperties_SetMassProperties_cj(
    properties: CPointer<Unit>, allowedDOFs: UInt32, massProperties: CPointer<JPHMassProperties>
): Unit {
    unsafe {
        JPH_MotionProperties_SetMassProperties(properties, allowedDOFs, massProperties)
    }
}

/**
 * @brief 获取逆质量（未检查版本，对应 JPH_MotionProperties_GetInverseMassUnchecked）
 */
public func JPH_MotionProperties_GetInverseMassUnchecked_cj(properties: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotionProperties_GetInverseMassUnchecked(properties)
    }
}

/**
 * @brief 设置逆质量（对应 JPH_MotionProperties_SetInverseMass）
 */
public func JPH_MotionProperties_SetInverseMass_cj(properties: CPointer<Unit>, inverseMass: Float32): Unit {
    unsafe {
        JPH_MotionProperties_SetInverseMass(properties, inverseMass)
    }
}

/**
 * @brief 获取逆惯量对角线（对应 JPH_MotionProperties_GetInverseInertiaDiagonal）
 */
public func JPH_MotionProperties_GetInverseInertiaDiagonal_cj(
    properties: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_MotionProperties_GetInverseInertiaDiagonal(properties, result)
    }
}

/**
 * @brief 获取惯量旋转（对应 JPH_MotionProperties_GetInertiaRotation）
 */
public func JPH_MotionProperties_GetInertiaRotation_cj(
    properties: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_MotionProperties_GetInertiaRotation(properties, result)
    }
}

/**
 * @brief 设置逆惯量（对应 JPH_MotionProperties_SetInverseInertia）
 */
public func JPH_MotionProperties_SetInverseInertia_cj(
    properties: CPointer<Unit>, diagonal: CPointer<JPHVec3>, rot: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_MotionProperties_SetInverseInertia(properties, diagonal, rot)
    }
}

/**
 * @brief 缩放到指定质量（对应 JPH_MotionProperties_ScaleToMass）
 */
public func JPH_MotionProperties_ScaleToMass_cj(properties: CPointer<Unit>, mass: Float32): Unit {
    unsafe {
        JPH_MotionProperties_ScaleToMass(properties, mass)
    }
}

// =============================================================================
// 临时分配器（TempAllocator）/ 回调作业系统 / 更新2
// =============================================================================

/**
 * @brief 创建临时分配器（对应 JPH_TempAllocator_Create）
 */
public func JPH_TempAllocator_Create_cj(size: UInt32): CPointer<Unit> {
    unsafe {
        JPH_TempAllocator_Create(size)
    }
}

/**
 * @brief 创建 malloc 式临时分配器（对应 JPH_TempAllocatorMalloc_Create）
 */
public func JPH_TempAllocatorMalloc_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_TempAllocatorMalloc_Create()
    }
}

/**
 * @brief 销毁临时分配器（对应 JPH_TempAllocator_Destroy）
 */
public func JPH_TempAllocator_Destroy_cj(allocator: CPointer<Unit>): Unit {
    unsafe {
        JPH_TempAllocator_Destroy(allocator)
    }
}

/**
 * @brief 步进物理世界一帧（带临时分配器，对应 JPH_PhysicsSystem_Update2）
 */
public func JPH_PhysicsSystem_Update2_cj(
    system: CPointer<Unit>, deltaTime: Float32, collisionSteps: Int32,
    tempAllocator: CPointer<Unit>, jobSystem: CPointer<Unit>
): UInt32 {
    unsafe {
        JPH_PhysicsSystem_Update2(system, deltaTime, collisionSteps, tempAllocator, jobSystem)
    }
}

/**
 * @brief 创建回调作业系统（对应 JPH_JobSystemCallback_Create）
 */
public func JPH_JobSystemCallback_Create_cj(config: CPointer<JPHJobSystemConfig>): CPointer<Unit> {
    unsafe {
        JPH_JobSystemCallback_Create(config)
    }
}

// =============================================================================
// 补充：PhysicsSystem 获取刚体指针 / RagdollSettings 附加 / 变速箱设置
// =============================================================================

/**
 * @brief 获取刚体指针（对应 JPH_PhysicsSystem_GetBodyPtr）
 */
public func JPH_PhysicsSystem_GetBodyPtr_cj(system: CPointer<Unit>, bodyID: UInt32): CPointer<Unit> {
    unsafe {
        JPH_PhysicsSystem_GetBodyPtr(system, bodyID)
    }
}

/**
 * @brief 设置部件对象层（对应 JPH_RagdollSettings_SetPartObjectLayer）
 */
public func JPH_RagdollSettings_SetPartObjectLayer_cj(
    settings: CPointer<Unit>, partIndex: Int32, layer: UInt32
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartObjectLayer(settings, partIndex, layer)
    }
}

/**
 * @brief 设置部件质量属性（对应 JPH_RagdollSettings_SetPartMassProperties）
 */
public func JPH_RagdollSettings_SetPartMassProperties_cj(
    settings: CPointer<Unit>, partIndex: Int32, mass: Float32
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartMassProperties(settings, partIndex, mass)
    }
}

/**
 * @brief 创建布娃娃实例（对应 JPH_RagdollSettings_CreateRagdoll）
 */
public func JPH_RagdollSettings_CreateRagdoll_cj(
    settings: CPointer<Unit>, system: CPointer<Unit>, collisionGroup: UInt32, userData: UInt64
): CPointer<Unit> {
    unsafe {
        JPH_RagdollSettings_CreateRagdoll(settings, system, collisionGroup, userData)
    }
}

/**
 * @brief 获取履带车辆控制器变速箱设置（对应 JPH_TrackedVehicleControllerSettings_GetTransmission）
 */
public func JPH_TrackedVehicleControllerSettings_GetTransmission_cj(
    settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_TrackedVehicleControllerSettings_GetTransmission(settings)
    }
}

/**
 * @brief 设置履带车辆控制器变速箱设置（对应 JPH_TrackedVehicleControllerSettings_SetTransmission）
 */
public func JPH_TrackedVehicleControllerSettings_SetTransmission_cj(
    settings: CPointer<Unit>, value: CPointer<Unit>
): Unit {
    unsafe {
        JPH_TrackedVehicleControllerSettings_SetTransmission(settings, value)
    }
}

/**
 * @brief 添加差速器设置（对应 JPH_WheeledVehicleControllerSettings_AddDifferential）
 * @param[en] leftWheel The left wheel index (-1 for none)
 * @param[en] rightWheel The right wheel index (-1 for none)
 * @note C 端按标量索引构造默认差速器（ratio 3.5 / limitedSlip 1.4 / torque 1.0）
 */
public func JPH_WheeledVehicleControllerSettings_AddDifferential_cj(
    settings: CPointer<Unit>, leftWheel: Int32, rightWheel: Int32
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_AddDifferential(settings, leftWheel, rightWheel)
    }
}

/**
 * @brief 获取轮式车辆控制器变速箱设置（对应 JPH_WheeledVehicleControllerSettings_GetTransmission）
 */
public func JPH_WheeledVehicleControllerSettings_GetTransmission_cj(
    settings: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_WheeledVehicleControllerSettings_GetTransmission(settings)
    }
}

/**
 * @brief 设置轮式车辆控制器变速箱设置（对应 JPH_WheeledVehicleControllerSettings_SetTransmission）
 */
public func JPH_WheeledVehicleControllerSettings_SetTransmission_cj(
    settings: CPointer<Unit>, value: CPointer<Unit>
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetTransmission(settings, value)
    }
}

// =============================================================================
// 摩托车控制器（MotorcycleController）
// =============================================================================

/**
 * @brief 创建摩托车控制器设置（对应 JPH_MotorcycleControllerSettings_Create）
 */
public func JPH_MotorcycleControllerSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_MotorcycleControllerSettings_Create()
    }
}

/**
 * @brief 获取最大倾斜角（对应 JPH_MotorcycleControllerSettings_GetMaxLeanAngle）
 */
public func JPH_MotorcycleControllerSettings_GetMaxLeanAngle_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetMaxLeanAngle(settings)
    }
}

/**
 * @brief 设置最大倾斜角（对应 JPH_MotorcycleControllerSettings_SetMaxLeanAngle）
 */
public func JPH_MotorcycleControllerSettings_SetMaxLeanAngle_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetMaxLeanAngle(settings, value)
    }
}

/**
 * @brief 获取倾斜平滑因子（对应 JPH_MotorcycleControllerSettings_GetLeanSmoothingFactor）
 */
public func JPH_MotorcycleControllerSettings_GetLeanSmoothingFactor_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetLeanSmoothingFactor(settings)
    }
}

/**
 * @brief 设置倾斜平滑因子（对应 JPH_MotorcycleControllerSettings_SetLeanSmoothingFactor）
 */
public func JPH_MotorcycleControllerSettings_SetLeanSmoothingFactor_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetLeanSmoothingFactor(settings, value)
    }
}

/**
 * @brief 获取倾斜弹簧常数（对应 JPH_MotorcycleControllerSettings_GetLeanSpringConstant）
 */
public func JPH_MotorcycleControllerSettings_GetLeanSpringConstant_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetLeanSpringConstant(settings)
    }
}

/**
 * @brief 设置倾斜弹簧常数（对应 JPH_MotorcycleControllerSettings_SetLeanSpringConstant）
 */
public func JPH_MotorcycleControllerSettings_SetLeanSpringConstant_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetLeanSpringConstant(settings, value)
    }
}

/**
 * @brief 获取倾斜弹簧阻尼（对应 JPH_MotorcycleControllerSettings_GetLeanSpringDamping）
 */
public func JPH_MotorcycleControllerSettings_GetLeanSpringDamping_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetLeanSpringDamping(settings)
    }
}

/**
 * @brief 设置倾斜弹簧阻尼（对应 JPH_MotorcycleControllerSettings_SetLeanSpringDamping）
 */
public func JPH_MotorcycleControllerSettings_SetLeanSpringDamping_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetLeanSpringDamping(settings, value)
    }
}

/**
 * @brief 获取倾斜弹簧积分系数（对应 JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient）
 */
public func JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficient(settings)
    }
}

/**
 * @brief 设置倾斜弹簧积分系数（对应 JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient）
 */
public func JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficient(settings, value)
    }
}

/**
 * @brief 获取倾斜弹簧积分系数衰减（对应 JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay）
 */
public func JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleControllerSettings_GetLeanSpringIntegrationCoefficientDecay(settings)
    }
}

/**
 * @brief 设置倾斜弹簧积分系数衰减（对应 JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay）
 */
public func JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleControllerSettings_SetLeanSpringIntegrationCoefficientDecay(settings, value)
    }
}

/**
 * @brief 是否启用倾斜控制器（对应 JPH_MotorcycleController_IsLeanControllerEnabled）
 */
public func JPH_MotorcycleController_IsLeanControllerEnabled_cj(controller: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_MotorcycleController_IsLeanControllerEnabled(controller)
    }
}

/**
 * @brief 启用/禁用倾斜控制器（对应 JPH_MotorcycleController_EnableLeanController）
 */
public func JPH_MotorcycleController_EnableLeanController_cj(controller: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_MotorcycleController_EnableLeanController(controller, value)
    }
}

/**
 * @brief 是否启用转向倾斜限位（对应 JPH_MotorcycleController_IsLeanSteeringLimitEnabled）
 */
public func JPH_MotorcycleController_IsLeanSteeringLimitEnabled_cj(controller: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_MotorcycleController_IsLeanSteeringLimitEnabled(controller)
    }
}

/**
 * @brief 启用/禁用转向倾斜限位（对应 JPH_MotorcycleController_EnableLeanSteeringLimit）
 */
public func JPH_MotorcycleController_EnableLeanSteeringLimit_cj(controller: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_MotorcycleController_EnableLeanSteeringLimit(controller, value)
    }
}

/**
 * @brief 获取倾斜平滑因子（对应 JPH_MotorcycleController_GetLeanSmoothingFactor）
 */
public func JPH_MotorcycleController_GetLeanSmoothingFactor_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetLeanSmoothingFactor(controller)
    }
}

/**
 * @brief 设置倾斜平滑因子（对应 JPH_MotorcycleController_SetLeanSmoothingFactor）
 */
public func JPH_MotorcycleController_SetLeanSmoothingFactor_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleController_SetLeanSmoothingFactor(controller, value)
    }
}

/**
 * @brief 获取倾斜弹簧常数（对应 JPH_MotorcycleController_GetLeanSpringConstant）
 */
public func JPH_MotorcycleController_GetLeanSpringConstant_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetLeanSpringConstant(controller)
    }
}

/**
 * @brief 设置倾斜弹簧常数（对应 JPH_MotorcycleController_SetLeanSpringConstant）
 */
public func JPH_MotorcycleController_SetLeanSpringConstant_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleController_SetLeanSpringConstant(controller, value)
    }
}

/**
 * @brief 获取倾斜弹簧阻尼（对应 JPH_MotorcycleController_GetLeanSpringDamping）
 */
public func JPH_MotorcycleController_GetLeanSpringDamping_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetLeanSpringDamping(controller)
    }
}

/**
 * @brief 设置倾斜弹簧阻尼（对应 JPH_MotorcycleController_SetLeanSpringDamping）
 */
public func JPH_MotorcycleController_SetLeanSpringDamping_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleController_SetLeanSpringDamping(controller, value)
    }
}

/**
 * @brief 获取倾斜弹簧积分系数（对应 JPH_MotorcycleController_GetLeanSpringIntegrationCoefficient）
 */
public func JPH_MotorcycleController_GetLeanSpringIntegrationCoefficient_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetLeanSpringIntegrationCoefficient(controller)
    }
}

/**
 * @brief 设置倾斜弹簧积分系数（对应 JPH_MotorcycleController_SetLeanSpringIntegrationCoefficient）
 */
public func JPH_MotorcycleController_SetLeanSpringIntegrationCoefficient_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleController_SetLeanSpringIntegrationCoefficient(controller, value)
    }
}

/**
 * @brief 获取倾斜弹簧积分系数衰减（对应 JPH_MotorcycleController_GetLeanSpringIntegrationCoefficientDecay）
 */
public func JPH_MotorcycleController_GetLeanSpringIntegrationCoefficientDecay_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetLeanSpringIntegrationCoefficientDecay(controller)
    }
}

/**
 * @brief 设置倾斜弹簧积分系数衰减（对应 JPH_MotorcycleController_SetLeanSpringIntegrationCoefficientDecay）
 */
public func JPH_MotorcycleController_SetLeanSpringIntegrationCoefficientDecay_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_MotorcycleController_SetLeanSpringIntegrationCoefficientDecay(controller, value)
    }
}

/**
 * @brief 获取轴距（对应 JPH_MotorcycleController_GetWheelBase）
 */
public func JPH_MotorcycleController_GetWheelBase_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_MotorcycleController_GetWheelBase(controller)
    }
}

// =============================================================================
// 窄相查询补充：CastRay2 / CastRay3 / CollidePoint / CollidePoint2 / CastShape / CastShape2 / CollideShape / CollideShape2
// =============================================================================

/**
 * @brief 窄相射线检测（带收集器回调，对应 JPH_NarrowPhaseQuery_CastRay2）
 */
public func JPH_NarrowPhaseQuery_CastRay2_cj(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CastRay2(
            query, origin, direction, rayCastSettings, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相射线检测（完整版，对应 JPH_NarrowPhaseQuery_CastRay3）
 */
public func JPH_NarrowPhaseQuery_CastRay3_cj(
    query: CPointer<Unit>, origin: CPointer<JPHVec3>, direction: CPointer<JPHVec3>,
    rayCastSettings: CPointer<JPHRayCastSettings>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHRayCastResult>) -> Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CastRay3(
            query, origin, direction, rayCastSettings, collectorType, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相点碰撞检测（对应 JPH_NarrowPhaseQuery_CollidePoint）
 */
public func JPH_NarrowPhaseQuery_CollidePoint_cj(
    query: CPointer<Unit>, point: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CollidePoint(
            query, point, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相点碰撞检测（完整版，对应 JPH_NarrowPhaseQuery_CollidePoint2）
 */
public func JPH_NarrowPhaseQuery_CollidePoint2_cj(
    query: CPointer<Unit>, point: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHCollidePointResult>) -> Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CollidePoint2(
            query, point, collectorType, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相形状碰撞检测（对应 JPH_NarrowPhaseQuery_CollideShape）
 */
public func JPH_NarrowPhaseQuery_CollideShape_cj(
    query: CPointer<Unit>, shape: CPointer<Unit>, shapeScale: CPointer<JPHVec3>,
    centerOfMassTransform: CPointer<JPHMat4>, collideShapeSettings: CPointer<JPHCollideShapeSettings>,
    baseOffset: CPointer<JPHVec3>, callback: CPointer<Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>,
    shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CollideShape(
            query, shape, shapeScale, centerOfMassTransform, collideShapeSettings,
            baseOffset, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相形状碰撞检测（完整版，对应 JPH_NarrowPhaseQuery_CollideShape2）
 */
public func JPH_NarrowPhaseQuery_CollideShape2_cj(
    query: CPointer<Unit>, shape: CPointer<Unit>, scale: CPointer<JPHVec3>,
    centerOfMassTransform: CPointer<JPHMat4>, settings: CPointer<JPHCollideShapeSettings>,
    baseOffset: CPointer<JPHVec3>, collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHCollideShapeResult>) -> Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CollideShape2(
            query, shape, scale, centerOfMassTransform, settings,
            baseOffset, collectorType, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相形状投射（对应 JPH_NarrowPhaseQuery_CastShape）
 */
public func JPH_NarrowPhaseQuery_CastShape_cj(
    query: CPointer<Unit>, shape: CPointer<Unit>,
    worldTransform: CPointer<JPHMat4>, direction: CPointer<JPHVec3>,
    shapeCastSettings: CPointer<JPHShapeCastSettings>, baseOffset: CPointer<JPHVec3>,
    callback: CPointer<Unit>, userData: CPointer<Unit>,
    broadPhaseLayerFilter: CPointer<Unit>, objectLayerFilter: CPointer<Unit>,
    bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CastShape(
            query, shape, worldTransform, direction,
            shapeCastSettings, baseOffset, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

/**
 * @brief 窄相形状投射（完整版，对应 JPH_NarrowPhaseQuery_CastShape2）
 */
public func JPH_NarrowPhaseQuery_CastShape2_cj(
    query: CPointer<Unit>, shape: CPointer<Unit>,
    worldTransform: CPointer<JPHMat4>, direction: CPointer<JPHVec3>,
    settings: CPointer<JPHShapeCastSettings>, baseOffset: CPointer<JPHVec3>,
    collectorType: UInt32,
    callback: CFunc<(CPointer<Unit>, CPointer<JPHShapeCastResult>) -> Unit>,
    userData: CPointer<Unit>, broadPhaseLayerFilter: CPointer<Unit>,
    objectLayerFilter: CPointer<Unit>, bodyFilter: CPointer<Unit>, shapeFilter: CPointer<Unit>
): UInt8 {
    unsafe {
        JPH_NarrowPhaseQuery_CastShape2(
            query, shape, worldTransform, direction, settings,
            baseOffset, collectorType, callback, userData,
            broadPhaseLayerFilter, objectLayerFilter, bodyFilter, shapeFilter)
    }
}

// =============================================================================
// 布娃娃设置（RagdollSettings）
// =============================================================================

/**
 * @brief 创建布娃娃设置（对应 JPH_RagdollSettings_Create）
 */
public func JPH_RagdollSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_RagdollSettings_Create()
    }
}

/**
 * @brief 销毁布娃娃设置（对应 JPH_RagdollSettings_Destroy）
 */
public func JPH_RagdollSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_RagdollSettings_Destroy(settings)
    }
}

/**
 * @brief 获取布娃娃设置的骨骼（对应 JPH_RagdollSettings_GetSkeleton）
 */
public func JPH_RagdollSettings_GetSkeleton_cj(character: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_RagdollSettings_GetSkeleton(character)
    }
}

/**
 * @brief 设置布娃娃设置的骨骼（对应 JPH_RagdollSettings_SetSkeleton）
 */
public func JPH_RagdollSettings_SetSkeleton_cj(character: CPointer<Unit>, skeleton: CPointer<Unit>): Unit {
    unsafe {
        JPH_RagdollSettings_SetSkeleton(character, skeleton)
    }
}

/**
 * @brief 稳定布娃娃（对应 JPH_RagdollSettings_Stabilize）
 */
public func JPH_RagdollSettings_Stabilize_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_RagdollSettings_Stabilize(settings)
    }
}

/**
 * @brief 禁用父子碰撞（对应 JPH_RagdollSettings_DisableParentChildCollisions）
 */
public func JPH_RagdollSettings_DisableParentChildCollisions_cj(
    settings: CPointer<Unit>, jointMatrices: CPointer<JPHMat4>, minSeparationDistance: Float32
): Unit {
    unsafe {
        JPH_RagdollSettings_DisableParentChildCollisions(settings, jointMatrices, minSeparationDistance)
    }
}

/**
 * @brief 计算刚体索引到约束索引的映射（对应 JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex）
 */
public func JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex(settings)
    }
}

/**
 * @brief 获取刚体索引对应的约束索引（对应 JPH_RagdollSettings_GetConstraintIndexForBodyIndex）
 */
public func JPH_RagdollSettings_GetConstraintIndexForBodyIndex_cj(
    settings: CPointer<Unit>, bodyIndex: Int32
): Int32 {
    unsafe {
        JPH_RagdollSettings_GetConstraintIndexForBodyIndex(settings, bodyIndex)
    }
}

/**
 * @brief 计算约束索引到刚体对索引的映射（对应 JPH_RagdollSettings_CalculateConstraintIndexToBodyIdxPair）
 */
public func JPH_RagdollSettings_CalculateConstraintIndexToBodyIdxPair_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_RagdollSettings_CalculateConstraintIndexToBodyIdxPair(settings)
    }
}

/**
 * @brief 调整部件数量（对应 JPH_RagdollSettings_ResizeParts）
 */
public func JPH_RagdollSettings_ResizeParts_cj(settings: CPointer<Unit>, count: Int32): Unit {
    unsafe {
        JPH_RagdollSettings_ResizeParts(settings, count)
    }
}

/**
 * @brief 获取部件数量（对应 JPH_RagdollSettings_GetPartCount）
 */
public func JPH_RagdollSettings_GetPartCount_cj(settings: CPointer<Unit>): Int32 {
    unsafe {
        JPH_RagdollSettings_GetPartCount(settings)
    }
}

/**
 * @brief 设置部件形状（对应 JPH_RagdollSettings_SetPartShape）
 */
public func JPH_RagdollSettings_SetPartShape_cj(
    settings: CPointer<Unit>, partIndex: Int32, shape: CPointer<Unit>
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartShape(settings, partIndex, shape)
    }
}

/**
 * @brief 设置部件位置（对应 JPH_RagdollSettings_SetPartPosition）
 */
public func JPH_RagdollSettings_SetPartPosition_cj(
    settings: CPointer<Unit>, partIndex: Int32, position: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartPosition(settings, partIndex, position)
    }
}

/**
 * @brief 设置部件旋转（对应 JPH_RagdollSettings_SetPartRotation）
 */
public func JPH_RagdollSettings_SetPartRotation_cj(
    settings: CPointer<Unit>, partIndex: Int32, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartRotation(settings, partIndex, rotation)
    }
}

/**
 * @brief 设置部件运动类型（对应 JPH_RagdollSettings_SetPartMotionType）
 */
public func JPH_RagdollSettings_SetPartMotionType_cj(
    settings: CPointer<Unit>, partIndex: Int32, motionType: UInt32
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartMotionType(settings, partIndex, motionType)
    }
}

/**
 * @brief 设置部件到父部件的约束（对应 JPH_RagdollSettings_SetPartToParent）
 */
public func JPH_RagdollSettings_SetPartToParent_cj(
    settings: CPointer<Unit>, partIndex: Int32, constraintSettings: CPointer<Unit>
): Unit {
    unsafe {
        JPH_RagdollSettings_SetPartToParent(settings, partIndex, constraintSettings)
    }
}

// =============================================================================
// 布娃娃（Ragdoll）
// =============================================================================

/**
 * @brief 销毁布娃娃（对应 JPH_Ragdoll_Destroy）
 */
public func JPH_Ragdoll_Destroy_cj(ragdoll: CPointer<Unit>): Unit {
    unsafe {
        JPH_Ragdoll_Destroy(ragdoll)
    }
}

/**
 * @brief 添加布娃娃到物理系统（对应 JPH_Ragdoll_AddToPhysicsSystem）
 */
public func JPH_Ragdoll_AddToPhysicsSystem_cj(
    ragdoll: CPointer<Unit>, activationMode: UInt32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Ragdoll_AddToPhysicsSystem(ragdoll, activationMode, lockBodies)
    }
}

/**
 * @brief 从物理系统移除布娃娃（对应 JPH_Ragdoll_RemoveFromPhysicsSystem）
 */
public func JPH_Ragdoll_RemoveFromPhysicsSystem_cj(ragdoll: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Ragdoll_RemoveFromPhysicsSystem(ragdoll, lockBodies)
    }
}

/**
 * @brief 激活布娃娃（对应 JPH_Ragdoll_Activate）
 */
public func JPH_Ragdoll_Activate_cj(ragdoll: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Ragdoll_Activate(ragdoll, lockBodies)
    }
}

/**
 * @brief 布娃娃是否活动（对应 JPH_Ragdoll_IsActive）
 */
public func JPH_Ragdoll_IsActive_cj(ragdoll: CPointer<Unit>, lockBodies: UInt8): UInt8 {
    unsafe {
        JPH_Ragdoll_IsActive(ragdoll, lockBodies)
    }
}

/**
 * @brief 重置布娃娃热启动缓存（对应 JPH_Ragdoll_ResetWarmStart）
 */
public func JPH_Ragdoll_ResetWarmStart_cj(ragdoll: CPointer<Unit>): Unit {
    unsafe {
        JPH_Ragdoll_ResetWarmStart(ragdoll)
    }
}

/**
 * @brief 按骨骼姿态设置布娃娃姿态（对应 JPH_Ragdoll_SetPose）
 */
public func JPH_Ragdoll_SetPose_cj(ragdoll: CPointer<Unit>, pose: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Ragdoll_SetPose(ragdoll, pose, lockBodies)
    }
}

/**
 * @brief 按根偏移 + 关节矩阵设置布娃娃姿态（对应 JPH_Ragdoll_SetPose2）
 */
public func JPH_Ragdoll_SetPose2_cj(
    ragdoll: CPointer<Unit>, rootOffset: CPointer<JPHVec3>,
    jointMatrices: CPointer<JPHMat4>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Ragdoll_SetPose2(ragdoll, rootOffset, jointMatrices, lockBodies)
    }
}

/**
 * @brief 获取布娃娃姿态（对应 JPH_Ragdoll_GetPose）
 */
public func JPH_Ragdoll_GetPose_cj(ragdoll: CPointer<Unit>, outPose: CPointer<Unit>, lockBodies: UInt8): Unit {
    unsafe {
        JPH_Ragdoll_GetPose(ragdoll, outPose, lockBodies)
    }
}

/**
 * @brief 获取布娃娃姿态（根偏移 + 关节矩阵，对应 JPH_Ragdoll_GetPose2）
 */
public func JPH_Ragdoll_GetPose2_cj(
    ragdoll: CPointer<Unit>, outRootOffset: CPointer<JPHVec3>,
    outJointMatrices: CPointer<JPHMat4>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Ragdoll_GetPose2(ragdoll, outRootOffset, outJointMatrices, lockBodies)
    }
}

/**
 * @brief 用电机驱动布娃娃到指定姿态（对应 JPH_Ragdoll_DriveToPoseUsingMotors）
 */
public func JPH_Ragdoll_DriveToPoseUsingMotors_cj(ragdoll: CPointer<Unit>, pose: CPointer<Unit>): Unit {
    unsafe {
        JPH_Ragdoll_DriveToPoseUsingMotors(ragdoll, pose)
    }
}

/**
 * @brief 用运动学驱动布娃娃到指定姿态（对应 JPH_Ragdoll_DriveToPoseUsingKinematics）
 */
public func JPH_Ragdoll_DriveToPoseUsingKinematics_cj(
    ragdoll: CPointer<Unit>, pose: CPointer<Unit>, deltaTime: Float32, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Ragdoll_DriveToPoseUsingKinematics(ragdoll, pose, deltaTime, lockBodies)
    }
}

/**
 * @brief 获取布娃娃刚体数量（对应 JPH_Ragdoll_GetBodyCount）
 */
public func JPH_Ragdoll_GetBodyCount_cj(ragdoll: CPointer<Unit>): Int32 {
    unsafe {
        JPH_Ragdoll_GetBodyCount(ragdoll)
    }
}

/**
 * @brief 获取指定刚体的 BodyID（对应 JPH_Ragdoll_GetBodyID）
 */
public func JPH_Ragdoll_GetBodyID_cj(ragdoll: CPointer<Unit>, bodyIndex: Int32): UInt32 {
    unsafe {
        JPH_Ragdoll_GetBodyID(ragdoll, bodyIndex)
    }
}

/**
 * @brief 获取布娃娃约束数量（对应 JPH_Ragdoll_GetConstraintCount）
 */
public func JPH_Ragdoll_GetConstraintCount_cj(ragdoll: CPointer<Unit>): Int32 {
    unsafe {
        JPH_Ragdoll_GetConstraintCount(ragdoll)
    }
}

/**
 * @brief 获取指定约束（对应 JPH_Ragdoll_GetConstraint）
 */
public func JPH_Ragdoll_GetConstraint_cj(ragdoll: CPointer<Unit>, constraintIndex: Int32): CPointer<Unit> {
    unsafe {
        JPH_Ragdoll_GetConstraint(ragdoll, constraintIndex)
    }
}

/**
 * @brief 获取布娃娃根变换（对应 JPH_Ragdoll_GetRootTransform）
 */
public func JPH_Ragdoll_GetRootTransform_cj(
    ragdoll: CPointer<Unit>, outPosition: CPointer<JPHVec3>,
    outRotation: CPointer<JPHQuat>, lockBodies: UInt8
): Unit {
    unsafe {
        JPH_Ragdoll_GetRootTransform(ragdoll, outPosition, outRotation, lockBodies)
    }
}

/**
 * @brief 获取布娃娃设置（对应 JPH_Ragdoll_GetRagdollSettings）
 */
public func JPH_Ragdoll_GetRagdollSettings_cj(ragdoll: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Ragdoll_GetRagdollSettings(ragdoll)
    }
}

// =============================================================================
// 六自由度约束（SixDOFConstraint）
// =============================================================================

/**
 * @brief 初始化六自由度约束设置（对应 JPH_SixDOFConstraintSettings_Init）
 */
public func JPH_SixDOFConstraintSettings_Init_cj(settings: CPointer<JPHSixDOFConstraintSettings>): Unit {
    unsafe {
        JPH_SixDOFConstraintSettings_Init(settings)
    }
}

/**
 * @brief 将指定轴设为自由（对应 JPH_SixDOFConstraintSettings_MakeFreeAxis）
 */
public func JPH_SixDOFConstraintSettings_MakeFreeAxis_cj(settings: CPointer<Unit>, axis: UInt32): Unit {
    unsafe {
        JPH_SixDOFConstraintSettings_MakeFreeAxis(settings, axis)
    }
}

/**
 * @brief 指定轴是否自由（对应 JPH_SixDOFConstraintSettings_IsFreeAxis）
 */
public func JPH_SixDOFConstraintSettings_IsFreeAxis_cj(settings: CPointer<Unit>, axis: UInt32): UInt8 {
    unsafe {
        JPH_SixDOFConstraintSettings_IsFreeAxis(settings, axis)
    }
}

/**
 * @brief 将指定轴设为固定（对应 JPH_SixDOFConstraintSettings_MakeFixedAxis）
 */
public func JPH_SixDOFConstraintSettings_MakeFixedAxis_cj(settings: CPointer<Unit>, axis: UInt32): Unit {
    unsafe {
        JPH_SixDOFConstraintSettings_MakeFixedAxis(settings, axis)
    }
}

/**
 * @brief 指定轴是否固定（对应 JPH_SixDOFConstraintSettings_IsFixedAxis）
 */
public func JPH_SixDOFConstraintSettings_IsFixedAxis_cj(settings: CPointer<Unit>, axis: UInt32): UInt8 {
    unsafe {
        JPH_SixDOFConstraintSettings_IsFixedAxis(settings, axis)
    }
}

/**
 * @brief 将指定轴设为受限（对应 JPH_SixDOFConstraintSettings_SetLimitedAxis）
 */
public func JPH_SixDOFConstraintSettings_SetLimitedAxis_cj(
    settings: CPointer<Unit>, axis: UInt32, min: Float32, max: Float32
): Unit {
    unsafe {
        JPH_SixDOFConstraintSettings_SetLimitedAxis(settings, axis, min, max)
    }
}

/**
 * @brief 创建六自由度约束（对应 JPH_SixDOFConstraint_Create）
 */
public func JPH_SixDOFConstraint_Create_cj(
    settings: CPointer<JPHSixDOFConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_SixDOFConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取六自由度约束设置（对应 JPH_SixDOFConstraint_GetSettings）
 */
public func JPH_SixDOFConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSixDOFConstraintSettings>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 获取指定轴最小限位（对应 JPH_SixDOFConstraint_GetLimitsMin）
 */
public func JPH_SixDOFConstraint_GetLimitsMin_cj(constraint: CPointer<Unit>, axis: UInt32): Float32 {
    unsafe {
        JPH_SixDOFConstraint_GetLimitsMin(constraint, axis)
    }
}

/**
 * @brief 获取指定轴最大限位（对应 JPH_SixDOFConstraint_GetLimitsMax）
 */
public func JPH_SixDOFConstraint_GetLimitsMax_cj(constraint: CPointer<Unit>, axis: UInt32): Float32 {
    unsafe {
        JPH_SixDOFConstraint_GetLimitsMax(constraint, axis)
    }
}

/**
 * @brief 获取平移 lambda（对应 JPH_SixDOFConstraint_GetTotalLambdaPosition）
 */
public func JPH_SixDOFConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

/**
 * @brief 获取旋转 lambda（对应 JPH_SixDOFConstraint_GetTotalLambdaRotation）
 */
public func JPH_SixDOFConstraint_GetTotalLambdaRotation_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTotalLambdaRotation(constraint, result)
    }
}

/**
 * @brief 获取平移电机 lambda（对应 JPH_SixDOFConstraint_GetTotalLambdaMotorTranslation）
 */
public func JPH_SixDOFConstraint_GetTotalLambdaMotorTranslation_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTotalLambdaMotorTranslation(constraint, result)
    }
}

/**
 * @brief 获取旋转电机 lambda（对应 JPH_SixDOFConstraint_GetTotalLambdaMotorRotation）
 */
public func JPH_SixDOFConstraint_GetTotalLambdaMotorRotation_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTotalLambdaMotorRotation(constraint, result)
    }
}

/**
 * @brief 获取平移限位最小值（对应 JPH_SixDOFConstraint_GetTranslationLimitsMin）
 */
public func JPH_SixDOFConstraint_GetTranslationLimitsMin_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTranslationLimitsMin(constraint, result)
    }
}

/**
 * @brief 获取平移限位最大值（对应 JPH_SixDOFConstraint_GetTranslationLimitsMax）
 */
public func JPH_SixDOFConstraint_GetTranslationLimitsMax_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTranslationLimitsMax(constraint, result)
    }
}

/**
 * @brief 获取旋转限位最小值（对应 JPH_SixDOFConstraint_GetRotationLimitsMin）
 */
public func JPH_SixDOFConstraint_GetRotationLimitsMin_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetRotationLimitsMin(constraint, result)
    }
}

/**
 * @brief 获取旋转限位最大值（对应 JPH_SixDOFConstraint_GetRotationLimitsMax）
 */
public func JPH_SixDOFConstraint_GetRotationLimitsMax_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetRotationLimitsMax(constraint, result)
    }
}

/**
 * @brief 指定轴是否固定（对应 JPH_SixDOFConstraint_IsFixedAxis）
 */
public func JPH_SixDOFConstraint_IsFixedAxis_cj(constraint: CPointer<Unit>, axis: UInt32): UInt8 {
    unsafe {
        JPH_SixDOFConstraint_IsFixedAxis(constraint, axis)
    }
}

/**
 * @brief 指定轴是否自由（对应 JPH_SixDOFConstraint_IsFreeAxis）
 */
public func JPH_SixDOFConstraint_IsFreeAxis_cj(constraint: CPointer<Unit>, axis: UInt32): UInt8 {
    unsafe {
        JPH_SixDOFConstraint_IsFreeAxis(constraint, axis)
    }
}

/**
 * @brief 获取指定轴限位弹簧设置（对应 JPH_SixDOFConstraint_GetLimitsSpringSettings）
 */
public func JPH_SixDOFConstraint_GetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>, axis: UInt32
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetLimitsSpringSettings(constraint, result, axis)
    }
}

/**
 * @brief 设置指定轴限位弹簧设置（对应 JPH_SixDOFConstraint_SetLimitsSpringSettings）
 */
public func JPH_SixDOFConstraint_SetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>, axis: UInt32
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetLimitsSpringSettings(constraint, settings, axis)
    }
}

/**
 * @brief 设置指定轴最大摩擦（对应 JPH_SixDOFConstraint_SetMaxFriction）
 */
public func JPH_SixDOFConstraint_SetMaxFriction_cj(
    constraint: CPointer<Unit>, axis: UInt32, inFriction: Float32
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetMaxFriction(constraint, axis, inFriction)
    }
}

/**
 * @brief 获取指定轴最大摩擦（对应 JPH_SixDOFConstraint_GetMaxFriction）
 */
public func JPH_SixDOFConstraint_GetMaxFriction_cj(constraint: CPointer<Unit>, axis: UInt32): Float32 {
    unsafe {
        JPH_SixDOFConstraint_GetMaxFriction(constraint, axis)
    }
}

/**
 * @brief 获取约束空间内的旋转（对应 JPH_SixDOFConstraint_GetRotationInConstraintSpace）
 */
public func JPH_SixDOFConstraint_GetRotationInConstraintSpace_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetRotationInConstraintSpace(constraint, result)
    }
}

/**
 * @brief 获取指定轴电机设置（对应 JPH_SixDOFConstraint_GetMotorSettings）
 */
public func JPH_SixDOFConstraint_GetMotorSettings_cj(
    constraint: CPointer<Unit>, axis: UInt32, settings: CPointer<JPHMotorSettings>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetMotorSettings(constraint, axis, settings)
    }
}

/**
 * @brief 设置指定轴电机状态（对应 JPH_SixDOFConstraint_SetMotorState）
 */
public func JPH_SixDOFConstraint_SetMotorState_cj(
    constraint: CPointer<Unit>, axis: UInt32, state: UInt32
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetMotorState(constraint, axis, state)
    }
}

/**
 * @brief 获取指定轴电机状态（对应 JPH_SixDOFConstraint_GetMotorState）
 */
public func JPH_SixDOFConstraint_GetMotorState_cj(constraint: CPointer<Unit>, axis: UInt32): UInt32 {
    unsafe {
        JPH_SixDOFConstraint_GetMotorState(constraint, axis)
    }
}

/**
 * @brief 设置目标线速度（约束空间，对应 JPH_SixDOFConstraint_SetTargetVelocityCS）
 */
public func JPH_SixDOFConstraint_SetTargetVelocityCS_cj(
    constraint: CPointer<Unit>, inVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetTargetVelocityCS(constraint, inVelocity)
    }
}

/**
 * @brief 获取目标线速度（约束空间，对应 JPH_SixDOFConstraint_GetTargetVelocityCS）
 */
public func JPH_SixDOFConstraint_GetTargetVelocityCS_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTargetVelocityCS(constraint, result)
    }
}

/**
 * @brief 设置目标角速度（约束空间，对应 JPH_SixDOFConstraint_SetTargetAngularVelocityCS）
 */
public func JPH_SixDOFConstraint_SetTargetAngularVelocityCS_cj(
    constraint: CPointer<Unit>, inAngularVelocity: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetTargetAngularVelocityCS(constraint, inAngularVelocity)
    }
}

/**
 * @brief 获取目标角速度（约束空间，对应 JPH_SixDOFConstraint_GetTargetAngularVelocityCS）
 */
public func JPH_SixDOFConstraint_GetTargetAngularVelocityCS_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTargetAngularVelocityCS(constraint, result)
    }
}

/**
 * @brief 设置目标位置（约束空间，对应 JPH_SixDOFConstraint_SetTargetPositionCS）
 */
public func JPH_SixDOFConstraint_SetTargetPositionCS_cj(
    constraint: CPointer<Unit>, inPosition: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetTargetPositionCS(constraint, inPosition)
    }
}

/**
 * @brief 获取目标位置（约束空间，对应 JPH_SixDOFConstraint_GetTargetPositionCS）
 */
public func JPH_SixDOFConstraint_GetTargetPositionCS_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTargetPositionCS(constraint, result)
    }
}

/**
 * @brief 设置目标朝向（约束空间，对应 JPH_SixDOFConstraint_SetTargetOrientationCS）
 */
public func JPH_SixDOFConstraint_SetTargetOrientationCS_cj(
    constraint: CPointer<Unit>, inOrientation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetTargetOrientationCS(constraint, inOrientation)
    }
}

/**
 * @brief 获取目标朝向（约束空间，对应 JPH_SixDOFConstraint_GetTargetOrientationCS）
 */
public func JPH_SixDOFConstraint_GetTargetOrientationCS_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_GetTargetOrientationCS(constraint, result)
    }
}

/**
 * @brief 设置目标朝向（刚体 1 空间，对应 JPH_SixDOFConstraint_SetTargetOrientationBS）
 */
public func JPH_SixDOFConstraint_SetTargetOrientationBS_cj(
    constraint: CPointer<Unit>, inOrientation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SixDOFConstraint_SetTargetOrientationBS(constraint, inOrientation)
    }
}

// =============================================================================
// 骨骼（Skeleton）
// =============================================================================

/**
 * @brief 创建骨骼（对应 JPH_Skeleton_Create）
 */
public func JPH_Skeleton_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_Skeleton_Create()
    }
}

/**
 * @brief 销毁骨骼（对应 JPH_Skeleton_Destroy）
 */
public func JPH_Skeleton_Destroy_cj(skeleton: CPointer<Unit>): Unit {
    unsafe {
        JPH_Skeleton_Destroy(skeleton)
    }
}

/**
 * @brief 添加关节（对应 JPH_Skeleton_AddJoint）
 */
public func JPH_Skeleton_AddJoint_cj(skeleton: CPointer<Unit>, name: CPointer<UInt8>): UInt32 {
    unsafe {
        JPH_Skeleton_AddJoint(skeleton, name)
    }
}

/**
 * @brief 添加关节（指定父关节索引，对应 JPH_Skeleton_AddJoint2）
 */
public func JPH_Skeleton_AddJoint2_cj(
    skeleton: CPointer<Unit>, name: CPointer<UInt8>, parentIndex: Int32
): UInt32 {
    unsafe {
        JPH_Skeleton_AddJoint2(skeleton, name, parentIndex)
    }
}

/**
 * @brief 添加关节（指定父关节名，对应 JPH_Skeleton_AddJoint3）
 */
public func JPH_Skeleton_AddJoint3_cj(
    skeleton: CPointer<Unit>, name: CPointer<UInt8>, parentName: CPointer<UInt8>
): UInt32 {
    unsafe {
        JPH_Skeleton_AddJoint3(skeleton, name, parentName)
    }
}

/**
 * @brief 获取关节数量（对应 JPH_Skeleton_GetJointCount）
 */
public func JPH_Skeleton_GetJointCount_cj(skeleton: CPointer<Unit>): Int32 {
    unsafe {
        JPH_Skeleton_GetJointCount(skeleton)
    }
}

/**
 * @brief 获取指定关节（对应 JPH_Skeleton_GetJoint）
 */
public func JPH_Skeleton_GetJoint_cj(
    skeleton: CPointer<Unit>, index: Int32, joint: CPointer<JPHSkeletonJoint>
): Unit {
    unsafe {
        JPH_Skeleton_GetJoint(skeleton, index, joint)
    }
}

/**
 * @brief 按名称获取关节索引（对应 JPH_Skeleton_GetJointIndex）
 */
public func JPH_Skeleton_GetJointIndex_cj(skeleton: CPointer<Unit>, name: CPointer<UInt8>): Int32 {
    unsafe {
        JPH_Skeleton_GetJointIndex(skeleton, name)
    }
}

/**
 * @brief 计算父关节索引（对应 JPH_Skeleton_CalculateParentJointIndices）
 */
public func JPH_Skeleton_CalculateParentJointIndices_cj(skeleton: CPointer<Unit>): Unit {
    unsafe {
        JPH_Skeleton_CalculateParentJointIndices(skeleton)
    }
}

/**
 * @brief 关节顺序是否正确（对应 JPH_Skeleton_AreJointsCorrectlyOrdered）
 */
public func JPH_Skeleton_AreJointsCorrectlyOrdered_cj(skeleton: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Skeleton_AreJointsCorrectlyOrdered(skeleton)
    }
}

// =============================================================================
// 骨骼姿态（SkeletonPose）
// =============================================================================

/**
 * @brief 创建骨骼姿态（对应 JPH_SkeletonPose_Create）
 */
public func JPH_SkeletonPose_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_SkeletonPose_Create()
    }
}

/**
 * @brief 销毁骨骼姿态（对应 JPH_SkeletonPose_Destroy）
 */
public func JPH_SkeletonPose_Destroy_cj(pose: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletonPose_Destroy(pose)
    }
}

/**
 * @brief 设置骨骼姿态关联的骨骼（对应 JPH_SkeletonPose_SetSkeleton）
 */
public func JPH_SkeletonPose_SetSkeleton_cj(pose: CPointer<Unit>, skeleton: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletonPose_SetSkeleton(pose, skeleton)
    }
}

/**
 * @brief 获取骨骼姿态关联的骨骼（对应 JPH_SkeletonPose_GetSkeleton）
 */
public func JPH_SkeletonPose_GetSkeleton_cj(pose: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_SkeletonPose_GetSkeleton(pose)
    }
}

/**
 * @brief 设置根偏移（对应 JPH_SkeletonPose_SetRootOffset）
 */
public func JPH_SkeletonPose_SetRootOffset_cj(pose: CPointer<Unit>, offset: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_SkeletonPose_SetRootOffset(pose, offset)
    }
}

/**
 * @brief 获取根偏移（对应 JPH_SkeletonPose_GetRootOffset）
 */
public func JPH_SkeletonPose_GetRootOffset_cj(pose: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_SkeletonPose_GetRootOffset(pose, result)
    }
}

/**
 * @brief 获取关节数量（对应 JPH_SkeletonPose_GetJointCount）
 */
public func JPH_SkeletonPose_GetJointCount_cj(pose: CPointer<Unit>): Int32 {
    unsafe {
        JPH_SkeletonPose_GetJointCount(pose)
    }
}

/**
 * @brief 获取指定关节状态（对应 JPH_SkeletonPose_GetJointState）
 */
public func JPH_SkeletonPose_GetJointState_cj(
    pose: CPointer<Unit>, index: Int32, outTranslation: CPointer<JPHVec3>, outRotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SkeletonPose_GetJointState(pose, index, outTranslation, outRotation)
    }
}

/**
 * @brief 设置指定关节状态（对应 JPH_SkeletonPose_SetJointState）
 */
public func JPH_SkeletonPose_SetJointState_cj(
    pose: CPointer<Unit>, index: Int32, translation: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SkeletonPose_SetJointState(pose, index, translation, rotation)
    }
}

/**
 * @brief 获取指定关节矩阵（对应 JPH_SkeletonPose_GetJointMatrix）
 */
public func JPH_SkeletonPose_GetJointMatrix_cj(
    pose: CPointer<Unit>, index: Int32, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonPose_GetJointMatrix(pose, index, result)
    }
}

/**
 * @brief 设置指定关节矩阵（对应 JPH_SkeletonPose_SetJointMatrix）
 */
public func JPH_SkeletonPose_SetJointMatrix_cj(
    pose: CPointer<Unit>, index: Int32, matrix: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonPose_SetJointMatrix(pose, index, matrix)
    }
}

/**
 * @brief 获取全部关节矩阵（对应 JPH_SkeletonPose_GetJointMatrices）
 */
public func JPH_SkeletonPose_GetJointMatrices_cj(
    pose: CPointer<Unit>, outMatrices: CPointer<JPHMat4>, count: Int32
): Unit {
    unsafe {
        JPH_SkeletonPose_GetJointMatrices(pose, outMatrices, count)
    }
}

/**
 * @brief 设置全部关节矩阵（对应 JPH_SkeletonPose_SetJointMatrices）
 */
public func JPH_SkeletonPose_SetJointMatrices_cj(
    pose: CPointer<Unit>, matrices: CPointer<JPHMat4>, count: Int32
): Unit {
    unsafe {
        JPH_SkeletonPose_SetJointMatrices(pose, matrices, count)
    }
}

/**
 * @brief 计算关节矩阵（对应 JPH_SkeletonPose_CalculateJointMatrices）
 */
public func JPH_SkeletonPose_CalculateJointMatrices_cj(pose: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletonPose_CalculateJointMatrices(pose)
    }
}

/**
 * @brief 计算关节状态（对应 JPH_SkeletonPose_CalculateJointStates）
 */
public func JPH_SkeletonPose_CalculateJointStates_cj(pose: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletonPose_CalculateJointStates(pose)
    }
}

/**
 * @brief 计算局部空间关节矩阵（对应 JPH_SkeletonPose_CalculateLocalSpaceJointMatrices）
 */
public func JPH_SkeletonPose_CalculateLocalSpaceJointMatrices_cj(
    pose: CPointer<Unit>, outMatrices: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonPose_CalculateLocalSpaceJointMatrices(pose, outMatrices)
    }
}

// =============================================================================
// 骨骼动画（SkeletalAnimation）
// =============================================================================

/**
 * @brief 创建骨骼动画（对应 JPH_SkeletalAnimation_Create）
 */
public func JPH_SkeletalAnimation_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_SkeletalAnimation_Create()
    }
}

/**
 * @brief 销毁骨骼动画（对应 JPH_SkeletalAnimation_Destroy）
 */
public func JPH_SkeletalAnimation_Destroy_cj(animation: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletalAnimation_Destroy(animation)
    }
}

/**
 * @brief 获取动画时长（对应 JPH_SkeletalAnimation_GetDuration）
 */
public func JPH_SkeletalAnimation_GetDuration_cj(animation: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SkeletalAnimation_GetDuration(animation)
    }
}

/**
 * @brief 是否循环播放（对应 JPH_SkeletalAnimation_IsLooping）
 */
public func JPH_SkeletalAnimation_IsLooping_cj(animation: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SkeletalAnimation_IsLooping(animation)
    }
}

/**
 * @brief 设置是否循环播放（对应 JPH_SkeletalAnimation_SetIsLooping）
 */
public func JPH_SkeletalAnimation_SetIsLooping_cj(animation: CPointer<Unit>, looping: UInt8): Unit {
    unsafe {
        JPH_SkeletalAnimation_SetIsLooping(animation, looping)
    }
}

/**
 * @brief 缩放关节（对应 JPH_SkeletalAnimation_ScaleJoints）
 */
public func JPH_SkeletalAnimation_ScaleJoints_cj(animation: CPointer<Unit>, scale: Float32): Unit {
    unsafe {
        JPH_SkeletalAnimation_ScaleJoints(animation, scale)
    }
}

/**
 * @brief 在指定时间采样动画到姿态（对应 JPH_SkeletalAnimation_Sample）
 */
public func JPH_SkeletalAnimation_Sample_cj(
    animation: CPointer<Unit>, time: Float32, pose: CPointer<Unit>
): Unit {
    unsafe {
        JPH_SkeletalAnimation_Sample(animation, time, pose)
    }
}

/**
 * @brief 获取动画关节数量（对应 JPH_SkeletalAnimation_GetAnimatedJointCount）
 */
public func JPH_SkeletalAnimation_GetAnimatedJointCount_cj(animation: CPointer<Unit>): Int32 {
    unsafe {
        JPH_SkeletalAnimation_GetAnimatedJointCount(animation)
    }
}

/**
 * @brief 添加动画关节（对应 JPH_SkeletalAnimation_AddAnimatedJoint）
 */
public func JPH_SkeletalAnimation_AddAnimatedJoint_cj(
    animation: CPointer<Unit>, jointName: CPointer<UInt8>
): Unit {
    unsafe {
        JPH_SkeletalAnimation_AddAnimatedJoint(animation, jointName)
    }
}

/**
 * @brief 添加关键帧（对应 JPH_SkeletalAnimation_AddKeyframe）
 */
public func JPH_SkeletalAnimation_AddKeyframe_cj(
    animation: CPointer<Unit>, jointIndex: Int32, time: Float32,
    translation: CPointer<JPHVec3>, rotation: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SkeletalAnimation_AddKeyframe(animation, jointIndex, time, translation, rotation)
    }
}

// =============================================================================
// 骨骼映射（SkeletonMapper）
// =============================================================================

/**
 * @brief 创建骨骼映射器（对应 JPH_SkeletonMapper_Create）
 */
public func JPH_SkeletonMapper_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_SkeletonMapper_Create()
    }
}

/**
 * @brief 销毁骨骼映射器（对应 JPH_SkeletonMapper_Destroy）
 */
public func JPH_SkeletonMapper_Destroy_cj(mapper: CPointer<Unit>): Unit {
    unsafe {
        JPH_SkeletonMapper_Destroy(mapper)
    }
}

/**
 * @brief 初始化映射器（对应 JPH_SkeletonMapper_Initialize）
 */
public func JPH_SkeletonMapper_Initialize_cj(
    mapper: CPointer<Unit>, skeleton1: CPointer<Unit>, neutralPose1: CPointer<JPHMat4>,
    skeleton2: CPointer<Unit>, neutralPose2: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonMapper_Initialize(mapper, skeleton1, neutralPose1, skeleton2, neutralPose2)
    }
}

/**
 * @brief 锁定全部平移自由度（对应 JPH_SkeletonMapper_LockAllTranslations）
 */
public func JPH_SkeletonMapper_LockAllTranslations_cj(
    mapper: CPointer<Unit>, skeleton2: CPointer<Unit>, neutralPose2: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonMapper_LockAllTranslations(mapper, skeleton2, neutralPose2)
    }
}

/**
 * @brief 锁定指定平移自由度（对应 JPH_SkeletonMapper_LockTranslations）
 */
public func JPH_SkeletonMapper_LockTranslations_cj(
    mapper: CPointer<Unit>, skeleton2: CPointer<Unit>,
    lockedTranslations: CPointer<UInt8>, neutralPose2: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonMapper_LockTranslations(mapper, skeleton2, lockedTranslations, neutralPose2)
    }
}

/**
 * @brief 正向映射（对应 JPH_SkeletonMapper_Map）
 */
public func JPH_SkeletonMapper_Map_cj(
    mapper: CPointer<Unit>, pose1ModelSpace: CPointer<JPHMat4>,
    pose2LocalSpace: CPointer<JPHMat4>, outPose2ModelSpace: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonMapper_Map(mapper, pose1ModelSpace, pose2LocalSpace, outPose2ModelSpace)
    }
}

/**
 * @brief 反向映射（对应 JPH_SkeletonMapper_MapReverse）
 */
public func JPH_SkeletonMapper_MapReverse_cj(
    mapper: CPointer<Unit>, pose2ModelSpace: CPointer<JPHMat4>, outPose1ModelSpace: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_SkeletonMapper_MapReverse(mapper, pose2ModelSpace, outPose1ModelSpace)
    }
}

/**
 * @brief 获取映射后的关节索引（对应 JPH_SkeletonMapper_GetMappedJointIndex）
 */
public func JPH_SkeletonMapper_GetMappedJointIndex_cj(mapper: CPointer<Unit>, joint1Index: Int32): Int32 {
    unsafe {
        JPH_SkeletonMapper_GetMappedJointIndex(mapper, joint1Index)
    }
}

/**
 * @brief 指定关节平移是否被锁定（对应 JPH_SkeletonMapper_IsJointTranslationLocked）
 */
public func JPH_SkeletonMapper_IsJointTranslationLocked_cj(mapper: CPointer<Unit>, joint2Index: Int32): UInt8 {
    unsafe {
        JPH_SkeletonMapper_IsJointTranslationLocked(mapper, joint2Index)
    }
}

// =============================================================================
// 滑块约束（SliderConstraint）
// =============================================================================

/**
 * @brief 初始化滑块约束设置（对应 JPH_SliderConstraintSettings_Init）
 */
public func JPH_SliderConstraintSettings_Init_cj(settings: CPointer<JPHSliderConstraintSettings>): Unit {
    unsafe {
        JPH_SliderConstraintSettings_Init(settings)
    }
}

/**
 * @brief 设置滑块约束的滑动轴（对应 JPH_SliderConstraintSettings_SetSliderAxis）
 */
public func JPH_SliderConstraintSettings_SetSliderAxis_cj(
    settings: CPointer<JPHSliderConstraintSettings>, axis: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SliderConstraintSettings_SetSliderAxis(settings, axis)
    }
}

/**
 * @brief 创建滑块约束（对应 JPH_SliderConstraint_Create）
 */
public func JPH_SliderConstraint_Create_cj(
    settings: CPointer<JPHSliderConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_SliderConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取滑块约束设置（对应 JPH_SliderConstraint_GetSettings）
 */
public func JPH_SliderConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSliderConstraintSettings>
): Unit {
    unsafe {
        JPH_SliderConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 获取当前位置（对应 JPH_SliderConstraint_GetCurrentPosition）
 */
public func JPH_SliderConstraint_GetCurrentPosition_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetCurrentPosition(constraint)
    }
}

/**
 * @brief 设置最大摩擦力（对应 JPH_SliderConstraint_SetMaxFrictionForce）
 */
public func JPH_SliderConstraint_SetMaxFrictionForce_cj(
    constraint: CPointer<Unit>, frictionForce: Float32
): Unit {
    unsafe {
        JPH_SliderConstraint_SetMaxFrictionForce(constraint, frictionForce)
    }
}

/**
 * @brief 获取最大摩擦力（对应 JPH_SliderConstraint_GetMaxFrictionForce）
 */
public func JPH_SliderConstraint_GetMaxFrictionForce_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetMaxFrictionForce(constraint)
    }
}

/**
 * @brief 设置电机设置（对应 JPH_SliderConstraint_SetMotorSettings）
 */
public func JPH_SliderConstraint_SetMotorSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHMotorSettings>
): Unit {
    unsafe {
        JPH_SliderConstraint_SetMotorSettings(constraint, settings)
    }
}

/**
 * @brief 获取电机设置（对应 JPH_SliderConstraint_GetMotorSettings）
 */
public func JPH_SliderConstraint_GetMotorSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHMotorSettings>
): Unit {
    unsafe {
        JPH_SliderConstraint_GetMotorSettings(constraint, result)
    }
}

/**
 * @brief 设置电机状态（对应 JPH_SliderConstraint_SetMotorState）
 */
public func JPH_SliderConstraint_SetMotorState_cj(constraint: CPointer<Unit>, state: UInt32): Unit {
    unsafe {
        JPH_SliderConstraint_SetMotorState(constraint, state)
    }
}

/**
 * @brief 获取电机状态（对应 JPH_SliderConstraint_GetMotorState）
 */
public func JPH_SliderConstraint_GetMotorState_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_SliderConstraint_GetMotorState(constraint)
    }
}

/**
 * @brief 设置目标速度（对应 JPH_SliderConstraint_SetTargetVelocity）
 */
public func JPH_SliderConstraint_SetTargetVelocity_cj(constraint: CPointer<Unit>, velocity: Float32): Unit {
    unsafe {
        JPH_SliderConstraint_SetTargetVelocity(constraint, velocity)
    }
}

/**
 * @brief 获取目标速度（对应 JPH_SliderConstraint_GetTargetVelocity）
 */
public func JPH_SliderConstraint_GetTargetVelocity_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetTargetVelocity(constraint)
    }
}

/**
 * @brief 设置目标位置（对应 JPH_SliderConstraint_SetTargetPosition）
 */
public func JPH_SliderConstraint_SetTargetPosition_cj(constraint: CPointer<Unit>, position: Float32): Unit {
    unsafe {
        JPH_SliderConstraint_SetTargetPosition(constraint, position)
    }
}

/**
 * @brief 获取目标位置（对应 JPH_SliderConstraint_GetTargetPosition）
 */
public func JPH_SliderConstraint_GetTargetPosition_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetTargetPosition(constraint)
    }
}

/**
 * @brief 设置位置限位（对应 JPH_SliderConstraint_SetLimits）
 */
public func JPH_SliderConstraint_SetLimits_cj(
    constraint: CPointer<Unit>, inLimitsMin: Float32, inLimitsMax: Float32
): Unit {
    unsafe {
        JPH_SliderConstraint_SetLimits(constraint, inLimitsMin, inLimitsMax)
    }
}

/**
 * @brief 获取最小位置限位（对应 JPH_SliderConstraint_GetLimitsMin）
 */
public func JPH_SliderConstraint_GetLimitsMin_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetLimitsMin(constraint)
    }
}

/**
 * @brief 获取最大位置限位（对应 JPH_SliderConstraint_GetLimitsMax）
 */
public func JPH_SliderConstraint_GetLimitsMax_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetLimitsMax(constraint)
    }
}

/**
 * @brief 是否有位置限位（对应 JPH_SliderConstraint_HasLimits）
 */
public func JPH_SliderConstraint_HasLimits_cj(constraint: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SliderConstraint_HasLimits(constraint)
    }
}

/**
 * @brief 获取限位弹簧设置（对应 JPH_SliderConstraint_GetLimitsSpringSettings）
 */
public func JPH_SliderConstraint_GetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_SliderConstraint_GetLimitsSpringSettings(constraint, result)
    }
}

/**
 * @brief 设置限位弹簧设置（对应 JPH_SliderConstraint_SetLimitsSpringSettings）
 */
public func JPH_SliderConstraint_SetLimitsSpringSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_SliderConstraint_SetLimitsSpringSettings(constraint, settings)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_SliderConstraint_GetTotalLambdaPosition）
 */
public func JPH_SliderConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, position: CPointer<Float32>
): Unit {
    unsafe {
        JPH_SliderConstraint_GetTotalLambdaPosition(constraint, position)
    }
}

/**
 * @brief 获取位置限位 lambda（对应 JPH_SliderConstraint_GetTotalLambdaPositionLimits）
 */
public func JPH_SliderConstraint_GetTotalLambdaPositionLimits_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetTotalLambdaPositionLimits(constraint)
    }
}

/**
 * @brief 获取旋转 lambda（对应 JPH_SliderConstraint_GetTotalLambdaRotation）
 */
public func JPH_SliderConstraint_GetTotalLambdaRotation_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SliderConstraint_GetTotalLambdaRotation(constraint, result)
    }
}

/**
 * @brief 获取电机 lambda（对应 JPH_SliderConstraint_GetTotalLambdaMotor）
 */
public func JPH_SliderConstraint_GetTotalLambdaMotor_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SliderConstraint_GetTotalLambdaMotor(constraint)
    }
}

// =============================================================================
// 软体共享设置（SoftBodySharedSettings）
// =============================================================================

/**
 * @brief 创建软体共享设置（对应 JPH_SoftBodySharedSettings_Create）
 */
public func JPH_SoftBodySharedSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_SoftBodySharedSettings_Create()
    }
}

/**
 * @brief 销毁软体共享设置（对应 JPH_SoftBodySharedSettings_Destroy）
 */
public func JPH_SoftBodySharedSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_Destroy(settings)
    }
}

/**
 * @brief 添加软体顶点（对应 JPH_SoftBodySharedSettings_AddVertex）
 */
public func JPH_SoftBodySharedSettings_AddVertex_cj(
    settings: CPointer<Unit>, vertex: CPointer<JPHSoftVertex>
): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_AddVertex(settings, vertex)
    }
}

/**
 * @brief 批量添加软体顶点（对应 JPH_SoftBodySharedSettings_AddVertices）
 */
public func JPH_SoftBodySharedSettings_AddVertices_cj(
    settings: CPointer<Unit>, vertices: CPointer<JPHSoftVertex>, count: UInt32
): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_AddVertices(settings, vertices, count)
    }
}

/**
 * @brief 移除软体顶点（对应 JPH_SoftBodySharedSettings_RemoveVertex）
 */
public func JPH_SoftBodySharedSettings_RemoveVertex_cj(settings: CPointer<Unit>, index: UInt32): UInt8 {
    unsafe {
        JPH_SoftBodySharedSettings_RemoveVertex(settings, index)
    }
}

/**
 * @brief 获取软体顶点数量（对应 JPH_SoftBodySharedSettings_GetVertexCount）
 */
public func JPH_SoftBodySharedSettings_GetVertexCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_SoftBodySharedSettings_GetVertexCount(settings)
    }
}

/**
 * @brief 获取指定软体顶点（对应 JPH_SoftBodySharedSettings_GetVertex）
 */
public func JPH_SoftBodySharedSettings_GetVertex_cj(
    settings: CPointer<Unit>, index: UInt32, outVertex: CPointer<JPHSoftVertex>
): UInt8 {
    unsafe {
        JPH_SoftBodySharedSettings_GetVertex(settings, index, outVertex)
    }
}

/**
 * @brief 添加软体面（对应 JPH_SoftBodySharedSettings_AddFace）
 */
public func JPH_SoftBodySharedSettings_AddFace_cj(
    settings: CPointer<Unit>, face: CPointer<JPHSoftFace>
): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_AddFace(settings, face)
    }
}

/**
 * @brief 批量添加软体面（对应 JPH_SoftBodySharedSettings_AddFaces）
 */
public func JPH_SoftBodySharedSettings_AddFaces_cj(
    settings: CPointer<Unit>, faces: CPointer<JPHSoftFace>, count: UInt32
): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_AddFaces(settings, faces, count)
    }
}

/**
 * @brief 移除软体面（对应 JPH_SoftBodySharedSettings_RemoveFace）
 */
public func JPH_SoftBodySharedSettings_RemoveFace_cj(settings: CPointer<Unit>, index: UInt32): UInt8 {
    unsafe {
        JPH_SoftBodySharedSettings_RemoveFace(settings, index)
    }
}

/**
 * @brief 获取软体面数量（对应 JPH_SoftBodySharedSettings_GetFaceCount）
 */
public func JPH_SoftBodySharedSettings_GetFaceCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_SoftBodySharedSettings_GetFaceCount(settings)
    }
}

/**
 * @brief 获取指定软体面（对应 JPH_SoftBodySharedSettings_GetFace）
 */
public func JPH_SoftBodySharedSettings_GetFace_cj(
    settings: CPointer<Unit>, index: UInt32, outFace: CPointer<JPHSoftFace>
): UInt8 {
    unsafe {
        JPH_SoftBodySharedSettings_GetFace(settings, index, outFace)
    }
}

/**
 * @brief 创建软体约束（对应 JPH_SoftBodySharedSettings_CreateConstraints）
 */
public func JPH_SoftBodySharedSettings_CreateConstraints_cj(
    settings: CPointer<Unit>, compliance: Float32, bendType: UInt32
): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_CreateConstraints(settings, compliance, bendType)
    }
}

/**
 * @brief 优化软体（对应 JPH_SoftBodySharedSettings_Optimize）
 */
public func JPH_SoftBodySharedSettings_Optimize_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_SoftBodySharedSettings_Optimize(settings)
    }
}

// =============================================================================
// 软体创建设置（SoftBodyCreationSettings）
// =============================================================================

/**
 * @brief 创建软体创建设置（对应 JPH_SoftBodyCreationSettings_Create）
 */
public func JPH_SoftBodyCreationSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_SoftBodyCreationSettings_Create()
    }
}

/**
 * @brief 创建软体创建设置（对应 JPH_SoftBodyCreationSettings_Create2）
 */
public func JPH_SoftBodyCreationSettings_Create2_cj(
    settings: CPointer<Unit>, position: CPointer<JPHVec3>,
    rotation: CPointer<JPHQuat>, objectLayer: UInt32
): CPointer<Unit> {
    unsafe {
        JPH_SoftBodyCreationSettings_Create2(settings, position, rotation, objectLayer)
    }
}

/**
 * @brief 销毁软体创建设置（对应 JPH_SoftBodyCreationSettings_Destroy）
 */
public func JPH_SoftBodyCreationSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_Destroy(settings)
    }
}

/**
 * @brief 获取共享设置句柄（对应 JPH_SoftBodyCreationSettings_GetSettings）
 */
public func JPH_SoftBodyCreationSettings_GetSettings_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_SoftBodyCreationSettings_GetSettings(settings)
    }
}

/**
 * @brief 设置共享设置（对应 JPH_SoftBodyCreationSettings_SetSettings）
 */
public func JPH_SoftBodyCreationSettings_SetSettings_cj(
    settings: CPointer<Unit>, sharedSettings: CPointer<Unit>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetSettings(settings, sharedSettings)
    }
}

/**
 * @brief 获取初始位置（对应 JPH_SoftBodyCreationSettings_GetPosition）
 */
public func JPH_SoftBodyCreationSettings_GetPosition_cj(
    settings: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_GetPosition(settings, result)
    }
}

/**
 * @brief 设置初始位置（对应 JPH_SoftBodyCreationSettings_SetPosition）
 */
public func JPH_SoftBodyCreationSettings_SetPosition_cj(
    settings: CPointer<Unit>, value: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetPosition(settings, value)
    }
}

/**
 * @brief 获取初始旋转（对应 JPH_SoftBodyCreationSettings_GetRotation）
 */
public func JPH_SoftBodyCreationSettings_GetRotation_cj(
    settings: CPointer<Unit>, result: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_GetRotation(settings, result)
    }
}

/**
 * @brief 设置初始旋转（对应 JPH_SoftBodyCreationSettings_SetRotation）
 */
public func JPH_SoftBodyCreationSettings_SetRotation_cj(
    settings: CPointer<Unit>, value: CPointer<JPHQuat>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetRotation(settings, value)
    }
}

/**
 * @brief 获取用户数据（对应 JPH_SoftBodyCreationSettings_GetUserData）
 */
public func JPH_SoftBodyCreationSettings_GetUserData_cj(settings: CPointer<Unit>): UInt64 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetUserData(settings)
    }
}

/**
 * @brief 设置用户数据（对应 JPH_SoftBodyCreationSettings_SetUserData）
 */
public func JPH_SoftBodyCreationSettings_SetUserData_cj(settings: CPointer<Unit>, userData: UInt64): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetUserData(settings, userData)
    }
}

/**
 * @brief 获取对象层（对应 JPH_SoftBodyCreationSettings_GetObjectLayer）
 */
public func JPH_SoftBodyCreationSettings_GetObjectLayer_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetObjectLayer(settings)
    }
}

/**
 * @brief 设置对象层（对应 JPH_SoftBodyCreationSettings_SetObjectLayer）
 */
public func JPH_SoftBodyCreationSettings_SetObjectLayer_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetObjectLayer(settings, value)
    }
}

/**
 * @brief 获取碰撞组（对应 JPH_SoftBodyCreationSettings_GetCollisionGroup）
 */
public func JPH_SoftBodyCreationSettings_GetCollisionGroup_cj(
    settings: CPointer<Unit>, result: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_GetCollisionGroup(settings, result)
    }
}

/**
 * @brief 设置碰撞组（对应 JPH_SoftBodyCreationSettings_SetCollisionGroup）
 */
public func JPH_SoftBodyCreationSettings_SetCollisionGroup_cj(
    settings: CPointer<Unit>, group: CPointer<JPHCollisionGroup>
): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetCollisionGroup(settings, group)
    }
}

/**
 * @brief 获取迭代次数（对应 JPH_SoftBodyCreationSettings_GetNumIterations）
 */
public func JPH_SoftBodyCreationSettings_GetNumIterations_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetNumIterations(settings)
    }
}

/**
 * @brief 设置迭代次数（对应 JPH_SoftBodyCreationSettings_SetNumIterations）
 */
public func JPH_SoftBodyCreationSettings_SetNumIterations_cj(settings: CPointer<Unit>, iterations: UInt32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetNumIterations(settings, iterations)
    }
}

/**
 * @brief 获取线阻尼（对应 JPH_SoftBodyCreationSettings_GetLinearDamping）
 */
public func JPH_SoftBodyCreationSettings_GetLinearDamping_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetLinearDamping(settings)
    }
}

/**
 * @brief 设置线阻尼（对应 JPH_SoftBodyCreationSettings_SetLinearDamping）
 */
public func JPH_SoftBodyCreationSettings_SetLinearDamping_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetLinearDamping(settings, value)
    }
}

/**
 * @brief 获取最大线速度（对应 JPH_SoftBodyCreationSettings_GetMaxLinearVelocity）
 */
public func JPH_SoftBodyCreationSettings_GetMaxLinearVelocity_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetMaxLinearVelocity(settings)
    }
}

/**
 * @brief 设置最大线速度（对应 JPH_SoftBodyCreationSettings_SetMaxLinearVelocity）
 */
public func JPH_SoftBodyCreationSettings_SetMaxLinearVelocity_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetMaxLinearVelocity(settings, value)
    }
}

/**
 * @brief 获取弹性系数（对应 JPH_SoftBodyCreationSettings_GetRestitution）
 */
public func JPH_SoftBodyCreationSettings_GetRestitution_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetRestitution(settings)
    }
}

/**
 * @brief 设置弹性系数（对应 JPH_SoftBodyCreationSettings_SetRestitution）
 */
public func JPH_SoftBodyCreationSettings_SetRestitution_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetRestitution(settings, value)
    }
}

/**
 * @brief 获取摩擦系数（对应 JPH_SoftBodyCreationSettings_GetFriction）
 */
public func JPH_SoftBodyCreationSettings_GetFriction_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetFriction(settings)
    }
}

/**
 * @brief 设置摩擦系数（对应 JPH_SoftBodyCreationSettings_SetFriction）
 */
public func JPH_SoftBodyCreationSettings_SetFriction_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetFriction(settings, value)
    }
}

/**
 * @brief 获取内部压力（对应 JPH_SoftBodyCreationSettings_GetPressure）
 */
public func JPH_SoftBodyCreationSettings_GetPressure_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetPressure(settings)
    }
}

/**
 * @brief 设置内部压力（对应 JPH_SoftBodyCreationSettings_SetPressure）
 */
public func JPH_SoftBodyCreationSettings_SetPressure_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetPressure(settings, value)
    }
}

/**
 * @brief 获取重力因子（对应 JPH_SoftBodyCreationSettings_GetGravityFactor）
 */
public func JPH_SoftBodyCreationSettings_GetGravityFactor_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetGravityFactor(settings)
    }
}

/**
 * @brief 设置重力因子（对应 JPH_SoftBodyCreationSettings_SetGravityFactor）
 */
public func JPH_SoftBodyCreationSettings_SetGravityFactor_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetGravityFactor(settings, value)
    }
}

/**
 * @brief 获取顶点半径（对应 JPH_SoftBodyCreationSettings_GetVertexRadius）
 */
public func JPH_SoftBodyCreationSettings_GetVertexRadius_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetVertexRadius(settings)
    }
}

/**
 * @brief 设置顶点半径（对应 JPH_SoftBodyCreationSettings_SetVertexRadius）
 */
public func JPH_SoftBodyCreationSettings_SetVertexRadius_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetVertexRadius(settings, value)
    }
}

/**
 * @brief 是否更新位置（对应 JPH_SoftBodyCreationSettings_GetUpdatePosition）
 */
public func JPH_SoftBodyCreationSettings_GetUpdatePosition_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetUpdatePosition(settings)
    }
}

/**
 * @brief 设置是否更新位置（对应 JPH_SoftBodyCreationSettings_SetUpdatePosition）
 */
public func JPH_SoftBodyCreationSettings_SetUpdatePosition_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetUpdatePosition(settings, value)
    }
}

/**
 * @brief 是否将旋转归为恒等（对应 JPH_SoftBodyCreationSettings_GetMakeRotationIdentity）
 */
public func JPH_SoftBodyCreationSettings_GetMakeRotationIdentity_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetMakeRotationIdentity(settings)
    }
}

/**
 * @brief 设置是否将旋转归为恒等（对应 JPH_SoftBodyCreationSettings_SetMakeRotationIdentity）
 */
public func JPH_SoftBodyCreationSettings_SetMakeRotationIdentity_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetMakeRotationIdentity(settings, value)
    }
}

/**
 * @brief 是否允许休眠（对应 JPH_SoftBodyCreationSettings_GetAllowSleeping）
 */
public func JPH_SoftBodyCreationSettings_GetAllowSleeping_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetAllowSleeping(settings)
    }
}

/**
 * @brief 设置是否允许休眠（对应 JPH_SoftBodyCreationSettings_SetAllowSleeping）
 */
public func JPH_SoftBodyCreationSettings_SetAllowSleeping_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetAllowSleeping(settings, value)
    }
}

/**
 * @brief 面是否双面（对应 JPH_SoftBodyCreationSettings_GetFacesDoubleSided）
 */
public func JPH_SoftBodyCreationSettings_GetFacesDoubleSided_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_SoftBodyCreationSettings_GetFacesDoubleSided(settings)
    }
}

/**
 * @brief 设置面是否双面（对应 JPH_SoftBodyCreationSettings_SetFacesDoubleSided）
 */
public func JPH_SoftBodyCreationSettings_SetFacesDoubleSided_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_SoftBodyCreationSettings_SetFacesDoubleSided(settings, value)
    }
}

// =============================================================================
// 摆动-扭转约束（SwingTwistConstraint）
// =============================================================================

/**
 * @brief 初始化摆动-扭转约束设置（对应 JPH_SwingTwistConstraintSettings_Init）
 */
public func JPH_SwingTwistConstraintSettings_Init_cj(settings: CPointer<JPHSwingTwistConstraintSettings>): Unit {
    unsafe {
        JPH_SwingTwistConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建摆动-扭转约束（对应 JPH_SwingTwistConstraint_Create）
 */
public func JPH_SwingTwistConstraint_Create_cj(
    settings: CPointer<JPHSwingTwistConstraintSettings>, body1: CPointer<Unit>, body2: CPointer<Unit>
): CPointer<Unit> {
    unsafe {
        JPH_SwingTwistConstraint_Create(settings, body1, body2)
    }
}

/**
 * @brief 获取摆动-扭转约束设置（对应 JPH_SwingTwistConstraint_GetSettings）
 */
public func JPH_SwingTwistConstraint_GetSettings_cj(
    constraint: CPointer<Unit>, settings: CPointer<JPHSwingTwistConstraintSettings>
): Unit {
    unsafe {
        JPH_SwingTwistConstraint_GetSettings(constraint, settings)
    }
}

/**
 * @brief 获取法线方向半锥角（对应 JPH_SwingTwistConstraint_GetNormalHalfConeAngle）
 */
public func JPH_SwingTwistConstraint_GetNormalHalfConeAngle_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SwingTwistConstraint_GetNormalHalfConeAngle(constraint)
    }
}

/**
 * @brief 获取位置 lambda（对应 JPH_SwingTwistConstraint_GetTotalLambdaPosition）
 */
public func JPH_SwingTwistConstraint_GetTotalLambdaPosition_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SwingTwistConstraint_GetTotalLambdaPosition(constraint, result)
    }
}

/**
 * @brief 获取扭转 lambda（对应 JPH_SwingTwistConstraint_GetTotalLambdaTwist）
 */
public func JPH_SwingTwistConstraint_GetTotalLambdaTwist_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SwingTwistConstraint_GetTotalLambdaTwist(constraint)
    }
}

/**
 * @brief 获取 Y 轴摆动 lambda（对应 JPH_SwingTwistConstraint_GetTotalLambdaSwingY）
 */
public func JPH_SwingTwistConstraint_GetTotalLambdaSwingY_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SwingTwistConstraint_GetTotalLambdaSwingY(constraint)
    }
}

/**
 * @brief 获取 Z 轴摆动 lambda（对应 JPH_SwingTwistConstraint_GetTotalLambdaSwingZ）
 */
public func JPH_SwingTwistConstraint_GetTotalLambdaSwingZ_cj(constraint: CPointer<Unit>): Float32 {
    unsafe {
        JPH_SwingTwistConstraint_GetTotalLambdaSwingZ(constraint)
    }
}

/**
 * @brief 获取电机 lambda（对应 JPH_SwingTwistConstraint_GetTotalLambdaMotor）
 */
public func JPH_SwingTwistConstraint_GetTotalLambdaMotor_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_SwingTwistConstraint_GetTotalLambdaMotor(constraint, result)
    }
}

// =============================================================================
// 履带车辆控制器（TrackedVehicleController）
// =============================================================================

/**
 * @brief 创建履带车辆控制器设置（对应 JPH_TrackedVehicleControllerSettings_Create）
 */
public func JPH_TrackedVehicleControllerSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_TrackedVehicleControllerSettings_Create()
    }
}

/**
 * @brief 获取履带车辆引擎设置（对应 JPH_TrackedVehicleControllerSettings_GetEngine）
 */
public func JPH_TrackedVehicleControllerSettings_GetEngine_cj(
    settings: CPointer<Unit>, result: CPointer<JPHVehicleEngineSettings>
): Unit {
    unsafe {
        JPH_TrackedVehicleControllerSettings_GetEngine(settings, result)
    }
}

/**
 * @brief 设置履带车辆引擎设置（对应 JPH_TrackedVehicleControllerSettings_SetEngine）
 */
public func JPH_TrackedVehicleControllerSettings_SetEngine_cj(
    settings: CPointer<Unit>, value: CPointer<JPHVehicleEngineSettings>
): Unit {
    unsafe {
        JPH_TrackedVehicleControllerSettings_SetEngine(settings, value)
    }
}

/**
 * @brief 设置指定履带设置（对应 JPH_TrackedVehicleControllerSettings_SetTrack）
 */
public func JPH_TrackedVehicleControllerSettings_SetTrack_cj(
    settings: CPointer<Unit>, index: UInt32, track: CPointer<JPHVehicleTrackSettings>
): Unit {
    unsafe {
        JPH_TrackedVehicleControllerSettings_SetTrack(settings, index, track)
    }
}

/**
 * @brief 获取指定侧履带（对应 JPH_TrackedVehicleController_GetTrack）
 */
public func JPH_TrackedVehicleController_GetTrack_cj(controller: CPointer<Unit>, side: UInt32): CPointer<Unit> {
    unsafe {
        JPH_TrackedVehicleController_GetTrack(controller, side)
    }
}

/**
 * @brief 获取履带车辆引擎句柄（对应 JPH_TrackedVehicleController_GetEngine）
 */
public func JPH_TrackedVehicleController_GetEngine_cj(controller: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TrackedVehicleController_GetEngine(controller)
    }
}

/**
 * @brief 获取履带车辆变速箱句柄（对应 JPH_TrackedVehicleController_GetTransmission）
 */
public func JPH_TrackedVehicleController_GetTransmission_cj(controller: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_TrackedVehicleController_GetTransmission(controller)
    }
}

/**
 * @brief 获取前进输入（对应 JPH_TrackedVehicleController_GetForwardInput）
 */
public func JPH_TrackedVehicleController_GetForwardInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TrackedVehicleController_GetForwardInput(controller)
    }
}

/**
 * @brief 设置前进输入（对应 JPH_TrackedVehicleController_SetForwardInput）
 */
public func JPH_TrackedVehicleController_SetForwardInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_TrackedVehicleController_SetForwardInput(controller, value)
    }
}

/**
 * @brief 获取左履带比例（对应 JPH_TrackedVehicleController_GetLeftRatio）
 */
public func JPH_TrackedVehicleController_GetLeftRatio_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TrackedVehicleController_GetLeftRatio(controller)
    }
}

/**
 * @brief 设置左履带比例（对应 JPH_TrackedVehicleController_SetLeftRatio）
 */
public func JPH_TrackedVehicleController_SetLeftRatio_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_TrackedVehicleController_SetLeftRatio(controller, value)
    }
}

/**
 * @brief 获取右履带比例（对应 JPH_TrackedVehicleController_GetRightRatio）
 */
public func JPH_TrackedVehicleController_GetRightRatio_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TrackedVehicleController_GetRightRatio(controller)
    }
}

/**
 * @brief 设置右履带比例（对应 JPH_TrackedVehicleController_SetRightRatio）
 */
public func JPH_TrackedVehicleController_SetRightRatio_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_TrackedVehicleController_SetRightRatio(controller, value)
    }
}

/**
 * @brief 获取刹车输入（对应 JPH_TrackedVehicleController_GetBrakeInput）
 */
public func JPH_TrackedVehicleController_GetBrakeInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_TrackedVehicleController_GetBrakeInput(controller)
    }
}

/**
 * @brief 设置刹车输入（对应 JPH_TrackedVehicleController_SetBrakeInput）
 */
public func JPH_TrackedVehicleController_SetBrakeInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_TrackedVehicleController_SetBrakeInput(controller, value)
    }
}

/**
 * @brief 设置驾驶输入（对应 JPH_TrackedVehicleController_SetDriverInput）
 */
public func JPH_TrackedVehicleController_SetDriverInput_cj(
    controller: CPointer<Unit>, forward: Float32, leftRatio: Float32, rightRatio: Float32, brake: Float32
): Unit {
    unsafe {
        JPH_TrackedVehicleController_SetDriverInput(controller, forward, leftRatio, rightRatio, brake)
    }
}

// =============================================================================
// 车辆：防倾杆 / 引擎 / 差速器 / 变速箱 / 履带
// =============================================================================

/**
 * @brief 初始化防倾杆设置（对应 JPH_VehicleAntiRollBar_Init）
 */
public func JPH_VehicleAntiRollBar_Init_cj(antiRollBar: CPointer<JPHVehicleAntiRollBar>): Unit {
    unsafe {
        JPH_VehicleAntiRollBar_Init(antiRollBar)
    }
}

/**
 * @brief 初始化引擎设置（对应 JPH_VehicleEngineSettings_Init）
 */
public func JPH_VehicleEngineSettings_Init_cj(settings: CPointer<JPHVehicleEngineSettings>): Unit {
    unsafe {
        JPH_VehicleEngineSettings_Init(settings)
    }
}

/**
 * @brief 钳制 RPM 到合理范围（对应 JPH_VehicleEngine_ClampRPM）
 */
public func JPH_VehicleEngine_ClampRPM_cj(engine: CPointer<Unit>): Unit {
    unsafe {
        JPH_VehicleEngine_ClampRPM(engine)
    }
}

/**
 * @brief 获取当前 RPM（对应 JPH_VehicleEngine_GetCurrentRPM）
 */
public func JPH_VehicleEngine_GetCurrentRPM_cj(engine: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleEngine_GetCurrentRPM(engine)
    }
}

/**
 * @brief 设置当前 RPM（对应 JPH_VehicleEngine_SetCurrentRPM）
 */
public func JPH_VehicleEngine_SetCurrentRPM_cj(engine: CPointer<Unit>, rpm: Float32): Unit {
    unsafe {
        JPH_VehicleEngine_SetCurrentRPM(engine, rpm)
    }
}

/**
 * @brief 获取引擎角速度（对应 JPH_VehicleEngine_GetAngularVelocity）
 */
public func JPH_VehicleEngine_GetAngularVelocity_cj(engine: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleEngine_GetAngularVelocity(engine)
    }
}

/**
 * @brief 获取引擎扭矩（对应 JPH_VehicleEngine_GetTorque）
 */
public func JPH_VehicleEngine_GetTorque_cj(engine: CPointer<Unit>, acceleration: Float32): Float32 {
    unsafe {
        JPH_VehicleEngine_GetTorque(engine, acceleration)
    }
}

/**
 * @brief 应用扭矩（对应 JPH_VehicleEngine_ApplyTorque）
 */
public func JPH_VehicleEngine_ApplyTorque_cj(engine: CPointer<Unit>, torque: Float32, deltaTime: Float32): Unit {
    unsafe {
        JPH_VehicleEngine_ApplyTorque(engine, torque, deltaTime)
    }
}

/**
 * @brief 应用阻尼（对应 JPH_VehicleEngine_ApplyDamping）
 */
public func JPH_VehicleEngine_ApplyDamping_cj(engine: CPointer<Unit>, deltaTime: Float32): Unit {
    unsafe {
        JPH_VehicleEngine_ApplyDamping(engine, deltaTime)
    }
}

/**
 * @brief 引擎是否允许休眠（对应 JPH_VehicleEngine_AllowSleep）
 */
public func JPH_VehicleEngine_AllowSleep_cj(engine: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_VehicleEngine_AllowSleep(engine)
    }
}

/**
 * @brief 初始化差速器设置（对应 JPH_VehicleDifferentialSettings_Init）
 */
public func JPH_VehicleDifferentialSettings_Init_cj(settings: CPointer<JPHVehicleDifferentialSettings>): Unit {
    unsafe {
        JPH_VehicleDifferentialSettings_Init(settings)
    }
}

/**
 * @brief 初始化履带设置（对应 JPH_VehicleTrackSettings_Init）
 */
public func JPH_VehicleTrackSettings_Init_cj(settings: CPointer<JPHVehicleTrackSettings>): Unit {
    unsafe {
        JPH_VehicleTrackSettings_Init(settings)
    }
}

/**
 * @brief 获取履带角速度（对应 JPH_VehicleTrack_GetAngularVelocity）
 */
public func JPH_VehicleTrack_GetAngularVelocity_cj(track: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTrack_GetAngularVelocity(track)
    }
}

/**
 * @brief 设置履带角速度（对应 JPH_VehicleTrack_SetAngularVelocity）
 */
public func JPH_VehicleTrack_SetAngularVelocity_cj(track: CPointer<Unit>, velocity: Float32): Unit {
    unsafe {
        JPH_VehicleTrack_SetAngularVelocity(track, velocity)
    }
}

/**
 * @brief 获取驱动轮索引（对应 JPH_VehicleTrack_GetDrivenWheel）
 */
public func JPH_VehicleTrack_GetDrivenWheel_cj(track: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleTrack_GetDrivenWheel(track)
    }
}

/**
 * @brief 获取履带转动惯量（对应 JPH_VehicleTrack_GetInertia）
 */
public func JPH_VehicleTrack_GetInertia_cj(track: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTrack_GetInertia(track)
    }
}

/**
 * @brief 获取履带角阻尼（对应 JPH_VehicleTrack_GetAngularDamping）
 */
public func JPH_VehicleTrack_GetAngularDamping_cj(track: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTrack_GetAngularDamping(track)
    }
}

/**
 * @brief 获取履带最大制动力矩（对应 JPH_VehicleTrack_GetMaxBrakeTorque）
 */
public func JPH_VehicleTrack_GetMaxBrakeTorque_cj(track: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTrack_GetMaxBrakeTorque(track)
    }
}

/**
 * @brief 获取履带差速比（对应 JPH_VehicleTrack_GetDifferentialRatio）
 */
public func JPH_VehicleTrack_GetDifferentialRatio_cj(track: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTrack_GetDifferentialRatio(track)
    }
}

// =============================================================================
// 车辆约束（VehicleConstraint）
// =============================================================================

/**
 * @brief 初始化车辆约束设置（对应 JPH_VehicleConstraintSettings_Init）
 */
public func JPH_VehicleConstraintSettings_Init_cj(settings: CPointer<JPHVehicleConstraintSettings>): Unit {
    unsafe {
        JPH_VehicleConstraintSettings_Init(settings)
    }
}

/**
 * @brief 创建车辆约束（对应 JPH_VehicleConstraint_Create）
 */
public func JPH_VehicleConstraint_Create_cj(
    body: CPointer<Unit>, settings: CPointer<JPHVehicleConstraintSettings>
): CPointer<Unit> {
    unsafe {
        JPH_VehicleConstraint_Create(body, settings)
    }
}

/**
 * @brief 车辆约束转为步进监听器句柄（对应 JPH_VehicleConstraint_AsPhysicsStepListener）
 */
public func JPH_VehicleConstraint_AsPhysicsStepListener_cj(constraint: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_VehicleConstraint_AsPhysicsStepListener(constraint)
    }
}

/**
 * @brief 设置最大俯仰/横滚角（对应 JPH_VehicleConstraint_SetMaxPitchRollAngle）
 */
public func JPH_VehicleConstraint_SetMaxPitchRollAngle_cj(
    constraint: CPointer<Unit>, maxPitchRollAngle: Float32
): Unit {
    unsafe {
        JPH_VehicleConstraint_SetMaxPitchRollAngle(constraint, maxPitchRollAngle)
    }
}

/**
 * @brief 设置车辆碰撞测试器（对应 JPH_VehicleConstraint_SetVehicleCollisionTester）
 */
public func JPH_VehicleConstraint_SetVehicleCollisionTester_cj(
    constraint: CPointer<Unit>, tester: CPointer<Unit>
): Unit {
    unsafe {
        JPH_VehicleConstraint_SetVehicleCollisionTester(constraint, tester)
    }
}

/**
 * @brief 覆盖重力（对应 JPH_VehicleConstraint_OverrideGravity）
 */
public func JPH_VehicleConstraint_OverrideGravity_cj(
    constraint: CPointer<Unit>, value: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_OverrideGravity(constraint, value)
    }
}

/**
 * @brief 重力是否被覆盖（对应 JPH_VehicleConstraint_IsGravityOverridden）
 */
public func JPH_VehicleConstraint_IsGravityOverridden_cj(constraint: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_VehicleConstraint_IsGravityOverridden(constraint)
    }
}

/**
 * @brief 获取重力覆盖值（对应 JPH_VehicleConstraint_GetGravityOverride）
 */
public func JPH_VehicleConstraint_GetGravityOverride_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetGravityOverride(constraint, result)
    }
}

/**
 * @brief 重置重力覆盖（对应 JPH_VehicleConstraint_ResetGravityOverride）
 */
public func JPH_VehicleConstraint_ResetGravityOverride_cj(constraint: CPointer<Unit>): Unit {
    unsafe {
        JPH_VehicleConstraint_ResetGravityOverride(constraint)
    }
}

/**
 * @brief 获取局部前进方向（对应 JPH_VehicleConstraint_GetLocalForward）
 */
public func JPH_VehicleConstraint_GetLocalForward_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetLocalForward(constraint, result)
    }
}

/**
 * @brief 获取局部上方向（对应 JPH_VehicleConstraint_GetLocalUp）
 */
public func JPH_VehicleConstraint_GetLocalUp_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetLocalUp(constraint, result)
    }
}

/**
 * @brief 获取世界空间上方向（对应 JPH_VehicleConstraint_GetWorldUp）
 */
public func JPH_VehicleConstraint_GetWorldUp_cj(
    constraint: CPointer<Unit>, result: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetWorldUp(constraint, result)
    }
}

/**
 * @brief 获取车辆刚体句柄（对应 JPH_VehicleConstraint_GetVehicleBody）
 */
public func JPH_VehicleConstraint_GetVehicleBody_cj(constraint: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_VehicleConstraint_GetVehicleBody(constraint)
    }
}

/**
 * @brief 获取车辆控制器句柄（对应 JPH_VehicleConstraint_GetController）
 */
public func JPH_VehicleConstraint_GetController_cj(constraint: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_VehicleConstraint_GetController(constraint)
    }
}

/**
 * @brief 获取车轮数量（对应 JPH_VehicleConstraint_GetWheelsCount）
 */
public func JPH_VehicleConstraint_GetWheelsCount_cj(constraint: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleConstraint_GetWheelsCount(constraint)
    }
}

/**
 * @brief 获取指定车轮句柄（对应 JPH_VehicleConstraint_GetWheel）
 */
public func JPH_VehicleConstraint_GetWheel_cj(constraint: CPointer<Unit>, index: UInt32): CPointer<Unit> {
    unsafe {
        JPH_VehicleConstraint_GetWheel(constraint, index)
    }
}

/**
 * @brief 获取车轮局部基向量（对应 JPH_VehicleConstraint_GetWheelLocalBasis）
 */
public func JPH_VehicleConstraint_GetWheelLocalBasis_cj(
    constraint: CPointer<Unit>, wheel: CPointer<Unit>,
    outForward: CPointer<JPHVec3>, outUp: CPointer<JPHVec3>, outRight: CPointer<JPHVec3>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetWheelLocalBasis(constraint, wheel, outForward, outUp, outRight)
    }
}

/**
 * @brief 获取车轮局部变换矩阵（对应 JPH_VehicleConstraint_GetWheelLocalTransform）
 */
public func JPH_VehicleConstraint_GetWheelLocalTransform_cj(
    constraint: CPointer<Unit>, wheelIndex: UInt32,
    wheelRight: CPointer<JPHVec3>, wheelUp: CPointer<JPHVec3>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetWheelLocalTransform(constraint, wheelIndex, wheelRight, wheelUp, result)
    }
}

/**
 * @brief 获取车轮世界变换矩阵（对应 JPH_VehicleConstraint_GetWheelWorldTransform）
 */
public func JPH_VehicleConstraint_GetWheelWorldTransform_cj(
    constraint: CPointer<Unit>, wheelIndex: UInt32,
    wheelRight: CPointer<JPHVec3>, wheelUp: CPointer<JPHVec3>, result: CPointer<JPHMat4>
): Unit {
    unsafe {
        JPH_VehicleConstraint_GetWheelWorldTransform(constraint, wheelIndex, wheelRight, wheelUp, result)
    }
}

// =============================================================================
// 车辆：碰撞测试器 / 控制器设置销毁
// =============================================================================

/**
 * @brief 销毁车辆碰撞测试器（对应 JPH_VehicleCollisionTester_Destroy）
 */
public func JPH_VehicleCollisionTester_Destroy_cj(tester: CPointer<Unit>): Unit {
    unsafe {
        JPH_VehicleCollisionTester_Destroy(tester)
    }
}

/**
 * @brief 获取碰撞测试器对象层（对应 JPH_VehicleCollisionTester_GetObjectLayer）
 */
public func JPH_VehicleCollisionTester_GetObjectLayer_cj(tester: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleCollisionTester_GetObjectLayer(tester)
    }
}

/**
 * @brief 设置碰撞测试器对象层（对应 JPH_VehicleCollisionTester_SetObjectLayer）
 */
public func JPH_VehicleCollisionTester_SetObjectLayer_cj(tester: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_VehicleCollisionTester_SetObjectLayer(tester, value)
    }
}

/**
 * @brief 创建射线碰撞测试器（对应 JPH_VehicleCollisionTesterRay_Create）
 */
public func JPH_VehicleCollisionTesterRay_Create_cj(
    layer: UInt32, up: CPointer<JPHVec3>, maxSlopeAngle: Float32
): CPointer<Unit> {
    unsafe {
        JPH_VehicleCollisionTesterRay_Create(layer, up, maxSlopeAngle)
    }
}

/**
 * @brief 创建球投射碰撞测试器（对应 JPH_VehicleCollisionTesterCastSphere_Create）
 */
public func JPH_VehicleCollisionTesterCastSphere_Create_cj(
    layer: UInt32, radius: Float32, up: CPointer<JPHVec3>, maxSlopeAngle: Float32
): CPointer<Unit> {
    unsafe {
        JPH_VehicleCollisionTesterCastSphere_Create(layer, radius, up, maxSlopeAngle)
    }
}

/**
 * @brief 创建圆柱投射碰撞测试器（对应 JPH_VehicleCollisionTesterCastCylinder_Create）
 */
public func JPH_VehicleCollisionTesterCastCylinder_Create_cj(
    layer: UInt32, convexRadiusFraction: Float32
): CPointer<Unit> {
    unsafe {
        JPH_VehicleCollisionTesterCastCylinder_Create(layer, convexRadiusFraction)
    }
}

/**
 * @brief 销毁车辆控制器设置（对应 JPH_VehicleControllerSettings_Destroy）
 */
public func JPH_VehicleControllerSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_VehicleControllerSettings_Destroy(settings)
    }
}

/**
 * @brief 获取控制器所属约束（对应 JPH_VehicleController_GetConstraint）
 */
public func JPH_VehicleController_GetConstraint_cj(controller: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_VehicleController_GetConstraint(controller)
    }
}

// =============================================================================
// 车辆变速箱设置（VehicleTransmissionSettings）与变速箱（VehicleTransmission）
// =============================================================================

/**
 * @brief 创建变速箱设置（对应 JPH_VehicleTransmissionSettings_Create）
 */
public func JPH_VehicleTransmissionSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_VehicleTransmissionSettings_Create()
    }
}

/**
 * @brief 销毁变速箱设置（对应 JPH_VehicleTransmissionSettings_Destroy）
 */
public func JPH_VehicleTransmissionSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_Destroy(settings)
    }
}

/**
 * @brief 获取变速箱模式（对应 JPH_VehicleTransmissionSettings_GetMode）
 */
public func JPH_VehicleTransmissionSettings_GetMode_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetMode(settings)
    }
}

/**
 * @brief 设置变速箱模式（对应 JPH_VehicleTransmissionSettings_SetMode）
 */
public func JPH_VehicleTransmissionSettings_SetMode_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetMode(settings, value)
    }
}

/**
 * @brief 获取档位比数量（对应 JPH_VehicleTransmissionSettings_GetGearRatioCount）
 */
public func JPH_VehicleTransmissionSettings_GetGearRatioCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetGearRatioCount(settings)
    }
}

/**
 * @brief 获取指定档位比（对应 JPH_VehicleTransmissionSettings_GetGearRatio）
 */
public func JPH_VehicleTransmissionSettings_GetGearRatio_cj(settings: CPointer<Unit>, index: UInt32): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetGearRatio(settings, index)
    }
}

/**
 * @brief 设置指定档位比（对应 JPH_VehicleTransmissionSettings_SetGearRatio）
 */
public func JPH_VehicleTransmissionSettings_SetGearRatio_cj(settings: CPointer<Unit>, index: UInt32, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetGearRatio(settings, index, value)
    }
}

/**
 * @brief 获取档位比数组指针（对应 JPH_VehicleTransmissionSettings_GetGearRatios）
 */
public func JPH_VehicleTransmissionSettings_GetGearRatios_cj(settings: CPointer<Unit>): CPointer<Float32> {
    unsafe {
        JPH_VehicleTransmissionSettings_GetGearRatios(settings)
    }
}

/**
 * @brief 批量设置档位比（对应 JPH_VehicleTransmissionSettings_SetGearRatios）
 */
public func JPH_VehicleTransmissionSettings_SetGearRatios_cj(
    settings: CPointer<Unit>, values: CPointer<Float32>, count: UInt32
): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetGearRatios(settings, values, count)
    }
}

/**
 * @brief 获取倒档比数量（对应 JPH_VehicleTransmissionSettings_GetReverseGearRatioCount）
 */
public func JPH_VehicleTransmissionSettings_GetReverseGearRatioCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetReverseGearRatioCount(settings)
    }
}

/**
 * @brief 获取指定倒档比（对应 JPH_VehicleTransmissionSettings_GetReverseGearRatio）
 */
public func JPH_VehicleTransmissionSettings_GetReverseGearRatio_cj(settings: CPointer<Unit>, index: UInt32): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetReverseGearRatio(settings, index)
    }
}

/**
 * @brief 设置指定倒档比（对应 JPH_VehicleTransmissionSettings_SetReverseGearRatio）
 */
public func JPH_VehicleTransmissionSettings_SetReverseGearRatio_cj(settings: CPointer<Unit>, index: UInt32, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetReverseGearRatio(settings, index, value)
    }
}

/**
 * @brief 获取倒档比数组指针（对应 JPH_VehicleTransmissionSettings_GetReverseGearRatios）
 */
public func JPH_VehicleTransmissionSettings_GetReverseGearRatios_cj(settings: CPointer<Unit>): CPointer<Float32> {
    unsafe {
        JPH_VehicleTransmissionSettings_GetReverseGearRatios(settings)
    }
}

/**
 * @brief 批量设置倒档比（对应 JPH_VehicleTransmissionSettings_SetReverseGearRatios）
 */
public func JPH_VehicleTransmissionSettings_SetReverseGearRatios_cj(
    settings: CPointer<Unit>, values: CPointer<Float32>, count: UInt32
): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetReverseGearRatios(settings, values, count)
    }
}

/**
 * @brief 获取升档 RPM（对应 JPH_VehicleTransmissionSettings_GetShiftUpRPM）
 */
public func JPH_VehicleTransmissionSettings_GetShiftUpRPM_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetShiftUpRPM(settings)
    }
}

/**
 * @brief 设置升档 RPM（对应 JPH_VehicleTransmissionSettings_SetShiftUpRPM）
 */
public func JPH_VehicleTransmissionSettings_SetShiftUpRPM_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetShiftUpRPM(settings, value)
    }
}

/**
 * @brief 获取降档 RPM（对应 JPH_VehicleTransmissionSettings_GetShiftDownRPM）
 */
public func JPH_VehicleTransmissionSettings_GetShiftDownRPM_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetShiftDownRPM(settings)
    }
}

/**
 * @brief 设置降档 RPM（对应 JPH_VehicleTransmissionSettings_SetShiftDownRPM）
 */
public func JPH_VehicleTransmissionSettings_SetShiftDownRPM_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetShiftDownRPM(settings, value)
    }
}

/**
 * @brief 获取换挡延迟（对应 JPH_VehicleTransmissionSettings_GetSwitchLatency）
 */
public func JPH_VehicleTransmissionSettings_GetSwitchLatency_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetSwitchLatency(settings)
    }
}

/**
 * @brief 设置换挡延迟（对应 JPH_VehicleTransmissionSettings_SetSwitchLatency）
 */
public func JPH_VehicleTransmissionSettings_SetSwitchLatency_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetSwitchLatency(settings, value)
    }
}

/**
 * @brief 获取换挡时间（对应 JPH_VehicleTransmissionSettings_GetSwitchTime）
 */
public func JPH_VehicleTransmissionSettings_GetSwitchTime_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetSwitchTime(settings)
    }
}

/**
 * @brief 设置换挡时间（对应 JPH_VehicleTransmissionSettings_SetSwitchTime）
 */
public func JPH_VehicleTransmissionSettings_SetSwitchTime_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetSwitchTime(settings, value)
    }
}

/**
 * @brief 获取离合器强度（对应 JPH_VehicleTransmissionSettings_GetClutchStrength）
 */
public func JPH_VehicleTransmissionSettings_GetClutchStrength_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetClutchStrength(settings)
    }
}

/**
 * @brief 设置离合器强度（对应 JPH_VehicleTransmissionSettings_SetClutchStrength）
 */
public func JPH_VehicleTransmissionSettings_SetClutchStrength_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetClutchStrength(settings, value)
    }
}

/**
 * @brief 获取离合器释放时间（对应 JPH_VehicleTransmissionSettings_GetClutchReleaseTime）
 */
public func JPH_VehicleTransmissionSettings_GetClutchReleaseTime_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmissionSettings_GetClutchReleaseTime(settings)
    }
}

/**
 * @brief 设置离合器释放时间（对应 JPH_VehicleTransmissionSettings_SetClutchReleaseTime）
 */
public func JPH_VehicleTransmissionSettings_SetClutchReleaseTime_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_VehicleTransmissionSettings_SetClutchReleaseTime(settings, value)
    }
}

/**
 * @brief 变速箱是否允许休眠（对应 JPH_VehicleTransmission_AllowSleep）
 */
public func JPH_VehicleTransmission_AllowSleep_cj(transmission: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_VehicleTransmission_AllowSleep(transmission)
    }
}

/**
 * @brief 获取离合器摩擦力（对应 JPH_VehicleTransmission_GetClutchFriction）
 */
public func JPH_VehicleTransmission_GetClutchFriction_cj(transmission: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmission_GetClutchFriction(transmission)
    }
}

/**
 * @brief 获取当前档位（对应 JPH_VehicleTransmission_GetCurrentGear）
 */
public func JPH_VehicleTransmission_GetCurrentGear_cj(transmission: CPointer<Unit>): Int32 {
    unsafe {
        JPH_VehicleTransmission_GetCurrentGear(transmission)
    }
}

/**
 * @brief 获取当前传动比（对应 JPH_VehicleTransmission_GetCurrentRatio）
 */
public func JPH_VehicleTransmission_GetCurrentRatio_cj(transmission: CPointer<Unit>): Float32 {
    unsafe {
        JPH_VehicleTransmission_GetCurrentRatio(transmission)
    }
}

/**
 * @brief 是否正在换挡（对应 JPH_VehicleTransmission_IsSwitchingGear）
 */
public func JPH_VehicleTransmission_IsSwitchingGear_cj(transmission: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_VehicleTransmission_IsSwitchingGear(transmission)
    }
}

/**
 * @brief 设置变速箱状态（对应 JPH_VehicleTransmission_Set）
 */
public func JPH_VehicleTransmission_Set_cj(transmission: CPointer<Unit>, currentGear: Int32, clutchFriction: Float32): Unit {
    unsafe {
        JPH_VehicleTransmission_Set(transmission, currentGear, clutchFriction)
    }
}

/**
 * @brief 设置变速箱模式（对应 JPH_VehicleTransmission_SetMode）
 */
public func JPH_VehicleTransmission_SetMode_cj(transmission: CPointer<Unit>, mode: UInt32): Unit {
    unsafe {
        JPH_VehicleTransmission_SetMode(transmission, mode)
    }
}

/**
 * @brief 更新变速箱（对应 JPH_VehicleTransmission_Update）
 */
public func JPH_VehicleTransmission_Update_cj(transmission: CPointer<Unit>, deltaTime: Float32, currentRPM: Float32, forwardInput: Float32, canShiftUp: UInt8): Unit {
    unsafe {
        JPH_VehicleTransmission_Update(transmission, deltaTime, currentRPM, forwardInput, canShiftUp)
    }
}

// =============================================================================
// 车辆车轮设置（WheelSettings）
// =============================================================================

/**
 * @brief 创建车轮设置（对应 JPH_WheelSettings_Create）
 */
public func JPH_WheelSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_WheelSettings_Create()
    }
}

/**
 * @brief 销毁车轮设置（对应 JPH_WheelSettings_Destroy）
 */
public func JPH_WheelSettings_Destroy_cj(settings: CPointer<Unit>): Unit {
    unsafe {
        JPH_WheelSettings_Destroy(settings)
    }
}

/**
 * @brief 获取车轮位置（对应 JPH_WheelSettings_GetPosition）
 */
public func JPH_WheelSettings_GetPosition_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetPosition(settings, result)
    }
}

/**
 * @brief 设置车轮位置（对应 JPH_WheelSettings_SetPosition）
 */
public func JPH_WheelSettings_SetPosition_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetPosition(settings, value)
    }
}

/**
 * @brief 获取悬挂力作用点（对应 JPH_WheelSettings_GetSuspensionForcePoint）
 */
public func JPH_WheelSettings_GetSuspensionForcePoint_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetSuspensionForcePoint(settings, result)
    }
}

/**
 * @brief 设置悬挂力作用点（对应 JPH_WheelSettings_SetSuspensionForcePoint）
 */
public func JPH_WheelSettings_SetSuspensionForcePoint_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionForcePoint(settings, value)
    }
}

/**
 * @brief 获取悬挂方向（对应 JPH_WheelSettings_GetSuspensionDirection）
 */
public func JPH_WheelSettings_GetSuspensionDirection_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetSuspensionDirection(settings, result)
    }
}

/**
 * @brief 设置悬挂方向（对应 JPH_WheelSettings_SetSuspensionDirection）
 */
public func JPH_WheelSettings_SetSuspensionDirection_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionDirection(settings, value)
    }
}

/**
 * @brief 获取转向轴（对应 JPH_WheelSettings_GetSteeringAxis）
 */
public func JPH_WheelSettings_GetSteeringAxis_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetSteeringAxis(settings, result)
    }
}

/**
 * @brief 设置转向轴（对应 JPH_WheelSettings_SetSteeringAxis）
 */
public func JPH_WheelSettings_SetSteeringAxis_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetSteeringAxis(settings, value)
    }
}

/**
 * @brief 获取轮轴上方向（对应 JPH_WheelSettings_GetWheelUp）
 */
public func JPH_WheelSettings_GetWheelUp_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetWheelUp(settings, result)
    }
}

/**
 * @brief 设置轮轴上方向（对应 JPH_WheelSettings_SetWheelUp）
 */
public func JPH_WheelSettings_SetWheelUp_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetWheelUp(settings, value)
    }
}

/**
 * @brief 获取轮轴前进方向（对应 JPH_WheelSettings_GetWheelForward）
 */
public func JPH_WheelSettings_GetWheelForward_cj(settings: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_GetWheelForward(settings, result)
    }
}

/**
 * @brief 设置轮轴前进方向（对应 JPH_WheelSettings_SetWheelForward）
 */
public func JPH_WheelSettings_SetWheelForward_cj(settings: CPointer<Unit>, value: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_WheelSettings_SetWheelForward(settings, value)
    }
}

/**
 * @brief 获取悬挂最小长度（对应 JPH_WheelSettings_GetSuspensionMinLength）
 */
public func JPH_WheelSettings_GetSuspensionMinLength_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettings_GetSuspensionMinLength(settings)
    }
}

/**
 * @brief 设置悬挂最小长度（对应 JPH_WheelSettings_SetSuspensionMinLength）
 */
public func JPH_WheelSettings_SetSuspensionMinLength_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionMinLength(settings, value)
    }
}

/**
 * @brief 获取悬挂最大长度（对应 JPH_WheelSettings_GetSuspensionMaxLength）
 */
public func JPH_WheelSettings_GetSuspensionMaxLength_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettings_GetSuspensionMaxLength(settings)
    }
}

/**
 * @brief 设置悬挂最大长度（对应 JPH_WheelSettings_SetSuspensionMaxLength）
 */
public func JPH_WheelSettings_SetSuspensionMaxLength_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionMaxLength(settings, value)
    }
}

/**
 * @brief 获取悬挂预载长度（对应 JPH_WheelSettings_GetSuspensionPreloadLength）
 */
public func JPH_WheelSettings_GetSuspensionPreloadLength_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettings_GetSuspensionPreloadLength(settings)
    }
}

/**
 * @brief 设置悬挂预载长度（对应 JPH_WheelSettings_SetSuspensionPreloadLength）
 */
public func JPH_WheelSettings_SetSuspensionPreloadLength_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionPreloadLength(settings, value)
    }
}

/**
 * @brief 获取悬挂弹簧设置（对应 JPH_WheelSettings_GetSuspensionSpring）
 */
public func JPH_WheelSettings_GetSuspensionSpring_cj(
    settings: CPointer<Unit>, result: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_WheelSettings_GetSuspensionSpring(settings, result)
    }
}

/**
 * @brief 设置悬挂弹簧设置（对应 JPH_WheelSettings_SetSuspensionSpring）
 */
public func JPH_WheelSettings_SetSuspensionSpring_cj(
    settings: CPointer<Unit>, springSettings: CPointer<JPHSpringSettings>
): Unit {
    unsafe {
        JPH_WheelSettings_SetSuspensionSpring(settings, springSettings)
    }
}

/**
 * @brief 获取车轮半径（对应 JPH_WheelSettings_GetRadius）
 */
public func JPH_WheelSettings_GetRadius_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettings_GetRadius(settings)
    }
}

/**
 * @brief 设置车轮半径（对应 JPH_WheelSettings_SetRadius）
 */
public func JPH_WheelSettings_SetRadius_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettings_SetRadius(settings, value)
    }
}

/**
 * @brief 获取车轮宽度（对应 JPH_WheelSettings_GetWidth）
 */
public func JPH_WheelSettings_GetWidth_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettings_GetWidth(settings)
    }
}

/**
 * @brief 设置车轮宽度（对应 JPH_WheelSettings_SetWidth）
 */
public func JPH_WheelSettings_SetWidth_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettings_SetWidth(settings, value)
    }
}

/**
 * @brief 是否启用悬挂力作用点（对应 JPH_WheelSettings_GetEnableSuspensionForcePoint）
 */
public func JPH_WheelSettings_GetEnableSuspensionForcePoint_cj(settings: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_WheelSettings_GetEnableSuspensionForcePoint(settings)
    }
}

/**
 * @brief 设置是否启用悬挂力作用点（对应 JPH_WheelSettings_SetEnableSuspensionForcePoint）
 */
public func JPH_WheelSettings_SetEnableSuspensionForcePoint_cj(settings: CPointer<Unit>, value: UInt8): Unit {
    unsafe {
        JPH_WheelSettings_SetEnableSuspensionForcePoint(settings, value)
    }
}

// =============================================================================
// 车辆车轮（Wheel）
// =============================================================================

/**
 * @brief 创建车轮（对应 JPH_Wheel_Create）
 */
public func JPH_Wheel_Create_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Wheel_Create(settings)
    }
}

/**
 * @brief 销毁车轮（对应 JPH_Wheel_Destroy）
 */
public func JPH_Wheel_Destroy_cj(wheel: CPointer<Unit>): Unit {
    unsafe {
        JPH_Wheel_Destroy(wheel)
    }
}

/**
 * @brief 获取车轮设置句柄（对应 JPH_Wheel_GetSettings）
 */
public func JPH_Wheel_GetSettings_cj(wheel: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_Wheel_GetSettings(wheel)
    }
}

/**
 * @brief 获取车轮角速度（对应 JPH_Wheel_GetAngularVelocity）
 */
public func JPH_Wheel_GetAngularVelocity_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetAngularVelocity(wheel)
    }
}

/**
 * @brief 设置车轮角速度（对应 JPH_Wheel_SetAngularVelocity）
 */
public func JPH_Wheel_SetAngularVelocity_cj(wheel: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_Wheel_SetAngularVelocity(wheel, value)
    }
}

/**
 * @brief 获取车轮旋转角（对应 JPH_Wheel_GetRotationAngle）
 */
public func JPH_Wheel_GetRotationAngle_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetRotationAngle(wheel)
    }
}

/**
 * @brief 设置车轮旋转角（对应 JPH_Wheel_SetRotationAngle）
 */
public func JPH_Wheel_SetRotationAngle_cj(wheel: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_Wheel_SetRotationAngle(wheel, value)
    }
}

/**
 * @brief 获取车轮转向角（对应 JPH_Wheel_GetSteerAngle）
 */
public func JPH_Wheel_GetSteerAngle_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetSteerAngle(wheel)
    }
}

/**
 * @brief 设置车轮转向角（对应 JPH_Wheel_SetSteerAngle）
 */
public func JPH_Wheel_SetSteerAngle_cj(wheel: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_Wheel_SetSteerAngle(wheel, value)
    }
}

/**
 * @brief 车轮是否有接触（对应 JPH_Wheel_HasContact）
 */
public func JPH_Wheel_HasContact_cj(wheel: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Wheel_HasContact(wheel)
    }
}

/**
 * @brief 获取接触刚体 BodyID（对应 JPH_Wheel_GetContactBodyID）
 */
public func JPH_Wheel_GetContactBodyID_cj(wheel: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Wheel_GetContactBodyID(wheel)
    }
}

/**
 * @brief 获取接触子形状 ID（对应 JPH_Wheel_GetContactSubShapeID）
 */
public func JPH_Wheel_GetContactSubShapeID_cj(wheel: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_Wheel_GetContactSubShapeID(wheel)
    }
}

/**
 * @brief 获取接触位置（对应 JPH_Wheel_GetContactPosition）
 */
public func JPH_Wheel_GetContactPosition_cj(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Wheel_GetContactPosition(wheel, result)
    }
}

/**
 * @brief 获取接触点速度（对应 JPH_Wheel_GetContactPointVelocity）
 */
public func JPH_Wheel_GetContactPointVelocity_cj(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Wheel_GetContactPointVelocity(wheel, result)
    }
}

/**
 * @brief 获取接触法线（对应 JPH_Wheel_GetContactNormal）
 */
public func JPH_Wheel_GetContactNormal_cj(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Wheel_GetContactNormal(wheel, result)
    }
}

/**
 * @brief 获取接触纵向方向（对应 JPH_Wheel_GetContactLongitudinal）
 */
public func JPH_Wheel_GetContactLongitudinal_cj(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Wheel_GetContactLongitudinal(wheel, result)
    }
}

/**
 * @brief 获取接触横向方向（对应 JPH_Wheel_GetContactLateral）
 */
public func JPH_Wheel_GetContactLateral_cj(wheel: CPointer<Unit>, result: CPointer<JPHVec3>): Unit {
    unsafe {
        JPH_Wheel_GetContactLateral(wheel, result)
    }
}

/**
 * @brief 获取悬挂长度（对应 JPH_Wheel_GetSuspensionLength）
 */
public func JPH_Wheel_GetSuspensionLength_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetSuspensionLength(wheel)
    }
}

/**
 * @brief 获取悬挂 lambda（对应 JPH_Wheel_GetSuspensionLambda）
 */
public func JPH_Wheel_GetSuspensionLambda_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetSuspensionLambda(wheel)
    }
}

/**
 * @brief 获取纵向 lambda（对应 JPH_Wheel_GetLongitudinalLambda）
 */
public func JPH_Wheel_GetLongitudinalLambda_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetLongitudinalLambda(wheel)
    }
}

/**
 * @brief 获取横向 lambda（对应 JPH_Wheel_GetLateralLambda）
 */
public func JPH_Wheel_GetLateralLambda_cj(wheel: CPointer<Unit>): Float32 {
    unsafe {
        JPH_Wheel_GetLateralLambda(wheel)
    }
}

/**
 * @brief 是否已撞到硬点（对应 JPH_Wheel_HasHitHardPoint）
 */
public func JPH_Wheel_HasHitHardPoint_cj(wheel: CPointer<Unit>): UInt8 {
    unsafe {
        JPH_Wheel_HasHitHardPoint(wheel)
    }
}

// =============================================================================
// 车辆：履带车轮设置 / 轮式车轮设置 / 轮式车轮
// =============================================================================

/**
 * @brief 创建履带车辆车轮设置（对应 JPH_WheelSettingsTV_Create）
 */
public func JPH_WheelSettingsTV_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_WheelSettingsTV_Create()
    }
}

/**
 * @brief 获取纵向摩擦力（对应 JPH_WheelSettingsTV_GetLongitudinalFriction）
 */
public func JPH_WheelSettingsTV_GetLongitudinalFriction_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsTV_GetLongitudinalFriction(settings)
    }
}

/**
 * @brief 设置纵向摩擦力（对应 JPH_WheelSettingsTV_SetLongitudinalFriction）
 */
public func JPH_WheelSettingsTV_SetLongitudinalFriction_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsTV_SetLongitudinalFriction(settings, value)
    }
}

/**
 * @brief 获取横向摩擦力（对应 JPH_WheelSettingsTV_GetLateralFriction）
 */
public func JPH_WheelSettingsTV_GetLateralFriction_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsTV_GetLateralFriction(settings)
    }
}

/**
 * @brief 设置横向摩擦力（对应 JPH_WheelSettingsTV_SetLateralFriction）
 */
public func JPH_WheelSettingsTV_SetLateralFriction_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsTV_SetLateralFriction(settings, value)
    }
}

/**
 * @brief 创建履带车辆车轮（对应 JPH_WheelTV_Create）
 */
public func JPH_WheelTV_Create_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelTV_Create(settings)
    }
}

/**
 * @brief 获取履带车辆车轮设置（对应 JPH_WheelTV_GetSettings）
 */
public func JPH_WheelTV_GetSettings_cj(wheel: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelTV_GetSettings(wheel)
    }
}

/**
 * @brief 创建轮式车辆车轮设置（对应 JPH_WheelSettingsWV_Create）
 */
public func JPH_WheelSettingsWV_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_WheelSettingsWV_Create()
    }
}

/**
 * @brief 获取转动惯量（对应 JPH_WheelSettingsWV_GetInertia）
 */
public func JPH_WheelSettingsWV_GetInertia_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsWV_GetInertia(settings)
    }
}

/**
 * @brief 设置转动惯量（对应 JPH_WheelSettingsWV_SetInertia）
 */
public func JPH_WheelSettingsWV_SetInertia_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetInertia(settings, value)
    }
}

/**
 * @brief 获取角阻尼（对应 JPH_WheelSettingsWV_GetAngularDamping）
 */
public func JPH_WheelSettingsWV_GetAngularDamping_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsWV_GetAngularDamping(settings)
    }
}

/**
 * @brief 设置角阻尼（对应 JPH_WheelSettingsWV_SetAngularDamping）
 */
public func JPH_WheelSettingsWV_SetAngularDamping_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetAngularDamping(settings, value)
    }
}

/**
 * @brief 获取最大转向角（对应 JPH_WheelSettingsWV_GetMaxSteerAngle）
 */
public func JPH_WheelSettingsWV_GetMaxSteerAngle_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsWV_GetMaxSteerAngle(settings)
    }
}

/**
 * @brief 设置最大转向角（对应 JPH_WheelSettingsWV_SetMaxSteerAngle）
 */
public func JPH_WheelSettingsWV_SetMaxSteerAngle_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetMaxSteerAngle(settings, value)
    }
}

/**
 * @brief 获取纵向摩擦力曲线（对应 JPH_WheelSettingsWV_GetLongitudinalFriction）
 */
public func JPH_WheelSettingsWV_GetLongitudinalFriction_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelSettingsWV_GetLongitudinalFriction(settings)
    }
}

/**
 * @brief 设置纵向摩擦力曲线（对应 JPH_WheelSettingsWV_SetLongitudinalFriction）
 */
public func JPH_WheelSettingsWV_SetLongitudinalFriction_cj(settings: CPointer<Unit>, value: CPointer<Unit>): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetLongitudinalFriction(settings, value)
    }
}

/**
 * @brief 获取横向摩擦力曲线（对应 JPH_WheelSettingsWV_GetLateralFriction）
 */
public func JPH_WheelSettingsWV_GetLateralFriction_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelSettingsWV_GetLateralFriction(settings)
    }
}

/**
 * @brief 设置横向摩擦力曲线（对应 JPH_WheelSettingsWV_SetLateralFriction）
 */
public func JPH_WheelSettingsWV_SetLateralFriction_cj(settings: CPointer<Unit>, value: CPointer<Unit>): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetLateralFriction(settings, value)
    }
}

/**
 * @brief 获取最大制动力矩（对应 JPH_WheelSettingsWV_GetMaxBrakeTorque）
 */
public func JPH_WheelSettingsWV_GetMaxBrakeTorque_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsWV_GetMaxBrakeTorque(settings)
    }
}

/**
 * @brief 设置最大制动力矩（对应 JPH_WheelSettingsWV_SetMaxBrakeTorque）
 */
public func JPH_WheelSettingsWV_SetMaxBrakeTorque_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetMaxBrakeTorque(settings, value)
    }
}

/**
 * @brief 获取最大手刹力矩（对应 JPH_WheelSettingsWV_GetMaxHandBrakeTorque）
 */
public func JPH_WheelSettingsWV_GetMaxHandBrakeTorque_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheelSettingsWV_GetMaxHandBrakeTorque(settings)
    }
}

/**
 * @brief 设置最大手刹力矩（对应 JPH_WheelSettingsWV_SetMaxHandBrakeTorque）
 */
public func JPH_WheelSettingsWV_SetMaxHandBrakeTorque_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheelSettingsWV_SetMaxHandBrakeTorque(settings, value)
    }
}

/**
 * @brief 创建轮式车辆车轮（对应 JPH_WheelWV_Create）
 */
public func JPH_WheelWV_Create_cj(settings: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelWV_Create(settings)
    }
}

/**
 * @brief 获取轮式车辆车轮设置（对应 JPH_WheelWV_GetSettings）
 */
public func JPH_WheelWV_GetSettings_cj(wheel: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheelWV_GetSettings(wheel)
    }
}

/**
 * @brief 对车轮施加扭矩（对应 JPH_WheelWV_ApplyTorque）
 */
public func JPH_WheelWV_ApplyTorque_cj(wheel: CPointer<Unit>, torque: Float32, deltaTime: Float32): Unit {
    unsafe {
        JPH_WheelWV_ApplyTorque(wheel, torque, deltaTime)
    }
}

// =============================================================================
// 轮式车辆控制器设置（WheeledVehicleControllerSettings）与控制器（WheeledVehicleController）
// =============================================================================

/**
 * @brief 创建轮式车辆控制器设置（对应 JPH_WheeledVehicleControllerSettings_Create）
 */
public func JPH_WheeledVehicleControllerSettings_Create_cj(): CPointer<Unit> {
    unsafe {
        JPH_WheeledVehicleControllerSettings_Create()
    }
}

/**
 * @brief 获取引擎设置（对应 JPH_WheeledVehicleControllerSettings_GetEngine）
 */
public func JPH_WheeledVehicleControllerSettings_GetEngine_cj(
    settings: CPointer<Unit>, result: CPointer<JPHVehicleEngineSettings>
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_GetEngine(settings, result)
    }
}

/**
 * @brief 设置引擎设置（对应 JPH_WheeledVehicleControllerSettings_SetEngine）
 */
public func JPH_WheeledVehicleControllerSettings_SetEngine_cj(
    settings: CPointer<Unit>, value: CPointer<JPHVehicleEngineSettings>
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetEngine(settings, value)
    }
}

/**
 * @brief 获取指定差速器设置（对应 JPH_WheeledVehicleControllerSettings_GetDifferential）
 */
public func JPH_WheeledVehicleControllerSettings_GetDifferential_cj(
    settings: CPointer<Unit>, index: UInt32, result: CPointer<JPHVehicleDifferentialSettings>
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_GetDifferential(settings, index, result)
    }
}

/**
 * @brief 设置指定差速器设置（对应 JPH_WheeledVehicleControllerSettings_SetDifferential）
 */
public func JPH_WheeledVehicleControllerSettings_SetDifferential_cj(
    settings: CPointer<Unit>, index: UInt32, value: CPointer<JPHVehicleDifferentialSettings>
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetDifferential(settings, index, value)
    }
}

/**
 * @brief 批量设置差速器设置（对应 JPH_WheeledVehicleControllerSettings_SetDifferentials）
 */
public func JPH_WheeledVehicleControllerSettings_SetDifferentials_cj(
    settings: CPointer<Unit>, values: CPointer<JPHVehicleDifferentialSettings>, count: UInt32
): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetDifferentials(settings, values, count)
    }
}

/**
 * @brief 获取差速器数量（对应 JPH_WheeledVehicleControllerSettings_GetDifferentialsCount）
 */
public func JPH_WheeledVehicleControllerSettings_GetDifferentialsCount_cj(settings: CPointer<Unit>): UInt32 {
    unsafe {
        JPH_WheeledVehicleControllerSettings_GetDifferentialsCount(settings)
    }
}

/**
 * @brief 设置差速器数量（对应 JPH_WheeledVehicleControllerSettings_SetDifferentialsCount）
 */
public func JPH_WheeledVehicleControllerSettings_SetDifferentialsCount_cj(settings: CPointer<Unit>, value: UInt32): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetDifferentialsCount(settings, value)
    }
}

/**
 * @brief 获取差速器限滑比（对应 JPH_WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio）
 */
public func JPH_WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio_cj(settings: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleControllerSettings_GetDifferentialLimitedSlipRatio(settings)
    }
}

/**
 * @brief 设置差速器限滑比（对应 JPH_WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio）
 */
public func JPH_WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio_cj(settings: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheeledVehicleControllerSettings_SetDifferentialLimitedSlipRatio(settings, value)
    }
}

/**
 * @brief 获取引擎句柄（对应 JPH_WheeledVehicleController_GetEngine）
 */
public func JPH_WheeledVehicleController_GetEngine_cj(controller: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheeledVehicleController_GetEngine(controller)
    }
}

/**
 * @brief 获取变速箱句柄（对应 JPH_WheeledVehicleController_GetTransmission）
 */
public func JPH_WheeledVehicleController_GetTransmission_cj(controller: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        JPH_WheeledVehicleController_GetTransmission(controller)
    }
}

/**
 * @brief 获取前进输入（对应 JPH_WheeledVehicleController_GetForwardInput）
 */
public func JPH_WheeledVehicleController_GetForwardInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleController_GetForwardInput(controller)
    }
}

/**
 * @brief 设置前进输入（对应 JPH_WheeledVehicleController_SetForwardInput）
 */
public func JPH_WheeledVehicleController_SetForwardInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetForwardInput(controller, value)
    }
}

/**
 * @brief 获取右转输入（对应 JPH_WheeledVehicleController_GetRightInput）
 */
public func JPH_WheeledVehicleController_GetRightInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleController_GetRightInput(controller)
    }
}

/**
 * @brief 设置右转输入（对应 JPH_WheeledVehicleController_SetRightInput）
 */
public func JPH_WheeledVehicleController_SetRightInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetRightInput(controller, value)
    }
}

/**
 * @brief 获取刹车输入（对应 JPH_WheeledVehicleController_GetBrakeInput）
 */
public func JPH_WheeledVehicleController_GetBrakeInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleController_GetBrakeInput(controller)
    }
}

/**
 * @brief 设置刹车输入（对应 JPH_WheeledVehicleController_SetBrakeInput）
 */
public func JPH_WheeledVehicleController_SetBrakeInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetBrakeInput(controller, value)
    }
}

/**
 * @brief 获取手刹输入（对应 JPH_WheeledVehicleController_GetHandBrakeInput）
 */
public func JPH_WheeledVehicleController_GetHandBrakeInput_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleController_GetHandBrakeInput(controller)
    }
}

/**
 * @brief 设置手刹输入（对应 JPH_WheeledVehicleController_SetHandBrakeInput）
 */
public func JPH_WheeledVehicleController_SetHandBrakeInput_cj(controller: CPointer<Unit>, value: Float32): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetHandBrakeInput(controller, value)
    }
}

/**
 * @brief 设置驾驶输入（对应 JPH_WheeledVehicleController_SetDriverInput）
 */
public func JPH_WheeledVehicleController_SetDriverInput_cj(
    controller: CPointer<Unit>, forward: Float32, right: Float32, brake: Float32, handBrake: Float32
): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetDriverInput(controller, forward, right, brake, handBrake)
    }
}

/**
 * @brief 获取离合器处轮速（对应 JPH_WheeledVehicleController_GetWheelSpeedAtClutch）
 */
public func JPH_WheeledVehicleController_GetWheelSpeedAtClutch_cj(controller: CPointer<Unit>): Float32 {
    unsafe {
        JPH_WheeledVehicleController_GetWheelSpeedAtClutch(controller)
    }
}

/**
 * @brief 设置轮胎最大冲量回调（对应 JPH_WheeledVehicleController_SetTireMaxImpulseCallback）
 */
public func JPH_WheeledVehicleController_SetTireMaxImpulseCallback_cj(
    controller: CPointer<Unit>, callback: CPointer<Unit>, userData: CPointer<Unit>
): Unit {
    unsafe {
        JPH_WheeledVehicleController_SetTireMaxImpulseCallback(controller, callback, userData)
    }
}
