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
 * otherwise be required by Sections 4(a), 5(b) and 6(d) of the License.
 *
 * @file[zh-cn] core_dsa_fenwicktree 树状数组的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.FenwickTree 绑定为 Lua 类型 three.core.dsa.FenwickTree
 * @explain[zh-cn] 覆盖构造（new/空或指定元素个数）、只读属性（size）与全部公共方法
 * （reset/add/query/prefixSum/rangeSum/lowerBound），参数与返回值均为整数。
 *
 * @file[en] core_dsa_fenwicktree  Lua binding of the Fenwick tree (three.script.prebind)
 * @brief[en] Binds three.core.dsa.FenwickTree as the Lua type three.core.dsa.FenwickTree
 * @explain[en] Covers construction (new / empty or sized), the read-only prop (size) and all
 * public methods (reset/add/query/prefixSum/rangeSum/lowerBound) with integer args/results.
 */
package three.script.prebind

import three.core.dsa.FenwickTree
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FenwickTree 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.FenwickTree）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FenwickTree
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.FenwickTree)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFenwickTree(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.FenwickTree")
    // ===== 构造 =====
    b.constructor { args =>
        if (args.size >= 1) { FenwickTree(args[0].intValue()) } else { FenwickTree() }
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ ref => LuaValue.of(ref.cast<FenwickTree>().size) }))
    // ===== 方法 =====
    b.method("reset") { ref, args =>
        ref.cast<FenwickTree>().reset(args[0].intValue())
        []
    }
    b.method("add") { ref, args =>
        ref.cast<FenwickTree>().add(args[0].intValue(), args[1].intValue())
        []
    }
    b.method("query") { ref, args =>
        [LuaValue.of(ref.cast<FenwickTree>().query(args[0].intValue()))]
    }
    b.method("prefixSum") { ref, args =>
        [LuaValue.of(ref.cast<FenwickTree>().prefixSum(args[0].intValue()))]
    }
    b.method("rangeSum") { ref, args =>
        [LuaValue.of(ref.cast<FenwickTree>().rangeSum(args[0].intValue(), args[1].intValue()))]
    }
    b.method("lowerBound") { ref, args =>
        [LuaValue.of(ref.cast<FenwickTree>().lowerBound(args[0].intValue()))]
    }
    b.install(vm)
}