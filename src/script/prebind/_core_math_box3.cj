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
 * @file[zh-cn] core_math_box3 3D 包围盒 Box3 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Box3 绑定为 Lua 类型 three.core.math.Box3
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/setFromArray/setFromObject/
 * setFromCenterAndSize/clone/copy/makeEmpty/isEmpty/getCenter/getSize/expandBy.../
 * contains.../intersects.../clampPoint/distanceToPoint/getBoundingSphere/intersect/union/
 * applyMatrix4/translate/equals/intersectsTriangle 等）与属性 min/max（读写）。
 * getCenter/getSize/getBoundingSphere 按参数个数分派无参与 target 两版。
 * 追加方法：setFromPoints 已通过 prebindObjList 对象数组通道绑定（使用
 * ArrayList 重载，Array 重载语义相同故不复绑）；fromJSON（HashMap）暂不绑定。
 *
 * @file[en] core_math_box3  Lua binding of the 3D bounding box Box3 (three.script.prebind)
 * @brief[en] Binds three.core.math.Box3 as the Lua type three.core.math.Box3
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/setFromArray/setFromObject/setFromCenterAndSize/clone/copy/makeEmpty/isEmpty/
 * getCenter/getSize/expandBy.../contains.../intersects.../clampPoint/distanceToPoint/
 * getBoundingSphere/intersect/union/applyMatrix4/translate/equals/intersectsTriangle
 * etc.) and properties min/max (read-write). getCenter/getSize/getBoundingSphere
 * dispatch between the no-arg and target versions by argument count.
 * Appended method: setFromPoints is now bound via the prebindObjList object-array
 * channel (the ArrayList overload; the Array overload has identical semantics and is
 * not additionally bound). fromJSON (HashMap) is still not bound.
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Box3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Box3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Box3
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Box3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBox3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Box3")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Box3(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
        } else {
            Box3()
        }
    }
    // ===== 属性 =====
    b.property("min", getter: Some({ref => prebindRegister(ref.cast<Box3>().min, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Box3>().min = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("max", getter: Some({ref => prebindRegister(ref.cast<Box3>().max, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Box3>().max = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Box3>().set(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromArray") {
        ref, args =>
            ref.cast<Box3>().setFromArray(args[0].toArrayFloat())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromBufferAttribute") {
        ref, args =>
            ref.cast<Box3>().setFromBufferAttribute(prebindAs<IAttributeReader>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromObject") {
        ref, args =>
            ref.cast<Box3>().setFromObject(prebindAs<IBox3Expandable>(args, 0), precise: prebindBool(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("expandByObject") {
        ref, args =>
            ref.cast<Box3>().expandByObject(prebindAs<IBox3Expandable>(args, 0), args[1].boolValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCenterAndSize") {
        ref, args =>
            ref.cast<Box3>().setFromCenterAndSize(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Box3>().clone(), "three.core.math.Box3")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Box3>().copy(prebindAs<Box3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 空判断 =====
    b.method("makeEmpty") {
        ref, _ =>
            ref.cast<Box3>().makeEmpty()
            [LuaValue.Object(ref.id)]
    }
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Box3>().isEmpty())]
    }
    // getCenter() / getCenter(target)
    b.method("getCenter") {
        ref, args => if (args.size >= 1) {
            ref.cast<Box3>().getCenter(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
        } else {
            [prebindRegister(ref.cast<Box3>().getCenter(), "three.core.math.Vector3")]
        }
    }
    // getSize() / getSize(target)
    b.method("getSize") {
        ref, args => if (args.size >= 1) {
            ref.cast<Box3>().getSize(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
        } else {
            [prebindRegister(ref.cast<Box3>().getSize(), "three.core.math.Vector3")]
        }
    }
    // ===== 扩展 =====
    b.method("expandByPoint") {
        ref, args =>
            ref.cast<Box3>().expandByPoint(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("expandByVector") {
        ref, args =>
            ref.cast<Box3>().expandByVector(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("expandByScalar") {
        ref, args =>
            ref.cast<Box3>().expandByScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 包含/相交 =====
    b.method("containsPoint") {
        ref, args => [LuaValue.of(ref.cast<Box3>().containsPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("containsBox") {
        ref, args => [LuaValue.of(ref.cast<Box3>().containsBox(prebindAs<Box3>(args, 0)))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Box3>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    b.method("intersectsSphere") {
        ref, args => [LuaValue.of(ref.cast<Box3>().intersectsSphere(prebindAs<Sphere>(args, 0)))]
    }
    b.method("intersectsPlane") {
        ref, args => [LuaValue.of(ref.cast<Box3>().intersectsPlane(prebindAs<Plane>(args, 0)))]
    }
    b.method("intersectsTriangle") {
        ref, args => [LuaValue.of(ref.cast<Box3>().intersectsTriangle(prebindAs<Triangle>(args, 0)))]
    }
    b.method("getParameter") {
        ref, args =>
            ref.cast<Box3>().getParameter(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    b.method("clampPoint") {
        ref, args =>
            ref.cast<Box3>().clampPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    b.method("distanceToPoint") {
        ref, args => [LuaValue.of(ref.cast<Box3>().distanceToPoint(prebindAs<Vector3>(args, 0)))]
    }
    // getBoundingSphere() / getBoundingSphere(target)
    b.method("getBoundingSphere") {
        ref, args => if (args.size >= 1) {
            ref.cast<Box3>().getBoundingSphere(prebindAs<Sphere>(args, 0))
            [LuaValue.Object(args[0].objectId())]
        } else {
            [prebindRegister(ref.cast<Box3>().getBoundingSphere(), "three.core.math.Sphere")]
        }
    }
    // ===== 交集/并集/变换/平移 =====
    b.method("intersect") {
        ref, args =>
            ref.cast<Box3>().intersect(prebindAs<Box3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("union") {
        ref, args =>
            ref.cast<Box3>().union(prebindAs<Box3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Box3>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<Box3>().translate(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Box3>().equals(prebindAs<Box3>(args, 0)))]
    }
    // ===== 点集（追加方法：ArrayList 重载，经 prebindObjList 对象数组通道） =====
    b.method("setFromPoints") {
        ref, args =>
            ref.cast<Box3>().setFromPoints(prebindObjList<Vector3>(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
