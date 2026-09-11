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
 * @file[zh-cn] LuaTable Lua 表引用封装（three.script.vm 子包）
 * @brief[zh-cn] Lua 表引用封装，包装 Lua 侧的表并支持字段与数组访问
 * @explain[zh-cn] 包装 Lua 侧的表（table），内部经 luaL_ref 注册表引用保持有效，
 * 提供字段读写（get/set）、数组索引（getIndex/setIndex）、长度等操作。
 *
 * @file[en] LuaTable  Lua table reference wrapper (three.script.vm sub-package)
 * @brief[en] Lua table reference wrapper encapsulating a Lua table with field and array access
 * @explain[en] Wraps a Lua table; the reference is kept alive via the luaL_ref registry.
 * Provides field read/write (get/set), array indexing (getIndex/setIndex),
 * length and other operations.
 *
 * @example[zh-cn] 读写表字段与数组
 * @example[en] Reading/writing table fields and arrays
 * vm.doString("player = {name='Alice', hp=100, x=1, y=2}")
 * let t = LuaTable.fromGlobal(vm, "player")
 * t.set("hp", LuaValue.of(Int64(90)))          // 写字段
 * let hp = t.get("hp").numberValue()           // 读字段
 * let x = t.getIndex(1).numberValue()          // 数组索引
 * let n = t.len()                              // 数组长度
 */
package three.script.vm

import luajit4cj.luajit.*

/**
 * @brief[zh-cn] Lua 表引用
 * @explain[zh-cn] 持有注册表引用，支持字段/数组读写、长度查询与引用释放。
 *
 * @brief[en] Lua table reference
 * @explain[en] Holds a registry reference and supports field/array access, length query
 * and reference release.
 */
public class LuaTable {
    /// 所属虚拟机
    private var _vm: LuaVM

    /// 注册表引用（LUA_REGISTRYINDEX 中的引用 id）
    private var _ref: Int32

    /// 是否已释放
    private var _disposed: Bool

    /**
     * @brief[zh-cn] 包装一个已存在的注册表引用
     * @param[zh-cn] vm  所属虚拟机
     * ref 注册表引用（由 luaL_ref 产生）
     *
     * @brief[en] Wraps an existing registry reference
     * @param[en] vm  The owning virtual machine
     * ref The registry reference (produced by luaL_ref)
     */
    public init(vm!: LuaVM, ref!: Int32) {
        this._vm = vm
        this._ref = ref
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 从全局变量获取表引用（非表则返回 null）
     * @param[zh-cn] vm   目标虚拟机
     * name 全局变量名
     * @return[zh-cn] 表引用；若全局变量不存在或不是表则返回 None
     *
     * @brief[en] Gets a table reference from a global variable (null when not a table)
     * @param[en] vm   The target virtual machine
     * name The global variable name
     * @return[en] The table reference, or None if the global is missing or not a table
     */
    public static func fromGlobal(vm: LuaVM, name: String): Option<LuaTable> {
        let L = vm.handle()
        if (L.isNull()) { return None }
        let cs = _toCString(name)
        lua_getfield_cj(L, LUA_GLOBALSINDEX, cs)
        _freeCString(cs)
        let t = lua_type_cj(L, -1)
        if (t != 5) {  // LUA_TTABLE
            lua_settop_cj(L, -2)
            return None
        }
        let ref = luaL_ref_cj(L, LUA_REGISTRYINDEX)
        return Some(LuaTable(vm: vm, ref: ref))
    }

    /**
     * @brief[zh-cn] 在 VM 中创建一个新表并返回引用
     * @param[zh-cn] vm   目标虚拟机
     * narr 预分配数组部分容量
     * nrec 预分配哈希部分容量
     * @return[zh-cn] 新建表的引用
     *
     * @brief[en] Creates a new table in the VM and returns a reference
     * @param[en] vm   The target virtual machine
     * narr Preallocated capacity of the array part
     * nrec Preallocated capacity of the hash part
     * @return[en] The reference to the newly created table
     */
    public static func create(vm: LuaVM, narr!: Int32 = 0, nrec!: Int32 = 0): LuaTable {
        let L = vm.handle()
        lua_createtable_cj(L, narr, nrec)
        let ref = luaL_ref_cj(L, LUA_REGISTRYINDEX)
        return LuaTable(vm: vm, ref: ref)
    }

    /**
     * @brief[zh-cn] 注册表引用 id
     *
     * @brief[en] The registry reference id
     */
    public prop ref: Int32 {
        get() { this._ref }
    }

    /**
     * @brief[zh-cn] 是否有效（未被释放）
     *
     * @brief[en] Whether the reference is still valid (not disposed)
     */
    public prop isValid: Bool {
        get() { !this._disposed }
    }

    /**
     * @brief[zh-cn] 释放注册表引用
     * @explain[zh-cn] 释放后 isValid 变为 false，该引用不再可用；重复调用无副作用。
     *
     * @brief[en] Releases the registry reference
     * @explain[en] After release isValid becomes false and the reference is no longer usable;
     * calling again has no effect.
     */
    public func dispose(): Unit {
        if (this._disposed) { return }
        let L = this._vm.handle()
        if (!L.isNull()) {
            luaL_unref_cj(L, LUA_REGISTRYINDEX, this._ref)
        }
        this._disposed = true
    }

    // =========================================================================
    // 字段读写
    // =========================================================================

    /**
     * @brief[zh-cn] 读取字段（t[k]），返回 LuaValue
     * @param[zh-cn] key 字段名
     * @return[zh-cn] 字段值（不存在时返回 nil）
     *
     * @brief[en] Reads a field (t[k]) and returns a LuaValue
     * @param[en] key The field name
     * @return[en] The field value (nil when absent)
     */
    public func get(key: String): LuaValue {
        let L = this._vm.handle()
        this._pushSelf(L)              // 表在 -1
        let cs = _toCString(key)
        lua_getfield_cj(L, -1, cs)
        _freeCString(cs)
        let v = _readValue(L, -1)
        lua_settop_cj(L, -3)           // 弹出表 + 字段值
        return v
    }

    /**
     * @brief[zh-cn] 写入字段（t[k] = v）
     * @param[zh-cn] key   字段名
     * value 要写入的值
     *
     * @brief[en] Writes a field (t[k] = v)
     * @param[en] key   The field name
     * value The value to write
     */
    public func set(key: String, value: LuaValue): Unit {
        let L = this._vm.handle()
        this._pushSelf(L)              // 表在 -1
        _pushValue(L, value)           // 值在 -1，表在 -2
        let cs = _toCString(key)
        lua_setfield_cj(L, -2, cs)
        _freeCString(cs)
        lua_settop_cj(L, -2)           // 弹出剩余表
    }

    /**
     * @brief[zh-cn] 读取数组索引（t[i]，1 起始）
     * @param[zh-cn] i 数组索引（从 1 开始）
     * @return[zh-cn] 索引处的值（不存在时返回 nil）
     *
     * @brief[en] Reads an array index (t[i], 1-based)
     * @param[en] i The array index (1-based)
     * @return[en] The value at the index (nil when absent)
     */
    public func getIndex(i: Int32): LuaValue {
        let L = this._vm.handle()
        this._pushSelf(L)              // 表在 -1
        lua_rawgeti_cj(L, -1, i)       // 值在 -1，表在 -2
        let v = _readValue(L, -1)
        lua_settop_cj(L, -3)           // 弹出表 + 值（栈共 2 个元素）
        return v
    }

    /**
     * @brief[zh-cn] 写入数组索引（t[i] = v，1 起始）
     * @param[zh-cn] i     数组索引（从 1 开始）
     * value 要写入的值
     *
     * @brief[en] Writes an array index (t[i] = v, 1-based)
     * @param[en] i     The array index (1-based)
     * value The value to write
     */
    public func setIndex(i: Int32, value: LuaValue): Unit {
        let L = this._vm.handle()
        this._pushSelf(L)              // 表在 -1
        _pushValue(L, value)           // 值在 -1，表在 -2
        lua_rawseti_cj(L, -2, i)
        lua_settop_cj(L, -2)           // 弹出剩余表
    }

    /**
     * @brief[zh-cn] 表长度（数组部分，#t）
     * @return[zh-cn] 表数组部分的长度
     *
     * @brief[en] Table length (array part, #t)
     * @return[en] The length of the array part of the table
     */
    public func len(): Int64 {
        let L = this._vm.handle()
        this._pushSelf(L)
        let n = Int64(lua_objlen_cj(L, -1))
        lua_settop_cj(L, -2)
        return n
    }

    /**
     * @brief[zh-cn] 表是否为数组（连续整数键）
     *
     * @brief[en] Whether the table is an array (consecutive integer keys)
     */
    public prop isArray: Bool {
        get() {
            // 长度 > 0 且第 len 个元素存在即可判定
            let n = this.len()
            if (n <= 0) { return false }
            let last = this.getIndex(Int32(n))
            return !last.isNil
        }
    }

    // =========================================================================
    // 内部
    // =========================================================================

    /// 把自身压入栈（经注册表引用）
    private func _pushSelf(L: CPointer<Unit>): Unit {
        lua_rawgeti_cj(L, LUA_REGISTRYINDEX, this._ref)
    }
}
