# Class
## class AnimationAction
```cj
public class AnimationAction
```
Animation action controlling playback of a single animation clip

### func crossFadeFrom\(AnimationAction,Float64,Bool\)
```cj
public func crossFadeFrom(fadeOutAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction
```
Fades this action in while fading the given action out

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fadeOutAction|AnimationAction|The action to fade outduration The cross-fade durationwarp Whether to use warping, defaults to false|
|duration|Float64||
|warp|Bool||

Return: 

- Returns itself for chaining

### func crossFadeTo\(AnimationAction,Float64,Bool\)
```cj
public func crossFadeTo(fadeInAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction
```
Fades this action out while fading the given action in

Parameter: 

|Name|Type|Describe|
|---|---|---|
|fadeInAction|AnimationAction|The action to fade induration The cross-fade durationwarp Whether to use warping, defaults to false|
|duration|Float64||
|warp|Bool||

Return: 

- Returns itself for chaining

### func fadeIn\(Float64\)
```cj
public func fadeIn(duration: Float64): AnimationAction
```
Fades the animation in from weight 0 to 1 over the given duration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|duration|Float64|The fade-in duration|

Return: 

- Returns itself for chaining

### func fadeOut\(Float64\)
```cj
public func fadeOut(duration: Float64): AnimationAction
```
Fades the animation out from weight 1 to 0 over the given duration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|duration|Float64|The fade-out duration|

Return: 

- Returns itself for chaining

### func getClip\(\)
```cj
public func getClip(): IAnimationClip
```
Returns the animation clip of this action

Return: 

- The animation clip

### func getEffectiveTimeScale\(\)
```cj
public func getEffectiveTimeScale(): Float64
```
Returns the effective time scale

Return: 

- The effective time scale

### func getEffectiveWeight\(\)
```cj
public func getEffectiveWeight(): Float64
```
Returns the effective weight

Return: 

- The effective weight

### func getMixer\(\)
```cj
public func getMixer(): AnimationMixer
```
Returns the animation mixer of this action

Return: 

- The animation mixer

### func getRoot\(\)
```cj
public func getRoot(): Object3D
```
Returns the root object of this action

Return: 

- The root object

### func halt\(Float64\)
```cj
public func halt(duration: Float64): AnimationAction
```
Decelerates the animation to a halt over the given duration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|duration|Float64|The duration|

Return: 

- Returns itself for chaining

### func init\(AnimationMixer,IAnimationClip,Object3D,Int64\)
```cj
public init(mixer: AnimationMixer, clip: IAnimationClip, localRoot: Object3D, blendMode!: Int64 = - 1)
```
Constructs a new animation action

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mixer|AnimationMixer|The mixer controlling this actionclip The animation clip holding the actual keyframeslocalRoot The root object this action runs on, defaults to noneblendMode Blend mode, defaults to the clip's blend mode|
|clip|IAnimationClip||
|localRoot|Object3D||
|blendMode|Int64||

### func isRunning\(\)
```cj
public func isRunning(): Bool
```
Returns whether the animation is running

Return: 

- Whether the animation is running

### func isScheduled\(\)
```cj
public func isScheduled(): Bool
```
Returns whether the action has been scheduled (play has been called)

Return: 

- Whether the action has been scheduled

### func play\(\)
```cj
public func play(): AnimationAction
```
Starts playing the animation

Return: 

- Returns itself for chaining

### func reset\(\)
```cj
public func reset(): AnimationAction
```
Resets the animation playback state

Return: 

- Returns itself for chaining

### func setDuration\(Float64\)
```cj
public func setDuration(duration: Float64): AnimationAction
```
Sets the duration of a single loop of this action

Parameter: 

|Name|Type|Describe|
|---|---|---|
|duration|Float64|The duration|

Return: 

- Returns itself for chaining

### func setEffectiveTimeScale\(Float64\)
```cj
public func setEffectiveTimeScale(timeScale: Float64): AnimationAction
```
Sets the effective time scale

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The effective time scale is 0 while the action is paused</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|timeScale|Float64|The time scale|

Return: 

- Returns itself for chaining

### func setEffectiveWeight\(Float64\)
```cj
public func setEffectiveWeight(weight: Float64): AnimationAction
```
Sets the effective weight

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The effective weight is 0 while the action is disabled</p>

Parameter: 

|Name|Type|Describe|
|---|---|---|
|weight|Float64|The weight|

Return: 

- Returns itself for chaining

### func setLoop\(Int64,Float64\)
```cj
public func setLoop(mode: Int64, repetitions: Float64): AnimationAction
```
Configures the loop settings

Parameter: 

|Name|Type|Describe|
|---|---|---|
|mode|Int64|The loop moderepetitions The number of repetitions|
|repetitions|Float64||

Return: 

- Returns itself for chaining

### func startAt\(Float64\)
```cj
public func startAt(time: Float64): AnimationAction
```
Sets the start time of the animation

Parameter: 

|Name|Type|Describe|
|---|---|---|
|time|Float64|The start time in seconds|

Return: 

- Returns itself for chaining

### func stopFading\(\)
```cj
public func stopFading(): AnimationAction
```
Stops any fading effect on this action

Return: 

- Returns itself for chaining

### func stopWarping\(\)
```cj
public func stopWarping(): AnimationAction
```
Stops any warping effect on this action

Return: 

- Returns itself for chaining

### func stop\(\)
```cj
public func stop(): AnimationAction
```
Stops playing the animation

Return: 

- Returns itself for chaining

### func syncWith\(AnimationAction\)
```cj
public func syncWith(action: AnimationAction): AnimationAction
```
Synchronizes this action with the given action

Parameter: 

|Name|Type|Describe|
|---|---|---|
|action|AnimationAction|The action to synchronize with|

Return: 

- Returns itself for chaining

### func warp\(Float64,Float64,Float64\)
```cj
public func warp(startTimeScale: Float64, endTimeScale: Float64, duration: Float64): AnimationAction
```
Warps the playback speed from startTimeScale to endTimeScale over the given duration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|startTimeScale|Float64|The starting time scaleendTimeScale The ending time scaleduration The duration|
|endTimeScale|Float64||
|duration|Float64||

Return: 

- Returns itself for chaining

### var blendMode
```cj
public var blendMode: Int64
```
Blend mode

### var clampWhenFinished
```cj
public var clampWhenFinished: Bool
```
Whether to pause automatically on the last frame

### var enabled
```cj
public var enabled: Bool
```
Whether the action is enabled

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>A disabled action has no effect; re-enabling resumes from the current time; defaults to true</p>

### var loop
```cj
public var loop: Int64
```
Loop mode (LoopRepeat | LoopOnce | LoopPingPong), set via setLoop

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>Defaults to LoopRepeat</p>

### var paused
```cj
public var paused: Bool
```
Whether the action is paused

### var repetitions
```cj
public var repetitions: Float64
```
Number of times the clip is repeated for this action, set via setLoop

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>No effect on LoopOnce mode; defaults to Infinity</p>

### var timeScale
```cj
public var timeScale: Float64
```
Scale factor for AnimationAction#time

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>A value of 0 pauses the animation and a negative value plays it backwards; defaults to 1</p>

### var time
```cj
public var time: Float64
```
Local time of this action in seconds, starting at 0

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>The value is clamped or wrapped to [0, clip.duration] depending on the loop state; defaults to 0</p>

### var weight
```cj
public var weight: Float64
```
How much this action affects the object (range [0, 1])

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>0 means no influence and 1 means full influence; values in between can blend multiple actions; defaults to 1</p>

### var zeroSlopeAtEnd
```cj
public var zeroSlopeAtEnd: Bool
```
Whether to enable smooth interpolation at the end

### var zeroSlopeAtStart
```cj
public var zeroSlopeAtStart: Bool
```
Whether to enable smooth interpolation at the start

