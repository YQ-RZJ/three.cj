/**
 * @file[zh-cn] AnimationAction 动画动作类
 * @brief[zh-cn] 管理单个动画剪辑的播放、混合、淡入淡出与变速
 * @explain[zh-cn] AnimationAction 是 AnimationClip 的调度实例，控制动画的播放状态、
 * 循环模式、权重与时间缩放。动作通过链式 API 与动画混合器交互，
 * 支持淡入淡出、交叉淡变与变速等高级控制。
 *
 * @file[en] AnimationAction  Animation action class
 * @brief[en] Manages playback, blending, fading and warping of a single animation clip
 * @explain[en] An AnimationAction is a scheduled instance of an AnimationClip that
 * controls playback state, loop mode, weight and time scale. Actions interact
 * with the animation mixer through a chainable API and support advanced controls
 * such as fading, cross-fading and warping.
 */
package three.animation.blend

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.core.math.interpolants.*
import three.utils.constants.*
import three.animation.interfaces.IAnimationClip
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 动画动作，管理单个动画剪辑的播放控制
 * @explain[zh-cn] 每个动作绑定一个动画混合器、一个动画剪辑与一个局部根对象，
 * 提供播放/停止、重置、淡入淡出、交叉淡变、变速与循环控制等能力。
 *
 * @brief[en] Animation action controlling playback of a single animation clip
 * @explain[en] Each action binds an animation mixer, an animation clip and a local root
 * object, offering play/stop, reset, fading, cross-fade, warping and loop controls.
 */
public class AnimationAction {
    /**
     * @brief[zh-cn] 所属的动画混合器
     *
     * @brief[en] The owning animation mixer
     */
    internal var _mixer: AnimationMixer
    /**
     * @brief[zh-cn] 关联的动画剪辑（接口引用，避免依赖 clip 包）
     *
     * @brief[en] The associated animation clip (interface reference to avoid depending on the clip package)
     */
    private var _clip: IAnimationClip
    /**
     * @brief[zh-cn] 局部根对象
     *
     * @brief[en] The local root object
     */
    private var _localRoot: Object3D
    /**
     * @brief[zh-cn] 混合模式
     *
     * @brief[en] Blend mode
     */
    public var blendMode: Int64

    /**
     * @brief[zh-cn] 插值器设置（结束行为）
     */
    internal var _interpolantSettings: HashMap<String, Int64>
    /**
     * @brief[zh-cn] 插值器数组，每个轨道一个
     */
    internal var _interpolants: Array<Interpolant>
    /**
     * @brief[zh-cn] 属性绑定数组，每个轨道一个 PropertyMixer
     */
    internal var _propertyBindings: Array<PropertyMixer>

    /**
     * @brief[zh-cn] 缓存索引（内存管理用）
     */
    internal var _cacheIndex: Option<Int64>
    /**
     * @brief[zh-cn] 按 clip 分组的缓存索引
     */
    internal var _byClipCacheIndex: Option<Int64>
    /**
     * @brief[zh-cn] 时间缩放插值器
     */
    internal var _timeScaleInterpolant: Option<Interpolant>
    /**
     * @brief[zh-cn] 恢复时间缩放值
     */
    internal var _restoreTimeScale: Option<Float64>
    /**
     * @brief[zh-cn] 权重插值器
     */
    internal var _weightInterpolant: Option<Interpolant>

    /**
     * @brief[zh-cn] 循环模式（LoopRepeat | LoopOnce | LoopPingPong），通过 setLoop 设置
     *
     * @brief[en] Loop mode (LoopRepeat | LoopOnce | LoopPingPong), set via setLoop
     *
     * @note[zh-cn] 默认值为 LoopRepeat
     * @note[en] Defaults to LoopRepeat
     */
    public var loop: Int64

    /**
     * @brief[zh-cn] 循环计数
     */
    internal var _loopCount: Int64

    /**
     * @brief[zh-cn] 调度开始时间（全局混合器时间），为空表示未调度
     */
    internal var _startTime: Option<Float64>

    /**
     * @brief[zh-cn] 此动作的本地时间（秒，从 0 开始）
     *
     * @brief[en] Local time of this action in seconds, starting at 0
     *
     * @note[zh-cn] 值会被钳制或包裹到 [0, clip.duration]（根据循环状态），默认值为 0
     * @note[en] The value is clamped or wrapped to [0, clip.duration] depending on the loop state; defaults to 0
     */
    public var time: Float64

    /**
     * @brief[zh-cn] AnimationAction#time 的缩放因子
     *
     * @brief[en] Scale factor for AnimationAction#time
     *
     * @note[zh-cn] 值为 0 时暂停动画，负值使动画反向播放，默认值为 1
     * @note[en] A value of 0 pauses the animation and a negative value plays it backwards; defaults to 1
     */
    public var timeScale: Float64

    /**
     * @brief[zh-cn] 有效时间缩放（考虑暂停和变速）
     */
    internal var _effectiveTimeScale: Float64

    /**
     * @brief[zh-cn] 此动作的影响程度（区间 [0, 1]）
     *
     * @brief[en] How much this action affects the object (range [0, 1])
     *
     * @note[zh-cn] 0 表示无影响，1 表示完全影响，介于两者之间的值可用于混合多个动作；默认值为 1
     * @note[en] 0 means no influence and 1 means full influence; values in between can blend multiple actions; defaults to 1
     */
    public var weight: Float64

    /**
     * @brief[zh-cn] 有效权重（考虑启用状态）
     */
    internal var _effectiveWeight: Float64

    /**
     * @brief[zh-cn] 此动作执行的剪辑重复次数，可通过 setLoop 设置
     *
     * @brief[en] Number of times the clip is repeated for this action, set via setLoop
     *
     * @note[zh-cn] 对 LoopOnce 模式无影响，默认值为 Infinity
     * @note[en] No effect on LoopOnce mode; defaults to Infinity
     */
    public var repetitions: Float64

    /**
     * @brief[zh-cn] 是否暂停
     *
     * @brief[en] Whether the action is paused
     */
    public var paused: Bool

    /**
     * @brief[zh-cn] 是否启用
     *
     * @brief[en] Whether the action is enabled
     *
     * @note[zh-cn] 禁用时动作无影响；重新启用时从当前时间继续，默认值为 true
     * @note[en] A disabled action has no effect; re-enabling resumes from the current time; defaults to true
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 是否在最后一帧自动暂停
     *
     * @brief[en] Whether to pause automatically on the last frame
     */
    public var clampWhenFinished: Bool

    /**
     * @brief[zh-cn] 是否在开始处启用平滑插值
     *
     * @brief[en] Whether to enable smooth interpolation at the start
     */
    public var zeroSlopeAtStart: Bool

    /**
     * @brief[zh-cn] 是否在结束处启用平滑插值
     *
     * @brief[en] Whether to enable smooth interpolation at the end
     */
    public var zeroSlopeAtEnd: Bool

    /**
     * @brief[zh-cn] 构造一个新的动画动作
     * @param[zh-cn] mixer 控制此动作的混合器
     * clip 包含实际关键帧的动画剪辑
     * localRoot 此动作执行的根对象，默认为空
     * blendMode 混合模式，默认使用剪辑的混合模式
     *
     * @brief[en] Constructs a new animation action
     * @param[en] mixer The mixer controlling this action
     * clip The animation clip holding the actual keyframes
     * localRoot The root object this action runs on, defaults to none
     * blendMode Blend mode, defaults to the clip's blend mode
     */
    public init(mixer: AnimationMixer, clip: IAnimationClip, localRoot: Object3D, blendMode!: Int64 = -1) {
        this._mixer = mixer
        this._clip = clip
        this._localRoot = localRoot
        this.blendMode = if (blendMode == -1) { clip.blendMode } else { blendMode }

        let tracks = clip.tracks
        let nTracks = tracks.size
        let interpolants = Array<Interpolant>(nTracks, { _ =>
            let interp = LinearInterpolant(Array<Float64>(0, { _ => 0.0 }), Array<Float64>(0, { _ => 0.0 }), 0, None)
            interp
        })

        let interpolantSettings = HashMap<String, Int64>()
        interpolantSettings.add("endingStart", ZeroCurvatureEnding)
        interpolantSettings.add("endingEnd", ZeroCurvatureEnding)

        for (i in 0..nTracks) {
            let interpolant = tracks[i].createInterpolant(None)
            interpolants[i] = interpolant
            interpolant.settings = Some(interpolantSettings)
        }

        this._interpolantSettings = interpolantSettings
        this._interpolants = interpolants
        this._propertyBindings = Array<PropertyMixer>(nTracks, { _ => PropertyMixer(PropertyBinding(localRoot, "", HashMap<String, Any>()), "number", 1) })

        this._cacheIndex = None
        this._byClipCacheIndex = None
        this._timeScaleInterpolant = None
        this._restoreTimeScale = None
        this._weightInterpolant = None

        this.loop = LoopRepeat
        this._loopCount = -1
        this._startTime = None
        this.time = 0.0
        this.timeScale = 1.0
        this._effectiveTimeScale = 1.0
        this.weight = 1.0
        this._effectiveWeight = 1.0
        this.repetitions = Float64.Inf
        this.paused = false
        this.enabled = true
        this.clampWhenFinished = false
        this.zeroSlopeAtStart = true
        this.zeroSlopeAtEnd = true
    }

    /**
     * @brief[zh-cn] 开始播放动画
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Starts playing the animation
     * @return[en] Returns itself for chaining
     */
    public func play(): AnimationAction {
        this._mixer._activateAction(this)
        return this
    }

    /**
     * @brief[zh-cn] 停止播放动画
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Stops playing the animation
     * @return[en] Returns itself for chaining
     */
    public func stop(): AnimationAction {
        this._mixer._deactivateAction(this)
        return this.reset()
    }

    /**
     * @brief[zh-cn] 重置动画播放状态
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Resets the animation playback state
     * @return[en] Returns itself for chaining
     */
    public func reset(): AnimationAction {
        this.paused = false
        this.enabled = true
        this.time = 0.0 // 重新开始剪辑
        this._loopCount = -1 // 忘记之前的循环
        this._startTime = None // 忘记调度

        return this.stopFading().stopWarping()
    }

    /**
     * @brief[zh-cn] 返回动画是否正在运行
     * @return[zh-cn] 是否正在运行
     *
     * @brief[en] Returns whether the animation is running
     * @return[en] Whether the animation is running
     */
    public func isRunning(): Bool {
        return this.enabled && !this.paused && this.timeScale != 0.0 &&
            this._startTime.isNone() && this._mixer._isActiveAction(this)
    }

    /**
     * @brief[zh-cn] 返回是否已调度（play 已被调用）
     * @return[zh-cn] 是否已调度
     *
     * @brief[en] Returns whether the action has been scheduled (play has been called)
     * @return[en] Whether the action has been scheduled
     */
    public func isScheduled(): Bool {
        return this._mixer._isActiveAction(this)
    }

    /**
     * @brief[zh-cn] 设置动画开始时间
     * @param[zh-cn] time 开始时间（秒）
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the start time of the animation
     * @param[en] time The start time in seconds
     * @return[en] Returns itself for chaining
     */
    public func startAt(time: Float64): AnimationAction {
        this._startTime = Some(time)
        return this
    }

    /**
     * @brief[zh-cn] 配置循环设置
     * @param[zh-cn] mode 循环模式
     * repetitions 重复次数
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Configures the loop settings
     * @param[en] mode The loop mode
     * repetitions The number of repetitions
     * @return[en] Returns itself for chaining
     */
    public func setLoop(mode: Int64, repetitions: Float64): AnimationAction {
        this.loop = mode
        this.repetitions = repetitions
        return this
    }

    /**
     * @brief[zh-cn] 设置有效权重
     * @param[zh-cn] weight 权重
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the effective weight
     * @param[en] weight The weight
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 动作禁用时有效权重为 0
     * @note[en] The effective weight is 0 while the action is disabled
     */
    public func setEffectiveWeight(weight: Float64): AnimationAction {
        this.weight = weight
        // 注意：与运行时更新逻辑相同
        this._effectiveWeight = if (this.enabled) { weight } else { 0.0 }
        return this.stopFading()
    }

    /**
     * @brief[zh-cn] 返回有效权重
     * @return[zh-cn] 有效权重
     *
     * @brief[en] Returns the effective weight
     * @return[en] The effective weight
     */
    public func getEffectiveWeight(): Float64 {
        return this._effectiveWeight
    }

    /**
     * @brief[zh-cn] 在指定时间内将动画从权重 0 淡入到 1
     * @param[zh-cn] duration 淡入持续时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Fades the animation in from weight 0 to 1 over the given duration
     * @param[en] duration The fade-in duration
     * @return[en] Returns itself for chaining
     */
    public func fadeIn(duration: Float64): AnimationAction {
        return this._scheduleFading(duration, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 在指定时间内将动画从权重 1 淡出到 0
     * @param[zh-cn] duration 淡出持续时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Fades the animation out from weight 1 to 0 over the given duration
     * @param[en] duration The fade-out duration
     * @return[en] Returns itself for chaining
     */
    public func fadeOut(duration: Float64): AnimationAction {
        return this._scheduleFading(duration, 1.0, 0.0)
    }

    /**
     * @brief[zh-cn] 使此动作淡入，同时使给定动作淡出
     * @param[zh-cn] fadeOutAction 要淡出的动作
     * duration 淡入淡出持续时间
     * warp 是否使用变速，默认 false
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Fades this action in while fading the given action out
     * @param[en] fadeOutAction The action to fade out
     * duration The cross-fade duration
     * warp Whether to use warping, defaults to false
     * @return[en] Returns itself for chaining
     */
    public func crossFadeFrom(fadeOutAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction {
        fadeOutAction.fadeOut(duration)
        this.fadeIn(duration)

        if (warp) {
            let fadeInDuration = this._clip.duration
            let fadeOutDuration = fadeOutAction._clip.duration
            let startEndRatio = fadeOutDuration / fadeInDuration
            let endStartRatio = fadeInDuration / fadeOutDuration

            fadeOutAction._restoreTimeScale = Some(fadeOutAction.timeScale)
            this._restoreTimeScale = Some(this.timeScale)

            fadeOutAction.warp(1.0, startEndRatio, duration)
            this.warp(endStartRatio, 1.0, duration)
        }

        return this
    }

    /**
     * @brief[zh-cn] 使此动作淡出，同时使给定动作淡入
     * @param[zh-cn] fadeInAction 要淡入的动作
     * duration 淡入淡出持续时间
     * warp 是否使用变速，默认 false
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Fades this action out while fading the given action in
     * @param[en] fadeInAction The action to fade in
     * duration The cross-fade duration
     * warp Whether to use warping, defaults to false
     * @return[en] Returns itself for chaining
     */
    public func crossFadeTo(fadeInAction: AnimationAction, duration: Float64, warp!: Bool = false): AnimationAction {
        return fadeInAction.crossFadeFrom(this, duration, warp: warp)
    }

    /**
     * @brief[zh-cn] 停止此动作的任何淡入淡出效果
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Stops any fading effect on this action
     * @return[en] Returns itself for chaining
     */
    public func stopFading(): AnimationAction {
        let weightInterpolant = this._weightInterpolant

        if (weightInterpolant.isSome()) {
            this._weightInterpolant = None
            this._mixer._takeBackControlInterpolant(weightInterpolant.getOrThrow())
        }

        return this
    }

    /**
     * @brief[zh-cn] 设置有效时间缩放
     * @param[zh-cn] timeScale 时间缩放
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the effective time scale
     * @param[en] timeScale The time scale
     * @return[en] Returns itself for chaining
     *
     * @note[zh-cn] 动作暂停时有效时间缩放为 0
     * @note[en] The effective time scale is 0 while the action is paused
     */
    public func setEffectiveTimeScale(timeScale: Float64): AnimationAction {
        this.timeScale = timeScale
        this._effectiveTimeScale = if (this.paused) { 0.0 } else { timeScale }
        return this.stopWarping()
    }

    /**
     * @brief[zh-cn] 返回有效时间缩放
     * @return[zh-cn] 有效时间缩放
     *
     * @brief[en] Returns the effective time scale
     * @return[en] The effective time scale
     */
    public func getEffectiveTimeScale(): Float64 {
        return this._effectiveTimeScale
    }

    /**
     * @brief[zh-cn] 设置此动作单次循环的持续时间
     * @param[zh-cn] duration 持续时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Sets the duration of a single loop of this action
     * @param[en] duration The duration
     * @return[en] Returns itself for chaining
     */
    public func setDuration(duration: Float64): AnimationAction {
        this.timeScale = this._clip.duration / duration
        return this.stopWarping()
    }

    /**
     * @brief[zh-cn] 将此动作与给定动作同步
     * @param[zh-cn] action 要同步的动作
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Synchronizes this action with the given action
     * @param[en] action The action to synchronize with
     * @return[en] Returns itself for chaining
     */
    public func syncWith(action: AnimationAction): AnimationAction {
        this.time = action.time
        this.timeScale = action.timeScale
        return this.stopWarping()
    }

    /**
     * @brief[zh-cn] 在指定时间内将动画速度减速到 0
     * @param[zh-cn] duration 持续时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Decelerates the animation to a halt over the given duration
     * @param[en] duration The duration
     * @return[en] Returns itself for chaining
     */
    public func halt(duration: Float64): AnimationAction {
        return this.warp(this._effectiveTimeScale, 0.0, duration)
    }

    /**
     * @brief[zh-cn] 在指定时间内将播放速度从 startTimeScale 变化到 endTimeScale
     * @param[zh-cn] startTimeScale 起始时间缩放
     * endTimeScale 结束时间缩放
     * duration 持续时间
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Warps the playback speed from startTimeScale to endTimeScale over the given duration
     * @param[en] startTimeScale The starting time scale
     * endTimeScale The ending time scale
     * duration The duration
     * @return[en] Returns itself for chaining
     */
    public func warp(startTimeScale: Float64, endTimeScale: Float64, duration: Float64): AnimationAction {
        let mixer = this._mixer
        let now = mixer.time
        let timeScale = this.timeScale

        var interpolant = this._timeScaleInterpolant

        if (interpolant.isNone()) {
            interpolant = Some(mixer._lendControlInterpolant())
            this._timeScaleInterpolant = interpolant
        }

        let interp = interpolant.getOrThrow()
        let times = interp.parameterPositions
        let values = interp.sampleValues

        times[0] = now
        times[1] = now + duration
        values[0] = startTimeScale / timeScale
        values[1] = endTimeScale / timeScale

        return this
    }

    /**
     * @brief[zh-cn] 停止此动作的任何变速效果
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * @brief[en] Stops any warping effect on this action
     * @return[en] Returns itself for chaining
     */
    public func stopWarping(): AnimationAction {
        let timeScaleInterpolant = this._timeScaleInterpolant

        if (timeScaleInterpolant.isSome()) {
            this._timeScaleInterpolant = None
            this._mixer._takeBackControlInterpolant(timeScaleInterpolant.getOrThrow())
        }

        this._restoreTimeScale = None

        return this
    }

    /**
     * @brief[zh-cn] 返回此动作的动画混合器
     * @return[zh-cn] 动画混合器
     *
     * @brief[en] Returns the animation mixer of this action
     * @return[en] The animation mixer
     */
    public func getMixer(): AnimationMixer {
        return this._mixer
    }

    /**
     * @brief[zh-cn] 返回此动作的动画剪辑
     * @return[zh-cn] 动画剪辑
     *
     * @brief[en] Returns the animation clip of this action
     * @return[en] The animation clip
     */
    public func getClip(): IAnimationClip {
        return this._clip
    }

    /**
     * @brief[zh-cn] 返回此动作的根对象
     * @return[zh-cn] 根对象
     *
     * @brief[en] Returns the root object of this action
     * @return[en] The root object
     */
    public func getRoot(): Object3D {
        return this._localRoot
    }

    // === 内部方法 ===

    /**
     * @param[zh-cn] time 全局混合器时间
     * @param[zh-cn] deltaTime 时间增量
     * @param[zh-cn] timeDirection 时间方向
     * @param[zh-cn] accuIndex 累积索引
     *
     * 更新动作（由 AnimationMixer 调用）
     */
    internal func _update(time: Float64, deltaTime: Float64, timeDirection: Float64, accuIndex: Int64): Unit {
        if (!this.enabled) {
            // 调用 _updateWeight 以更新 _effectiveWeight
            this._updateWeight(time)
            return
        }

        var dt = deltaTime
        let startTime = this._startTime

        if (startTime.isSome()) {
            // 检查调度的动作开始
            let startTimeVal = startTime.getOrThrow()
            let timeRunning = (time - startTimeVal) * timeDirection
            if (timeRunning < 0.0 || timeDirection == 0.0) {
                dt = 0.0
            } else {
                this._startTime = None // 取消调度
                dt = timeDirection * timeRunning
            }
        }

        // 应用时间缩放并推进时间
        dt *= this._updateTimeScale(time)
        let clipTime = this._updateTime(dt)

        // 注意：_updateTime 可能禁用动作，导致有效权重为 0
        let weight = this._updateWeight(time)

        if (weight > 0.0) {
            let interpolants = this._interpolants
            let propertyMixers = this._propertyBindings

            if (this.blendMode == AdditiveAnimationBlendMode) {
                // 加法混合模式
                for (j in 0..interpolants.size) {
                    interpolants[j].evaluate(clipTime)
                    propertyMixers[j].accumulateAdditive(weight)
                }
            } else {
                // 普通混合模式
                for (j in 0..interpolants.size) {
                    interpolants[j].evaluate(clipTime)
                    propertyMixers[j].accumulate(accuIndex, weight)
                }
            }
        }
    }

    /**
     * @param[zh-cn] time 全局混合器时间
     * @return[zh-cn] 有效权重
     *
     * 更新权重
     */
    internal func _updateWeight(time: Float64): Float64 {
        var weight: Float64 = 0.0

        if (this.enabled) {
            weight = this.weight
            let interpolant = this._weightInterpolant

            if (interpolant.isSome()) {
                let interp = interpolant.getOrThrow()
                let interpolantValue = interp.evaluate(time)[0]
                weight *= interpolantValue

                if (time > interp.parameterPositions[1]) {
                    this.stopFading()

                    if (interpolantValue == 0.0) {
                        // 淡出完成，禁用
                        this.enabled = false
                    }
                }
            }
        }

        this._effectiveWeight = weight
        return weight
    }

    /**
     * @param[zh-cn] time 全局混合器时间
     * @return[zh-cn] 有效时间缩放
     *
     * 更新时间缩放
     */
    internal func _updateTimeScale(time: Float64): Float64 {
        var timeScale: Float64 = 0.0

        if (!this.paused) {
            timeScale = this.timeScale

            let interpolant = this._timeScaleInterpolant

            if (interpolant.isSome()) {
                let interp = interpolant.getOrThrow()
                let interpolantValue = interp.evaluate(time)[0]
                timeScale *= interpolantValue

                if (time > interp.parameterPositions[1]) {
                    if (timeScale == 0.0) {
                        // 运动已停止，暂停
                        this.paused = true
                    } else {
                        if (this._restoreTimeScale.isSome()) {
                            timeScale = this._restoreTimeScale.getOrThrow()
                        }
                        // 变速完成 — 应用最终时间缩放
                        this.timeScale = timeScale
                    }
                    this.stopWarping()
                }
            }
        }

        this._effectiveTimeScale = timeScale
        return timeScale
    }

    /**
     * @param[zh-cn] deltaTime 时间增量
     * @return[zh-cn] 剪辑时间
     *
     * 更新时间
     */
    internal func _updateTime(deltaTime: Float64): Float64 {
        let duration = this._clip.duration
        let loop = this.loop

        var time = this.time + deltaTime
        var loopCount = this._loopCount

        let pingPong = (loop == LoopPingPong)

        if (deltaTime == 0.0) {
            if (loopCount == -1) { return time }
            return if (pingPong && (loopCount & 1) == 1) { duration - time } else { time }
        }

        if (loop == LoopOnce) {
            if (loopCount == -1) {
                // 刚开始
                this._loopCount = 0
                this._setEndings(true, true, false)
            }

            // handle_stop 标签逻辑
            if (time >= duration) {
                time = duration
            } else if (time < 0.0) {
                time = 0.0
            } else {
                this.time = time
                return time
            }

            if (this.clampWhenFinished) {
                this.paused = true
            } else {
                this.enabled = false
            }

            this.time = time
            this._mixer.dispatchEvent(Event("finished"))
            return time

        } else {
            // 重复循环或乒乓循环

            if (loopCount == -1) {
                // 刚开始
                if (deltaTime >= 0.0) {
                    loopCount = 0
                    this._setEndings(true, this.repetitions == 0.0, pingPong)
                } else {
                    // 反向循环时，初始通过零算作一次循环
                    this._setEndings(this.repetitions == 0.0, true, pingPong)
                }
            }

            if (time >= duration || time < 0.0) {
                // 环绕
                let loopDelta = Int64(floor(time / duration)) // 有符号
                time -= duration * Float64(loopDelta)
                loopCount += abs(loopDelta)

                let pending = this.repetitions - Float64(loopCount)

                if (pending <= 0.0) {
                    // 必须停止（切换状态、钳制时间、触发事件）
                    if (this.clampWhenFinished) {
                        this.paused = true
                    } else {
                        this.enabled = false
                    }

                    time = if (deltaTime > 0.0) { duration } else { 0.0 }
                    this.time = time
                    this._mixer.dispatchEvent(Event("finished"))
                    return time
                } else {
                    // 继续运行
                    if (pending == 1.0) {
                        // 进入最后一轮
                        let atStart = deltaTime < 0.0
                        this._setEndings(atStart, !atStart, pingPong)
                    } else {
                        this._setEndings(false, false, pingPong)
                    }

                    this._loopCount = loopCount
                    this.time = time
                    this._mixer.dispatchEvent(Event("loop"))
                }
            } else {
                this._loopCount = loopCount
                this.time = time
            }

            if (pingPong && (loopCount & 1) == 1) {
                // 乒乓回合反转时间
                return duration - time
            }
        }

        return time
    }

    /**
     * @param[zh-cn] atStart 是否在起点处结束
     * @param[zh-cn] atEnd 是否在终点处结束
     * @param[zh-cn] pingPong 是否乒乓循环
     *
     * 设置插值器端点行为
     */
    internal func _setEndings(atStart: Bool, atEnd: Bool, pingPong: Bool): Unit {
        let settings = this._interpolantSettings

        if (pingPong) {
            settings.add("endingStart", ZeroSlopeEnding)
            settings.add("endingEnd", ZeroSlopeEnding)
        } else {
            // 假设 LoopOnce 时 atStart == atEnd == true
            if (atStart) {
                settings.add("endingStart", if (this.zeroSlopeAtStart) { ZeroSlopeEnding } else { ZeroCurvatureEnding })
            } else {
                settings.add("endingStart", WrapAroundEnding)
            }

            if (atEnd) {
                settings.add("endingEnd", if (this.zeroSlopeAtEnd) { ZeroSlopeEnding } else { ZeroCurvatureEnding })
            } else {
                settings.add("endingEnd", WrapAroundEnding)
            }
        }
    }

    /**
     * @param[zh-cn] duration 持续时间
     * @param[zh-cn] weightNow 当前权重
     * @param[zh-cn] weightThen 目标权重
     * @return[zh-cn] 返回自身以支持链式调用
     *
     * 调度淡入淡出效果
     */
    internal func _scheduleFading(duration: Float64, weightNow: Float64, weightThen: Float64): AnimationAction {
        let mixer = this._mixer
        let now = mixer.time
        var interpolant = this._weightInterpolant

        if (interpolant.isNone()) {
            interpolant = Some(mixer._lendControlInterpolant())
            this._weightInterpolant = interpolant
        }

        let interp = interpolant.getOrThrow()
        let times = interp.parameterPositions
        let values = interp.sampleValues

        times[0] = now
        values[0] = weightNow
        times[1] = now + duration
        values[1] = weightThen

        return this
    }
}
