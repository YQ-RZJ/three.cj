# 类
## class AnimationMixer
```cj
public class AnimationMixer <: EventDispatcher
```
动画混合器，管理一组动画动作的混合播放

### func bindSceneSkeleton\(Skeleton\)
```cj
public func bindSceneSkeleton(skeleton: Skeleton): Unit
```
绑定场景骨骼

参数: 

|名称|类型|描述|
|---|---|---|
|skeleton|Skeleton|场景层骨骼对象|

### func clipAction\(IAnimationClip,Option<Object3D>,Int64\)
```cj
public func clipAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None, blendMode!: Int64 = - 1): AnimationAction
```
返回传入剪辑的 AnimationAction 实例

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>如果适合 clip 和 root 参数的动作尚不存在，此方法将创建它；
使用相同的 clip 和 root 参数多次调用此方法始终返回相同的动作</p>

参数: 

|名称|类型|描述|
|---|---|---|
|clip|IAnimationClip|动画剪辑optionalRoot 可选的替代根对象，默认为混合器根对象blendMode 混合模式，默认使用剪辑的混合模式|
|optionalRoot|Option<Object3D>||
|blendMode|Int64||

返回: 

- 动画动作

### func existingAction\(IAnimationClip,Option<Object3D>\)
```cj
public func existingAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None): Option < AnimationAction >
```
返回传入剪辑的现有动画动作

参数: 

|名称|类型|描述|
|---|---|---|
|clip|IAnimationClip|动画剪辑optionalRoot 可选的替代根对象，默认为混合器根对象|
|optionalRoot|Option<Object3D>||

返回: 

- 动画动作，未找到返回 None

### func getRoot\(\)
```cj
public func getRoot(): Object3D
```
返回此混合器的根对象

返回: 

- 根对象

### func init\(Object3D\)
```cj
public init(root: Object3D)
```
构造一个新的动画混合器

参数: 

|名称|类型|描述|
|---|---|---|
|root|Object3D|此混合器播放动画的根对象|

### func registerSkeletalData\(String,SkeletalAnimationData\)
```cj
public func registerSkeletalData(clipUUID: String, data: SkeletalAnimationData): Unit
```
注册骨骼动画数据

参数: 

|名称|类型|描述|
|---|---|---|
|clipUUID|String|动画片段的 UUID|
|data|SkeletalAnimationData|骨骼动画压缩数据|

### func setTime\(Float64\)
```cj
public func setTime(time: Float64): AnimationMixer
```
将全局混合器设置为特定时间并相应更新动画

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>当需要跳转到动画中的精确时间时很有用；输入参数将被 AnimationMixer#timeScale 缩放</p>

参数: 

|名称|类型|描述|
|---|---|---|
|time|Float64|要设置的时间（秒）|

返回: 

- 返回自身以支持链式调用

### func stopAllAction\(\)
```cj
public func stopAllAction(): AnimationMixer
```
停用此混合器上所有先前调度的动作

返回: 

- 返回自身以支持链式调用

### func uncacheAction\(IAnimationClip,Option<Object3D>\)
```cj
public func uncacheAction(clip: IAnimationClip, optionalRoot!: Option < Object3D >= None): Unit
```
释放动作的所有内存资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>使用此方法前，确保调用了 AnimationAction#stop 停用动作</p>

参数: 

|名称|类型|描述|
|---|---|---|
|clip|IAnimationClip|动画剪辑optionalRoot 可选的替代根对象，默认为混合器根对象|
|optionalRoot|Option<Object3D>||

### func uncacheClip\(IAnimationClip\)
```cj
public func uncacheClip(clip: IAnimationClip): Unit
```
释放剪辑的所有内存资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>使用此方法前，确保对所有相关动作调用了 AnimationAction#stop</p>

参数: 

|名称|类型|描述|
|---|---|---|
|clip|IAnimationClip|要取消缓存的剪辑|

### func uncacheRoot\(Object3D\)
```cj
public func uncacheRoot(root: Object3D): Unit
```
释放根对象的所有内存资源

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>使用此方法前，确保对所有相关动作调用了 AnimationAction#stop</p>

参数: 

|名称|类型|描述|
|---|---|---|
|root|Object3D|要取消缓存的根对象|

### func updateSkeletal\(SkeletonData,Float32\)
```cj
public func updateSkeletal(skeletonData: SkeletonData, deltaTime: Float32): Unit
```
使用骨骼采样/混合 Job 管线更新骨骼动画

参数: 

|名称|类型|描述|
|---|---|---|
|skeletonData|SkeletonData|运行时骨骼数据|
|deltaTime|Float32|帧间隔时间（秒），与 update 的入参保持一致|

### func update\(Float64\)
```cj
public func update(deltaTime: Float64): AnimationMixer
```
推进全局混合器时间并更新动画

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>通常在渲染循环中通过传递 Clock 或 Timer 的增量时间来调用</p>

参数: 

|名称|类型|描述|
|---|---|---|
|deltaTime|Float64|增量时间（秒）|

返回: 

- 返回自身以支持链式调用

### var stats
```cj
public var stats: HashMap < String, HashMap < String,() -> Int64 >>
```
统计信息

### var timeScale
```cj
public var timeScale: Float64
```
全局时间缩放因子

<p style="background:oklch(98% 0 0);color:black;border-radius:.375rem;padding:8px;margin:8px;white-space:pre-wrap;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);"><span style="text-shadow:2px 2px 4px rgba(0, 0, 0, 0.3);">💬 </span>设置为 0 再恢复为 1 可暂停/恢复所有动作，默认值为 1</p>

### var time
```cj
public var time: Float64
```
全局混合器时间（秒，从创建时为 0）

