# 类
## class IKAimJob
```cj
public class IKAimJob
```
单关节瞄准 IK Job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
执行瞄准 IK

返回: 

- true 表示成功

### func validate\(\)
```cj
public func validate(): Bool
```
验证输入合法性

### var forward
```cj
public var forward: Vector3F
```
关节前向轴（局部空间，必须归一化）

### var jointCorrection
```cj
public var jointCorrection:?QuaternionF
```
输出：关节校正四元数（局部空间）

### var jointMatrix
```cj
public var jointMatrix: Array < Float32 >
```
关节模型空间矩阵（输入）

### var offset
```cj
public var offset: Vector3F
```
关节偏移（局部空间）

### var poleVector
```cj
public var poleVector:?Vector3F
```
Pole vector（模型空间）

### var reached
```cj
public var reached:?Bool
```
输出：目标是否可达（可选）

### var target
```cj
public var target: Vector3F
```
目标位置（模型空间）

### var twistAngle
```cj
public var twistAngle: Float32
```
扭转角度（绕目标向量的额外旋转，弧度）

### var up
```cj
public var up: Vector3F
```
关节上向轴（局部空间）

### var weight
```cj
public var weight: Float32
```
IK 权重 [0, 1]

