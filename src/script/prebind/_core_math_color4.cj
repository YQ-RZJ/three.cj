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
 * @file[zh-cn] core_math_color4 RGBA 颜色 Color4 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Color4 绑定为 Lua 类型 three.core.math.Color4
 * @explain[zh-cn] 覆盖构造（new/无参/RGBA 四参/hex 单参/Color 对象拷贝），实例方法
 * （setAlpha/clone4/copy4）与属性（a）。r/g/b 与颜色空间语义继承自 Color；如需这些
 * 成员请在 Lua 中以 Color4 对象直接使用对应 Color 绑定（本类表仅注册自身声明的方法与
 * 属性 a）。
 *
 * @file[en] core_math_color4  Lua binding of the RGBA color Color4 (three.script.prebind)
 * @brief[en] Binds three.core.math.Color4 as the Lua type three.core.math.Color4
 * @explain[en] Covers construction (new / no-arg / RGBA four-arg / hex one-arg / copy from
 * a Color object), instance methods (setAlpha/clone4/copy4) and the property (a). The r/g/b
 * and color-space semantics are inherited from Color; use the Color bindings on a Color4
 * object when those members are needed (this class table only registers its own declared
 * methods and the property a).
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Color4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Color4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Color4
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Color4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installColor4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Color4")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Color4(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                a: prebindNum(args, 3, default: 1.0))
        } else if (args.size == 1 && args[0].isObject) {
            Color4(prebindAs<Color>(args, 0), a: prebindNum(args, 1, default: 1.0))
        } else if (args.size == 1) {
            Color4(UInt32(args[0].numberValue()), a: prebindNum(args, 1, default: 1.0))
        } else {
            Color4()
        }
    }
    // ===== 属性 =====
    b.property("a", getter: Some({ref => LuaValue.of(ref.cast<Color4>().a)}),
        setter: Some({ref, v => ref.cast<Color4>().a = v.numberValue()}))
    // ===== 方法 =====
    b.method("setAlpha") {
        ref, args =>
            ref.cast<Color4>().setAlpha(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clone4") {
        ref, _ => [prebindRegister(ref.cast<Color4>().clone4(), "three.core.math.Color4")]
    }
    b.method("copy4") {
        ref, args =>
            ref.cast<Color4>().copy4(prebindAs<Color4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
