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
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] AudioListener 音频监听器，代表场景中的"耳朵"
 * @brief[zh-cn] 音频监听器：继承 Object3D，将世界变换同步到 OpenAL 监听器
 * @explain[zh-cn] 通常作为 Camera 的子节点添加（camera.add(listener)），
 * 在每帧 updateMatrixWorld 中将世界位置和朝向同步到 OpenAL 监听器，
 * 并支持主音量（master gain）控制。
 * 坐标约定：Three.cj 使用左手坐标系，OpenAL 使用右手坐标系，
 * 同步位置/朝向时需翻转 Z 轴（LH → RH: z' = -z）。
 *
 * @file[en] AudioListener  The audio listener representing the "ears" in the scene
 * @brief[en] Audio listener: extends Object3D and syncs world transforms to the OpenAL listener
 * @explain[en] Usually added as a child of the Camera (camera.add(listener)). On every frame
 * updateMatrixWorld syncs the world position and orientation to the OpenAL listener
 * and supports master gain control.
 * Coordinate convention: Three.cj uses a left-handed coordinate system while OpenAL
 * is right-handed, so the Z axis is flipped when syncing position/orientation
 * (LH → RH: z' = -z).
 */
package three.audio.listener

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import openalsoft4cj.al.*
import openalsoft4cj.alc.*
import std.sync.*

import three.audio.device.*
import three.profiler.*
import three.profiler.macros.*
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] 音频监听器，代表场景中的"耳朵"
 * @explain[zh-cn] 继承 Object3D，作为 Camera 的子节点随场景更新；
 * 在 updateMatrixWorld 中将世界位置、朝向与主音量同步到 OpenAL 监听器。
 * 同步时需要将左手系坐标/朝向翻转到 OpenAL 右手系（Z 轴取反）。
 *
 * @brief[en] Audio listener representing the "ears" in the scene
 * @explain[en] Extends Object3D and is usually attached to the Camera. updateMatrixWorld
 * syncs the world position, orientation and master gain to the OpenAL listener,
 * flipping the left-handed coordinates/orientation into the OpenAL right-handed
 * system (negate Z).
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Object3D]
public open class AudioListener <: Object3D & IReleasable {
    /**
     * @brief[zh-cn] 音频上下文引用
     *
     * @brief[en] The audio context reference
     */
    @JsonIgnore
    public var context: AudioContext

    /**
     * @brief[zh-cn] 主音量（0.0 ~ 1.0+）
     *
     * @brief[en] Master volume (0.0 ~ 1.0+)
     */
    public var gain: Float64

    /**
     * @brief[zh-cn] 时间增量（用于平滑插值；当前实现为简化版，不使用 linearRampToValueAtTime）
     *
     * @brief[en] Time delta (for smooth interpolation; current implementation is simplified, no linearRampToValueAtTime)
     */
    public var timeDelta: Float64

    /**
     * @brief[zh-cn] 音频变换槽（异步下发到 OpenAL 监听器）
     * @explain[zh-cn] 渲染线程每帧把监听器的世界变换写进槽内并置脏，音频线程在
     *               自己的循环里取走脏槽并调用 alListenerfv，避免每帧一次跨线程
     *               阻塞往返（实测单次 70~180µs）。
     *
     * @brief[en] The audio transform slot (submitted asynchronously to the OpenAL listener)
     * @explain[en] Every frame the render thread writes the listener's world transform
     *               into the slot and flags it dirty; the audio thread picks up dirty
     *               slots in its own loop and calls alListenerfv, avoiding a blocking
     *               cross-thread round trip per frame (measured 70~180µs each).
     */
    @JsonIgnore
    private var _slot: AudioTransformSlot = AudioTransformSlot()

    /**
     * @brief[zh-cn] 创建音频监听器
     * @param[zh-cn] context 音频上下文（默认使用 AudioContext.context 单例）
     *
     * @brief[en] Creates an audio listener
     * @param[en] context The audio context (defaults to the AudioContext.context singleton)
     */
    public init(context!: AudioContext = AudioContext.context) {
        super()
        this.context = context
        this.gain = 1.0
        this.timeDelta = 0.0
        this._slot.isListener = true
        this.context.registerTransformSlot(this._slot)
    }

    /**
     * @brief[zh-cn] 获取主音量
     * @return[zh-cn] 当前主音量（0.0 ~ 1.0+）
     *
     * @brief[en] Returns the master volume
     * @return[en] The current master volume (0.0 ~ 1.0+)
     */
    public func getMasterVolume(): Float64 {
        return this.gain
    }

    /**
     * @brief[zh-cn] 释放监听器：从音频上下文的变换槽注册表注销
     * @explain[zh-cn] 注册表是单例上的强引用表，若不注销，监听器（及其所在子树）
     *               会一直存活，且音频线程每帧仍会遍历该槽。释放后本对象不应再使用。
     *
     * @brief[en] Releases the listener: unregisters it from the
     * audio context transform-slot registry
     * @explain[en] The registry is a strong-reference table on the singleton. Without
     *               unregistering, the listener (and its subtree) stays alive and the audio
     *               thread keeps iterating its slot every frame. Do not use the object afterwards.
     */
    public func release(): Bool {
        this.context.unregisterTransformSlot(this._slot)
        return true
    }

    /**
     * @brief[zh-cn] 设置主音量
     * @param[zh-cn] value 目标音量（0.0 = 静音，1.0 = 原始音量）
     * @note[zh-cn] 上下文已初始化时通过 postAudio 异步下发 AL_GAIN 到 OpenAL 监听器（不阻塞调用方）。
     *
     * @brief[en] Sets the master volume
     * @param[en] value Target volume (0.0 = mute, 1.0 = unity)
     * @note[en] When the context is initialized, the AL_GAIN is pushed to the OpenAL
     * listener asynchronously via postAudio (never blocks the caller).
     */
    public func setMasterVolume(value: Float64): Unit {
        this.gain = value
        if (this.context.initialized) {
            let g = Float32(value)
            this.context.postAudio({ => alListenerf_cj(AL_GAIN, g) })
        }
    }

    /**
     * @brief[zh-cn] 重写 updateMatrixWorld，将世界变换同步到 OpenAL 监听器
     * @param[zh-cn] force 是否强制更新世界矩阵
     * @note[zh-cn] 从 matrixWorld 分解位置和朝向，转换到 OpenAL 右手坐标系后写入变换槽；
     * 音频线程在下一轮循环中把脏槽下发到监听器，渲染线程不产生任何阻塞等待。
     * 左手系 → 右手系转换：
     * - 位置: (x, y, z) → (x, y, -z)
     * - 前方向(at): (x, y, z) → (x, y, -z)
     * - 上方向(up): (upX, upY, upZ) → (upX, upY, -upZ)
     *
     * @brief[en] Overrides updateMatrixWorld to sync the world transform to the OpenAL listener
     * @param[en] force Whether to force updating the world matrix
     * @note[en] Decomposes the position and orientation from matrixWorld, converts them to
     * the OpenAL right-handed system and writes them into the transform slot; the audio
     * thread submits dirty slots to the listener in its next loop iteration, so the
     * render thread never blocks.
     * LH → RH conversion:
     * - Position: (x, y, z) → (x, y, -z)
     * - Forward (at): (x, y, z) → (x, y, -z)
     * - Up: (upX, upY, upZ) → (upX, upY, -upZ)
     */
    @Zone[three.audio.listener.AudioListener.updateMatrixWorld, name=audioListenerUpdate]
    public override func updateMatrixWorld(force: Bool): Unit {
        super.updateMatrixWorld(force)

        if (!this.context.initialized) { return }

        let te = this.matrixWorld.elements

        // 从世界矩阵提取位置（左手系 → OpenAL 右手系：翻转 Z）
        let px = Float32(te[12])
        let py = Float32(te[13])
        let pz = Float32(-te[14])

        // 从世界矩阵提取朝向
        // 左手系中 Object3D 的 -Z 方向为"前方向"（与相机一致）
        // matrixWorld 的列向量：col0=right, col1=up, col2=forward(LH: +Z)
        // 在本引擎左手系中，getWorldDirection 返回 +Z 方向
        // 但对于监听器"看向"的方向，应该取 -Z（与相机 lookAt 一致）
        // forward 在左手系 = (te[8], te[9], te[10])
        // up 在左手系 = (te[4], te[5], te[6])

        // 前方向（LH +Z → RH -Z 方向翻转）
        let atX = Float32(te[8])
        let atY = Float32(te[9])
        let atZ = Float32(-te[10])

        // 上方向（LH +Z → RH -Z 方向翻转）
        let upX = Float32(te[4])
        let upY = Float32(te[5])
        let upZ = Float32(-te[6])

        // 异步提交：只写槽内字段并置脏，音频线程负责下发 OpenAL
        this.context.postTransform(
            this._slot,
            px, py, pz,
            atX, atY, atZ,
            upX, upY, upZ,
            Float32(this.gain)
        )
    }
}
