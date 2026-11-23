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
 * @file[zh-cn] core_math_frustum 视锥体 Frustum 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Frustum 绑定为 Lua 类型 three.core.math.Frustum
 * @explain[zh-cn] 覆盖构造（new）、实例方法（set/setFromProjectionMatrix/containsPoint/
 * intersectsSphere/intersectsSphereArray/intersectsBox/intersectsBoxComponents/
 * intersectsSphereComponents/intersectsObject/intersectsSprite/clone/copy/equals）与属性
 * planes（Lua 表 ↔ Array<Plane>，读写）、isFrustum（只读标记）。互变异构方法均返回
 * 自身（Lua 链式可用）。setFromProjectionMatrix 的 coordinateSystem/reversedDepth 可
 * 选传参；intersectsObject/intersectsSprite 的 IFrustumCullable 接口参数按既有核心
 * 绑定（如 Box3.setFromObject）惯例处理。
 *
 * @file[en] core_math_frustum Lua binding of the frustum Frustum (three.script.prebind)
 * @brief[en] Binds three.core.math.Frustum as the Lua type three.core.math.Frustum
 * @explain[en] Covers construction (new), instance methods (set/setFromProjectionMatrix/
 * containsPoint/intersectsSphere/intersectsSphereArray/intersectsBox/
 * intersectsBoxComponents/intersectsSphereComponents/intersectsObject/intersectsSprite/
 * clone/copy/equals) and properties planes (Lua table ↔ Array<Plane>, read-write) and
 * isFrustum (read-only marker). Mutating methods return self for Lua chaining.
 * setFromProjectionMatrix takes optional coordinateSystem/reversedDepth arguments; the
 * IFrustumCullable interface arguments of intersectsObject/intersectsSprite follow
 * existing core-binding conventions (e.g. Box3.setFromObject).
 */
package three.script.prebind

import three.core.math.*
import three.core._interfaces.*
import three.utils.constants.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Frustum 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Frustum）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Frustum
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Frustum)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFrustum(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Frustum")
    // ===== 构造（仅无参） =====
    b.constructor {
        _ => Frustum()
    }
    // ===== 属性 =====
    b.property(
        "planes",
        getter: Some(
            {
                ref =>
                    let src = ref.cast<Frustum>().planes
                    let arr = Array<LuaValue>(src.size, {i => prebindRegister(src[i], "three.core.math.Plane")})
                    LuaValue.of(arr)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let vals = v.arrayValues()
                    let arr = Array<Plane>(vals.size, {i => LuaObjectRegistry.getAs<Plane>(vals[i].objectId())})
                    ref.cast<Frustum>().planes = arr
            }
        )
    )
    b.property("isFrustum", getter: Some({ref => LuaValue.of(ref.cast<Frustum>().isFrustum)}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref
                .cast<Frustum>()
                .set(prebindAs<Plane>(args, 0), prebindAs<Plane>(args, 1), prebindAs<Plane>(args, 2),
                    prebindAs<Plane>(args, 3), prebindAs<Plane>(args, 4), prebindAs<Plane>(args, 5))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromProjectionMatrix") {
        ref, args =>
            ref
                .cast<Frustum>()
                .setFromProjectionMatrix(prebindAs<Matrix4>(args, 0),
                    coordinateSystem: prebindInt(args, 1, default: WebGPUCoordinateSystem),
                    reversedDepth: prebindBool(args, 2))
            [LuaValue.Object(ref.id)]
    }
    // ===== 包含/相交 =====
    b.method("containsPoint") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().containsPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("intersectsSphere") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().intersectsSphere(prebindAs<Sphere>(args, 0)))]
    }
    b.method("intersectsSphereArray") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().intersectsSphereArray(args[0].toArrayFloat()))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    b.method("intersectsBoxComponents") {
        ref, args => [LuaValue.of(
            ref
                .cast<Frustum>()
                .intersectsBoxComponents(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue(), args[4].numberValue(), args[5].numberValue()))]
    }
    b.method("intersectsSphereComponents") {
        ref, args => [LuaValue.of(
            ref
                .cast<Frustum>()
                .intersectsSphereComponents(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue()))]
    }
    b.method("intersectsObject") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().intersectsObject(prebindAs<IFrustumCullable>(args, 0)))]
    }
    b.method("intersectsSprite") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().intersectsSprite(prebindAs<IFrustumCullable>(args, 0)))]
    }
    // ===== 克隆/复制/比较 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Frustum>().clone(), "three.core.math.Frustum")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Frustum>().copy(prebindAs<Frustum>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Frustum>().equals(prebindAs<Frustum>(args, 0)))]
    }
    b.install(vm)
}
