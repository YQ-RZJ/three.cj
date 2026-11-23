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
 * @file[zh-cn] utils_allocator ID 分配器 IdAllocator 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.allocator.IdAllocator 绑定为 Lua 类型
 * three.utils.allocator.IdAllocator
 * @explain[zh-cn] 构造支持可选起始 ID（默认 0）；allocate() 返回新分配的
 * Int64；release 按实参个数在两种重载间分派——带参回收单个 ID，无参
 * 为重置（返回 Bool）；freeCount() 返回空闲 ID 数量；releasable 只读
 * 属性来自 IReleasable 接口默认实现。
 *
 * @file[en] utils_allocator  Lua binding of the ID allocator IdAllocator (three.script.prebind)
 * @brief[en] Binds three.utils.allocator.IdAllocator as the Lua type
 * three.utils.allocator.IdAllocator
 * @explain[en] Construction accepts an optional start ID (default 0); allocate()
 * returns the newly allocated Int64; release dispatches between the two
 * overloads by argument count — with an argument it recycles one ID, without
 * one it resets (returns Bool); freeCount() returns the number of free IDs;
 * the read-only releasable property comes from the IReleasable interface's
 * default implementation.
 */
package three.script.prebind

import three.utils.allocator.IdAllocator
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 IdAllocator 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.allocator.IdAllocator）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of IdAllocator
 * @param[en] vm The target virtual machine (class table installed at three.utils.allocator.IdAllocator)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installIdAllocator(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.allocator.IdAllocator")
    // ===== 构造（可选起始 ID） =====
    b.constructor {
        args => if (args.size > 0) {
            IdAllocator(startId: args[0].intValue())
        } else {
            IdAllocator()
        }
    }
    // ===== 属性 =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<IdAllocator>().releasable)}))
    // ===== 方法 =====
    b.method("allocate") {
        ref, _ => [LuaValue.of(ref.cast<IdAllocator>().allocate())]
    }
    b.method("release") {
        ref, args =>
            let alloc = ref.cast<IdAllocator>()
            if (args.size > 0) {
                // 带参：回收单个 ID
                alloc.release(args[0].intValue())
                []
            } else {
                // 无参：重置分配器
                [LuaValue.of(alloc.release())]
            }
    }
    b.method("freeCount") {
        ref, _ => [LuaValue.of(ref.cast<IdAllocator>().freeCount())]
    }
    b.install(vm)
}
