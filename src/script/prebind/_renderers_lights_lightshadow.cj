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
 * @file[zh-cn] renderers_lights_lightshadow 阴影配置基类 LightShadow 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.LightShadow 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 绑定构造（可选 camera）、属性（camera / intensity / bias / normalBias / radius /
 * blurSamples / mapSize / mapType / map / mapPass / matrix / autoUpdate / needsUpdate / smType /
 * depthImpl / packDepth / cascadeCount / cascadeLambda / cascadeSplits / cascadeCameras /
 * releasable）与方法（getViewportCount / getFrustum / updateMatrices / calculateCascadeSplits /
 * initCascadeCameras / updateCascadeMatrices / getViewport / getFrameExtents / release / copy /
 * clone）。map/mapPass 为 Option<RenderTarget>，None 用 nil；cascadeSplits 为数值数组，
 * cascadeCameras 为 OrthographicCamera 对象数组；Vector2/Vector4/Matrix4/Frustum 均以对象往返。
 * Lua 类表没有继承，DirectionalLightShadow / PointLightShadow / SpotLightShadow 的绑定都必须在
 * b.install 之前调用 _prebindLgtLightShadowMembers。updateMatrices/copy 按 LightShadow 强转后
 * 经虚函数分派，子类覆写自动生效；私有字段 _frustum/_frameExtents/_viewportCount/_viewports
 * 不生成 Lua 成员，其中可读部分经 getFrustum/getFrameExtents/getViewportCount/getViewport 暴露。
 *
 * @file[en] renderers_lights_lightshadow  Lua binding of the LightShadow base class
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.LightShadow and exports the shared subclass member installer
 * @explain[en] Binds the constructor (optional camera), properties (camera / intensity / bias /
 * normalBias / radius / blurSamples / mapSize / mapType / map / mapPass / matrix / autoUpdate /
 * needsUpdate / smType / depthImpl / packDepth / cascadeCount / cascadeLambda / cascadeSplits /
 * cascadeCameras / releasable) and methods (getViewportCount / getFrustum / updateMatrices /
 * calculateCascadeSplits / initCascadeCameras / updateCascadeMatrices / getViewport /
 * getFrameExtents / release / copy / clone). map/mapPass are Option<RenderTarget> with nil for None;
 * cascadeSplits is a numeric array and cascadeCameras an OrthographicCamera object array;
 * Vector2/Vector4/Matrix4/Frustum round-trip as objects. Lua class tables have no inheritance, so
 * the DirectionalLightShadow / PointLightShadow / SpotLightShadow bindings must call
 * _prebindLgtLightShadowMembers before b.install. updateMatrices/copy cast to LightShadow and rely
 * on virtual dispatch, so subclass overrides apply. The private fields _frustum/_frameExtents/
 * _viewportCount/_viewports generate no Lua members; the readable parts are exposed through
 * getFrustum/getFrameExtents/getViewportCount/getViewport.
 */
package three.script.prebind

import std.collection.*
import three.renderers.lights.*
import three.renderers.cameras.*
import three.renderers.rendertarget.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将可选渲染目标转为 Lua 值（Some 注册对象，None 返回 nil）
 * @param[zh-cn] rt 可选渲染目标
 * @return[zh-cn] Lua 值
 *
 * @brief[en] Converts an optional render target into a Lua value (Some registers, None is nil)
 * @param[en] rt The optional render target
 * @return[en] The Lua value
 */
internal func _prebindLgtRenderTargetToLua(rt: Option<RenderTarget>): LuaValue {
    match (rt) {
        case Some(r) => prebindRegister(r, "three.renderers.rendertarget.RenderTarget")
        case None => LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 将 Lua 值转为可选渲染目标（nil/非对象返回 None）
 * @param[zh-cn] v Lua 值
 * @return[zh-cn] 可选渲染目标
 *
 * @brief[en] Converts a Lua value into an optional render target (nil/non-object yields None)
 * @param[en] v The Lua value
 * @return[en] The optional render target
 */
internal func _prebindLgtRenderTargetFromLua(v: LuaValue): Option<RenderTarget> {
    if (v.isNil || !v.isObject) {
        return None
    }
    return Some(prebindAsValue<RenderTarget>(v))
}

/**
 * @brief[zh-cn] 将正交相机列表转为 Lua 对象数组
 * @param[zh-cn] items 正交相机列表
 * @return[zh-cn] Lua 数组值（元素注册为 OrthographicCamera）
 *
 * @brief[en] Converts an orthographic-camera list into a Lua object array
 * @param[en] items The orthographic camera list
 * @return[en] Lua array value (elements registered as OrthographicCamera)
 */
internal func _prebindLgtCameraListToLua(items: ArrayList<OrthographicCamera>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.renderers.cameras.OrthographicCamera")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 LightShadow 的成员（构造除外）
 * @explain[zh-cn] Lua 类表没有继承，所有 LightShadow 子类的绑定都必须在 b.install 之前调用本函数，
 * 否则子类实例只能看到自己新增的成员。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 数组参数需经此读取）
 *
 * @brief[en] Installs the LightShadow members (except the constructor) on a binder
 * @explain[en] Lua class tables have no inheritance, so every LightShadow subclass binding must call
 * this before b.install; otherwise instances only expose their own extra members.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua array arguments)
 */
internal func _prebindLgtLightShadowMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 相机 / 采样参数 =====
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<LightShadow>().camera, "three.renderers.cameras.Camera")
    }), setter: Some({
        ref, v => ref.cast<LightShadow>().camera = prebindAsValue<Camera>(v)
    }))
    b.property("intensity", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().intensity)}),
        setter: Some({ref, v => ref.cast<LightShadow>().intensity = v.numberValue()}))
    b.property("bias", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().bias)}),
        setter: Some({ref, v => ref.cast<LightShadow>().bias = v.numberValue()}))
    b.property("normalBias", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().normalBias)}),
        setter: Some({ref, v => ref.cast<LightShadow>().normalBias = v.numberValue()}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().radius)}),
        setter: Some({ref, v => ref.cast<LightShadow>().radius = v.numberValue()}))
    b.property("blurSamples", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().blurSamples)}),
        setter: Some({ref, v => ref.cast<LightShadow>().blurSamples = v.intValue()}))
    // ===== 贴图 =====
    b.property("mapSize", getter: Some({
        ref => prebindRegister(ref.cast<LightShadow>().mapSize, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<LightShadow>().mapSize = prebindAsValue<Vector2>(v)
    }))
    b.property("mapType", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().mapType)}),
        setter: Some({ref, v => ref.cast<LightShadow>().mapType = v.intValue()}))
    b.property("map", getter: Some({ref => _prebindLgtRenderTargetToLua(ref.cast<LightShadow>().map)}), setter: Some({
        ref, v => ref.cast<LightShadow>().map = _prebindLgtRenderTargetFromLua(v)
    }))
    b.property("mapPass", getter: Some({ref => _prebindLgtRenderTargetToLua(ref.cast<LightShadow>().mapPass)}),
        setter: Some({
            ref, v => ref.cast<LightShadow>().mapPass = _prebindLgtRenderTargetFromLua(v)
        }))
    // ===== 矩阵 / 更新标志 =====
    b.property("matrix", getter: Some({
        ref => prebindRegister(ref.cast<LightShadow>().matrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<LightShadow>().matrix = prebindAsValue<Matrix4>(v)
    }))
    b.property("autoUpdate", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().autoUpdate)}),
        setter: Some({ref, v => ref.cast<LightShadow>().autoUpdate = v.boolValue()}))
    b.property("needsUpdate", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().needsUpdate)}),
        setter: Some({ref, v => ref.cast<LightShadow>().needsUpdate = v.boolValue()}))
    // ===== 分布 / 深度 / 打包 =====
    b.property("smType", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().smType)}),
        setter: Some({ref, v => ref.cast<LightShadow>().smType = v.intValue()}))
    b.property("depthImpl", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().depthImpl)}),
        setter: Some({ref, v => ref.cast<LightShadow>().depthImpl = v.intValue()}))
    b.property("packDepth", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().packDepth)}),
        setter: Some({ref, v => ref.cast<LightShadow>().packDepth = v.intValue()}))
    // ===== CSM 级联 =====
    b.property("cascadeCount", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().cascadeCount)}),
        setter: Some({ref, v => ref.cast<LightShadow>().cascadeCount = v.intValue()}))
    b.property("cascadeLambda", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().cascadeLambda)}),
        setter: Some({ref, v => ref.cast<LightShadow>().cascadeLambda = v.numberValue()}))
    b.property("cascadeSplits", getter: Some({ref => prebindF64ListToLua(ref.cast<LightShadow>().cascadeSplits)}),
        setter: Some({
            ref, v => ref.cast<LightShadow>().cascadeSplits = prebindF64List(vm, [v], 0)
        }))
    b.property("cascadeCameras",
        getter: Some({ref => _prebindLgtCameraListToLua(ref.cast<LightShadow>().cascadeCameras)}), setter: Some({
            ref, v => ref.cast<LightShadow>().cascadeCameras = prebindObjList<OrthographicCamera>(vm, [v], 0)
        }))
    // ===== 视口 / 视锥查询 =====
    b.method("getViewportCount") {
        ref, _ => [LuaValue.of(ref.cast<LightShadow>().getViewportCount())]
    }
    b.method("getFrustum") {
        ref, _ => [prebindRegister(ref.cast<LightShadow>().getFrustum(), "three.core.math.Frustum")]
    }
    b.method("getViewport") {
        ref, args => [prebindRegister(ref.cast<LightShadow>().getViewport(prebindInt(args, 0)),
            "three.core.math.Vector4")]
    }
    b.method("getFrameExtents") {
        ref, _ => [prebindRegister(ref.cast<LightShadow>().getFrameExtents(), "three.core.math.Vector2")]
    }
    // ===== 更新 =====
    b.method("updateMatrices") {
        ref, args =>
            ref.cast<LightShadow>().updateMatrices(prebindAs<Light>(args, 0))
            []
    }
    b.method("calculateCascadeSplits") {
        ref, args => [prebindF64ListToLua(
            ref
                .cast<LightShadow>()
                .calculateCascadeSplits(prebindInt(args, 0), prebindNum(args, 1), prebindNum(args, 2),
                    prebindNum(args, 3)))]
    }
    b.method("initCascadeCameras") {
        ref, _ =>
            ref.cast<LightShadow>().initCascadeCameras()
            []
    }
    b.method("updateCascadeMatrices") {
        ref, args =>
            ref
                .cast<LightShadow>()
                .updateCascadeMatrices(prebindAs<Light>(args, 0), prebindAs<Camera>(args, 1), prebindInt(args, 2))
            []
    }
    // ===== 生命周期 / 拷贝 =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<LightShadow>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<LightShadow>().release())]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<LightShadow>().copy(prebindAs<LightShadow>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<LightShadow>().clone(), "three.renderers.lights.LightShadow")]
    }
}

/**
 * @brief[zh-cn] 安装 LightShadow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.LightShadow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LightShadow
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.LightShadow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLightShadow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.LightShadow")
    // ===== 构造：可选 camera =====
    b.constructor {
        args => if (args.size > 0 && !args[0].isNil && args[0].isObject) {
            LightShadow(prebindAsValue<Camera>(args[0]))
        } else {
            LightShadow()
        }
    }
    // ===== LightShadow 自有成员 =====
    _prebindLgtLightShadowMembers(b, vm)
    b.install(vm)
}
