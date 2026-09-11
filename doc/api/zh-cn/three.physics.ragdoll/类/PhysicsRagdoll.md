# 类
## class PhysicsRagdoll
```cj
public class PhysicsRagdoll
```
运行时布娃娃：加入物理世界后进行关节刚体模拟

### func activate\(\)
```cj
public func activate(): Unit
```
激活（唤醒）布娃娃

### func addToWorld\(PhysicsActivation\)
```cj
public func addToWorld(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit
```
将布娃娃加入物理世界

参数: 

|名称|类型|描述|
|---|---|---|
|activation|PhysicsActivation|激活策略（默认立即激活）|

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁布娃娃（会自动从物理世界移除并释放全部刚体/约束）

### func driveToPoseUsingKinematics\(PhysicsSkeletonPose,Float32\)
```cj
public func driveToPoseUsingKinematics(pose: PhysicsSkeletonPose, deltaTime: Float32): Unit
```
用运动学方式把布娃娃插值驱动到目标姿态（直接搬动刚体，适合死亡动画过渡）

参数: 

|名称|类型|描述|
|---|---|---|
|pose|PhysicsSkeletonPose|目标姿态deltaTime 本帧时间步长（秒）|
|deltaTime|Float32||

### func driveToPoseUsingMotors\(PhysicsSkeletonPose\)
```cj
public func driveToPoseUsingMotors(pose: PhysicsSkeletonPose): Unit
```
用关节电机把布娃娃驱动向目标姿态（产生力矩，适合活动角色）

参数: 

|名称|类型|描述|
|---|---|---|
|pose|PhysicsSkeletonPose|目标姿态|

### func getBodyID\(Int64\)
```cj
public func getBodyID(bodyIndex: Int64): UInt32
```
获取指定部件刚体的 BodyID

参数: 

|名称|类型|描述|
|---|---|---|
|bodyIndex|Int64|部件索引|

返回: 

- 刚体 BodyID（可用于碰撞回调/查询）

### func getPose\(PhysicsSkeletonPose\)
```cj
public func getPose(pose: PhysicsSkeletonPose): Unit
```
读取布娃娃当前姿态到给定姿态对象

参数: 

|名称|类型|描述|
|---|---|---|
|pose|PhysicsSkeletonPose|输出姿态（调用后其关节状态被填充）|

### func getRootTransform\(\)
```cj
public func getRootTransform():(Vector3, Quaternion)
```
获取布娃娃根变换（世界空间位置与旋转）

返回: 

- (根位置, 根旋转) 元组（three 左手系）

### func isActive\(\)
```cj
public func isActive(): Bool
```
布娃娃是否处于活动（未休眠）状态

### func removeFromWorld\(\)
```cj
public func removeFromWorld(): Unit
```
将布娃娃从物理世界移除（可再次 addToWorld 加入）

### func setPose\(PhysicsSkeletonPose\)
```cj
public func setPose(pose: PhysicsSkeletonPose): Unit
```
直接设置布娃娃姿态（瞬间到位，不产生速度）

参数: 

|名称|类型|描述|
|---|---|---|
|pose|PhysicsSkeletonPose|目标姿态|

### prop bodyCount: Int64
```cj
public prop bodyCount: Int64
```
刚体（部件）数量

### prop constraintCount: Int64
```cj
public prop constraintCount: Int64
```
关节约束数量

### prop isValid: Bool
```cj
public prop isValid: Bool
```
布娃娃是否有效（创建成功且未销毁）

### prop skeleton: PhysicsSkeleton
```cj
public prop skeleton: PhysicsSkeleton
```
布娃娃关联的骨骼

