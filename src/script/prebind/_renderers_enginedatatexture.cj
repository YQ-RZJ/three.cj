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
 * @file[zh-cn] renderers_enginedatatexture 数据纹理资源对象 EngineDataTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.EngineDataTexture 绑定为 Lua 类型
 * three.renderers.textures.EngineDataTexture
 * @explain[zh-cn] 构造按参数形态区分 2D / 3D：
 * - 2D：new(renderer, width, height, pixels, format[, flags])
 * - 3D：new(renderer, width, height, depth, pixels, format[, flags])
 * pixels 为 0~255 的 Lua 数值数组（经「Lua 表 ↔ Array<UInt8>」通道），format / flags
 * 取引擎常量（类表上的同名 staticMethod：FORMAT_RGBA8 / FORMAT_RGBA16F / FORMAT_RGBA32F /
 * FLAGS_CLAMP_UV / FLAGS_CLAMP_UVW / FLAGS_CLAMP_UVW_POINT）。
 * 绑定 width / height / depth / isValid / releasable 只读属性与 handleIdx / dispose /
 * release 方法，以及静态 invalid()（无效占位实例，不触达 GPU）。
 * 使用前提：构造会经渲染器资源通道把像素上传为 GPU 纹理，必须由引擎完成渲染后端初始化后
 * 调用；invalid() / 属性读取可安全调用。
 * 跳过成员及原因：内部句柄访问器为 internal（public 面不泄漏句柄类型），Lua 侧无需接触。
 *
 * @file[en] renderers_enginedatatexture  Lua binding of the data-texture resource object
 * EngineDataTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.EngineDataTexture as the Lua type three.renderers.textures.EngineDataTexture
 * @explain[en] The constructor distinguishes 2D / 3D by argument shape:
 * - 2D: new(renderer, width, height, pixels, format[, flags])
 * - 3D: new(renderer, width, height, depth, pixels, format[, flags])
 * pixels is a Lua number array of 0~255 values (through the "Lua table <-> Array<UInt8>" channel);
 * format / flags take engine constants (same-named staticMethods on the class table:
 * FORMAT_RGBA8 / FORMAT_RGBA16F / FORMAT_RGBA32F / FLAGS_CLAMP_UV / FLAGS_CLAMP_UVW /
 * FLAGS_CLAMP_UVW_POINT).
 * Binds the read-only width / height / depth / isValid / releasable properties, the handleIdx /
 * dispose / release methods, and the static invalid() (invalid placeholder instance that touches
 * no GPU).
 * Precondition: construction uploads the pixel data as a GPU texture through the renderer's
 * resource channel, so it may only be called after the engine has finished render-backend
 * initialization; invalid() / property reads are safe at any time.
 * Skipped members and reasons: the internal handle accessors are internal (the public face leaks
 * no handle types) and Lua never needs them.
 */
package three.script.prebind

import three.renderers.textures.EngineDataTexture
import three.renderers.ThreeRenderer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EngineDataTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.EngineDataTexture）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EngineDataTexture
 * @param[en] vm The target virtual machine (class table at three.renderers.textures.EngineDataTexture)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEngineDataTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.EngineDataTexture")
    // ===== 构造：2D（第 4 参为像素表）/ 3D（第 4 参为 depth，第 5 参为像素表） =====
    b.constructor {
        args =>
            let renderer = prebindAs<ThreeRenderer>(args, 0)
            let width = prebindInt(args, 1)
            let height = prebindInt(args, 2)
            if (args.size > 3 && !args[3].isArray && !args[3].isTable) {
                // 3D：new(renderer, width, height, depth, pixels, format[, flags])
                EngineDataTexture(renderer.gfxBackend(), width, height, prebindInt(args, 3), prebindBytes(vm, args, 4),
                    format: UInt32(prebindInt(args, 5) & 0xFFFFFFFF), flags: UInt64(prebindInt(args, 6)))
            } else {
                // 2D：new(renderer, width, height, pixels, format[, flags])
                EngineDataTexture(renderer.gfxBackend(), width, height, prebindBytes(vm, args, 3),
                    format: UInt32(prebindInt(args, 4) & 0xFFFFFFFF), flags: UInt64(prebindInt(args, 5)))
            }
    }
    // ===== 只读属性 =====
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<EngineDataTexture>().width)}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<EngineDataTexture>().height)}))
    b.property("depth", getter: Some({ref => LuaValue.of(ref.cast<EngineDataTexture>().depth)}))
    b.property("isValid", getter: Some({ref => LuaValue.of(ref.cast<EngineDataTexture>().isValid)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<EngineDataTexture>().releasable)}))
    // ===== 句柄索引与释放 =====
    b.method("handleIdx") {
        ref, _ => [LuaValue.of(Int64(ref.cast<EngineDataTexture>().handleIdx()))]
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<EngineDataTexture>().dispose()
            Array<LuaValue>()
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<EngineDataTexture>().release())]
    }
    // ===== 静态工具与常用常量（按函数取值，与 ThreeRenderer 常量风格一致） =====
    b.staticMethod("invalid") {
        _ => [prebindRegister(EngineDataTexture.invalid(), "three.renderers.textures.EngineDataTexture")]
    }
    b.staticMethod("FORMAT_RGBA8") {_ => [LuaValue.of(Int64(EngineDataTexture.FORMAT_RGBA8))]}
    b.staticMethod("FORMAT_RGBA16F") {_ => [LuaValue.of(Int64(EngineDataTexture.FORMAT_RGBA16F))]}
    b.staticMethod("FORMAT_RGBA32F") {_ => [LuaValue.of(Int64(EngineDataTexture.FORMAT_RGBA32F))]}
    b.staticMethod("FLAGS_CLAMP_UV") {_ => [LuaValue.of(Int64(EngineDataTexture.FLAGS_CLAMP_UV))]}
    b.staticMethod("FLAGS_CLAMP_UVW") {_ => [LuaValue.of(Int64(EngineDataTexture.FLAGS_CLAMP_UVW))]}
    b.staticMethod("FLAGS_CLAMP_UVW_POINT") {_ => [LuaValue.of(Int64(EngineDataTexture.FLAGS_CLAMP_UVW_POINT))]}
    b.install(vm)
}
