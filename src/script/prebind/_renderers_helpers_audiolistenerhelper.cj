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
 * @file[zh-cn] renderers_helpers_audiolistenerhelper AudioListenerHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.AudioListenerHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 listener / size：listener 为 AudioListener 对象时走带参构造，
 * 缺省走无参构造）、属性（listener / axes / forwardArrow / upArc）与方法 update，以及 Object3D
 * 与 IReleasable 成员。所有对象属性均以已绑定类型往返。Lua 类表没有继承，本类绑定在 b.install
 * 之前复用 Object3D 与 IReleasable 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_audiolistenerhelper  Lua binding of AudioListenerHelper
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.AudioListenerHelper as a Lua type
 * @explain[en] Binds the constructor (optional listener / size: an AudioListener first argument
 * selects the parameterized overload, otherwise the no-arg one), the properties (listener / axes /
 * forwardArrow / upArc) and update, plus the Object3D and IReleasable members. Every object
 * property round-trips as a bound type. Lua class tables have no inheritance, so the Object3D and
 * IReleasable members are reused before b.install. Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.audio.listener.AudioListener
import three.scene.objects.*
import three.scene.entity.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioListenerHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.AudioListenerHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioListenerHelper
 * @param[en] vm The target virtual machine
 * (class table at three.renderers.helpers.AudioListenerHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioListenerHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.AudioListenerHelper")
    // ===== 构造：可选 listener / size（无 listener 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            AudioListenerHelper(prebindAs<AudioListener>(args, 0), size: prebindNum(args, 1, default: 1.0))
        } else {
            AudioListenerHelper()
        }
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 监听器辅助自有成员 =====
    b.property("listener", getter: Some({
        ref => prebindRegister(ref.cast<AudioListenerHelper>().listener, "three.audio.listener.AudioListener")
    }), setter: Some({
        ref, v => ref.cast<AudioListenerHelper>().listener = prebindAsValue<AudioListener>(v)
    }))
    b.property("axes", getter: Some({
        ref => prebindRegister(ref.cast<AudioListenerHelper>().axes, "three.renderers.helpers.AxesHelper")
    }), setter: Some({
        ref, v => ref.cast<AudioListenerHelper>().axes = prebindAsValue<AxesHelper>(v)
    }))
    b.property("forwardArrow", getter: Some({
        ref => prebindRegister(ref.cast<AudioListenerHelper>().forwardArrow, "three.renderers.helpers.ArrowHelper")
    }), setter: Some({
        ref, v => ref.cast<AudioListenerHelper>().forwardArrow = prebindAsValue<ArrowHelper>(v)
    }))
    b.property("upArc", getter: Some({
        ref => prebindRegister(ref.cast<AudioListenerHelper>().upArc, "three.scene.entity.LineSegments")
    }), setter: Some({
        ref, v => ref.cast<AudioListenerHelper>().upArc = prebindAsValue<LineSegments>(v)
    }))
    b.method("update") {
        ref, _ =>
            ref.cast<AudioListenerHelper>().update()
            []
    }
    b.install(vm)
}
