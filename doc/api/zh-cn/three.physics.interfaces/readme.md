# 包 three.physics.interfaces 

## API列表

### 类
|  名称   | 描述  |
|  ----  | ----  |
|[PhysicsBodyDesc](./类/PhysicsBodyDesc.md#class-physicsbodydesc)|刚体创建描述（后端无关）|
|[PhysicsConstraintDesc](./类/PhysicsConstraintDesc.md#class-physicsconstraintdesc)|约束创建描述（后端无关）|
|[PhysicsPointHit](./类/PhysicsPointHit.md#class-physicspointhit)|点碰撞查询结果（collidePoint，后端无关）|
|[PhysicsRayHit](./类/PhysicsRayHit.md#class-physicsrayhit)|射线查询结果（后端无关）|
|[PhysicsShapeHit](./类/PhysicsShapeHit.md#class-physicsshapehit)|形状碰撞/投射查询结果（collideShape/castShape，后端无关）|

### 接口
|  名称   | 描述  |
|  ----  | ----  |
|[IPhysicsBackend](./接口/IPhysicsBackend.md#interface-iphysicsbackend)|可插拔物理后端接口|
|[IPhysicsSensorListener](./接口/IPhysicsSensorListener.md#interface-iphysicssensorlistener)|传感器回调（后端无关）|

### 结构体
|  名称   | 描述  |
|  ----  | ----  |
|[PhysicsBodyHandle](./结构体/PhysicsBodyHandle.md#struct-physicsbodyhandle)|物理刚体句柄（后端无关）|
|[PhysicsCompoundPart](./结构体/PhysicsCompoundPart.md#struct-physicscompoundpart)|复合形状子部件（Compound 用）|
|[PhysicsConstraintHandle](./结构体/PhysicsConstraintHandle.md#struct-physicsconstrainthandle)|约束句柄（后端无关）|
|[PhysicsShape](./结构体/PhysicsShape.md#struct-physicsshape)|物理形状描述（后端无关）|

### 枚举
|  名称   | 描述  |
|  ----  | ----  |
|[PhysicsActivation](./枚举/PhysicsActivation.md#enum-physicsactivation)|激活策略（添加刚体到世界时是否立即唤醒）|
|[PhysicsConstraintSpace](./枚举/PhysicsConstraintSpace.md#enum-physicsconstraintspace)|约束空间（对应 JPH_ConstraintSpace）|
|[PhysicsConstraintType](./枚举/PhysicsConstraintType.md#enum-physicsconstrainttype)|约束类型枚举（后端无关，对应 JPH_ConstraintSubType）|
|[PhysicsContactEvent](./枚举/PhysicsContactEvent.md#enum-physicscontactevent)|碰撞回调事件类型（ContactListener）|
|[PhysicsLayer](./枚举/PhysicsLayer.md#enum-physicslayer)|物理层（碰撞分组）|
|[PhysicsMotionType](./枚举/PhysicsMotionType.md#enum-physicsmotiontype)|刚体运动类型（后端无关抽象，对应 JPH_MotionType）|
|[PhysicsMotorState](./枚举/PhysicsMotorState.md#enum-physicsmotorstate)|约束电机状态（对应 JPH_MotorState）|
|[PhysicsShapeType](./枚举/PhysicsShapeType.md#enum-physicsshapetype)|形状类型枚举（不带参数，参数由 PhysicsShape 结构体持有）|

