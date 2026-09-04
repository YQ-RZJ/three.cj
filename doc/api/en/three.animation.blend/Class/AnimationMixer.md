# Class
## class AnimationMixer
```cj
public class AnimationMixer <: EventDispatcher
```
Animation mixer that manages the blended playback of a set of animation actions

### func clipAction\(IAnimationClip,Option<Object3D>,Int64\)
```cj
public func clipAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None, blendMode!: Int64 = - 1): AnimationAction
```
Returns an AnimationAction for the given clip

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>If an action matching the clip and root parameters does not yet exist,
it is created; calling repeatedly with the same clip and root always returns
the same action</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clip|IAnimationClip|The animation clipoptionalRoot An optional alternate root object, defaults to the mixer's rootblendMode Blend mode, defaults to the clip's blend mode|
|optionalRoot|Option<Object3D>||
|blendMode|Int64||

Return: 

- The animation action

### func existingAction\(IAnimationClip,Option<Object3D>\)
```cj
public func existingAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None): Option < AnimationAction >
```
Returns an existing animation action for the given clip

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clip|IAnimationClip|The animation clipoptionalRoot An optional alternate root object, defaults to the mixer's root|
|optionalRoot|Option<Object3D>||

Return: 

- The animation action, or None if not found

### func getRoot\(\)
```cj
public func getRoot(): Object3D
```
Returns the root object of this mixer

Return: 

- The root object

### func init\(Object3D\)
```cj
public init(root: Object3D)
```
Constructs a new animation mixer

Parameter: 

|Name|Type|Describe|
|---|---|---|
|root|Object3D|The root object on which this mixer plays animations|

### func setTime\(Float64\)
```cj
public func setTime(time: Float64): AnimationMixer
```
Sets the global mixer to a specific time and updates the animations accordingly

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Useful when jumping to an exact time in the animation; the input is scaled by AnimationMixer#timeScale</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|time|Float64|The time to set in seconds|

Return: 

- Returns itself for chaining

### func stopAllAction\(\)
```cj
public func stopAllAction(): AnimationMixer
```
Deactivates all previously scheduled actions on this mixer

Return: 

- Returns itself for chaining

### func uncacheAction\(IAnimationClip,Option<Object3D>\)
```cj
public func uncacheAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None): Unit
```
Releases all memory resources of an action

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Make sure to call AnimationAction#stop to deactivate the action before using this method</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clip|IAnimationClip|The animation clipoptionalRoot An optional alternate root object, defaults to the mixer's root|
|optionalRoot|Option<Object3D>||

### func uncacheClip\(IAnimationClip\)
```cj
public func uncacheClip(clip: IAnimationClip): Unit
```
Releases all memory resources of a clip

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Make sure to call AnimationAction#stop on all related actions before using this method</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|clip|IAnimationClip|The clip to uncache|

### func uncacheRoot\(Object3D\)
```cj
public func uncacheRoot(root: Object3D): Unit
```
Releases all memory resources of a root object

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Make sure to call AnimationAction#stop on all related actions before using this method</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|root|Object3D|The root object to uncache|

### func update\(Float64\)
```cj
public func update(deltaTime: Float64): AnimationMixer
```
Advances the global mixer time and updates the animations

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Usually called in the render loop with the delta time of a Clock or Timer</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|deltaTime|Float64|The delta time in seconds|

Return: 

- Returns itself for chaining

### var stats
```cj
public var stats: HashMap < String, HashMap < String,() -> Int64 >>
```
Statistics

### var timeScale
```cj
public var timeScale: Float64
```
Global time scale factor

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Setting it to 0 and back to 1 pauses/resumes all actions; defaults to 1</p>

### var time
```cj
public var time: Float64
```
Global mixer time in seconds, 0 at creation

