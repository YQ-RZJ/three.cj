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
 * @file[zh-cn] core_dsa_unionfind 并查集的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.UnionFind 绑定为 Lua 类型 three.core.dsa.UnionFind
 * @explain[zh-cn] 覆盖构造（new/空或指定元素个数）、只读属性（size/componentCount）与
 * 全部公共方法（makeSet/find/union/connected/reset），参数与返回值均为整数/布尔。
 *
 * @file[en] core_dsa_unionfind  Lua binding of the union-find structure (three.script.prebind)
 * @brief[en] Binds three.core.dsa.UnionFind as the Lua type three.core.dsa.UnionFind
 * @explain[en] Covers construction (new / empty or sized), read-only props (size/componentCount)
 * and all public methods (makeSet/find/union/connected/reset) with integer/bool results.
 */
package three.script.prebind

import three.core.dsa.UnionFind
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UnionFind 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.UnionFind）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UnionFind
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.UnionFind)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUnionFind(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.UnionFind")
    // ===== 构造 =====
    b.constructor { args =>
        if (args.size >= 1) { UnionFind(args[0].intValue()) } else { UnionFind() }
    }
    // ===== 属性 =====
    b.property("size", getter: Some({ ref => LuaValue.of(ref.cast<UnionFind>().size) }))
    b.property("componentCount", getter: Some({ ref => LuaValue.of(ref.cast<UnionFind>().componentCount) }))
    // ===== 方法 =====
    b.method("makeSet") { ref, _ =>
        [LuaValue.of(ref.cast<UnionFind>().makeSet())]
    }
    b.method("find") { ref, args =>
        [LuaValue.of(ref.cast<UnionFind>().find(args[0].intValue()))]
    }
    b.method("union") { ref, args =>
        [LuaValue.of(ref.cast<UnionFind>().union(args[0].intValue(), args[1].intValue()))]
    }
    b.method("connected") { ref, args =>
        [LuaValue.of(ref.cast<UnionFind>().connected(args[0].intValue(), args[1].intValue()))]
    }
    b.method("reset") { ref, args =>
        ref.cast<UnionFind>().reset(args[0].intValue())
        []
    }
    b.install(vm)
}