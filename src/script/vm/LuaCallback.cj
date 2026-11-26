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
 * @file[zh-cn] LuaCallback Lua 函数回调（three.script.vm 子包）
 * @brief[zh-cn] 包装 LuaValue.Function 引用，提供仓颉侧可重复调用的 Lua 函数回调
 * @explain[zh-cn] 由 LuaValue.Function(ref) 构造，持有 lua_State 快照与注册表引用；
 * call() 经 lua_pcall 保护调用，支持任意参数与多返回值；release() 释放注册表引用。
 * @example[zh-cn] 从全局函数构造回调并调用
 *
 * @file[en] LuaCallback  Lua function callback (three.script.vm sub-package)
 * @brief[en] Wraps a LuaValue.Function reference, providing a repeatable callable Lua callback
 * @explain[en] Built from LuaValue.Function(ref); holds a lua_State snapshot plus a registry
 * reference; call() uses protected lua_pcall with arbitrary arguments and multiple results;
 * release() frees the registry reference.
 * @example[en] Building a callback from a global function and calling it
 * let cb = LuaCallback.fromValue(vm, vm.getGlobal("onUpdate")).getOrThrow()
 * let r = cb.call([LuaValue.of(1.0), LuaValue.of(2.0)])
 * cb.release(vm)
 */
package three.script.vm

import std.sync.*
import three._vendor.luajit4cj.luajit.*
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] 当前线程的 Lua 回调重入深度（Lua → C 绑定 → 仓颉 → Lua 的嵌套层数）
 * @explain[zh-cn] 每个仓颉线程独立存储；仅在 LuaCallback.call 内维护。
 *
 * @brief[en] Lua callback reentry depth for the current thread (nesting of
 * Lua → C binding → Cangjie → Lua); per-Cangjie-thread, maintained inside LuaCallback.call.
 */
private let _reentryDepth = ThreadLocal<Int64>()

// 运行时内部导出（libcangjie-runtime）：仅用于读取当前线程栈的配置大小与保留区。
// 实测二者语义稳定；不读取当前 SP（运行时未导出该能力）。
foreign func CJ_CJThreadStackSizeGet(): Int64

foreign func CJ_CJThreadStackReversedGet(): Int64

/// 自适应估算中「每次重入」预留的保守栈开销（含 LuaJIT C 帧 + 绑定分派 + 引擎调用链）
private const _REENTRY_LAYER_COST: Int64 = 64 * 1024
/// 自适应估算中额外预留的安全余量
private const _REENTRY_SAFETY_MARGIN: Int64 = 64 * 1024
/// 运行时无法提供栈大小时的回退上限
private const _REENTRY_FALLBACK_LIMIT: Int64 = 32

/**
 * @brief[zh-cn] Lua 函数回调
 * @explain[zh-cn] 经 fromValue 从 LuaValue.Function(ref) 构造；call 执行保护调用，
 * release 释放注册表引用。回调不持有 LuaVM 引用本身，仅持有 lua_State 快照；
 * 所属 VM 关闭后 call 抛 LuaError。
 *
 * @brief[en] Lua function callback
 * @explain[en] Built via fromValue from a LuaValue.Function(ref); call performs a protected
 * call and release frees the registry reference. The callback does not hold the LuaVM itself,
 * only a lua_State snapshot; call throws LuaError once the owning VM is closed.
 */
public class LuaCallback <: IReleasable {
    /// lua_State 快照（由所属 VM 的 handle 取得；VM 关闭后失效判空）
    private var _L: CPointer<Unit>

    /// 注册表引用（LUA_REGISTRYINDEX 中的 ref id；0 表示已释放/无效）
    private var _ref: Int64

    /// 重入深度上限配置值（原子读写）
    private static let _reentryLimit = AtomicInt64(-1)

    /**
     * @brief[zh-cn] Lua 回调重入深度上限（默认 -1 = 按栈大小自适应）
     * @explain[zh-cn] Lua → C 绑定 → 仓颉 → Lua 的嵌套在每次 LuaCallback.call 时计数；
     * 达到上限即抛 LuaReentryLimitError，避免 C 栈打穿后退化为 LuaJIT 返回路径死循环。
     * 取值语义：
     * - `> 0`：固定上限，按设定值；
     * - `0`：不限制（关闭守卫，例如确认调用链深度可控时）；
     * - `< 0`（默认 `-1`）：自适应，按
     *   `(CJ_CJThreadStackSizeGet() - 保留区 - 安全余量) / 每层保守开销` 估算，
     *   因此调大 `cjStackSize` 时上限自动放大。
     *
     * @brief[en] Lua callback reentry depth limit (default -1 = adaptive from stack size).
     * @explain[en] Nesting of Lua → C binding → Cangjie → Lua is counted on each
     * LuaCallback.call; reaching the limit throws LuaReentryLimitError so a blown C stack
     * cannot degrade into a LuaJIT return-path infinite loop. Semantics:
     * `> 0` fixed limit; `0` unlimited (guard disabled); `< 0` (default `-1`) adaptive,
     * estimated as `(stackSize - reserved - safetyMargin) / perLayerCost`, so raising
     * `cjStackSize` automatically raises the limit.
     */
    public static mut prop reentryLimit: Int64 {
        get() {
            LuaCallback._reentryLimit.load()
        }
        set(v) {
            LuaCallback._reentryLimit.store(v)
        }
    }

    /// 解析实际生效的重入上限（0 表示不限制）
    private static func _resolveReentryLimit(): Int64 {
        let configured = LuaCallback._reentryLimit.load()
        if (configured >= 0) {
            return configured
        }
        // 自适应：只依赖运行时导出的「栈大小 / 保留区」，两者都是边界值，不随递归变化。
        var stackSize = 0
        var reserved = 0
        unsafe {
            stackSize = CJ_CJThreadStackSizeGet()
            reserved = CJ_CJThreadStackReversedGet()
        }
        if (stackSize <= 0) {
            return _REENTRY_FALLBACK_LIMIT
        }
        if (reserved < 0) {
            reserved = 0
        }
        let usable = stackSize - reserved - _REENTRY_SAFETY_MARGIN
        if (usable <= 0) {
            return 1
        }
        let estimate = usable / _REENTRY_LAYER_COST
        if (estimate < 1) {
            return 1
        }
        return estimate
    }

    /// 内部构造（经 fromValue 使用）
    internal init(L: CPointer<Unit>, ref: Int64) {
        this._L = L
        this._ref = ref
    }

    /**
     * @brief[zh-cn] 从 LuaValue 构造回调
     * @param[zh-cn] vm 所属虚拟机
     * @param[zh-cn] v 目标值（须为 LuaValue.Function(ref) 且 ref>0；VM 须有效）
     * @return[zh-cn] 回调；值不是函数引用或 VM 已关闭时返回 None
     *
     * @brief[en] Builds a callback from a LuaValue
     * @param[en] vm The owning virtual machine
     * @param[en] v   The target value (must be LuaValue.Function(ref) with ref>0; the VM must be valid)
     * @return[en] The callback, or None when the value is not a function reference or the VM is closed
     */
    public static func fromValue(vm: LuaVM, v: LuaValue): Option<LuaCallback> {
        if (v.isFunction && v.refId() > 0 && vm.releasable) {
            return Some(LuaCallback(vm.handle(), v.refId()))
        }
        return None
    }

    /**
     * @brief[zh-cn] 注册表引用 id
     *
     * @brief[en] The registry reference id
     */
    public prop ref: Int64 {
        get() {
            this._ref
        }
    }

    /**
     * @brief[zh-cn] 是否有效（未被释放且持有引用）
     *
     * @brief[en] Whether the callback is still usable (not released and holds a reference)
     */
    public prop releasable: Bool {
        get() {
            !this._L.isNull() && this._ref > 0
        }
    }

    /**
     * @brief[zh-cn] 调用 Lua 函数（保护调用，lua_pcall）
     * @param[zh-cn] args 参数数组（LuaValue；空数组 = 无参数）
     * @return[zh-cn] 返回值数组（可能为空；表/函数经 _readValue 转为引用变体）
     * @throws[zh-cn] LuaError 运行时错误，或 VM 已关闭/回调已释放；
     * LuaReentryLimitError 重入深度达到 LuaCallback.reentryLimit
     *
     * @brief[en] Calls the Lua function (protected lua_pcall)
     * @param[en] args The argument array (LuaValue; empty array means no arguments)
     * @return[en] The result array (may be empty; tables/functions become reference variants via _readValue)
     * @throws[en] LuaError On a runtime error, or when the VM is closed / the callback is released;
     * LuaReentryLimitError when nesting reaches LuaCallback.reentryLimit
     */
    public func call(args!: Array<LuaValue> = []): Array<LuaValue> {
        if (this._L.isNull() || this._ref <= 0) {
            throw LuaError("LuaCallback: VM 已关闭或回调已释放", code: 5)
        }
        // 0. 重入深度守卫：必须在 lua_pcall 之前判定。
        //    一旦 C 栈被打穿，执行已落到 LuaJIT 的返回桩，仓颉侧再也拿不到控制权，
        //    StackOverflowError / lua_pcall 错误码都不会产生。
        let limit = LuaCallback._resolveReentryLimit()
        let depth = _reentryDepth.get() ?? 0
        if (limit > 0 && depth >= limit) {
            throw LuaReentryLimitError(
                "LuaCallback: 回调重入深度 ${depth} 达到上限 ${limit}，已中止调用（防止 C 栈溢出）")
        }
        _reentryDepth.set(Some(depth + 1))
        try {
            return _invoke(args)
        } finally {
            _reentryDepth.set(Some(depth))
        }
    }

    /// 实际执行一次保护调用（重入守卫已在 call 中处理）
    private func _invoke(args: Array<LuaValue>): Array<LuaValue> {
        let L = this._L
        // 0. 记录调用前的栈基线：call 可能在绑定方法（C 分派）内部被调用，
        //    此时栈上已有外层帧，收尾必须只回退到基线，不能清空整个栈。
        let base = lua_gettop_cj(L)
        // 1. 取函数
        lua_rawgeti_cj(L, LUA_REGISTRYINDEX, Int32(this._ref))
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
            var msg = "LuaCallback call error (code ${rc})"
            if (isStr != 0) {
                let cs = lua_tolstring_cj(L, -1, CPointer<UIntNative>())
                if (!cs.isNull()) {
                    msg = unsafe { cs.toString() }
                }
            }
            lua_settop_cj(L, base)
            throw LuaError(msg, code: rc)
        }
        // 4. 收集返回值（相对基线之后的槽位）
        let n = lua_gettop_cj(L) - base
        var results = Array<LuaValue>(Int64(n), {_ => LuaValue.Nil})
        for (i in 0..n) {
            results[Int64(i)] = _readValue(L, base + i + 1)
        }
        lua_settop_cj(L, base)
        return results
    }

    /**
     * @brief[zh-cn] 释放注册表引用（IReleasable 无参实现；幂等）
     * @explain[zh-cn] 经持有的 _L 快照直接 luaL_unref（无需 vm 参数）；释放后 releasable
     * 变为 false，call 抛异常；重复调用返回 false，不二次释放。
     * @return[zh-cn] 本次调用真正执行了 unref 时返回 true；已释放（幂等命中）返回 false
     *
     * @brief[en] Releases the registry reference (IReleasable parameterless implementation; idempotent)
     * @explain[en] Calls luaL_unref directly via the held _L snapshot (no vm argument needed);
     * after release releasable becomes false and call throws; repeated calls return false
     * and never free twice.
     * @return[en] true if this call actually unref'd; false if already released (idempotent hit)
     */
    public func release(): Bool {
        if (this._ref <= 0) {
            return false
        }
        if (!this._L.isNull()) {
            luaL_unref_cj(this._L, LUA_REGISTRYINDEX, Int32(this._ref))
        }
        this._ref = 0
        return true
    }

    /**
     * @brief[zh-cn] 释放注册表引用（luaL_unref）
     * @param[zh-cn] vm 所属虚拟机（校验 VM 仍有效后再执行；已关闭则跳过释放并置无效）
     * @explain[zh-cn] 释放后 releasable 变为 false，call 抛异常；重复调用无副作用。
     *
     * @brief[en] Releases the registry reference (luaL_unref)
     * @param[en] vm The owning virtual machine (used to verify the VM is still valid; when
     * closed the release is skipped and the callback is invalidated)
     * @explain[en] After release releasable becomes false and call throws; repeated calls have no effect.
     */
    public func release(vm: LuaVM): Unit {
        if (this._ref <= 0) {
            return
        }
        if (vm.releasable && !this._L.isNull()) {
            luaL_unref_cj(this._L, LUA_REGISTRYINDEX, Int32(this._ref))
        }
        this._ref = 0
    }
}
