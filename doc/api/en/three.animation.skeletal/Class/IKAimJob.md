# Class
## class IKAimJob
```cj
public class IKAimJob
```
Single-joint aim IK job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the aim IK

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var forward
```cj
public var forward: Vector3F
```
Joint forward axis (local space, must be normalized)

### var jointCorrection
```cj
public var jointCorrection:?QuaternionF
```
Output: joint correction quaternion (local space)

### var jointMatrix
```cj
public var jointMatrix: Array < Float32 >
```
Joint model-space matrix (input)

### var offset
```cj
public var offset: Vector3F
```
Joint offset (local space)

### var poleVector
```cj
public var poleVector:?Vector3F
```
Pole vector (model space)

### var reached
```cj
public var reached:?Bool
```
Output: whether the target is reachable (optional)

### var target
```cj
public var target: Vector3F
```
Target position (model space)

### var twistAngle
```cj
public var twistAngle: Float32
```
Twist angle (extra rotation around the target vector, radians)

### var up
```cj
public var up: Vector3F
```
Joint up axis (local space)

### var weight
```cj
public var weight: Float32
```
IK weight [0, 1]

