# Interface
## interface IAnimationClip
```cj
public interface IAnimationClip
```
Animation clip interface: the contract type through which the blend package references AnimationClip

### prop blendMode: Int64
```cj
mut prop blendMode: Int64
```
Blend mode (NormalAnimationBlendMode / AdditiveAnimationBlendMode)

### prop duration: Float64
```cj
mut prop duration: Float64
```
Clip duration (seconds)

### prop name: String
```cj
mut prop name: String
```
Clip name

### prop tracks: Array < IKeyframeTrack >
```cj
mut prop tracks: Array < IKeyframeTrack >
```
Keyframe track array (referenced via the IKeyframeTrack interface to avoid depending on the concrete KeyframeTrack class in the blend package)

### prop userData: HashMap < String, Any >
```cj
mut prop userData: HashMap < String, Any >
```
User-defined data

### prop uuid: String
```cj
mut prop uuid: String
```
Unique identifier

