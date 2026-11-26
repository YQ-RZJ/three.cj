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
 * @file[zh-cn] LuaObjectRegistry 引擎对象注册表（three.script.binding 子包）
 * @brief[zh-cn] 维护"对象 id ↔ 仓颉对象"的全局注册映射，并提供 userdata 承载/id 读写
 * @explain[zh-cn] 绑定引擎的核心数据面：
 * - 每个暴露给 Lua 的仓颉对象分配一个全局唯一 id，对象本体存放在本注册表；
 * - Lua 侧通过 full userdata（8 字节，内存存放 id）持有该引用；
 * - LuaVM 的对象桥接（setObjectBridge）在第一次调用时由本包注册；
 * - userdata 被 Lua GC 回收时通过 __gc 清理注册表条目（对象本体仍由仓颉 GC 托管）。
 * @example[zh-cn] 注册并读取对象
 * let id = LuaObjectRegistry.register(myObj, "three.Example")
 * let obj = LuaObjectRegistry.get(id)   // Option<Any>
 *
 * @file[en] LuaObjectRegistry  Engine object registry (three.script.binding sub-package)
 * @brief[en] Maintains the global "object id ↔ Cangjie object" mapping plus userdata id I/O
 * @explain[en] The core data plane of the binding engine:
 * - every Cangjie object exposed to Lua gets a globally unique id; the object itself lives here;
 * - Lua side holds the reference via full userdata (8 bytes, storing the id);
 * - LuaVM's object bridge (setObjectBridge) is registered by this package on first use;
 * - when a userdata is collected by Lua GC, the registry entry is cleared via __gc
 *   (the object itself is still owned by the Cangjie GC).
 * @example[en] Registering and reading an object
 * let id = LuaObjectRegistry.register(myObj, "three.Example")
 * let obj = LuaObjectRegistry.get(id)   // Option<Any>
 */
package three.script.binding

import std.collection.*
import three._vendor.luajit4cj.luajit.*
import three.script.vm.*
import three.utils.memory.VoidPtr

// =============================================================================
// 全局对象注册表（id ↔ 仓颉对象 + 绑定类名）
// =============================================================================

/** 下一个对象 id */
private var _nextObjId: Int64 = 1

/** 对象注册表：id → (仓颉对象, 绑定类名) */
private var _objRegistry: HashMap<Int64, (Any, String)> = HashMap()

/** 是否已安装 LuaVM 对象桥接 */
private var _bridgeInstalled: Bool = false

// =============================================================================
// LuaObjectRegistry：对象注册表 + userdata 承载
// =============================================================================

/**
 * @brief[zh-cn] 引擎对象注册表（静态方法集合）
 * @explain[zh-cn] 支持：
 * - register：分配 id 并保存仓颉对象
 * - get / getAs：按 id 取对象（Option / 强转）
 * - unregister：按 id 移除
 * - classNameOf：查询对象绑定类名
 * - pushUserdataTo / installBridge：userdata 承载与 LuaVM 桥接
 *
 * @brief[en] Engine object registry (a collection of static methods)
 * @explain[en] Supports:
 * - register: allocates an id and stores the Cangjie object
 * - get / getAs: fetches an object by id (Option / cast)
 * - unregister: removes an entry by id
 * - classNameOf: queries the bound class name of an object
 * - pushUserdataTo / installBridge: userdata carrier and LuaVM bridging
 */
public class LuaObjectRegistry {

    /**
     * @brief[zh-cn] 分配 id 并注册仓颉对象
     * @param[zh-cn] obj 仓颉对象（Any）
     * @param[zh-cn] className 绑定类名（Lua 侧 metatable 键，如 "three.core.math.Vector3"）
     * @return[zh-cn] 对象 id（>0；供 userdata 承载与后续查询）
     *
     * @brief[en] Allocates an id and registers a Cangjie object
     * @param[en] obj The Cangjie object (Any)
     * @param[en] className The bound class name (the Lua-side metatable key, e.g. "three.core.math.Vector3")
     * @return[en] The object id (>0; carried by userdata and used for later lookups)
     */
    public static func register(obj: Any, className: String): Int64 {
        let id = _nextObjId
        _nextObjId += 1
        _objRegistry[id] = (obj, className)
        return id
    }

    /**
     * @brief[zh-cn] 按 id 取仓颉对象
     * @param[zh-cn] id 注册时返回的对象 id
     * @return[zh-cn] 对象；不存在或已移除时返回 None
     *
     * @brief[en] Fetches the Cangjie object by id
     * @param[en] id The object id returned at registration
     * @return[en] The object, or None if absent/removed
     */
    public static func get(id: Int64): Option<Any> {
        if (_objRegistry.contains(id)) {
            return Some(_objRegistry.get(id).getOrThrow()[0])
        }
        return None
    }

    /**
     * @brief[zh-cn] 按 id 取对象并强转为 T
     * @explain[zh-cn] 类型不匹配或对象不存在时抛异常（调用方负责捕获/容错）。
     * @param[zh-cn] id 对象 id
     * @return[zh-cn] 强转后的对象
     * @throws[zh-cn] Exception 类型不匹配或对象缺失时抛出
     *
     * @brief[en] Fetches the object by id and casts it to T
     * @explain[en] Throws when the type does not match or the object is missing
     * (the caller is responsible for catching/failure tolerance).
     * @param[en] id The object id
     * @return[en] The cast object
     * @throws[en] Exception Thrown when the type does not match or the object is missing
     */
    public static func getAs<T>(id: Int64): T {
        let obj = LuaObjectRegistry.get(id).getOrThrow()
        return (obj as T).getOrThrow()
    }

    /**
     * @brief[zh-cn] 按 id 移除注册表条目
     * @param[zh-cn] id 对象 id
     * @return[zh-cn] 是否移除成功（条目存在）
     *
     * @brief[en] Removes the registry entry by id
     * @param[en] id The object id
     * @return[en] Whether an entry was removed
     */
    public static func unregister(id: Int64): Bool {
        if (_objRegistry.contains(id)) {
            _objRegistry.remove(id)
            return true
        }
        return false
    }

    /**
     * @brief[zh-cn] 查询对象的绑定类名
     * @param[zh-cn] id 对象 id
     * @return[zh-cn] 绑定类名；不存在时返回 None
     *
     * @brief[en] Queries the bound class name of the object
     * @param[en] id The object id
     * @return[en] The bound class name, or None if absent
     */
    public static func classNameOf(id: Int64): Option<String> {
        if (_objRegistry.contains(id)) {
            return Some(_objRegistry.get(id).getOrThrow()[1])
        }
        return None
    }

    /**
     * @brief[zh-cn] 当前注册对象数量
     *
     * @brief[en] The number of currently registered objects
     */
    public static prop count: Int64 {
        get() { Int64(_objRegistry.size) }
    }

    // =========================================================================
    // userdata 承载（桥接 LuaVM）
    // =========================================================================

    /**
     * @brief[zh-cn] 安装 LuaVM 对象桥接（push/read userdata）
     * @explain[zh-cn] 仅需调用一次（重复安装无害，可安全用于多 VM 场景）。
     * 安装后：
     * - push：把对象 id 写入 8 字节 full userdata 并设置绑定类 metatable；
     * - read：从 lightuserdata/full userdata 读取对象 id。
     *
     * @brief[en] Installs the LuaVM object bridge (push/read userdata)
     * @explain[en] Only needs to be called once (re-installation is harmless and safe
     * for multi-VM scenarios). After installation:
     * - push: writes the object id into an 8-byte full userdata and sets the bound
     *   class metatable;
     * - read: reads the object id from lightuserdata/full userdata.
     */
    public static func installBridge(): Unit {
        if (_bridgeInstalled) {
            return
        }
        _bridgeInstalled = true
        LuaVM.setObjectBridge(
            Some({ L, id => LuaObjectRegistry._pushUserdata(L.value, id) }),
            Some({ L, idx => LuaObjectRegistry._readId(L.value, idx) }))
    }

    /// 内部：把对象 id 写入 userdata 并设置 metatable（包含 C 函数分派）
    internal static func _pushUserdata(L: CPointer<Unit>, id: Int64): Unit {
        if (L.isNull()) { return }
        // 1. 分配 8 字节 userdata 承载 id
        let ud = lua_newuserdata_cj(L, UIntNative(8))
        unsafe {
            let p = CPointer<Int64>(ud)
            p.write(id)
        }
        // 2. 设置绑定类 metatable（luaL_setmetatable：按名称从注册表取类型元表）
        let cnOpt = LuaObjectRegistry.classNameOf(id)
        if (let Some(cn) <- cnOpt) {
            let cs = unsafe { LibC.mallocCString(cn) }
            luaL_setmetatable_cj(L, cs)
            unsafe { LibC.free(cs) }
        }
    }

    /// 内部：从 userdata 读取对象 id（非本引擎 userdata 返回 0）
    internal static func _readId(L: CPointer<Unit>, idx: Int32): Int64 {
        if (L.isNull()) { return 0 }
        let t = lua_type_cj(L, idx)
        if (t == LUA_TLIGHTUSERDATA || t == LUA_TUSERDATA) {
            let ud = lua_touserdata_cj(L, idx)
            if (ud.isNull()) { return 0 }
            unsafe {
                let p = CPointer<Int64>(ud)
                return p.read()
            }
        }
        return 0
    }

    // =========================================================================
    // 数组便捷工具（仓颉数组 ↔ Lua 1-based table）
    // =========================================================================

    /**
     * @brief[zh-cn] 压 Float64 数组为 Lua table（1-based；空数组压空表）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] arr 浮点数组
     *
     * @brief[en] Pushes an Array<Float64> as a Lua table (1-based; empty array pushes an empty table)
     * @param[en] L   The underlying lua_State handle
     * @param[en] arr The float array
     */
    public static func pushArrayFloat(L: VoidPtr, arr: Array<Float64>): Unit {
        let lv = L.value
        if (lv.isNull()) { return }
        let n = Int32(arr.size)
        lua_createtable_cj(lv, n, 0)
        var i: Int32 = 1
        for (v in arr) {
            lua_pushnumber_cj(lv, v)
            lua_rawseti_cj(lv, -2, i)
            i += 1
        }
    }

    /**
     * @brief[zh-cn] 读取 Lua table（1-based）为 Float64 数组（非数值槽取 0.0）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] idx 栈索引（非表时返回空数组）
     * @return[zh-cn] 浮点数组
     *
     * @brief[en] Reads a Lua table (1-based) as an Array<Float64> (non-number slots become 0.0)
     * @param[en] L   The underlying lua_State handle
     * @param[en] idx The stack index (returns an empty array when not a table)
     * @return[en] The float array
     */
    public static func readFloatArray(L: VoidPtr, idx: Int32): Array<Float64> {
        let lv = L.value
        if (lv.isNull()) { return Array<Float64>() }
        if (lua_type_cj(lv, idx) != LUA_TTABLE) { return Array<Float64>() }
        let len = Int64(lua_objlen_cj(lv, idx))
        var out = Array<Float64>(len, { _ => 0.0 })
        for (i in 0..len) {
            lua_rawgeti_cj(lv, idx, Int32(i + 1))
            if (lua_type_cj(lv, -1) == LUA_TNUMBER) {
                out[i] = lua_tonumber_cj(lv, -1)
            }
            lua_settop_cj(lv, -2)
        }
        return out
    }

    /**
     * @brief[zh-cn] 压 Int64 数组为 Lua table（1-based；空数组压空表）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] arr 整数数组
     *
     * @brief[en] Pushes an Array<Int64> as a Lua table (1-based; empty array pushes an empty table)
     * @param[en] L   The underlying lua_State handle
     * @param[en] arr The integer array
     */
    public static func pushIntArray(L: VoidPtr, arr: Array<Int64>): Unit {
        let lv = L.value
        if (lv.isNull()) { return }
        let n = Int32(arr.size)
        lua_createtable_cj(lv, n, 0)
        var i: Int32 = 1
        for (v in arr) {
            lua_pushinteger_cj(lv, v)
            lua_rawseti_cj(lv, -2, i)
            i += 1
        }
    }

    /**
     * @brief[zh-cn] 读取 Lua table（1-based）为 Int64 数组（非数值槽取 0）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] idx 栈索引（非表时返回空数组）
     * @return[zh-cn] 整数数组
     *
     * @brief[en] Reads a Lua table (1-based) as an Array<Int64> (non-number slots become 0)
     * @param[en] L   The underlying lua_State handle
     * @param[en] idx The stack index (returns an empty array when not a table)
     * @return[en] The integer array
     */
    public static func readIntArray(L: VoidPtr, idx: Int32): Array<Int64> {
        let lv = L.value
        if (lv.isNull()) { return Array<Int64>() }
        if (lua_type_cj(lv, idx) != LUA_TTABLE) { return Array<Int64>() }
        let len = Int64(lua_objlen_cj(lv, idx))
        var out = Array<Int64>(len, { _ => 0 })
        for (i in 0..len) {
            lua_rawgeti_cj(lv, idx, Int32(i + 1))
            if (lua_type_cj(lv, -1) == LUA_TNUMBER) {
                out[i] = lua_tointeger_cj(lv, -1)
            }
            lua_settop_cj(lv, -2)
        }
        return out
    }

    /**
     * @brief[zh-cn] 压 String 数组为 Lua table（1-based；空数组压空表）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] arr 字符串数组
     *
     * @brief[en] Pushes an Array<String> as a Lua table (1-based; empty array pushes an empty table)
     * @param[en] L   The underlying lua_State handle
     * @param[en] arr The string array
     */
    public static func pushStringArray(L: VoidPtr, arr: Array<String>): Unit {
        let lv = L.value
        if (lv.isNull()) { return }
        let n = Int32(arr.size)
        lua_createtable_cj(lv, n, 0)
        var i: Int32 = 1
        for (v in arr) {
            let cs = unsafe { LibC.mallocCString(v) }
            lua_pushstring_cj(lv, cs)
            unsafe { LibC.free(cs) }
            lua_rawseti_cj(lv, -2, i)
            i += 1
        }
    }

    /**
     * @brief[zh-cn] 读取 Lua table（1-based）为 String 数组（非字符串槽取 ""）
     * @param[zh-cn] L   底层 lua_State 句柄
     * @param[zh-cn] idx 栈索引（非表时返回空数组）
     * @return[zh-cn] 字符串数组
     *
     * @brief[en] Reads a Lua table (1-based) as an Array<String> (non-string slots become "")
     * @param[en] L   The underlying lua_State handle
     * @param[en] idx The stack index (returns an empty array when not a table)
     * @return[en] The string array
     */
    public static func readStringArray(L: VoidPtr, idx: Int32): Array<String> {
        let lv = L.value
        if (lv.isNull()) { return Array<String>() }
        if (lua_type_cj(lv, idx) != LUA_TTABLE) { return Array<String>() }
        let len = Int64(lua_objlen_cj(lv, idx))
        var out = Array<String>(len, { _ => "" })
        for (i in 0..len) {
            lua_rawgeti_cj(lv, idx, Int32(i + 1))
            if (lua_type_cj(lv, -1) == LUA_TSTRING) {
                let cs = lua_tolstring_cj(lv, -1, CPointer<UIntNative>())
                if (!cs.isNull()) {
                    out[i] = unsafe { cs.toString() }
                }
            }
            lua_settop_cj(lv, -2)
        }
        return out
    }
}