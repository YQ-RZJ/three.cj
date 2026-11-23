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
 * @file[zh-cn] scene_entity_sprite Sprite 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.Sprite 绑定为 Lua 类型 three.scene.entity.Sprite
 * @explain[zh-cn] 覆盖构造（material 可选）、属性 material/center（读写）、intersectsFrustum、
 * raycast、copy、clone、getWorldBoundingSphere。绑定层适配：raycast 的仓颉签名为调用方传入
 * 可变 ArrayList<Intersection>，此处改为「传入 raycaster、返回 Intersection 数组」（raycaster
 * 未设置相机时不命中）；copy 返回自身；clone 返回新 Sprite；getWorldBoundingSphere 返回
 * 数组 {cx, cy, cz, radius} 或 nil。跳过私有静态辅助 _getUnitQuadGeometry（内部单位 quad
 * 面片构建，仅供渲染管线使用）；异常经 try/catch 吞掉后返回空数组/false/nil。
 *
 * @file[en] scene_entity_sprite  Lua binding of Sprite (three.script.prebind)
 * @brief[en] Binds three.scene.entity.Sprite as the Lua type three.scene.entity.Sprite
 * @explain[en] Covers construction (optional material), props material/center (read-write),
 * intersectsFrustum, raycast, copy, clone, getWorldBoundingSphere. Binding adaptations: raycast
 * takes a caller-supplied mutable ArrayList<Intersection> in Cangjie, so here it takes a raycaster
 * and returns an Intersection array (no hit when the raycaster has no camera); copy returns self;
 * clone returns a new Sprite; getWorldBoundingSphere returns {cx, cy, cz, radius} or nil. The
 * private static helper _getUnitQuadGeometry (internal unit-quad building for the render pipeline)
 * is skipped; exceptions are swallowed and yield an empty array / false / nil.
 */
package three.script.prebind

import three.scene.entity.*
import three.scene.objects.*
import three.renderers.materials.*
import three.core.math.*
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Sprite 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.Sprite）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Sprite
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.Sprite)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSprite(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.Sprite")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 1 && args[0].isObject) {
            Sprite(material: prebindAs<Material>(args, 0))
        } else {
            Sprite()
        }
    }
    // ===== 属性 =====
    b.property("material", getter: Some({
        ref => prebindRegister(ref.cast<Sprite>().material, "three.renderers.materials.Material")
    }), setter: Some({
        ref, v => ref.cast<Sprite>().material = prebindAsValue<Material>(v)
    }))
    b.property("center", getter: Some({
        ref => prebindRegister(ref.cast<Sprite>().center, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<Sprite>().center = prebindAsValue<Vector2>(v)
    }))
    // ===== 视锥 =====
    b.method("intersectsFrustum") {
        ref, args => [LuaValue.of(ref.cast<Sprite>().intersectsFrustum(prebindAs<Frustum>(args, 0)))]
    }
    // ===== 射线（绑定层：返回 Intersection 数组） =====
    b.method("raycast") {
        ref, args =>
            var out = Array<LuaValue>()
            try {
                let hits = ArrayList<Intersection>()
                ref.cast<Sprite>().raycast(prebindAs<Raycaster>(args, 0), hits)
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
            ref.cast<Sprite>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Sprite>().clone(), "three.scene.entity.Sprite")]
    }
    // ===== 世界包围球（{cx, cy, cz, radius} / nil） =====
    b.method("getWorldBoundingSphere") {
        ref, _ =>
            var out = LuaValue.Nil
            match (ref.cast<Sprite>().getWorldBoundingSphere()) {
                case Some(buf) =>
                    let arr = Array<LuaValue>(buf.size, {i => LuaValue.of(buf[i])})
                    out = LuaValue.of(arr)
                case None => ()
            }
            [out]
    }
    b.install(vm)
}
