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
 * @file[zh-cn] renderers_textures_texture 纹理基类 Texture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.Texture 绑定为 Lua 类型
 * three.renderers.textures.Texture
 * @explain[zh-cn] 构造的 12 个参数均为命名可选参数（image / width / height / wrapS / wrapT /
 * magFilter / minFilter / mapping / format / type / anisotropy / colorSpace），Lua 侧按位置
 * 传入前 N 个，缺省值同仓颉默认（ClampToEdgeWrapping / LinearFilter / LinearMipmapLinearFilter /
 * UVMapping / RGBAFormat / UnsignedByteType / 1 / 空串）。
 * 绑定全部可映射成员：image（Lua 数值表 ↔ Array<UInt8>）、采样状态、UV 变换（Vector2/Matrix3
 * 经 prebindRegister 注册、setter 经 prebindAsValue 取回）、source（Source）、renderTarget
 * （Option<IRenderTarget>）以及 release / releasable / update / updateMatrix / transformUv /
 * copy / clone。子类绑定经 _prebindRtxTextureMembers 复用本文件的成员，避免逐个复制。
 * 跳过：mipmaps（ArrayList<Any> 嵌套容器）、userData（HashMap<String, Any> 无 Lua 通道）、
 * setValues（HashMap<String, Any>）、rtWidth/rtHeight/rtDepth/rtIsArrayTexture/rtRenderTarget/
 * rtIsRenderTargetTexture/rtClone（IRenderTargetTexture 同义别名，已由 width/height/depth/
 * isArrayTexture/renderTarget/clone 覆盖）。
 *
 * @file[en] renderers_textures_texture  Lua binding of the texture base class Texture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.Texture as the Lua type
 * three.renderers.textures.Texture
 * @explain[en] All 12 constructor parameters are named optional ones (image / width / height /
 * wrapS / wrapT / magFilter / minFilter / mapping / format / type / anisotropy / colorSpace);
 * Lua passes the first N positionally and the Cangjie defaults apply (ClampToEdgeWrapping /
 * LinearFilter / LinearMipmapLinearFilter / UVMapping / RGBAFormat / UnsignedByteType / 1 / "").
 * Every mappable member is bound: image (Lua number table <-> Array<UInt8>), sampling state, UV
 * transform (Vector2/Matrix3 registered via prebindRegister, fetched by the setter via
 * prebindAsValue), source (Source), renderTarget (Option<IRenderTarget>), plus release / releasable /
 * update / updateMatrix / transformUv / copy / clone. Subclass bindings reuse these members through
 * _prebindRtxTextureMembers instead of duplicating them.
 * Skipped: mipmaps (ArrayList<Any> nested container), userData (HashMap<String, Any>, no Lua
 * channel), setValues (HashMap<String, Any>), and the rtWidth/rtHeight/rtDepth/rtIsArrayTexture/
 * rtRenderTarget/rtIsRenderTargetTexture/rtClone aliases of IRenderTargetTexture (already covered by
 * width/height/depth/isArrayTexture/renderTarget/clone).
 */
package three.script.prebind

import three.renderers.textures.*
import three.renderers.rendertarget.RenderTarget
import three.core.math.{Matrix3, Vector2}
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取 6 面图像参数（Lua 二维表 → Array<Array<UInt8>>）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 六面字节数组（非表/缺省返回空数组）
 *
 * @brief[en] Reads the six-face image argument (Lua 2-D table -> Array<Array<UInt8>>)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The six face byte arrays (empty when absent or not a table)
 */
internal func _prebindRtxFaces(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Array<UInt8>> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<Array<UInt8>>(n, {_ => Array<UInt8>()})
    for (i in 0..n) {
        out[i] = prebindBytes(vm, [elems[i]], 0)
    }
    return out
}

/**
 * @brief[zh-cn] 将 6 面图像转为 Lua 二维表（Array<Array<UInt8>> → Lua 数组的数组）
 * @param[zh-cn] faces 六面字节数组
 * @return[zh-cn] Lua 数组值（每项为字节数组值）
 *
 * @brief[en] Converts the six face images into a Lua 2-D table
 * @param[en] faces The six face byte arrays
 * @return[en] The Lua array value (each item a byte-array value)
 */
internal func _prebindRtxFacesToLua(faces: Array<Array<UInt8>>): LuaValue {
    let n = faces.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindBytesToLua(faces[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 Texture 的成员（构造除外）
 * @explain[zh-cn] 各纹理子类绑定复用本函数（每个子类独立 metatable，无 __index 继承链），
 * 所有回调按 Texture 强转，因此对任意子类实例均可工作。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the Texture members (except the constructor) on a class binder
 * @explain[en] Subclass bindings reuse this function (each subclass has its own metatable and
 * there is no __index inheritance chain). Every callback casts to Texture, so it works for any
 * subclass instance.
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindRtxTextureMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    // ===== 基础属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<Texture>().kind)}),
        setter: Some({ref, v => ref.cast<Texture>().kind = v.stringValue()}))
    b.property("image", getter: Some({ref => prebindBytesToLua(ref.cast<Texture>().image)}),
        setter: Some({ref, v => ref.cast<Texture>().image = prebindBytes(vm, [v], 0)}))
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<Texture>().width)}),
        setter: Some({ref, v => ref.cast<Texture>().width = v.intValue()}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<Texture>().height)}),
        setter: Some({ref, v => ref.cast<Texture>().height = v.intValue()}))
    b.property("wrapS", getter: Some({ref => LuaValue.of(ref.cast<Texture>().wrapS)}),
        setter: Some({ref, v => ref.cast<Texture>().wrapS = v.intValue()}))
    b.property("wrapT", getter: Some({ref => LuaValue.of(ref.cast<Texture>().wrapT)}),
        setter: Some({ref, v => ref.cast<Texture>().wrapT = v.intValue()}))
    b.property("magFilter", getter: Some({ref => LuaValue.of(ref.cast<Texture>().magFilter)}),
        setter: Some({ref, v => ref.cast<Texture>().magFilter = v.intValue()}))
    b.property("minFilter", getter: Some({ref => LuaValue.of(ref.cast<Texture>().minFilter)}),
        setter: Some({ref, v => ref.cast<Texture>().minFilter = v.intValue()}))
    b.property("needsUpdate", getter: Some({ref => LuaValue.of(ref.cast<Texture>().needsUpdate)}),
        setter: Some({ref, v => ref.cast<Texture>().needsUpdate = v.boolValue()}))
    b.property("version", getter: Some({ref => LuaValue.of(ref.cast<Texture>().version)}),
        setter: Some({ref, v => ref.cast<Texture>().version = v.intValue()}))
    b.property("mapping", getter: Some({ref => LuaValue.of(ref.cast<Texture>().mapping)}),
        setter: Some({ref, v => ref.cast<Texture>().mapping = v.intValue()}))
    b.property("format", getter: Some({ref => LuaValue.of(ref.cast<Texture>().format)}),
        setter: Some({ref, v => ref.cast<Texture>().format = v.intValue()}))
    b.property("internalFormat", getter: Some({
        ref => match (ref.cast<Texture>().internalFormat) {
            case Some(s) => LuaValue.of(s)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<Texture>().internalFormat = if (v.isNil) {
            None
        } else {
            Some(v.stringValue())
        }
    }))
    b.property("type", getter: Some({ref => LuaValue.of(ref.cast<Texture>().`type`)}),
        setter: Some({ref, v => ref.cast<Texture>().`type` = v.intValue()}))
    b.property("anisotropy", getter: Some({ref => LuaValue.of(ref.cast<Texture>().anisotropy)}),
        setter: Some({ref, v => ref.cast<Texture>().anisotropy = v.intValue()}))
    b.property("colorSpace", getter: Some({ref => LuaValue.of(ref.cast<Texture>().colorSpace)}),
        setter: Some({ref, v => ref.cast<Texture>().colorSpace = v.stringValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<Texture>().uuid)}),
        setter: Some({ref, v => ref.cast<Texture>().uuid = v.stringValue()}))
    b.property("id", getter: Some({ref => LuaValue.of(ref.cast<Texture>().id)}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<Texture>().name)}),
        setter: Some({ref, v => ref.cast<Texture>().name = v.stringValue()}))
    // ===== 数据源 =====
    b.property("source",
        getter: Some({ref => prebindRegister(ref.cast<Texture>().source, "three.renderers.textures.Source")}),
        setter: Some({
            ref, v => ref.cast<Texture>().source = prebindAsValue<Source>(v)
        }))
    // ===== UV 变换 =====
    b.property("channel", getter: Some({ref => LuaValue.of(ref.cast<Texture>().channel)}),
        setter: Some({ref, v => ref.cast<Texture>().channel = v.intValue()}))
    b.property("offset", getter: Some({ref => prebindRegister(ref.cast<Texture>().offset, "three.core.math.Vector2")}),
        setter: Some({ref, v => ref.cast<Texture>().offset = prebindAsValue<Vector2>(v)}))
    b.property("repeat", getter: Some({ref => prebindRegister(ref.cast<Texture>().repeat, "three.core.math.Vector2")}),
        setter: Some({ref, v => ref.cast<Texture>().repeat = prebindAsValue<Vector2>(v)}))
    b.property("center", getter: Some({ref => prebindRegister(ref.cast<Texture>().center, "three.core.math.Vector2")}),
        setter: Some({ref, v => ref.cast<Texture>().center = prebindAsValue<Vector2>(v)}))
    b.property("rotation", getter: Some({ref => LuaValue.of(ref.cast<Texture>().rotation)}),
        setter: Some({ref, v => ref.cast<Texture>().rotation = v.numberValue()}))
    b.property("matrixAutoUpdate", getter: Some({ref => LuaValue.of(ref.cast<Texture>().matrixAutoUpdate)}),
        setter: Some({ref, v => ref.cast<Texture>().matrixAutoUpdate = v.boolValue()}))
    b.property("matrix", getter: Some({ref => prebindRegister(ref.cast<Texture>().matrix, "three.core.math.Matrix3")}),
        setter: Some({ref, v => ref.cast<Texture>().matrix = prebindAsValue<Matrix3>(v)}))
    // ===== 上传选项 =====
    b.property("generateMipmaps", getter: Some({ref => LuaValue.of(ref.cast<Texture>().generateMipmaps)}),
        setter: Some({ref, v => ref.cast<Texture>().generateMipmaps = v.boolValue()}))
    b.property("premultiplyAlpha", getter: Some({ref => LuaValue.of(ref.cast<Texture>().premultiplyAlpha)}),
        setter: Some({ref, v => ref.cast<Texture>().premultiplyAlpha = v.boolValue()}))
    b.property("flipY", getter: Some({ref => LuaValue.of(ref.cast<Texture>().flipY)}),
        setter: Some({ref, v => ref.cast<Texture>().flipY = v.boolValue()}))
    b.property("unpackAlignment", getter: Some({ref => LuaValue.of(ref.cast<Texture>().unpackAlignment)}),
        setter: Some({ref, v => ref.cast<Texture>().unpackAlignment = v.intValue()}))
    // ===== 渲染目标关联 =====
    b.property("isRenderTargetTexture", getter: Some({ref => LuaValue.of(ref.cast<Texture>().isRenderTargetTexture)}),
        setter: Some({ref, v => ref.cast<Texture>().isRenderTargetTexture = v.boolValue()}))
    b.property("renderTarget", getter: Some({
        ref => match (ref.cast<Texture>().renderTarget) {
            case Some(rt) => prebindRegister(rt, "three.renderers.rendertarget.RenderTarget")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<Texture>().renderTarget = if (v.isObject) {
            Some(prebindAsValue<RenderTarget>(v))
        } else {
            None
        }
    }))
    b.property("depth", getter: Some({ref => LuaValue.of(ref.cast<Texture>().depth)}),
        setter: Some({ref, v => ref.cast<Texture>().depth = v.intValue()}))
    b.property("isArrayTexture", getter: Some({ref => LuaValue.of(ref.cast<Texture>().isArrayTexture)}),
        setter: Some({ref, v => ref.cast<Texture>().isArrayTexture = v.boolValue()}))
    b.property("normalized", getter: Some({ref => LuaValue.of(ref.cast<Texture>().normalized)}),
        setter: Some({ref, v => ref.cast<Texture>().normalized = v.boolValue()}))
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<Texture>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Texture>().release())]
    }
    // ===== 3D 纹理判定 =====
    b.method("getIsData3DTexture") {
        ref, _ => [LuaValue.of(ref.cast<Texture>().getIsData3DTexture())]
    }
    // ===== 更新 / UV =====
    b.method("update") {
        ref, _ =>
            ref.cast<Texture>().update()
            Array<LuaValue>()
    }
    b.method("updateMatrix") {
        ref, _ =>
            ref.cast<Texture>().updateMatrix()
            Array<LuaValue>()
    }
    b.method("transformUv") {
        ref, args => [prebindRegister(
            ref.cast<Texture>().transformUv(prebindAs<Vector2>(args, 0), prebindAs<Vector2>(args, 1)),
            "three.core.math.Vector2")]
    }
    // ===== 拷贝 / 克隆 =====
    b.method("copy") {
        ref, args =>
            ref.cast<Texture>().copy(prebindAs<Texture>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Texture>().clone(), "three.renderers.textures.Texture")]
    }
}

/**
 * @brief[zh-cn] 安装 Texture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.Texture）
 *
 * @brief[en] Installs the Lua binding of Texture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.Texture)
 */
public func installTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.Texture")
    // ===== 构造（命名可选参数，Lua 按位置传入前 N 个） =====
    b.constructor {
        args => Texture(image: prebindBytes(vm, args, 0), width: prebindInt(args, 1), height: prebindInt(args, 2),
            wrapS: prebindInt(args, 3, default: 1001), wrapT: prebindInt(args, 4, default: 1001),
            magFilter: prebindInt(args, 5, default: 1006), minFilter: prebindInt(args, 6, default: 1008),
            mapping: prebindInt(args, 7, default: 300), format: prebindInt(args, 8, default: 1023),
            `type`: prebindInt(args, 9, default: 1009), anisotropy: prebindInt(args, 10, default: 1),
            colorSpace: prebindStr(args, 11))
    }
    _prebindRtxTextureMembers(b, vm)
    b.install(vm)
}
