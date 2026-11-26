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
 * @file[zh-cn] utils_encode_groupvarint GroupVarint 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.GroupVarint 绑定为 Lua 命名空间 three.utils.encode.GroupVarint
 * @explain[zh-cn] 纯静态工具类。仓颉侧 encodeGroup / decodeGroup 通过调用方提供的输出缓冲区写回结果，
 * Lua 没有引用数组回写通道，故包装为：encodeGroup(4 个 UInt32) → 编码字节数组；decodeGroup(字节数组,
 * 起始偏移) → (4 个 UInt32 的数组, 读取字节数)。encodeStream(stream) → 字节数组；decodeStream(字节数组,
 * count) → UInt32 数组；worstBufferSize(count) → 最坏输出字节数。
 *
 * @file[en] utils_encode_groupvarint  Lua binding of GroupVarint (three.script.prebind)
 * @brief[en] Binds three.utils.encode.GroupVarint as the Lua namespace three.utils.encode.GroupVarint
 * @explain[en] Pure static utility. The Cangjie encodeGroup / decodeGroup write results into a
 * caller-provided output buffer; Lua has no by-reference array channel, so they are wrapped as:
 * encodeGroup(4 UInt32 values) -> encoded byte array; decodeGroup(byte array, start offset) ->
 * (array of 4 UInt32 values, bytes consumed). encodeStream(stream) -> byte array;
 * decodeStream(byte array, count) -> UInt32 array; worstBufferSize(count) -> worst-case bytes.
 */
package three.script.prebind

import three.utils.encode.GroupVarint
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GroupVarint 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.GroupVarint）
 *
 * @brief[en] Installs the Lua binding of GroupVarint (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.utils.encode.GroupVarint)
 */
public func installGroupVarint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.GroupVarint")
    // ===== 单组编码：输入须为 4 个 UInt32；返回编码后的字节数组 =====
    b.staticMethod("encodeGroup") { args =>
        let input = prebindU32Array(vm, args, 0)
        var out: LuaValue = LuaValue.Nil
        if (input.size == 4) {
            let buf = Array<UInt8>(17, { _ => 0u8 })
            let written = GroupVarint.encodeGroup(input, buf)
            if (written > 0 && written <= 17) {
                out = prebindBytesToLua(Array<UInt8>(written, { i => buf[i] }))
            }
        }
        [out]
    }
    // ===== 单组解码：返回 (4 个 UInt32 的数组, 读取字节数) =====
    b.staticMethod("decodeGroup") { args =>
        let data = prebindBytes(vm, args, 0)
        let baseOffset = prebindInt(args, 1)
        var values: LuaValue = LuaValue.Nil
        var consumed: LuaValue = LuaValue.Nil
        if (baseOffset >= 0 && baseOffset < data.size) {
            let out = Array<UInt32>(4, { _ => 0u32 })
            let n = GroupVarint.decodeGroup(data, baseOffset, out)
            values = prebindU32ArrayToLua(out)
            consumed = LuaValue.of(n)
        }
        [values, consumed]
    }
    // ===== 流编码：输入长度须为 4 的倍数 =====
    b.staticMethod("encodeStream") { args =>
        let stream = prebindU32Array(vm, args, 0)
        var out: LuaValue = LuaValue.Nil
        if (stream.size % 4 == 0) {
            out = prebindBytesToLua(GroupVarint.encodeStream(stream))
        }
        [out]
    }
    // ===== 流解码：count 须为 4 的倍数 =====
    b.staticMethod("decodeStream") { args =>
        let data = prebindBytes(vm, args, 0)
        let count = prebindInt(args, 1)
        var out: LuaValue = LuaValue.Nil
        if (count >= 0 && count % 4 == 0) {
            out = prebindU32ArrayToLua(GroupVarint.decodeStream(data, count))
        }
        [out]
    }
    // ===== 最坏输出字节数 =====
    b.staticMethod("worstBufferSize") { args =>
        [LuaValue.of(GroupVarint.worstBufferSize(prebindInt(args, 0)))]
    }
    b.install(vm)
}
