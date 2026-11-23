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
 * @file[zh-cn] resource_archive_ziparchive ZIP 归档的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.archive.ZipEntry / ZipArchive 绑定为同名 Lua 类型
 * @explain[zh-cn] ZipEntry 为条目元信息：构造参数按仓颉位置映射
 * new(name, isDirectory, compressedSize, uncompressedSize, crc32, method, flags,
 * [localOffset])，localOffset 省略时取 0；name/isDirectory/compressedSize/
 * uncompressedSize/crc32/method/flags 只读属性。跳过项：localOffset（internal，
 * 仅内部使用，不暴露）。
 * ZipArchive 构造器为 private（只能由 loadFromBytes/loadFromFile 创建），故 Lua 侧
 * 无 new；绑定静态 loadFromBytes(bytes)/loadFromFile(path)、只读属性 entries/
 * entryCount、方法 find/read/extractAll。
 * 字节数据以 Lua 数值数组（0~255）交换；entries 返回 ZipEntry 对象数组。
 * 文件读取、ZIP 结构解析与解压可能抛异常，绑定方法内 try/catch：
 * loadFromBytes/loadFromFile/find/read 失败返回 nil，extractAll 失败返回 false，
 * 绝不让异常穿出绑定方法（lua_error 的 longjmp 会破坏仓颉栈）。
 *
 * @file[en] resource_archive_ziparchive  Lua binding of ZIP archives (three.script.prebind)
 * @brief[en] Binds three.resource.archive.ZipEntry / ZipArchive as Lua types of the same names
 * @explain[en] ZipEntry is entry metadata: the constructor follows the Cangjie positional
 * mapping new(name, isDirectory, compressedSize, uncompressedSize, crc32, method, flags,
 * [localOffset]) where localOffset defaults to 0; name/isDirectory/compressedSize/
 * uncompressedSize/crc32/method/flags are read-only properties. Skipped: localOffset
 * (internal, engine-only).
 * ZipArchive's constructor is private (instances come from loadFromBytes/loadFromFile), so
 * there is no Lua new; the binding exposes static loadFromBytes(bytes)/loadFromFile(path),
 * read-only properties entries/entryCount and methods find/read/extractAll.
 * Byte data is exchanged as Lua numeric arrays (0~255); entries returns an array of ZipEntry
 * objects. File IO, ZIP structure parsing and extraction may throw, so every binding method
 * wraps them in try/catch: loadFromBytes/loadFromFile/find/read return nil on failure,
 * extractAll returns false, and exceptions never escape a binding method (lua_error's
 * longjmp would corrupt Cangjie stack frames).
 */
package three.script.prebind

import three.resource.archive.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 安装 ZipEntry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.archive.ZipEntry）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ZipEntry
 * @param[en] vm The target virtual machine (class table installed at three.resource.archive.ZipEntry)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installZipEntry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.archive.ZipEntry")
    // ===== 构造：name, isDirectory, compressedSize, uncompressedSize,
    //              crc32, method, flags, [localOffset] =====
    b.constructor {
        args => ZipEntry(prebindStr(args, 0), prebindBool(args, 1), prebindInt(args, 2), prebindInt(args, 3),
            UInt32(prebindInt(args, 4) & 0xFFFFFFFF), UInt16(prebindInt(args, 5) & 0xFFFF),
            UInt16(prebindInt(args, 6) & 0xFFFF), prebindInt(args, 7, default: 0))
    }
    // ===== 属性（只读） =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<ZipEntry>().name)}))
    b.property("isDirectory", getter: Some({ref => LuaValue.of(ref.cast<ZipEntry>().isDirectory)}))
    b.property("compressedSize", getter: Some({ref => LuaValue.of(ref.cast<ZipEntry>().compressedSize)}))
    b.property("uncompressedSize", getter: Some({ref => LuaValue.of(ref.cast<ZipEntry>().uncompressedSize)}))
    b.property("crc32", getter: Some({ref => LuaValue.of(Float64(ref.cast<ZipEntry>().crc32))}))
    b.property("method", getter: Some({ref => LuaValue.of(Int64(ref.cast<ZipEntry>().method))}))
    b.property("flags", getter: Some({ref => LuaValue.of(Int64(ref.cast<ZipEntry>().flags))}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ZipArchive 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.archive.ZipArchive）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ZipArchive
 * @param[en] vm The target virtual machine (class table installed at three.resource.archive.ZipArchive)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installZipArchive(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.archive.ZipArchive")
    // ===== 静态加载（失败返回 nil） =====
    b.staticMethod("loadFromBytes") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(zip) <- ZipArchive.loadFromBytes(prebindBytes(vm, args, 0))) {
                    out = prebindRegister(zip, "three.resource.archive.ZipArchive")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.staticMethod("loadFromFile") {
        args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(zip) <- ZipArchive.loadFromFile(prebindStr(args, 0))) {
                    out = prebindRegister(zip, "three.resource.archive.ZipArchive")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    // ===== 属性（只读） =====
    b.property("entryCount", getter: Some({ref => LuaValue.of(ref.cast<ZipArchive>().entryCount)}))
    b.property(
        "entries",
        getter: Some(
            {
                ref =>
                    let list = ref.cast<ZipArchive>().entries
                    var out = Array<LuaValue>(list.size, {_ => LuaValue.Nil})
                    var i: Int64 = 0
                    for (entry in list) {
                        out[i] = prebindRegister(entry, "three.resource.archive.ZipEntry")
                        i += 1
                    }
                    LuaValue.Array(out)
            }
        )
    )
    // ===== 查找 / 解压 =====
    b.method("find") {
        ref, args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(entry) <- ref.cast<ZipArchive>().find(prebindStr(args, 0))) {
                    out = prebindRegister(entry, "three.resource.archive.ZipEntry")
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.method("read") {
        ref, args =>
            var out: LuaValue = LuaValue.Nil
            try {
                if (let Some(data) <- ref
                    .cast<ZipArchive>()
                    .read(prebindStr(args, 0), verify: prebindBool(args, 1, default: true))) {
                    out = prebindBytesToLua(data)
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.method("extractAll") {
        ref, args =>
            var ok = false
            try {
                ok = ref.cast<ZipArchive>().extractAll(prebindStr(args, 0), verify: prebindBool(args, 1, default: true))
            } catch (_: Exception) {
                ok = false
            }
            [LuaValue.Boolean(ok)]
    }
    b.install(vm)
}
