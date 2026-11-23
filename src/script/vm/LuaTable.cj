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
 * @example[zh-cn] 读写表字段与数组
 *
 * @file[en] LuaTable  Lua table reference wrapper (three.script.vm sub-package)
 * @brief[en] Lua table reference wrapper encapsulating a Lua table with field and array access
 * @explain[en] Wraps a Lua table; the reference is kept alive via the luaL_ref registry.
 * Provides field read/write (get/set), array indexing (getIndex/setIndex),
 * length and other operations.
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
import three.utils.memory.VoidPtr
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] Lua 表引用
 * @explain[zh-cn] 持有注册表引用，支持字段/数组读写、长度查询与引用释放。
 *
 * @brief[en] Lua table reference
 * @explain[en] Holds a registry reference and supports field/array access, length query
 * and reference release.
 */
public class LuaTable <: IReleasable {
    /// 所属虚拟机
    private var _vm: LuaVM

    /// 注册表引用（LUA_REGISTRYINDEX 中的引用 id）
    private var _ref: Int32

    /// 是否已释放
    private var _disposed: Bool

    /**
     * @brief[zh-cn] 包装一个已存在的注册表引用
     * @param[zh-cn] vm  所属虚拟机
     * @param[zh-cn] ref 注册表引用（由 luaL_ref 产生）
     *
     * @brief[en] Wraps an existing registry reference
     * @param[en] vm  The owning virtual machine
     * @param[en] ref The registry reference (produced by luaL_ref)
     */
    public init(vm!: LuaVM, ref!: Int32) {
        this._vm = vm
        this._ref = ref
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 从全局变量获取表引用（非表则返回 null）
     * @param[zh-cn] vm   目标虚拟机
     * @param[zh-cn] name 全局变量名
     * @return[zh-cn] 表引用；若全局变量不存在或不是表则返回 None
     *
     * @brief[en] Gets a table reference from a global variable (null when not a table)
     * @param[en] vm   The target virtual machine
     * @param[en] name The global variable name
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
     * @param[zh-cn] narr 预分配数组部分容量
     * @param[zh-cn] nrec 预分配哈希部分容量
     * @return[zh-cn] 新建表的引用
     *
     * @brief[en] Creates a new table in the VM and returns a reference
     * @param[en] vm   The target virtual machine
     * @param[en] narr Preallocated capacity of the array part
     * @param[en] nrec Preallocated capacity of the hash part
     * @return[en] The reference to the newly created table
     */
    public static func create(vm: LuaVM, narr!: Int32 = 0, nrec!: Int32 = 0): LuaTable {
        let L = vm.handle()
        lua_createtable_cj(L, narr, nrec)
        let ref = luaL_ref_cj(L, LUA_REGISTRYINDEX)
        return LuaTable(vm: vm, ref: ref)
    }

    /**
     * @brief[zh-cn] 从栈索引建立表引用（lua_pushvalue + luaL_ref；非表返回 None）
     * @param[zh-cn] vm  所属虚拟机（引用释放时使用 handle）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] idx 栈索引（值不为表时返回 None，栈不变）
     * @return[zh-cn] 表引用；栈顶值不是表时返回 None
     *
     * @brief[en] Creates a table reference from a stack index (lua_pushvalue + luaL_ref;
     * None when the value is not a table)
     * @param[en] vm  The owning virtual machine (used for release)
     * @param[en] L    The underlying lua_State handle
     * @param[en] idx The stack index (returns None and leaves the stack untouched when not a table)
     * @return[en] The table reference, or None when the top value is not a table
     */
    public static func fromStack(vm: LuaVM, L: VoidPtr, idx: Int32): Option<LuaTable> {
        let lv = L.value
        if (lv.isNull()) { return None }
        if (lua_type_cj(lv, idx) != LUA_TTABLE) { return None }
        lua_pushvalue_cj(lv, idx)
        let ref = luaL_ref_cj(lv, LUA_REGISTRYINDEX)
        return Some(LuaTable(vm: vm, ref: ref))
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
    public prop releasable: Bool {
        get() { !this._disposed }
    }

    /**
     * @brief[zh-cn] 释放注册表引用
     * @explain[zh-cn] 释放后 releasable 变为 false，该引用不再可用；重复调用无副作用。
     *
     * @brief[en] Releases the registry reference
     * @explain[en] After release releasable becomes false and the reference is no longer usable;
     * calling again has no effect.
     */
    public func release(): Bool {
        if (this._disposed) { return false }
        let L = this._vm.handle()
        if (!L.isNull()) {
            luaL_unref_cj(L, LUA_REGISTRYINDEX, this._ref)
        }
        this._disposed = true
        return true
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
     * @param[zh-cn] value 要写入的值
     *
     * @brief[en] Writes a field (t[k] = v)
     * @param[en] key   The field name
     * @param[en] value The value to write
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
     * @param[zh-cn] value 要写入的值
     *
     * @brief[en] Writes an array index (t[i] = v, 1-based)
     * @param[en] i     The array index (1-based)
     * @param[en] value The value to write
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
     * @brief[zh-cn] 以数值数组形式读取表中全部数组段元素（t[1]..t[n]，n = len()）
     * @explain[zh-cn] 将表的数组部分（连续整数键 1..len）读为元素数组；哈希部分（字符串键）不读取。
     * 每个元素经栈读取（同 getIndex），**不创建新的注册表引用**（嵌套 table 元素除外，
     * 其 readValue 语义同逐索引取值）。
     * @return[zh-cn] 数组段元素；表无数组部分时返回空数组
     *
     * @brief[en] Reads the whole array part of the table (t[1]..t[n], n = len()) as an element array
     * @explain[en] Reads the array part (contiguous integer keys 1..len) as a LuaValue array; the hash
     * part (string keys) is ignored. Each element is read through the stack (same as getIndex) and
     * creates no new registry reference (except nested table elements, whose readValue semantics match
     * per-index access).
     * @return[en] The array-part elements; an empty array when the table has no array part
     */
    public func getValues(): Array<LuaValue> {
        let L = this._vm.handle()
        this._pushSelf(L)              // 表在 -1
        let n = Int64(lua_objlen_cj(L, -1))
        var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
        for (i in 1..=n) {
            lua_rawgeti_cj(L, -1, Int32(i))   // 值在 -1，表在 -2
            out[i - 1] = _readValue(L, -1)
            lua_settop_cj(L, -2)              // 弹值，保留表
        }
        lua_settop_cj(L, -2)           // 弹表
        return out
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
