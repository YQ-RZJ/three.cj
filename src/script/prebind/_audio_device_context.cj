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
 * @file[zh-cn] audio_device_context 音频上下文与变换槽的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.audio.device.AudioContext / AudioTransformSlot 绑定为 Lua 类型
 * @explain[zh-cn] AudioContext 为私有构造单例，Lua 侧通过静态方法 instance() 取得实例
 * （每次调用都会把同一对象登记为新 id，供属性/方法访问）；绑定 initialized/releasable
 * 只读属性、initialize/release、getError、多普勒三项设置、HRTF 系列查询与选择、
 * 变换槽注册/注销/postTransform。
 * execAudio / postAudio 的仓颉签名是 () -> Unit 闭包，Lua 侧以 Lua 函数传入。
 * 关键约束：LuaJIT 的 lua_State 非线程安全，回调**不能**在音频线程执行，
 * 因此二者按下列可观察语义映射（详见 LuaDeferredCallbackQueue）：
 * - execAudio(fn)：先抽干延迟队列（保持 FIFO），再做一次同步屏障
 *   （空闭包 execAudio，等音频线程执行完此前全部命令），最后在**当前 Lua 线程**执行 fn；
 *   成功返回 true，入参非法或回调自身出错返回 false（**不抛异常**，避免 lua_error
 *   的 longjmp 跨仓颉栈帧破坏运行时状态）；
 * - postAudio(fn)：投递即返回，fn 进入延迟队列，由 pumpAudioCallbacks 或下一次 execAudio
 *   在 Lua 线程执行；入队成功返回 true，入参非法返回 false；
 * - pumpAudioCallbacks()：先同步屏障，再返回本次执行的条数；
 * - pendingAudioCallbacks：待执行回调数量（只读）。
 * 未调用 initialize（音频上下文未初始化）时跳过同步屏障，仅执行回调。
 * device 属性是 CPointer<Unit>，无法映射到 Lua，不绑定（原始 OpenAL 调用只在仓颉侧使用）。
 * AudioTransformSlot 为纯数据类：无参构造 + 11 个可读写字段（sourceId/isListener/
 * px,py,pz/ox,oy,oz/ux,uy,uz/gain）；invalidate 为 protected，不绑定。
 *
 * @file[en] audio_device_context  Lua bindings of the audio context and transform slot
 * (three.script.prebind)
 * @brief[en] Binds three.audio.device.AudioContext / AudioTransformSlot as Lua types
 * @explain[en] AudioContext is a singleton with a private constructor, so Lua obtains it
 * through the static method instance() (each call registers the same object under a fresh
 * id for property/method access); initialized/releasable read-only properties,
 * initialize/release, getError, the three Doppler settings, the HRTF query/selection
 * family and transform-slot register/unregister/postTransform are bound.
 * execAudio / postAudio take a () -> Unit closure in Cangjie; on the Lua side they accept a
 * Lua function. Hard constraint: the LuaJIT lua_State is not thread-safe, so callbacks must
 * **not** run on the audio thread. Both are therefore mapped to these observable semantics
 * (see LuaDeferredCallbackQueue):
 * - execAudio(fn): drain the deferred queue first (FIFO), then take a synchronous barrier
 *   (an empty-closure execAudio that waits for every earlier command), and finally run fn on
 *   the **current Lua thread**; returns true on success, false when the argument is invalid or
 *   the callback itself fails (**never throws**, to avoid lua_error's longjmp crossing Cangjie
 *   stack frames and corrupting runtime state);
 * - postAudio(fn): returns immediately; fn goes to the deferred queue and runs on the Lua
 *   thread from pumpAudioCallbacks or the next execAudio; returns true when enqueued, false
 *   for an invalid argument;
 * - pumpAudioCallbacks(): takes the barrier, then returns how many callbacks ran;
 * - pendingAudioCallbacks: the read-only pending count.
 * When the context is not initialized the barrier is skipped and only callbacks run.
 * The device property is a CPointer<Unit> with no Lua mapping and stays unbound (raw OpenAL
 * calls stay on the Cangjie side). AudioTransformSlot is a plain data class: the
 * parameterless constructor plus 11 mutable fields (sourceId/isListener/px,py,pz/ox,oy,oz/
 * ux,uy,uz/gain); invalidate is protected and not bound.
 */
package three.script.prebind

import three.audio.device.AudioContext
import three.audio.device.AudioTransformSlot
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选的音频上下文参数（缺省 / nil / 非对象 → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(AudioContext) 或 None（None 表示使用 AudioContext.context 单例）
 *
 * @brief[en] Reads an optional audio-context argument (absent / nil / non-object → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(AudioContext), or None meaning the AudioContext.context singleton
 */
internal func _prebindOptAudioContext(args: Array<LuaValue>, idx: Int64): Option<AudioContext> {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return None
    }
    return Some(LuaObjectRegistry.getAs<AudioContext>(args[idx].objectId()))
}

/**
 * @brief[zh-cn] 取可选音频上下文参数（缺省 / nil / 非对象 → AudioContext.context 单例）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 目标音频上下文
 *
 * @brief[en] Resolves an optional audio-context argument (absent / nil / non-object →
 * the AudioContext.context singleton)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The target audio context
 */
internal func _prebindEffectCtx(args: Array<LuaValue>, idx: Int64): AudioContext {
    if (let Some(ctx) <- _prebindOptAudioContext(args, idx)) {
        return ctx
    }
    return AudioContext.context
}

/**
 * @brief[zh-cn] 读取音频回调参数（Lua 函数经 LuaCallback 包装；非法入参返回 None）
 * @explain[zh-cn] 这里刻意**不抛异常**：绑定方法抛异常会让分派层调用 lua_error 做 longjmp，
 * 而 longjmp 跨过仓颉栈帧会导致运行时栈状态失配（表现为后续随机位置访问冲突）。
 * 因此非法入参一律以返回值 false 告知 Lua 侧，由脚本自行判断。
 * @param[zh-cn] vm 所属虚拟机
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 包装后的 Lua 回调；参数缺失 / 非函数 / VM 已关闭时返回 None
 *
 * @brief[en] Reads an audio callback argument (Lua function wrapped into LuaCallback; None when invalid)
 * @explain[en] This deliberately **does not throw**: an exception from a binding method makes the
 * dispatch layer call lua_error, whose longjmp crosses Cangjie stack frames and leaves the runtime
 * stack state inconsistent (observed as random later access violations). Invalid input is therefore
 * reported to Lua as a false return value instead.
 * @param[en] vm The owning virtual machine
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The wrapped Lua callback; None when the argument is missing, not a function, or the VM is closed
 */
internal func _prebindOptAudioCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Option<LuaCallback> {
    if (args.size <= idx) {
        return None
    }
    return LuaCallback.fromValue(vm, args[idx])
}

/**
 * @brief[zh-cn] AudioContext.postAudio 的 Lua 延迟回调队列（进程内单例）
 * @explain[zh-cn] 工作线程不得直接调用 Lua，postAudio 只入队；由 Lua 线程经
 * pumpAudioCallbacks / execAudio 抽干执行。
 *
 * @brief[en] The Lua deferred callback queue backing AudioContext.postAudio (process-wide)
 * @explain[en] Worker threads never call Lua directly: postAudio only enqueues, and the Lua
 * thread drains it through pumpAudioCallbacks / execAudio.
 */
private let _audioLuaCallbacks: LuaDeferredCallbackQueue = LuaDeferredCallbackQueue()

/**
 * @brief[zh-cn] 安装 AudioContext 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.device.AudioContext）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioContext
 * @param[en] vm The target virtual machine (class table installed at three.audio.device.AudioContext)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioContext(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.device.AudioContext")
    // ===== 单例入口（私有构造，Lua 侧无 new） =====
    b.staticMethod("instance") {
        _ => [prebindRegister(AudioContext.context, "three.audio.device.AudioContext")]
    }
    // ===== 属性（只读） =====
    b.property("initialized", getter: Some({ref => LuaValue.of(ref.cast<AudioContext>().initialized)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioContext>().releasable)}))
    // ===== 生命周期 =====
    b.method("initialize") {
        ref, _ => [LuaValue.of(ref.cast<AudioContext>().initialize())]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioContext>().release())]
    }
    b.method("getError") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioContext>().getError()))]
    }
    // ===== 全局多普勒设置 =====
    b.method("setDopplerFactor") {
        ref, args =>
            ref.cast<AudioContext>().setDopplerFactor(Float32(prebindNum(args, 0, default: 1.0)))
            Array<LuaValue>()
    }
    b.method("setDopplerVelocity") {
        ref, args =>
            ref.cast<AudioContext>().setDopplerVelocity(Float32(prebindNum(args, 0, default: 1.0)))
            Array<LuaValue>()
    }
    b.method("setSpeedOfSound") {
        ref, args =>
            ref.cast<AudioContext>().setSpeedOfSound(Float32(prebindNum(args, 0, default: 343.3)))
            Array<LuaValue>()
    }
    // ===== HRTF（ALC_SOFT_HRTF 扩展） =====
    b.method("setHrtfEnabled") {
        ref, args =>
            ref.cast<AudioContext>().setHrtfEnabled(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("getHrtfStatus") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioContext>().getHrtfStatus()))]
    }
    b.method("getHrtfCount") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioContext>().getHrtfCount()))]
    }
    b.method("getHrtfName") {
        ref, args => [LuaValue.of(ref.cast<AudioContext>().getHrtfName(Int32(prebindInt(args, 0))))]
    }
    b.method("getHrtfList") {
        ref, _ =>
            let list = ref.cast<AudioContext>().getHrtfList()
            var out = Array<String>(list.size, {_ => ""})
            var i: Int64 = 0
            for (name in list) {
                out[i] = name
                i += 1
            }
            [LuaValue.of(out)]
    }
    b.method("selectHrtf") {
        ref, args =>
            ref.cast<AudioContext>().selectHrtf(Int32(prebindInt(args, 0, default: -1)))
            Array<LuaValue>()
    }
    // ===== 变换槽注册 / 异步下发 =====
    b.method("registerTransformSlot") {
        ref, args =>
            ref.cast<AudioContext>().registerTransformSlot(prebindAs<AudioTransformSlot>(args, 0))
            Array<LuaValue>()
    }
    b.method("unregisterTransformSlot") {
        ref, args =>
            ref.cast<AudioContext>().unregisterTransformSlot(prebindAs<AudioTransformSlot>(args, 0))
            Array<LuaValue>()
    }
    b.method("postTransform") {
        ref, args =>
            ref
                .cast<AudioContext>()
                .postTransform(prebindAs<AudioTransformSlot>(args, 0), Float32(prebindNum(args, 1)),
                    Float32(prebindNum(args, 2)), Float32(prebindNum(args, 3)), Float32(prebindNum(args, 4)),
                    Float32(prebindNum(args, 5)), Float32(prebindNum(args, 6)), Float32(prebindNum(args, 7)),
                    Float32(prebindNum(args, 8)), Float32(prebindNum(args, 9)),
                    Float32(prebindNum(args, 10, default: 1.0)))
            Array<LuaValue>()
    }
    // ===== Lua 回调投递（音频线程安全映射，见文件头 @explain） =====
    // 入参非法时返回 false（不抛异常，避免 lua_error 的 longjmp 破坏仓颉栈）；
    // 成功执行返回 true。
    b.method("execAudio") {
        ref, args =>
            let ctx = ref.cast<AudioContext>()
            if (let Some(cb) <- _prebindOptAudioCallback(vm, args, 0)) {
                var ok = false
                try {
                    // 1. 先执行已投递的延迟回调（保持与 postAudio 的 FIFO 顺序）
                    _audioLuaCallbacks.drain()
                    // 2. 空闭包 = 同步屏障：等音频线程把此前命令全部执行完（未初始化则无事可等）
                    if (ctx.initialized) {
                        ctx.execAudio({=> ()})
                    }
                    // 3. 回到当前 Lua 线程执行回调
                    cb.call()
                    ok = true
                } catch (_) {
                    // 回调自身出错：仅报告失败，不向 Lua 抛错
                    ok = false
                }
                cb.release()
                [LuaValue.Boolean(ok)]
            } else {
                [LuaValue.Boolean(false)]
            }
    }
    b.method("postAudio") {
        _, args => if (let Some(cb) <- _prebindOptAudioCallback(vm, args, 0)) {
            _audioLuaCallbacks.post(cb)
            [LuaValue.Boolean(true)]
        } else {
            [LuaValue.Boolean(false)]
        }
    }
    b.method("pumpAudioCallbacks") {
        ref, _ =>
            let ctx = ref.cast<AudioContext>()
            if (ctx.initialized) {
                ctx.execAudio({=> ()})
            }
            [LuaValue.of(_audioLuaCallbacks.drain())]
    }
    b.property("pendingAudioCallbacks", getter: Some({_ => LuaValue.of(_audioLuaCallbacks.size)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AudioTransformSlot 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.device.AudioTransformSlot）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioTransformSlot
 * @param[en] vm The target virtual machine (class table installed at three.audio.device.AudioTransformSlot)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioTransformSlot(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.device.AudioTransformSlot")
    b.constructor {_ => AudioTransformSlot()}
    // ===== 目标源标识 =====
    b.property("sourceId", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioTransformSlot>().sourceId))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().sourceId = UInt32(v.intValue())}))
    b.property("isListener", getter: Some({ref => LuaValue.of(ref.cast<AudioTransformSlot>().isListener)}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().isListener = v.boolValue()}))
    // ===== 位置 =====
    b.property("px", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().px))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().px = Float32(v.numberValue())}))
    b.property("py", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().py))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().py = Float32(v.numberValue())}))
    b.property("pz", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().pz))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().pz = Float32(v.numberValue())}))
    // ===== 朝向 / 方向 =====
    b.property("ox", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().ox))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().ox = Float32(v.numberValue())}))
    b.property("oy", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().oy))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().oy = Float32(v.numberValue())}))
    b.property("oz", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().oz))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().oz = Float32(v.numberValue())}))
    // ===== 上方向 / 速度 =====
    b.property("ux", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().ux))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().ux = Float32(v.numberValue())}))
    b.property("uy", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().uy))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().uy = Float32(v.numberValue())}))
    b.property("uz", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().uz))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().uz = Float32(v.numberValue())}))
    // ===== 主音量 =====
    b.property("gain", getter: Some({ref => LuaValue.of(Float64(ref.cast<AudioTransformSlot>().gain))}),
        setter: Some({ref, v => ref.cast<AudioTransformSlot>().gain = Float32(v.numberValue())}))
    b.install(vm)
}
