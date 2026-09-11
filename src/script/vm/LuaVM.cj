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
 * @file[zh-cn] LuaVM LuaJIT 脚本虚拟机高级封装（three.script.vm 子包）
 * @brief[zh-cn] LuaJIT 脚本虚拟机高级封装，提供安全、易用的 Lua 脚本引擎
 * @explain[zh-cn] 在 luajit4cj 的 CFFI 之上提供安全、易用的 Lua 脚本引擎。能力覆盖：
 * - 生命周期：luaL_newstate / luaL_openlibs / lua_close
 * - 动态解析：luaL_loadstring / luaL_loadbuffer / luaL_loadfile
 * - 执行：lua_pcall（保护调用，错误抛 LuaError）
 * - 全局变量读写、栈操作、表创建、函数调用
 * - GC 控制（lua_gc）、JIT 控制（luaJIT_setmode）
 * - 错误处理：统一抛 LuaError（携带错误码 + 消息）
 *
 * @file[en] LuaVM  High-level LuaJIT scripting VM wrapper (three.script.vm sub-package)
 * @brief[en] High-level LuaJIT scripting VM wrapper providing a safe, easy-to-use Lua engine
 * @explain[en] Provides a safe, easy-to-use Lua scripting engine on top of luajit4cj's CFFI.
 * Feature coverage:
 * - Lifecycle: luaL_newstate / luaL_openlibs / lua_close
 * - Dynamic parsing: luaL_loadstring / luaL_loadbuffer / luaL_loadfile
 * - Execution: lua_pcall (protected call; errors are thrown as LuaError)
 * - Global read/write, stack operations, table creation, function calls
 * - GC control (lua_gc), JIT control (luaJIT_setmode)
 * - Error handling: unified LuaError (carrying the error code + message)
 *
 * @example[zh-cn] 创建虚拟机、执行脚本并释放
 * @example[en] Creating a VM, executing a script and releasing it
 * let vm = LuaVM()                       // 创建状态机 + 打开标准库
 * let r = vm.doString("return 1 + 2")    // 动态解析 + 执行，返回多值
 * vm.setGlobal("player", LuaValue.of("Alice"))
 * let fn = vm.loadString("function(a,b) return a*b end")  // 编译
 * vm.dispose()                           // 关闭状态机
 */
package three.script.vm

import std.collection.*
import three.core.math.*
import luajit4cj.luajit.*

// =============================================================================
// Option<String> 空值（避免与 luajit4cj.LuaType.None 枚举构造器歧义）
// =============================================================================

/**
 * @brief[zh-cn] 类型化的 None（用于 _doChunk/_loadChunk 的 Option<String> 参数）
 *
 * @brief[en] Typed None (used for the Option<String> parameters of _doChunk/_loadChunk)
 */
private let _NO_STR: Option<String> = None

// =============================================================================
// LuaVM：脚本虚拟机（持有 lua_State 句柄）
// =============================================================================

/**
 * @brief[zh-cn] Lua 脚本虚拟机
 * @explain[zh-cn] 持有 lua_State 句柄，封装 Lua 状态机的创建、执行、全局读写与资源释放。
 *
 * @brief[en] Lua scripting virtual machine
 * @explain[en] Holds a lua_State handle and wraps Lua state creation, execution,
 * global access and resource release.
 *
 * @note[zh-cn] 线程安全说明：Lua 状态机不是线程安全的，同一 LuaVM 实例应仅在
 * 单线程内使用；如跨线程需要各自创建独立 LuaVM。
 * @note[en] Thread-safety: Lua states are not thread-safe. A LuaVM instance should only
 * be used within a single thread; create separate LuaVM instances across threads.
 */
public class LuaVM {
    /**
     * @brief[zh-cn] lua_State 句柄（null 表示已关闭）
     *
     * @brief[en] The lua_State handle (null means closed)
     */
    private var _L: CPointer<Unit>

    /**
     * @brief[zh-cn] 是否已打开标准库
     *
     * @brief[en] Whether the standard libraries have been opened
     */
    private var _libsOpened: Bool

    /**
     * @brief[zh-cn] 创建 Lua 状态机
     * @param[zh-cn] openLibs 是否打开标准库（base/string/table/math/io/os 等）
     *
     * @brief[en] Creates a Lua state
     * @param[en] openLibs Whether to open the standard libraries (base/string/table/math/io/os etc.)
     *
     * @throws[zh-cn] LuaError 创建失败时抛出
     * @throws[en] LuaError Thrown when the state cannot be created
     */
    public init(openLibs!: Bool = true) {
        let L = luaL_newstate_cj()
        if (L.isNull()) {
            throw LuaError("无法创建 Lua 状态机", code: 4)
        }
        this._L = L
        this._libsOpened = false
        if (openLibs) {
            this.openLibs()
        }
    }

    /**
     * @brief[zh-cn] 打开全部标准库（base/package/string/table/math/io/os/debug/jit/ffi 等）
     *
     * @brief[en] Opens all standard libraries (base/package/string/table/math/io/os/debug/jit/ffi etc.)
     */
    public func openLibs(): Unit {
        if (!this._L.isNull()) {
            luaL_openlibs_cj(this._L)
            this._libsOpened = true
        }
    }

    /**
     * @brief[zh-cn] 是否已打开标准库
     *
     * @brief[en] Whether the standard libraries have been opened
     */
    public prop libsOpened: Bool {
        get() { this._libsOpened }
    }

    /**
     * @brief[zh-cn] 底层 lua_State 句柄（供 LuaBinder/LuaTable 等高级封装使用）
     *
     * @brief[en] The underlying lua_State handle (for LuaBinder/LuaTable and other wrappers)
     */
    public func handle(): CPointer<Unit> {
        return this._L
    }

    /**
     * @brief[zh-cn] 状态机是否有效（未被 dispose）
     *
     * @brief[en] Whether the state is still valid (not disposed)
     */
    public prop isValid: Bool {
        get() { !this._L.isNull() }
    }

    /**
     * @brief[zh-cn] 关闭状态机并释放资源（之后 handle() 失效）
     *
     * @brief[en] Closes the state and releases resources (handle() becomes invalid afterwards)
     */
    public func dispose(): Unit {
        if (!this._L.isNull()) {
            lua_close_cj(this._L)
            this._L = CPointer<Unit>()
        }
        this._libsOpened = false
    }

    // =========================================================================
    // 动态解析 + 执行
    // =========================================================================

    /**
     * @brief[zh-cn] 从字符串加载并执行 Lua 代码（动态解析）
     * @param[zh-cn] chunk Lua 源码字符串
     * @return[zh-cn] 返回值数组（可能为空）
     *
     * @brief[en] Loads and executes Lua code from a string (dynamic parsing)
     * @param[en] chunk The Lua source string
     * @return[en] The result array (may be empty)
     *
     * @throws[zh-cn] LuaError 语法错误或运行时错误
     * @throws[en] LuaError On a syntax or runtime error
     * @note[zh-cn] 用法示例：
     * @note[en] Example usage:
     * let r = vm.doString("return 1 + 2, 'hi'")
     * r[0].numberValue() == 3.0; r[1].stringValue() == "hi"
     */
    public func doString(chunk: String): Array<LuaValue> {
        return this._doChunk(chunk, _NO_STR, _NO_STR)
    }

    /**
     * @brief[zh-cn] 从字节缓冲区加载并执行 Lua 代码（二进制 chunk 或源码）
     * @param[zh-cn] code 源码或预编译字节码字符串
     * name chunk 名（用于错误消息，默认 "=(buffer)"）
     * @return[zh-cn] 返回值数组
     *
     * @brief[en] Loads and executes Lua code from a byte buffer (binary chunk or source)
     * @param[en] code The source or precompiled bytecode string
     * name The chunk name (used in error messages, default "=(buffer)")
     * @return[en] The result array
     *
     * @throws[zh-cn] LuaError 语法错误或运行时错误
     * @throws[en] LuaError On a syntax or runtime error
     */
    public func doBuffer(code: String, name!: String = "=(buffer)"): Array<LuaValue> {
        return this._doChunk(code, name, _NO_STR)
    }

    /**
     * @brief[zh-cn] 从文件加载并执行 Lua 脚本
     * @param[zh-cn] path Lua 脚本文件路径
     * @return[zh-cn] 返回值数组
     *
     * @brief[en] Loads and executes a Lua script from a file
     * @param[en] path The Lua script file path
     * @return[en] The result array
     *
     * @throws[zh-cn] LuaError 文件不存在 / 语法错误 / 运行时错误
     * @throws[en] LuaError When the file is missing, or on a syntax/runtime error
     */
    public func doFile(path: String): Array<LuaValue> {
        return this._doChunk(_NO_STR, _NO_STR, path)
    }

    /**
     * @brief[zh-cn] 统一执行入口：chunk/name/path 三选一（内部）
     * @param[zh-cn] code Lua 源码（仅当 path 为 None 时使用）
     * name chunk 名（可选）
     * path 文件路径（三选一）
     * @return[zh-cn] 返回值数组
     *
     * @brief[en] Unified execution entry: exactly one of chunk/name/path (internal)
     * @param[en] code The Lua source (used only when path is None)
     * name The chunk name (optional)
     * path The file path (one of the three)
     * @return[en] The array of return values
     */
    private func _doChunk(code: Option<String>, name: Option<String>,
                          path: Option<String>): Array<LuaValue> {
        let L = this._requireState()
        var rc: Int32 = 0
        // 1. 加载（解析 + 编译）
        match (path) {
            case Some(p) =>
                let cs = _toCString(p)
                rc = luaL_loadfile_cj(L, cs)
                _freeCString(cs)
            case None =>
                let src = code.getOrThrow()
                match (name) {
                    case Some(n) =>
                        let cs = _toCString(src)
                        let ns = _toCString(n)
                        // luaL_loadbuffer 需要 UTF-8 字节长度（String.size 是字符数）
                        rc = luaL_loadbuffer_cj(L, cs, UIntNative(src.toArray().size), ns)
                        _freeCString(cs)
                        _freeCString(ns)
                    case None =>
                        let cs = _toCString(src)
                        rc = luaL_loadstring_cj(L, cs)
                        _freeCString(cs)
                }
        }
        if (rc != LUA_OK) {
            // 编译错误：栈顶是错误消息
            let msg = this._popError()
            throw LuaError(msg, code: rc)
        }
        // 2. 执行（保护调用，允许多返回值）
        rc = lua_pcall_cj(L, 0, LUA_MULTRET, 0)
        if (rc != LUA_OK) {
            let msg = this._popError()
            throw LuaError(msg, code: rc)
        }
        // 3. 收集返回值
        let n = lua_gettop_cj(L)
        var results = Array<LuaValue>(Int64(n), { _ => LuaValue.Nil })
        for (i in 0..n) {
            results[Int64(i)] = _readValue(L, i + 1)
        }
        lua_settop_cj(L, 0) // 清空栈
        return results
    }

    // =========================================================================
    // 编译（load，不执行）
    // =========================================================================

    /**
     * @brief[zh-cn] 从字符串编译 Lua 代码但不执行，返回可重复调用的 LuaFunction
     * @param[zh-cn] chunk Lua 源码
     * @return[zh-cn] 编译后的函数
     *
     * @brief[en] Compiles Lua code from a string without executing it, returning a reusable LuaFunction
     * @param[en] chunk The Lua source
     * @return[en] The compiled function
     *
     * @throws[zh-cn] LuaError 语法错误
     * @throws[en] LuaError On a syntax error
     * @note[zh-cn] 用法示例：
     * @note[en] Example usage:
     * let f = vm.loadString("function(a,b) return a+b end")
     * let r = f.call([LuaValue.of(3.0), LuaValue.of(4.0)])
     */
    public func loadString(chunk: String): LuaFunction {
        return this._loadChunk(chunk, _NO_STR, _NO_STR)
    }

    /**
     * @brief[zh-cn] 从文件编译 Lua 代码但不执行，返回可重复调用的 LuaFunction
     * @param[zh-cn] path Lua 脚本文件路径
     * @return[zh-cn] 编译后的函数
     *
     * @brief[en] Compiles Lua code from a file without executing it, returning a reusable LuaFunction
     * @param[en] path The Lua script file path
     * @return[en] The compiled function
     *
     * @throws[zh-cn] LuaError 文件不存在 / 语法错误
     * @throws[en] LuaError When the file is missing or on a syntax error
     */
    public func loadFile(path: String): LuaFunction {
        return this._loadChunk(_NO_STR, _NO_STR, path)
    }

    /**
     * @brief[zh-cn] 统一编译入口（内部）：chunk/path 二选一
     * @param[zh-cn] code Lua 源码（仅当 path 为 None 时使用）
     * name chunk 名（可选）
     * path 文件路径（二选一）
     * @return[zh-cn] 编译后的 LuaFunction
     *
     * @brief[en] Unified compilation entry (internal): either chunk or path
     * @param[en] code The Lua source (used only when path is None)
     * name The chunk name (optional)
     * path The file path (one of the two)
     * @return[en] The compiled LuaFunction
     */
    private func _loadChunk(code: Option<String>, name: Option<String>,
                            path: Option<String>): LuaFunction {
        let L = this._requireState()
        var rc: Int32 = 0
        match (path) {
            case Some(p) =>
                let cs = _toCString(p)
                rc = luaL_loadfile_cj(L, cs)
                _freeCString(cs)
            case None =>
                let src = code.getOrThrow()
                let cs = _toCString(src)
                rc = luaL_loadstring_cj(L, cs)
                _freeCString(cs)
        }
        if (rc != LUA_OK) {
            let msg = this._popError()
            throw LuaError(msg, code: rc)
        }
        // 栈顶是编译后的函数 → 注册表引用
        let ref = luaL_ref_cj(L, LUA_REGISTRYINDEX)
        return LuaFunction(vm: this, ref: ref)
    }

    // =========================================================================
    // 全局变量读写
    // =========================================================================

    /**
     * @brief[zh-cn] 读取全局变量并返回 LuaValue
     * @param[zh-cn] name 全局变量名
     * @return[zh-cn] 变量值（不存在时为 LuaValue.Nil）
     *
     * @brief[en] Reads a global variable and returns it as a LuaValue
     * @param[en] name The global variable name
     * @return[en] The variable value (LuaValue.Nil if it does not exist)
     */
    public func getGlobal(name: String): LuaValue {
        let L = this._requireState()
        let cs = _toCString(name)
        lua_getfield_cj(L, LUA_GLOBALSINDEX, cs)
        _freeCString(cs)
        let v = _readValue(L, -1)
        lua_settop_cj(L, -2)
        return v
    }

    /**
     * @brief[zh-cn] 写入全局变量
     * @param[zh-cn] name 全局变量名
     * value 要写入的变量值
     *
     * @brief[en] Writes a global variable
     * @param[en] name The global variable name
     * value The value to write
     */
    public func setGlobal(name: String, value: LuaValue): Unit {
        let L = this._requireState()
        _pushValue(L, value)
        let cs = _toCString(name)
        lua_setfield_cj(L, LUA_GLOBALSINDEX, cs)
        _freeCString(cs)
    }

    /**
     * @brief[zh-cn] 判断全局变量是否存在
     * @param[zh-cn] name 全局变量名
     * @return[zh-cn] 变量存在且非 nil 时为 true
     *
     * @brief[en] Checks whether a global variable exists
     * @param[en] name The global variable name
     * @return[en] true if the variable exists and is not nil
     */
    public func hasGlobal(name: String): Bool {
        let v = this.getGlobal(name)
        return !v.isNil
    }

    // =========================================================================
    // 栈操作（高级用户）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取栈顶索引（即栈上元素个数）
     * @return[zh-cn] 栈顶索引
     *
     * @brief[en] Gets the top stack index (the number of elements on the stack)
     * @return[en] The top stack index
     */
    public func getTop(): Int32 {
        return lua_gettop_cj(this._requireState())
    }

    /**
     * @brief[zh-cn] 设置栈大小（负数 = 从栈顶移除 |n| 个元素）
     * @param[zh-cn] idx 目标栈顶索引（负数表示相对栈顶）
     *
     * @brief[en] Sets the stack size (a negative value removes |n| elements from the top)
     * @param[en] idx The target top index (negative values are relative to the top)
     */
    public func setTop(idx: Int32): Unit {
        lua_settop_cj(this._requireState(), idx)
    }

    /**
     * @brief[zh-cn] 从栈顶弹出 n 个元素
     * @param[zh-cn] n 要弹出的元素个数（默认 1）
     *
     * @brief[en] Pops n elements from the top of the stack
     * @param[en] n The number of elements to pop (default 1)
     */
    public func pop(n!: Int32 = 1): Unit {
        let top = lua_gettop_cj(this._requireState())
        lua_settop_cj(this._requireState(), top - n)
    }

    /**
     * @brief[zh-cn] 检查栈是否有足够空间（不足则尝试扩展，返回是否成功）
     * @param[zh-cn] n 需要的额外元素个数
     * @return[zh-cn] 空间充足或扩展成功时为 true
     *
     * @brief[en] Checks whether the stack has enough space (grows it if needed) and returns success
     * @param[en] n The number of additional elements needed
     * @return[en] true if there is enough space or the growth succeeded
     */
    public func checkStack(n: Int32): Bool {
        return lua_checkstack_cj(this._requireState(), n) != 0
    }

    // =========================================================================
    // 函数调用（对栈上函数对象）
    // =========================================================================

    /**
     * @brief[zh-cn] 调用栈顶函数（参数需已压栈）
     * @param[zh-cn] nargs 参数个数
     * nresults 期望返回值个数（LUA_MULTRET=-1 表示取全部）
     * @return[zh-cn] 返回值数组
     *
     * @brief[en] Calls the function on top of the stack (arguments must already be pushed)
     * @param[en] nargs The number of arguments
     * nresults The expected number of results (LUA_MULTRET=-1 means all)
     * @return[en] The result array
     *
     * @throws[zh-cn] LuaError 运行时错误
     * @throws[en] LuaError On a runtime error
     */
    public func callFunction(nargs: Int32, nresults!: Int32 = LUA_MULTRET): Array<LuaValue> {
        let L = this._requireState()
        let rc = lua_pcall_cj(L, nargs, nresults, 0)
        if (rc != LUA_OK) {
            let msg = this._popError()
            throw LuaError(msg, code: rc)
        }
        if (nresults == LUA_MULTRET) {
            let n = lua_gettop_cj(L)
            var results = Array<LuaValue>(Int64(n), { _ => LuaValue.Nil })
            for (i in 0..n) {
                results[Int64(i)] = _readValue(L, i + 1)
            }
            lua_settop_cj(L, 0)
            return results
        } else {
            var results = Array<LuaValue>(Int64(nresults), { _ => LuaValue.Nil })
            for (i in 0..nresults) {
                results[Int64(i)] = _readValue(L, i + 1)
            }
            lua_settop_cj(L, 0)
            return results
        }
    }

    // =========================================================================
    // 表操作（便捷）
    // =========================================================================

    /**
     * @brief[zh-cn] 创建新表并压栈（lua_createtable）
     * @param[zh-cn] narr 预分配的数组部分容量（默认 0）
     * nrec 预分配的哈希部分容量（默认 0）
     *
     * @brief[en] Creates a new table and pushes it onto the stack (lua_createtable)
     * @param[en] narr Pre-allocated array-part capacity (default 0)
     * nrec Pre-allocated hash-part capacity (default 0)
     */
    public func createTable(narr!: Int32 = 0, nrec!: Int32 = 0): Unit {
        lua_createtable_cj(this._requireState(), narr, nrec)
    }

    /**
     * @brief[zh-cn] 获取表字段（表在 idx，字段值压栈）——低层 API，供 LuaTable 使用
     * @param[zh-cn] idx 表的栈索引
     * name 字段名
     *
     * @brief[en] Gets a table field (table at idx; the field value is pushed) — low-level API for LuaTable
     * @param[en] idx The stack index of the table
     * name The field name
     */
    public func getField(idx: Int32, name: String): Unit {
        let cs = _toCString(name)
        lua_getfield_cj(this._requireState(), idx, cs)
        _freeCString(cs)
    }

    /**
     * @brief[zh-cn] 设置表字段（值已在栈顶，表在 idx）——低层 API，供 LuaTable 使用
     * @param[zh-cn] idx 表的栈索引
     * name 字段名
     *
     * @brief[en] Sets a table field (value already on top of the stack, table at idx) — low-level API for LuaTable
     * @param[en] idx The stack index of the table
     * name The field name
     */
    public func setField(idx: Int32, name: String): Unit {
        let cs = _toCString(name)
        lua_setfield_cj(this._requireState(), idx, cs)
        _freeCString(cs)
    }

    // =========================================================================
    // GC 控制
    // =========================================================================

    /**
     * @brief[zh-cn] 执行完整 GC 周期
     *
     * @brief[en] Performs a full GC cycle
     */
    public func gcCollect(): Unit {
        lua_gc_cj(this._requireState(), LUA_GCCOLLECT, 0)
    }

    /**
     * @brief[zh-cn] 停止 GC
     *
     * @brief[en] Stops the garbage collector
     */
    public func gcStop(): Unit {
        lua_gc_cj(this._requireState(), LUA_GCSTOP, 0)
    }

    /**
     * @brief[zh-cn] 重启 GC
     *
     * @brief[en] Restarts the garbage collector
     */
    public func gcRestart(): Unit {
        lua_gc_cj(this._requireState(), LUA_GCRESTART, 0)
    }

    /**
     * @brief[zh-cn] 获取当前内存使用量（KB，小数部分见 gcCountBytes）
     * @return[zh-cn] 内存使用量（KB 整数部分）
     *
     * @brief[en] Gets the current memory usage in KB (fractional part via gcCountBytes)
     * @return[en] The memory usage in KB (integer part)
     */
    public func gcCountKB(): Int64 {
        return Int64(lua_gc_cj(this._requireState(), LUA_GCCOUNT, 0))
    }

    /**
     * @brief[zh-cn] 获取当前内存使用量余数（字节）
     * @return[zh-cn] 内存使用量余数字节数
     *
     * @brief[en] Gets the remainder of the current memory usage (bytes)
     * @return[en] The byte remainder of the memory usage
     */
    public func gcCountBytes(): Int64 {
        return Int64(lua_gc_cj(this._requireState(), LUA_GCCOUNTB, 0))
    }

    /**
     * @brief[zh-cn] 执行 n 步增量 GC
     * @param[zh-cn] steps 增量步数
     * @return[zh-cn] GC 是否已完成一个周期（1 表示完成）
     *
     * @brief[en] Performs n steps of incremental GC
     * @param[en] steps The number of incremental steps
     * @return[en] Whether GC finished a cycle (1 means finished)
     */
    public func gcStep(steps: Int32): Int64 {
        return Int64(lua_gc_cj(this._requireState(), LUA_GCSTEP, steps))
    }

    // =========================================================================
    // JIT 控制（LuaJIT 特性）
    // =========================================================================

    /**
     * @brief[zh-cn] 启用 JIT 编译引擎
     * @return[zh-cn] 0 表示成功
     *
     * @brief[en] Enables the JIT compilation engine
     * @return[en] 0 on success
     */
    public func jitOn(): Int32 {
        return luaJIT_setmode_cj(this._requireState(), 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_ON)
    }

    /**
     * @brief[zh-cn] 禁用 JIT 编译引擎（回退解释执行）
     * @return[zh-cn] 0 表示成功
     *
     * @brief[en] Disables the JIT compilation engine (falls back to interpretation)
     * @return[en] 0 on success
     */
    public func jitOff(): Int32 {
        return luaJIT_setmode_cj(this._requireState(), 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_OFF)
    }

    // =========================================================================
    // 版本信息
    // =========================================================================

    /**
     * @brief[zh-cn] Lua 版本字符串（如 "Lua 5.1"）
     * @return[zh-cn] Lua 版本字符串
     *
     * @brief[en] The Lua version string (e.g. "Lua 5.1")
     * @return[en] The Lua version string
     */
    public static prop version: String {
        get() { LUA_VERSION }
    }

    /**
     * @brief[zh-cn] LuaJIT 版本字符串（如 "LuaJIT 2.1.x"）
     * @return[zh-cn] LuaJIT 版本字符串
     *
     * @brief[en] The LuaJIT version string (e.g. "LuaJIT 2.1.x")
     * @return[en] The LuaJIT version string
     */
    public static prop jitVersion: String {
        get() { LUAJIT_VERSION }
    }

    // =========================================================================
    // 内部工具
    // =========================================================================

    /**
     * @brief[zh-cn] 校验状态机有效，返回底层句柄
     * @return[zh-cn] 有效的 lua_State 句柄
     *
     * @throws[zh-cn] LuaError 状态机已关闭时抛出
     *
     * @brief[en] Validates that the state is valid and returns the underlying handle
     * @return[en] A valid lua_State handle
     *
     * @throws[en] LuaError Thrown when the state is closed
     */
    private func _requireState(): CPointer<Unit> {
        if (this._L.isNull()) {
            throw LuaError("Lua 状态机已关闭", code: 5)
        }
        return this._L
    }

    /**
     * @brief[zh-cn] 弹出栈顶错误消息并返回 String（pcall/load 失败时栈顶为错误）
     * @return[zh-cn] 错误消息字符串
     *
     * @brief[en] Pops the error message on top of the stack and returns it as a String
     * (the top of the stack holds the error when pcall/load fails)
     * @return[en] The error message string
     */
    private func _popError(): String {
        let L = this._L
        if (L.isNull()) { return "unknown error" }
        // 尝试取字符串；可能带 traceback 前缀，直接读取
        let isStr = lua_isstring_cj(L, -1)
        if (isStr != 0) {
            let cs = lua_tolstring_cj(L, -1, CPointer<UIntNative>())
            let s = if (cs.isNull()) { "(null error)" } else { unsafe { cs.toString() } }
            lua_settop_cj(L, -2)
            return s
        }
        lua_settop_cj(L, -2)
        return "Lua error (code ${lua_type_cj(L, 0)})"
    }

    // =========================================================================
    // 值转换（包内工具，供 LuaTable/LuaFunction/LuaBinder 使用）
    // =========================================================================

    /**
     * @brief[zh-cn] 从栈索引读取 LuaValue
     * @param[zh-cn] L 底层 lua_State 句柄
     * idx 栈索引
     * @return[zh-cn] 对应的 LuaValue（表/函数等返回 nil 占位）
     *
     * @brief[en] Reads a LuaValue from a stack index
     * @param[en] L The underlying lua_State handle
     * idx The stack index
     * @return[en] The corresponding LuaValue (nil placeholder for tables/functions etc.)
     */
    public static func readValue(L: CPointer<Unit>, idx: Int32): LuaValue {
        return _readValue(L, idx)
    }

    /**
     * @brief[zh-cn] 压入 LuaValue 到栈
     * @param[zh-cn] L 底层 lua_State 句柄
     * v 要压入的 LuaValue
     *
     * @brief[en] Pushes a LuaValue onto the stack
     * @param[en] L The underlying lua_State handle
     * v The LuaValue to push
     */
    public static func pushValue(L: CPointer<Unit>, v: LuaValue): Unit {
        _pushValue(L, v)
    }
}

// =============================================================================
// 包级工具函数（String ↔ CString、值转换）
// =============================================================================

/**
 * @brief[zh-cn] String → CString（malloc 分配，用完须调用 _freeCString 释放）
 * @param[zh-cn] s 待转换的字符串
 * @return[zh-cn] 转换后的 CString
 *
 * @brief[en] String → CString (malloc-allocated; call _freeCString when done)
 * @param[en] s The string to convert
 * @return[en] The converted CString
 */
internal func _toCString(s: String): CString {
    return unsafe { LibC.mallocCString(s) }
}

/**
 * @brief[zh-cn] 释放由 _toCString 分配的 CString
 * @param[zh-cn] cs 待释放的 CString
 *
 * @brief[en] Frees a CString allocated by _toCString
 * @param[en] cs The CString to free
 */
internal func _freeCString(cs: CString): Unit {
    unsafe { LibC.free(cs) }
}

/**
 * @brief[zh-cn] 从栈索引读取 LuaValue（基础类型；表/函数等返回 nil 占位，
 * 用 LuaTable/LuaFunction 访问）
 * @param[zh-cn] L 底层 lua_State 句柄
 * idx 栈索引
 * @return[zh-cn] 对应的 LuaValue
 *
 * @brief[en] Reads a LuaValue from a stack index (basic types; tables/functions etc.
 * return a nil placeholder, access them via LuaTable/LuaFunction)
 * @param[en] L The underlying lua_State handle
 * idx The stack index
 * @return[en] The corresponding LuaValue
 */
internal func _readValue(L: CPointer<Unit>, idx: Int32): LuaValue {
    let t = lua_type_cj(L, idx)
    match (t) {
        case 0 => return LuaValue.Nil            // LUA_TNIL
        case 1 =>                                // LUA_TBOOLEAN
            return LuaValue.Boolean(lua_toboolean_cj(L, idx) != 0)
        case 3 =>                                // LUA_TNUMBER
            // 判断是否为整数值：lua_tointegerx 的 isnum 对小数也返回 1（LuaJIT 同 Lua 5.1），
            // 不能用它区分整数/浮点。改用 tonumber 截断后回比：
            //   整数值满足 Float64(lua_tointeger) == lua_tonumber（如 42.0）
            //   小数值不满足（如 3.14 截断为 3，3.0 != 3.14）
            let n = lua_tonumber_cj(L, idx)
            let i = lua_tointeger_cj(L, idx)
            if (Float64(i) == n) {
                return LuaValue.Integer(i)
            }
            return LuaValue.Number(n)
        case 4 =>                                // LUA_TSTRING
            let cs = lua_tolstring_cj(L, idx, CPointer<UIntNative>())
            if (cs.isNull()) { return LuaValue.Str("") }
            return LuaValue.Str(unsafe { cs.toString() })
        case _ =>
            // table/function/userdata/thread/lightuserdata → nil 占位
            return LuaValue.Nil
    }
}

/**
 * @brief[zh-cn] 压入 LuaValue 到栈
 * @param[zh-cn] L 底层 lua_State 句柄
 * v 要压入的 LuaValue
 *
 * @brief[en] Pushes a LuaValue onto the stack
 * @param[en] L The underlying lua_State handle
 * v The LuaValue to push
 */
internal func _pushValue(L: CPointer<Unit>, v: LuaValue): Unit {
    match (v) {
        case LuaValue.Nil => lua_pushnil_cj(L)
        case LuaValue.Boolean(b) => lua_pushboolean_cj(L, if (b) { 1 } else { 0 })
        case LuaValue.Number(n) => lua_pushnumber_cj(L, n)
        case LuaValue.Integer(i) => lua_pushinteger_cj(L, i)
        case LuaValue.Str(s) =>
            let cs = _toCString(s)
            lua_pushstring_cj(L, cs)
            _freeCString(cs)
    }
}
