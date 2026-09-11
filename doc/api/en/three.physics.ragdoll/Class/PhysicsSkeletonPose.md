# Class
## class PhysicsSkeletonPose
```cj
public class PhysicsSkeletonPose
```
Skeleton pose: per-joint local translation/rotation (or joint matrices)

### func calculateJointMatrices\(\)
```cj
public func calculateJointMatrices(): Unit
```
Calculates all joint matrices from the joint states (translation/rotation)

### func calculateJointStates\(\)
```cj
public func calculateJointStates(): Unit
```
Calculates all joint states (translation/rotation) from the joint matrices

### func dispose\(\)
```cj
public func dispose(): Unit
```
Releases the underlying pose handle

### func getJointMatrix\(Int64\)
```cj
public func getJointMatrix(index: Int64): Matrix4
```
Reads the local matrix of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint index|

Return: 

- The local transform matrix (three left-handed)

### func getJointState\(Int64\)
```cj
public func getJointState(index: Int64):(Vector3, Quaternion)
```
Reads the local state of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint index|

Return: 

- A (local translation, local rotation) tuple

### func init\(PhysicsSkeleton\)
```cj
public init(skeleton: PhysicsSkeleton)
```
Creates a pose associated with the given skeleton

Parameter: 

|Name|Type|Describe|
|---|---|---|
|skeleton|PhysicsSkeleton|The target skeleton|

### func setJointMatrix\(Int64,Matrix4\)
```cj
public func setJointMatrix(index: Int64, matrix: Matrix4): Unit
```
Sets the local matrix of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint indexmatrix The local transform matrix (three left-handed, column-major)|
|matrix|Matrix4||

### func setJointState\(Int64,Vector3,Quaternion\)
```cj
public func setJointState(index: Int64, translation: Vector3, rotation: Quaternion): Unit
```
Sets the local state of a joint

Parameter: 

|Name|Type|Describe|
|---|---|---|
|index|Int64|The joint indextranslation Local translation relative to the parent joint (three left-handed)rotation Local rotation relative to the parent joint|
|translation|Vector3||
|rotation|Quaternion||

### prop jointCount: Int64
```cj
public prop jointCount: Int64
```
The number of joints in the pose

### prop rootOffset: Vector3
```cj
public mut prop rootOffset: Vector3
```
The root offset (world translation of the whole pose)

