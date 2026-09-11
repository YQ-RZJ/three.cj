# Class
## class SamplingContext
```cj
public class SamplingContext
```
Sampling context (inter-frame cache)

### func init\(\)
```cj
public init()
```


### func invalidate\(\)
```cj
public func invalidate(): Unit
```
Invalidates the cache (call when switching animations)

### func resize\(Int\)
```cj
public func resize(numTracks: Int): Unit
```
Resizes the cache to match the number of tracks

Parameter: 

|Name|Type|Describe|
|---|---|---|
|numTracks|Int||

### var lastAnimation
```cj
public var lastAnimation:?SkeletalAnimationData
```
The animation of the previous frame

### var lastRatio
```cj
public var lastRatio: Float32
```
The time ratio of the previous frame

### var lastRotKeyframe
```cj
public var lastRotKeyframe: Array < Int >
```
Previous-frame keyframe index of each track's rotation

### var lastScaleKeyframe
```cj
public var lastScaleKeyframe: Array < Int >
```
Previous-frame keyframe index of each track's scale

### var lastTransKeyframe
```cj
public var lastTransKeyframe: Array < Int >
```
Previous-frame keyframe index of each track's translation

### var maxTracks
```cj
public var maxTracks: Int
```
Maximum supported number of tracks

