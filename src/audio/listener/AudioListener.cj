/**
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
public open class AudioListener <: Object3D {
    /**
     * @brief[zh-cn] 音频上下文引用
     *
     * @brief[en] The audio context reference
     */
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
        this.kind = "AudioListener"
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
     * @brief[zh-cn] 设置主音量
     * @param[zh-cn] value 目标音量（0.0 = 静音，1.0 = 原始音量）
     *
     * @brief[en] Sets the master volume
     * @param[en] value Target volume (0.0 = mute, 1.0 = unity)
     *
     * @note[zh-cn] 上下文已初始化时同步通过 execAudio 下发 AL_GAIN 到 OpenAL 监听器。
     * @note[en] When the context is initialized, the AL_GAIN is pushed to the OpenAL
     * listener synchronously via execAudio.
     */
    public func setMasterVolume(value: Float64): Unit {
        this.gain = value
        if (this.context.initialized) {
            let g = Float32(value)
            this.context.execAudio({ => alListenerf_cj(AL_GAIN, g) })
        }
    }

    /**
     * @brief[zh-cn] 重写 updateMatrixWorld，将世界变换同步到 OpenAL 监听器
     * @param[zh-cn] force 是否强制更新世界矩阵
     *
     * @brief[en] Overrides updateMatrixWorld to sync the world transform to the OpenAL listener
     * @param[en] force Whether to force updating the world matrix
     *
     * @note[zh-cn] 从 matrixWorld 分解位置和朝向，转换到 OpenAL 右手坐标系后设置到监听器。
     * 左手系 → 右手系转换：
     * - 位置: (x, y, z) → (x, y, -z)
     * - 前方向(at): (x, y, z) → (x, y, -z)
     * - 上方向(up): (upX, upY, upZ) → (upX, upY, -upZ)
     * @note[en] Decomposes the position and orientation from matrixWorld, converts them to
     * the OpenAL right-handed system and applies them to the listener.
     * LH → RH conversion:
     * - Position: (x, y, z) → (x, y, -z)
     * - Forward (at): (x, y, z) → (x, y, -z)
     * - Up: (upX, upY, upZ) → (upX, upY, -upZ)
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        super.updateMatrixWorld(force)

        if (!this.context.initialized) { return }

        let te = this.matrixWorld.elements

        // 从世界矩阵提取位置（左手系）
        let px = te[12]
        let py = te[13]
        let pz = te[14]

        // 从世界矩阵提取朝向
        // 左手系中 Object3D 的 -Z 方向为"前方向"（与相机一致）
        // matrixWorld 的列向量：col0=right, col1=up, col2=forward(LH: +Z)
        // 在 Three.js 左手系中，getWorldDirection 返回 +Z 方向
        // 但对于监听器"看向"的方向，应该取 -Z（与相机 lookAt 一致）
        // forward 在左手系 = (te[8], te[9], te[10])
        // up 在左手系 = (te[4], te[5], te[6])

        // 转换到 OpenAL 右手系：翻转 Z
        let atX = Float32(te[8])
        let atY = Float32(te[9])
        let atZ = Float32(-te[10])   // LH +Z → RH -Z 方向翻转

        let upX = Float32(te[4])
        let upY = Float32(te[5])
        let upZ = Float32(-te[6])    // LH +Z → RH -Z 方向翻转

        // 设置监听器位置（LH → RH: z 翻转）
        let posBuf = unsafe { LibC.malloc<Float32>(count: 3) }
        unsafe {
            posBuf.write(Float32(px))
            (posBuf + 1).write(Float32(py))
            (posBuf + 2).write(Float32(-pz))  // LH → RH: z 翻转
        }

        // 设置监听器朝向 [atX, atY, atZ, upX, upY, upZ]
        let orientBuf = unsafe { LibC.malloc<Float32>(count: 6) }
        unsafe {
            orientBuf.write(atX)
            (orientBuf + 1).write(atY)
            (orientBuf + 2).write(atZ)
            (orientBuf + 3).write(upX)
            (orientBuf + 4).write(upY)
            (orientBuf + 5).write(upZ)
        }

        let gainVal = Float32(this.gain)
        // 三个监听器属性在单次 execAudio 闭包内提交，减少线程往返
        this.context.execAudio({ =>
            alListenerfv_cj(AL_POSITION, posBuf)
            alListenerfv_cj(AL_ORIENTATION, orientBuf)
            alListenerf_cj(AL_GAIN, gainVal)
        })

        unsafe { LibC.free(posBuf) }
        unsafe { LibC.free(orientBuf) }
    }
}
