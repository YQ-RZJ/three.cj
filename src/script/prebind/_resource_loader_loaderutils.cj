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
 * @file[zh-cn] resource_loader_loaderutils 加载器工具 LoaderUtils 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.LoaderUtils 绑定为 Lua 命名空间
 * three.resource.loader.LoaderUtils
 * @explain[zh-cn] LoaderUtils 为纯静态工具类（无构造器，不安装 new），绑定两个静态方法：
 * extractUrlBase(url) 与 resolveURL(url, path)。
 *
 * @file[en] resource_loader_loaderutils  Lua binding of the loader utilities LoaderUtils
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.LoaderUtils as the Lua namespace
 * three.resource.loader.LoaderUtils
 * @explain[en] LoaderUtils is a pure static utility class (no constructor, no `new`), binding
 * its two static methods: extractUrlBase(url) and resolveURL(url, path).
 */
package three.script.prebind

import three.resource.loader.LoaderUtils
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LoaderUtils 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.resource.loader.LoaderUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LoaderUtils (pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table at three.resource.loader.LoaderUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLoaderUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.LoaderUtils")
    // ===== 静态工具方法 =====
    b.staticMethod("extractUrlBase") {
        args => [LuaValue.of(LoaderUtils.extractUrlBase(prebindStr(args, 0)))]
    }
    b.staticMethod("resolveURL") {
        args => [LuaValue.of(LoaderUtils.resolveURL(prebindStr(args, 0), prebindStr(args, 1)))]
    }
    b.install(vm)
}
