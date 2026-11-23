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
 * @file[zh-cn] renderers_interfaces 渲染抽象接口（IShaderProgram / IUniformRegistry）的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 ThreeRenderer.makeShaderProgram / makeUniformRegistry 返回的抽象接口
 * 实例完整暴露给 Lua
 * @explain[zh-cn] 约定：
 * - 句柄一律以整数 idx 传递（见 renderers_gfx_gfxhandles 的约定）；
 * - uniform 数据以 Lua 数值数组传入，绑定层转成 PtrArray<Float32> 后立即提交；
 * - IShaderProgram.compile 支持无参与带变体 define 数组两种形态。
 *
 * @file[en] renderers_interfaces  Lua bindings of the render abstraction interfaces
 * (IShaderProgram / IUniformRegistry) (three.script.prebind)
 * @brief[en] Fully exposes the abstraction interface instances returned by
 * ThreeRenderer.makeShaderProgram / makeUniformRegistry to Lua
 * @explain[en] Conventions:
 * - Handles are always passed as integer idx (see the convention in renderers_gfx_gfxhandles);
 * - Uniform data is passed as a Lua number array and converted to PtrArray<Float32> for immediate submission;
 * - IShaderProgram.compile supports both the no-argument and the variant-define-array forms.
 */
package three.script.prebind

import three.renderers._interfaces.{IShaderProgram, IUniformRegistry}
import three.renderers.common.{GfxUniformHandle, GfxUniformType}
import three.utils.memory.PtrArray
import three.script.vm.*
import three.script.binding.*

// =============================================================================
// ===== 绑定层辅助 =====
// =============================================================================

/// 读取 Lua 字符串数组参数（非数组/表返回空数组）
internal func prebindStrArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<String> {
    let elems = prebindArray(vm, args, idx)
    var out = Array<String>(elems.size, {_ => ""})
    for (i in 0..elems.size) {
        out[i] = elems[i].stringValue(default: "")
    }
    return out
}

/// 读取 Lua 数值数组参数并包装为 PtrArray<Float32>（空数组时给出 1 元素缓冲避免零长度）
internal func prebindF32Ptr(vm: LuaVM, args: Array<LuaValue>, idx: Int64): PtrArray<Float32> {
    let vals = prebindFloatArray(vm, args, idx)
    let n = if (vals.size > 0) {
        vals.size
    } else {
        1
    }
    let mem = PtrArray<Float32>(n)
    for (i in 0..vals.size) {
        mem.set(i, Float32(vals[i]))
    }
    return mem
}

// =============================================================================
// ===== IShaderProgram =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 IShaderProgram 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers._interfaces.IShaderProgram）
 *
 * @brief[en] Installs the Lua binding of IShaderProgram
 * @param[en] vm The target virtual machine (class table at three.renderers._interfaces.IShaderProgram)
 */
public func installIShaderProgram(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers._interfaces.IShaderProgram")
    // ===== 编译（无参 / 带变体 define 数组） =====
    b.method("compile") {
        ref, args =>
            let prog = ref.cast<IShaderProgram>()
            if (args.size > 0 && (args[0].isArray || args[0].isTable)) {
                prog.compile(extraDefines: prebindStrArray(vm, args, 0))
            } else {
                prog.compile()
            }
            Array<LuaValue>()
    }
    b.method("resetHandles") {
        ref, _ =>
            ref.cast<IShaderProgram>().resetHandles()
            Array<LuaValue>()
    }
    // ===== 抽象层程序句柄（整数 idx） =====
    b.property("gfxProgramHandle",
        getter: Some({ref => LuaValue.of(prebindGfxHandleIdx(ref.cast<IShaderProgram>().gfxProgramHandle))}))
    b.install(vm)
}

// =============================================================================
// ===== IUniformRegistry =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 IUniformRegistry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers._interfaces.IUniformRegistry）
 *
 * @brief[en] Installs the Lua binding of IUniformRegistry
 * @param[en] vm The target virtual machine (class table at three.renderers._interfaces.IUniformRegistry)
 */
public func installIUniformRegistry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers._interfaces.IUniformRegistry")
    // ===== 创建 uniform（可选数组长度） =====
    b.method("createUniform") {
        ref, args =>
            let reg = ref.cast<IUniformRegistry>()
            let name = prebindStr(args, 0)
            let uniformType = prebindGfxUniformType(prebindInt(args, 1))
            if (args.size > 2) {
                [LuaValue.of(
                    prebindGfxHandleIdx(reg.createUniform(name, uniformType, UInt16(prebindInt(args, 2) & 0xFFFF))))]
            } else {
                [LuaValue.of(prebindGfxHandleIdx(reg.createUniform(name, uniformType)))]
            }
    }
    // ===== 数据提交（Lua 数值数组 → PtrArray<Float32>） =====
    b.method("setVec4") {
        ref, args =>
            ref.cast<IUniformRegistry>().setVec4(prebindStr(args, 0), prebindF32Ptr(vm, args, 1))
            Array<LuaValue>()
    }
    b.method("setMat4") {
        ref, args =>
            ref.cast<IUniformRegistry>().setMat4(prebindStr(args, 0), prebindF32Ptr(vm, args, 1))
            Array<LuaValue>()
    }
    b.method("setMat3") {
        ref, args =>
            ref.cast<IUniformRegistry>().setMat3(prebindStr(args, 0), prebindF32Ptr(vm, args, 1))
            Array<LuaValue>()
    }
    // ===== 纹理采样器绑定 =====
    b.method("setTexture") {
        ref, args =>
            ref
                .cast<IUniformRegistry>()
                .setTexture(prebindStr(args, 0), UInt8(prebindInt(args, 1) & 0xFF), prebindTextureHandle(args, 2),
                    UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    // ===== 查询与释放 =====
    b.method("getHandle") {
        ref, args => match (ref.cast<IUniformRegistry>().getHandle(prebindStr(args, 0))) {
            case Some(h) => [LuaValue.of(prebindGfxHandleIdx(h))]
            case None => [LuaValue.Nil]
        }
    }
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<IUniformRegistry>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<IUniformRegistry>().release())]
    }
    b.install(vm)
}
