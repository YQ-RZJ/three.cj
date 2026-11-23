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
 * @file[zh-cn] core_math_euler 欧拉角 Euler 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Euler 绑定为 Lua 类型 three.core.math.Euler
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/clone/copy/setFromRotationMatrix/
 * setFromQuaternion/setFromVector3/reorder/equals/fromArray/toArray/onChange 等）与属性
 * （x/y/z/order）。order 属性与相关参数以整数表示（0=XYZ,1=YXZ,2=ZXY,3=ZYX,4=YZX,5=XZY，
 * 与 fromArray 的数组第四元素约定一致）。onChange 接受 Lua 函数作为回调（经 LuaCallback
 * 桥接）。重载方法（set/setFromRotationMatrix/setFromQuaternion/setFromVector3）按实参个数
 * 自动分派。
 *
 * @file[en] core_math_euler  Lua binding of the Euler angles Euler (three.script.prebind)
 * @brief[en] Binds three.core.math.Euler as the Lua type three.core.math.Euler
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/clone/copy/setFromRotationMatrix/setFromQuaternion/setFromVector3/reorder/equals/
 * fromArray/toArray/onChange etc.) and properties (x/y/z/order). The order property and
 * related arguments are integers (0=XYZ,1=YXZ,2=ZXY,3=ZYX,4=YZX,5=XZY, matching the
 * fourth-array-element convention of fromArray). onChange accepts a Lua function as the
 * callback (bridged via LuaCallback). Overloaded methods (set/setFromRotationMatrix/
 * setFromQuaternion/setFromVector3) dispatch on the argument count.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/// 欧拉角旋转顺序 → 整数索引（0=XYZ,1=YXZ,2=ZXY,3=ZYX,4=YZX,5=XZY）
internal func _eulerOrderToInt(o: EulerOrder): Int64 {
    match (o) {
        case EulerOrder.XYZ => 0
        case EulerOrder.YXZ => 1
        case EulerOrder.ZXY => 2
        case EulerOrder.ZYX => 3
        case EulerOrder.YZX => 4
        case EulerOrder.XZY => 5
    }
}

/// 整数索引 → 欧拉角旋转顺序（越界回退 XZY）
internal func _eulerOrderFromInt(v: Int64): EulerOrder {
    match (v) {
        case 0 => EulerOrder.XYZ
        case 1 => EulerOrder.YXZ
        case 2 => EulerOrder.ZXY
        case 3 => EulerOrder.ZYX
        case 4 => EulerOrder.YZX
        case _ => EulerOrder.XZY
    }
}

/**
 * @brief[zh-cn] 安装 Euler 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Euler）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Euler
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Euler)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEuler(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Euler")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Euler(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
        } else {
            Euler()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(ref.cast<Euler>().x)}),
        setter: Some({ref, v => ref.cast<Euler>().x = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Euler>().y)}),
        setter: Some({ref, v => ref.cast<Euler>().y = v.numberValue()}))
    b.property("z", getter: Some({ref => LuaValue.of(ref.cast<Euler>().z)}),
        setter: Some({ref, v => ref.cast<Euler>().z = v.numberValue()}))
    b.property("order", getter: Some({ref => LuaValue.of(_eulerOrderToInt(ref.cast<Euler>().order))}),
        setter: Some({ref, v => ref.cast<Euler>().order = _eulerOrderFromInt(v.intValue())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            let x = args[0].numberValue()
            let y = args[1].numberValue()
            let z = args[2].numberValue()
            if (args.size >= 4) {
                ref.cast<Euler>().set(x, y, z, _eulerOrderFromInt(args[3].intValue()))
            } else {
                ref.cast<Euler>().set(x, y, z)
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Euler>().clone(), "three.core.math.Euler")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Euler>().copy(prebindAs<Euler>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵/四元数/向量 =====
    b.method("setFromRotationMatrix") {
        ref, args =>
            let m = prebindAs<Matrix4>(args, 0)
            if (args.size >= 3) {
                ref.cast<Euler>().setFromRotationMatrix(m, _eulerOrderFromInt(args[1].intValue()), args[2].boolValue())
            } else if (args.size == 2) {
                ref.cast<Euler>().setFromRotationMatrix(m, _eulerOrderFromInt(args[1].intValue()))
            } else {
                ref.cast<Euler>().setFromRotationMatrix(m)
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromQuaternion") {
        ref, args =>
            let q = prebindAs<Quaternion>(args, 0)
            if (args.size >= 3) {
                ref.cast<Euler>().setFromQuaternion(q, _eulerOrderFromInt(args[1].intValue()), args[2].boolValue())
            } else if (args.size == 2) {
                ref.cast<Euler>().setFromQuaternion(q, _eulerOrderFromInt(args[1].intValue()))
            } else {
                ref.cast<Euler>().setFromQuaternion(q)
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromVector3") {
        ref, args =>
            let v = prebindAs<Vector3>(args, 0)
            if (args.size >= 2) {
                ref.cast<Euler>().setFromVector3(v, _eulerOrderFromInt(args[1].intValue()))
            } else {
                ref.cast<Euler>().setFromVector3(v)
            }
            [LuaValue.Object(ref.id)]
    }
    b.method("reorder") {
        ref, args =>
            ref.cast<Euler>().reorder(_eulerOrderFromInt(args[0].intValue()))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Euler>().equals(prebindAs<Euler>(args, 0)))]
    }
    // ===== 数组 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Euler>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, _ =>
            var arr = Array<Float64>(3, {_ => 0.0})
            ref.cast<Euler>().toArray(arr)
            [LuaValue.of(arr)]
    }
    // ===== 变更回调 =====
    b.method("onChange") {
        ref, args =>
            let cbOpt = LuaCallback.fromValue(vm, args[0])
            if (let Some(cb) <- cbOpt) {
                ref.cast<Euler>().onChange(
                    {
                        =>
                        cb.call();
                        ()
                    }
                )
            }
            [LuaValue.Object(ref.id)]
    }
    // ===== 静态 =====
    b.staticMethod("DEFAULT_ORDER") {
        _ => [LuaValue.of(_eulerOrderToInt(Euler.DEFAULT_ORDER))]
    }
    b.install(vm)
}
