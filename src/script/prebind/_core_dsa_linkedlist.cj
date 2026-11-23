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
 * @file[zh-cn] core_dsa_linkedlist 双向链表 LinkedList/LinkedListNode 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 LinkedList<LuaValue>/LinkedListNode<LuaValue> 实例化（泛型"any 方式"）
 * 绑定为 Lua 类型 three.core.dsa.LinkedList 与 three.core.dsa.LinkedListNode
 * @explain[zh-cn] LinkedList 覆盖构造（new）、全部公共方法（addFirst/addLast/addBefore/
 * addAfter/removeFirst/removeLast/remove/isEmpty/clear/toArray）与属性（first/last/
 * firstNode/lastNode/size）。addFirst 等返回新节点（注册为 LinkedListNode 对象回传）；
 * addBefore/addAfter/remove 接受 LinkedListNode 对象参数。removeFirst/removeLast 与
 * first/last 返回 ?T：Some→直接回传元素（本就是 LuaValue），None→nil；firstNode/lastNode
 * 返回 ?LinkedListNode：Some→注册节点回传，None→nil。iterator()（返回 Iterator，无 Lua
 * 通道）不绑定。LinkedListNode 仅绑定公开属性（value/prev/next；构造为 internal 不可用），
 * 节点由 addFirst/addLast 等创建后回传 Lua。value 为公开可写 var→属性读写；prev/next 为
 * ?LinkedListNode 只读属性（Some→注册节点回传，None→nil）。
 *
 * @file[en] core_dsa_linkedlist  Lua binding of the doubly linked list LinkedList/LinkedListNode
 * @brief[en] Binds LinkedList<LuaValue>/LinkedListNode<LuaValue> (generics "any" style) as the
 * Lua types three.core.dsa.LinkedList and three.core.dsa.LinkedListNode
 * @explain[en] LinkedList covers construction (new), all public methods (addFirst/addLast/
 * addBefore/addAfter/removeFirst/removeLast/remove/isEmpty/clear/toArray) and props
 * (first/last/firstNode/lastNode/size). addFirst etc. return fresh nodes (registered and
 * passed back as LinkedListNode objects); addBefore/addAfter/remove take LinkedListNode
 * object args. removeFirst/removeLast and first/last return ?T: Some→element passed back
 * (already a LuaValue), None→nil; firstNode/lastNode return ?LinkedListNode: Some→registered
 * node, None→nil. iterator() (returns Iterator, no Lua channel) is not bound. LinkedListNode
 * only binds public props (value/prev/next; the ctor is internal and unusable); nodes are
 * created by addFirst/addLast etc. and returned to Lua. value is a public writable var→
 * read/write property; prev/next are read-only ?LinkedListNode props (Some→registered node,
 * None→nil).
 */
package three.script.prebind

import three.core.dsa.LinkedList
import three.core.dsa.LinkedListNode
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LinkedList 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.LinkedList）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LinkedList
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.LinkedList)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLinkedList(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.LinkedList")
    // ===== 构造 =====
    b.constructor {_ => LinkedList<LuaValue>()}
    // ===== 属性 =====
    b.property("first", getter: Some({
        ref => match (ref.cast<LinkedList<LuaValue>>().first) {
            case Some(v) => v
            case None => LuaValue.Nil
        }
    }))
    b.property("last", getter: Some({
        ref => match (ref.cast<LinkedList<LuaValue>>().last) {
            case Some(v) => v
            case None => LuaValue.Nil
        }
    }))
    b.property("firstNode", getter: Some({
        ref => match (ref.cast<LinkedList<LuaValue>>().firstNode) {
            case Some(n) => prebindRegister(n, "three.core.dsa.LinkedListNode")
            case None => LuaValue.Nil
        }
    }))
    b.property("lastNode", getter: Some({
        ref => match (ref.cast<LinkedList<LuaValue>>().lastNode) {
            case Some(n) => prebindRegister(n, "three.core.dsa.LinkedListNode")
            case None => LuaValue.Nil
        }
    }))
    b.property("size", getter: Some({ref => LuaValue.of(ref.cast<LinkedList<LuaValue>>().size)}))
    // ===== 方法 =====
    b.method("addFirst") {
        ref, args => [prebindRegister(ref.cast<LinkedList<LuaValue>>().addFirst(args[0]),
            "three.core.dsa.LinkedListNode")]
    }
    b.method("addLast") {
        ref, args => [prebindRegister(ref.cast<LinkedList<LuaValue>>().addLast(args[0]), "three.core.dsa.LinkedListNode")]
    }
    b.method("addBefore") {
        ref, args => [prebindRegister(
            ref.cast<LinkedList<LuaValue>>().addBefore(prebindAs<LinkedListNode<LuaValue>>(args, 0), args[1]),
            "three.core.dsa.LinkedListNode")]
    }
    b.method("addAfter") {
        ref, args => [prebindRegister(
            ref.cast<LinkedList<LuaValue>>().addAfter(prebindAs<LinkedListNode<LuaValue>>(args, 0), args[1]),
            "three.core.dsa.LinkedListNode")]
    }
    b.method("removeFirst") {
        ref, _ => match (ref.cast<LinkedList<LuaValue>>().removeFirst()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("removeLast") {
        ref, _ => match (ref.cast<LinkedList<LuaValue>>().removeLast()) {
            case Some(v) => [v]
            case None => [LuaValue.Nil]
        }
    }
    b.method("remove") {
        ref, args =>
            ref.cast<LinkedList<LuaValue>>().remove(prebindAs<LinkedListNode<LuaValue>>(args, 0))
            []
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<LinkedList<LuaValue>>().isEmpty())]
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<LinkedList<LuaValue>>().clear()
            []
    }
    b.method("toArray") {
        ref, _ => [LuaValue.of(ref.cast<LinkedList<LuaValue>>().toArray())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 LinkedListNode 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.LinkedListNode）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] 无 new（构造为 internal），节点由 LinkedList.addFirst/addLast 等创建并回传。
 *
 * @brief[en] Installs the Lua binding of LinkedListNode
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.LinkedListNode)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] No new (the ctor is internal); nodes are created and returned by
 * LinkedList.addFirst/addLast and friends.
 */
public func installLinkedListNode(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.LinkedListNode")
    // ===== 属性 =====
    b.property("value", getter: Some({ref => ref.cast<LinkedListNode<LuaValue>>().value}),
        setter: Some({ref, v => ref.cast<LinkedListNode<LuaValue>>().value = v}))
    b.property("prev", getter: Some({
        ref => match (ref.cast<LinkedListNode<LuaValue>>().prev) {
            case Some(n) => prebindRegister(n, "three.core.dsa.LinkedListNode")
            case None => LuaValue.Nil
        }
    }))
    b.property("next", getter: Some({
        ref => match (ref.cast<LinkedListNode<LuaValue>>().next) {
            case Some(n) => prebindRegister(n, "three.core.dsa.LinkedListNode")
            case None => LuaValue.Nil
        }
    }))
    b.install(vm)
}
