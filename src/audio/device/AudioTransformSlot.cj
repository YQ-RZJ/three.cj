/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such binary product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] AudioTransformSlot.cj — 音频变换槽（渲染线程写 / 音频线程读）
 * @brief[zh-cn] 承载一个可异步下发给 OpenAL 的音频对象变换参数。
 * @explain[zh-cn] 渲染线程每帧更新监听器/空间音源的世界变换。若每次都通过
 *               execAudio 同步往返，渲染线程要为每个音源各阻塞一次（实测单次
 *               70~180µs），N 个音源即 N 倍帧时间。本类把"写值"与"下发"解耦：
 *               渲染线程只把新值写进槽内，音频线程在自己的循环中取走新版本
 *               并调用 OpenAL，渲染线程全程不阻塞。
 *               依据《多线程改造计划》阶段 3，脏标记由**版本号 + seqlock** 取代
 *               （不再有 Mutex）：
 *               - 写者：版本 +1（变奇数 = 写入中）→ 写参数 → 版本 +1（变偶数 = 稳定）；
 *               - 读者：读到偶数版本且与本地已消费版本不同 → 复制参数 → 复读版本，
 *                 一致才认可（不一致说明复制期间被覆盖，下一轮重取）；
 *               - 版本号单调递增，读者以"已消费版本"判断是否有新数据，无需清标记，
 *                 避免"读者清标记时覆盖写者刚置的新标记"导致丢更新。
 *
 * @file[en] AudioTransformSlot.cj — audio transform slot (written by the render thread, read by the audio thread)
 * @brief[en] Carries the transform parameters of one audio object, submitted to OpenAL asynchronously.
 * @explain[en] The render thread updates the world transform of the listener/spatial
 *               source every frame. Submitting each of them through a synchronous
 *               execAudio round trip blocks the render thread once per source
 *               (measured 70~180µs each), i.e. N times the frame time for N
 *               sources. This class decouples "writing the values" from
 *               "submitting them": the render thread only writes the new values
 *               and the audio thread picks up new versions in its own loop and
 *               calls OpenAL, so the render thread never blocks. Per Phase 3 of
 *               the multi-threading plan the dirty flag is replaced by a
 *               **version counter + seqlock** (no Mutex):
 *               - writer: version +1 (odd = writing) → write params → version +1 (even = stable);
 *               - reader: even version different from its last consumed version → copy params →
 *                 re-read version; accept only when unchanged (otherwise retry next round);
 *               - the version is monotonic and the reader tracks "consumed version", so no flag
 *                 clearing is needed and no update can be lost by clearing a freshly set flag.
 */

package three.audio.device

import std.sync.AtomicInt64

/**
 * @brief[zh-cn] 音频变换槽
 * @explain[zh-cn] 一个槽对应一个 OpenAL 音频对象（监听器或空间音源）。槽内保存
 *               待下发的参数值与版本号：渲染线程写入参数并推进版本，音频线程
 *               取走新版本后调用 OpenAL。参数以普通字段存放（不做堆分配），下发时
 *               由 AudioContext 复制到其共享的暂存缓冲再交给 OpenAL，避免每个音频
 *               对象各自持有 C 内存。
 *               并发约定：参数字段只由**写者**（渲染线程）经由 AudioContext.postTransform
 *               在 seqlock 保护下写入，只由**读者**（音频线程）在版本一致时读取；
 *               `sourceId` / `isListener` 只由音频线程写入。
 *
 * @brief[en] An audio transform slot
 * @explain[en] One slot corresponds to one OpenAL audio object (listener or spatial
 *               source). The slot holds the pending parameter values and a version
 *               counter: the render thread writes the values and advances the
 *               version, the audio thread takes the new version, calls OpenAL. The
 *               values live in plain fields (no heap allocation); the AudioContext
 *               copies them into its shared staging buffer before handing them to
 *               OpenAL, so no per-object C memory is needed.
 *               Concurrency: parameter fields are written only by the *writer*
 *               (render thread) through AudioContext.postTransform under the
 *               seqlock, and read only by the *reader* (audio thread) when the
 *               version is stable; `sourceId` / `isListener` are written only by
 *               the audio thread.
 */
public class AudioTransformSlot {
    /**
     * @brief[zh-cn] 版本号（seqlock：奇数 = 写入中，偶数 = 参数稳定）
     * @explain[zh-cn] 写者每次提交 +2（中途经过奇数态）；读者以"已消费版本"判断
     *               是否还有新数据，因此无需独立的 dirty 布尔标记。
     *
     * @brief[en] Version counter (seqlock: odd = being written, even = stable)
     * @explain[en] The writer adds 2 per submission (passing through an odd state); the
     *              reader compares against its consumed version, so no separate dirty flag is needed.
     */
    internal let _version = AtomicInt64(0)

    /**
     * @brief[zh-cn] 读者已消费的版本（仅音频线程访问，无需原子）
     *
     * @brief[en] Version already consumed by the reader (audio thread only, no atomics needed)
     */
    internal var _consumedVersion: Int64 = 0

    /**
     * @brief[zh-cn] 目标 OpenAL 源 ID
     * @explain[zh-cn] 监听器用 0 表示（OpenAL 的监听器是全局单例，通过
     *               alListenerfv 设置，不属于某个源）；音源为其源 ID，
     *               源被释放后置 0，表示跳过下发。
     *
     * @brief[en] The target OpenAL source id
     * @explain[en] Zero for the listener (OpenAL's listener is a global singleton set
     *               through alListenerfv, not a source); a source slot holds its
     *               source id, and zero after the source was released, which means
     *               "skip submission".
     */
    public var sourceId: UInt32 = 0u32

    /**
     * @brief[zh-cn] 是否为监听器槽（true 用 alListenerfv，false 用 alSourcefv）
     *
     * @brief[en] Whether this is a listener slot (alListenerfv) or a source slot (alSourcefv)
     */
    public var isListener: Bool = false

    /**
     * @brief[zh-cn] 位置 X（OpenAL 右手系）
     *
     * @brief[en] Position X (OpenAL right-handed system)
     */
    public var px: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 位置 Y（OpenAL 右手系）
     *
     * @brief[en] Position Y (OpenAL right-handed system)
     */
    public var py: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 位置 Z（OpenAL 右手系）
     *
     * @brief[en] Position Z (OpenAL right-handed system)
     */
    public var pz: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 朝向 X（监听器的前方向 / 音源的方向）
     *
     * @brief[en] Orientation X (listener forward axis / source direction)
     */
    public var ox: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 朝向 Y（监听器的前方向 / 音源的方向）
     *
     * @brief[en] Orientation Y (listener forward axis / source direction)
     */
    public var oy: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 朝向 Z（监听器的前方向 / 音源的方向）
     *
     * @brief[en] Orientation Z (listener forward axis / source direction)
     */
    public var oz: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 上方向 X（监听器）/ 速度 X（音源）
     *
     * @brief[en] Up axis X (listener) / velocity X (source)
     */
    public var ux: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 上方向 Y（监听器）/ 速度 Y（音源）
     *
     * @brief[en] Up axis Y (listener) / velocity Y (source)
     */
    public var uy: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 上方向 Z（监听器）/ 速度 Z（音源）
     *
     * @brief[en] Up axis Z (listener) / velocity Z (source)
     */
    public var uz: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 主音量（仅监听器槽使用，用于下发 AL_GAIN）
     *
     * @brief[en] Master gain (listener slots only, used to submit AL_GAIN)
     */
    public var gain: Float32 = 1.0f32

    /**
     * @brief[zh-cn] 使槽失效（目标源已释放）：源 ID 置 0 并推进版本
     * @explain[zh-cn] 音频线程下一次取到新版本时看到 sourceId == 0 即跳过下发，
     *               避免向已删除的 OpenAL 源写参数（AL_INVALID_NAME）。
     *               版本 +2 保持"偶数=稳定"不变式，中间奇数态让并发读者本轮跳过。
     *
     * @brief[en] Invalidates the slot (target source released): zeroes the source id and advances the version
     * @explain[en] When the audio thread next picks up the new version and sees sourceId == 0 it
     *              skips submission, avoiding writes to a deleted OpenAL source (AL_INVALID_NAME).
     *              Adding 2 keeps the "even = stable" invariant; the intermediate odd state
     *              makes a concurrent reader skip this round.
     */
    public func invalidate(): Unit {
        this.sourceId = 0u32
        this._version.fetchAdd(1)
        this._version.fetchAdd(1)
    }
}
