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
 * @file[zh-cn] LuaBinder 仓颉 ↔ Lua 双向绑定（three.script.binding 子包）
 * @brief[zh-cn] 仓颉与 Lua 双向绑定，将仓颉函数注册为 Lua 全局函数或表方法
 * @explain[zh-cn] 将仓颉函数注册为 Lua 全局函数/表方法，实现"仓颉方法绑定"：
 *
 * @file[en] LuaBinder  Bidirectional Cangjie-Lua binding (three.script.binding sub-package)
 * @brief[en] Bidirectional Cangjie-Lua binding; registers Cangjie functions as Lua globals or table methods
 * @explain[en] Registers Cangjie functions as Lua globals/table methods, implementing
 * "Cangjie method binding":
 *
 * @example[zh-cn] 注册仓颉函数并在 Lua 中调用
 * @example[en] Registering a Cangjie function and calling it from Lua
 * LuaBinder.registerFunction(vm, "cj_add") { args ->
 * let a = args[0].numberValue()
 * let b = args[1].numberValue()
 * [LuaValue.of(a + b)]
 * }
 * vm.doString("result = cj_add(2, 3)")   // Lua 侧直接调用仓颉函数
 * @note[zh-cn] 绑定机制（CFFI 关键约束）：lua_CFunction 是 CFunc<(CPointer<Unit>) -> Int32>，
 * 仓颉侧定义的 CFunc Lambda 不能捕获变量，因此无法在闭包中直接持有仓颉回调对象。
 * 解法：全局注册表 _handlers（id → 回调），注册时把 id 作为闭包 upvalue（lightuserdata）
 * 传给 C 闭包；C 分发函数从 upvalue 取回 id 查表调用仓颉回调，再把返回值压回 Lua 栈。
 * @note[en] Binding mechanism (CFFI constraint): lua_CFunction is CFunc<(CPointer<Unit>) -> Int32>,
 * and Cangjie CFunc lambdas cannot capture variables, so the Cangjie callback cannot be
 * held directly in a closure. Solution: a global registry _handlers (id → callback); the id
 * is passed to the C closure as an upvalue (lightuserdata); the C dispatcher reads the id
 * from the upvalue, looks up and calls the Cangjie callback, then pushes results back.
 */
package three.script.binding

import std.collection.*
import luajit4cj.luajit.*
import three.script.vm.*

// =============================================================================
// 全局注册表（id → 仓颉回调）
// =============================================================================

/** 下一个回调 id */
private var _nextId: Int64 = 1

/** 回调注册表：id → (参数数组) -> 返回值数组 */
private var _handlers: HashMap<Int64, (Array<LuaValue>) -> Array<LuaValue>> = HashMap()

/** upvalue 索引 1（lua_upvalueindex(1) = LUA_GLOBALSINDEX - 1） */
private let _UPVALUE1: Int32 = -10003

// =============================================================================
// LuaBinder：静态绑定工具
// =============================================================================

/**
 * @brief[zh-cn] 仓颉 ↔ Lua 绑定器（静态方法集合）
 * @explain[zh-cn] 支持：
 * - registerFunction：注册全局函数（Lua 调仓颉）
 * - registerTableMethods：注册表方法集（Lua 对象方法调仓颉）
 * - unregister：按名称移除
 *
 * @brief[en] Cangjie-Lua binder (a collection of static methods)
 * @explain[en] Supports:
 * - registerFunction: registers a global function (Lua calls Cangjie)
 * - registerTableMethods: registers a set of table methods (Lua object methods call Cangjie)
 * - unregister: removes by id
 */
public class LuaBinder {

    /**
     * @brief[zh-cn] 注册仓颉函数为 Lua 全局函数
     * @param[zh-cn] vm   目标虚拟机
     * name Lua 侧全局函数名
     * fn   仓颉回调：(LuaValue 参数数组) -> 返回值数组
     * @return[zh-cn] 注册的 id（供 unregister 使用；-1 表示失败）
     *
     * @brief[en] Registers a Cangjie function as a Lua global function
     * @param[en] vm   The target virtual machine
     * name The Lua-side global function name
     * fn   The Cangjie callback: (LuaValue argument array) -> result array
     * @return[en] The registered id (for unregister; -1 on failure)
     *
     * @note[zh-cn] 用法示例：
     * @note[en] Example usage:
     * LuaBinder.registerFunction(vm, "add") { args ->
     * [LuaValue.of(args[0].numberValue() + args[1].numberValue())]
     * }
     */
    public static func registerFunction(vm: LuaVM, name: String,
                                        fn: (Array<LuaValue>) -> Array<LuaValue>): Int64 {
        let L = vm.handle()
        if (L.isNull()) { return -1 }
        // 1. 分配 id 并存入全局注册表
        let id = _nextId
        _nextId += 1
        _handlers[id] = fn
        // 2. 压 upvalue（id 作为整数，供 C 闭包取回）
        lua_pushinteger_cj(L, id)
        // 3. 创建 C 闭包（分发函数，1 个 upvalue）
        let cf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatch(L2) }
        lua_pushcclosure_cj(L, cf, 1)
        // 4. 注册为全局变量
        let cs = unsafe { LibC.mallocCString(name) }
        lua_setfield_cj(L, LUA_GLOBALSINDEX, cs)
        unsafe { LibC.free(cs) }
        return id
    }

    /**
     * @brief[zh-cn] 注册一组仓颉函数为 Lua 全局函数（批量）
     * @param[zh-cn] vm    目标虚拟机
     * funcs 函数名 → 仓颉回调
     *
     * @brief[en] Registers a batch of Cangjie functions as Lua global functions
     * @param[en] vm    The target virtual machine
     * funcs Function name → Cangjie callback
     */
    public static func registerFunctions(vm: LuaVM,
                                         funcs: HashMap<String, (Array<LuaValue>) -> Array<LuaValue>>): Unit {
        for ((name, fn) in funcs) {
            LuaBinder.registerFunction(vm, name, fn)
        }
    }

    /**
     * @brief[zh-cn] 把仓颉函数注册为 Lua 表的字段（方法）
     * @param[zh-cn] vm    目标虚拟机
     * table 目标表（LuaTable 引用）
     * name  字段名
     * fn    仓颉回调
     * @return[zh-cn] 注册的 id
     *
     * @brief[en] Registers a Cangjie function as a field (method) of a Lua table
     * @param[en] vm    The target virtual machine
     * table The target table (LuaTable reference)
     * name  The field name
     * fn    The Cangjie callback
     * @return[en] The registered id
     */
    public static func registerTableMethod(vm: LuaVM, table: LuaTable, name: String,
                                           fn: (Array<LuaValue>) -> Array<LuaValue>): Int64 {
        let L = vm.handle()
        if (L.isNull()) { return -1 }
        let id = _nextId
        _nextId += 1
        _handlers[id] = fn
        // 压表 + upvalue + 闭包 → setfield
        // 栈: [表] → pushinteger(id) → [表, id] → pushcclosure(吞掉 id) → [表, 闭包]
        // 表在 -2，闭包在 -1
        lua_rawgeti_cj(L, LUA_REGISTRYINDEX, table.ref)
        lua_pushinteger_cj(L, id)
        let cf: CFunc<(CPointer<Unit>) -> Int32> = { L2 => _dispatch(L2) }
        lua_pushcclosure_cj(L, cf, 1)
        let cs = unsafe { LibC.mallocCString(name) }
        lua_setfield_cj(L, -2, cs)
        unsafe { LibC.free(cs) }
        lua_settop_cj(L, -2)
        return id
    }

    /**
     * @brief[zh-cn] 按注册 id 移除回调
     * @explain[zh-cn] 清空全局注册表条目；Lua 侧引用仍存在但调用无效果。
     * @param[zh-cn] id 注册时返回的回调 id
     *
     * @brief[en] Removes a callback by its registered id
     * @explain[en] Clears the entry from the global registry; the Lua-side reference still
     * exists but calling it has no effect.
     * @param[en] id The callback id returned at registration
     */
    public static func unregister(id: Int64): Unit {
        if (_handlers.contains(id)) {
            _handlers.remove(id)
        }
    }

    /**
     * @brief[zh-cn] 当前注册的回调数量
     *
     * @brief[en] The number of currently registered callbacks
     */
    public static prop handlerCount: Int64 {
        get() { Int64(_handlers.size) }
    }

    // =========================================================================
    // C 分发函数（CFunc，不能捕获变量 —— 只访问全局注册表）
    // =========================================================================

    /// Lua 调用仓颉函数的统一分发入口
    private static func _dispatch(L: CPointer<Unit>): Int32 {
        // 1. 从 upvalue 1 取回 id（lua_upvalueindex(1) = LUA_GLOBALSINDEX - 1）
        let id = lua_tointeger_cj(L, _UPVALUE1)
        // 2. 查全局注册表
        let handler = _handlers.get(id)
        match (handler) {
            case None =>
                // 未注册（可能已 unregister）：Lua 报错
                let cs = unsafe { LibC.mallocCString("handler not registered") }
                lua_pushstring_cj(L, cs)
                unsafe { LibC.free(cs) }
                return lua_error_cj(L)
            case Some(h) =>
                // 3. 读取参数（栈上全部）
                let nargs = lua_gettop_cj(L)
                var args = Array<LuaValue>(Int64(nargs), { _ => LuaValue.Nil })
                for (i in 0..nargs) {
                    args[Int64(i)] = LuaVM.readValue(L, i + 1)
                }
                // 4. 调用仓颉回调
                let results = h(args)
                // 5. 压返回值
                for (v in results) {
                    LuaVM.pushValue(L, v)
                }
                // 6. 返回返回值数量
                return Int32(results.size)
        }
    }
}
