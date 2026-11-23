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
 * @file[zh-cn] utils_memory 内存缓冲 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将内存缓冲绑定为 Lua 类型 three.utils.memory.BgfxMemory
 * @explain[zh-cn] 底层改用 three.utils.memory.PtrArray<UInt8>（不再依赖 bgfx 包），
 * 对 Lua 暴露与旧 BgfxMemory 一致的字节缓冲能力：构造（size 字节）、
 * writeFloats/writeUInt16/writeUInt8（数组 + 计数写入）、writeFloat/readFloat
 * （按 float 元素索引读写）。同一字节缓冲可安全承载 Float32/UInt16/UInt8 混写。
 * @note[zh-cn] 旧静态查询 getAvailTransientIndexBuffer / getAvailInstanceDataBuffer
 * 依赖 bgfx 瞬时缓冲运行时，抽象层无等价物且无脚本使用，本批一并移除。
 * memory 包其余 public 类均为泛型模板（UniquePtr/SharedPtr/PtrArray/AutoFreePtr，
 * T <: CType），按约定模板类跳过不绑（PtrArray 已在 _utils_memory_ptrarray.cj 中
 * 按元素类型实例化绑定）；ScopeGuard 构造需 ()->Unit 清理回调，同样跳过。
 *
 * @file[en] utils_memory  Lua binding of the memory buffer (three.script.prebind)
 * @brief[en] Binds the memory buffer as the Lua type three.utils.memory.BgfxMemory
 * @explain[en] Now backed by three.utils.memory.PtrArray<UInt8> (no longer depends on the
 * bgfx package); exposes the same byte-buffer capabilities as the old BgfxMemory:
 * construction (byte size), writeFloats/writeUInt16/writeUInt8 (array + count),
 * writeFloat/readFloat (float element indexed). The same byte buffer safely holds mixed
 * Float32/UInt16/UInt8 writes.
 * @note[en] The former static queries getAvailTransientIndexBuffer /
 * getAvailInstanceDataBuffer depend on the bgfx transient-buffer runtime, have no
 * abstraction-layer equivalent and no script used them, so they are removed in this batch.
 * The other public classes in the memory package are generic templates
 * (UniquePtr/SharedPtr/PtrArray/AutoFreePtr, T <: CType) and are skipped by convention
 * (PtrArray is instantiated per element type in _utils_memory_ptrarray.cj);
 * ScopeGuard's constructor takes a ()->Unit cleanup callback and is skipped too.
 */
package three.script.prebind

import three.utils.memory.PtrArray
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装内存缓冲的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.memory.BgfxMemory）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of the memory buffer
 * @param[en] vm The target virtual machine (class table installed at three.utils.memory.BgfxMemory)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBgfxMemory(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.memory.BgfxMemory")
    // ===== 构造（size 字节 → PtrArray<UInt8> 连续堆缓冲，内存清零） =====
    b.constructor {
        args => PtrArray<UInt8>(Int64(args[0].intValue()))
    }
    // ===== 数组写入 =====
    b.method("writeFloats") {
        ref, args =>
            let buf = ref.cast<PtrArray<UInt8>>()
            let vals = args[0].toArrayFloat()
            let count = args[1].intValue()
            let p = unsafe { CPointer<Float32>(buf.data()) }
            for (i in 0..count) {
                unsafe { p.write(i, Float32(vals[i])) }
            }
            []
    }
    b.method("writeUInt16") {
        ref, args =>
            let buf = ref.cast<PtrArray<UInt8>>()
            let vals = args[0].toArrayInt()
            let count = args[1].intValue()
            let p = unsafe { CPointer<UInt16>(buf.data()) }
            for (i in 0..count) {
                unsafe { p.write(i, UInt16(vals[i] & 0xFFFF)) }
            }
            []
    }
    b.method("writeUInt8") {
        ref, args =>
            let buf = ref.cast<PtrArray<UInt8>>()
            let vals = args[0].toArrayInt()
            let count = args[1].intValue()
            for (i in 0..count) {
                buf.set(i, UInt8(vals[i] & 0xFF))
            }
            []
    }
    // ===== 单值读写（按 float 元素索引） =====
    b.method("writeFloat") {
        ref, args =>
            let buf = ref.cast<PtrArray<UInt8>>()
            let p = unsafe { CPointer<Float32>(buf.data()) }
            unsafe { p.write(args[0].intValue(), Float32(args[1].numberValue())) }
            []
    }
    b.method("readFloat") {
        ref, args =>
            let buf = ref.cast<PtrArray<UInt8>>()
            let p = unsafe { CPointer<Float32>(buf.data()) }
            [LuaValue.of(Float64(unsafe { p.read(args[0].intValue()) }))]
    }
    b.install(vm)
}
