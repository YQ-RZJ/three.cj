# Package three.physics.interfaces 

## API List

### Class
|  Name   | Describe  |
|  ----  | ----  |
|[PhysicsBodyDesc](./Class/PhysicsBodyDesc.md#class-physicsbodydesc)|Rigid-body creation description (backend-agnostic)|
|[PhysicsConstraintDesc](./Class/PhysicsConstraintDesc.md#class-physicsconstraintdesc)|Constraint creation description (backend-agnostic)|
|[PhysicsPointHit](./Class/PhysicsPointHit.md#class-physicspointhit)|Point-collision query result (collidePoint, backend-agnostic)|
|[PhysicsRayHit](./Class/PhysicsRayHit.md#class-physicsrayhit)|Ray-cast query result (backend-agnostic)|
|[PhysicsShapeHit](./Class/PhysicsShapeHit.md#class-physicsshapehit)|Shape-collision/cast query result (collideShape/castShape, backend-agnostic)|

### Interface
|  Name   | Describe  |
|  ----  | ----  |
|[IPhysicsBackend](./Interface/IPhysicsBackend.md#interface-iphysicsbackend)|Pluggable physics backend interface|
|[IPhysicsSensorListener](./Interface/IPhysicsSensorListener.md#interface-iphysicssensorlistener)|Sensor callbacks (backend-agnostic)|

### Struct
|  Name   | Describe  |
|  ----  | ----  |
|[PhysicsBodyHandle](./Struct/PhysicsBodyHandle.md#struct-physicsbodyhandle)|Physics body handle (backend-agnostic)|
|[PhysicsCompoundPart](./Struct/PhysicsCompoundPart.md#struct-physicscompoundpart)|Sub-part of a compound shape (used by Compound)|
|[PhysicsConstraintHandle](./Struct/PhysicsConstraintHandle.md#struct-physicsconstrainthandle)|Constraint handle (backend-agnostic)|
|[PhysicsShape](./Struct/PhysicsShape.md#struct-physicsshape)|Physics shape description (backend-agnostic)|

### Enum
|  Name   | Describe  |
|  ----  | ----  |
|[PhysicsActivation](./Enum/PhysicsActivation.md#enum-physicsactivation)|Activation strategy (whether the body is woken immediately when added to the world)|
|[PhysicsConstraintSpace](./Enum/PhysicsConstraintSpace.md#enum-physicsconstraintspace)|Constraint space (corresponds to JPH_ConstraintSpace)|
|[PhysicsConstraintType](./Enum/PhysicsConstraintType.md#enum-physicsconstrainttype)|Constraint-type enum (backend-agnostic, corresponds to JPH_ConstraintSubType)|
|[PhysicsContactEvent](./Enum/PhysicsContactEvent.md#enum-physicscontactevent)|Collision callback event type (ContactListener)|
|[PhysicsLayer](./Enum/PhysicsLayer.md#enum-physicslayer)|Physics layer (collision grouping)|
|[PhysicsMotionType](./Enum/PhysicsMotionType.md#enum-physicsmotiontype)|Rigid-body motion type (backend-agnostic abstraction, corresponds to JPH_MotionType)|
|[PhysicsShapeType](./Enum/PhysicsShapeType.md#enum-physicsshapetype)|Shape-type enum (no parameters; parameters are held by the PhysicsShape struct)|

