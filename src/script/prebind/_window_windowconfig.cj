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
 * @file[zh-cn] window_windowconfig 窗口创建配置的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 WindowConfig 绑定为 Lua 类型 three.window.WindowConfig
 * @explain[zh-cn] 无参构造 + 全部 public 字段（可读写属性）。Lua 侧用法：
 *   local cfg = three.window.WindowConfig.new()
 *   cfg.resizable = false
 *   cfg.width/height 等尺寸字段由 WindowEngine.start 的 width/height 参数提供，
 *   此处只承载创建标志、透明度与最小/最大尺寸。
 *
 * @file[en] window_windowconfig  Lua binding of the window creation config (three.script.prebind)
 * @brief[en] Binds WindowConfig as the Lua type three.window.WindowConfig
 * @explain[en] No-arg construction plus every public field (read-write properties). Lua usage:
 *   local cfg = three.window.WindowConfig.new()
 *   cfg.resizable = false
 * The width/height of the window come from WindowEngine.start's width/height arguments; this
 * config only carries creation flags, opacity and the minimum/maximum size limits.
 */
package three.script.prebind

import three.window.WindowConfig
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 WindowConfig 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.WindowConfig）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of WindowConfig
 * @param[en] vm The target virtual machine (class table installed at three.window.WindowConfig)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installWindowConfig(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.WindowConfig")
    b.constructor {_ => WindowConfig()}
    b.property("resizable", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().resizable)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().resizable = v.boolValue()}))
    b.property("fullscreen", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().fullscreen)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().fullscreen = v.boolValue()}))
    b.property("borderless", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().borderless)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().borderless = v.boolValue()}))
    b.property("alwaysOnTop", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().alwaysOnTop)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().alwaysOnTop = v.boolValue()}))
    b.property("highPixelDensity", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().highPixelDensity)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().highPixelDensity = v.boolValue()}))
    b.property("opacity", getter: Some({ref => LuaValue.of(Float64(ref.cast<WindowConfig>().opacity))}),
        setter: Some({ref, v => ref.cast<WindowConfig>().opacity = Float32(v.numberValue())}))
    b.property("minWidth", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowConfig>().minWidth))}),
        setter: Some({ref, v => ref.cast<WindowConfig>().minWidth = Int32(v.intValue())}))
    b.property("minHeight", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowConfig>().minHeight))}),
        setter: Some({ref, v => ref.cast<WindowConfig>().minHeight = Int32(v.intValue())}))
    b.property("maxWidth", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowConfig>().maxWidth))}),
        setter: Some({ref, v => ref.cast<WindowConfig>().maxWidth = Int32(v.intValue())}))
    b.property("maxHeight", getter: Some({ref => LuaValue.of(Int64(ref.cast<WindowConfig>().maxHeight))}),
        setter: Some({ref, v => ref.cast<WindowConfig>().maxHeight = Int32(v.intValue())}))
    b.property("enableGui", getter: Some({ref => LuaValue.of(ref.cast<WindowConfig>().enableGui)}),
        setter: Some({ref, v => ref.cast<WindowConfig>().enableGui = v.boolValue()}))
    b.install(vm)
}
