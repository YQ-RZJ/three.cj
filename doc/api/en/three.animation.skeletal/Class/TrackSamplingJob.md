# Class
## class TrackSamplingJob
```cj
public class TrackSamplingJob
```
Track sampling job

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

### var output
```cj
public var output: TrackSampleOutput
```
Output

### var ratio
```cj
public var ratio: Float32
```
Time ratio [0, 1]

### var track
```cj
public var track:?SkeletalTrackData
```
The track to sample

