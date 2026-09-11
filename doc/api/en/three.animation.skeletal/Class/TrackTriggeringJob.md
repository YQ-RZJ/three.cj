# Class
## class TrackTriggeringJob
```cj
public class TrackTriggeringJob
```
Track event triggering job

### func init\(\)
```cj
public init()
```


### func run\(\)
```cj
public func run(): Bool
```
Runs the trigger detection

Return: 

- true on success

### func validate\(\)
```cj
public func validate(): Bool
```
Validates the inputs

### var currentRatio
```cj
public var currentRatio: Float32
```
Time ratio of the current frame [0, 1]

### var events
```cj
public var events: ArrayList < TriggerEvent >
```
Output: the list of trigger events

### var fallingOnly
```cj
public var fallingOnly: Bool
```
Whether to detect only falling crossings (top-down)

### var previousRatio
```cj
public var previousRatio: Float32
```
Time ratio of the previous frame [0, 1]

### var risingOnly
```cj
public var risingOnly: Bool
```
Whether to detect only rising crossings (bottom-up)

### var threshold
```cj
public var threshold: Float32
```
Threshold

### var track
```cj
public var track:?SkeletalTrackData
```
The float track to check

