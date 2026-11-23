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
 * @file[zh-cn] scene_entity_lod LOD 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.LOD 绑定为 Lua 类型 three.scene.entity.LOD
 * @explain[zh-cn] 覆盖构造、属性 autoUpdate/hysteresis/levels（只读）/levelsJson（JSON 字符串
 * 读写）、addLevel（distance 可选）、getObjectForDistance、setCurrentLevel、getCurrentLevel、
 * removeLevel、update（相机）、visibleAtDistance、release、copy、clone。绑定层适配：
 * levels 为 ArrayList<(Object3D, Float64)> 元组数组，只读暴露为
 * {{object, distance}, ...}，setter 跳过；getObjectForDistance 的结果按
 * three.scene.objects.Object3D 注册；copy 返回自身；clone 返回新 LOD。
 * 跳过私有字段 _currentLevel（经 getCurrentLevel/setCurrentLevel 访问）；
 * 异常经 try/catch 吞掉后返回 nil/false/0。
 *
 * @file[en] scene_entity_lod  Lua binding of LOD (three.script.prebind)
 * @brief[en] Binds three.scene.entity.LOD as the Lua type three.scene.entity.LOD
 * @explain[en] Covers construction, props autoUpdate/hysteresis/levels (read-only)/levelsJson
 * (JSON string read-write), addLevel (optional distance), getObjectForDistance, setCurrentLevel,
 * getCurrentLevel, removeLevel, update (camera), visibleAtDistance, release, copy, clone.
 * Binding adaptations: levels is an ArrayList<(Object3D, Float64)> tuple array, exposed read-only
 * as {{object, distance}, ...} with no setter; getObjectForDistance results are registered as
 * three.scene.objects.Object3D; copy returns self; clone returns a new LOD. The private
 * _currentLevel field is skipped (use getCurrentLevel/setCurrentLevel); exceptions are swallowed
 * and yield nil / false / 0.
 */
package three.script.prebind

import three.scene.entity.*
import three.scene.objects.*
import three.renderers.cameras.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LOD 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.LOD）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LOD
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.LOD)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLOD(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.LOD")
    // ===== 构造 =====
    b.constructor {_ => LOD()}
    // ===== 属性 =====
    b.property("autoUpdate", getter: Some({ref => LuaValue.of(ref.cast<LOD>().autoUpdate)}),
        setter: Some({ref, v => ref.cast<LOD>().autoUpdate = v.boolValue()}))
    b.property("hysteresis", getter: Some({ref => LuaValue.of(ref.cast<LOD>().hysteresis)}),
        setter: Some({ref, v => ref.cast<LOD>().hysteresis = v.numberValue()}))
    // levels：元组数组，只读暴露为 {{object, distance}, ...}
    b.property(
        "levels",
        getter: Some(
            {
                ref =>
                    let levels = ref.cast<LOD>().levels
                    let arr = Array<LuaValue>(levels.size, {
                        i => LuaValue.Array(
                            [
                                prebindRegister(levels[i][0], "three.scene.objects.Object3D"),
                                LuaValue.of(levels[i][1])
                            ]
                        )
                    })
                    LuaValue.of(arr)
            }
        )
    )
    b.property("levelsJson", getter: Some({ref => LuaValue.of(ref.cast<LOD>().levelsJson)}),
        setter: Some({ref, v => ref.cast<LOD>().levelsJson = v.stringValue()}))
    // ===== 层级维护 =====
    b.method("addLevel") {
        ref, args =>
            ref.cast<LOD>().addLevel(prebindAs<Object3D>(args, 0), distance: prebindNum(args, 1, default: 0.0))
            []
    }
    b.method("removeLevel") {
        ref, args =>
            var ok = false
            try {
                ok = ref.cast<LOD>().removeLevel(prebindNum(args, 0))
            } catch (_) {
                ok = false
            }
            [LuaValue.of(ok)]
    }
    b.method("getObjectForDistance") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<LOD>().getObjectForDistance(prebindNum(args, 0)),
                    "three.scene.objects.Object3D")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.method("setCurrentLevel") {
        ref, args =>
            ref.cast<LOD>().setCurrentLevel(prebindInt(args, 0))
            []
    }
    b.method("getCurrentLevel") {
        ref, _ => [LuaValue.of(ref.cast<LOD>().getCurrentLevel())]
    }
    // ===== 相机更新 / 可见性 =====
    b.method("update") {
        ref, args =>
            try {
                ref.cast<LOD>().update(prebindAs<Camera>(args, 0))
            } catch (_) {
                // 相机缺失或更新失败：忽略，不向 Lua 抛出
            }
            []
    }
    b.method("visibleAtDistance") {
        ref, args =>
            var out = false
            try {
                out = ref.cast<LOD>().visibleAtDistance(prebindNum(args, 0))
            } catch (_) {
                out = false
            }
            [LuaValue.of(out)]
    }
    // ===== 资源释放 / 复制 =====
    b.method("release") {
        ref, _ =>
            var ok = false
            try {
                ok = ref.cast<LOD>().release()
            } catch (_) {
                ok = false
            }
            [LuaValue.of(ok)]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<LOD>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<LOD>().clone(), "three.scene.entity.LOD")]
    }
    b.install(vm)
}
