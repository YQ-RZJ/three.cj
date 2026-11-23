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
 * @file[zh-cn] core_dsa_binaryheap 二叉堆 BinaryHeap 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 以 BinaryHeap<LuaValue> 实例化（LuaValue 已实现 IHeapNode，满足
 * T <: IHeapNode 约束）绑定为 Lua 类型 three.core.dsa.BinaryHeap
 * @explain[zh-cn] 覆盖构造（new / 可选初始容量）、只读属性（size）与全部公共方法
 * （push/pop/top/get/contains/update/remove/isEmpty/clear）。节点即 LuaValue 本体
 * （LuaValue 实现 IHeapNode 后作为泛型实参直通，无需包装）；pop 的 ?LuaValue 返回值：
 * Some→元素直接回传，None→nil；push/remove/clear 返回空，fill 断言见具体方法注释。
 *
 * @file[en] core_dsa_binaryheap  Lua binding of the binary heap BinaryHeap
 * (three.script.prebind)
 * @brief[en] Binds three.core.dsa.BinaryHeap instantiated as BinaryHeap<LuaValue>
 * (LuaValue implements IHeapNode, satisfying the T <: IHeapNode bound) into the Lua
 * type three.core.dsa.BinaryHeap
 * @explain[en] Covers construction (new / optional initial capacity), read-only prop
 * (size) and all public methods (push/pop/top/get/contains/update/remove/isEmpty/
 * clear). Heap nodes are LuaValue themselves (LuaValue implements IHeapNode, so it
 * passes straight through as the generic argument without wrapping); ?LuaValue returns:
 * Some→element passed back directly, None→nil; push/remove/clear return empty.
 */
package three.script.prebind

import three.core.dsa.BinaryHeap
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 BinaryHeap 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.BinaryHeap）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BinaryHeap
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.BinaryHeap)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBinaryHeap(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.BinaryHeap")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 1) {
            BinaryHeap<LuaValue>(args[0].intValue())
        } else {
            BinaryHeap<LuaValue>()
        }
    }
    // ===== 属性 =====
    b.property(
        "size",
        getter: Some(
            {
                ref =>
                    let heap = ref.cast<BinaryHeap<LuaValue>>()
                    LuaValue.of(heap.size)
            }
        )
    )
    // ===== 方法 =====
    b.method("push") {
        ref, args =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            heap.push(args[0])
            []
    }
    b.method("pop") {
        ref, _ =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            match (heap.pop()) {
                case Some(v) => [v]
                case None => [LuaValue.Nil]
            }
    }
    b.method("top") {
        ref, _ =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            [heap.top()]
    }
    b.method("get") {
        ref, args =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            [heap.get(args[0].intValue())]
    }
    b.method("contains") {
        ref, args =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            [LuaValue.of(heap.contains(args[0]))]
    }
    b.method("update") {
        ref, args =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            [LuaValue.of(heap.update(args[0]))]
    }
    b.method("remove") {
        ref, args =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            heap.remove(args[0])
            []
    }
    b.method("isEmpty") {
        ref, _ =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            [LuaValue.of(heap.isEmpty())]
    }
    b.method("clear") {
        ref, _ =>
            let heap = ref.cast<BinaryHeap<LuaValue>>()
            heap.clear()
            []
    }
    b.install(vm)
}
