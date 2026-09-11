# Class
## class SamplingJob
```cj
public class SamplingJob
```
Animation sampling job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the sampling

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

Return: 

- true if the job can run

### var animation
```cj
public var animation:?SkeletalAnimationData
```
The animation data to sample

### var context
```cj
public var context: SamplingContext
```
Sampling context (inter-frame cache)

### var output
```cj
public var output: Array < SoaTransform >
```
Output buffer

### var ratio
```cj
public var ratio: Float32
```
Time ratio [0, 1]

