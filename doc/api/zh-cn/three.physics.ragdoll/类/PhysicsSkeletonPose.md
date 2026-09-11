# 类
## class PhysicsSkeletonPose
```cj
public class PhysicsSkeletonPose
```
骨骼姿态：每个关节的局部位移/旋转（或关节矩阵）

### func calculateJointMatrices\(\)
```cj
public func calculateJointMatrices(): Unit
```
由关节状态（位移/旋转）计算全部关节矩阵

### func calculateJointStates\(\)
```cj
public func calculateJointStates(): Unit
```
由关节矩阵反算全部关节状态（位移/旋转）

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放底层姿态句柄

### func getJointMatrix\(Int64\)
```cj
public func getJointMatrix(index: Int64): Matrix4
```
读取指定关节的局部矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引|

返回: 

- 局部变换矩阵（three 左手系）

### func getJointState\(Int64\)
```cj
public func getJointState(index: Int64):(Vector3, Quaternion)
```
读取指定关节的局部状态

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引|

返回: 

- (局部位移, 局部旋转) 元组

### func init\(PhysicsSkeleton\)
```cj
public init(skeleton: PhysicsSkeleton)
```
创建关联指定骨骼的姿态

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|PhysicsSkeleton|目标骨骼|

### func setJointMatrix\(Int64,Matrix4\)
```cj
public func setJointMatrix(index: Int64, matrix: Matrix4): Unit
```
设置指定关节的局部矩阵

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引matrix 局部变换矩阵（three 左手系列主序）|
|matrix|Matrix4||

### func setJointState\(Int64,Vector3,Quaternion\)
```cj
public func setJointState(index: Int64, translation: Vector3, rotation: Quaternion): Unit
```
设置指定关节的局部状态

参数: 

|名称|类型|描述|
|---|---|---|
|index|Int64|关节索引translation 相对父关节的局部位移（three 左手系）rotation 相对父关节的局部旋转|
|translation|Vector3||
|rotation|Quaternion||

### prop jointCount: Int64
```cj
public prop jointCount: Int64
```
姿态中的关节数量

### prop rootOffset: Vector3
```cj
public mut prop rootOffset: Vector3
```
根偏移（整个姿态相对世界的平移）

