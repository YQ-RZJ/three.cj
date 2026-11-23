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
 * @file[zh-cn] renderers_common_info 渲染统计 Info 家族与通用常量 Constants 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 绑定 three.renderers.common.Info / RenderInfo / ComputeInfo / MemoryInfo / Constants
 * @explain[zh-cn] Info 由渲染器每帧刷新（calls / triangles / vertices / frame），
 * 通过 ThreeRenderer.info 属性以注册对象形式暴露（引用同一实例，读到的始终是最新统计）；
 * render / compute / memory 子统计同样按注册对象返回。
 * 其余 three.renderers.common 下的类为渲染管线内部脚手架（绑定/管线/渲染列表等），
 * 不属于脚本可达的渲染能力面，不在此绑定。
 *
 * @file[en] renderers_common_info  Lua bindings of the render statistics Info family and the
 * common Constants (three.script.prebind)
 * @brief[en] Binds three.renderers.common.Info / RenderInfo / ComputeInfo / MemoryInfo / Constants
 * @explain[en] Info is refreshed every frame by the renderer (calls / triangles / vertices / frame)
 * and is exposed through the ThreeRenderer.info property as a registered object (referencing the
 * same instance, so reads always see the latest statistics); the render / compute / memory
 * sub-statistics are returned as registered objects as well.
 * The other classes under three.renderers.common are internal render-pipeline scaffolding
 * (bindings / pipelines / render lists, etc.) and are not part of the script-reachable renderers
 * surface, so they are not bound here.
 */
package three.script.prebind

import three.renderers.common.{Info, RenderInfo, ComputeInfo, MemoryInfo, Constants}
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Info 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.common.Info）
 *
 * @brief[en] Installs the Lua binding of Info
 * @param[en] vm The target virtual machine (class table at three.renderers.common.Info)
 */
public func installInfo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.Info")
    b.constructor {_ => Info()}
    // ===== 顶层统计（可读写） =====
    b.property("autoReset", getter: Some({ref => LuaValue.of(ref.cast<Info>().autoReset)}),
        setter: Some({ref, v => ref.cast<Info>().autoReset = v.boolValue()}))
    b.property("frame", getter: Some({ref => LuaValue.of(ref.cast<Info>().frame)}),
        setter: Some({ref, v => ref.cast<Info>().frame = v.intValue()}))
    b.property("calls", getter: Some({ref => LuaValue.of(ref.cast<Info>().calls)}),
        setter: Some({ref, v => ref.cast<Info>().calls = v.intValue()}))
    b.property("triangles", getter: Some({ref => LuaValue.of(ref.cast<Info>().triangles)}),
        setter: Some({ref, v => ref.cast<Info>().triangles = v.intValue()}))
    b.property("vertices", getter: Some({ref => LuaValue.of(ref.cast<Info>().vertices)}),
        setter: Some({ref, v => ref.cast<Info>().vertices = v.intValue()}))
    // ===== 子统计（返回同一实例的注册对象） =====
    b.property("render",
        getter: Some({ref => prebindRegister(ref.cast<Info>().render, "three.renderers.common.RenderInfo")}))
    b.property("compute",
        getter: Some({ref => prebindRegister(ref.cast<Info>().compute, "three.renderers.common.ComputeInfo")}))
    b.property("memory",
        getter: Some({ref => prebindRegister(ref.cast<Info>().memory, "three.renderers.common.MemoryInfo")}))
    // ===== 操作 =====
    b.method("reset") {
        ref, _ =>
            ref.cast<Info>().reset()
            Array<LuaValue>()
    }
    b.method("update") {
        ref, args =>
            ref.cast<Info>().update(prebindInt(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RenderInfo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.common.RenderInfo）
 *
 * @brief[en] Installs the Lua binding of RenderInfo
 * @param[en] vm The target virtual machine (class table at three.renderers.common.RenderInfo)
 */
public func installRenderInfo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.RenderInfo")
    b.constructor {_ => RenderInfo()}
    b.property("calls", getter: Some({ref => LuaValue.of(ref.cast<RenderInfo>().calls)}),
        setter: Some({ref, v => ref.cast<RenderInfo>().calls = v.intValue()}))
    b.property("triangles", getter: Some({ref => LuaValue.of(ref.cast<RenderInfo>().triangles)}),
        setter: Some({ref, v => ref.cast<RenderInfo>().triangles = v.intValue()}))
    b.property("vertices", getter: Some({ref => LuaValue.of(ref.cast<RenderInfo>().vertices)}),
        setter: Some({ref, v => ref.cast<RenderInfo>().vertices = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ComputeInfo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.common.ComputeInfo）
 *
 * @brief[en] Installs the Lua binding of ComputeInfo
 * @param[en] vm The target virtual machine (class table at three.renderers.common.ComputeInfo)
 */
public func installComputeInfo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.ComputeInfo")
    b.constructor {_ => ComputeInfo()}
    b.property("calls", getter: Some({ref => LuaValue.of(ref.cast<ComputeInfo>().calls)}),
        setter: Some({ref, v => ref.cast<ComputeInfo>().calls = v.intValue()}))
    b.property("computeCalls", getter: Some({ref => LuaValue.of(ref.cast<ComputeInfo>().computeCalls)}),
        setter: Some({ref, v => ref.cast<ComputeInfo>().computeCalls = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MemoryInfo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.common.MemoryInfo）
 *
 * @brief[en] Installs the Lua binding of MemoryInfo
 * @param[en] vm The target virtual machine (class table at three.renderers.common.MemoryInfo)
 */
public func installMemoryInfo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.MemoryInfo")
    b.constructor {_ => MemoryInfo()}
    b.property("textures", getter: Some({ref => LuaValue.of(ref.cast<MemoryInfo>().textures)}),
        setter: Some({ref, v => ref.cast<MemoryInfo>().textures = v.intValue()}))
    b.property("geometries", getter: Some({ref => LuaValue.of(ref.cast<MemoryInfo>().geometries)}),
        setter: Some({ref, v => ref.cast<MemoryInfo>().geometries = v.intValue()}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装渲染通用常量 Constants 的 Lua 绑定（纯静态，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.common.Constants）
 *
 * @brief[en] Installs the Lua binding of the common Constants (pure static, no constructor)
 * @param[en] vm The target virtual machine (namespace table at three.renderers.common.Constants)
 */
public func installrenderersConstants(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.Constants")
    b.staticMethod("TRIANGLES") {_ => [LuaValue.of(Constants.TRIANGLES)]}
    b.staticMethod("LINES") {_ => [LuaValue.of(Constants.LINES)]}
    b.staticMethod("POINTS") {_ => [LuaValue.of(Constants.POINTS)]}
    b.staticMethod("BACKEND") {_ => [LuaValue.of(Constants.BACKEND)]}
    b.install(vm)
}
