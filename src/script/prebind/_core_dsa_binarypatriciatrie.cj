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
 * @file[zh-cn] core_dsa_binarypatriciatrie 二进制 Patricia 树的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 BinaryPatriciaTrie<LuaValue> 实例化绑定为 Lua 类型 three.core.dsa.BinaryPatriciaTrie
 * @explain[zh-cn] 覆盖构造（new）、只读属性（size）与全部可转接的公共方法（set/get/has/
 * delete/clear）。键为 Array<UInt8>，经 prebindBytes 从 Lua 字节数组读取；值为 LuaValue
 * 直通（get 命中返回元素、未命中返回 nil）。返回 (Array<UInt8>, V) 元组或元组数组的方法
 * （longestPrefix/prefixOf/startsWith/bitSubsetOf/bitLongestSubset/fBitSubsetOf/
 * fBitLongestSubset）在绑定框架无元组转 Lua 通道，故不绑定。
 *
 * @file[en] core_dsa_binarypatriciatrie  Lua binding of the binary Patricia trie (three.script.prebind)
 * @brief[en] Binds three.core.dsa.BinaryPatriciaTrie instantiated as BinaryPatriciaTrie<LuaValue>
 * into the Lua type three.core.dsa.BinaryPatriciaTrie
 * @explain[en] Covers construction (new), the read-only prop (size) and all bridgeable public
 * methods (set/get/has/delete/clear). Keys are Array<UInt8> read from Lua byte arrays via
 * prebindBytes; values are LuaValues passed straight through (get returns the element on hit
 * and nil otherwise). Methods returning (Array<UInt8>, V) tuples / tuple arrays
 * (longestPrefix/prefixOf/startsWith/bitSubsetOf/bitLongestSubset/fBitSubsetOf/
 * fBitLongestSubset) have no tuple→Lua channel in the binding framework and are omitted.
 */
package three.script.prebind

import three.core.dsa.BinaryPatriciaTrie
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 安装 BinaryPatriciaTrie 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.BinaryPatriciaTrie）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BinaryPatriciaTrie
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.BinaryPatriciaTrie)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBinaryPatriciaTrie(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.BinaryPatriciaTrie")
    // ===== 构造 =====
    b.constructor {_ => BinaryPatriciaTrie<LuaValue>()}
    // ===== 属性 =====
    b.property("size", getter: Some({
        ref => LuaValue.of(ref.cast<BinaryPatriciaTrie<LuaValue>>().size)
    }))
    // ===== 方法 =====
    b.method("set") {
        ref, args =>
            let trie = ref.cast<BinaryPatriciaTrie<LuaValue>>()
            trie.set(prebindBytes(vm, args, 0), args[1])
            []
    }
    b.method("get") {
        ref, args =>
            let trie = ref.cast<BinaryPatriciaTrie<LuaValue>>()
            match (trie.get(prebindBytes(vm, args, 0))) {
                case Some(v) => [v]
                case None => [LuaValue.Nil]
            }
    }
    b.method("has") {
        ref, args =>
            let trie = ref.cast<BinaryPatriciaTrie<LuaValue>>()
            [LuaValue.of(trie.has(prebindBytes(vm, args, 0)))]
    }
    b.method("delete") {
        ref, args =>
            let trie = ref.cast<BinaryPatriciaTrie<LuaValue>>()
            [LuaValue.of(trie.delete(prebindBytes(vm, args, 0)))]
    }
    b.method("clear") {
        ref, _ =>
            let trie = ref.cast<BinaryPatriciaTrie<LuaValue>>()
            trie.clear()
            []
    }
    b.install(vm)
}
