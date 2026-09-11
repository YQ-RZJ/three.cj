# Class
## class BlendingJob
```cj
public class BlendingJob
```
Multi-animation blending job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the blending

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var additiveLayers
```cj
public var additiveLayers: ArrayList < BlendLayer >
```
List of additive blending layers

### var layers
```cj
public var layers: ArrayList < BlendLayer >
```
List of normal blending layers

### var output
```cj
public var output: Array < SoaTransform >
```
Output buffer

### var restPose
```cj
public var restPose: Array < SoaTransform >
```
Skeleton rest pose

### var threshold
```cj
public var threshold: Float32
```
Weight threshold: joints whose accumulated weight is below this value use the rest pose

