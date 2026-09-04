/**
 * @file[zh-cn] IAudioEffect 音频效果对象接口（解耦 source 与 mixer）
 * @brief[zh-cn] 本文件定义音频效果对象接口 IAudioEffect
 * @explain[zh-cn] 预留接口：当 source 包未来需要直接引用 AudioEffect 时，
 * 通过此接口避免直接依赖 mixer 包，从而打破 source → mixer 的潜在循环依赖边界。
 *
 * @file[en] IAudioEffect  Audio effect object interface (decoupling source and mixer)
 * @brief[en] This file defines the audio effect object interface IAudioEffect
 * @explain[en] Reserved interface: when the source package needs to reference AudioEffect
 * in the future, it uses this interface to avoid a direct dependency on the mixer
 * package, breaking the potential circular dependency boundary of source → mixer.
 */
package three.audio.interfaces

/**
 * @brief[zh-cn] 音频效果对象接口
 * @explain[zh-cn] 暴露 OpenAL 效果句柄 effectId，供 source 包按需引用音频效果。
 *
 * @brief[en] Audio effect object interface
 * @explain[en] Exposes the OpenAL effect handle effectId so the source package can
 * reference audio effects as needed.
 */
public interface IAudioEffect {
    /**
     * @brief[zh-cn] 获取 OpenAL 效果句柄
     * @return[zh-cn] OpenAL 效果句柄（ALuint）
     *
     * @brief[en] Returns the OpenAL effect handle
     * @return[en] The OpenAL effect handle (ALuint)
     */
    func getEffectId(): UInt32
}
