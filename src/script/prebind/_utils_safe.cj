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
 * @file[zh-cn] utils_safe 安全托管包装 Safe 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.safe.Safe 绑定为 Lua 类型 three.utils.safe.Safe
 * @explain[zh-cn] Safe<T>（T <: IReleasable）是泛型类，Lua 侧按 IReleasable 具体化：
 * 构造接受任意已注册的 IReleasable 对象；value 只读属性返回被托管对象
 * （注册为 three.utils.safe.IReleasable 类名）；releasable 只读属性与
 * release()（幂等，返回是否本次真正释放）如实绑定。
 * 接口 IReleasable 本身不绑定（接口不绑）。
 *
 * @file[en] utils_safe  Lua binding of the Safe ownership wrapper (three.script.prebind)
 * @brief[en] Binds three.utils.safe.Safe as the Lua type three.utils.safe.Safe
 * @explain[en] Safe<T> (T <: IReleasable) is generic; the binding instantiates it
 * with IReleasable. The constructor accepts any registered IReleasable object;
 * the read-only property value returns the wrapped object (registered under
 * three.utils.safe.IReleasable); releasable (read-only) and release() (idempotent,
 * returns whether this call actually released) are bound faithfully.
 * The IReleasable interface itself is not bound (interfaces are not bound).
 */
package three.script.prebind

import three.utils.safe.IReleasable
import three.utils.safe.Safe
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Safe 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.utils.safe.Safe）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Safe
 * @param[en] vm The target virtual machine (class table installed at three.utils.safe.Safe)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSafe(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.safe.Safe")
    // ===== 构造 =====
    b.constructor {
        args => Safe<IReleasable>(prebindAs<IReleasable>(args, 0))
    }
    // ===== 属性 =====
    b.property("value",
        getter: Some({ref => prebindRegister(ref.cast<Safe<IReleasable>>().value, "three.utils.safe.IReleasable")}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<Safe<IReleasable>>().releasable)}))
    // ===== 方法 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Safe<IReleasable>>().release())]
    }
    b.install(vm)
}
