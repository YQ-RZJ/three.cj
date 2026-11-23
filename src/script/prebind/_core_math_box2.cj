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
 * @file[zh-cn] core_math_box2 2D 包围盒 Box2 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Box2 绑定为 Lua 类型 three.core.math.Box2
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/setFromCenterAndSize/clone/copy/
 * makeEmpty/isEmpty/expandBy.../contains.../intersectsBox/getParameter/clampPoint/intersect/
 * union/translate/equals 等）与属性 min/max（读写，返回内嵌 Vector2 句柄）。
 * getCenter/getSize 等以 target 为参数的方法返回传入的 target 对象 id。
 * 追加方法：setFromPoints 已通过 prebindObjList 对象数组通道绑定
 * （Lua 对象数组→ArrayList<Vector2>）。
 *
 * @file[en] core_math_box2  Lua binding of the 2D bounding box Box2 (three.script.prebind)
 * @brief[en] Binds three.core.math.Box2 as the Lua type three.core.math.Box2
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/setFromCenterAndSize/clone/copy/makeEmpty/isEmpty/expandBy.../contains.../
 * intersectsBox/getParameter/clampPoint/intersect/union/translate/equals etc.) and
 * properties min/max (read-write; the embedded Vector2 handle is returned). Methods
 * taking a target vector (getCenter/getSize etc.) return the passed target object id.
 * Appended method: setFromPoints is now bound via the prebindObjList object-array
 * channel (Lua object array → ArrayList<Vector2>).
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Box2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Box2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Box2
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Box2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBox2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Box2")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Box2(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1))
        } else {
            Box2()
        }
    }
    // ===== 属性 =====
    b.property("min", getter: Some({ref => prebindRegister(ref.cast<Box2>().min, "three.core.math.Vector2")}),
        setter: Some({ref, v => ref.cast<Box2>().min = LuaObjectRegistry.getAs<Vector2>(v.objectId())}))
    b.property("max", getter: Some({ref => prebindRegister(ref.cast<Box2>().max, "three.core.math.Vector2")}),
        setter: Some({ref, v => ref.cast<Box2>().max = LuaObjectRegistry.getAs<Vector2>(v.objectId())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Box2>().set(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCenterAndSize") {
        ref, args =>
            ref.cast<Box2>().setFromCenterAndSize(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Box2>().clone(), "three.core.math.Box2")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Box2>().copy(prebindAs<Box2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 空判断 =====
    b.method("makeEmpty") {
        ref, _ =>
            ref.cast<Box2>().makeEmpty()
            [LuaValue.Object(ref.id)]
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Box2>().isEmpty())]
    }
    b.method("getCenter") {
        ref, args =>
            ref.cast<Box2>().getCenter(prebindAs<Vector2>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("getSize") {
        ref, args =>
            ref.cast<Box2>().getSize(prebindAs<Vector2>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 扩展 =====
    b.method("expandByPoint") {
        ref, args =>
            ref.cast<Box2>().expandByPoint(prebindAs<Vector2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("expandByVector") {
        ref, args =>
            ref.cast<Box2>().expandByVector(prebindAs<Vector2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("expandByScalar") {
        ref, args =>
            ref.cast<Box2>().expandByScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 包含/相交 =====
    b.method("containsPoint") {
        ref, args => [LuaValue.of(ref.cast<Box2>().containsPoint(prebindAs<Vector2>(args, 0)))]
    }
    b.method("containsBox") {
        ref, args => [LuaValue.of(ref.cast<Box2>().containsBox(prebindAs<Box2>(args, 0)))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Box2>().intersectsBox(prebindAs<Box2>(args, 0)))]
    }
    b.method("getParameter") {
        ref, args =>
            ref.cast<Box2>().getParameter(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    b.method("clampPoint") {
        ref, args =>
            ref.cast<Box2>().clampPoint(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    b.method("distanceToPoint") {
        ref, args => [LuaValue.of(ref.cast<Box2>().distanceToPoint(prebindAs<Vector2>(args, 0)))]
    }
    // ===== 交集/并集/平移 =====
    b.method("intersect") {
        ref, args =>
            ref.cast<Box2>().intersect(prebindAs<Box2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("union") {
        ref, args =>
            ref.cast<Box2>().union(prebindAs<Box2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<Box2>().translate(prebindAs<Vector2>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Box2>().equals(prebindAs<Box2>(args, 0)))]
    }
    // ===== 点集（追加方法：经 prebindObjList 对象数组通道） =====
    b.method("setFromPoints") {
        ref, args =>
            ref.cast<Box2>().setFromPoints(prebindObjList<Vector2>(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
