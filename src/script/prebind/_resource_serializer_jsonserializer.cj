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
 * @file[zh-cn] resource_serializer_jsonserializer JSON 序列化的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.serializer.JsonSerializer 绑定为 Lua 类型
 * three.resource.serializer.JsonSerializer
 * @explain[zh-cn] JsonSerializer 为纯静态工具类（无构造器），绑定对象转 JSON 的两个入口：
 * - toJson(obj)：返回 JSON 字符串；
 * - toJsonBytes(obj)：返回 UTF-8 JSON 字节数组（Lua 数值数组）。
 * obj 须为实现了 JsonStreamSerializable（@JsonAdapter 生成）的已注册对象。
 * 跳过项与原因（泛型类型参数无法由 Lua 侧指定 / 无法映射）：
 * - fromJson<T>(json)、fromJsonBytes<T>(bytes)：返回类型 T 由泛型参数决定，Lua 无法提供，
 *   且无反射通道按名字实例化 T；
 * - isValidJson<T>(json)：同样依赖泛型 T，无法绑定。
 * 同包的 Serializer.cj 仅重公开 fastjson 的 API（JsonUtil、流式读写类、接口等），
 * 没有本包自有的 public 类型，故不绑定。
 * JSON 序列化可能抛异常（对象成员非法、流写入失败等），绑定方法内 try/catch：
 * 失败返回 nil，绝不让异常穿出绑定方法。
 *
 * @file[en] resource_serializer_jsonserializer  Lua binding of JSON serialization
 * (three.script.prebind)
 * @brief[en] Binds three.resource.serializer.JsonSerializer as the Lua type
 * three.resource.serializer.JsonSerializer
 * @explain[en] JsonSerializer is a purely static utility class (no constructor); the two
 * object-to-JSON entry points are bound:
 * - toJson(obj): returns a JSON string;
 * - toJsonBytes(obj): returns UTF-8 JSON bytes (Lua numeric array).
 * obj must be a registered object implementing JsonStreamSerializable (@JsonAdapter-generated).
 * Skipped members and reasons (generic type arguments cannot be supplied from Lua / cannot be
 * mapped):
 * - fromJson<T>(json), fromJsonBytes<T>(bytes): the result type T comes from the generic
 *   parameter, which Lua cannot provide, and there is no reflection channel to instantiate T
 *   by name;
 * - isValidJson<T>(json): likewise depends on the generic T and cannot be bound.
 * The sibling Serializer.cj only re-exports fastjson APIs (JsonUtil, stream reader/writer
 * classes, interfaces) and declares no public type of its own, so it is not bound.
 * JSON serialization may throw (invalid members, stream write failures, etc.), so each binding
 * method wraps it in try/catch: failures return nil and exceptions never escape a binding method.
 */
package three.script.prebind

import three.resource.serializer.JsonSerializer
import three._vendor.fastjson.stream.JsonStreamSerializable
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 JsonSerializer 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.resource.serializer.JsonSerializer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of JsonSerializer (static-only class, no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.resource.serializer.JsonSerializer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installJsonSerializer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.serializer.JsonSerializer")
    // ===== 对象 → JSON 字符串（失败返回 nil） =====
    b.staticMethod("toJson") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (args.size > 0 && args[0].isObject) {
                    out = LuaValue.of(JsonSerializer.toJson(prebindAs<JsonStreamSerializable>(args, 0)))
                }
            } catch (_: Exception) {
            }
            [out]
    }
    // ===== 对象 → UTF-8 JSON 字节（失败返回 nil） =====
    b.staticMethod("toJsonBytes") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (args.size > 0 && args[0].isObject) {
                    let raw = JsonSerializer.toJsonBytes(prebindAs<JsonStreamSerializable>(args, 0))
                    out = prebindBytesToLua(Array<UInt8>(raw.size, {i => raw[i]}))
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.install(vm)
}
