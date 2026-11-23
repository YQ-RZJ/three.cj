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
 * @file[zh-cn] resource_loader_ddsloader DDS 压缩纹理加载器的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.DDSLoader 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 LoadingManager）、继承自 Loader 的公共配置
 * （manager/crossOrigin/withCredentials/path/resourcePath 属性与
 * setPath/setResourcePath/setCrossOrigin/setWithCredentials/abort 方法）以及
 * load(url, onLoad?, onProgress?, onError?)：同步读取本地文件，onLoad 回传
 * three.renderers.textures.CompressedTexture 对象；解析失败由引擎经 onError 通知，
 * 绑定层捕获异常后返回 false（绝不向 Lua 抛错）。成员复用
 * resource_loader_compressedtextureloader.cj 的
 * prebindInstallCompressedTextureLoaderMembers。
 * 跳过：parse（override 返回 HashMap<String, Any> 纹理数据字典，无法映射为 Lua 值）；
 * requestHeader（HashMap<String, Any>）。
 *
 * @file[en] resource_loader_ddsloader  Lua binding of the DDS compressed texture loader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.DDSLoader as a Lua type
 * @explain[en] Binds construction (optional LoadingManager), Loader's inherited config
 * (manager/crossOrigin/withCredentials/path/resourcePath properties and
 * setPath/setResourcePath/setCrossOrigin/setWithCredentials/abort methods) plus
 * load(url, onLoad?, onProgress?, onError?): reads a local file synchronously, onLoad
 * receives a three.renderers.textures.CompressedTexture object; parse failures are
 * reported through onError by the engine and the binding returns false when an exception
 * escapes (never throws to Lua). Members are reused from
 * prebindInstallCompressedTextureLoaderMembers in
 * resource_loader_compressedtextureloader.cj.
 * Skipped: parse (its override returns a HashMap<String, Any> texture-data dictionary,
 * not mappable to Lua values); requestHeader (HashMap<String, Any>).
 */
package three.script.prebind

import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 DDSLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.DDSLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DDSLoader
 * @param[en] vm The target virtual machine (class table installed at
 * three.resource.loader.DDSLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDDSLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.DDSLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            DDSLoader(m)
        } else {
            DDSLoader()
        }
    }
    prebindInstallCompressedTextureLoaderMembers(b, vm)
    b.install(vm)
}
