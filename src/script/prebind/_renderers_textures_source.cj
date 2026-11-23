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
 * @file[zh-cn] renderers_textures_source 贴图数据源 Source 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.Source 绑定为 Lua 类型
 * three.renderers.textures.Source
 * @explain[zh-cn] 覆盖构造（data / width / height，均为命名可选参数，Lua 按位置传入前 N 个）、
 * data（Lua 数值表 ↔ Array<UInt8>）、width / height / version / needsUpdate / dataReady /
 * kind 属性，以及 getSize（返回 width/height 的 Lua 数组）。
 *
 * @file[en] renderers_textures_source  Lua binding of the texture data source Source
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.Source as the Lua type
 * three.renderers.textures.Source
 * @explain[en] Covers the constructor (data / width / height, all named optional parameters, Lua
 * passes the first N positionally), the data property (Lua number table <-> Array<UInt8>),
 * width / height / version / needsUpdate / dataReady / kind, and getSize (a Lua array with
 * width/height).
 */
package three.script.prebind

import three.renderers.textures.Source
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Source 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.Source）
 *
 * @brief[en] Installs the Lua binding of Source
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.Source)
 */
public func installTextureSource(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.Source")
    // ===== 构造（命名可选参数，Lua 按位置传入前 N 个） =====
    b.constructor {
        args => Source(data: prebindBytes(vm, args, 0), width: prebindInt(args, 1), height: prebindInt(args, 2))
    }
    // ===== 属性 =====
    b.property("data", getter: Some({ref => prebindBytesToLua(ref.cast<Source>().data)}),
        setter: Some({ref, v => ref.cast<Source>().data = prebindBytes(vm, [v], 0)}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<Source>().width)}),
        setter: Some({ref, v => ref.cast<Source>().width = v.intValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<Source>().height)}),
        setter: Some({ref, v => ref.cast<Source>().height = v.intValue()}))
    b.property("version", getter: Some({ref => LuaValue.of(ref.cast<Source>().version)}),
        setter: Some({ref, v => ref.cast<Source>().version = v.intValue()}))
    b.property("needsUpdate", getter: Some({ref => LuaValue.of(ref.cast<Source>().needsUpdate)}),
        setter: Some({ref, v => ref.cast<Source>().needsUpdate = v.boolValue()}))
    b.property("dataReady", getter: Some({ref => LuaValue.of(ref.cast<Source>().dataReady)}),
        setter: Some({ref, v => ref.cast<Source>().dataReady = v.boolValue()}))
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<Source>().kind)}),
        setter: Some({ref, v => ref.cast<Source>().kind = v.stringValue()}))
    // ===== 尺寸 =====
    b.method("getSize") {
        ref, _ =>
            let size = ref.cast<Source>().getSize()
            [LuaValue.of(size[0]), LuaValue.of(size[1])]
    }
    b.install(vm)
}
