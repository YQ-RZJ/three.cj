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
 * @file[zh-cn] resource_pipeline_assetbundle 资源包与构建器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.pipeline.BundleEntry / AssetBundle / AssetBundleBuilder
 * 绑定为同名 Lua 类型
 * @explain[zh-cn] BundleEntry 为结构体值对象：按值注册，构造按仓颉位置映射
 * new(name, offset, size, crc32)；字段仅有 getter——结构体在注册表中按值装箱，
 * cast 取回的是副本，setter 无法回写，故不提供（需修改请重新 new）。
 * AssetBundle 构造器为 private（只能由 loadFromBytes/loadFromFile 创建），Lua 侧无 new；
 * 绑定静态 MAGIC（字节数组）、VERSION、loadFromBytes(bytes, verify)/loadFromFile(path,
 * verify)、只读属性 entryCount、方法 contains/get/read/getNames。
 * AssetBundleBuilder 绑定无参构造、add(name, bytes)（链式返回自身）、
 * addFile(name, path)（成功返回自身，失败返回 nil）、build()（档案字节）、
 * writeTo(path)（成功 true / 失败 false）。
 * 字节以 Lua 数值数组（0~255）交换；getNames 返回字符串数组。
 * 档案解析、CRC 校验与文件读写可能抛异常，绑定方法内 try/catch：解析/读取失败返回
 * nil，writeTo/addFile 失败返回 false/nil，绝不让异常穿出绑定方法。
 * 跳过项：AssetBundle 的私有 init 与内部字段（_data/_entries/_dataBase）均为非公开成员。
 *
 * @file[en] resource_pipeline_assetbundle  Lua bindings of asset bundles and the builder
 * (three.script.prebind)
 * @brief[en] Binds three.resource.pipeline.BundleEntry / AssetBundle / AssetBundleBuilder as
 * Lua types of the same names
 * @explain[en] BundleEntry is a struct value object: registered by value, constructed with the
 * Cangjie positional mapping new(name, offset, size, crc32); fields are getter-only — structs
 * are boxed by value in the registry and cast returns a copy, so setters could not write back
 * (create a new one instead).
 * AssetBundle's constructor is private (instances come from loadFromBytes/loadFromFile), so
 * there is no Lua new; the binding exposes static MAGIC (byte array), VERSION,
 * loadFromBytes(bytes, verify)/loadFromFile(path, verify), the read-only property entryCount
 * and methods contains/get/read/getNames.
 * AssetBundleBuilder binds the parameterless constructor, add(name, bytes) (chainable, returns
 * self), addFile(name, path) (self on success, nil on failure), build() (archive bytes) and
 * writeTo(path) (true on success, false on failure).
 * Bytes are exchanged as Lua numeric arrays (0~255); getNames returns a string array.
 * Archive parsing, CRC verification and file IO may throw, so each binding method wraps them in
 * try/catch: parse/read failures return nil, writeTo/addFile failures return false/nil, and
 * exceptions never escape a binding method.
 * Skipped: AssetBundle's private init and internal fields (_data/_entries/_dataBase) are
 * non-public members.
 */
package three.script.prebind

import three.resource.pipeline.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 安装 BundleEntry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.pipeline.BundleEntry）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BundleEntry
 * @param[en] vm The target virtual machine (class table installed at three.resource.pipeline.BundleEntry)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBundleEntry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.pipeline.BundleEntry")
    // ===== 构造：name, offset, size, crc32 =====
    b.constructor {
        args => BundleEntry(prebindStr(args, 0), UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
            UInt32(prebindInt(args, 2) & 0xFFFFFFFF), UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
    }
    // ===== 属性（只读：结构体按值装箱，setter 无法回写） =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<BundleEntry>().name)}))
    b.property("offset", getter: Some({ref => LuaValue.of(Float64(ref.cast<BundleEntry>().offset))}))
    b.property("size", getter: Some({ref => LuaValue.of(Float64(ref.cast<BundleEntry>().size))}))
    b.property("crc32", getter: Some({ref => LuaValue.of(Float64(ref.cast<BundleEntry>().crc32))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AssetBundle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.pipeline.AssetBundle）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AssetBundle
 * @param[en] vm The target virtual machine (class table installed at three.resource.pipeline.AssetBundle)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAssetBundle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.pipeline.AssetBundle")
    // ===== 静态常量 =====
    b.staticMethod("MAGIC") {_ => [prebindBytesToLua(AssetBundle.MAGIC)]}
    b.staticMethod("VERSION") {_ => [LuaValue.of(Float64(AssetBundle.VERSION))]}
    // ===== 静态加载（失败返回 nil） =====
    b.staticMethod("loadFromBytes") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(bundle) <- AssetBundle.loadFromBytes(prebindBytes(vm, args, 0),
                    verify: prebindBool(args, 1, default: true))) {
                    out = prebindRegister(bundle, "three.resource.pipeline.AssetBundle")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.staticMethod("loadFromFile") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(bundle) <- AssetBundle.loadFromFile(prebindStr(args, 0),
                    verify: prebindBool(args, 1, default: true))) {
                    out = prebindRegister(bundle, "three.resource.pipeline.AssetBundle")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    // ===== 属性（只读） =====
    b.property("entryCount", getter: Some({ref => LuaValue.of(ref.cast<AssetBundle>().entryCount)}))
    // ===== 查询 / 读取 =====
    b.method("contains") {
        ref, args => [LuaValue.of(ref.cast<AssetBundle>().contains(prebindStr(args, 0)))]
    }
    b.method("get") {
        ref, args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(entry) <- ref.cast<AssetBundle>().get(prebindStr(args, 0))) {
                    out = prebindRegister(entry, "three.resource.pipeline.BundleEntry")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.method("read") {
        ref, args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(data) <- ref.cast<AssetBundle>().read(prebindStr(args, 0))) {
                    out = prebindBytesToLua(data)
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.method("getNames") {
        ref, _ =>
            let names = ref.cast<AssetBundle>().getNames()
            var out = Array<LuaValue>(names.size, {_ => LuaValue.Nil})
            var i: Int64 = 0
            for (name in names) {
                out[i] = LuaValue.of(name)
                i += 1
            }
            [LuaValue.Array(out)]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AssetBundleBuilder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.pipeline.AssetBundleBuilder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AssetBundleBuilder
 * @param[en] vm The target virtual machine (class table installed at
 *            three.resource.pipeline.AssetBundleBuilder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAssetBundleBuilder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.pipeline.AssetBundleBuilder")
    // ===== 构造 =====
    b.constructor {_ => AssetBundleBuilder()}
    // ===== 添加条目（链式返回自身） =====
    b.method("add") {
        ref, args =>
            ref.cast<AssetBundleBuilder>().add(prebindStr(args, 0), prebindBytes(vm, args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addFile") {
        ref, args => match (ref.cast<AssetBundleBuilder>().addFile(prebindStr(args, 0), prebindStr(args, 1))) {
            case Some(_) => [LuaValue.Object(ref.id)]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 产出 =====
    b.method("build") {
        ref, _ => [prebindBytesToLua(ref.cast<AssetBundleBuilder>().build())]
    }
    b.method("writeTo") {
        ref, args =>
            var ok = false
            try {
                ok = ref.cast<AssetBundleBuilder>().writeTo(prebindStr(args, 0))
            } catch (_: Exception) {
                ok = false
            }
            [LuaValue.Boolean(ok)]
    }
    b.install(vm)
}
