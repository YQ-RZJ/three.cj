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
 * @file[zh-cn] core_math_triangle 三角形 Triangle 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Triangle 绑定为 Lua 类型 three.core.math.Triangle
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/setFromAttributeAndIndices/
 * clone/copy/getArea/getMidpoint/getNormal/getPlane/getBarycoord/getInterpolation/
 * containsPoint/isFrontFacing/intersectsBox/closestPointToPoint/equals）与属性 a/b/c
 * （读写），以及 6 个静态方法（computeNormal/computeBarycoord/testContainsPoint/
 * computeInterpolation/testIsFrontFacing/getInterpolatedAttribute）。互变异构方法均
 * 返回自身（Lua 链式可用）；getMidpoint/getNormal/getPlane/getBarycoord/
 * closestPointToPoint 按参数个数分派无参与 target 两版；返回 Option<Vector3> 的方法
 * 命中时返回 target、未命中返回 nil。追加方法：setFromPointsAndIndices 已通过
 * luaVec3Array 对象数组转换通道绑定；setFromAttributeAndIndices/getInterpolatedAttribute 的
 * IAttributeReader 接口参数按既有核心绑定（如 Box3.setFromBufferAttribute）惯例处理。
 *
 * @file[en] core_math_triangle Lua binding of the triangle Triangle (three.script.prebind)
 * @brief[en] Binds three.core.math.Triangle as the Lua type three.core.math.Triangle
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/setFromAttributeAndIndices/clone/copy/getArea/getMidpoint/getNormal/getPlane/
 * getBarycoord/getInterpolation/containsPoint/isFrontFacing/intersectsBox/
 * closestPointToPoint/equals), properties a/b/c (read-write) and 6 statics
 * (computeNormal/computeBarycoord/testContainsPoint/computeInterpolation/
 * testIsFrontFacing/getInterpolatedAttribute). Mutating methods return self for Lua
 * chaining; getMidpoint/getNormal/getPlane/getBarycoord/closestPointToPoint dispatch
 * between no-arg and target versions by argument count; methods returning
 * Option<Vector3> return the target on hit and nil otherwise. Appended method:
 * setFromPointsAndIndices is now bound via the luaVec3Array object-array conversion
 * channel; the IAttributeReader interface arguments
 * of setFromAttributeAndIndices/getInterpolatedAttribute follow existing core-binding
 * conventions (e.g. Box3.setFromBufferAttribute).
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Triangle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Triangle）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Triangle
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Triangle)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTriangle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Triangle")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Triangle(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2))
        } else {
            Triangle()
        }
    }
    // ===== 属性 =====
    b.property("a", getter: Some({ref => prebindRegister(ref.cast<Triangle>().a, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Triangle>().a = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("b", getter: Some({ref => prebindRegister(ref.cast<Triangle>().b, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Triangle>().b = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("c", getter: Some({ref => prebindRegister(ref.cast<Triangle>().c, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Triangle>().c = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    // ===== 静态：法向量/重心坐标/包含/插值/朝向/属性插值 =====
    b.staticMethod("computeNormal") {
        args =>
            Triangle.computeNormal(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2),
                prebindAs<Vector3>(args, 3))
            [LuaValue.Object(args[3].objectId())]
    }
    b.staticMethod("computeBarycoord") {
        args =>
            let r = Triangle.computeBarycoord(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                prebindAs<Vector3>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[4].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.staticMethod("testContainsPoint") {
        args => [LuaValue.of(
            Triangle.testContainsPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                prebindAs<Vector3>(args, 2), prebindAs<Vector3>(args, 3)))]
    }
    b.staticMethod("computeInterpolation") {
        args =>
            let r = Triangle.computeInterpolation(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                prebindAs<Vector3>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindAs<Vector3>(args, 5), prebindAs<Vector3>(args, 6), prebindAs<Vector3>(args, 7))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[7].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.staticMethod("testIsFrontFacing") {
        args => [LuaValue.of(
            Triangle.testIsFrontFacing(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                prebindAs<Vector3>(args, 2), prebindAs<Vector3>(args, 3)))]
    }
    b.staticMethod("getInterpolatedAttribute") {
        args =>
            Triangle.getInterpolatedAttribute(prebindAs<IAttributeReader>(args, 0), args[1].intValue(),
                args[2].intValue(), args[3].intValue(), prebindAs<Vector3>(args, 4), prebindAs<Vector3>(args, 5))
            [LuaValue.Object(args[5].objectId())]
    }
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Triangle>().set(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromAttributeAndIndices") {
        ref, args =>
            ref
                .cast<Triangle>()
                .setFromAttributeAndIndices(prebindAs<IAttributeReader>(args, 0), args[1].intValue(), args[2].intValue(),
                    args[3].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Triangle>().clone(), "three.core.math.Triangle")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Triangle>().copy(prebindAs<Triangle>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getArea") {
        ref, _ => [LuaValue.of(ref.cast<Triangle>().getArea())]
    }
    // getMidpoint() / getMidpoint(target)
    b.method("getMidpoint") {
        ref, args =>
            let v = ref.cast<Triangle>()
            if (args.size >= 1) {
                v.getMidpoint(prebindAs<Vector3>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.getMidpoint(), "three.core.math.Vector3")]
            }
    }
    // getNormal() / getNormal(target)
    b.method("getNormal") {
        ref, args =>
            let v = ref.cast<Triangle>()
            if (args.size >= 1) {
                v.getNormal(prebindAs<Vector3>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.getNormal(), "three.core.math.Vector3")]
            }
    }
    // getPlane() / getPlane(target)
    b.method("getPlane") {
        ref, args =>
            let v = ref.cast<Triangle>()
            if (args.size >= 1) {
                v.getPlane(prebindAs<Plane>(args, 0))
                [LuaValue.Object(args[0].objectId())]
            } else {
                [prebindRegister(v.getPlane(), "three.core.math.Plane")]
            }
    }
    // getBarycoord(point) / getBarycoord(point, target)
    b.method("getBarycoord") {
        ref, args =>
            let v = ref.cast<Triangle>()
            if (args.size >= 2) {
                let r = v.getBarycoord(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
                if (let Some(_) <- r) {
                    [LuaValue.Object(args[1].objectId())]
                } else {
                    [LuaValue.Nil]
                }
            } else {
                [prebindRegister(v.getBarycoord(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3")]
            }
    }
    b.method("getInterpolation") {
        ref, args =>
            let r = ref
                .cast<Triangle>()
                .getInterpolation(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2),
                    prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[4].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.method("containsPoint") {
        ref, args => [LuaValue.of(ref.cast<Triangle>().containsPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("isFrontFacing") {
        ref, args => [LuaValue.of(ref.cast<Triangle>().isFrontFacing(prebindAs<Vector3>(args, 0)))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Triangle>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    // closestPointToPoint(p) / closestPointToPoint(p, target)
    b.method("closestPointToPoint") {
        ref, args =>
            let v = ref.cast<Triangle>()
            if (args.size >= 2) {
                v.closestPointToPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.closestPointToPoint(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3")]
            }
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Triangle>().equals(prebindAs<Triangle>(args, 0)))]
    }
    // ===== 点集+索引（追加方法：经 luaVec3Array 对象数组通道） =====
    b.method("setFromPointsAndIndices") {
        ref, args =>
            ref
                .cast<Triangle>()
                .setFromPointsAndIndices(luaVec3Array(vm, args, 0), args[1].intValue(), args[2].intValue(),
                    args[3].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}

/// 读取 Lua 数组/表参数为 Vector3 对象数组（元素须为已注册 Object，逐一 getAs<Vector3>
/// 转换；非对象元素跳过，非数组/表返回空）。用于 setFromPointsAndIndices(Array<Vector3>)。
internal func luaVec3Array(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Vector3> {
    let elems = prebindArray(vm, args, idx)
    var n = 0
    for (elem in elems) {
        if (elem.isObject) {
            n += 1
        }
    }
    var out = Array<Vector3>(n, {_ => Vector3()})
    var k = 0
    for (elem in elems) {
        if (elem.isObject) {
            out[k] = LuaObjectRegistry.getAs<Vector3>(elem.objectId())
            k += 1
        }
    }
    return out
}
