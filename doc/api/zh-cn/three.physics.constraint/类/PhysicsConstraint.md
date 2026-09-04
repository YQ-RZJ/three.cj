# 类
## class PhysicsConstraint
```cj
public class PhysicsConstraint
```
约束运行时句柄封装

### func cone\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64\)
```cj
public static func cone(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, halfAngle: Float64): PhysicsConstraint
```
创建锥约束：锥角限制的球关节（如肩关节）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 锚点（世界坐标）axis 锥轴方向（世界坐标）halfAngle 锥半角（弧度）|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|halfAngle|Float64||

返回: 

- 新建的约束封装

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁约束并从世界移除

### func distance\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func distance(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor1: Vector3, anchor2: Vector3, minDist: Float64, maxDist: Float64): PhysicsConstraint
```
创建距离约束：保持两锚点间距离（可带弹簧范围）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor1 第一个锚点（世界坐标）anchor2 第二个锚点（世界坐标）minDist 最小距离maxDist 最大距离|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor1|Vector3||
|anchor2|Vector3||
|minDist|Float64||
|maxDist|Float64||

返回: 

- 新建的约束封装

### func fixed\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle\)
```cj
public static func fixed(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraint
```
创建固定约束：将两刚体焊接在一起，无相对运动

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||

返回: 

- 新建的约束封装

### func gear\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64\)
```cj
public static func gear(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, hingeAxis: Vector3, ratio: Float64): PhysicsConstraint
```
创建齿轮约束：以固定比例耦合两铰链的旋转（传动）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 锚点（世界坐标）hingeAxis 铰链轴方向ratio 传动比|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|hingeAxis|Vector3||
|ratio|Float64||

返回: 

- 新建的约束封装

### func hinge\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func hinge(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, limitMin!: Float64 = - 3.14159265358979, limitMax!: Float64 = 3.14159265358979): PhysicsConstraint
```
创建铰链约束：绕单轴旋转，可设角度限位（弧度）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 铰链锚点（世界坐标）axis 旋转轴（世界方向）limitMin 最小旋转角（弧度，默认 -π 无限制）limitMax 最大旋转角（弧度，默认 +π 无限制）|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|limitMin|Float64||
|limitMax|Float64||

返回: 

- 新建的约束封装

### func init\(PhysicsWorld,PhysicsConstraintHandle\)
```cj
public init(world!: PhysicsWorld, handle!: PhysicsConstraintHandle)
```
创建约束封装（通常由静态构造方法创建，无需直接调用）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界handle 底层约束句柄|
|handle|PhysicsConstraintHandle||

### func isEnabled\(\)
```cj
public func isEnabled(): Bool
```
约束是否启用

返回: 

- 启用返回 true

### func isValid\(\)
```cj
public func isValid(): Bool
```
约束是否有效（已创建且未销毁）

返回: 

- 有效返回 true

### func point\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3\)
```cj
public static func point(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3): PhysicsConstraint
```
创建点约束（球关节）：两刚体共享一个锚点，可自由旋转

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 共享锚点（世界坐标）|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||

返回: 

- 新建的约束封装

### func setEnabled\(Bool\)
```cj
public func setEnabled(enabled: Bool): PhysicsConstraint
```
设置约束是否启用

参数: 

|名称|类型|描述|
|---|---|---|
|enabled|Bool|true 启用，false 临时断开约束|

返回: 

- 返回 this，便于链式调用

### func sixDOF\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3\)
```cj
public static func sixDOF(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axisX!: Vector3 = Vector3(1.0, 0.0, 0.0)): PhysicsConstraint
```
创建六自由度约束：共享锚点，每自由度可 Free/Limited/Locked（默认全 Free = 球关节）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 共享锚点（世界坐标）axisX 第一个局部轴方向（默认 X 轴）|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axisX|Vector3||

返回: 

- 新建的约束封装

### func slider\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Float64,Float64\)
```cj
public static func slider(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, axis: Vector3, limitMin: Float64, limitMax: Float64): PhysicsConstraint
```
创建滑块约束：沿单轴平移（可限位），如抽屉、活塞

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 滑块锚点（世界坐标）axis 滑动轴（世界方向）limitMin 最小平移距离limitMax 最大平移距离|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|axis|Vector3||
|limitMin|Float64||
|limitMax|Float64||

返回: 

- 新建的约束封装

### func swingTwist\(PhysicsWorld,PhysicsBodyHandle,PhysicsBodyHandle,Vector3,Vector3,Vector3,Float64,Float64\)
```cj
public static func swingTwist(world: PhysicsWorld, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle, anchor: Vector3, twistAxis: Vector3, planeAxis: Vector3, twistMin: Float64, twistMax: Float64): PhysicsConstraint
```
创建摆动-扭转约束（肩/髋关节，扭转角限位）

参数: 

|名称|类型|描述|
|---|---|---|
|world|PhysicsWorld|所属物理世界bodyA 第一个刚体句柄bodyB 第二个刚体句柄anchor 锚点（世界坐标）twistAxis 扭转轴方向planeAxis 摆动平面轴方向twistMin 最小扭转角（弧度）twistMax 最大扭转角（弧度）|
|bodyA|PhysicsBodyHandle||
|bodyB|PhysicsBodyHandle||
|anchor|Vector3||
|twistAxis|Vector3||
|planeAxis|Vector3||
|twistMin|Float64||
|twistMax|Float64||

返回: 

- 新建的约束封装

### prop handle: PhysicsConstraintHandle
```cj
public prop handle: PhysicsConstraintHandle
```
获取约束句柄（销毁后为 INVALID）

