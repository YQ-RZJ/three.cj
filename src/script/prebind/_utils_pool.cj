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
 * @file[zh-cn] utils_pool 对象池 PoolManager 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.pool.PoolManager 绑定为 Lua 类型 three.utils.pool.PoolManager
 * @explain[zh-cn] PoolManager 是实例工具类（非静态单例）：构造支持默认容量
 * 128 与显式 capacity；get 返回的对象统一注册为 three.utils.pool.Object
 * （不透明句柄，可再传回 recycle）。register 系列因对象工厂/回收护
 * 回调参数无法从 Lua 提供而跳过（回调不绑）。泛型类 ObjectPool<T>
 * 因工厂回调构造无法从 Lua 实例化，本文件不为其生成类表（跳过原因
 * 详见汇报）。
 *
 * @file[en] utils_pool  Lua binding of the pool manager PoolManager (three.script.prebind)
 * @brief[en] Binds three.utils.pool.PoolManager as the Lua type three.utils.pool.PoolManager
 * @explain[en] PoolManager is an instance utility (not a static singleton): construction
 * supports the default capacity 128 and an explicit capacity; objects returned
 * by get are registered under three.utils.pool.Object (an opaque handle that
 * can be passed back into recycle). The register family is skipped because
 * object-factory / recycle-callback arguments cannot be provided from Lua
 * (callbacks are not bound). The generic ObjectPool<T> is not bound either
 * (its factory-callback constructor cannot be instantiated from Lua).
 */
package three.script.prebind

import three.utils.pool.PoolManager
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PoolManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.pool.PoolManager）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PoolManager
 * @param[en] vm The target virtual machine (class table installed at three.utils.pool.PoolManager)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPoolManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.pool.PoolManager")
    // ===== 构造（无参 = 默认容量 128） =====
    b.constructor {
        args => if (args.size > 0) {
            PoolManager(args[0].intValue())
        } else {
            PoolManager()
        }
    }
    // ===== 查询 =====
    b.method("isRegister") {
        ref, args => [LuaValue.of(ref.cast<PoolManager>().isRegister(args[0].intValue()))]
    }
    // ===== 获取/回收 =====
    b.method("get") {
        ref, args => [prebindRegister(ref.cast<PoolManager>().get(args[0].intValue()), "three.utils.pool.Object")]
    }
    b.method("recycle") {
        ref, args =>
            ref.cast<PoolManager>().recycle(args[0].intValue(), prebindAs<Object>(args, 1))
            []
    }
    // ===== 注销/清理 =====
    b.method("unregister") {
        ref, args =>
            ref.cast<PoolManager>().unregister(args[0].intValue())
            []
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<PoolManager>().clear()
            []
    }
    b.install(vm)
}
