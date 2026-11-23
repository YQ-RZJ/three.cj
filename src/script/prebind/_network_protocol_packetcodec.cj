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
 * @file[zh-cn] network_protocol_packetcodec 协议包编解码的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.protocol.PacketWriter / PacketReader 绑定为 Lua 类型
 * three.network.protocol.PacketWriter / PacketReader
 * @explain[zh-cn] 覆盖 PacketWriter 的全部写接口（U8~U64 / I16~I64 / Bool / F32 / F64 /
 * 原始字节 / 长度前缀字符串 / toArray / clear / size）与 PacketReader 的全部读接口
 * （对应 read* / remaining / hasMore / position / skip）。
 * 数值映射：UInt32 / UInt64 经 Float64 装箱为 Lua number（Lua number 为双精度），
 * 其余整型经 Int64 装箱；字节数组在 Lua 侧为数值数组（元素 0~255）。
 * 越界策略：仓颉侧 PacketReader 越界会抛 IllegalStateException，绑定层在方法内捕获并
 * 返回零值 / 空串 / 空数组，**不向 Lua 抛错**——绑定方法抛异常会让分派层执行
 * lua_error 的 longjmp，跨过仓颉栈帧破坏运行时状态（实测表现为后续随机访问冲突）。
 * 脚本可用 remaining / hasMore 预先判断，避免读到零值。
 *
 * @file[en] network_protocol_packetcodec  Lua bindings of the protocol packet codec
 * (three.script.prebind)
 * @brief[en] Binds three.network.protocol.PacketWriter / PacketReader as Lua types
 * three.network.protocol.PacketWriter / PacketReader
 * @explain[en] Covers every PacketWriter write API (U8~U64 / I16~I64 / Bool / F32 / F64 /
 * raw bytes / length-prefixed string / toArray / clear / size) and every PacketReader read
 * API (read* / remaining / hasMore / position / skip).
 * Numeric mapping: UInt32 / UInt64 are boxed as Lua numbers via Float64 (Lua numbers are
 * doubles) and other integers via Int64; byte arrays appear as Lua number arrays (0~255).
 * Out-of-range policy: the Cangjie PacketReader throws IllegalStateException; the binding
 * catches it and returns zero / empty string / empty array and **never throws to Lua** -
 * throwing out of a binding method would make the dispatch layer perform lua_error's
 * longjmp across Cangjie stack frames and corrupt runtime state (observed as random later
 * access violations). Scripts can pre-check with remaining / hasMore to avoid zero values.
 */
package three.script.prebind

import three.network.protocol.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PacketWriter 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.protocol.PacketWriter）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PacketWriter
 * @param[en] vm The target virtual machine (class table installed at
 * three.network.protocol.PacketWriter)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPacketWriter(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.protocol.PacketWriter")
    // ===== 构造 =====
    b.constructor {_ => PacketWriter()}
    // ===== 容量 =====
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<PacketWriter>().size)}))
    // ===== 单字节 =====
    b.method("writeU8") {
        ref, args =>
            ref.cast<PacketWriter>().writeU8(UInt8(prebindInt(args, 0) & 0xFF))
            Array<LuaValue>()
    }
    // ===== 无符号整型（大端） =====
    b.method("writeU16") {
        ref, args =>
            ref.cast<PacketWriter>().writeU16(UInt16(prebindInt(args, 0) & 0xFFFF))
            Array<LuaValue>()
    }
    b.method("writeU32") {
        ref, args =>
            ref.cast<PacketWriter>().writeU32(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.method("writeU64") {
        ref, args =>
            ref.cast<PacketWriter>().writeU64(UInt64(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    // ===== 有符号整型（大端补码） =====
    b.method("writeI16") {
        ref, args =>
            ref.cast<PacketWriter>().writeI16(Int16(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    b.method("writeI32") {
        ref, args =>
            ref.cast<PacketWriter>().writeI32(Int32(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    b.method("writeI64") {
        ref, args =>
            ref.cast<PacketWriter>().writeI64(prebindInt(args, 0))
            Array<LuaValue>()
    }
    // ===== 布尔 / 浮点 =====
    b.method("writeBool") {
        ref, args =>
            ref.cast<PacketWriter>().writeBool(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("writeF32") {
        ref, args =>
            ref.cast<PacketWriter>().writeF32(Float32(prebindNum(args, 0)))
            Array<LuaValue>()
    }
    b.method("writeF64") {
        ref, args =>
            ref.cast<PacketWriter>().writeF64(prebindNum(args, 0))
            Array<LuaValue>()
    }
    // ===== 字节块 / 字符串 =====
    b.method("writeBytes") {
        ref, args =>
            ref.cast<PacketWriter>().writeBytes(prebindBytes(vm, args, 0))
            Array<LuaValue>()
    }
    b.method("writeString") {
        ref, args =>
            ref.cast<PacketWriter>().writeString(prebindStr(args, 0))
            Array<LuaValue>()
    }
    // ===== 取包 / 复位 =====
    b.method("toArray") {
        ref, _ => [prebindBytesToLua(ref.cast<PacketWriter>().toArray())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<PacketWriter>().clear()
            Array<LuaValue>()
    }
    // ===== 常量 =====
    b.staticMethod("MAX_STRING_BYTES") {_ => [LuaValue.of(MAX_STRING_BYTES)]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PacketReader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.protocol.PacketReader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 所有 read* 均做越界捕获：越界时返回 0 / false / "" / 空数组，
 * 并保持游标不变（仓颉侧 _need 在越界时未推进游标）。
 *
 * @brief[en] Installs the Lua binding of PacketReader
 * @param[en] vm The target virtual machine (class table installed at
 * three.network.protocol.PacketReader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] Every read* catches out-of-range errors and returns 0 / false / "" / an empty
 * array while leaving the cursor untouched (the Cangjie _need guard does not advance it).
 */
public func installPacketReader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.protocol.PacketReader")
    // ===== 构造（字节数组） =====
    b.constructor {args => PacketReader(prebindBytes(vm, args, 0))}
    // ===== 游标状态 =====
    b.property("remaining", getter: Some({ref => LuaValue.of(ref.cast<PacketReader>().remaining)}))
    b.property("hasMore", getter: Some({ref => LuaValue.of(ref.cast<PacketReader>().hasMore)}))
    b.property("position", getter: Some({ref => LuaValue.of(ref.cast<PacketReader>().position)}))
    // ===== 单字节 =====
    b.method("readU8") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Int64 = 0
            try {
                v = Int64(r.readU8())
            } catch (_) {
                v = 0
            }
            [LuaValue.of(v)]
    }
    // ===== 无符号整型（大端） =====
    b.method("readU16") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Int64 = 0
            try {
                v = Int64(r.readU16())
            } catch (_) {
                v = 0
            }
            [LuaValue.of(v)]
    }
    b.method("readU32") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Float64 = 0.0
            try {
                v = Float64(r.readU32())
            } catch (_) {
                v = 0.0
            }
            [LuaValue.of(v)]
    }
    b.method("readU64") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Float64 = 0.0
            try {
                v = Float64(r.readU64())
            } catch (_) {
                v = 0.0
            }
            [LuaValue.of(v)]
    }
    // ===== 有符号整型（大端补码） =====
    b.method("readI16") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Int64 = 0
            try {
                v = Int64(r.readI16())
            } catch (_) {
                v = 0
            }
            [LuaValue.of(v)]
    }
    b.method("readI32") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Int64 = 0
            try {
                v = Int64(r.readI32())
            } catch (_) {
                v = 0
            }
            [LuaValue.of(v)]
    }
    b.method("readI64") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Int64 = 0
            try {
                v = r.readI64()
            } catch (_) {
                v = 0
            }
            [LuaValue.of(v)]
    }
    // ===== 布尔 / 浮点 =====
    b.method("readBool") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v = false
            try {
                v = r.readBool()
            } catch (_) {
                v = false
            }
            [LuaValue.of(v)]
    }
    b.method("readF32") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Float64 = 0.0
            try {
                v = Float64(r.readF32())
            } catch (_) {
                v = 0.0
            }
            [LuaValue.of(v)]
    }
    b.method("readF64") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var v: Float64 = 0.0
            try {
                v = r.readF64()
            } catch (_) {
                v = 0.0
            }
            [LuaValue.of(v)]
    }
    // ===== 字节块 / 字符串 =====
    b.method("readBytes") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var out: Array<UInt8> = Array<UInt8>()
            try {
                out = r.readBytes()
            } catch (_) {
                out = Array<UInt8>()
            }
            [prebindBytesToLua(out)]
    }
    b.method("readString") {
        ref, _ =>
            let r = ref.cast<PacketReader>()
            var out = ""
            try {
                out = r.readString()
            } catch (_) {
                out = ""
            }
            [LuaValue.of(out)]
    }
    // ===== 跳过 =====
    b.method("skip") {
        ref, args =>
            let r = ref.cast<PacketReader>()
            try {
                r.skip(prebindInt(args, 0))
            } catch (_) {
                // 越界跳过：忽略，游标保持不变
            }
            Array<LuaValue>()
    }
    // ===== 常量 =====
    b.staticMethod("MAX_STRING_BYTES") {_ => [LuaValue.of(MAX_STRING_BYTES)]}
    b.install(vm)
}
