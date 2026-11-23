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
 * @file[zh-cn] scene_entity_linesegments LineSegments 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.LineSegments 绑定为 Lua 类型 three.scene.entity.LineSegments
 * @explain[zh-cn] LineSegments 继承 Line，仅重写 computeLineDistances（按线段逐段距离）。
 * 绑定框架的类表无继承链，故在 LineSegments 类表上重复暴露 Line 成员：属性 geometry/material、
 * computeLineDistances、intersectsFrustum、raycast、copy、clone。绑定层适配：
 * raycast 改为「传入 raycaster、返回 Intersection 数组」；copy 返回自身；clone 沿用
 * Line.clone 语义（返回 Line 实例，注册为 three.scene.entity.Line）。
 * 跳过 getCullingGeometry（返回 IGeometryProvider 接口实例），异常经 try/catch 吞掉后
 * 返回空数组/false/nil。索引几何调用 computeLineDistances 时引擎仅告警，绑定不改写行为。
 *
 * @file[en] scene_entity_linesegments  Lua binding of LineSegments (three.script.prebind)
 * @brief[en] Binds three.scene.entity.LineSegments as the Lua type three.scene.entity.LineSegments
 * @explain[en] LineSegments extends Line and only overrides computeLineDistances (per-segment
 * distances). Binding class tables have no inheritance chain, so Line's members are re-exposed
 * on the LineSegments table: geometry/material props, computeLineDistances, intersectsFrustum,
 * raycast, copy, clone. Binding adaptations: raycast takes a raycaster and returns an
 * Intersection array; copy returns self; clone keeps Line.clone semantics (yields a Line
 * instance registered as three.scene.entity.Line). getCullingGeometry is skipped (returns an
 * IGeometryProvider interface instance); exceptions are swallowed and yield an empty array /
 * false / nil. For indexed geometry computeLineDistances only logs a warning in the engine,
 * which the binding leaves unchanged.
 */
package three.script.prebind

import three.scene.entity.*
import three.scene.objects.*
import three.renderers.geometry.*
import three.renderers.materials.*
import three.core.math.*
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LineSegments 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.LineSegments）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LineSegments
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.LineSegments)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLineSegments(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.LineSegments")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2 && args[1].isObject) {
            LineSegments(geometry: prebindAs<BufferGeometry>(args, 0), material: prebindAs<Material>(args, 1))
        } else if (args.size >= 1 && args[0].isObject) {
            LineSegments(geometry: prebindAs<BufferGeometry>(args, 0))
        } else {
            LineSegments()
        }
    }
    // ===== 属性（继承自 Line） =====
    b.property("geometry", getter: Some({
        ref => prebindRegister(ref.cast<LineSegments>().geometry, "three.renderers.geometry.BufferGeometry")
    }), setter: Some({
        ref, v => ref.cast<LineSegments>().geometry = prebindAsValue<BufferGeometry>(v)
    }))
    b.property("material", getter: Some({
        ref => prebindRegister(ref.cast<LineSegments>().material, "three.renderers.materials.Material")
    }), setter: Some({
        ref, v => ref.cast<LineSegments>().material = prebindAsValue<Material>(v)
    }))
    // ===== 逐段距离（重写；返回自身） =====
    b.method("computeLineDistances") {
        ref, _ =>
            ref.cast<LineSegments>().computeLineDistances()
            [LuaValue.Object(ref.id)]
    }
    // ===== 视锥 =====
    b.method("intersectsFrustum") {
        ref, args => [LuaValue.of(ref.cast<LineSegments>().intersectsFrustum(prebindAs<Frustum>(args, 0)))]
    }
    // ===== 射线（绑定层：返回 Intersection 数组） =====
    b.method("raycast") {
        ref, args =>
            var out = Array<LuaValue>()
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<LineSegments>().raycast(prebindAs<Raycaster>(args, 0), hits)
                out = Array<LuaValue>(hits.size, {
                    i => prebindRegister(hits[i], "three.scene.objects.Intersection")
                })
            } catch (_) {
                out = Array<LuaValue>()
            }
            [LuaValue.of(out)]
    }
    // ===== 复制 / 克隆 =====
    b.method("copy") {
        ref, args =>
            ref.cast<LineSegments>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<LineSegments>().clone(), "three.scene.entity.Line")]
    }
    b.install(vm)
}
