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
 * @file[zh-cn] scene_entity_groundreflector GroundReflector 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.entity.GroundReflector 绑定为 Lua 类型
 * three.scene.entity.GroundReflector
 * @explain[zh-cn] 覆盖无参构造与 (geometry, textureWidth, textureHeight, color, clipBias,
 * useDepthTexture) 构造（位置参数 + 可选参数）、属性 clipBias/useDepthTexture/fresnelCoe/
 * virtualCamera/textureMatrix（读写）、静态常量 REFLECTOR_VIEW_ID_BASE（静态方法读取）、
 * computeVirtualCamera（失败返回 false）、getTextureSize（返回 width, height 两个值）、
 * release（返回 bool）。跳过 ensureRTs（internal）、getReflectFB / getReflectDepthFB /
 * getRenderTarget / getReflectDepthTex（bgfx 的 FrameBufferHandle/TextureHandle 为
 * Box<bgfx4cj 句柄>，无法在 Lua 侧有意义表达）；computeVirtualCamera/release 的异常经
 * try/catch 吞掉，返回 false。继承自 Mesh/Object3D 的成员由对应绑定负责，此处不重复。
 *
 * @file[en] scene_entity_groundreflector  Lua binding of GroundReflector (three.script.prebind)
 * @brief[en] Binds three.scene.entity.GroundReflector as the Lua type
 * three.scene.entity.GroundReflector
 * @explain[en] Covers the no-arg constructor and the (geometry, textureWidth, textureHeight,
 * color, clipBias, useDepthTexture) constructor (positional + optional args), props
 * clipBias/useDepthTexture/fresnelCoe/virtualCamera/textureMatrix (read-write), the static
 * constant REFLECTOR_VIEW_ID_BASE (read via a static method), computeVirtualCamera (false on
 * failure), getTextureSize (returns width, height) and release (bool). ensureRTs (internal) is
 * skipped, and getReflectFB / getReflectDepthFB / getRenderTarget / getReflectDepthTex are
 * skipped (bgfx FrameBufferHandle/TextureHandle are Box<bgfx4cj handle> values that cannot be
 * meaningfully expressed from Lua); exceptions in computeVirtualCamera/release are swallowed and
 * yield false. Members inherited from Mesh/Object3D are provided by their own bindings and not
 * repeated here.
 */
package three.script.prebind

import three.scene.entity.*
import three.renderers.geometry.*
import three.renderers.cameras.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GroundReflector 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.entity.GroundReflector）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GroundReflector
 * @param[en] vm The target virtual machine (class table installed at three.scene.entity.GroundReflector)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGroundReflector(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.entity.GroundReflector")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 1 && args[0].isObject) {
            let color = if (args.size > 3 && args[3].isObject) {
                prebindAs<Color>(args, 3)
            } else {
                Color(0x7f, 0x7f, 0x7f)
            }
            GroundReflector(
                prebindAs<BufferGeometry>(args, 0),
                textureWidth: prebindInt(args, 1, default: 512),
                textureHeight: prebindInt(args, 2, default: 512),
                color: color,
                clipBias: prebindNum(args, 4, default: 0.0),
                useDepthTexture: prebindBool(args, 5, default: false)
            )
        } else {
            GroundReflector()
        }
    }
    // ===== 静态常量 =====
    b.staticMethod("REFLECTOR_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(GroundReflector.REFLECTOR_VIEW_ID_BASE))]
    }
    // ===== 属性 =====
    b.property("clipBias", getter: Some({ref => LuaValue.of(ref.cast<GroundReflector>().clipBias)}),
        setter: Some({ref, v => ref.cast<GroundReflector>().clipBias = v.numberValue()}))
    b.property("useDepthTexture", getter: Some({ref => LuaValue.of(ref.cast<GroundReflector>().useDepthTexture)}),
        setter: Some({ref, v => ref.cast<GroundReflector>().useDepthTexture = v.boolValue()}))
    b.property("fresnelCoe", getter: Some({ref => LuaValue.of(ref.cast<GroundReflector>().fresnelCoe)}),
        setter: Some({ref, v => ref.cast<GroundReflector>().fresnelCoe = v.numberValue()}))
    b.property("virtualCamera", getter: Some({
        ref => prebindRegister(ref.cast<GroundReflector>().virtualCamera, "three.renderers.cameras.PerspectiveCamera")
    }), setter: Some({
        ref, v => ref.cast<GroundReflector>().virtualCamera = prebindAsValue<PerspectiveCamera>(v)
    }))
    b.property("textureMatrix", getter: Some({
        ref => prebindRegister(ref.cast<GroundReflector>().textureMatrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<GroundReflector>().textureMatrix = prebindAsValue<Matrix4>(v)
    }))
    // ===== 镜像虚拟相机 =====
    b.method("computeVirtualCamera") {
        ref, args =>
            var ok = false
            try {
                ok = ref.cast<GroundReflector>().computeVirtualCamera(prebindAs<Camera>(args, 0))
            } catch (_) {
                ok = false
            }
            [LuaValue.of(ok)]
    }
    // ===== 尺寸（返回 width, height 两个值） =====
    b.method("getTextureSize") {
        ref, _ =>
            let (w, h) = ref.cast<GroundReflector>().getTextureSize()
            [LuaValue.of(w), LuaValue.of(h)]
    }
    // ===== 资源释放 =====
    b.method("release") {
        ref, _ =>
            var ok = false
            try {
                ok = ref.cast<GroundReflector>().release()
            } catch (_) {
                ok = false
            }
            [LuaValue.of(ok)]
    }
    b.install(vm)
}
