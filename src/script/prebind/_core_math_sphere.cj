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
 * @file[zh-cn] core_math_sphere 球体 Sphere 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Sphere 绑定为 Lua 类型 three.core.math.Sphere
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/clone/copy/makeEmpty/
 * isEmpty/containsPoint/distanceToPoint/intersectsSphere/intersectsPlane/intersectsBox/
 * clampPoint/getBoundingBox/applyMatrix4/translate/equals/expandByPoint/union）与属性
 * center/radius（读写）。互变异构方法均返回自身（Lua 链式可用）。getBoundingBox
 * 按参数个数分派无参与 target 两版（无参返回新 Box3）。追加方法：setFromPoints
 * 已通过 prebindObjList 对象数组通道绑定（可选 center 经 Option 通道接收）；
 * fromJSON（HashMap）依赖 JSON 转接，暂不绑定。
 *
 * @file[en] core_math_sphere Lua binding of the sphere Sphere (three.script.prebind)
 * @brief[en] Binds three.core.math.Sphere as the Lua type three.core.math.Sphere
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/clone/copy/makeEmpty/isEmpty/containsPoint/distanceToPoint/intersectsSphere/
 * intersectsPlane/intersectsBox/clampPoint/getBoundingBox/applyMatrix4/translate/equals/
 * expandByPoint/union) and properties center/radius (read-write). Mutating methods
 * return self for Lua chaining. getBoundingBox dispatches between the no-arg and target
 * versions by argument count (no-arg returns a new Box3). Appended method:
 * setFromPoints is now bound via the prebindObjList object-array channel (the optional
 * center is accepted through the Option channel); fromJSON (HashMap) is still not bound.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Sphere 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Sphere）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Sphere
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Sphere)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSphere(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Sphere")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Sphere(prebindAs<Vector3>(args, 0), args[1].numberValue())
        } else {
            Sphere()
        }
    }
    // ===== 属性 =====
    b.property("center", getter: Some({ref => prebindRegister(ref.cast<Sphere>().center, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Sphere>().center = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<Sphere>().radius)}),
        setter: Some({ref, v => ref.cast<Sphere>().radius = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Sphere>().set(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Sphere>().clone(), "three.core.math.Sphere")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Sphere>().copy(prebindAs<Sphere>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeEmpty") {
        ref, _ =>
            ref.cast<Sphere>().makeEmpty()
            [LuaValue.Object(ref.id)]
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Sphere>().isEmpty())]
    }
    // ===== 点/距离 =====
    b.method("containsPoint") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().containsPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("distanceToPoint") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().distanceToPoint(prebindAs<Vector3>(args, 0)))]
    }
    // ===== 相交 =====
    b.method("intersectsSphere") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().intersectsSphere(prebindAs<Sphere>(args, 0)))]
    }
    b.method("intersectsPlane") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().intersectsPlane(prebindAs<Plane>(args, 0)))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    b.method("clampPoint") {
        ref, args =>
            ref.cast<Sphere>().clampPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    // getBoundingBox() / getBoundingBox(target)
    b.method("getBoundingBox") {
        ref, args =>
            let v = ref.cast<Sphere>()
            if (args.size >= 1) {
                v.getBoundingBox(prebindAs<Box3>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.getBoundingBox(), "three.core.math.Box3")]
            }
    }
    // ===== 变换/平移 =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Sphere>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<Sphere>().translate(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较/扩展/并 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Sphere>().equals(prebindAs<Sphere>(args, 0)))]
    }
    b.method("expandByPoint") {
        ref, args =>
            ref.cast<Sphere>().expandByPoint(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("union") {
        ref, args =>
            ref.cast<Sphere>().union(prebindAs<Sphere>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 点集（追加方法：经 prebindObjList 对象数组通道；可选 center） =====
    b.method("setFromPoints") {
        ref, args =>
            let s = ref.cast<Sphere>()
            let pts = prebindObjList<Vector3>(vm, args, 0)
            if (args.size >= 2 && args[1].isObject) {
                s.setFromPoints(pts, optionalCenter: Some(LuaObjectRegistry.getAs<Vector3>(args[1].objectId())))
            } else {
                s.setFromPoints(pts)
            }
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
