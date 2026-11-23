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
 * @file[zh-cn] renderers_gfx_gfxhandles 抽象层 GPU 句柄值类型的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.common 的 Gfx*Handle 句柄值类型绑定为 Lua 类型
 * @explain[zh-cn] 约定：
 * - 句柄是 16 位索引的值语义 struct（不是指针）；Lua 侧统一以整数 idx 表示，
 *   便于比较与传参（0xFFFF = 无效）；
 * - 每个句柄类提供 new(idx) / INVALID() / 只读 idx / isValid 辅助；
 * - 绑定 API 中凡出现句柄参数/返回值，均使用整数 idx：
 *   传入时按位截断为 UInt16，返回时直接给出 Int64 idx。
 * 有效句柄仅由引擎资源对象（EngineDataTexture / EngineRenderTarget /
 * IUniformRegistry / IShaderProgram 等）产生，脚本侧不要自行伪造有效值。
 *
 * @file[en] renderers_gfx_gfxhandles  Lua bindings of the abstraction-layer GPU handle value types
 * (three.script.prebind)
 * @brief[en] Binds the Gfx*Handle value types of three.renderers.common as Lua types
 * @explain[en] Conventions:
 * - Handles are 16-bit-index value structs (not pointers); on the Lua side they are uniformly
 *   represented as integer idx values for easy comparison and passing (0xFFFF = invalid);
 * - Each handle class provides new(idx) / INVALID() / read-only idx / isValid helpers;
 * - Every handle parameter/return in the bound APIs uses the integer idx: parameters are
 *   truncated to UInt16, returns give the Int64 idx directly.
 * Valid handles are produced only by engine resource objects (EngineDataTexture /
 * EngineRenderTarget / IUniformRegistry / IShaderProgram etc.); scripts must not forge valid values.
 */
package three.script.prebind

import three.renderers.common.*
import three.script.vm.*
import three.script.binding.*

// =============================================================================
// ===== 绑定层句柄 ⇄ 整数 idx 转换 =====
// =============================================================================

/// 从 Lua 参数读取纹理句柄（整数 idx；缺失/越界按无效句柄 0xFFFF）
internal func prebindTextureHandle(args: Array<LuaValue>, idx: Int64): GfxTextureHandle {
    if (args.size <= idx) {
        return GfxTextureHandle.INVALID
    }
    return GfxTextureHandle(UInt16(args[idx].intValue(default: 0xFFFF) & 0xFFFF))
}

/// 从 Lua 参数读取帧缓冲句柄（整数 idx）
internal func prebindFrameBufferHandle(args: Array<LuaValue>, idx: Int64): GfxFrameBufferHandle {
    if (args.size <= idx) {
        return GfxFrameBufferHandle.INVALID
    }
    return GfxFrameBufferHandle(UInt16(args[idx].intValue(default: 0xFFFF) & 0xFFFF))
}

/// 从 Lua 参数读取程序句柄（整数 idx）
internal func prebindProgramHandle(args: Array<LuaValue>, idx: Int64): GfxProgramHandle {
    if (args.size <= idx) {
        return GfxProgramHandle.INVALID
    }
    return GfxProgramHandle(UInt16(args[idx].intValue(default: 0xFFFF) & 0xFFFF))
}

/// 从 Lua 参数读取 uniform 句柄（整数 idx）
internal func prebindUniformHandle(args: Array<LuaValue>, idx: Int64): GfxUniformHandle {
    if (args.size <= idx) {
        return GfxUniformHandle.INVALID
    }
    return GfxUniformHandle(UInt16(args[idx].intValue(default: 0xFFFF) & 0xFFFF))
}

/// 纹理句柄 → Lua 整数 idx
internal func prebindGfxHandleIdx(h: GfxTextureHandle): Int64 {
    return Int64(h.idx)
}

/// 帧缓冲句柄 → Lua 整数 idx
internal func prebindGfxHandleIdx(h: GfxFrameBufferHandle): Int64 {
    return Int64(h.idx)
}

/// 程序句柄 → Lua 整数 idx
internal func prebindGfxHandleIdx(h: GfxProgramHandle): Int64 {
    return Int64(h.idx)
}

/// uniform 句柄 → Lua 整数 idx
internal func prebindGfxHandleIdx(h: GfxUniformHandle): Int64 {
    return Int64(h.idx)
}

// =============================================================================
// ===== 句柄类型绑定 =====
// =============================================================================

/**
 * @brief[zh-cn] 安装 GfxTextureHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxTextureHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxTextureHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxTextureHandle")
    b.constructor {args => GfxTextureHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxTextureHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxTextureHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxFrameBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxFrameBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxFrameBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxFrameBufferHandle")
    b.constructor {args => GfxFrameBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxFrameBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxFrameBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxProgramHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxProgramHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxProgramHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxProgramHandle")
    b.constructor {args => GfxProgramHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxProgramHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxProgramHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxUniformHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxUniformHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxUniformHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxUniformHandle")
    b.constructor {args => GfxUniformHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxUniformHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxUniformHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxShaderHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxShaderHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxShaderHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxShaderHandle")
    b.constructor {args => GfxShaderHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxShaderHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxShaderHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxVertexBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxVertexBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxVertexBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxVertexBufferHandle")
    b.constructor {args => GfxVertexBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxVertexBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxVertexBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxIndexBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxIndexBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxIndexBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxIndexBufferHandle")
    b.constructor {args => GfxIndexBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxIndexBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxIndexBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxVertexLayoutHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxVertexLayoutHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxVertexLayoutHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxVertexLayoutHandle")
    b.constructor {args => GfxVertexLayoutHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxVertexLayoutHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxVertexLayoutHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxDynamicVertexBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxDynamicVertexBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxDynamicVertexBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxDynamicVertexBufferHandle")
    b.constructor {args => GfxDynamicVertexBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxDynamicVertexBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxDynamicVertexBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxDynamicIndexBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxDynamicIndexBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxDynamicIndexBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxDynamicIndexBufferHandle")
    b.constructor {args => GfxDynamicIndexBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxDynamicIndexBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxDynamicIndexBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxIndirectBufferHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxIndirectBufferHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxIndirectBufferHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxIndirectBufferHandle")
    b.constructor {args => GfxIndirectBufferHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxIndirectBufferHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxIndirectBufferHandle>().isValid)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GfxOcclusionQueryHandle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Lua binding of GfxOcclusionQueryHandle
 * @param[en] vm The target virtual machine
 */
public func installGfxOcclusionQueryHandle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.common.GfxOcclusionQueryHandle")
    b.constructor {args => GfxOcclusionQueryHandle(UInt16(prebindInt(args, 0, default: 0xFFFF) & 0xFFFF))}
    b.staticMethod("INVALID") {_ => [LuaValue.of(Int64(0xFFFF))]}
    b.property("idx", getter: Some({ref => LuaValue.of(Int64(ref.cast<GfxOcclusionQueryHandle>().idx))}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<GfxOcclusionQueryHandle>().isValid)}))
    b.install(vm)
}
