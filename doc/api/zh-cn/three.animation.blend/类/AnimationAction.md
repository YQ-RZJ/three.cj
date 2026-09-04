# 类
## class AnimationAction
```cj
public class AnimationAction
```
动画动作，管理单个动画剪辑的播放控制

### func crossFadeFrom\(AnimationAction,Float64,Bool\)
```cj
public func crossFadeFrom(fadeOutAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction
```
使此动作淡入，同时使给定动作淡出

参数: 

|名称|类型|描述|
|---|---|---|
|fadeOutAction|AnimationAction|要淡出的动作duration 淡入淡出持续时间warp 是否使用变速，默认 false|
|duration|Float64||
|warp|Bool||

返回: 

- 返回自身以支持链式调用

### func crossFadeTo\(AnimationAction,Float64,Bool\)
```cj
public func crossFadeTo(fadeInAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction
```
使此动作淡出，同时使给定动作淡入

参数: 

|名称|类型|描述|
|---|---|---|
|fadeInAction|AnimationAction|要淡入的动作duration 淡入淡出持续时间warp 是否使用变速，默认 false|
|duration|Float64||
|warp|Bool||

返回: 

- 返回自身以支持链式调用

### func fadeIn\(Float64\)
```cj
public func fadeIn(duration: Float64): AnimationAction
```
在指定时间内将动画从权重 0 淡入到 1

参数: 

|名称|类型|描述|
|---|---|---|
|duration|Float64|淡入持续时间|

返回: 

- 返回自身以支持链式调用

### func fadeOut\(Float64\)
```cj
public func fadeOut(duration: Float64): AnimationAction
```
在指定时间内将动画从权重 1 淡出到 0

参数: 

|名称|类型|描述|
|---|---|---|
|duration|Float64|淡出持续时间|

返回: 

- 返回自身以支持链式调用

### func getClip\(\)
```cj
public func getClip(): IAnimationClip
```
返回此动作的动画剪辑

返回: 

- 动画剪辑

### func getEffectiveTimeScale\(\)
```cj
public func getEffectiveTimeScale(): Float64
```
返回有效时间缩放

返回: 

- 有效时间缩放

### func getEffectiveWeight\(\)
```cj
public func getEffectiveWeight(): Float64
```
返回有效权重

返回: 

- 有效权重

### func getMixer\(\)
```cj
public func getMixer(): AnimationMixer
```
返回此动作的动画混合器

返回: 

- 动画混合器

### func getRoot\(\)
```cj
public func getRoot(): Object3D
```
返回此动作的根对象

返回: 

- 根对象

### func halt\(Float64\)
```cj
public func halt(duration: Float64): AnimationAction
```
在指定时间内将动画速度减速到 0

参数: 

|名称|类型|描述|
|---|---|---|
|duration|Float64|持续时间|

返回: 

- 返回自身以支持链式调用

### func init\(AnimationMixer,IAnimationClip,Object3D,Int64\)
```cj
public init(mixer: AnimationMixer, clip: IAnimationClip, localRoot: Object3D, blendMode!: Int64 = - 1)
```
构造一个新的动画动作

参数: 

|名称|类型|描述|
|---|---|---|
|mixer|AnimationMixer|控制此动作的混合器clip 包含实际关键帧的动画剪辑localRoot 此动作执行的根对象，默认为空blendMode 混合模式，默认使用剪辑的混合模式|
|clip|IAnimationClip||
|localRoot|Object3D||
|blendMode|Int64||

### func isRunning\(\)
```cj
public func isRunning(): Bool
```
返回动画是否正在运行

返回: 

- 是否正在运行

### func isScheduled\(\)
```cj
public func isScheduled(): Bool
```
返回是否已调度（play 已被调用）

返回: 

- 是否已调度

### func play\(\)
```cj
public func play(): AnimationAction
```
开始播放动画

返回: 

- 返回自身以支持链式调用

### func reset\(\)
```cj
public func reset(): AnimationAction
```
重置动画播放状态

返回: 

- 返回自身以支持链式调用

### func setDuration\(Float64\)
```cj
public func setDuration(duration: Float64): AnimationAction
```
设置此动作单次循环的持续时间

参数: 

|名称|类型|描述|
|---|---|---|
|duration|Float64|持续时间|

返回: 

- 返回自身以支持链式调用

### func setEffectiveTimeScale\(Float64\)
```cj
public func setEffectiveTimeScale(timeScale: Float64): AnimationAction
```
设置有效时间缩放

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>动作暂停时有效时间缩放为 0</p>

参数: 

|名称|类型|描述|
|---|---|---|
|timeScale|Float64|时间缩放|

返回: 

- 返回自身以支持链式调用

### func setEffectiveWeight\(Float64\)
```cj
public func setEffectiveWeight(weight: Float64): AnimationAction
```
设置有效权重

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>动作禁用时有效权重为 0</p>

参数: 

|名称|类型|描述|
|---|---|---|
|weight|Float64|权重|

返回: 

- 返回自身以支持链式调用

### func setLoop\(Int64,Float64\)
```cj
public func setLoop(mode: Int64, repetitions: Float64): AnimationAction
```
配置循环设置

参数: 

|名称|类型|描述|
|---|---|---|
|mode|Int64|循环模式repetitions 重复次数|
|repetitions|Float64||

返回: 

- 返回自身以支持链式调用

### func startAt\(Float64\)
```cj
public func startAt(time: Float64): AnimationAction
```
设置动画开始时间

参数: 

|名称|类型|描述|
|---|---|---|
|time|Float64|开始时间（秒）|

返回: 

- 返回自身以支持链式调用

### func stopFading\(\)
```cj
public func stopFading(): AnimationAction
```
停止此动作的任何淡入淡出效果

返回: 

- 返回自身以支持链式调用

### func stopWarping\(\)
```cj
public func stopWarping(): AnimationAction
```
停止此动作的任何变速效果

返回: 

- 返回自身以支持链式调用

### func stop\(\)
```cj
public func stop(): AnimationAction
```
停止播放动画

返回: 

- 返回自身以支持链式调用

### func syncWith\(AnimationAction\)
```cj
public func syncWith(action: AnimationAction): AnimationAction
```
将此动作与给定动作同步

参数: 

|名称|类型|描述|
|---|---|---|
|action|AnimationAction|要同步的动作|

返回: 

- 返回自身以支持链式调用

### func warp\(Float64,Float64,Float64\)
```cj
public func warp(startTimeScale: Float64, endTimeScale: Float64, duration: Float64): AnimationAction
```
在指定时间内将播放速度从 startTimeScale 变化到 endTimeScale

参数: 

|名称|类型|描述|
|---|---|---|
|startTimeScale|Float64|起始时间缩放endTimeScale 结束时间缩放duration 持续时间|
|endTimeScale|Float64||
|duration|Float64||

返回: 

- 返回自身以支持链式调用

### var blendMode
```cj
public var blendMode: Int64
```
混合模式

### var clampWhenFinished
```cj
public var clampWhenFinished: Bool
```
是否在最后一帧自动暂停

### var enabled
```cj
public var enabled: Bool
```
是否启用

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>禁用时动作无影响；重新启用时从当前时间继续，默认值为 true</p>

### var loop
```cj
public var loop: Int64
```
循环模式（LoopRepeat | LoopOnce | LoopPingPong），通过 setLoop 设置

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>默认值为 LoopRepeat</p>

### var paused
```cj
public var paused: Bool
```
是否暂停

### var repetitions
```cj
public var repetitions: Float64
```
此动作执行的剪辑重复次数，可通过 setLoop 设置

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>对 LoopOnce 模式无影响，默认值为 Infinity</p>

### var timeScale
```cj
public var timeScale: Float64
```
AnimationAction#time 的缩放因子

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>值为 0 时暂停动画，负值使动画反向播放，默认值为 1</p>

### var time
```cj
public var time: Float64
```
此动作的本地时间（秒，从 0 开始）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>值会被钳制或包裹到 [0, clip.duration]（根据循环状态），默认值为 0</p>

### var weight
```cj
public var weight: Float64
```
此动作的影响程度（区间 [0, 1]）

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>0 表示无影响，1 表示完全影响，介于两者之间的值可用于混合多个动作；默认值为 1</p>

### var zeroSlopeAtEnd
```cj
public var zeroSlopeAtEnd: Bool
```
是否在结束处启用平滑插值

### var zeroSlopeAtStart
```cj
public var zeroSlopeAtStart: Bool
```
是否在开始处启用平滑插值

