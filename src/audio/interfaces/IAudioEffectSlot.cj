/**
 * @file[zh-cn] IAudioEffectSlot 音频效果槽接口（解耦 source 与 mixer）
 * @brief[zh-cn] 本文件定义音频效果槽接口 IAudioEffectSlot
 * @explain[zh-cn] source 包通过此接口引用效果槽，避免直接依赖 mixer 包的具体类 AudioEffectSlot，
 * 从而打破 source → mixer 的潜在循环依赖边界。
 *
 * @file[en] IAudioEffectSlot  Audio effect slot interface (decoupling source and mixer)
 * @brief[en] This file defines the audio effect slot interface IAudioEffectSlot
 * @explain[en] The source package references effect slots through this interface instead of
 * the concrete mixer class AudioEffectSlot, breaking the potential circular
 * dependency boundary of source → mixer.
 */
package three.audio.interfaces

/**
 * @brief[zh-cn] 音频效果槽接口
 * @explain[zh-cn] 暴露 source 包所需的唯一属性：OpenAL 效果槽句柄 slotId。
 *
 * @brief[en] Audio effect slot interface
 * @explain[en] Exposes the only property the source package needs: the OpenAL effect
 * slot handle slotId.
 */
public interface IAudioEffectSlot {
    /**
     * @brief[zh-cn] 获取 OpenAL 效果槽句柄
     * @return[zh-cn] OpenAL 效果槽句柄（ALuint）
     *
     * @brief[en] Returns the OpenAL effect slot handle
     * @return[en] The OpenAL effect slot handle (ALuint)
     */
    func getSlotId(): UInt32
}
