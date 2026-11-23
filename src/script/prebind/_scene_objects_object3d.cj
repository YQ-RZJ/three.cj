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
 * @file[zh-cn] scene_objects_object3d Object3D 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.objects.Object3D 绑定为 Lua 类型 three.scene.objects.Object3D
 * @explain[zh-cn] 绑定 Object3D 全部可映射的 public 成员：变换（position/rotation/quaternion/
 * scale/pivot/up）、矩阵（matrix/matrixWorld/modelViewMatrix/normalMatrix）、局部/世界矩阵更新、
 * 层级（parent 读写、children 只读 + add/remove/attach/removeFromParent/clear）、可见性与阴影/
 * 剔除标志、旋转与平移辅助方法、localToWorld/worldToLocal 与 getWorld* 系列、遍历与按 id/name/
 * 属性查询、raycast、世界包围球/包围盒查询、getProperty/getUuid 等。组件的 Vector3/Quaternion/
 * Matrix3/Matrix4/Euler 属性 getter 经 prebindRegister 注册，setter 经 prebindAsValue 取回。
 * Group/Scene/ClippingGroup 通过本文件的 prebindInstallObject3DMembers 复用同一批成员，
 * 与既有绑定（Audio/PositionalAudio 共享 _installAudioMembers）保持一致。
 * 跳过成员及原因：
 * - animations：ArrayList<IAnimationClip>，接口实例无法映射为 Lua 类型；
 * - customDepthMaterial / customDistanceMaterial：Option<IMaterial>，接口实例无法映射；
 * - userData：HashMap<String, Any>，任意 Any 值无法安全映射为 Lua 值；
 * - animationsJson / userDataJson / customDepthMaterialJson / customDistanceMaterialJson：
 *   fastjson 序列化辅助属性（默认实现无实际效果），非脚本接口；
 * - operator==：LuaClassBinder 不提供运算符重载绑定；
 * - children：只读数组视图（增删须经 add/remove/attach/clear 以维护 parent 链与结构版本）。
 * structureVersion 静态计数器以静态方法 structureVersion() 暴露。
 * 矩阵求逆（worldToLocal/attach/lookAt）与 raycast 内部异常一律在方法内捕获，失败返回 nil。
 *
 * @file[en] scene_objects_object3d  Lua binding of Object3D (three.script.prebind)
 * @brief[en] Binds three.scene.objects.Object3D as the Lua type three.scene.objects.Object3D
 * @explain[en] Binds every mappable public member of Object3D: transforms (position/rotation/
 * quaternion/scale/pivot/up), matrices (matrix/matrixWorld/modelViewMatrix/normalMatrix),
 * local/world matrix updates, hierarchy (parent read-write, children read-only plus add/remove/
 * attach/removeFromParent/clear), visibility/shadow/culling flags, rotation and translation
 * helpers, localToWorld/worldToLocal and the getWorld* family, traversal and lookups by id/name/
 * property, raycast, world bounding sphere/box queries, getProperty/getUuid, etc. Object-valued
 * properties (Vector3/Quaternion/Matrix3/Matrix4/Euler) are registered by the getter via
 * prebindRegister and fetched by the setter via prebindAsValue.
 * Group/Scene/ClippingGroup reuse the same members through prebindInstallObject3DMembers in
 * this file, matching the existing Audio/PositionalAudio shared-member pattern.
 * Skipped members and reasons:
 * - animations: ArrayList<IAnimationClip>, interface instances have no Lua mapping;
 * - customDepthMaterial / customDistanceMaterial: Option<IMaterial>, interface instances;
 * - userData: HashMap<String, Any>, arbitrary Any values cannot be mapped safely;
 * - animationsJson / userDataJson / customDepthMaterialJson / customDistanceMaterialJson:
 *   fastjson serialization shims (default implementations have no effect), not script APIs;
 * - operator==: LuaClassBinder has no operator-overload binding;
 * - children: exposed as a read-only array view (mutate via add/remove/attach/clear so that the
 *   parent link and the structure version stay consistent).
 * The static counter structureVersion is exposed as the static method structureVersion().
 * Matrix inversions (worldToLocal/attach/lookAt) and raycast failures are caught inside the
 * methods, which return nil instead of letting exceptions escape.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.scene.objects.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 对象列表转 Lua 数组（元素以 three.scene.objects.Object3D 注册）
 * @param[zh-cn] items Object3D 列表
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an object list into a Lua array (elements registered as
 * three.scene.objects.Object3D)
 * @param[en] items The Object3D list
 * @return[en] The Lua array value
 */
internal func prebindObject3DListToLua(items: ArrayList<Object3D>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.scene.objects.Object3D")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 Object3D 的成员（构造除外）
 * @explain[zh-cn] 子类（Group/Scene/ClippingGroup）绑定复用本函数，避免逐个复制成员。
 * 内部统一按 Object3D 强转，因此对任意 Object3D 子类实例均可工作。
 * @param[zh-cn] b 目标类绑定器
 *
 * @brief[en] Installs the Object3D members (except the constructor) on a class binder
 * @explain[en] Subclass bindings (Group/Scene/ClippingGroup) reuse this function instead of
 * duplicating members. Every callback casts to Object3D, so it works for any subclass instance.
 * @param[en] b The target class binder
 */
internal func prebindInstallObject3DMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 变换属性 =====
    b.property("position",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().position, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Object3D>().position = prebindAsValue<Vector3>(v)}))
    b.property("rotation", getter: Some({ref => prebindRegister(ref.cast<Object3D>().rotation, "three.core.math.Euler")}),
        setter: Some({ref, v => ref.cast<Object3D>().rotation = prebindAsValue<Euler>(v)}))
    b.property("quaternion",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().quaternion, "three.core.math.Quaternion")}),
        setter: Some({ref, v => ref.cast<Object3D>().quaternion = prebindAsValue<Quaternion>(v)}))
    b.property("scale", getter: Some({ref => prebindRegister(ref.cast<Object3D>().scale, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Object3D>().scale = prebindAsValue<Vector3>(v)}))
    b.property("pivot", getter: Some({ref => prebindRegister(ref.cast<Object3D>().pivot, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Object3D>().pivot = prebindAsValue<Vector3>(v)}))
    b.property("up", getter: Some({ref => prebindRegister(ref.cast<Object3D>().up, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Object3D>().up = prebindAsValue<Vector3>(v)}))
    // ===== 矩阵属性 =====
    b.property("matrix", getter: Some({ref => prebindRegister(ref.cast<Object3D>().matrix, "three.core.math.Matrix4")}),
        setter: Some({ref, v => ref.cast<Object3D>().matrix = prebindAsValue<Matrix4>(v)}))
    b.property("matrixWorld",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().matrixWorld, "three.core.math.Matrix4")}),
        setter: Some({ref, v => ref.cast<Object3D>().matrixWorld = prebindAsValue<Matrix4>(v)}))
    b.property("modelViewMatrix",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().modelViewMatrix, "three.core.math.Matrix4")}),
        setter: Some({ref, v => ref.cast<Object3D>().modelViewMatrix = prebindAsValue<Matrix4>(v)}))
    b.property("normalMatrix",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().normalMatrix, "three.core.math.Matrix3")}),
        setter: Some({ref, v => ref.cast<Object3D>().normalMatrix = prebindAsValue<Matrix3>(v)}))
    // ===== 更新标志 / 可见性 =====
    b.property("matrixAutoUpdate", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().matrixAutoUpdate)}),
        setter: Some({ref, v => ref.cast<Object3D>().matrixAutoUpdate = v.boolValue()}))
    b.property("matrixWorldAutoUpdate", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().matrixWorldAutoUpdate)}),
        setter: Some({ref, v => ref.cast<Object3D>().matrixWorldAutoUpdate = v.boolValue()}))
    b.property("matrixWorldNeedsUpdate", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().matrixWorldNeedsUpdate)}),
        setter: Some({ref, v => ref.cast<Object3D>().matrixWorldNeedsUpdate = v.boolValue()}))
    b.property("visible", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().visible)}),
        setter: Some({ref, v => ref.cast<Object3D>().visible = v.boolValue()}))
    b.property("castShadow", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().castShadow)}),
        setter: Some({ref, v => ref.cast<Object3D>().castShadow = v.boolValue()}))
    b.property("receiveShadow", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().receiveShadow)}),
        setter: Some({ref, v => ref.cast<Object3D>().receiveShadow = v.boolValue()}))
    b.property("frustumCulled", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().frustumCulled)}),
        setter: Some({ref, v => ref.cast<Object3D>().frustumCulled = v.boolValue()}))
    b.property("isStatic", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().isStatic)}),
        setter: Some({ref, v => ref.cast<Object3D>().isStatic = v.boolValue()}))
    b.property("cullVisible", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().cullVisible)}),
        setter: Some({ref, v => ref.cast<Object3D>().cullVisible = v.boolValue()}))
    b.property("worldBoundingSphereDirty",
        getter: Some({ref => LuaValue.of(ref.cast<Object3D>().worldBoundingSphereDirty)}))
    b.property("renderOrder", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().renderOrder)}),
        setter: Some({ref, v => ref.cast<Object3D>().renderOrder = v.numberValue()}))
    // ===== 图层 =====
    b.property("layers",
        getter: Some({ref => prebindRegister(ref.cast<Object3D>().layers, "three.scene.objects.Layers")}),
        setter: Some({ref, v => ref.cast<Object3D>().layers = prebindAsValue<Layers>(v)}))
    // ===== 标识 =====
    b.property("id", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().id)}),
        setter: Some({ref, v => ref.cast<Object3D>().id = v.intValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().uuid)}),
        setter: Some({ref, v => ref.cast<Object3D>().uuid = v.stringValue()}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<Object3D>().name)}),
        setter: Some({ref, v => ref.cast<Object3D>().name = v.stringValue()}))
    // ===== 层级 =====
    b.property("parent", getter: Some({
        ref => match (ref.cast<Object3D>().parent) {
            case Some(p) => prebindRegister(p, "three.scene.objects.Object3D")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Object3D>().parent = Some(LuaObjectRegistry.getAs<Object3D>(v.objectId()))
        } else {
            ref.cast<Object3D>().parent = None
        }
    }))
    b.property("children", getter: Some({ref => prebindObject3DListToLua(ref.cast<Object3D>().children)}))
    // ===== 矩阵更新 =====
    b.method("updateMatrix") {
        ref, _ =>
            ref.cast<Object3D>().updateMatrix()
            []
    }
    b.method("updateMatrixWorld") {
        ref, args =>
            ref.cast<Object3D>().updateMatrixWorld(prebindBool(args, 0))
            []
    }
    b.method("updateWorldMatrix") {
        ref, args =>
            ref.cast<Object3D>().updateWorldMatrix(prebindBool(args, 0), prebindBool(args, 1), prebindBool(args, 2))
            []
    }
    b.method("invalidateWorldBounds") {
        ref, _ =>
            ref.cast<Object3D>().invalidateWorldBounds()
            []
    }
    // ===== 层级操作 =====
    b.method("add") {
        ref, args =>
            ref.cast<Object3D>().add(prebindAs<Object3D>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("remove") {
        ref, args =>
            ref.cast<Object3D>().remove(prebindAs<Object3D>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("removeFromParent") {
        ref, _ =>
            ref.cast<Object3D>().removeFromParent()
            []
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<Object3D>().clear()
            []
    }
    b.method("attach") {
        ref, args => try {
            ref.cast<Object3D>().attach(prebindAs<Object3D>(args, 0))
            [LuaValue.Object(ref.id)]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    // ===== 拷贝 / 克隆 =====
    b.method("copy") {
        ref, args =>
            ref.cast<Object3D>().copy(prebindAs<Object3D>(args, 0), prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Object3D>().clone(), "three.scene.objects.Object3D")]
    }
    // ===== 朝向 / 变换 =====
    b.method("lookAt") {
        ref, args =>
            try {
                ref.cast<Object3D>().lookAt(prebindAs<Vector3>(args, 0))
            } catch (_: Exception) {
                ()
            }
            []
    }
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Object3D>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            []
    }
    b.method("applyQuaternion") {
        ref, args =>
            ref.cast<Object3D>().applyQuaternion(prebindAs<Quaternion>(args, 0))
            []
    }
    // ===== 旋转 =====
    b.method("setRotationFromAxisAngle") {
        ref, args =>
            ref.cast<Object3D>().setRotationFromAxisAngle(prebindAs<Vector3>(args, 0), prebindNum(args, 1))
            []
    }
    b.method("setRotationFromEuler") {
        ref, args =>
            ref.cast<Object3D>().setRotationFromEuler(prebindAs<Euler>(args, 0))
            []
    }
    b.method("setRotationFromMatrix") {
        ref, args =>
            ref.cast<Object3D>().setRotationFromMatrix(prebindAs<Matrix4>(args, 0))
            []
    }
    b.method("setRotationFromQuaternion") {
        ref, args =>
            ref.cast<Object3D>().setRotationFromQuaternion(prebindAs<Quaternion>(args, 0))
            []
    }
    b.method("rotateOnAxis") {
        ref, args =>
            ref.cast<Object3D>().rotateOnAxis(prebindAs<Vector3>(args, 0), prebindNum(args, 1))
            []
    }
    b.method("rotateOnWorldAxis") {
        ref, args =>
            ref.cast<Object3D>().rotateOnWorldAxis(prebindAs<Vector3>(args, 0), prebindNum(args, 1))
            []
    }
    b.method("rotateX") {
        ref, args =>
            ref.cast<Object3D>().rotateX(prebindNum(args, 0))
            []
    }
    b.method("rotateY") {
        ref, args =>
            ref.cast<Object3D>().rotateY(prebindNum(args, 0))
            []
    }
    b.method("rotateZ") {
        ref, args =>
            ref.cast<Object3D>().rotateZ(prebindNum(args, 0))
            []
    }
    // ===== 平移 =====
    b.method("translateOnAxis") {
        ref, args =>
            ref.cast<Object3D>().translateOnAxis(prebindAs<Vector3>(args, 0), prebindNum(args, 1))
            []
    }
    b.method("translateX") {
        ref, args =>
            ref.cast<Object3D>().translateX(prebindNum(args, 0))
            []
    }
    b.method("translateY") {
        ref, args =>
            ref.cast<Object3D>().translateY(prebindNum(args, 0))
            []
    }
    b.method("translateZ") {
        ref, args =>
            ref.cast<Object3D>().translateZ(prebindNum(args, 0))
            []
    }
    // ===== 坐标变换（target 入参就地修改，返回同一句柄） =====
    b.method("localToWorld") {
        ref, args =>
            ref.cast<Object3D>().localToWorld(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("worldToLocal") {
        ref, args => try {
            ref.cast<Object3D>().worldToLocal(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.method("getWorldPosition") {
        ref, args =>
            ref.cast<Object3D>().getWorldPosition(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("getWorldQuaternion") {
        ref, args =>
            ref.cast<Object3D>().getWorldQuaternion(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("getWorldScale") {
        ref, args =>
            ref.cast<Object3D>().getWorldScale(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.method("getWorldDirection") {
        ref, args =>
            ref.cast<Object3D>().getWorldDirection(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 查询 =====
    b.method("getObjectById") {
        ref, args => match (ref.cast<Object3D>().getObjectById(prebindInt(args, 0))) {
            case Some(o) => [prebindRegister(o, "three.scene.objects.Object3D")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getObjectByName") {
        ref, args => match (ref.cast<Object3D>().getObjectByName(prebindStr(args, 0))) {
            case Some(o) => [prebindRegister(o, "three.scene.objects.Object3D")]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getObjectsByProperty") {
        ref, args =>
            var value: Any = 0
            if (args.size > 1) {
                if (args[1].isString) {
                    value = args[1].stringValue()
                } else if (args[1].isInteger) {
                    value = args[1].intValue()
                } else if (args[1].isNumber) {
                    value = args[1].numberValue()
                }
            }
            let result = ArrayList<Object3D>()
            ref.cast<Object3D>().getObjectsByProperty(prebindStr(args, 0), value, result)
            [prebindObject3DListToLua(result)]
    }
    b.method("getProperty") {
        ref, args => match (ref.cast<Object3D>().getProperty(prebindStr(args, 0))) {
            case s: String => [LuaValue.of(s)]
            case i: Int64 => [LuaValue.of(i)]
            case f: Float64 => [LuaValue.of(f)]
            case _ => [LuaValue.Nil]
        }
    }
    b.method("getUuid") {
        ref, _ => [LuaValue.of(ref.cast<Object3D>().getUuid())]
    }
    b.method("getChildCount") {
        ref, _ => [LuaValue.of(ref.cast<Object3D>().getChildCount())]
    }
    b.method("getChildAt") {
        ref, args => match (ref.cast<Object3D>().getChildAt(prebindInt(args, 0))) {
            case o: Object3D => [prebindRegister(o, "three.scene.objects.Object3D")]
            case _ => [LuaValue.Nil]
        }
    }
    // ===== 遍历（Lua 函数回调） =====
    b.method("traverse") {
        ref, args =>
            let cb = prebindOptCallback(vm, args, 0)
            ref.cast<Object3D>().traverse({
                child: Object3D => if (let Some(c) <- cb) {
                    try {
                        c.call(args: [prebindRegister(child, "three.scene.objects.Object3D")])
                    } catch (_: Exception) {
                        ()
                    }
                }
            })
            []
    }
    b.method("traverseVisible") {
        ref, args =>
            let cb = prebindOptCallback(vm, args, 0)
            ref.cast<Object3D>().traverseVisible({
                child: Object3D => if (let Some(c) <- cb) {
                    try {
                        c.call(args: [prebindRegister(child, "three.scene.objects.Object3D")])
                    } catch (_: Exception) {
                        ()
                    }
                }
            })
            []
    }
    b.method("traverseAncestors") {
        ref, args =>
            let cb = prebindOptCallback(vm, args, 0)
            ref.cast<Object3D>().traverseAncestors({
                child: Object3D => if (let Some(c) <- cb) {
                    try {
                        c.call(args: [prebindRegister(child, "three.scene.objects.Object3D")])
                    } catch (_: Exception) {
                        ()
                    }
                }
            })
            []
    }
    // ===== 射线检测 =====
    b.method("raycast") {
        ref, args => try {
            let hits = ArrayList<Intersection>()
            ref.cast<Object3D>().raycast(prebindAs<Raycaster>(args, 0), hits)
            let n = hits.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = prebindRegister(hits[i], "three.scene.objects.Intersection")
            }
            [LuaValue.Array(out)]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    // ===== 包围体 =====
    b.method("getWorldBoundingSphere") {
        ref, _ => match (ref.cast<Object3D>().getWorldBoundingSphere()) {
            case Some(s) => [LuaValue.of(s)]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getWorldBoundingBox") {
        ref, _ => match (ref.cast<Object3D>().getWorldBoundingBox()) {
            case Some(bb) =>
                let (mn, mx) = bb
                [LuaValue.Array([LuaValue.of(mn), LuaValue.of(mx)])]
            case None => [LuaValue.Nil]
        }
    }
    b.method("getPreciseVertexCount") {
        ref, _ => [LuaValue.of(ref.cast<Object3D>().getPreciseVertexCount())]
    }
    b.method("getPreciseVertexPosition") {
        ref, args => [LuaValue.of(ref.cast<Object3D>().getPreciseVertexPosition(prebindInt(args, 0)))]
    }
    // ===== 渲染钩子（基类为空实现，子类可覆写） =====
    b.method("onBeforeShadow") {
        ref, _ =>
            ref.cast<Object3D>().onBeforeShadow()
            []
    }
    b.method("onAfterShadow") {
        ref, _ =>
            ref.cast<Object3D>().onAfterShadow()
            []
    }
    b.method("onBeforeRender") {
        ref, _ =>
            ref.cast<Object3D>().onBeforeRender()
            []
    }
    b.method("onAfterRender") {
        ref, _ =>
            ref.cast<Object3D>().onAfterRender()
            []
    }
}

/**
 * @brief[zh-cn] 安装 Object3D 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.objects.Object3D）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Object3D
 * @param[en] vm The target virtual machine (class table installed at three.scene.objects.Object3D)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installObject3D(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.objects.Object3D")
    // ===== 构造 =====
    b.constructor {_ => Object3D()}
    // ===== 静态：场景结构版本 =====
    b.staticMethod("structureVersion") {_ => [LuaValue.of(Object3D.structureVersion)]}
    // ===== 实例成员 =====
    prebindInstallObject3DMembers(b, vm)
    b.install(vm)
}
