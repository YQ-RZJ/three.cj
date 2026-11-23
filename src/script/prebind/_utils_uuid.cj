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
 * @file[zh-cn] utils_uuid UUID 生成工具的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.UUID 绑定为 Lua 命名空间 three.utils.encode.UUID
 * @explain[zh-cn] UUID 是纯静态工具类（无构造器，不安装 new），公开成员仅有
 * 静态 uuid()：生成 RFC 4122 v4 随机 UUID 字符串，以 staticMethod 暴露。
 *
 * @file[en] utils_uuid  Lua binding of the UUID generator (three.script.prebind)
 * @brief[en] Binds three.utils.encode.UUID as the Lua namespace three.utils.encode.UUID
 * @explain[en] UUID is a pure static utility class (no constructor, no `new`); its only
 * public member is the static uuid() that generates an RFC 4122 v4 random UUID
 * string, exposed as a staticMethod.
 */
package three.script.prebind

import three.utils.encode.UUID
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UUID 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.UUID）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UUID (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.UUID)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUUID(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.UUID")
    b.staticMethod("uuid") {_ => [LuaValue.of(UUID.uuid())]}
    b.install(vm)
}
