# 类
## class IKTwoBoneJob
```cj
public class IKTwoBoneJob
```
双关节 IK Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行双关节 IK 解算

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var endEffectorPosition
```cj
public var endEffectorPosition: Vector3F
```
末端效应器（如手腕/脚踝）的模型空间位置

### var midJointCorrection
```cj
public var midJointCorrection:?QuaternionF
```
第二个关节的校正四元数（输出，局部空间）

### var midJointMatrix
```cj
public var midJointMatrix: Array < Float32 >
```
第二个关节（中间，如肘/膝）的模型空间矩阵

### var midJointPoleVector
```cj
public var midJointPoleVector:?Vector3F
```
Mid-joint pole vector（模型空间）

### var startJointCorrection
```cj
public var startJointCorrection:?QuaternionF
```
第一个关节的校正四元数（输出，局部空间）

### var startJointMatrix
```cj
public var startJointMatrix: Array < Float32 >
```
第一个关节（近端，如肩/髋）的模型空间矩阵

### var target
```cj
public var target: Vector3F
```
目标位置（模型空间）

### var weight
```cj
public var weight: Float32
```
IK 权重 [0, 1]

