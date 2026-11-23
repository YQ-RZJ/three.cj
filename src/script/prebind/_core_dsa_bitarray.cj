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
 * @file[zh-cn] core_dsa_bitarray 动态位数组的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.BitArray 绑定为 Lua 类型 three.core.dsa.BitArray
 * @explain[zh-cn] 覆盖构造（new，初始索引+可选置位值）、只读属性（length）与公共方法
 * （copy/get/set/setIdxs/and/or/not/equal/cover/assign/clear/toBinaryString/hashCode）。
 * 字节数组通道（toArray/innerData/copyInnerData，Array<UInt8>）在绑定框架中无对应
 * Lua 通道，故不绑定。运算符 ==/!= 不绑定。
 *
 * @file[en] core_dsa_bitarray  Lua binding of the dynamic bit array (three.script.prebind)
 * @brief[en] Binds three.core.dsa.BitArray as the Lua type three.core.dsa.BitArray
 * @explain[en] Covers construction (new, initial index + optional set flag), the read-only
 * prop (length) and public methods (copy/get/set/setIdxs/and/or/not/equal/cover/assign/clear/
 * toBinaryString/hashCode). Byte-array accessors (toArray/innerData/copyInnerData, Array<UInt8>)
 * have no Lua channel in the binding framework and are omitted. Operators ==/!= are not bound.
 */
package three.script.prebind

import three.core.dsa.BitArray
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 BitArray 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.BitArray）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BitArray
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.BitArray)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBitArray(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.BitArray")
    // ===== 构造 =====
    b.constructor { args =>
        BitArray(prebindInt(args, 0), value: prebindBool(args, 1, default: true))
    }
    // ===== 属性 =====
    b.property("length", getter: Some({ ref => LuaValue.of(ref.cast<BitArray>().length) }))
    // ===== 方法 =====
    b.method("copy") { ref, _ =>
        [prebindRegister(ref.cast<BitArray>().copy(), "three.core.dsa.BitArray")]
    }
    b.method("get") { ref, args =>
        [LuaValue.of(ref.cast<BitArray>().get(args[0].intValue()))]
    }
    b.method("set") { ref, args =>
        ref.cast<BitArray>().set(args[0].intValue(), value: prebindBool(args, 1, default: true))
        []
    }
    b.method("setIdxs") { ref, args =>
        ref.cast<BitArray>().setIdxs(args[0].toArrayInt(), value: prebindBool(args, 1, default: true))
        []
    }
    // ===== 按位运算 =====
    b.method("and") { ref, args =>
        ref.cast<BitArray>().and(prebindAs<BitArray>(args, 0))
        []
    }
    b.method("or") { ref, args =>
        ref.cast<BitArray>().or(prebindAs<BitArray>(args, 0))
        []
    }
    b.method("not") { ref, _ =>
        ref.cast<BitArray>().not()
        []
    }
    // ===== 比较 =====
    b.method("equal") { ref, args =>
        [LuaValue.of(ref.cast<BitArray>().equal(prebindAs<BitArray>(args, 0)))]
    }
    b.method("cover") { ref, args =>
        [LuaValue.of(ref.cast<BitArray>().cover(prebindAs<BitArray>(args, 0)))]
    }
    // ===== 赋值/清空 =====
    b.method("assign") { ref, args =>
        ref.cast<BitArray>().assign(prebindAs<BitArray>(args, 0))
        []
    }
    b.method("clear") { ref, _ =>
        ref.cast<BitArray>().clear()
        []
    }
    // ===== 字符串 / 哈希 =====
    b.method("toBinaryString") { ref, _ =>
        [LuaValue.of(ref.cast<BitArray>().toBinaryString())]
    }
    b.method("hashCode") { ref, _ =>
        [LuaValue.of(ref.cast<BitArray>().hashCode())]
    }
    b.install(vm)
}