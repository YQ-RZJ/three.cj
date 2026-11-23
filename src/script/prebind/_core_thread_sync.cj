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
 * @file[zh-cn] core_thread_sync 线程同步原语的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.thread 的 RecursiveMutex / Mutex / Condition / Semaphore /
 * RWLock 绑定为 Lua 类型 three.core.thread.X
 * @explain[zh-cn] 全部为对象式 SDL 同步原语封装，覆盖构造与 lock/tryLock/unlock/dispose、
 * wait/signal/broadcast 等方法；Condition.wait 支持 1 参（mutex）与 2 参（超时毫秒）重载，
 * Semaphore.wait 支持 0 参阻塞与 1 参超时重载。Sync.cj 的自由函数 sleep/sleepNS 无类载体
 * 不绑定；泛型 SThread/SPSCQueue 与依赖函数回调的 withLock 见各文件说明依次跳过。
 *
 * @file[en] core_thread_sync  Lua binding of the thread synchronization primitives
 * (three.script.prebind)
 * @brief[en] Binds three.core.thread.RecursiveMutex / Mutex / Condition / Semaphore /
 * RWLock as the Lua types three.core.thread.X
 * @explain[en] All are object-style wrappers of SDL sync primitives, covering construction
 * and lock/tryLock/unlock/dispose, wait/signal/broadcast etc.; Condition.wait supports the
 * 1-arg (mutex) and 2-arg (timeout ms) overloads, Semaphore.wait supports the 0-arg blocking
 * and 1-arg timeout overloads. The free functions sleep/sleepNS in Sync.cj are not bound
 * (no class carrier); generic SThread/SPSCQueue and withLock (function callback) are skipped
 * as described in their respective files.
 */
package three.script.prebind

import three.core.thread.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RecursiveMutex 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.RecursiveMutex）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] withLock<T> 为泛型方法（回调参数）不绑定。
 *
 * @brief[en] Installs the Lua binding of RecursiveMutex
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.RecursiveMutex)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] withLock<T> is a generic method (callback parameter) and is not bound.
 */
public func installRecursiveMutex(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.RecursiveMutex")
    b.constructor {_ => RecursiveMutex()}
    b.method("lock") {
        ref, _ =>
            ref.cast<RecursiveMutex>().lock()
            []
    }
    b.method("tryLock") {
        ref, _ => [LuaValue.of(ref.cast<RecursiveMutex>().tryLock())]
    }
    b.method("unlock") {
        ref, _ =>
            ref.cast<RecursiveMutex>().unlock()
            []
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<RecursiveMutex>().dispose()
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Mutex 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.Mutex）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Mutex
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.Mutex)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMutex(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.Mutex")
    b.constructor {_ => Mutex()}
    b.method("lock") {
        ref, _ =>
            ref.cast<Mutex>().lock()
            []
    }
    b.method("tryLock") {
        ref, _ => [LuaValue.of(ref.cast<Mutex>().tryLock())]
    }
    b.method("unlock") {
        ref, _ =>
            ref.cast<Mutex>().unlock()
            []
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<Mutex>().dispose()
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Condition 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.Condition）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] wait 支持 1 参（mutex）与 2 参（mutex + 超时毫秒）两种重载。
 *
 * @brief[en] Installs the Lua binding of Condition
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.Condition)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] wait supports the 1-arg (mutex) and 2-arg (mutex + timeout ms) overloads.
 */
public func installCondition(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.Condition")
    b.constructor {_ => Condition()}
    b.method("wait") {
        ref, args => if (args.size >= 2) {
            [LuaValue.of(ref.cast<Condition>().wait(prebindAs<Mutex>(args, 0), Int32(args[1].intValue())))]
        } else {
            [LuaValue.of(ref.cast<Condition>().wait(prebindAs<Mutex>(args, 0)))]
        }
    }
    b.method("signal") {
        ref, _ =>
            ref.cast<Condition>().signal()
            []
    }
    b.method("broadcast") {
        ref, _ =>
            ref.cast<Condition>().broadcast()
            []
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<Condition>().dispose()
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 Semaphore 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.Semaphore）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 * @explain[zh-cn] wait 支持 0 参阻塞与 1 参（超时毫秒）两种重载；构造初始计数值可选。
 *
 * @brief[en] Installs the Lua binding of Semaphore
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.Semaphore)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 * @explain[en] wait supports the 0-arg blocking and 1-arg (timeout ms) overloads; the
 * initial count is optional in the constructor.
 */
public func installSemaphore(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.Semaphore")
    b.constructor {args => Semaphore(initVal: UInt32(prebindInt(args, 0, default: 0)))}
    b.method("wait") {
        ref, args => if (args.size > 0) {
            [LuaValue.of(ref.cast<Semaphore>().wait(Int32(args[0].intValue())))]
        } else {
            ref.cast<Semaphore>().wait()
            []
        }
    }
    b.method("tryWait") {
        ref, _ => [LuaValue.of(ref.cast<Semaphore>().tryWait())]
    }
    b.method("signal") {
        ref, _ =>
            ref.cast<Semaphore>().signal()
            []
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<Semaphore>().dispose()
            []
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RWLock 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.RWLock）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RWLock
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.RWLock)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRWLock(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.RWLock")
    b.constructor {_ => RWLock()}
    b.method("lockRead") {
        ref, _ =>
            ref.cast<RWLock>().lockRead()
            []
    }
    b.method("lockWrite") {
        ref, _ =>
            ref.cast<RWLock>().lockWrite()
            []
    }
    b.method("tryLockRead") {
        ref, _ => [LuaValue.of(ref.cast<RWLock>().tryLockRead())]
    }
    b.method("tryLockWrite") {
        ref, _ => [LuaValue.of(ref.cast<RWLock>().tryLockWrite())]
    }
    b.method("unlock") {
        ref, _ =>
            ref.cast<RWLock>().unlock()
            []
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<RWLock>().dispose()
            []
    }
    b.install(vm)
}
