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
 * @file[zh-cn] renderers_rendertarget_rendertarget 渲染目标族
 * （RenderTargetOptions / RenderTarget）的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.rendertarget 的 RenderTargetOptions 与
 * RenderTarget 绑定为 Lua 类型
 * @explain[zh-cn] 适配约定：
 * - 构造按位置传参：RenderTargetOptions.new()；RenderTarget.new(width, height[, options])，
 *   width/height 缺省为 1，options 缺省为 nil（引擎用默认选项）；
 * - 属性：RenderTargetOptions 的全部基础字段（generateMipmaps / magFilter / minFilter /
 *   format / type / internalFormat / wrapS / wrapT / wrapR / anisotropy / colorSpace /
 *   depthBuffer / stencilBuffer / resolve* / storeMultisampled* / samples / count / depth /
 *   multiview / useArrayDepthTexture）可读写，internalFormat 用 nil 表示无值；
 *   RenderTarget 的 kind / width / height / depth / scissor / scissorTest / viewport /
 *   depthBuffer / stencilBuffer / resolve* / storeMultisampled* / samples / multiview /
 *   useArrayDepthTexture 可读写，另有只读 releasable；
 * - 方法：setSize / copy / clone / release。
 * 跳过成员及原因（逐条）：
 * - RenderTarget.textures（ArrayList<Option<IRenderTargetTexture>>）：泛型容器且元素为接口实例，
 *   绑定层无 ArrayList / 接口对象通道；
 * - RenderTarget.userData（HashMap<String, Any>）：项目约定 HashMap / Any 不直接绑定；
 * - RenderTarget.getTexture / setTexture / getDepthTexture / setDepthTexture：参数或返回值为
 *   IRenderTargetTexture 接口实例，该接口无 Lua 类型，无法安全往返；
 * - RenderTargetOptions.depthTexture（?IRenderTargetTexture）：同上，接口实例无绑定通道；
 * - IRenderTargetTexture 接口本身：接口不是可构造类，不生成 Lua 类表；
 * - 继承自 EventDispatcher 的监听器方法：与既有绑定一致，由 EventDispatcher 自身绑定负责，
 *   子类不重复登记。
 *
 * @file[en] renderers_rendertarget_rendertarget  Lua bindings of the render target family
 * (RenderTargetOptions / RenderTarget) (three.script.prebind)
 * @brief[en] Binds three.renderers.rendertarget's RenderTargetOptions and RenderTarget as Lua
 * types
 * @explain[en] Adaptation rules:
 * - Constructors take positional arguments: RenderTargetOptions.new();
 *   RenderTarget.new(width, height[, options]) where width/height default to 1 and options
 *   defaults to nil (engine defaults);
 * - Properties: every basic field of RenderTargetOptions (generateMipmaps / magFilter /
 *   minFilter / format / type / internalFormat / wrapS / wrapT / wrapR / anisotropy /
 *   colorSpace / depthBuffer / stencilBuffer / resolve* / storeMultisampled* / samples /
 *   count / depth / multiview / useArrayDepthTexture) is read-write, with nil representing an
 *   absent internalFormat; RenderTarget's kind / width / height / depth / scissor /
 *   scissorTest / viewport / depthBuffer / stencilBuffer / resolve* / storeMultisampled* /
 *   samples / multiview / useArrayDepthTexture are read-write, plus read-only releasable;
 * - Methods: setSize / copy / clone / release.
 * Skipped members and reasons (one by one):
 * - RenderTarget.textures (ArrayList<Option<IRenderTargetTexture>>): a generic container whose
 *   entries are interface instances; the binding layer has no ArrayList / interface-object
 *   channel;
 * - RenderTarget.userData (HashMap<String, Any>): project convention does not bind HashMap / Any;
 * - RenderTarget.getTexture / setTexture / getDepthTexture / setDepthTexture: parameters or
 *   return values are IRenderTargetTexture interface instances, which have no Lua type and
 *   cannot round-trip safely;
 * - RenderTargetOptions.depthTexture (?IRenderTargetTexture): same reason, no binding channel
 *   for interface instances;
 * - the IRenderTargetTexture interface itself: an interface is not a constructible class, so no
 *   Lua class table is generated;
 * - listener methods inherited from EventDispatcher: consistent with existing bindings, they
 *   are owned by the EventDispatcher binding and not re-registered by subclasses.
 */
package three.script.prebind

import three.renderers.rendertarget.RenderTarget
import three.renderers.rendertarget.RenderTargetOptions
import three.core.math.Vector4
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 登记 RenderTarget 家族共有成员（属性 + 尺寸 / 拷贝 / 克隆 / 释放）
 * @param[zh-cn] b 类绑定器（RenderTarget 或 RenderTarget3D）
 * @param[zh-cn] className 实例归属的绑定类全名（clone 返回新实例时使用）
 *
 * @brief[en] Registers the members shared by the RenderTarget family
 * (properties + resize / copy / clone / release)
 * @param[en] b The class binder (RenderTarget or RenderTarget3D)
 * @param[en] className Full bound class name of the instance (used when clone returns a new one)
 */
internal func _prebindRtbInstallRenderTargetMembers(b: LuaClassBinder, className: String): Unit {
    // ===== 基础属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().kind)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().kind = v.stringValue()}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().width)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().width = v.intValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().height)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().height = v.intValue()}))
    b.property("depth", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().depth)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().depth = v.intValue()}))
    // ===== 裁剪与视口（Vector4 对象经注册表往返） =====
    b.property("scissor", getter: Some({
        ref => prebindRegister(ref.cast<RenderTarget>().scissor, "three.core.math.Vector4")
    }), setter: Some({
        ref, v => ref.cast<RenderTarget>().scissor = LuaObjectRegistry.getAs<Vector4>(v.objectId())
    }))
    b.property("scissorTest", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().scissorTest)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().scissorTest = v.boolValue()}))
    b.property("viewport", getter: Some({
        ref => prebindRegister(ref.cast<RenderTarget>().viewport, "three.core.math.Vector4")
    }), setter: Some({
        ref, v => ref.cast<RenderTarget>().viewport = LuaObjectRegistry.getAs<Vector4>(v.objectId())
    }))
    // ===== 缓冲配置 =====
    b.property("depthBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().depthBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().depthBuffer = v.boolValue()}))
    b.property("stencilBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().stencilBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().stencilBuffer = v.boolValue()}))
    b.property("resolveColorBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().resolveColorBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().resolveColorBuffer = v.boolValue()}))
    b.property("resolveDepthBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().resolveDepthBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().resolveDepthBuffer = v.boolValue()}))
    b.property("resolveStencilBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().resolveStencilBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().resolveStencilBuffer = v.boolValue()}))
    b.property("storeMultisampledColorBuffer",
        getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().storeMultisampledColorBuffer)}), setter: Some({
            ref, v => ref.cast<RenderTarget>().storeMultisampledColorBuffer = v.boolValue()
        }))
    b.property("storeMultisampledDepthBuffer",
        getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().storeMultisampledDepthBuffer)}), setter: Some({
            ref, v => ref.cast<RenderTarget>().storeMultisampledDepthBuffer = v.boolValue()
        }))
    b.property("storeMultisampledStencilBuffer", getter: Some({
        ref => LuaValue.of(ref.cast<RenderTarget>().storeMultisampledStencilBuffer)
    }), setter: Some({
        ref, v => ref.cast<RenderTarget>().storeMultisampledStencilBuffer = v.boolValue()
    }))
    b.property("samples", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().samples)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().samples = v.intValue()}))
    b.property("multiview", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().multiview)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().multiview = v.boolValue()}))
    b.property("useArrayDepthTexture", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().useArrayDepthTexture)}),
        setter: Some({ref, v => ref.cast<RenderTarget>().useArrayDepthTexture = v.boolValue()}))
    // ===== IReleasable 只读状态 =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<RenderTarget>().releasable)}))
    // ===== 尺寸 / 拷贝 / 克隆 / 释放 =====
    b.method("setSize") {
        ref, args =>
            ref
                .cast<RenderTarget>()
                .setSize(prebindInt(args, 0), prebindInt(args, 1), depth: prebindInt(args, 2, default: 1))
            Array<LuaValue>()
    }
    b.method("copy") {
        ref, args =>
            ref.cast<RenderTarget>().copy(prebindAs<RenderTarget>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<RenderTarget>().clone(), className)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<RenderTarget>().release())]
    }
}

/**
 * @brief[zh-cn] 安装 RenderTargetOptions 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.rendertarget.RenderTargetOptions）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderTargetOptions
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.rendertarget.RenderTargetOptions)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderTargetOptions(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.rendertarget.RenderTargetOptions")
    // ===== 构造：无参，全字段取引擎默认值 =====
    b.constructor {_ => RenderTargetOptions()}
    // ===== 纹理过滤与格式 =====
    b.property("generateMipmaps", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().generateMipmaps)}),
        setter: Some({
            ref, v => ref.cast<RenderTargetOptions>().generateMipmaps = v.boolValue()
        }))
    b.property("magFilter", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().magFilter)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().magFilter = v.intValue()}))
    b.property("minFilter", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().minFilter)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().minFilter = v.intValue()}))
    b.property("format", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().format)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().format = v.intValue()}))
    b.property("type", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().`type`)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().`type` = v.intValue()}))
    b.property(
        "internalFormat",
        getter: Some({
            ref => match (ref.cast<RenderTargetOptions>().internalFormat) {
                case Some(s) => LuaValue.of(s)
                case None => LuaValue.Nil
            }
        }),
        setter: Some(
            {
                ref, v =>
                    let value: ?String = if (v.isNil) {
                        None
                    } else {
                        Some(v.stringValue())
                    }
                    ref.cast<RenderTargetOptions>().internalFormat = value
            }
        )
    )
    // ===== 包裹与各向异性 =====
    b.property("wrapS", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().wrapS)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().wrapS = v.intValue()}))
    b.property("wrapT", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().wrapT)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().wrapT = v.intValue()}))
    b.property("wrapR", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().wrapR)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().wrapR = v.intValue()}))
    b.property("anisotropy", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().anisotropy)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().anisotropy = v.intValue()}))
    b.property("colorSpace", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().colorSpace)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().colorSpace = v.stringValue()}))
    // ===== 缓冲与解析配置 =====
    b.property("depthBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().depthBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().depthBuffer = v.boolValue()}))
    b.property("stencilBuffer", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().stencilBuffer)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().stencilBuffer = v.boolValue()}))
    b.property("resolveColorBuffer",
        getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().resolveColorBuffer)}), setter: Some({
            ref, v => ref.cast<RenderTargetOptions>().resolveColorBuffer = v.boolValue()
        }))
    b.property("resolveDepthBuffer",
        getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().resolveDepthBuffer)}), setter: Some({
            ref, v => ref.cast<RenderTargetOptions>().resolveDepthBuffer = v.boolValue()
        }))
    b.property("resolveStencilBuffer", getter: Some({
        ref => LuaValue.of(ref.cast<RenderTargetOptions>().resolveStencilBuffer)
    }), setter: Some({
        ref, v => ref.cast<RenderTargetOptions>().resolveStencilBuffer = v.boolValue()
    }))
    b.property("storeMultisampledColorBuffer", getter: Some({
        ref => LuaValue.of(ref.cast<RenderTargetOptions>().storeMultisampledColorBuffer)
    }), setter: Some({
        ref, v => ref.cast<RenderTargetOptions>().storeMultisampledColorBuffer = v.boolValue()
    }))
    b.property("storeMultisampledDepthBuffer", getter: Some({
        ref => LuaValue.of(ref.cast<RenderTargetOptions>().storeMultisampledDepthBuffer)
    }), setter: Some({
        ref, v => ref.cast<RenderTargetOptions>().storeMultisampledDepthBuffer = v.boolValue()
    }))
    b.property("storeMultisampledStencilBuffer", getter: Some({
        ref => LuaValue.of(ref.cast<RenderTargetOptions>().storeMultisampledStencilBuffer)
    }), setter: Some({
        ref, v => ref.cast<RenderTargetOptions>().storeMultisampledStencilBuffer = v.boolValue()
    }))
    // ===== 尺寸与采样 =====
    b.property("samples", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().samples)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().samples = v.intValue()}))
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().count)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().count = v.intValue()}))
    b.property("depth", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().depth)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().depth = v.intValue()}))
    b.property("multiview", getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().multiview)}),
        setter: Some({ref, v => ref.cast<RenderTargetOptions>().multiview = v.boolValue()}))
    b.property("useArrayDepthTexture",
        getter: Some({ref => LuaValue.of(ref.cast<RenderTargetOptions>().useArrayDepthTexture)}), setter: Some({
            ref, v => ref.cast<RenderTargetOptions>().useArrayDepthTexture = v.boolValue()
        }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RenderTarget 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.rendertarget.RenderTarget）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderTarget
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.rendertarget.RenderTarget)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderTarget(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.rendertarget.RenderTarget")
    // ===== 构造：width / height 缺省 1；第 3 个参数为 RenderTargetOptions 对象或 nil =====
    b.constructor {
        args => if (args.size >= 3 && args[2].isObject) {
            RenderTarget(width: prebindInt(args, 0, default: 1), height: prebindInt(args, 1, default: 1),
                options: Some(prebindAs<RenderTargetOptions>(args, 2)))
        } else {
            RenderTarget(prebindInt(args, 0, default: 1), prebindInt(args, 1, default: 1))
        }
    }
    _prebindRtbInstallRenderTargetMembers(b, "three.renderers.rendertarget.RenderTarget")
    b.install(vm)
}
