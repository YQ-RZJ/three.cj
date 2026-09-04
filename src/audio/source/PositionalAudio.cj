/**
 * @file[zh-cn] PositionalAudio 3D 位置音频源
 * @brief[zh-cn] 在 Audio 基础上增加 3D 空间定位效果的位置音频
 * @explain[zh-cn] PositionalAudio 播放的声音具有 3D 空间定位效果，会根据音频源和
 * 监听者之间的距离和方向自动衰减和空间化。
 * 内部映射：
 * - Web Audio PannerNode → OpenAL Source 的位置属性 + 距离衰减模型
 * - PannerNode.distanceModel → alDistanceModel + AL_REFERENCE_DISTANCE /
 * AL_ROLLOFF_FACTOR / AL_MAX_DISTANCE
 * - PannerNode.coneInnerAngle / coneOuterAngle / coneOuterGain →
 * AL_CONE_INNER_ANGLE / AL_CONE_OUTER_ANGLE / AL_CONE_OUTER_GAIN
 *
 * @file[en] PositionalAudio 3D positional audio source
 * @brief[en] Positional audio that adds 3D spatialization on top of Audio
 * @explain[en] PositionalAudio plays sound with 3D spatial positioning; the sound is
 * automatically attenuated and spatialized based on the distance and
 * direction between the audio source and the listener.
 * Internal mapping:
 * - Web Audio PannerNode → OpenAL source position attributes + distance model
 * - PannerNode.distanceModel → alDistanceModel + AL_REFERENCE_DISTANCE /
 * AL_ROLLOFF_FACTOR / AL_MAX_DISTANCE
 * - PannerNode.coneInnerAngle / coneOuterAngle / coneOuterGain →
 * AL_CONE_INNER_ANGLE / AL_CONE_OUTER_ANGLE / AL_CONE_OUTER_GAIN
 *
 * @note[zh-cn] Three.cj 使用左手坐标系，OpenAL 使用右手坐标系，同步位置时需要翻转
 * Z 轴（LH → RH: z' = -z）。
 * @note[en] Three.cj uses a left-handed coordinate system while OpenAL is right-handed;
 * flip the Z axis when syncing positions (LH → RH: z' = -z).
 */
package three.audio.source

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import openalsoft4cj.al.*
import openalsoft4cj.alc.*

import three.audio.device.*
import three.audio.listener.*

/**
 * @brief[zh-cn] 3D 位置音频，继承 Audio
 * @explain[zh-cn] PositionalAudio 播放的声音具有 3D 空间定位效果，会根据音频源和
 * 监听者之间的距离和方向自动衰减和空间化。
 *
 * @brief[en] 3D positional audio extending Audio
 * @explain[en] PositionalAudio plays sound with 3D spatial positioning; the sound is
 * automatically attenuated and spatialized based on the distance and
 * direction between the audio source and the listener.
 *
 * @note[zh-cn] Three.cj 使用左手坐标系，OpenAL 使用右手坐标系，同步位置时需要翻转
 * Z 轴（LH → RH: z' = -z）。
 * @note[en] Three.cj uses a left-handed coordinate system while OpenAL is right-handed;
 * flip the Z axis when syncing positions (LH → RH: z' = -z).
 */
public open class PositionalAudio <: Audio {
    /**
     * @brief[zh-cn] 参考距离（音量开始衰减的距离），默认 1.0
     *
     * @brief[en] Reference distance (distance where attenuation begins), default 1.0
     */
    public var refDistance: Float64

    /**
     * @brief[zh-cn] 滚降因子（衰减速度），默认 1.0
     *
     * @brief[en] Rolloff factor (attenuation rate), default 1.0
     */
    public var rolloffFactor: Float64

    /**
     * @brief[zh-cn] 最大衰减距离（仅 linear 模型有效），默认 10000.0
     *
     * @brief[en] Maximum attenuation distance (only effective for the linear model), default 10000.0
     */
    public var maxDistance: Float64

    /**
     * @brief[zh-cn] 距离模型：0=None, 1=inverse, 2=inverseClamped, 3=linear, 4=linearClamped, 5=exponential, 6=exponentialClamped
     *
     * @brief[en] Distance model: 0=None, 1=inverse, 2=inverseClamped, 3=linear, 4=linearClamped, 5=exponential, 6=exponentialClamped
     */
    public var distanceModel: Int64

    /**
     * @brief[zh-cn] 方向性锥体内角（度），默认 360（全方向）
     *
     * @brief[en] Directional cone inner angle (degrees), default 360 (omnidirectional)
     */
    public var coneInnerAngle: Float64

    /**
     * @brief[zh-cn] 方向性锥体外角（度），默认 360
     *
     * @brief[en] Directional cone outer angle (degrees), default 360
     */
    public var coneOuterAngle: Float64

    /**
     * @brief[zh-cn] 方向性锥体外增益，默认 0
     *
     * @brief[en] Directional cone outer gain, default 0
     */
    public var coneOuterGain: Float64

    /**
     * @brief[zh-cn] 速度（m/s，世界坐标，用于多普勒效应；默认 0 = 无多普勒）
     *
     * @brief[en] Velocity (m/s, world space, used for the Doppler effect; default 0 = no Doppler)
     */
    public var velocity: Vector3

    /**
     * @brief[zh-cn] 创建 3D 位置音频源
     * @param[zh-cn] listener 关联的音频监听器
     *
     * @brief[en] Creates a 3D positional audio source
     * @param[en] listener The associated audio listener
     */
    public init(listener!: AudioListener) {
        // 仓颉：super 必须为构造器首条语句
        super(listener: listener)
        this.refDistance = 1.0
        this.rolloffFactor = 1.0
        this.maxDistance = 10000.0
        this.distanceModel = 2  // inverseClamped，对应 Three.js 默认 'inverse'
        this.coneInnerAngle = 360.0
        this.coneOuterAngle = 360.0
        this.coneOuterGain = 0.0
        this.velocity = Vector3()
        this.kind = "PositionalAudio"
    }

    /**
     * @brief[zh-cn] 重写：创建 OpenAL 源并绑定缓冲区，同时设置距离衰减参数
     * @explain[zh-cn] 在绑定缓冲区的同时设置距离衰减（AL_REFERENCE_DISTANCE /
     * AL_ROLLOFF_FACTOR / AL_MAX_DISTANCE）与方向性锥体（AL_CONE_INNER_ANGLE /
     * AL_CONE_OUTER_ANGLE / AL_CONE_OUTER_GAIN），并应用全局距离模型。
     *
     * @brief[en] Override: creates the OpenAL source and binds the buffer, also setting distance attenuation parameters
     * @explain[en] Along with binding the buffer, sets distance attenuation
     * (AL_REFERENCE_DISTANCE / AL_ROLLOFF_FACTOR / AL_MAX_DISTANCE) and the
     * directional cone (AL_CONE_INNER_ANGLE / AL_CONE_OUTER_ANGLE /
     * AL_CONE_OUTER_GAIN), and applies the global distance model.
     */
    protected override func _createSource(): Unit {
        if (!this.context.initialized) { return }

        match (this.buffer) {
            case Some(buf) =>
                let bufId = buf.bufferId
                let refDist = Float32(this.refDistance)
                let rolloff = Float32(this.rolloffFactor)
                let maxDist = Float32(this.maxDistance)
                let coneInner = Float32(this.coneInnerAngle)
                let coneOuter = Float32(this.coneOuterAngle)
                let coneOuterG = Float32(this.coneOuterGain)
                let modelIdx = this.distanceModel

                this.context.execAudio({ =>
                    // 生成源
                    let srcPtr = unsafe { LibC.malloc<UInt32>() }
                    alGenSources_cj(1, srcPtr)
                    let id = unsafe { srcPtr.read() }
                    unsafe { LibC.free(srcPtr) }

                    // 绑定缓冲区
                    alSourcei_cj(id, AL_BUFFER, Int32(bufId))

                    // 设置距离衰减参数（PannerNode 等价属性）
                    alSourcef_cj(id, AL_REFERENCE_DISTANCE, refDist)
                    alSourcef_cj(id, AL_ROLLOFF_FACTOR, rolloff)
                    alSourcef_cj(id, AL_MAX_DISTANCE, maxDist)
                    alSourcei_cj(id, AL_SOURCE_RELATIVE, 0)  // 绝对坐标

                    // 设置方向性锥体
                    alSourcef_cj(id, AL_CONE_INNER_ANGLE, coneInner)
                    alSourcef_cj(id, AL_CONE_OUTER_ANGLE, coneOuter)
                    alSourcef_cj(id, AL_CONE_OUTER_GAIN, coneOuterG)

                    this.sourceId = id
                })

                // 设置全局距离模型
                this._applyDistanceModel()
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 重写 updateMatrixWorld，将世界位置和朝向同步到 OpenAL 源
     * @param[zh-cn] force 是否强制更新
     * @explain[zh-cn] 从 matrixWorld 提取位置和朝向，转换到右手坐标系（翻转 Z 轴）后
     * 设置到源；速度用于多普勒效应。
     *
     * @brief[en] Overrides updateMatrixWorld to sync the world position and orientation to the OpenAL source
     * @param[en] force Whether to force the update
     * @explain[en] Extracts the position and orientation from matrixWorld, converts them
     * to the right-handed coordinate system (flip Z axis) and sets them on the
     * source; the velocity is used for the Doppler effect.
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        super.updateMatrixWorld(force)

        if (!this.context.initialized) { return }
        if (this.sourceId == 0u32) { return }

        let te = this.matrixWorld.elements

        // 从世界矩阵提取位置（左手系）
        let px = te[12]
        let py = te[13]
        let pz = te[14]

        // 转换到 OpenAL 右手系：翻转 Z
        let posBuf = unsafe { LibC.malloc<Float32>(count: 3) }
        unsafe {
            posBuf.write(Float32(px))
            (posBuf + 1).write(Float32(py))
            (posBuf + 2).write(Float32(-pz))  // LH → RH: z 翻转
        }

        // 从世界矩阵提取方向（左手系 +Z 方向），转换到右手系
        let dirBuf = unsafe { LibC.malloc<Float32>(count: 3) }
        unsafe {
            dirBuf.write(Float32(te[8]))    // forward x
            (dirBuf + 1).write(Float32(te[9]))   // forward y
            (dirBuf + 2).write(Float32(-te[10])) // forward z: LH → RH
        }

        // 速度（左手系 → 右手系: z 翻转，用于多普勒效应；默认 0 = 无多普勒）
        let velBuf = unsafe { LibC.malloc<Float32>(count: 3) }
        let vx = Float32(this.velocity.x)
        let vy = Float32(this.velocity.y)
        let vz = Float32(-this.velocity.z)  // LH → RH
        unsafe {
            velBuf.write(vx)
            (velBuf + 1).write(vy)
            (velBuf + 2).write(vz)
        }

        let srcId = this.sourceId
        // 三个源属性在单次 execAudio 闭包内提交，减少线程往返
        this.context.execAudio({ =>
            alSourcefv_cj(srcId, AL_POSITION, posBuf)
            alSourcefv_cj(srcId, AL_DIRECTION, dirBuf)
            alSourcefv_cj(srcId, AL_VELOCITY, velBuf)
        })

        unsafe { LibC.free(posBuf) }
        unsafe { LibC.free(dirBuf) }
        unsafe { LibC.free(velBuf) }
    }

    /**
     * @brief[zh-cn] 设置参考距离
     * @param[zh-cn] value 参考距离（音量开始衰减的距离）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the reference distance
     * @param[en] value Reference distance (distance where attenuation begins)
     * @return[en] this (for chaining)
     */
    public func setRefDistance(value: Float64): PositionalAudio {
        this.refDistance = value
        if (this.context.initialized && this.sourceId != 0u32) {
            alSourcef_cj(this.sourceId, AL_REFERENCE_DISTANCE, Float32(value))
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取参考距离
     * @return[zh-cn] 当前参考距离
     *
     * @brief[en] Returns the reference distance
     * @return[en] The current reference distance
     */
    public func getRefDistance(): Float64 {
        return this.refDistance
    }

    /**
     * @brief[zh-cn] 设置滚降因子
     * @param[zh-cn] value 滚降因子（衰减速度）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the rolloff factor
     * @param[en] value Rolloff factor (attenuation rate)
     * @return[en] this (for chaining)
     */
    public func setRolloffFactor(value: Float64): PositionalAudio {
        this.rolloffFactor = value
        if (this.context.initialized && this.sourceId != 0u32) {
            alSourcef_cj(this.sourceId, AL_ROLLOFF_FACTOR, Float32(value))
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取滚降因子
     * @return[zh-cn] 当前滚降因子
     *
     * @brief[en] Returns the rolloff factor
     * @return[en] The current rolloff factor
     */
    public func getRolloffFactor(): Float64 {
        return this.rolloffFactor
    }

    /**
     * @brief[zh-cn] 设置距离模型
     * @param[zh-cn] model 距离模型索引：
     * 0 = none, 1 = inverse, 2 = inverseClamped, 3 = linear,
     * 4 = linearClamped, 5 = exponential, 6 = exponentialClamped
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the distance model
     * @param[en] model Distance model index:
     * 0 = none, 1 = inverse, 2 = inverseClamped, 3 = linear,
     * 4 = linearClamped, 5 = exponential, 6 = exponentialClamped
     * @return[en] this (for chaining)
     */
    public func setDistanceModel(model: Int64): PositionalAudio {
        this.distanceModel = model
        this._applyDistanceModel()
        return this
    }

    /**
     * @brief[zh-cn] 获取距离模型
     * @return[zh-cn] 当前距离模型索引
     *
     * @brief[en] Returns the distance model
     * @return[en] The current distance model index
     */
    public func getDistanceModel(): Int64 {
        return this.distanceModel
    }

    /**
     * @brief[zh-cn] 设置最大距离
     * @param[zh-cn] value 最大衰减距离
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the maximum distance
     * @param[en] value Maximum attenuation distance
     * @return[en] this (for chaining)
     */
    public func setMaxDistance(value: Float64): PositionalAudio {
        this.maxDistance = value
        if (this.context.initialized && this.sourceId != 0u32) {
            let srcId = this.sourceId
            let v = Float32(value)
            this.context.execAudio({ => alSourcef_cj(srcId, AL_MAX_DISTANCE, v) })
        }
        return this
    }

    /**
     * @brief[zh-cn] 获取最大距离
     * @return[zh-cn] 当前最大衰减距离
     *
     * @brief[en] Returns the maximum distance
     * @return[en] The current maximum attenuation distance
     */
    public func getMaxDistance(): Float64 {
        return this.maxDistance
    }

    /**
     * @brief[zh-cn] 设置方向性锥体
     * @param[zh-cn] coneInnerAngle 内角（度）
     * coneOuterAngle 外角（度）
     * coneOuterGain 外角增益（0.0 ~ 1.0）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the directional cone
     * @param[en] coneInnerAngle Inner angle (degrees)
     * coneOuterAngle Outer angle (degrees)
     * coneOuterGain Outer angle gain (0.0 ~ 1.0)
     * @return[en] this (for chaining)
     */
    public func setDirectionalCone(coneInnerAngle!: Float64, coneOuterAngle!: Float64, coneOuterGain!: Float64): PositionalAudio {
        this.coneInnerAngle = coneInnerAngle
        this.coneOuterAngle = coneOuterAngle
        this.coneOuterGain = coneOuterGain
        this._applyDirectionalCone()
        return this
    }

    /**
     * @brief[zh-cn] 设置速度（m/s，世界坐标），启用多普勒效应
     * @param[zh-cn] v 速度向量（世界坐标，左手系）
     * @return[zh-cn] this（便于链式调用）
     *
     * @brief[en] Sets the velocity (m/s, world space) to enable the Doppler effect
     * @param[en] v Velocity vector (world space, left-handed)
     * @return[en] this (for chaining)
     *
     * @note[zh-cn] 还需设置全局多普勒因子（AudioContext.setDopplerFactor）才能听到效果；
     * 速度在每次 updateMatrixWorld 时同步到 AL_VELOCITY。
     * @note[en] You also need to set the global Doppler factor
     * (AudioContext.setDopplerFactor) to hear the effect; the velocity is
     * synced to AL_VELOCITY on every updateMatrixWorld.
     */
    public func setVelocity(v: Vector3): PositionalAudio {
        this.velocity = v
        return this
    }

    /**
     * @brief[zh-cn] 获取速度
     * @return[zh-cn] 当前速度向量
     *
     * @brief[en] Returns the velocity
     * @return[en] The current velocity vector
     */
    public func getVelocity(): Vector3 {
        return this.velocity
    }

    /**
     * 应用距离模型到全局
     */
    private func _applyDistanceModel(): Unit {
        if (!this.context.initialized) { return }
        let modelValue: UInt32 = match (this.distanceModel) {
            case 0 => DistanceModel.None.value()
            case 1 => DistanceModel.InverseDistance.value()
            case 2 => DistanceModel.InverseDistanceClamped.value()
            case 3 => DistanceModel.LinearDistance.value()
            case 4 => DistanceModel.LinearDistanceClamped.value()
            case 5 => DistanceModel.ExponentDistance.value()
            case 6 => DistanceModel.ExponentDistanceClamped.value()
            case _ => DistanceModel.InverseDistanceClamped.value()
        }
        this.context.execAudio({ => alDistanceModel_cj(modelValue) })
    }

    /**
     * 应用方向性锥体参数到源
     */
    private func _applyDirectionalCone(): Unit {
        if (!this.context.initialized) { return }
        if (this.sourceId == 0u32) { return }
        let srcId = this.sourceId
        let inner = Float32(this.coneInnerAngle)
        let outer = Float32(this.coneOuterAngle)
        let outerG = Float32(this.coneOuterGain)
        this.context.execAudio({ =>
            alSourcef_cj(srcId, AL_CONE_INNER_ANGLE, inner)
            alSourcef_cj(srcId, AL_CONE_OUTER_ANGLE, outer)
            alSourcef_cj(srcId, AL_CONE_OUTER_GAIN, outerG)
        })
    }
}
