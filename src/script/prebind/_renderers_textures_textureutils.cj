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
 * @file[zh-cn] renderers_textures_textureutils TextureUtils / TypeByteLength 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.TextureUtils 与
 * three.renderers.textures.TypeByteLength 绑定为 Lua 类型
 * @explain[zh-cn] TypeByteLength（struct）绑定构造（byteLength / components）与同名只读属性；
 * TextureUtils 为纯静态工具类（不安装 new），绑定静态方法 contain / cover / fill（就地修改并
 * 返回传入的 Texture 句柄）、getByteLength（未知格式时返回 nil）以及包级函数
 * getTextureTypeByteLength（同样以 staticMethod 暴露，返回 TypeByteLength，未知类型时返回 nil）。
 * 包级便捷函数 contain / cover / fill 与静态方法语义完全一致，不重复注册。
 *
 * @file[en] renderers_textures_textureutils  Lua bindings of TextureUtils / TypeByteLength
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.TextureUtils and
 * three.renderers.textures.TypeByteLength as Lua types
 * @explain[en] TypeByteLength (a struct) gets its constructor (byteLength / components) and the
 * same-named read-only properties. TextureUtils is a pure static utility (no `new`): the static
 * methods contain / cover / fill (mutate and return the passed Texture handle), getByteLength
 * (returns nil for unknown formats) and the package-level getTextureTypeByteLength (also exposed as
 * a staticMethod, returning TypeByteLength or nil for unknown types) are bound. The package-level
 * contain / cover / fill convenience functions are semantically identical to the static methods and
 * are not registered twice.
 */
package three.script.prebind

import three.renderers.textures.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TypeByteLength 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.TypeByteLength）
 *
 * @brief[en] Installs the Lua binding of TypeByteLength
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.TypeByteLength)
 */
public func installTypeByteLength(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.TypeByteLength")
    // ===== 构造 =====
    b.constructor {
        args => TypeByteLength(prebindInt(args, 0), prebindInt(args, 1))
    }
    // ===== 只读属性 =====
    b.property("byteLength", getter: Some({ref => LuaValue.of(ref.cast<TypeByteLength>().byteLength)}))
    b.property("components", getter: Some({ref => LuaValue.of(ref.cast<TypeByteLength>().components)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TextureUtils 的 Lua 绑定（纯静态工具，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.textures.TextureUtils）
 *
 * @brief[en] Installs the Lua binding of TextureUtils (a pure static utility; no constructor, no
 * `new`)
 * @param[en] vm The target virtual machine (namespace table installed at
 * three.renderers.textures.TextureUtils)
 */
public func installTextureUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.TextureUtils")
    // ===== CSS object-fit 风格变换（就地修改并返回传入句柄） =====
    b.staticMethod("contain") {
        args =>
            TextureUtils.contain(prebindAs<Texture>(args, 0), prebindNum(args, 1, default: 1.0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("cover") {
        args =>
            TextureUtils.cover(prebindAs<Texture>(args, 0), prebindNum(args, 1, default: 1.0))
            [LuaValue.Object(args[0].objectId())]
    }
    b.staticMethod("fill") {
        args =>
            TextureUtils.fill(prebindAs<Texture>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 字节长度估算（未知格式返回 nil） =====
    b.staticMethod("getByteLength") {
        args => try {
            [LuaValue.of(
                TextureUtils.getByteLength(prebindInt(args, 0), prebindInt(args, 1), prebindInt(args, 2, default: 1023),
                    prebindInt(args, 3, default: 1009)))]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    // ===== 类型字节描述（包级函数，以静态方法暴露） =====
    b.staticMethod("getTextureTypeByteLength") {
        args => try {
            [prebindRegister(getTextureTypeByteLength(prebindInt(args, 0)), "three.renderers.textures.TypeByteLength")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.install(vm)
}
