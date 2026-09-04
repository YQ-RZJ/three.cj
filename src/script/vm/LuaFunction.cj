/**
 * @file[zh-cn] LuaFunction Lua 函数引用封装（three.script.vm 子包）
 * @brief[zh-cn] Lua 函数引用封装，包装 Lua 侧的函数并支持调用
 * @explain[zh-cn] 包装 Lua 侧的函数（function），内部经 luaL_ref 注册表引用保持有效，
 * 提供 call() 调用（任意参数 → 任意返回值）与参数/返回值 LuaValue 转换。
 *
 * @file[en] LuaFunction  Lua function reference wrapper (three.script.vm sub-package)
 * @brief[en] Lua function reference wrapper encapsulating a Lua function and supporting calls
 * @explain[en] Wraps a Lua function; internally the reference is kept alive via luaL_ref
 * registry references. Provides call() with arbitrary arguments/results and
 * LuaValue conversion for arguments and return values.
 *
 * @example[zh-cn] 编译并调用一个加法函数
 * @example[en] Compiling and calling an addition function
 * let f = vm.loadString("function(a, b) return a + b, a * b end")
 * let r = f.call([LuaValue.of(3.0), LuaValue.of(4.0)])
 * r[0].numberValue() == 7.0   // a+b
 * r[1].numberValue() == 12.0  // a*b
 */
package three.script.vm

import std.collection.*
import luajit4cj.luajit.*

/**
 * @brief[zh-cn] Lua 函数引用
 * @explain[zh-cn] 持有注册表引用，可重复调用、查询有效性并在无需使用时释放。
 *
 * @brief[en] Lua function reference
 * @explain[en] Holds a registry reference; can be called repeatedly, queried for
 * validity and released when no longer needed.
 */
public class LuaFunction {
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
     * @brief[zh-cn] 从全局变量获取函数引用（非函数则返回 null）
     * @param[zh-cn] vm   目标虚拟机
     * name 全局变量名
     * @return[zh-cn] 函数引用；若全局变量不存在或不是函数则返回 None
     *
     * @brief[en] Gets a function reference from a global variable (null when not a function)
     * @param[en] vm   The target virtual machine
     * name The global variable name
     * @return[en] The function reference, or None if the global is missing or not a function
     */
    public static func fromGlobal(vm: LuaVM, name: String): Option<LuaFunction> {
        let L = vm.handle()
        if (L.isNull()) { return None }
        let cs = _toCString(name)
        lua_getfield_cj(L, LUA_GLOBALSINDEX, cs)
        _freeCString(cs)
        let t = lua_type_cj(L, -1)
        if (t != 6) {  // LUA_TFUNCTION
            lua_settop_cj(L, -2)
            return None
        }
        let ref = luaL_ref_cj(L, LUA_REGISTRYINDEX)
        return Some(LuaFunction(vm: vm, ref: ref))
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
    // 调用
    // =========================================================================

    /**
     * @brief[zh-cn] 调用函数
     * @param[zh-cn] args 参数数组（LuaValue；空数组 = 无参数）
     * @return[zh-cn] 返回值数组（可能为空）
     *
     * @brief[en] Calls the function
     * @param[en] args Argument array (LuaValue; empty array means no arguments)
     * @return[en] The result array (may be empty)
     *
     * @throws[zh-cn] LuaError 运行时错误
     * @throws[en] LuaError On a runtime error
     */
    public func call(args!: Array<LuaValue> = []): Array<LuaValue> {
        let L = this._vm.handle()
        // 1. 压函数
        lua_rawgeti_cj(L, LUA_REGISTRYINDEX, this._ref)
        // 2. 压参数
        for (v in args) {
            _pushValue(L, v)
        }
        // 3. 保护调用
        let nargs = Int32(args.size)
        let rc = lua_pcall_cj(L, nargs, LUA_MULTRET, 0)
        if (rc != LUA_OK) {
            // 错误消息在栈顶
            let isStr = lua_isstring_cj(L, -1)
            var msg = "Lua call error (code ${rc})"
            if (isStr != 0) {
                let cs = lua_tolstring_cj(L, -1, CPointer<UIntNative>())
                if (!cs.isNull()) {
                    msg = unsafe { cs.toString() }
                }
            }
            lua_settop_cj(L, 0)
            throw LuaError(msg, code: rc)
        }
        // 4. 收集返回值
        let n = lua_gettop_cj(L)
        var results = Array<LuaValue>(Int64(n), { _ => LuaValue.Nil })
        for (i in 0..n) {
            results[Int64(i)] = _readValue(L, i + 1)
        }
        lua_settop_cj(L, 0)
        return results
    }
}
