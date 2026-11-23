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
 * @file[zh-cn] resource_loader_rgbeloader RGBE（兼容旧名）纹理加载器的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.RGBELoader 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 LoadingManager）、type 属性、setDataType(value)、
 * setRGBEDataType(value)（兼容名，无返回值），以及继承自 DataTextureLoader 的
 * Loader 公共配置、load(url, onLoad?, onProgress?, onError?)（onLoad 回传
 * three.renderers.textures.DataTexture）与 createDataTexture(buffer)：均同步执行，
 * 绑定层捕获异常，失败返回 false / nil（绝不向 Lua 抛错）。成员复用
 * resource_loader_datatextureloader.cj 的 prebindInstallDataTextureLoaderMembers。
 * 跳过：parse（继承自 HDRLoader，返回 HashMap<String, Any> 纹理数据字典，无法映射为
 * Lua 值）；requestHeader（HashMap<String, Any>）。
 *
 * @file[en] resource_loader_rgbeloader  Lua binding of the RGBE (legacy-name) texture
 * loader (three.script.prebind)
 * @brief[en] Binds three.resource.loader.RGBELoader as a Lua type
 * @explain[en] Binds construction (optional LoadingManager), the type property,
 * setDataType(value), setRGBEDataType(value) (compatibility name, no return value), and the
 * members inherited from DataTextureLoader: Loader common config, load(url, onLoad?,
 * onProgress?, onError?) (onLoad receives a three.renderers.textures.DataTexture) and
 * createDataTexture(buffer). All are synchronous; the binding catches exceptions and
 * returns false / nil on failure (never throws to Lua). Members are reused from
 * prebindInstallDataTextureLoaderMembers in resource_loader_datatextureloader.cj.
 * Skipped: parse (inherited from HDRLoader, returns a HashMap<String, Any> texture-data
 * dictionary, not mappable to Lua values); requestHeader (HashMap<String, Any>).
 */
package three.script.prebind

import three.resource.loader.*
import three.utils.constants.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RGBELoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.RGBELoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RGBELoader
 * @param[en] vm The target virtual machine (class table installed at
 * three.resource.loader.RGBELoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRGBELoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.RGBELoader")
    // ===== 构造：可选 manager（type 默认 FloatType） =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            RGBELoader(m)
        } else {
            RGBELoader()
        }
    }
    prebindInstallDataTextureLoaderMembers(b, vm)
    // ===== 输出数据类型 =====
    b.property("type", getter: Some({ref => LuaValue.of(ref.cast<RGBELoader>().`type`)}),
        setter: Some({ref, v => ref.cast<RGBELoader>().`type` = v.intValue()}))
    b.method("setDataType") {
        ref, args =>
            ref.cast<RGBELoader>().setDataType(prebindInt(args, 0, default: FloatType))
            [LuaValue.Object(ref.id)]
    }
    b.method("setRGBEDataType") {
        ref, args =>
            ref.cast<RGBELoader>().setRGBEDataType(prebindInt(args, 0, default: FloatType))
            []
    }
    b.install(vm)
}
