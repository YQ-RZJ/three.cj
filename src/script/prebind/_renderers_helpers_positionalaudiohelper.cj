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
 * @file[zh-cn] renderers_helpers_positionalaudiohelper PositionalAudioHelper 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.PositionalAudioHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 audio / color：audio 为 PositionalAudio 对象时走带参构造，缺省走
 * 无参构造）、属性（audio / color / innerCone / outerCone / refSphere / maxSphere /
 * velocityArrow）与方法 update，以及 Object3D 与 IReleasable 成员。color 为 UInt32 十六进制值；
 * 锥体、球体与箭头均以已绑定类型往返。Lua 类表没有继承，本类绑定在 b.install 之前复用 Object3D
 * 与 IReleasable 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_positionalaudiohelper  Lua binding of PositionalAudioHelper
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.PositionalAudioHelper as a Lua type
 * @explain[en] Binds the constructor (optional audio / color: a PositionalAudio first argument
 * selects the parameterized overload, otherwise the no-arg one), the properties (audio / color /
 * innerCone / outerCone / refSphere / maxSphere / velocityArrow) and update, plus the Object3D and
 * IReleasable members. color is a UInt32 hex value; the cones, spheres and arrow round-trip as bound
 * types. Lua class tables have no inheritance, so the Object3D and IReleasable members are reused
 * before b.install. Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.audio.source.PositionalAudio
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PositionalAudioHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.PositionalAudioHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PositionalAudioHelper
 * @param[en] vm The target virtual machine
 * (class table at three.renderers.helpers.PositionalAudioHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPositionalAudioHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.PositionalAudioHelper")
    // ===== 构造：可选 audio / color（无 audio 时走无参构造） =====
    b.constructor {
        args => if (args.size > 0 && args[0].isObject) {
            PositionalAudioHelper(prebindAs<PositionalAudio>(args, 0),
                color: _prebindHlpHexArg(args, 1, default: 0xffff00))
        } else {
            PositionalAudioHelper()
        }
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 位置音频辅助自有成员 =====
    b.property("audio", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().audio, "three.audio.source.PositionalAudio")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().audio = prebindAsValue<PositionalAudio>(v)
    }))
    b.property("color", getter: Some({ref => LuaValue.of(Float64(ref.cast<PositionalAudioHelper>().color))}),
        setter: Some({
            ref, v => ref.cast<PositionalAudioHelper>().color = UInt32(v.intValue())
        }))
    b.property("innerCone", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().innerCone, "three.scene.entity.LineSegments")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().innerCone = prebindAsValue<LineSegments>(v)
    }))
    b.property("outerCone", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().outerCone, "three.scene.entity.LineSegments")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().outerCone = prebindAsValue<LineSegments>(v)
    }))
    b.property("refSphere", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().refSphere, "three.scene.entity.Mesh")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().refSphere = prebindAsValue<Mesh>(v)
    }))
    b.property("maxSphere", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().maxSphere, "three.scene.entity.Mesh")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().maxSphere = prebindAsValue<Mesh>(v)
    }))
    b.property("velocityArrow", getter: Some({
        ref => prebindRegister(ref.cast<PositionalAudioHelper>().velocityArrow, "three.renderers.helpers.ArrowHelper")
    }), setter: Some({
        ref, v => ref.cast<PositionalAudioHelper>().velocityArrow = prebindAsValue<ArrowHelper>(v)
    }))
    b.method("update") {
        ref, _ =>
            ref.cast<PositionalAudioHelper>().update()
            []
    }
    b.install(vm)
}
