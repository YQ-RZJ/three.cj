# 类
## class PhysicsVehicle
```cj
public class PhysicsVehicle
```
轮式载具运行时对象

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁载具（移除并释放车辆约束；底盘刚体由调用方管理）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>底盘刚体不在此销毁——载具常复用底盘，请按需调用
world.destroyBody(chassis)</p>

### func getWheelWorldTransform\(Int64\)
```cj
public func getWheelWorldTransform(index: Int64): Matrix4
```
读取指定车轮的世界变换（用于渲染车轮网格）

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|车轮索引|

返回: 

- 车轮世界矩阵（three 左手系）；无效索引返回单位矩阵

### func setDriverInput\(Float64,Float64,Float64,Float64\)
```cj
public func setDriverInput(forward: Float64, steer: Float64, brake!: Float64 = 0.0, handBrake!: Float64 = 0.0): Unit
```
设置驾驶员输入（油门/转向/刹车/手刹）

参数: 

|名称|类型|描述|
|---|---|---|
|forward|Float64|油门（-1 倒车 ~ 1 前进）steer 转向（-1 左 ~ 1 右）brake 刹车（0 ~ 1）handBrake 手刹（0 ~ 1）|
|steer|Float64||
|brake|Float64||
|handBrake|Float64||

### prop chassis: PhysicsBodyHandle
```cj
public prop chassis: PhysicsBodyHandle
```
底盘刚体句柄（可进一步控制底盘）

### prop isValid: Bool
```cj
public prop isValid: Bool
```
载具是否有效（创建成功且未销毁）

### prop wheelCount: Int64
```cj
public prop wheelCount: Int64
```
车轮数量

