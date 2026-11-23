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
 * @file[zh-cn] renderers_rendertarget_rendertarget3d 3D 渲染目标 RenderTarget3D 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.rendertarget.RenderTarget3D 绑定为 Lua 类型
 * @explain[zh-cn] 适配约定：
 * - 构造按位置传参：RenderTarget3D.new(width, height, depth)，三者缺省均为 1；
 * - 继承 RenderTarget：共用 _prebindRtbInstallRenderTargetMembers 登记基类全部属性与方法
 *   （kind / width / height / depth / scissor / scissorTest / viewport / 缓冲与解析开关 /
 *   samples / multiview / useArrayDepthTexture / releasable / setSize / copy / clone /
 *   release），绑定层无 __index 继承链，故子类重复登记；
 * - clone 返回的新实例按 three.renderers.rendertarget.RenderTarget3D 注册。
 * 跳过成员及原因：
 * - copy(source: RenderTarget3D) 重载：Lua 无方法重载，统一由基类 copy 承接（参数按
 *   RenderTarget 读取，传入 RenderTarget3D 实例同样有效，仅复制基类字段）；
 * - 其余跳过项与父类一致：textures（ArrayList<Option<IRenderTargetTexture>> 泛型容器 +
 *   接口元素）、userData（HashMap<String, Any>）、getTexture / setTexture /
 *   getDepthTexture / setDepthTexture（IRenderTargetTexture 接口实例无 Lua 类型）；
 * - 继承自 EventDispatcher 的监听器方法由 EventDispatcher 绑定负责，不重复登记。
 *
 * @file[en] renderers_rendertarget_rendertarget3d  Lua binding of the 3D render target
 * RenderTarget3D (three.script.prebind)
 * @brief[en] Binds three.renderers.rendertarget.RenderTarget3D as a Lua type
 * @explain[en] Adaptation rules:
 * - Constructor takes positional arguments: RenderTarget3D.new(width, height, depth), all
 *   defaulting to 1;
 * - Inherits RenderTarget: _prebindRtbInstallRenderTargetMembers registers every base property
 *   and method (kind / width / height / depth / scissor / scissorTest / viewport / buffer and
 *   resolve switches / samples / multiview / useArrayDepthTexture / releasable / setSize /
 *   copy / clone / release); the binding layer has no __index inheritance chain, so the
 *   subclass re-registers them;
 * - A new instance returned by clone is registered as
 *   three.renderers.rendertarget.RenderTarget3D.
 * Skipped members and reasons:
 * - the copy(source: RenderTarget3D) overload: Lua has no method overloading, so the base copy
 *   handles it (its argument is read as RenderTarget; passing a RenderTarget3D still works and
 *   copies the base fields only);
 * - the remaining skipped items match the parent: textures (ArrayList<Option<IRenderTargetTexture>>
 *   generic container with interface entries), userData (HashMap<String, Any>),
 *   getTexture / setTexture / getDepthTexture / setDepthTexture (IRenderTargetTexture interface
 *   instances have no Lua type);
 * - listener methods inherited from EventDispatcher are owned by the EventDispatcher binding and
 *   are not re-registered.
 */
package three.script.prebind

import three.renderers.rendertarget.RenderTarget3D
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RenderTarget3D 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.rendertarget.RenderTarget3D）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderTarget3D
 * @param[en] vm The target virtual machine (class table installed at
 *            three.renderers.rendertarget.RenderTarget3D)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderTarget3D(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.rendertarget.RenderTarget3D")
    // ===== 构造：width / height / depth 缺省均为 1 =====
    b.constructor {
        args => RenderTarget3D(width: prebindInt(args, 0, default: 1), height: prebindInt(args, 1, default: 1),
            depth: prebindInt(args, 2, default: 1))
    }
    // ===== RenderTarget 基类成员 =====
    _prebindRtbInstallRenderTargetMembers(b, "three.renderers.rendertarget.RenderTarget3D")
    b.install(vm)
}
