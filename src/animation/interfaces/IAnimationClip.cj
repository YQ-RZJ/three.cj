/**
 * @file[zh-cn] IAnimationClip 动画剪辑接口（解耦 blend 与 clip 包的循环依赖）
 * @brief[zh-cn] 定义 AnimationClip 的公共契约，供 blend 包以接口引用剪辑实例
 * @explain[zh-cn] 背景：blend 包的 AnimationAction/AnimationMixer 持有 AnimationClip 实例（clip 包），
 * 访问其 uuid/blendMode/duration/tracks 等成员。而 clip 包的工厂方法
 * parse/CreateFromMorphTargetSequence 需构造 KeyframeTrack 具体类（blend 包），
 * 形成 clip ↔ blend 循环依赖。
 * 解决：将 AnimationClip 的 public 契约抽象为本接口，
 * - 实现方（clip 包 AnimationClip）实现本接口；
 * - 使用方（blend 包 AnimationAction._clip / AnimationMixer.clipAction 等）以接口引用，
 * 避免直接依赖 clip 包。
 * 接口继承 three.interfaces.IAnimationClip（标记接口）：
 * - Object3D.animations 仍以 three.interfaces.IAnimationClip 父接口存储（不依赖 animation 包）；
 * - 调用方需要访问 clip 成员时，可 as 转换为本子接口或 AnimationClip 具体类。
 *
 * @file[en] IAnimationClip  Animation clip interface (decouples the circular dependency between the blend and clip packages)
 * @brief[en] Defines the public contract of AnimationClip, referenced by the blend package through this interface
 * @explain[en] Background: the blend package's AnimationAction/AnimationMixer hold AnimationClip
 * instances (clip package) and access members such as uuid/blendMode/duration/tracks.
 * The clip package's factory methods parse/CreateFromMorphTargetSequence must construct
 * concrete KeyframeTrack classes (blend package), forming a clip ↔ blend circular dependency.
 * Solution: abstract the public contract of AnimationClip into this interface:
 * - the implementer (clip package's AnimationClip) implements this interface;
 * - consumers (blend package's AnimationAction._clip / AnimationMixer.clipAction etc.)
 * reference it through the interface, avoiding a direct dependency on the clip package.
 * The interface extends three.interfaces.IAnimationClip (a marker interface):
 * - Object3D.animations is still stored as the parent interface three.interfaces.IAnimationClip
 * (no dependency on the animation package);
 * - callers needing clip members can cast (as) to this sub-interface or the concrete
 * AnimationClip class.
 */
package three.animation.interfaces

import std.collection.*

/**
 * @brief[zh-cn] 动画剪辑接口：blend 包引用 AnimationClip 的契约类型
 * @explain[zh-cn] 声明剪辑的公开属性契约，供使用方以接口引用，避免直接依赖 clip 包。
 *
 * @brief[en] Animation clip interface: the contract type through which the blend package references AnimationClip
 * @explain[en] Declares the public property contract of a clip so consumers can reference it via the interface without directly depending on the clip package.
 */
public interface IAnimationClip {
    /**
     * @brief[zh-cn] 剪辑名称
     *
     * @brief[en] Clip name
     */
    mut prop name: String

    /**
     * @brief[zh-cn] 剪辑持续时间（秒）
     *
     * @brief[en] Clip duration (seconds)
     */
    mut prop duration: Float64

    /**
     * @brief[zh-cn] 唯一标识
     *
     * @brief[en] Unique identifier
     */
    mut prop uuid: String

    /**
     * @brief[zh-cn] 混合模式（NormalAnimationBlendMode / AdditiveAnimationBlendMode）
     *
     * @brief[en] Blend mode (NormalAnimationBlendMode / AdditiveAnimationBlendMode)
     */
    mut prop blendMode: Int64

    /**
     * @brief[zh-cn] 关键帧轨道数组（通过 IKeyframeTrack 接口引用，避免依赖 blend 包 KeyframeTrack 具体类）
     *
     * @brief[en] Keyframe track array (referenced via the IKeyframeTrack interface to avoid depending on the concrete KeyframeTrack class in the blend package)
     */
    mut prop tracks: Array<IKeyframeTrack>

    /**
     * @brief[zh-cn] 用户自定义数据
     *
     * @brief[en] User-defined data
     */
    mut prop userData: HashMap<String, Any>
}
