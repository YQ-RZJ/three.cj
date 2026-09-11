# Class
## class IKTwoBoneJob
```cj
public class IKTwoBoneJob
```
Two-joint IK job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the two-joint IK solve

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var endEffectorPosition
```cj
public var endEffectorPosition: Vector3F
```
Model-space position of the end effector (e.g. wrist/ankle)

### var midJointCorrection
```cj
public var midJointCorrection:?QuaternionF
```
Correction quaternion of the second joint (output, local space)

### var midJointMatrix
```cj
public var midJointMatrix: Array < Float32 >
```
Model-space matrix of the second joint (mid, e.g. elbow/knee)

### var midJointPoleVector
```cj
public var midJointPoleVector:?Vector3F
```
Mid-joint pole vector (model space)

### var startJointCorrection
```cj
public var startJointCorrection:?QuaternionF
```
Correction quaternion of the first joint (output, local space)

### var startJointMatrix
```cj
public var startJointMatrix: Array < Float32 >
```
Model-space matrix of the first joint (proximal, e.g. shoulder/hip)

### var target
```cj
public var target: Vector3F
```
Target position (model space)

### var weight
```cj
public var weight: Float32
```
IK weight [0, 1]

