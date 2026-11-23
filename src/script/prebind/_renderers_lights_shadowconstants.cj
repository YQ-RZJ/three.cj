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
 * @file[zh-cn] renderers_lights_shadowconstants 阴影常量 ShadowConstants 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights 包内 ShadowConstants.cj 的 public 顶层常量绑定为
 * Lua 命名空间 three.renderers.lights.ShadowConstants 上的静态方法
 * @explain[zh-cn] 常量文件没有类声明，仅含 public let 顶层常量；为便于脚本访问，统一挂到
 * three.renderers.lights.ShadowConstants 命名空间，以同名 staticMethod 暴露（Lua 侧按函数调用，
 * 如 ShadowConstants.BASIC_SHADOW_MAP()）。覆盖阴影贴图实现（BASIC/PCF/PCF_SOFT/VSM/PCSS/ESM）、
 * 分布类型（SM_TYPE_SINGLE/OMNI/CASCADE）、深度计算（DEPTH_IMPL_INVZ/LINEAR）、深度打包
 * （PACK_DEPTH_RGBA/VSM）与级联数量（CSM_CASCADE_COUNT）。无构造器，不安装 new。
 *
 * @file[en] renderers_lights_shadowconstants  Lua binding of the shadow constants
 * (three.script.prebind)
 * @brief[en] Binds the public top-level constants of ShadowConstants.cj in three.renderers.lights
 * as static methods on the Lua namespace three.renderers.lights.ShadowConstants
 * @explain[en] The constants file declares no class, only public top-level lets; for script access
 * they are all attached to the three.renderers.lights.ShadowConstants namespace as same-named
 * staticMethods (called from Lua, e.g. ShadowConstants.BASIC_SHADOW_MAP()). Covers the shadow-map
 * implementations (BASIC/PCF/PCF_SOFT/VSM/PCSS/ESM), distribution types
 * (SM_TYPE_SINGLE/OMNI/CASCADE), depth computation (DEPTH_IMPL_INVZ/LINEAR), depth packing
 * (PACK_DEPTH_RGBA/VSM) and the cascade count (CSM_CASCADE_COUNT). No constructor, no `new`.
 */
package three.script.prebind

import three.renderers.lights.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装阴影常量的 Lua 绑定（无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.lights.ShadowConstants）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the shadow constants (no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table at
 * three.renderers.lights.ShadowConstants)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShadowConstants(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.ShadowConstants")
    // ===== 阴影贴图实现 =====
    b.staticMethod("BASIC_SHADOW_MAP") {_ => [LuaValue.of(BASIC_SHADOW_MAP)]}
    b.staticMethod("PCF_SHADOW_MAP") {_ => [LuaValue.of(PCF_SHADOW_MAP)]}
    b.staticMethod("PCF_SOFT_SHADOW_MAP") {_ => [LuaValue.of(PCF_SOFT_SHADOW_MAP)]}
    b.staticMethod("VSM_SHADOW_MAP") {_ => [LuaValue.of(VSM_SHADOW_MAP)]}
    b.staticMethod("PCSS_SHADOW_MAP") {_ => [LuaValue.of(PCSS_SHADOW_MAP)]}
    b.staticMethod("ESM_SHADOW_MAP") {_ => [LuaValue.of(ESM_SHADOW_MAP)]}
    // ===== 阴影贴图分布类型 =====
    b.staticMethod("SM_TYPE_SINGLE") {_ => [LuaValue.of(SM_TYPE_SINGLE)]}
    b.staticMethod("SM_TYPE_OMNI") {_ => [LuaValue.of(SM_TYPE_OMNI)]}
    b.staticMethod("SM_TYPE_CASCADE") {_ => [LuaValue.of(SM_TYPE_CASCADE)]}
    // ===== 深度计算方式 =====
    b.staticMethod("DEPTH_IMPL_INVZ") {_ => [LuaValue.of(DEPTH_IMPL_INVZ)]}
    b.staticMethod("DEPTH_IMPL_LINEAR") {_ => [LuaValue.of(DEPTH_IMPL_LINEAR)]}
    // ===== 深度打包方式 =====
    b.staticMethod("PACK_DEPTH_RGBA") {_ => [LuaValue.of(PACK_DEPTH_RGBA)]}
    b.staticMethod("PACK_DEPTH_VSM") {_ => [LuaValue.of(PACK_DEPTH_VSM)]}
    // ===== CSM 级联数量 =====
    b.staticMethod("CSM_CASCADE_COUNT") {_ => [LuaValue.of(CSM_CASCADE_COUNT)]}
    b.install(vm)
}
