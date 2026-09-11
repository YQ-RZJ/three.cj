# Class
## class RawAnimationUtils
```cj
public class RawAnimationUtils
```
Offline animation utility collection

### func concatenate\(RawAnimation,RawAnimation\)
```cj
public static func concatenate(first: RawAnimation, second: RawAnimation): Option < RawAnimation >
```
Concatenates two animations

Parameter: 

|Name|Type|Describe|
|---|---|---|
|first|RawAnimation|The first animation|
|second|RawAnimation|The second animation|

Return: 

- The merged animation (first followed by second)

### func makeAdditiveDelta\(RawAnimation,RawAnimation\)
```cj
public static func makeAdditiveDelta(base: RawAnimation, target: RawAnimation): Option < RawAnimation >
```
Creates an additive delta animation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|base|RawAnimation|The base animation|
|target|RawAnimation|The target animation|

Return: 

- The additive animation (delta = target relative to base)

### func resample\(RawAnimation,Float32\)
```cj
public static func resample(source: RawAnimation, newFps: Float32): RawAnimation
```
Resamples the animation to a new frame rate

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|RawAnimation|The source animation|
|newFps|Float32|The new frame rate (frames per second)|

Return: 

- The resampled animation (one keyframe per frame per track)

### func retarget\(RawAnimation,Array<String>,Array<String>\)
```cj
public static func retarget(source: RawAnimation, sourceJointNames: Array < String >, targetJointNames: Array < String >): RawAnimation
```
Retargets an animation to a different skeleton structure

Parameter: 

|Name|Type|Describe|
|---|---|---|
|source|RawAnimation|The source animation|
|sourceJointNames|Array<String>|The list of source skeleton joint names|
|targetJointNames|Array<String>|The list of target skeleton joint names|

Return: 

- The retargeted animation (only tracks present in the target skeleton are kept)

