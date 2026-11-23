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
 * @file[zh-cn] renderers_postprocessing_pass 后处理 Pass 基类的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.Pass 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 绑定 Pass 的全部可映射成员：isPass / enabled / needsSwap / clear /
 * renderToScreen / quad（Option<FullScreenQuad>）、setQuad / onAttach / setSize /
 * release 以及只读 releasable（Pass 实现 IReleasable）；并暴露自定义 pass 所需的高阶渲染 API：
 * submitQuad / submitQuadWithState / setRenderTarget / setViewport / clearRenderTarget /
 * bindTexture / getTexture / setUniformFloats / setStencil / touchView /
 * setScalarUniform / setVec2Uniform / setVec4Uniform / cachedUniform / passUniforms /
 * disposePassUniforms（句柄参数与返回值统一使用整数 idx，见 renderers_gfx_gfxhandles）。
 * 导出 _prebindPpPassMembers 供全部 Pass 子类复用（Lua 类表没有继承，子类必须在
 * b.install 之前调用它）。所有回调按 Pass 强转，经虚函数分派到子类实现。
 * 使用前提：setSize / onAttach 会触发 pass 内部渲染目标的创建/销毁（经抽象后端），
 * 必须由引擎完成渲染后端初始化后才能调用；构造与属性读写等纯数据操作可安全调用。
 * 跳过成员及原因：
 * - render(renderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle,
 *   deltaTime)：参数为抽象层帧缓冲句柄，且渲染由 EffectComposer.render 统一驱动，不在脚本层重写。
 *
 * @file[en] renderers_postprocessing_pass  Lua binding of the post-processing Pass base class
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.Pass and exports the shared subclass installer
 * @explain[en] Binds every mappable Pass member: isPass / enabled / needsSwap / clear /
 * renderToScreen / quad (Option<FullScreenQuad>), setQuad / onAttach / setSize / release and the
 * read-only releasable (Pass implements IReleasable); also exposes the high-level renderers API a
 * custom pass needs: submitQuad / submitQuadWithState / setRenderTarget / setViewport /
 * clearRenderTarget / bindTexture / getTexture / setUniformFloats / setStencil / touchView /
 * setScalarUniform / setVec2Uniform / setVec4Uniform / cachedUniform / passUniforms /
 * disposePassUniforms (handle params/returns use the integer idx; see renderers_gfx_gfxhandles).
 * _prebindPpPassMembers is exported for every Pass subclass (Lua class tables have no inheritance,
 * so subclasses must call it before b.install). All callbacks cast to Pass and rely on virtual
 * dispatch.
 * Precondition: setSize / onAttach trigger creation/destruction of the pass-internal render
 * targets (through the abstract backend) and may only be called after the engine has finished
 * render-backend initialization; construction and property access are pure data operations and
 * safe at any time.
 * Skipped members and reasons:
 * - render(renderer, writeBuffer: GfxFrameBufferHandle, readBuffer: GfxFrameBufferHandle,
 *   deltaTime): the buffers are abstract frame-buffer handles and renderers is driven centrally by
 *   EffectComposer.render, so it is not overridden from scripts.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.renderers.textures.EngineDataTexture
import three.renderers.ThreeRenderer
import three.scene.objects.Object3D
import three.core.math.{Vector2, Color}
import std.collection.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安全读取可选 Vector2 参数（缺失 / nil / 非对象返回默认值）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] Vector2 参数值
 *
 * @brief[en] Reads an optional Vector2 argument (absent / nil / non-object returns the default)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @param[en] default The default value
 * @return[en] The Vector2 argument value
 */
internal func _prebindPpVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2 = Vector2()): Vector2 {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return default
    }
    return LuaObjectRegistry.getAs<Vector2>(args[idx].objectId())
}

/**
 * @brief[zh-cn] 安全读取可选 Color 参数（缺失 / nil / 非对象返回默认值）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] Color 参数值
 *
 * @brief[en] Reads an optional Color argument (absent / nil / non-object returns the default)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @param[en] default The default value
 * @return[en] The Color argument value
 */
internal func _prebindPpColor(args: Array<LuaValue>, idx: Int64, default!: Color = Color(0, 0, 0)): Color {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return default
    }
    return LuaObjectRegistry.getAs<Color>(args[idx].objectId())
}

/**
 * @brief[zh-cn] 安全读取可选 EngineDataTexture 参数（缺失 / nil / 非对象返回无效占位实例）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 数据纹理（无效实例由关联 pass 跳过绘制）
 *
 * @brief[en] Reads an optional EngineDataTexture argument (absent / nil / non-object returns the
 * invalid placeholder instance)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The data texture (an invalid instance makes the associated pass skip drawing)
 */
internal func _prebindPpDataTexture(args: Array<LuaValue>, idx: Int64): EngineDataTexture {
    if (args.size <= idx || !args[idx].isObject) {
        return EngineDataTexture.invalid()
    }
    return prebindAs<EngineDataTexture>(args, idx)
}

/**
 * @brief[zh-cn] 将 pass 链转为 Lua 数组（元素按 Pass 类名注册）
 * @param[zh-cn] list pass 链
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a pass chain into a Lua array (elements registered as Pass)
 * @param[en] list The pass chain
 * @return[en] The Lua array value
 */
internal func _prebindPpPassArrayToLua(list: ArrayList<Pass>): LuaValue {
    let n = list.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(list[i], "three.renderers.postprocessing.Pass")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将 Lua 数组转为 pass 链（元素须为已注册 Pass 对象）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] v 待转换的 Lua 值
 * @return[zh-cn] pass 链
 *
 * @brief[en] Converts a Lua array into a pass chain (elements must be registered Pass objects)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] v The Lua value to convert
 * @return[en] The pass chain
 */
internal func _prebindPpPassArrayFromLua(vm: LuaVM, v: LuaValue): ArrayList<Pass> {
    return prebindObjList<Pass>(vm, [v], 0)
}

/**
 * @brief[zh-cn] 将 Object3D 列表转为 Lua 数组
 * @param[zh-cn] list 物体列表
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an Object3D list into a Lua array
 * @param[en] list The object list
 * @return[en] The Lua array value
 */
internal func _prebindPpObj3DListToLua(list: ArrayList<Object3D>): LuaValue {
    let n = list.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(list[i], "three.scene.objects.Object3D")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 Pass 的成员（构造除外）
 * @explain[zh-cn] 每个 Pass 子类绑定复用本函数（每个子类独立 metatable，无 __index 继承链），
 * 所有回调按 Pass 强转，因此对任意子类实例均可工作。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the Pass members (except the constructor) on a binder
 * @explain[en] Every Pass subclass binding reuses this function (each subclass has its own
 * metatable and there is no __index inheritance chain); the callbacks cast to Pass, so they work
 * for any subclass instance.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindPpPassMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 标识与链控制 =====
    b.property("isPass", getter: Some({ref => LuaValue.of(ref.cast<Pass>().isPass)}))
    b.property("enabled", getter: Some({ref => LuaValue.of(ref.cast<Pass>().enabled)}),
        setter: Some({ref, v => ref.cast<Pass>().enabled = v.boolValue()}))
    b.property("needsSwap", getter: Some({ref => LuaValue.of(ref.cast<Pass>().needsSwap)}),
        setter: Some({ref, v => ref.cast<Pass>().needsSwap = v.boolValue()}))
    b.property("clear", getter: Some({ref => LuaValue.of(ref.cast<Pass>().clear)}),
        setter: Some({ref, v => ref.cast<Pass>().clear = v.boolValue()}))
    b.property("renderToScreen", getter: Some({ref => LuaValue.of(ref.cast<Pass>().renderToScreen)}),
        setter: Some({ref, v => ref.cast<Pass>().renderToScreen = v.boolValue()}))
    // ===== 共享全屏 quad =====
    b.property("quad", getter: Some({
        ref => match (ref.cast<Pass>().quad) {
            case Some(q) => prebindRegister(q, "three.renderers.postprocessing.FullScreenQuad")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<Pass>().quad = if (v.isObject) {
            Some(prebindAsValue<FullScreenQuad>(v))
        } else {
            None
        }
    }))
    b.method("setQuad") {
        ref, args =>
            ref.cast<Pass>().setQuad(prebindAs<FullScreenQuad>(args, 0))
            Array<LuaValue>()
    }
    // ===== 生命周期 =====
    b.method("onAttach") {
        ref, args =>
            ref.cast<Pass>().onAttach(prebindAs<EffectComposer>(args, 0))
            Array<LuaValue>()
    }
    b.method("setSize") {
        ref, args =>
            ref.cast<Pass>().setSize(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<Pass>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Pass>().release())]
    }
    // ===== 自定义 pass 的高阶渲染 API（句柄一律用整数 idx） =====
    b.method("submitQuad") {
        ref, args =>
            ref.cast<Pass>().submitQuad(UInt16(prebindInt(args, 0) & 0xFFFF), prebindProgramHandle(args, 1))
            Array<LuaValue>()
    }
    b.method("submitQuadWithState") {
        ref, args =>
            ref
                .cast<Pass>()
                .submitQuadWithState(UInt16(prebindInt(args, 0) & 0xFFFF), prebindProgramHandle(args, 1),
                    UInt64(prebindInt(args, 2)))
            Array<LuaValue>()
    }
    b.method("setRenderTarget") {
        ref, args =>
            ref
                .cast<Pass>()
                .setRenderTarget(prebindAs<ThreeRenderer>(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
                    prebindFrameBufferHandle(args, 2))
            Array<LuaValue>()
    }
    b.method("setViewport") {
        ref, args =>
            ref
                .cast<Pass>()
                .setViewport(prebindAs<ThreeRenderer>(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
                    UInt16(prebindInt(args, 2) & 0xFFFF), UInt16(prebindInt(args, 3) & 0xFFFF),
                    UInt16(prebindInt(args, 4) & 0xFFFF), UInt16(prebindInt(args, 5) & 0xFFFF))
            Array<LuaValue>()
    }
    b.method("clearRenderTarget") {
        ref, args =>
            ref
                .cast<Pass>()
                .clearRenderTarget(prebindAs<ThreeRenderer>(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
                    UInt16(prebindInt(args, 2) & 0xFFFF), UInt32(prebindInt(args, 3) & 0xFFFFFFFF),
                    depth: Float32(prebindNum(args, 4, default: 1.0)), stencil: UInt8(prebindInt(args, 5) & 0xFF))
            Array<LuaValue>()
    }
    b.method("bindTexture") {
        ref, args =>
            ref
                .cast<Pass>()
                .bindTexture(prebindAs<ThreeRenderer>(args, 0), UInt8(prebindInt(args, 1) & 0xFF),
                    prebindUniformHandle(args, 2), prebindTextureHandle(args, 3), UInt32(prebindInt(args, 4) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.method("getTexture") {
        ref, args => [LuaValue.of(
            prebindGfxHandleIdx(
                ref
                    .cast<Pass>()
                    .getTexture(prebindAs<ThreeRenderer>(args, 0), prebindFrameBufferHandle(args, 1),
                        UInt8(prebindInt(args, 2) & 0xFF))))]
    }
    b.method("setUniformFloats") {
        ref, args =>
            ref
                .cast<Pass>()
                .setUniformFloats(prebindAs<ThreeRenderer>(args, 0), prebindUniformHandle(args, 1),
                    prebindFloatArray(vm, args, 2), num: UInt16(prebindInt(args, 3, default: 1) & 0xFFFF))
            Array<LuaValue>()
    }
    b.method("setStencil") {
        ref, args =>
            ref
                .cast<Pass>()
                .setStencil(prebindAs<ThreeRenderer>(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF))
            Array<LuaValue>()
    }
    b.method("touchView") {
        ref, args =>
            ref.cast<Pass>().touchView(prebindAs<ThreeRenderer>(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF))
            Array<LuaValue>()
    }
    // ===== 便捷 uniform 上传（内部槽位复用） =====
    b.method("setScalarUniform") {
        ref, args =>
            ref
                .cast<Pass>()
                ._setScalarUniform(prebindAs<ThreeRenderer>(args, 0), prebindUniformHandle(args, 1), prebindInt(args, 2),
                    prebindNum(args, 3))
            Array<LuaValue>()
    }
    b.method("setVec2Uniform") {
        ref, args =>
            ref
                .cast<Pass>()
                ._setVec2Uniform(prebindAs<ThreeRenderer>(args, 0), prebindUniformHandle(args, 1), prebindInt(args, 2),
                    prebindNum(args, 3), prebindNum(args, 4))
            Array<LuaValue>()
    }
    b.method("setVec4Uniform") {
        ref, args =>
            ref
                .cast<Pass>()
                ._setVec4Uniform(prebindAs<ThreeRenderer>(args, 0), prebindUniformHandle(args, 1), prebindInt(args, 2),
                    prebindNum(args, 3), prebindNum(args, 4), prebindNum(args, 5), prebindNum(args, 6))
            Array<LuaValue>()
    }
    b.method("cachedUniform") {
        ref, args => [LuaValue.of(
            prebindGfxHandleIdx(
                ref
                    .cast<Pass>()
                    ._cachedUniform(prebindStr(args, 0), prebindGfxUniformType(prebindInt(args, 1)),
                        num: UInt16(prebindInt(args, 2, default: 1) & 0xFFFF))))]
    }
    b.method("passUniforms") {
        ref, _ => [prebindRegister(ref.cast<Pass>()._passUniforms(), "three.renderers._interfaces.IUniformRegistry")]
    }
    b.method("disposePassUniforms") {
        ref, _ =>
            ref.cast<Pass>()._disposePassUniforms()
            Array<LuaValue>()
    }
}

/**
 * @brief[zh-cn] 安装 Pass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.Pass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Pass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.Pass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.Pass")
    b.constructor {_ => Pass()}
    _prebindPpPassMembers(b, vm)
    b.install(vm)
}
